import 'package:flutter/material.dart';

// ============================================================
// Theme Configuration (Icons & Colors)
// ============================================================


/// Visual theme configuration for location error widgets.
///
/// Contains icons and colors for all error types. Use this to customize
/// the visual appearance without affecting the text content.
///
/// ## Example: Custom Theme
/// ```dart
/// PlacePicker(
///   locationErrorConfiguration: LocationErrorConfiguration(
///     theme: LocationErrorTheme(
///       gpsDisabledIcon: Icons.gps_off,
///       gpsDisabledIconColor: Colors.orange,
///     ),
///   ),
/// )
/// ```
class LocationErrorTheme {
  /// Creates a custom theme configuration.
  ///
  /// All parameters have sensible defaults that follow Material Design guidelines.
  const LocationErrorTheme({
    // GPS Disabled
    this.gpsDisabledIcon = Icons.location_off_rounded,
    this.gpsDisabledIconColor,
    this.gpsDisabledIconBackgroundColor,

    // Permission Denied
    this.permissionDeniedIcon = Icons.location_disabled_rounded,
    this.permissionDeniedIconColor,
    this.permissionDeniedIconBackgroundColor,

    // Permission Permanently Denied
    this.permissionPermanentlyDeniedIcon = Icons.app_settings_alt_rounded,
    this.permissionPermanentlyDeniedIconColor,
    this.permissionPermanentlyDeniedIconBackgroundColor,

    // Unknown Error
    this.unknownErrorIcon = Icons.error_outline_rounded,
    this.unknownErrorIconColor,
    this.unknownErrorIconBackgroundColor,
  });

  // ============================================================
  // GPS Disabled Theme
  // ============================================================

  /// Icon displayed when GPS/location services are disabled.
  ///
  /// Default: [Icons.location_off_rounded]
  final IconData gpsDisabledIcon;

  /// Color of the GPS disabled icon.
  ///
  /// Default: Uses theme's error color
  final Color? gpsDisabledIconColor;

  /// Background color of the GPS disabled icon circle.
  ///
  /// Default: Uses theme's error container color with reduced opacity
  final Color? gpsDisabledIconBackgroundColor;

  // ============================================================
  // Permission Denied Theme
  // ============================================================

  /// Icon displayed when location permission is denied.
  ///
  /// Default: [Icons.location_disabled_rounded]
  final IconData permissionDeniedIcon;

  /// Color of the permission denied icon.
  ///
  /// Default: Uses theme's tertiary color
  final Color? permissionDeniedIconColor;

  /// Background color of the permission denied icon circle.
  ///
  /// Default: Uses theme's tertiary container color with reduced opacity
  final Color? permissionDeniedIconBackgroundColor;

  // ============================================================
  // Permission Permanently Denied Theme
  // ============================================================

  /// Icon displayed when location permission is permanently denied.
  ///
  /// Default: [Icons.app_settings_alt_rounded]
  final IconData permissionPermanentlyDeniedIcon;

  /// Color of the permission permanently denied icon.
  ///
  /// Default: Uses theme's error color
  final Color? permissionPermanentlyDeniedIconColor;

  /// Background color of the permission permanently denied icon circle.
  ///
  /// Default: Uses theme's error container color with reduced opacity
  final Color? permissionPermanentlyDeniedIconBackgroundColor;

  // ============================================================
  // Unknown Error Theme
  // ============================================================

  /// Icon displayed for unknown/unexpected errors.
  ///
  /// Default: [Icons.error_outline_rounded]
  final IconData unknownErrorIcon;

  /// Color of the unknown error icon.
  ///
  /// Default: Uses theme's error color
  final Color? unknownErrorIconColor;

  /// Background color of the unknown error icon circle.
  ///
  /// Default: Uses theme's error container color with reduced opacity
  final Color? unknownErrorIconBackgroundColor;

