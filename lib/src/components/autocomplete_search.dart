import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:google_maps_place_picker_mb/providers/place_provider.dart';
import 'package:google_maps_place_picker_mb/providers/search_provider.dart';
import 'package:google_maps_place_picker_mb/src/components/prediction_tile.dart';
import 'package:google_maps_place_picker_mb/src/controllers/autocomplete_search_controller.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:google_maps_place_picker_mb/src/models/enums.dart' show SearchingState;
import 'package:provider/provider.dart';

class AutoCompleteSearch extends StatefulWidget {
  const AutoCompleteSearch(
      {super.key,
      required this.sessionToken,
      required this.onPicked,
      required this.appBarKey,
      this.hintText = "Search here",
      this.searchingText = "Searching...",
      this.hidden = false,
      this.height = 40,
      this.contentPadding = EdgeInsets.zero,
      this.debounceMilliseconds,
      this.onSearchFailed,
      required this.searchBarController,
      this.autocompleteOffset,
      this.autocompleteRadius,
      this.autocompleteLanguage,
      this.autocompleteComponents,
      this.autocompleteTypes,
      this.strictbounds,
      this.region,
      this.initialSearchString,
      this.searchForInitialValue,
      this.autocompleteOnTrailingWhitespace});

  final String? sessionToken;
  final String? hintText;
  final String? searchingText;
  final bool hidden;
  final double height;
  final EdgeInsetsGeometry contentPadding;
  final int? debounceMilliseconds;
  final ValueChanged<Prediction> onPicked;
  final ValueChanged<String>? onSearchFailed;
  final SearchBarController searchBarController;
  final num? autocompleteOffset;
  final num? autocompleteRadius;
  final String? autocompleteLanguage;
  final List<String>? autocompleteTypes;
  final List<Component>? autocompleteComponents;
  final bool? strictbounds;
  final String? region;
  final GlobalKey appBarKey;
  final String? initialSearchString;
  final bool? searchForInitialValue;
  final bool? autocompleteOnTrailingWhitespace;

  @override
  AutoCompleteSearchState createState() => AutoCompleteSearchState();
}

