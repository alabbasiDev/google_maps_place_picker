import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:google_maps_place_picker_mb/providers/place_provider.dart';
import 'package:google_maps_place_picker_mb/src/components/animated_pin.dart';
import 'package:flutter_google_maps_webservices/geocoding.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'models/enums.dart';

typedef SelectedPlaceWidgetBuilder = Widget Function(
  BuildContext context,
  PickResult? selectedPlace,
  SearchingState state,
  bool isSearchBarFocused,
);

typedef PinBuilder = Widget Function(
  BuildContext context,
  PinState state,
);

class GoogleMapPlacePicker extends StatelessWidget {
  const GoogleMapPlacePicker({
    super.key,
    required this.initialTarget,
    required this.appBarKey,
    this.selectedPlaceWidgetBuilder,
    this.pinBuilder,
    this.onSearchFailed,
    this.onMoveStart,
    this.onMapCreated,
    this.debounceMilliseconds,
    this.enableMapTypeButton,
    this.enableMyLocationButton,
    this.onToggleMapType,
    this.onMyLocation,
    this.onPlacePicked,
    this.usePinPointingSearch,
    this.usePlaceDetailSearch,
    this.selectInitialPosition,
    this.language,
    this.pickArea,
    this.forceSearchOnZoomChanged,
    this.hidePlaceDetailsWhenDraggingPin,
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.onCameraIdle,
    this.selectText,
    this.outsideOfPickAreaText,
    this.zoomGesturesEnabled = true,
    this.zoomControlsEnabled = false,
    this.fullMotion = false,
  });

  final LatLng initialTarget;
  final GlobalKey appBarKey;

  final SelectedPlaceWidgetBuilder? selectedPlaceWidgetBuilder;
  final PinBuilder? pinBuilder;

  final ValueChanged<String>? onSearchFailed;
  final VoidCallback? onMoveStart;
  final MapCreatedCallback? onMapCreated;
  final VoidCallback? onToggleMapType;
  final VoidCallback? onMyLocation;
  final ValueChanged<PickResult>? onPlacePicked;

  final int? debounceMilliseconds;
  final bool? enableMapTypeButton;
  final bool? enableMyLocationButton;

  final bool? usePinPointingSearch;
  final bool? usePlaceDetailSearch;

  final bool? selectInitialPosition;

  final String? language;
  final CircleArea? pickArea;

  final bool? forceSearchOnZoomChanged;
  final bool? hidePlaceDetailsWhenDraggingPin;

  /// GoogleMap pass-through events:
  final Function(PlaceProvider)? onCameraMoveStarted;
  final CameraPositionCallback? onCameraMove;
  final Function(PlaceProvider)? onCameraIdle;

  // strings
  final String? selectText;
  final String? outsideOfPickAreaText;

  /// Zoom feature toggle
  final bool zoomGesturesEnabled;
  final bool zoomControlsEnabled;