  /// Creates a copy of this theme with the given fields replaced.
  LocationErrorTheme copyWith({
    IconData? gpsDisabledIcon,
    Color? gpsDisabledIconColor,
    Color? gpsDisabledIconBackgroundColor,
    IconData? permissionDeniedIcon,
    Color? permissionDeniedIconColor,
    Color? permissionDeniedIconBackgroundColor,
    IconData? permissionPermanentlyDeniedIcon,
    Color? permissionPermanentlyDeniedIconColor,
    Color? permissionPermanentlyDeniedIconBackgroundColor,
    IconData? unknownErrorIcon,
    Color? unknownErrorIconColor,
    Color? unknownErrorIconBackgroundColor,
  }) {
    return LocationErrorTheme(
      gpsDisabledIcon: gpsDisabledIcon ?? this.gpsDisabledIcon,
      gpsDisabledIconColor: gpsDisabledIconColor ?? this.gpsDisabledIconColor,
      gpsDisabledIconBackgroundColor:
      gpsDisabledIconBackgroundColor ?? this.gpsDisabledIconBackgroundColor,
      permissionDeniedIcon: permissionDeniedIcon ?? this.permissionDeniedIcon,
      permissionDeniedIconColor:
      permissionDeniedIconColor ?? this.permissionDeniedIconColor,
      permissionDeniedIconBackgroundColor:
      permissionDeniedIconBackgroundColor ??
          this.permissionDeniedIconBackgroundColor,
      permissionPermanentlyDeniedIcon: permissionPermanentlyDeniedIcon ??
          this.permissionPermanentlyDeniedIcon,
      permissionPermanentlyDeniedIconColor:
      permissionPermanentlyDeniedIconColor ??
          this.permissionPermanentlyDeniedIconColor,
      permissionPermanentlyDeniedIconBackgroundColor:
      permissionPermanentlyDeniedIconBackgroundColor ??
          this.permissionPermanentlyDeniedIconBackgroundColor,
      unknownErrorIcon: unknownErrorIcon ?? this.unknownErrorIcon,
      unknownErrorIconColor:
      unknownErrorIconColor ?? this.unknownErrorIconColor,
      unknownErrorIconBackgroundColor: unknownErrorIconBackgroundColor ??
          this.unknownErrorIconBackgroundColor,
    );
  }
}

// ============================================================
// Strings Configuration (Translations)
// ============================================================

/// Translatable strings for location error widgets.
///
/// Contains all text content that can be translated. Use factory constructors
/// for common languages or create a custom instance for full translation control.
///
/// ## Example: Custom Translation
/// ```dart
/// PlacePicker(
///   locationErrorConfiguration: LocationErrorConfiguration(
///     strings: LocationErrorStrings(
///       gpsDisabledTitle: 'Servicios de ubicación desactivados',
///       gpsDisabledMessage: 'El GPS está desactivado en tu dispositivo.',
///       // ... other strings
///     ),
///   ),
/// )
/// ```
///
/// ## Example: Using Factory Constructor
/// ```dart
/// PlacePicker(
///   locationErrorConfiguration: LocationErrorConfiguration(
///     strings: LocationErrorStrings.arabic(),
///   ),
/// )
/// ```
class LocationErrorStrings {
  /// Creates custom location error strings.
  ///
  /// All parameters have sensible English defaults, so you only need to
  /// override the strings you want to translate.
  const LocationErrorStrings({
    // GPS Disabled
    this.gpsDisabledTitle = 'Location Services Disabled',
    this.gpsDisabledMessage =
    'GPS is turned off on your device. Please enable location services to pick a location on the map.',
    this.gpsDisabledOpenSettingsButtonText = 'Enable Location',
    this.gpsDisabledRetryButtonText = 'Try Again',
    this.gpsDisabledInstructionSteps = const [
      'Tap "Enable Location" below',
      'Turn on Location/GPS in settings',
      'Return to this app',
    ],

    // Permission Denied
    this.permissionDeniedTitle = 'Location Permission Required',
    this.permissionDeniedMessage =
    'This app needs access to your location to show nearby places and let you pick a location on the map.',
    this.permissionDeniedGrantButtonText = 'Grant Permission',
    this.permissionDeniedInstructionSteps,

    // Permission Permanently Denied
    this.permissionPermanentlyDeniedTitle = 'Permission Permanently Denied',
    this.permissionPermanentlyDeniedMessage =
    'Location permission was denied. You need to manually enable it in app settings to use this feature.',
    this.permissionPermanentlyDeniedOpenSettingsButtonText =
    'Open App Settings',
    this.permissionPermanentlyDeniedRetryButtonText = 'Try Again',
    this.permissionPermanentlyDeniedInstructionSteps = const [
      'Tap "Open App Settings" below',
      'Go to Permissions → Location',
      'Select "Allow" or "While using the app"',
      'Return to this app',
    ],

    // Unknown Error
    this.unknownErrorTitle = 'Something Went Wrong',
    this.unknownErrorMessage =
    'An unexpected error occurred while accessing your location. Please try again.',
    this.unknownErrorRetryButtonText = 'Try Again',
    this.unknownErrorInstructionSteps,

    // Common
    this.instructionsHeaderText = 'How to enable:',
  });

