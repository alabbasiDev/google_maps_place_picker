import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:google_maps_place_picker_mb/providers/place_provider.dart';
import 'package:google_maps_place_picker_mb/src/components/autocomplete_search.dart';
import 'package:google_maps_place_picker_mb/src/components/location_error_widgets.dart';
import 'package:google_maps_place_picker_mb/src/controllers/autocomplete_search_controller.dart';
import 'package:google_maps_place_picker_mb/src/google_map_place_picker.dart';
import 'package:google_maps_place_picker_mb/src/models/enums.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'models/location_error_configuration.dart';

typedef IntroModalWidgetBuilder = Widget Function(
  BuildContext context,
  Function? close,
);

/// Builder for custom location error widget.
///
/// Use this for complete control over the error UI. If you only need to
/// customize text and icons, use [LocationErrorConfiguration] instead.
typedef LocationErrorWidgetBuilder = Widget Function(
  BuildContext context,
  LocationErrorType errorType,
  VoidCallback onRetry,
);

final Logger logger = Logger();

class PlacePicker extends StatefulWidget {
  const PlacePicker({
    super.key,
    required this.apiKey,
    this.onPlacePicked,
    required this.initialPosition,
    this.useCurrentLocation = false,
    this.desiredLocationAccuracy = LocationAccuracy.high,
    this.onMapCreated,
    this.hintText,
    this.searchingText,
    this.selectText,
    this.outsideOfPickAreaText,
    this.onAutoCompleteFailed,
    this.onGeocodingSearchFailed,
    this.proxyBaseUrl,
    this.httpClient,
    this.selectedPlaceWidgetBuilder,
    this.pinBuilder,
    this.introModalWidgetBuilder,
    this.autoCompleteDebounceInMilliseconds = 500,
    this.cameraMoveDebounceInMilliseconds = 750,
    this.initialMapType = MapType.normal,
    this.enableMapTypeButton = true,
    this.enableMyLocationButton = true,
    this.myLocationButtonCooldown = 10,
    this.usePinPointingSearch = true,
    this.usePlaceDetailSearch = false,
    this.autocompleteOffset,
    this.autocompleteRadius,
    this.autocompleteLanguage,
    this.autocompleteComponents,
    this.autocompleteTypes,
    this.strictbounds,
    this.region,
    this.pickArea,
    this.selectInitialPosition = false,
    this.resizeToAvoidBottomInset = true,
    this.initialSearchString,
    this.searchForInitialValue = false,
    this.forceSearchOnZoomChanged = false,
    this.automaticallyImplyAppBarLeading = true,
    this.autocompleteOnTrailingWhitespace = false,
    this.hidePlaceDetailsWhenDraggingPin = true,
    this.ignoreLocationPermissionErrors = false,
    this.onTapBack,
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.onCameraIdle,
    this.onMapTypeChanged,
    this.zoomGesturesEnabled = true,
    this.zoomControlsEnabled = false,
    this.locationErrorWidgetBuilder,
    this.locationErrorConfiguration,
  });

  final String apiKey;

  final LatLng initialPosition;
  final bool useCurrentLocation;
  final LocationAccuracy desiredLocationAccuracy;

  final String? hintText;
  final String? searchingText;
  final String? selectText;
  final String? outsideOfPickAreaText;

  final ValueChanged<String>? onAutoCompleteFailed;
  final ValueChanged<String>? onGeocodingSearchFailed;
  final int autoCompleteDebounceInMilliseconds;
  final int cameraMoveDebounceInMilliseconds;

  final MapType initialMapType;
  final bool enableMapTypeButton;
  final bool enableMyLocationButton;

  /// Deprecated: No longer used. A loading spinner is shown instead.
  @Deprecated(
      'No longer used. Loading spinner is shown while fetching location.')
  final int myLocationButtonCooldown;

  final bool usePinPointingSearch;
  final bool usePlaceDetailSearch;

