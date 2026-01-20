
enum PinState { Preparing, Idle, Dragging }

enum SearchingState { Idle, Searching }

/// Types of location-related errors
enum LocationErrorType {
  /// GPS/Location services are disabled on the device
  locationServiceDisabled,

  /// User denied location permission
  permissionDenied,

  /// User permanently denied location permission
  permissionDeniedForever,

  /// Unknown or other error
  unknown,
}