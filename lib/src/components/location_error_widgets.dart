import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_place_picker_mb/src/models/enums.dart'
    show LocationErrorType;

import '../models/location_error_configuration.dart';

// ============================================================
// Location Error Bottom Sheet
// ============================================================

/// Shows a modal bottom sheet for location errors.
///
/// Returns a [Future] that completes when the bottom sheet is dismissed.
Future<void> showLocationErrorBottomSheet({
  required BuildContext context,
  required LocationErrorType errorType,
  LocationErrorConfiguration? config,
}) async {
  final effectiveConfig = config ??
      LocationErrorConfiguration.fromLocale(Localizations.localeOf(context));

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _LocationErrorBottomSheet(
      errorType: errorType,
      config: effectiveConfig,
    ),
  );
}

/// A compact bottom sheet widget for displaying location errors.
class _LocationErrorBottomSheet extends StatelessWidget {
  const _LocationErrorBottomSheet({
    required this.errorType,
    required this.config,
  });

  final LocationErrorType errorType;
  final LocationErrorConfiguration config;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDragHandle(colorScheme),
              const SizedBox(height: 16),
              _buildContent(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle(ColorScheme colorScheme) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    final (icon, iconColor, iconBgColor, title, message, buttonText, onAction) =
        _getErrorData(colorScheme);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 40, color: iconColor),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onAction();
            },
            icon: const Icon(Icons.settings_rounded, size: 20),
            label: Text(buttonText),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  (IconData, Color, Color, String, String, String, VoidCallback) _getErrorData(
      ColorScheme colorScheme) {
    return switch (errorType) {
      LocationErrorType.locationServiceDisabled => (
          config.theme.gpsDisabledIcon,
          config.theme.gpsDisabledIconColor ?? colorScheme.error,
          config.theme.gpsDisabledIconBackgroundColor ??
              colorScheme.errorContainer.withValues(alpha: 0.4),
          config.strings.gpsDisabledTitle,
          config.strings.gpsDisabledMessage,
          config.strings.gpsDisabledOpenSettingsButtonText,
          () => Geolocator.openLocationSettings(),
        ),
      LocationErrorType.permissionDenied => (
          config.theme.permissionDeniedIcon,
          config.theme.permissionDeniedIconColor ?? colorScheme.tertiary,
          config.theme.permissionDeniedIconBackgroundColor ??
              colorScheme.tertiaryContainer.withValues(alpha: 0.4),
          config.strings.permissionDeniedTitle,
          config.strings.permissionDeniedMessage,
          config.strings.permissionDeniedGrantButtonText,
          () => Geolocator.requestPermission(),
        ),
      LocationErrorType.permissionDeniedForever => (
          config.theme.permissionPermanentlyDeniedIcon,
          config.theme.permissionPermanentlyDeniedIconColor ??
              colorScheme.error,
          config.theme.permissionPermanentlyDeniedIconBackgroundColor ??
              colorScheme.errorContainer.withValues(alpha: 0.4),
          config.strings.permissionPermanentlyDeniedTitle,
          config.strings.permissionPermanentlyDeniedMessage,
          config.strings.permissionPermanentlyDeniedOpenSettingsButtonText,
          () => Geolocator.openAppSettings(),
        ),
      LocationErrorType.unknown => (
          config.theme.unknownErrorIcon,
          config.theme.unknownErrorIconColor ?? colorScheme.error,
          config.theme.unknownErrorIconBackgroundColor ??
              colorScheme.errorContainer.withValues(alpha: 0.4),
          config.strings.unknownErrorTitle,
          config.strings.unknownErrorMessage,
          config.strings.unknownErrorRetryButtonText,
          () {},
        ),
    };
  }
}

/// Default location error widget based on error type.
///
/// Auto-detects locale if [config] is null.
class DefaultLocationErrorWidget extends StatelessWidget {
  const DefaultLocationErrorWidget({
    required this.errorType,
    required this.onRetry,
    this.config,
    this.error,
  });

  final LocationErrorType errorType;
  final Object? error;
  final VoidCallback onRetry;
  final LocationErrorConfiguration? config;