  final num? autocompleteOffset;
  final num? autocompleteRadius;
  final String? autocompleteLanguage;
  final List<String>? autocompleteTypes;
  final List<Component>? autocompleteComponents;
  final bool? strictbounds;
  final String? region;

  /// If set the picker can only pick addresses in the given circle area.
  /// The section will be highlighted.
  final CircleArea? pickArea;

  /// If true the [body] and the scaffold's floating widgets should size
  /// themselves to avoid the onscreen keyboard whose height is defined by the
  /// ambient [MediaQuery]'s [MediaQueryData.viewInsets] `bottom` property.
  ///
  /// For example, if there is an onscreen keyboard displayed above the
  /// scaffold, the body can be resized to avoid overlapping the keyboard, which
  /// prevents widgets inside the body from being obscured by the keyboard.
  ///
  /// Defaults to true.
  final bool resizeToAvoidBottomInset;

  final bool selectInitialPosition;

  /// By using default setting of Place Picker, it will result result when user hits the select here button.
  ///
  /// If you managed to use your own [selectedPlaceWidgetBuilder], then this WILL NOT be invoked, and you need use data which is
  /// being sent with [selectedPlaceWidgetBuilder].
  final ValueChanged<PickResult>? onPlacePicked;

  /// optional - builds selected place's UI
  ///
  /// It is provided by default if you leave it as a null.
  /// INPORTANT: If this is non-null, [onPlacePicked] will not be invoked, as there will be no default 'Select here' button.
  final SelectedPlaceWidgetBuilder? selectedPlaceWidgetBuilder;

  /// optional - builds customized pin widget which indicates current pointing position.
  ///
  /// It is provided by default if you leave it as a null.
  final PinBuilder? pinBuilder;

  /// optional - builds customized introduction panel.
  ///
  /// None is provided / the map is instantly accessible if you leave it as a null.
  final IntroModalWidgetBuilder? introModalWidgetBuilder;

  /// optional - sets 'proxy' value in google_maps_webservice
  ///
  /// In case of using a proxy the baseUrl can be set.
  /// The apiKey is not required in case the proxy sets it.
  /// (Not storing the apiKey in the app is good practice)
  final String? proxyBaseUrl;

  /// optional - set 'client' value in google_maps_webservice
  ///
  /// In case of using a proxy url that requires authentication
  /// or custom configuration
  final BaseClient? httpClient;

  /// Initial value of autocomplete search
  final String? initialSearchString;

  /// Whether to search for the initial value or not
  final bool searchForInitialValue;

  /// Allow searching place when zoom has changed. By default searching is disabled when zoom has changed in order to prevent unwilling API usage.
  final bool forceSearchOnZoomChanged;

  /// Whether to display appbar backbutton. Defaults to true.
  final bool automaticallyImplyAppBarLeading;

  /// Will perform an autocomplete search, if set to true. Note that setting
  /// this to true, while providing a smoother UX experience, may cause
  /// additional unnecessary queries to the Places API.
  ///
  /// Defaults to false.
  final bool autocompleteOnTrailingWhitespace;

  /// Whether to hide place details when dragging pin. Defaults to true.
  final bool hidePlaceDetailsWhenDraggingPin;

  /// Whether to ignore location permission errors. Defaults to false.
  /// If this is set to `true` the UI will be blocked.
  final bool ignoreLocationPermissionErrors;

  // Raised when clicking on the back arrow.
  // This will not listen for the system back button on Android devices.
  // If this is not set, but the back button is visible through automaticallyImplyLeading,
  // the Navigator will try to pop instead.
  final VoidCallback? onTapBack;

  /// GoogleMap pass-through events:

  /// Callback method for when the map is ready to be used.
  ///
  /// Used to receive a [GoogleMapController] for this [GoogleMap].
  final MapCreatedCallback? onMapCreated;