class AutoCompleteSearchState extends State<AutoCompleteSearch> {
  TextEditingController controller = TextEditingController();
  FocusNode focus = FocusNode();
  OverlayEntry? overlayEntry;
  SearchProvider provider = SearchProvider();

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchString != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.text = widget.initialSearchString!;
        if (widget.searchForInitialValue!) {
          _onSearchInputChange();
        }
      });
    }
    controller.addListener(_onSearchInputChange);
    focus.addListener(_onFocusChanged);

    widget.searchBarController.attach(this);
  }

  @override
  void dispose() {
    controller.removeListener(_onSearchInputChange);
    controller.dispose();

    focus.removeListener(_onFocusChanged);
    focus.dispose();
    _clearOverlay();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hidden) {
      return const SizedBox.shrink();
    }
    return ChangeNotifierProvider.value(
      value: provider,
      child: RoundedFrame(
        height: widget.height,
        padding: const EdgeInsets.only(right: 10),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black54
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 4.0,
        child: Row(
          children: <Widget>[
            const SizedBox(width: 10),
            const Icon(Icons.search),
            const SizedBox(width: 10),
            Expanded(
              child: _SearchTextField(
                controller: controller,
                focusNode: focus,
                hintText: widget.hintText,
                contentPadding: widget.contentPadding,
              ),
            ),
            _TextClearIcon(onClear: clearText),
          ],
        ),
      ),
    );
  }

  void _onSearchInputChange() {
    if (!mounted) return;
    this.provider.searchTerm = controller.text;

    PlaceProvider provider = PlaceProvider.of(context, listen: false);

    if (controller.text.isEmpty) {
      provider.debounceTimer?.cancel();
      _searchPlace(controller.text);
      return;
    }

    if (controller.text.trim() == this.provider.prevSearchTerm.trim()) {
      provider.debounceTimer?.cancel();
      return;
    }

    if (!widget.autocompleteOnTrailingWhitespace! &&
        controller.text.substring(controller.text.length - 1) == " ") {
      provider.debounceTimer?.cancel();
      return;
    }

    if (provider.debounceTimer?.isActive ?? false) {
      provider.debounceTimer!.cancel();
    }

    provider.debounceTimer =
        Timer(Duration(milliseconds: widget.debounceMilliseconds!), () {
      _searchPlace(controller.text.trim());
    });
  }

  void _onFocusChanged() {
    PlaceProvider provider = PlaceProvider.of(context, listen: false);
    provider.isSearchBarFocused = focus.hasFocus;
    provider.debounceTimer?.cancel();
    provider.placeSearchingState = SearchingState.Idle;
  }

  void _searchPlace(String searchTerm) {
    provider.prevSearchTerm = searchTerm;
    _clearOverlay();
    if (searchTerm.length < 1) return;
    _displayOverlay(
      _SearchingOverlay(searchingText: widget.searchingText),
    );
    _performAutoCompleteSearch(searchTerm);
  }

  void _clearOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }

  void _displayOverlay(Widget overlayChild) {
    _clearOverlay();

    final RenderBox? appBarRenderBox =
        widget.appBarKey.currentContext!.findRenderObject() as RenderBox?;
    final translation = appBarRenderBox?.getTransformTo(null).getTranslation();
    final Offset offset = translation != null
        ? Offset(translation.x, translation.y)
        : Offset(0.0, 0.0);
    final screenWidth = MediaQuery.of(context).size.width;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: appBarRenderBox!.paintBounds.shift(offset).top +
            appBarRenderBox.size.height,
        left: screenWidth * 0.025,
        right: screenWidth * 0.025,
        child: Material(
          elevation: 4.0,
          child: overlayChild,
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  Future<void> _performAutoCompleteSearch(String searchTerm) async {
    PlaceProvider provider = PlaceProvider.of(context, listen: false);

    if (searchTerm.isNotEmpty) {
      final PlacesAutocompleteResponse response =
          await provider.places.autocomplete(
        searchTerm,
        sessionToken: widget.sessionToken,
        location: provider.currentPosition == null
            ? null
            : Location(
                lat: provider.currentPosition!.latitude,
                lng: provider.currentPosition!.longitude),
        offset: widget.autocompleteOffset,
        radius: widget.autocompleteRadius,
        language: widget.autocompleteLanguage,
        types: widget.autocompleteTypes ?? const [],
        components: widget.autocompleteComponents ?? const [],
        strictbounds: widget.strictbounds ?? false,
        region: widget.region,
      );

      if (response.errorMessage?.isNotEmpty == true ||
          response.status == "REQUEST_DENIED") {
        if (widget.onSearchFailed != null) {
          widget.onSearchFailed!(response.status);
        }
        return;
      }

      _displayOverlay(
        _PredictionOverlay(
          predictions: response.predictions,
          onSelected: (selectedPrediction) {
            resetSearchBar();
            widget.onPicked(selectedPrediction);
          },
        ),
      );
    }
  }

  void clearText() {
    provider.searchTerm = "";
    controller.clear();
  }

  void resetSearchBar() {
    clearText();
    focus.unfocus();
  }

  void clearOverlay() {
    _clearOverlay();
  }
}

/// Search text field widget.
class _SearchTextField extends StatelessWidget {
  const _SearchTextField({
    required this.controller,
    required this.focusNode,
    this.hintText,
    this.contentPadding = EdgeInsets.zero,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        errorBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        isDense: true,
        contentPadding: contentPadding,
      ),
    );
  }
}

/// Clear text icon button widget.
class _TextClearIcon extends StatelessWidget {
  const _TextClearIcon({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Selector<SearchProvider, String>(
      selector: (_, provider) => provider.searchTerm,
      builder: (_, searchTerm, __) {
        if (searchTerm.isEmpty) {
          return const SizedBox(width: 10);
        }
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.clear,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        );
      },
    );
  }
}

/// Searching overlay indicator widget.
class _SearchingOverlay extends StatelessWidget {
  const _SearchingOverlay({this.searchingText});

  final String? searchingText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              searchingText ?? "Searching...",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

/// Prediction list overlay widget.
class _PredictionOverlay extends StatelessWidget {
  const _PredictionOverlay({
    required this.predictions,
    required this.onSelected,
  });

  final List<Prediction> predictions;
  final ValueChanged<Prediction> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListBody(
      children: predictions
          .map(
            (prediction) => PredictionTile(
              prediction: prediction,
              onTap: onSelected,
            ),
          )
          .toList(),
    );
  }
}