  /// Use never scrollable scroll-view with maximum dimensions to prevent unnecessary re-rendering.
  final bool fullMotion;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (fullMotion)
          SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      _GoogleMapSelector(
                        initialTarget: initialTarget,
                        zoomGesturesEnabled: zoomGesturesEnabled,
                        pickArea: pickArea,
                        selectInitialPosition: selectInitialPosition,
                        usePinPointingSearch: usePinPointingSearch,
                        hidePlaceDetailsWhenDraggingPin:
                            hidePlaceDetailsWhenDraggingPin,
                        debounceMilliseconds: debounceMilliseconds,
                        language: language,
                        usePlaceDetailSearch: usePlaceDetailSearch,
                        forceSearchOnZoomChanged: forceSearchOnZoomChanged,
                        onSearchFailed: onSearchFailed,
                        onMapCreated: onMapCreated,
                        onCameraMoveStarted: onCameraMoveStarted,
                        onCameraMove: onCameraMove,
                        onCameraIdle: onCameraIdle,
                        onMoveStart: onMoveStart,
                      ),
                      _PinWidget(pinBuilder: pinBuilder),
                    ],
                  ))),
        if (!fullMotion) ...[
          _GoogleMapSelector(
            initialTarget: initialTarget,
            zoomGesturesEnabled: zoomGesturesEnabled,
            pickArea: pickArea,
            selectInitialPosition: selectInitialPosition,
            usePinPointingSearch: usePinPointingSearch,
            hidePlaceDetailsWhenDraggingPin: hidePlaceDetailsWhenDraggingPin,
            debounceMilliseconds: debounceMilliseconds,
            language: language,
            usePlaceDetailSearch: usePlaceDetailSearch,
            forceSearchOnZoomChanged: forceSearchOnZoomChanged,
            onSearchFailed: onSearchFailed,
            onMapCreated: onMapCreated,
            onCameraMoveStarted: onCameraMoveStarted,
            onCameraMove: onCameraMove,
            onCameraIdle: onCameraIdle,
            onMoveStart: onMoveStart,
          ),
          _PinWidget(pinBuilder: pinBuilder),
        ],
        _FloatingCardWidget(
          selectedPlaceWidgetBuilder: selectedPlaceWidgetBuilder,
          hidePlaceDetailsWhenDraggingPin: hidePlaceDetailsWhenDraggingPin,
          pickArea: pickArea,
          selectText: selectText,
          outsideOfPickAreaText: outsideOfPickAreaText,
          onPlacePicked: onPlacePicked,
        ),
        _MapIconsWidget(
          appBarKey: appBarKey,
          enableMapTypeButton: enableMapTypeButton,
          enableMyLocationButton: enableMyLocationButton,
          onToggleMapType: onToggleMapType,
          onMyLocation: onMyLocation,
        ),
        _ZoomButtonsWidget(
          zoomControlsEnabled: zoomControlsEnabled,
        ),
      ],
    );
  }
}

/// Google Map widget with map type selector.
class _GoogleMapSelector extends StatelessWidget {
  const _GoogleMapSelector({
    required this.initialTarget,
    required this.zoomGesturesEnabled,
    this.pickArea,
    this.selectInitialPosition,
    this.usePinPointingSearch,
    this.hidePlaceDetailsWhenDraggingPin,
    this.debounceMilliseconds,
    this.language,
    this.usePlaceDetailSearch,
    this.forceSearchOnZoomChanged,
    this.onSearchFailed,
    this.onMapCreated,
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.onCameraIdle,
    this.onMoveStart,
  });

  final LatLng initialTarget;
  final bool zoomGesturesEnabled;
  final CircleArea? pickArea;
  final bool? selectInitialPosition;
  final bool? usePinPointingSearch;
  final bool? hidePlaceDetailsWhenDraggingPin;
  final int? debounceMilliseconds;
  final String? language;
  final bool? usePlaceDetailSearch;
  final bool? forceSearchOnZoomChanged;
  final ValueChanged<String>? onSearchFailed;
  final MapCreatedCallback? onMapCreated;
  final Function(PlaceProvider)? onCameraMoveStarted;
  final CameraPositionCallback? onCameraMove;
  final Function(PlaceProvider)? onCameraIdle;
  final VoidCallback? onMoveStart;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaceProvider, MapType>(
      selector: (_, provider) => provider.mapType,
      builder: (_, mapType, __) => _GoogleMapInner(
        provider: PlaceProvider.of(context, listen: false),
        mapType: mapType,
        initialTarget: initialTarget,
        zoomGesturesEnabled: zoomGesturesEnabled,
        pickArea: pickArea,
        selectInitialPosition: selectInitialPosition,
        usePinPointingSearch: usePinPointingSearch,
        hidePlaceDetailsWhenDraggingPin: hidePlaceDetailsWhenDraggingPin,
        debounceMilliseconds: debounceMilliseconds,
        language: language,
        usePlaceDetailSearch: usePlaceDetailSearch,
        forceSearchOnZoomChanged: forceSearchOnZoomChanged,
        onSearchFailed: onSearchFailed,
        onMapCreated: onMapCreated,
        onCameraMoveStarted: onCameraMoveStarted,
        onCameraMove: onCameraMove,
        onCameraIdle: onCameraIdle,
        onMoveStart: onMoveStart,
      ),
    );
  }
}