  /// Called when the camera starts moving.
  ///
  /// This can be initiated by the following:
  /// 1. Non-gesture animation initiated in response to user actions.
  ///    For example: zoom buttons, my location button, or marker clicks.
  /// 2. Programmatically initiated animation.
  /// 3. Camera motion initiated in response to user gestures on the map.
  ///    For example: pan, tilt, pinch to zoom, or rotate.
  final Function(PlaceProvider)? onCameraMoveStarted;

  /// Called repeatedly as the camera continues to move after an
  /// onCameraMoveStarted call.
  ///
  /// This may be called as often as once every frame and should
  /// not perform expensive operations.
  final CameraPositionCallback? onCameraMove;

  /// Called when camera movement has ended, there are no pending
  /// animations and the user has stopped interacting with the map.
  final Function(PlaceProvider)? onCameraIdle;

  /// Called when the map type has been changed.
  final Function(MapType)? onMapTypeChanged;

  /// Toggle on & off zoom gestures
  final bool zoomGesturesEnabled;

  /// Allow user to make visible the zoom button
  final bool zoomControlsEnabled;

  /// Optional - builds completely customized location error widget.
  ///
  /// If not provided, default solution widgets will be shown based on error type.
  /// Use this for complete control over the error UI.
  ///
  /// If you only need to customize text and icons, use [locationErrorConfiguration] instead.
  final LocationErrorWidgetBuilder? locationErrorWidgetBuilder;

  /// Configuration for all location error widgets.
  ///
  /// Customize icons, colors, titles, messages, button texts, and instruction steps
  /// for all error types (GPS disabled, permission denied, permission permanently
  /// denied, and unknown errors).
  ///
  /// **Auto-detection:** If not provided, the configuration will be automatically
  /// selected based on the device's locale. Currently supports:
  /// - English (en) - default
  /// - Arabic (ar)
  ///
  /// Use factory constructors for explicit language selection:
  /// - [LocationErrorConfiguration.english]
  /// - [LocationErrorConfiguration.arabic]
  /// - [LocationErrorConfiguration.fromLocale] for custom locale
  ///
  /// Or create a custom instance for full translation control.
  ///
  /// Example:
  /// ```dart
  /// // Auto-detect (recommended)
  /// PlacePicker(
  ///   // locationErrorConfiguration is automatically detected from device locale
  /// )
  ///
  /// // Explicit language
  /// PlacePicker(
  ///   locationErrorConfiguration: LocationErrorConfiguration.arabic(),
  /// )
  ///
  /// // Custom translation
  /// PlacePicker(
  ///   locationErrorConfiguration: LocationErrorConfiguration(
  ///     gpsDisabledTitle: 'Your translated title',
  ///     // ... other translations
  ///   ),
  /// )
  /// ```
  final LocationErrorConfiguration? locationErrorConfiguration;

  @override
  State<PlacePicker> createState() => _PlacePickerState();
}

class _PlacePickerState extends State<PlacePicker> {
  GlobalKey appBarKey = GlobalKey();
  Future<PlaceProvider>? _futureProvider;
  PlaceProvider? provider;
  SearchBarController searchBarController = SearchBarController();
  bool showIntroModal = true;

  @override
  void initState() {
    super.initState();
    _futureProvider = _initPlaceProvider();
  }

  void _retryInitialization() {
    setState(() {
      _futureProvider = _initPlaceProvider();
    });
  }

  LocationErrorType _parseLocationError(Object error) {
    return switch (error) {
      GpsDisabledException() => LocationErrorType.locationServiceDisabled,
      LocationPermissionDeniedException() => LocationErrorType.permissionDenied,
      LocationPermissionPermanentlyDeniedException() =>
        LocationErrorType.permissionDeniedForever,
      _ => LocationErrorType.unknown,
    };
  }

  @override
  void dispose() {
    searchBarController.dispose();

    super.dispose();
  }

