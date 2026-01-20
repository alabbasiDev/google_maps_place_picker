/// Base class for all location-related exceptions in the place picker.
sealed class PlacePickerLocationException implements Exception {
  const PlacePickerLocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when location services (GPS) are disabled on the device.
///
/// The user needs to enable GPS/Location Services in their device settings.
final class GpsDisabledException extends PlacePickerLocationException {
  const GpsDisabledException([
    super.message = 'Location services are disabled. Please enable GPS.',
  ]);
}

/// Exception thrown when the user denies location permission.
///
/// The app can request permission again.
final class LocationPermissionDeniedException extends PlacePickerLocationException {
  const LocationPermissionDeniedException([
    super.message = 'Location permission was denied.',
  ]);
}

/// Exception thrown when location permission is permanently denied.
///
/// The user must manually grant permission from app settings.
final class LocationPermissionPermanentlyDeniedException extends PlacePickerLocationException {
  const LocationPermissionPermanentlyDeniedException([
    super.message =
        'Location permission is permanently denied. Please enable it in app settings.',
  ]);
}