/// Inner Google Map widget with all map functionality.
class _GoogleMapInner extends StatelessWidget {
  const _GoogleMapInner({
    required this.provider,
    required this.mapType,
    required this.initialTarget,
    required this.zoomGesturesEnabled,
    this.pickArea,
    this.selectInitialPosition,
    this.usePinPointingSearch,
    this.hidePlaceDetailsWhenDraggingPin,
    this.debounceMilliseconds,
    this.language,
    this.usePlaceDetailSearch,
    this.forceSearchOnZoomChanged,
    this.onSearchFailed,
    this.onMapCreated,
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.onCameraIdle,
    this.onMoveStart,
  });

  final PlaceProvider provider;
  final MapType mapType;
  final LatLng initialTarget;
  final bool zoomGesturesEnabled;
  final CircleArea? pickArea;
  final bool? selectInitialPosition;
  final bool? usePinPointingSearch;
  final bool? hidePlaceDetailsWhenDraggingPin;
  final int? debounceMilliseconds;
  final String? language;
  final bool? usePlaceDetailSearch;
  final bool? forceSearchOnZoomChanged;
  final ValueChanged<String>? onSearchFailed;
  final MapCreatedCallback? onMapCreated;
  final Function(PlaceProvider)? onCameraMoveStarted;
  final CameraPositionCallback? onCameraMove;
  final Function(PlaceProvider)? onCameraIdle;
  final VoidCallback? onMoveStart;

  Future<void> _searchByCameraLocation() async {
    if (forceSearchOnZoomChanged == false &&
        provider.prevCameraPosition != null &&
        provider.prevCameraPosition!.target.latitude ==
            provider.cameraPosition!.target.latitude &&
        provider.prevCameraPosition!.target.longitude ==
            provider.cameraPosition!.target.longitude) {
      provider.placeSearchingState = SearchingState.Idle;
      return;
    }
    if (provider.cameraPosition == null) {
      provider.placeSearchingState = SearchingState.Idle;
      return;
    }
    provider.placeSearchingState = SearchingState.Searching;
    final GeocodingResponse response =
        await provider.geocoding.searchByLocation(
      Location(
          lat: provider.cameraPosition!.target.latitude,
          lng: provider.cameraPosition!.target.longitude),
      language: language,
    );
    if (response.errorMessage?.isNotEmpty == true ||
        response.status == "REQUEST_DENIED") {
      print("Camera Location Search Error: " + response.errorMessage!);
      onSearchFailed?.call(response.status);
      provider.placeSearchingState = SearchingState.Idle;
      return;
    }
    if (usePlaceDetailSearch!) {
      final PlacesDetailsResponse detailResponse =
          await provider.places.getDetailsByPlaceId(
        response.results[0].placeId,
        language: language,
      );
      if (detailResponse.errorMessage?.isNotEmpty == true ||
          detailResponse.status == "REQUEST_DENIED") {
        print("Fetching details by placeId Error: " +
            detailResponse.errorMessage!);
        onSearchFailed?.call(detailResponse.status);
        provider.placeSearchingState = SearchingState.Idle;
        return;
      }
      provider.selectedPlace =
          PickResult.fromPlaceDetailResult(detailResponse.result);
    } else {
      provider.selectedPlace =
          PickResult.fromGeocodingResult(response.results[0]);
    }
    provider.placeSearchingState = SearchingState.Idle;
  }