  Future<PlaceProvider> _initPlaceProvider() async {
    final headers = await const GoogleApiHeaders().getHeaders();
    final provider = PlaceProvider(
      widget.apiKey,
      widget.proxyBaseUrl,
      widget.httpClient,
      headers,
    );
    provider.sessionToken = const Uuid().v4();
    provider.desiredAccuracy = widget.desiredLocationAccuracy;
    provider.setMapType(widget.initialMapType);
    if (widget.useCurrentLocation) {
      await provider.updateCurrentLocation(
          gracefully: widget.ignoreLocationPermissionErrors);
    }
    return provider;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          searchBarController.clearOverlay();
          return Future.value(true);
        },
        child: FutureBuilder<PlaceProvider>(
          future: _futureProvider,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              logger.e(snapshot.error);
              final error = snapshot.error;
              final errorType = _parseLocationError(error!);

              return Scaffold(
                appBar: AppBar(
                  elevation: 1,
                ),
                body: widget.locationErrorWidgetBuilder?.call(
                      context,
                      errorType,
                      _retryInitialization,
                    ) ??
                    DefaultLocationErrorWidget(
                      errorType: errorType,
                      error: error,
                      onRetry: _retryInitialization,
                      config: widget.locationErrorConfiguration,
                    ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              provider = snapshot.data;
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider<PlaceProvider>.value(value: provider!),
                ],
                child: Stack(children: [
                  Scaffold(
                    key: ValueKey<int>(provider.hashCode),
                    resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
                    extendBodyBehindAppBar: true,
                    appBar: AppBar(
                      key: appBarKey,
                      automaticallyImplyLeading: false,
                      iconTheme: Theme.of(context).iconTheme,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      titleSpacing: 0.0,
                      title: _SearchBarWidget(
                        provider: provider!,
                        appBarKey: appBarKey,
                        searchBarController: searchBarController,
                        showBackButton: provider!.placeSearchingState ==
                                SearchingState.Idle &&
                            (widget.automaticallyImplyAppBarLeading ||
                                widget.onTapBack != null),
                        onBackPressed: _handleBackButton,
                        onPicked: (prediction) {
                          if (mounted) _pickPrediction(prediction);
                        },
                        onSearchFailed: widget.onAutoCompleteFailed,
                        hintText: widget.hintText,
                        searchingText: widget.searchingText,
                        debounceMilliseconds:
                            widget.autoCompleteDebounceInMilliseconds,
                        autocompleteOffset: widget.autocompleteOffset,
                        autocompleteRadius: widget.autocompleteRadius,
                        autocompleteLanguage: widget.autocompleteLanguage,
                        autocompleteComponents: widget.autocompleteComponents,
                        autocompleteTypes: widget.autocompleteTypes,
                        strictbounds: widget.strictbounds,
                        region: widget.region,
                        initialSearchString: widget.initialSearchString,
                        searchForInitialValue: widget.searchForInitialValue,
                        autocompleteOnTrailingWhitespace:
                            widget.autocompleteOnTrailingWhitespace,
                      ),
                    ),
                    body: _MapWithLocation(
                      provider: provider!,
                      initialPosition: widget.initialPosition,
                      appBarKey: appBarKey,
                      fullMotion: !widget.resizeToAvoidBottomInset,
                      selectedPlaceWidgetBuilder:
                          widget.selectedPlaceWidgetBuilder,
                      pinBuilder: widget.pinBuilder,
                      onSearchFailed: widget.onGeocodingSearchFailed,
                      debounceMilliseconds:
                          widget.cameraMoveDebounceInMilliseconds,
                      enableMapTypeButton: widget.enableMapTypeButton,
                      enableMyLocationButton: widget.enableMyLocationButton,
                      usePinPointingSearch: widget.usePinPointingSearch,
                      usePlaceDetailSearch: widget.usePlaceDetailSearch,
                      onMapCreated: widget.onMapCreated,
                      selectInitialPosition: widget.selectInitialPosition,
                      language: widget.autocompleteLanguage,
                      pickArea: widget.pickArea,
                      forceSearchOnZoomChanged: widget.forceSearchOnZoomChanged,
                      hidePlaceDetailsWhenDraggingPin:
                          widget.hidePlaceDetailsWhenDraggingPin,
                      selectText: widget.selectText,
                      outsideOfPickAreaText: widget.outsideOfPickAreaText,
                      onToggleMapType: _handleToggleMapType,
                      onMyLocation: _handleMyLocation,
                      onMoveStart: _handleMoveStart,
                      onPlacePicked: widget.onPlacePicked,
                      onCameraMoveStarted: widget.onCameraMoveStarted,
                      onCameraMove: widget.onCameraMove,
                      onCameraIdle: widget.onCameraIdle,
                      zoomGesturesEnabled: widget.zoomGesturesEnabled,
                      zoomControlsEnabled: widget.zoomControlsEnabled,
                    ),
                  ),
                  _IntroModalWidget(
                    showModal: showIntroModal,
                    introModalWidgetBuilder: widget.introModalWidgetBuilder,
                  ),
                ]),
              );
            }

            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ));
  }

  Future<void> _pickPrediction(Prediction prediction) async {
    provider!.placeSearchingState = SearchingState.Searching;
    final PlacesDetailsResponse response =
        await provider!.places.getDetailsByPlaceId(
      prediction.placeId!,
      sessionToken: provider!.sessionToken,
      language: widget.autocompleteLanguage,
    );
    if (response.errorMessage?.isNotEmpty == true ||
        response.status == "REQUEST_DENIED") {
      widget.onAutoCompleteFailed?.call(response.status);
      return;
    }
    provider!.selectedPlace = PickResult.fromPlaceDetailResult(response.result);
    provider!.isAutoCompleteSearching = true;
    await _moveTo(provider!.selectedPlace!.geometry!.location.lat,
        provider!.selectedPlace!.geometry!.location.lng);
    if (provider == null) return;
    provider!.placeSearchingState = SearchingState.Idle;
  }

  Future<void> _moveTo(double latitude, double longitude) async {
    if (provider?.mapController == null) return;
    final GoogleMapController? controller = provider!.mapController;
    await controller!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(latitude, longitude), zoom: 16),
      ),
    );
  }

  Future<void> _moveToCurrentPosition() async {
    if (provider?.currentPosition == null) return;
    await _moveTo(provider!.currentPosition!.latitude,
        provider!.currentPosition!.longitude);
  }

  void _handleToggleMapType() {
    if (provider == null) return;
    provider!.switchMapType();
    widget.onMapTypeChanged?.call(provider!.mapType);
  }

  Future<void> _handleMyLocation() async {
    if (provider == null || provider!.isLoadingLocation) return;
    // If already at current position, just animate to it without GPS request
    if (_isMapAtCurrentPosition()) {
      await _moveToCurrentPosition();
      return;
    }
    provider!.isLoadingLocation = true;
    try {
      await provider!.updateCurrentLocation(
          gracefully: widget.ignoreLocationPermissionErrors);
      await _moveToCurrentPosition();
    } catch (error) {
      if (!mounted) return;
      final errorType = _parseLocationError(error);
      await showLocationErrorBottomSheet(
        context: context,
        errorType: errorType,
        config: widget.locationErrorConfiguration,
      );
    } finally {
      if (provider != null) {
        provider!.isLoadingLocation = false;
      }
    }
  }

  /// Checks if the map camera is already at the user's current position.
  /// Uses a threshold of ~50 meters to account for GPS inaccuracies.
  bool _isMapAtCurrentPosition() {
    final currentPos = provider?.currentPosition;
    final cameraPos = provider?.cameraPosition;
    if (currentPos == null || cameraPos == null) return false;
    const double threshold = 0.0005; // ~50 meters at equator
    final latDiff = (currentPos.latitude - cameraPos.target.latitude).abs();
    final lngDiff = (currentPos.longitude - cameraPos.target.longitude).abs();
    return latDiff < threshold && lngDiff < threshold;
  }

  void _handleMoveStart() {
    if (provider == null) return;
    searchBarController.reset();
  }

  void _handleBackButton() {
    if (!showIntroModal || widget.introModalWidgetBuilder == null) {
      provider?.debounceTimer?.cancel();
      if (widget.onTapBack != null) {
        widget.onTapBack!();
        return;
      }
      Navigator.maybePop(context);
    }
  }
}