  @override
  Widget build(BuildContext context) {
    // Auto-detect configuration from device locale if not provided
    final effectiveConfig = config ??
        LocationErrorConfiguration.fromLocale(Localizations.localeOf(context));

    return Scaffold(
      body: switch (errorType) {
        LocationErrorType.locationServiceDisabled => GpsDisabledSolutionWidget(
            onRetry: onRetry,
            config: effectiveConfig,
          ),
        LocationErrorType.permissionDenied => PermissionDeniedSolutionWidget(
            onRetry: onRetry,
            config: effectiveConfig,
          ),
        LocationErrorType.permissionDeniedForever =>
          PermissionPermanentlyDeniedSolutionWidget(
            onRetry: onRetry,
            config: effectiveConfig,
          ),
        LocationErrorType.unknown => UnknownErrorSolutionWidget(
            onRetry: onRetry,
            errorMessage: error?.toString(),
            config: effectiveConfig,
          ),
      },
    );
  }
}

// ============================================================
// Error Solution Widgets
// ============================================================

/// Base widget for displaying location errors with solutions.
///
/// This widget handles the common UI pattern for all location error types
/// and automatically retries when the app resumes from settings.
class LocationErrorSolutionWidget extends StatefulWidget {
  const LocationErrorSolutionWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryButtonText,
    required this.onPrimaryAction,
    required this.onRetry,
    this.secondaryButtonText,
    this.onSecondaryAction,
    this.iconColor,
    this.iconBackgroundColor,
    this.instructionSteps,
    this.instructionsHeaderText = 'How to enable:',
    this.autoRetryOnResume = true,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryButtonText;
  final VoidCallback onPrimaryAction;
  final VoidCallback onRetry;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryAction;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final List<String>? instructionSteps;
  final String instructionsHeaderText;
  final bool autoRetryOnResume;

  @override
  State<LocationErrorSolutionWidget> createState() =>
      _LocationErrorSolutionWidgetState();
}

class _LocationErrorSolutionWidgetState
    extends State<LocationErrorSolutionWidget> with WidgetsBindingObserver {
  bool _waitingForSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _waitingForSettings &&
        widget.autoRetryOnResume) {
      _waitingForSettings = false;
      widget.onRetry();
    }
  }

  void _handlePrimaryAction() {
    _waitingForSettings = true;
    widget.onPrimaryAction();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            _ErrorIconSection(
              icon: widget.icon,
              iconColor: widget.iconColor,
              iconBackgroundColor: widget.iconBackgroundColor,
            ),
            const SizedBox(height: 32),
            _ErrorTextSection(
              title: widget.title,
              message: widget.message,
            ),
            if (widget.instructionSteps != null) ...[
              const SizedBox(height: 24),
              _InstructionStepsSection(
                headerText: widget.instructionsHeaderText,
                instructionSteps: widget.instructionSteps!,
              ),
            ],
            const SizedBox(height: 40),
            _ActionButtonsSection(
              primaryButtonText: widget.primaryButtonText,
              secondaryButtonText: widget.secondaryButtonText,
              onPrimaryAction: _handlePrimaryAction,
              onSecondaryAction: widget.onSecondaryAction ?? widget.onRetry,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// Displays the error icon with circular background.
class _ErrorIconSection extends StatelessWidget {
  const _ErrorIconSection({
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
  });

  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: iconBackgroundColor ??
            colorScheme.errorContainer.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 72,
        color: iconColor ?? colorScheme.error,
      ),
    );
  }
}

/// Displays the error title and message text.
class _ErrorTextSection extends StatelessWidget {
  const _ErrorTextSection({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Displays the numbered instruction steps.
class _InstructionStepsSection extends StatelessWidget {
  const _InstructionStepsSection({
    required this.headerText,
    required this.instructionSteps,
  });

  final String headerText;
  final List<String> instructionSteps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                headerText,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...instructionSteps.asMap().entries.map((entry) {
            return _InstructionStepItem(
              stepNumber: entry.key + 1,
              stepText: entry.value,
            );
          }),
        ],
      ),
    );
  }
}

/// A single instruction step item with number badge.
class _InstructionStepItem extends StatelessWidget {
  const _InstructionStepItem({
    required this.stepNumber,
    required this.stepText,
  });

  final int stepNumber;
  final String stepText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stepText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays primary and optional secondary action buttons.
class _ActionButtonsSection extends StatelessWidget {
  const _ActionButtonsSection({
    required this.primaryButtonText,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    this.secondaryButtonText,
  });