  @override
  Widget build(BuildContext context) {
    final CameraPosition initialCameraPosition =
        CameraPosition(target: initialTarget, zoom: 15);

    return GoogleMap(
      zoomGesturesEnabled: zoomGesturesEnabled,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      initialCameraPosition: initialCameraPosition,
      mapType: mapType,
      myLocationEnabled: true,
      circles: pickArea != null && pickArea!.radius > 0
          ? Set<Circle>.from([pickArea])
          : <Circle>{},
      onMapCreated: (GoogleMapController controller) {
        provider.mapController = controller;
        provider.setCameraPosition(null);
        provider.pinState = PinState.Idle;
        if (selectInitialPosition!) {
          provider.setCameraPosition(initialCameraPosition);
          _searchByCameraLocation();
        }
        onMapCreated?.call(controller);
      },
      onCameraIdle: () {
        if (provider.isAutoCompleteSearching) {
          provider.isAutoCompleteSearching = false;
          provider.pinState = PinState.Idle;
          provider.placeSearchingState = SearchingState.Idle;
          return;
        }
        if (usePinPointingSearch!) {
          if (provider.pinState == PinState.Dragging) {
            if (provider.debounceTimer?.isActive ?? false) {
              provider.debounceTimer!.cancel();
            }
            provider.debounceTimer =
                Timer(Duration(milliseconds: debounceMilliseconds!), () {
              _searchByCameraLocation();
            });
          }
        }
        provider.pinState = PinState.Idle;
        onCameraIdle?.call(provider);
      },
      onCameraMoveStarted: () {
        onCameraMoveStarted?.call(provider);
        provider.setPrevCameraPosition(provider.cameraPosition);
        provider.debounceTimer?.cancel();
        provider.pinState = PinState.Dragging;
        if (hidePlaceDetailsWhenDraggingPin!) {
          provider.placeSearchingState = SearchingState.Searching;
        }
        onMoveStart!();
      },
      onCameraMove: (CameraPosition position) {
        provider.setCameraPosition(position);
        onCameraMove?.call(position);
      },
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{}
        ..add(Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer())),
    );
  }
}

/// Pin widget displayed at the center of the map.
class _PinWidget extends StatelessWidget {
  const _PinWidget({this.pinBuilder});

  final PinBuilder? pinBuilder;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Selector<PlaceProvider, PinState>(
        selector: (_, provider) => provider.pinState,
        builder: (context, state, __) {
          if (pinBuilder == null) {
            return _DefaultPin(state: state);
          }
          return Builder(
            builder: (builderContext) => pinBuilder!(builderContext, state),
          );
        },
      ),
    );
  }
}

/// Default pin widget when no custom builder is provided.
class _DefaultPin extends StatelessWidget {
  const _DefaultPin({required this.state});

  final PinState state;

  @override
  Widget build(BuildContext context) {
    if (state == PinState.Preparing) {
      return const SizedBox.shrink();
    }
    final bool isDragging = state == PinState.Dragging;

    return Stack(
      children: <Widget>[
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              isDragging
                  ? AnimatedPin(
                      child:
                          const Icon(Icons.place, size: 36, color: Colors.red))
                  : const Icon(Icons.place, size: 36, color: Colors.red),
              const SizedBox(height: 42),
            ],
          ),
        ),
        Center(
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

/// Floating card showing selected place details.
class _FloatingCardWidget extends StatelessWidget {
  const _FloatingCardWidget({
    this.selectedPlaceWidgetBuilder,
    this.hidePlaceDetailsWhenDraggingPin,
    this.pickArea,
    this.selectText,
    this.outsideOfPickAreaText,
    this.onPlacePicked,
  });

  final SelectedPlaceWidgetBuilder? selectedPlaceWidgetBuilder;
  final bool? hidePlaceDetailsWhenDraggingPin;
  final CircleArea? pickArea;
  final String? selectText;
  final String? outsideOfPickAreaText;
  final ValueChanged<PickResult>? onPlacePicked;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaceProvider,
        Tuple4<PickResult?, SearchingState, bool, PinState>>(
      selector: (_, provider) => Tuple4(
        provider.selectedPlace,
        provider.placeSearchingState,
        provider.isSearchBarFocused,
        provider.pinState,
      ),
      builder: (context, data, __) {
        final selectedPlace = data.item1;
        final searchingState = data.item2;
        final isSearchBarFocused = data.item3;
        final pinState = data.item4;

        if ((selectedPlace == null && searchingState == SearchingState.Idle) ||
            isSearchBarFocused ||
            (pinState == PinState.Dragging &&
                hidePlaceDetailsWhenDraggingPin!)) {
          return const SizedBox.shrink();
        }
        if (selectedPlaceWidgetBuilder != null) {
          return Builder(
            builder: (builderContext) => selectedPlaceWidgetBuilder!(
              builderContext,
              selectedPlace,
              searchingState,
              isSearchBarFocused,
            ),
          );
        }
        return _DefaultPlaceWidget(
          selectedPlace: selectedPlace,
          searchingState: searchingState,
          pickArea: pickArea,
          selectText: selectText,
          outsideOfPickAreaText: outsideOfPickAreaText,
          onPlacePicked: onPlacePicked,
        );
      },
    );
  }
}

/// Default place widget showing address and select button.
class _DefaultPlaceWidget extends StatelessWidget {
  const _DefaultPlaceWidget({
    this.selectedPlace,
    required this.searchingState,
    this.pickArea,
    this.selectText,
    this.outsideOfPickAreaText,
    this.onPlacePicked,
  });

