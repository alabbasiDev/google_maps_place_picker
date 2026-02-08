import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:google_maps_place_picker_mb/src/exceptions/location_exceptions.dart';
import 'package:google_maps_place_picker_mb/src/models/enums.dart';
import 'package:google_maps_place_picker_mb/src/models/pick_result.dart';
import 'package:flutter_google_maps_webservices/geocoding.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class PlaceProvider extends ChangeNotifier {
  PlaceProvider(
    String apiKey,
    String? proxyBaseUrl,
    Client? httpClient,
    Map<String, dynamic> apiHeaders,
  ) {
    places = GoogleMapsPlaces(
      apiKey: apiKey,
      baseUrl: proxyBaseUrl,
      httpClient: httpClient,
      apiHeaders: apiHeaders as Map<String, String>?,
    );
    geocoding = GoogleMapsGeocoding(
      apiKey: apiKey,
      baseUrl: proxyBaseUrl,
      httpClient: httpClient,
      apiHeaders: apiHeaders as Map<String, String>?,
    );
  }

  static PlaceProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<PlaceProvider>(context, listen: listen);

  late GoogleMapsPlaces places;
  late GoogleMapsGeocoding geocoding;
  String? sessionToken;
  LocationAccuracy? desiredAccuracy;
  bool isAutoCompleteSearching = false;

  bool _isLoadingLocation = false;

  bool get isLoadingLocation => _isLoadingLocation;

  set isLoadingLocation(bool value) {
    _isLoadingLocation = value;
    notifyListeners();
  }

  Future<void> updateCurrentLocation({bool gracefully = false}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print(
        'PlacePicker-PlaceProvider-updateCurrentLocation=>serviceEnabled=> $serviceEnabled');
    if (!serviceEnabled) {
      // if (gracefully) return;
      print(
          'PlacePicker-PlaceProvider-updateCurrentLocation=>GpsDisabledException');
      return Future.error(const GpsDisabledException());
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // if (gracefully) return;
        print(
            'PlacePicker-PlaceProvider-updateCurrentLocation=>LocationPermissionDeniedException');
        return Future.error(const LocationPermissionDeniedException());
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // if (gracefully) return;
      print(
          'PlacePicker-PlaceProvider-updateCurrentLocation=>LocationPermissionPermanentlyDeniedException');
      return Future.error(const LocationPermissionPermanentlyDeniedException());
    }

    print(
        'PlacePicker-PlaceProvider-updateCurrentLocation=>Geolocator.getCurrentPosition');
    try {
      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: desiredAccuracy ?? LocationAccuracy.medium,
          timeLimit: const Duration(minutes: 3),
        ),
      ).timeout(const Duration(minutes: 3), onTimeout: () {
        throw TimeoutException("Location request timed out");
      });
      print('PlacePicker-PlaceProvider-updateCurrentLocation=>currentPosition=> ${_currentPosition?.latitude}');
      // currentPosition = _currentPosition;
    } on TimeoutException catch (e) {
      // Handle the timeout exception (e.g., inform the user, retry with different settings)
      print("PlacePicker-Location request timed out: $e");

    } catch (e) {
      // Handle other potential errors (e.g., permission denied)
      print("PlacePicker-An error occurred: $e");
    }finally{
      isLoadingLocation = false;
    }
  }

  Position? _currentPosition;

  Position? get currentPosition => _currentPosition;

  set currentPosition(Position? newPosition) {
    _currentPosition = newPosition;
    print(
        'PlacePicker-PlaceProvider=>current-position-updated=> ${_currentPosition?.latitude}');
    notifyListeners();
  }

  Timer? _debounceTimer;

  Timer? get debounceTimer => _debounceTimer;

  set debounceTimer(Timer? timer) {
    _debounceTimer = timer;
    notifyListeners();
  }

  CameraPosition? _previousCameraPosition;

  CameraPosition? get prevCameraPosition => _previousCameraPosition;

  setPrevCameraPosition(CameraPosition? prePosition) {
    _previousCameraPosition = prePosition;
  }

  CameraPosition? _currentCameraPosition;

  CameraPosition? get cameraPosition => _currentCameraPosition;

  setCameraPosition(CameraPosition? newPosition) {
    _currentCameraPosition = newPosition;
  }

  PickResult? _selectedPlace;

  PickResult? get selectedPlace => _selectedPlace;

  set selectedPlace(PickResult? result) {
    _selectedPlace = result;
    notifyListeners();
  }

  SearchingState _placeSearchingState = SearchingState.Idle;

  SearchingState get placeSearchingState => _placeSearchingState;

  set placeSearchingState(SearchingState newState) {
    _placeSearchingState = newState;
    notifyListeners();
  }

  GoogleMapController? _mapController;

  GoogleMapController? get mapController => _mapController;

  set mapController(GoogleMapController? controller) {
    _mapController = controller;
    notifyListeners();
  }

  PinState _pinState = PinState.Preparing;

  PinState get pinState => _pinState;

  set pinState(PinState newState) {
    _pinState = newState;
    notifyListeners();
  }

  bool _isSeachBarFocused = false;

  bool get isSearchBarFocused => _isSeachBarFocused;

  set isSearchBarFocused(bool focused) {
    _isSeachBarFocused = focused;
    notifyListeners();
  }

  MapType _mapType = MapType.normal;

  MapType get mapType => _mapType;

  setMapType(MapType mapType, {bool notify = false}) {
    _mapType = mapType;
    if (notify) notifyListeners();
  }

  switchMapType() {
    _mapType = MapType.values[(_mapType.index + 1) % MapType.values.length];
    if (_mapType == MapType.none) _mapType = MapType.normal;
    notifyListeners();
  }
}