  /// Creates English strings (default).
  factory LocationErrorStrings.english() {
    return const LocationErrorStrings();
  }

  /// Creates Arabic strings.
  factory LocationErrorStrings.arabic() {
    return const LocationErrorStrings(
      // GPS Disabled
      gpsDisabledTitle: 'خدمات الموقع معطلة',
      gpsDisabledMessage:
      'نظام تحديد المواقع (GPS) معطل على جهازك. يرجى تفعيل خدمات الموقع لاختيار موقع على الخريطة.',
      gpsDisabledOpenSettingsButtonText: 'تفعيل الموقع',
      gpsDisabledRetryButtonText: 'حاول مرة أخرى',
      gpsDisabledInstructionSteps: [
        'اضغط على "تفعيل الموقع" أدناه',
        'قم بتشغيل الموقع/GPS في الإعدادات',
        'ارجع إلى هذا التطبيق',
      ],

      // Permission Denied
      permissionDeniedTitle: 'إذن الموقع مطلوب',
      permissionDeniedMessage:
      'يحتاج هذا التطبيق إلى الوصول إلى موقعك لعرض الأماكن القريبة والسماح لك باختيار موقع على الخريطة.',
      permissionDeniedGrantButtonText: 'منح الإذن',

      // Permission Permanently Denied
      permissionPermanentlyDeniedTitle: 'تم رفض الإذن نهائياً',
      permissionPermanentlyDeniedMessage:
      'تم رفض إذن الموقع. تحتاج إلى تفعيله يدوياً من إعدادات التطبيق لاستخدام هذه الميزة.',
      permissionPermanentlyDeniedOpenSettingsButtonText: 'فتح إعدادات التطبيق',
      permissionPermanentlyDeniedRetryButtonText: 'حاول مرة أخرى',
      permissionPermanentlyDeniedInstructionSteps: [
        'اضغط على "فتح إعدادات التطبيق" أدناه',
        'انتقل إلى الأذونات ← الموقع',
        'اختر "السماح" أو "أثناء استخدام التطبيق"',
        'ارجع إلى هذا التطبيق',
      ],

      // Unknown Error
      unknownErrorTitle: 'حدث خطأ ما',
      unknownErrorMessage:
      'حدث خطأ غير متوقع أثناء الوصول إلى موقعك. يرجى المحاولة مرة أخرى.',
      unknownErrorRetryButtonText: 'حاول مرة أخرى',

      // Common
      instructionsHeaderText: 'كيفية التفعيل:',
    );
  }