  final PickResult? selectedPlace;
  final SearchingState searchingState;
  final CircleArea? pickArea;
  final String? selectText;
  final String? outsideOfPickAreaText;
  final ValueChanged<PickResult>? onPlacePicked;

  @override
  Widget build(BuildContext context) {
    return FloatingCard(
      bottomPosition: MediaQuery.of(context).size.height * 0.1,
      leftPosition: MediaQuery.of(context).size.width * 0.15,
      rightPosition: MediaQuery.of(context).size.width * 0.15,
      width: MediaQuery.of(context).size.width * 0.7,
      borderRadius: BorderRadius.circular(12.0),
      elevation: 4.0,
      color: Theme.of(context).cardColor,
      child: searchingState == SearchingState.Searching
          ? const _LoadingIndicator()
          : _SelectionDetails(
              result: selectedPlace!,
              pickArea: pickArea,
              selectText: selectText,
              outsideOfPickAreaText: outsideOfPickAreaText,
              onPlacePicked: onPlacePicked,
            ),
    );
  }
}

/// Loading indicator widget.
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 48,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// Selection details widget showing address and action button.
class _SelectionDetails extends StatelessWidget {
  const _SelectionDetails({
    required this.result,
    this.pickArea,
    this.selectText,
    this.outsideOfPickAreaText,
    this.onPlacePicked,
  });

  final PickResult result;
  final CircleArea? pickArea;
  final String? selectText;
  final String? outsideOfPickAreaText;
  final ValueChanged<PickResult>? onPlacePicked;

  bool get _canBePicked {
    return pickArea == null ||
        pickArea!.radius <= 0 ||
        Geolocator.distanceBetween(
                pickArea!.center.latitude,
                pickArea!.center.longitude,
                result.geometry!.location.lat,
                result.geometry!.location.lng) <=
            pickArea!.radius;
  }

  @override
  Widget build(BuildContext context) {
    final bool canBePicked = _canBePicked;
    final MaterialStateColor buttonColor = MaterialStateColor.resolveWith(
        (states) => canBePicked ? Colors.lightGreen : Colors.red);
    final bool showIconOnly = (canBePicked && (selectText?.isEmpty ?? true)) ||
        (!canBePicked && (outsideOfPickAreaText?.isEmpty ?? true));

    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text(
            result.formattedAddress!,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          showIconOnly
              ? _IconOnlyButton(
                  canBePicked: canBePicked,
                  buttonColor: buttonColor,
                  onTap: () {
                    if (canBePicked) onPlacePicked!(result);
                  },
                )
              : _TextButton(
                  canBePicked: canBePicked,
                  buttonColor: buttonColor,
                  text: canBePicked ? selectText! : outsideOfPickAreaText!,
                  onTap: () {
                    if (canBePicked) onPlacePicked!(result);
                  },
                ),
        ],
      ),
    );
  }
}

/// Icon-only action button.
class _IconOnlyButton extends StatelessWidget {
  const _IconOnlyButton({
    required this.canBePicked,
    required this.buttonColor,
    required this.onTap,
  });