/// Search bar widget with back button and autocomplete.
class _SearchBarWidget extends StatelessWidget {
  const _SearchBarWidget({
    required this.provider,
    required this.appBarKey,
    required this.searchBarController,
    required this.showBackButton,
    required this.onBackPressed,
    required this.onPicked,
    required this.onSearchFailed,
    this.hintText,
    this.searchingText,
    this.debounceMilliseconds = 500,
    this.autocompleteOffset,
    this.autocompleteRadius,
    this.autocompleteLanguage,
    this.autocompleteComponents,
    this.autocompleteTypes,
    this.strictbounds,
    this.region,
    this.initialSearchString,
    this.searchForInitialValue = false,
    this.autocompleteOnTrailingWhitespace = false,
  });

  final PlaceProvider provider;
  final GlobalKey appBarKey;
  final SearchBarController searchBarController;
  final bool showBackButton;
  final VoidCallback onBackPressed;
  final ValueChanged<Prediction> onPicked;
  final ValueChanged<String>? onSearchFailed;
  final String? hintText;
  final String? searchingText;
  final int debounceMilliseconds;
  final num? autocompleteOffset;
  final num? autocompleteRadius;
  final String? autocompleteLanguage;
  final List<Component>? autocompleteComponents;
  final List<String>? autocompleteTypes;
  final bool? strictbounds;
  final String? region;
  final String? initialSearchString;
  final bool searchForInitialValue;
  final bool autocompleteOnTrailingWhitespace;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const SizedBox(width: 15),
        if (showBackButton)
          _BackButton(onPressed: onBackPressed)
        else
          const SizedBox.shrink(),
        Expanded(
          child: AutoCompleteSearch(
            appBarKey: appBarKey,
            searchBarController: searchBarController,
            sessionToken: provider.sessionToken,
            hintText: hintText,
            searchingText: searchingText,
            debounceMilliseconds: debounceMilliseconds,
            onPicked: onPicked,
            onSearchFailed: onSearchFailed,
            autocompleteOffset: autocompleteOffset,
            autocompleteRadius: autocompleteRadius,
            autocompleteLanguage: autocompleteLanguage,
            autocompleteComponents: autocompleteComponents,
            autocompleteTypes: autocompleteTypes,
            strictbounds: strictbounds,
            region: region,
            initialSearchString: initialSearchString,
            searchForInitialValue: searchForInitialValue,
            autocompleteOnTrailingWhitespace: autocompleteOnTrailingWhitespace,
          ),
        ),
        const SizedBox(width: 5),
      ],
    );
  }
}