  /// Creates strings based on the given [Locale].
  ///
  /// Supported languages:
  /// - English (en) - default
  /// - Arabic (ar)
  ///
  /// Falls back to English for unsupported languages.
  factory LocationErrorStrings.fromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return LocationErrorStrings.arabic();
      case 'en':
      default:
        return LocationErrorStrings.english();
    }
  }

  /// List of supported language codes for auto-detection.
  static const List<String> supportedLanguageCodes = ['en', 'ar'];

  /// Checks if the given language code is supported.
  static bool isLanguageSupported(String languageCode) {
    return supportedLanguageCodes.contains(languageCode);
  }

  // ============================================================
  // GPS Disabled Strings
  // ============================================================

  /// Title shown when GPS/location services are disabled.
  final String gpsDisabledTitle;

  /// Message explaining why GPS is needed and how to enable it.
  final String gpsDisabledMessage;

  /// Text for the button that opens device location settings.
  final String gpsDisabledOpenSettingsButtonText;

  /// Text for the retry button on GPS disabled screen.
  final String gpsDisabledRetryButtonText;

  /// Step-by-step instructions for enabling GPS.
  final List<String>? gpsDisabledInstructionSteps;

  // ============================================================
  // Permission Denied Strings
  // ============================================================

  /// Title shown when location permission is denied.
  final String permissionDeniedTitle;

  /// Message explaining why location permission is needed.
  final String permissionDeniedMessage;

  /// Text for the button that requests location permission.
  final String permissionDeniedGrantButtonText;

  /// Step-by-step instructions for granting permission.
  final List<String>? permissionDeniedInstructionSteps;

  // ============================================================
  // Permission Permanently Denied Strings
  // ============================================================

  /// Title shown when location permission is permanently denied.
  final String permissionPermanentlyDeniedTitle;

  /// Message explaining that permission must be enabled in settings.
  final String permissionPermanentlyDeniedMessage;

  /// Text for the button that opens app settings.
  final String permissionPermanentlyDeniedOpenSettingsButtonText;

  /// Text for the retry button on permission permanently denied screen.
  final String permissionPermanentlyDeniedRetryButtonText;

  /// Step-by-step instructions for enabling permission in app settings.
  final List<String>? permissionPermanentlyDeniedInstructionSteps;

  // ============================================================
  // Unknown Error Strings
  // ============================================================

  /// Title shown for unknown/unexpected errors.
  final String unknownErrorTitle;

  /// Message shown for unknown/unexpected errors.
  final String unknownErrorMessage;

  /// Text for the retry button on unknown error screen.
  final String unknownErrorRetryButtonText;

  /// Step-by-step instructions for unknown errors.
  final List<String>? unknownErrorInstructionSteps;

  // ============================================================
  // Common Strings
  // ============================================================

  /// Header text shown above instruction steps.
  final String instructionsHeaderText;

  /// Creates a copy of this strings with the given fields replaced.
  LocationErrorStrings copyWith({
    String? gpsDisabledTitle,
    String? gpsDisabledMessage,
    String? gpsDisabledOpenSettingsButtonText,
    String? gpsDisabledRetryButtonText,
    List<String>? gpsDisabledInstructionSteps,
    String? permissionDeniedTitle,
    String? permissionDeniedMessage,
    String? permissionDeniedGrantButtonText,
    List<String>? permissionDeniedInstructionSteps,
    String? permissionPermanentlyDeniedTitle,
    String? permissionPermanentlyDeniedMessage,
    String? permissionPermanentlyDeniedOpenSettingsButtonText,
    String? permissionPermanentlyDeniedRetryButtonText,
    List<String>? permissionPermanentlyDeniedInstructionSteps,
    String? unknownErrorTitle,
    String? unknownErrorMessage,
    String? unknownErrorRetryButtonText,
    List<String>? unknownErrorInstructionSteps,
    String? instructionsHeaderText,
  }) {
    return LocationErrorStrings(
      gpsDisabledTitle: gpsDisabledTitle ?? this.gpsDisabledTitle,
      gpsDisabledMessage: gpsDisabledMessage ?? this.gpsDisabledMessage,
      gpsDisabledOpenSettingsButtonText: gpsDisabledOpenSettingsButtonText ??
          this.gpsDisabledOpenSettingsButtonText,
      gpsDisabledRetryButtonText:
      gpsDisabledRetryButtonText ?? this.gpsDisabledRetryButtonText,
      gpsDisabledInstructionSteps:
      gpsDisabledInstructionSteps ?? this.gpsDisabledInstructionSteps,
      permissionDeniedTitle:
      permissionDeniedTitle ?? this.permissionDeniedTitle,
      permissionDeniedMessage:
      permissionDeniedMessage ?? this.permissionDeniedMessage,
      permissionDeniedGrantButtonText: permissionDeniedGrantButtonText ??
          this.permissionDeniedGrantButtonText,
      permissionDeniedInstructionSteps: permissionDeniedInstructionSteps ??
          this.permissionDeniedInstructionSteps,
      permissionPermanentlyDeniedTitle: permissionPermanentlyDeniedTitle ??
          this.permissionPermanentlyDeniedTitle,
      permissionPermanentlyDeniedMessage: permissionPermanentlyDeniedMessage ??
          this.permissionPermanentlyDeniedMessage,
      permissionPermanentlyDeniedOpenSettingsButtonText:
      permissionPermanentlyDeniedOpenSettingsButtonText ??
          this.permissionPermanentlyDeniedOpenSettingsButtonText,
      permissionPermanentlyDeniedRetryButtonText:
      permissionPermanentlyDeniedRetryButtonText ??
          this.permissionPermanentlyDeniedRetryButtonText,
      permissionPermanentlyDeniedInstructionSteps:
      permissionPermanentlyDeniedInstructionSteps ??
          this.permissionPermanentlyDeniedInstructionSteps,
      unknownErrorTitle: unknownErrorTitle ?? this.unknownErrorTitle,
      unknownErrorMessage: unknownErrorMessage ?? this.unknownErrorMessage,
      unknownErrorRetryButtonText:
      unknownErrorRetryButtonText ?? this.unknownErrorRetryButtonText,
      unknownErrorInstructionSteps:
      unknownErrorInstructionSteps ?? this.unknownErrorInstructionSteps,
      instructionsHeaderText:
      instructionsHeaderText ?? this.instructionsHeaderText,
    );
  }
}