  final String primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onPrimaryAction,
            icon: const Icon(Icons.settings_rounded),
            label: Text(primaryButtonText),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (secondaryButtonText != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSecondaryAction,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(secondaryButtonText!),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================
// Specific Error Widgets
// ============================================================

/// Widget displayed when GPS/Location services are disabled on the device.
///
/// Provides a button to open device location settings and auto-retries
/// when the user returns to the app.
class GpsDisabledSolutionWidget extends StatelessWidget {
  const GpsDisabledSolutionWidget({
    super.key,
    required this.onRetry,
    required this.config,
  });

  final VoidCallback onRetry;
  final LocationErrorConfiguration config;

  @override
  Widget build(BuildContext context) {
    return LocationErrorSolutionWidget(
      icon: config.theme.gpsDisabledIcon,
      iconColor: config.theme.gpsDisabledIconColor,
      iconBackgroundColor: config.theme.gpsDisabledIconBackgroundColor,
      title: config.strings.gpsDisabledTitle,
      message: config.strings.gpsDisabledMessage,
      primaryButtonText: config.strings.gpsDisabledOpenSettingsButtonText,
      secondaryButtonText: config.strings.gpsDisabledRetryButtonText,
      instructionSteps: config.strings.gpsDisabledInstructionSteps,
      instructionsHeaderText: config.strings.instructionsHeaderText,
      onPrimaryAction: () async {
        await Geolocator.openLocationSettings();
      },
      onRetry: onRetry,
    );
  }
}

/// Widget displayed when location permission is denied.
///
/// Provides a button to request permission again.
class PermissionDeniedSolutionWidget extends StatelessWidget {
  const PermissionDeniedSolutionWidget({
    super.key,
    required this.onRetry,
    required this.config,
  });

  final VoidCallback onRetry;
  final LocationErrorConfiguration config;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LocationErrorSolutionWidget(
      icon: config.theme.permissionDeniedIcon,
      iconColor: config.theme.permissionDeniedIconColor ?? colorScheme.tertiary,
      iconBackgroundColor: config.theme.permissionDeniedIconBackgroundColor ??
          colorScheme.tertiaryContainer.withValues(alpha: 0.4),
      title: config.strings.permissionDeniedTitle,
      message: config.strings.permissionDeniedMessage,
      primaryButtonText: config.strings.permissionDeniedGrantButtonText,
      instructionSteps: config.strings.permissionDeniedInstructionSteps,
      instructionsHeaderText: config.strings.instructionsHeaderText,
      onPrimaryAction: onRetry,
      onRetry: onRetry,
      autoRetryOnResume: false,
    );
  }
}

/// Widget displayed when location permission is permanently denied.
///
/// Provides a button to open app settings and auto-retries
/// when the user returns to the app.
class PermissionPermanentlyDeniedSolutionWidget extends StatelessWidget {
  const PermissionPermanentlyDeniedSolutionWidget({
    super.key,
    required this.onRetry,
    required this.config,
  });

  final VoidCallback onRetry;
  final LocationErrorConfiguration config;

  @override
  Widget build(BuildContext context) {
    return LocationErrorSolutionWidget(
      icon: config.theme.permissionPermanentlyDeniedIcon,
      iconColor: config.theme.permissionPermanentlyDeniedIconColor,
      iconBackgroundColor:
          config.theme.permissionPermanentlyDeniedIconBackgroundColor,
      title: config.strings.permissionPermanentlyDeniedTitle,
      message: config.strings.permissionPermanentlyDeniedMessage,
      primaryButtonText:
          config.strings.permissionPermanentlyDeniedOpenSettingsButtonText,
      secondaryButtonText:
          config.strings.permissionPermanentlyDeniedRetryButtonText,
      instructionSteps:
          config.strings.permissionPermanentlyDeniedInstructionSteps,
      instructionsHeaderText: config.strings.instructionsHeaderText,
      onPrimaryAction: () async {
        await Geolocator.openAppSettings();
      },
      onRetry: onRetry,
    );
  }
}

/// Widget displayed for unknown location errors.
///
/// Provides a retry button and shows an error message.
class UnknownErrorSolutionWidget extends StatelessWidget {
  const UnknownErrorSolutionWidget({
    super.key,
    required this.onRetry,
    required this.config,
    this.errorMessage,
  });

  final VoidCallback onRetry;
  final String? errorMessage;
  final LocationErrorConfiguration config;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LocationErrorSolutionWidget(
      icon: config.theme.unknownErrorIcon,
      iconColor: config.theme.unknownErrorIconColor ?? colorScheme.error,
      iconBackgroundColor: config.theme.unknownErrorIconBackgroundColor,
      title: config.strings.unknownErrorTitle,
      message: errorMessage ?? config.strings.unknownErrorMessage,
      primaryButtonText: config.strings.unknownErrorRetryButtonText,
      instructionSteps: config.strings.unknownErrorInstructionSteps,
      instructionsHeaderText: config.strings.instructionsHeaderText,
      onPrimaryAction: onRetry,
      onRetry: onRetry,
      autoRetryOnResume: false,
    );
  }
}