/// Back button for search bar.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        !kIsWeb && Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
      ),
      color: Colors.black.withAlpha(128),
      padding: EdgeInsets.zero,
    );
  }
}

/// Map widget with location handling.
class _MapWithLocation extends StatelessWidget {
  const _MapWithLocation({
    required this.provider,
    required this.initialPosition,
    required this.appBarKey,
    required this.onToggleMapType,
    required this.onMyLocation,
    required this.onMoveStart,
    this.fullMotion = false,
    this.selectedPlaceWidgetBuilder,
    this.pinBuilder,
    this.onSearchFailed,
    this.debounceMilliseconds,
    this.enableMapTypeButton,
    this.enableMyLocationButton,
    this.usePinPointingSearch,
    this.usePlaceDetailSearch,
    this.onMapCreated,
    this.selectInitialPosition,
    this.language,
    this.pickArea,
    this.forceSearchOnZoomChanged,
    this.hidePlaceDetailsWhenDraggingPin,
    this.selectText,
    this.outsideOfPickAreaText,
    this.onPlacePicked,
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.onCameraIdle,
    this.zoomGesturesEnabled = true,
    this.zoomControlsEnabled = false,
  });

  final PlaceProvider provider;
  final LatLng initialPosition;
  final GlobalKey appBarKey;
  final bool fullMotion;
  final SelectedPlaceWidgetBuilder? selectedPlaceWidgetBuilder;
  final PinBuilder? pinBuilder;
  final ValueChanged<String>? onSearchFailed;
  final int? debounceMilliseconds;
  final bool? enableMapTypeButton;
  final bool? enableMyLocationButton;
  final bool? usePinPointingSearch;
  final bool? usePlaceDetailSearch;
  final MapCreatedCallback? onMapCreated;
  final bool? selectInitialPosition;
  final String? language;
  final CircleArea? pickArea;
  final bool? forceSearchOnZoomChanged;
  final bool? hidePlaceDetailsWhenDraggingPin;
  final String? selectText;
  final String? outsideOfPickAreaText;
  final VoidCallback onToggleMapType;
  final VoidCallback onMyLocation;
  final VoidCallback onMoveStart;
  final ValueChanged<PickResult>? onPlacePicked;
  final Function(PlaceProvider)? onCameraMoveStarted;
  final CameraPositionCallback? onCameraMove;
  final Function(PlaceProvider)? onCameraIdle;
  final bool zoomGesturesEnabled;
  final bool zoomControlsEnabled;