// ============================================================
// Combined Configuration
// ============================================================

/// Complete configuration for location error widgets.
///
/// Combines [LocationErrorTheme] (icons & colors) with [LocationErrorStrings]
/// (translatable text) for full customization control.
///
/// ## Example: Auto-detect language (recommended)
/// ```dart
/// PlacePicker(
///   // locationErrorConfiguration is automatically detected from device locale
/// )
/// ```
///
/// ## Example: Custom theme only
/// ```dart
/// PlacePicker(
///   locationErrorConfiguration: LocationErrorConfiguration(
///     theme: LocationErrorTheme(
///       gpsDisabledIcon: Icons.gps_off,
///       gpsDisabledIconColor: Colors.orange,
///     ),
///   ),
/// )
/// ```
///
/// ## Example: Custom strings only (Arabic)
/// ```dart
/// PlacePicker(
///   locationErrorConfiguration: LocationErrorConfiguration(
///     strings: LocationErrorStrings.arabic(),
///   ),
/// )
/// ```
///
/// ## Example: Both custom theme and strings
/// ```dart
/// PlacePicker(
///   locationErrorConfiguration: LocationErrorConfiguration(
///     theme: LocationErrorTheme(gpsDisabledIcon: Icons.gps_off),
///     strings: LocationErrorStrings.arabic(),
///   ),
/// )
/// ```
class LocationErrorConfiguration {
  /// Creates a location error configuration.
  ///
  /// Both [theme] and [strings] default to their English/default values.
  const LocationErrorConfiguration({
    this.theme = const LocationErrorTheme(),
    this.strings = const LocationErrorStrings(),
  });

  /// Creates a configuration based on the given [Locale].
  ///
  /// The theme remains default (icons don't change by locale),
  /// but strings are auto-detected based on the locale.
  ///
  /// Supported languages:
  /// - English (en) - default
  /// - Arabic (ar)
  factory LocationErrorConfiguration.fromLocale(Locale locale) {
    return LocationErrorConfiguration(
      strings: LocationErrorStrings.fromLocale(locale),
    );
  }

  /// Visual theme configuration (icons and colors).
  final LocationErrorTheme theme;

  /// Translatable strings configuration.
  final LocationErrorStrings strings;

  /// List of supported language codes for auto-detection.
  static const List<String> supportedLanguageCodes =
      LocationErrorStrings.supportedLanguageCodes;

  /// Checks if the given language code is supported.
  static bool isLanguageSupported(String languageCode) {
    return LocationErrorStrings.isLanguageSupported(languageCode);
  }

  /// Creates a copy of this configuration with the given fields replaced.
  LocationErrorConfiguration copyWith({
    LocationErrorTheme? theme,
    LocationErrorStrings? strings,
  }) {
    return LocationErrorConfiguration(
      theme: theme ?? this.theme,
      strings: strings ?? this.strings,
    );
  }
}