  final bool canBePicked;
  final MaterialStateColor buttonColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: const Size(56, 56),
      child: ClipOval(
        child: Material(
          child: InkWell(
            overlayColor: buttonColor,
            onTap: onTap,
            child: Icon(
              canBePicked ? Icons.check_sharp : Icons.app_blocking_sharp,
              color: buttonColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Text action button with icon.
class _TextButton extends StatelessWidget {
  const _TextButton({
    required this.canBePicked,
    required this.buttonColor,
    required this.text,
    required this.onTap,
  });

  final bool canBePicked;
  final MaterialStateColor buttonColor;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size(MediaQuery.of(context).size.width * 0.8, 56),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Material(
          child: InkWell(
            overlayColor: buttonColor,
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canBePicked ? Icons.check_sharp : Icons.app_blocking_sharp,
                  color: buttonColor,
                ),
                const SizedBox(width: 10),
                Text(text, style: TextStyle(color: buttonColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Zoom control buttons widget.
class _ZoomButtonsWidget extends StatelessWidget {
  const _ZoomButtonsWidget({required this.zoomControlsEnabled});

  final bool zoomControlsEnabled;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaceProvider, Tuple2<GoogleMapController?, LatLng?>>(
      selector: (_, provider) => Tuple2<GoogleMapController?, LatLng?>(
        provider.mapController,
        provider.cameraPosition?.target,
      ),
      builder: (context, data, __) {
        if (!zoomControlsEnabled || data.item1 == null || data.item2 == null) {
          return const SizedBox.shrink();
        }
        return Positioned(
          bottom: MediaQuery.of(context).size.height * 0.1 - 3.6,
          right: 2,
          child: _ZoomButtonsCard(
            controller: data.item1!,
            currentTarget: data.item2!,
          ),
        );
      },
    );
  }
}

/// Zoom buttons card with zoom in/out functionality.
class _ZoomButtonsCard extends StatelessWidget {
  const _ZoomButtonsCard({
    required this.controller,
    required this.currentTarget,
  });

  final GoogleMapController controller;
  final LatLng currentTarget;

  Future<void> _zoomIn() async {
    double currentZoomLevel = await controller.getZoomLevel();
    currentZoomLevel = currentZoomLevel + 2;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentTarget, zoom: currentZoomLevel),
      ),
    );
  }

  Future<void> _zoomOut() async {
    double currentZoomLevel = await controller.getZoomLevel();
    currentZoomLevel = currentZoomLevel - 2;
    if (currentZoomLevel < 0) currentZoomLevel = 0;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentTarget, zoom: currentZoomLevel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.15 - 13,
        height: 107,
        child: Column(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _zoomIn,
            ),
            const SizedBox(height: 2),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: _zoomOut,
            ),
          ],
        ),
      ),
    );
  }
}

/// Map icons widget (map type toggle, my location button).
class _MapIconsWidget extends StatelessWidget {
  const _MapIconsWidget({
    required this.appBarKey,
    this.enableMapTypeButton,
    this.enableMyLocationButton,
    this.onToggleMapType,
    this.onMyLocation,
  });

  final GlobalKey appBarKey;
  final bool? enableMapTypeButton;
  final bool? enableMyLocationButton;
  final VoidCallback? onToggleMapType;
  final VoidCallback? onMyLocation;

  @override
  Widget build(BuildContext context) {
    if (appBarKey.currentContext == null) {
      return const SizedBox.shrink();
    }
    final RenderBox appBarRenderBox =
        appBarKey.currentContext!.findRenderObject() as RenderBox;

    return Positioned(
      top: appBarRenderBox.size.height,
      right: 15,
      child: Column(
        children: <Widget>[
          if (enableMapTypeButton!)
            _MapIconButton(
              icon: Icons.layers,
              onPressed: onToggleMapType,
            ),
          if (enableMapTypeButton!) const SizedBox(height: 10),
          if (enableMyLocationButton!)
            Selector<PlaceProvider, bool>(
              selector: (_, provider) => provider.isLoadingLocation,
              builder: (context, isLoading, child) {
                if (isLoading) {
                  return const _MyLocationLoadingButton();
                }
                return _MapIconButton(
                  icon: Icons.my_location,
                  onPressed: onMyLocation,
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Loading indicator for my location button.
class _MyLocationLoadingButton extends StatelessWidget {
  const _MyLocationLoadingButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 35,
      height: 35,
      child: RawMaterialButton(
        shape: const CircleBorder(),
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black54
            : Colors.white,
        elevation: 4.0,
        onPressed: null,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

/// Individual map icon button.
class _MapIconButton extends StatelessWidget {
  const _MapIconButton({
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 35,
      height: 35,
      child: RawMaterialButton(
        shape: const CircleBorder(),
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black54
            : Colors.white,
        elevation: 4.0,
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }
}