  LatLng get _initialTarget {
    if (provider.currentPosition == null) {
      return initialPosition;
    }
    return LatLng(
      provider.currentPosition!.latitude,
      provider.currentPosition!.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMapPlacePicker(
      fullMotion: fullMotion,
      initialTarget: _initialTarget,
      appBarKey: appBarKey,
      selectedPlaceWidgetBuilder: selectedPlaceWidgetBuilder,
      pinBuilder: pinBuilder,
      onSearchFailed: onSearchFailed,
      debounceMilliseconds: debounceMilliseconds,
      enableMapTypeButton: enableMapTypeButton,
      enableMyLocationButton: enableMyLocationButton,
      usePinPointingSearch: usePinPointingSearch,
      usePlaceDetailSearch: usePlaceDetailSearch,
      onMapCreated: onMapCreated,
      selectInitialPosition: selectInitialPosition,
      language: language,
      pickArea: pickArea,
      forceSearchOnZoomChanged: forceSearchOnZoomChanged,
      hidePlaceDetailsWhenDraggingPin: hidePlaceDetailsWhenDraggingPin,
      selectText: selectText,
      outsideOfPickAreaText: outsideOfPickAreaText,
      onToggleMapType: onToggleMapType,
      onMyLocation: onMyLocation,
      onMoveStart: onMoveStart,
      onPlacePicked: onPlacePicked,
      onCameraMoveStarted: onCameraMoveStarted,
      onCameraMove: onCameraMove,
      onCameraIdle: onCameraIdle,
      zoomGesturesEnabled: zoomGesturesEnabled,
      zoomControlsEnabled: zoomControlsEnabled,
    );
  }
}

/// Intro modal overlay widget.
class _IntroModalWidget extends StatefulWidget {
  const _IntroModalWidget({
    required this.showModal,
    required this.introModalWidgetBuilder,
  });

  final bool showModal;
  final IntroModalWidgetBuilder? introModalWidgetBuilder;

  @override
  State<_IntroModalWidget> createState() => _IntroModalWidgetState();
}

class _IntroModalWidgetState extends State<_IntroModalWidget> {
  late bool _showModal;

  @override
  void initState() {
    super.initState();
    _showModal = widget.showModal;
  }

  void _closeModal() {
    if (mounted) {
      setState(() {
        _showModal = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showModal || widget.introModalWidgetBuilder == null) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: [
        const Positioned.fill(
          child: Material(
            type: MaterialType.canvas,
            color: Color.fromARGB(128, 0, 0, 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            child: ClipRect(),
          ),
        ),
        widget.introModalWidgetBuilder!(context, _closeModal),
      ],
    );
  }
}
