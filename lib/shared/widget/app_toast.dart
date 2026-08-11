import 'package:book_drive_car/core/theme/app_assets.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:book_drive_car/shared/constants/app_keys.dart';

/// Variants for [AppToast], matching the Figma toast component.
enum AppToastType { success, error, warning, info }

/// Branded in-app toast notification shown via [ScaffoldMessenger].
///
/// Matches Figma specs exactly:
/// - pill shape (radius 9999), padding 20px, border 1px
/// - 40×40 icon bubble, 24×24 icon, 16px gap to text
/// - drop shadow: y=4, blur=12, 8% opacity tinted to variant
/// - dismiss via close button or auto-dismiss after the given duration
///
/// Usage:
/// ```dart
/// AppToast.show(context, message: 'Saved!');
/// AppToast.show(
///   context,
///   message: 'Something went wrong',
///   type: AppToastType.error,
/// );
/// ```
class AppToast extends StatelessWidget {
  const AppToast({
    required this.message,
    this.type = AppToastType.success,
    this.onClose,
    super.key,
  });

  final String message;
  final AppToastType type;

  /// Optional callback when close button is tapped.
  /// When null the X button still calls hideCurrentSnackBar automatically.
  final VoidCallback? onClose;

  static void showSuccess(BuildContext? context, String message) {
    show(context, message: message, type: AppToastType.success);
  }

  static void showError(BuildContext? context, String message) {
    show(context, message: message, type: AppToastType.error);
  }

  static void show(
    BuildContext? context, {
    required String message,
    AppToastType type = AppToastType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = appNavigatorKey.currentState?.overlay;

    if (overlay == null) {
      final messenger =
          appScaffoldMessengerKey.currentState ??
          (context != null ? ScaffoldMessenger.maybeOf(context) : null);
      if (messenger == null) {
        return;
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: AppToast(
              message: message,
              type: type,
              onClose: messenger.hideCurrentSnackBar,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            padding: EdgeInsets.zero,
            behavior: SnackBarBehavior.floating,
            duration: duration,
          ),
        );
      return;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) {
        final topInset = MediaQuery.of(overlayContext).padding.top;
        return Positioned(
          top: topInset + 16,
          left: 16,
          right: 16,
          child: SafeArea(
            bottom: false,
            child: Material(
              color: Colors.transparent,
              child: AppToast(
                message: message,
                type: type,
                onClose: () => entry.remove(),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    Timer(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  // Preserve old snackbar behavior for the fallback path only.
  static void _showSnackBarFallback(
    ScaffoldMessengerState messenger, {
    required String message,
    required AppToastType type,
    required Duration duration,
  }) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AppToast(
            message: message,
            type: type,
            onClose: messenger.hideCurrentSnackBar,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          behavior: SnackBarBehavior.floating,
          duration: duration,
        ),
      );
  }

  // ── Colors per variant ────────────────────────────────────────────────────

  Color get _background => switch (type) {
    AppToastType.success => AppColors.toastSuccessBackground,
    AppToastType.error => AppColors.toastErrorBackground,
    AppToastType.warning => AppColors.toastWarningBackground,
    AppToastType.info => AppColors.toastInfoBackground,
  };

  Color get _border => switch (type) {
    AppToastType.success => AppColors.toastSuccessBorder,
    AppToastType.error => AppColors.toastErrorBorder,
    AppToastType.warning => AppColors.toastWarningBorder,
    AppToastType.info => AppColors.toastInfoBorder,
  };

  Color get _shadow => switch (type) {
    AppToastType.success => AppColors.toastSuccessShadow,
    AppToastType.error => AppColors.toastErrorShadow,
    AppToastType.warning => AppColors.toastWarningShadow,
    AppToastType.info => AppColors.toastInfoShadow,
  };

  Color get _iconBg => switch (type) {
    AppToastType.success => AppColors.toastSuccessIconBg,
    AppToastType.error => AppColors.toastErrorIconBg,
    AppToastType.warning => AppColors.toastWarningIconBg,
    AppToastType.info => AppColors.toastInfoIconBg,
  };

  Color get _accentColor => switch (type) {
    AppToastType.success => AppColors.toastSuccessContent,
    AppToastType.error => AppColors.toastErrorContent,
    AppToastType.warning => AppColors.toastWarningContent,
    AppToastType.info => AppColors.toastInfoContent,
  };

  // Icon: success uses custom SVG; others fall back to Material icons
  Widget _buildIcon() {
    if (type == AppToastType.success) {
      return SvgPicture.asset(
        AppAssets.icCheckmarkCircle,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(_accentColor, BlendMode.srcIn),
      );
    }
    final icon = switch (type) {
      AppToastType.error => Icons.heart_broken_rounded,
      AppToastType.warning => Icons.warning_amber_rounded,
      AppToastType.info => Icons.info_rounded,
      AppToastType.success => Icons.check_circle_rounded,
    };
    return Icon(icon, size: 24, color: _accentColor);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: _shadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: _iconBg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: _buildIcon(),
            ),
            // ── Gap 16px ───────────────────────────────────────────────────
            const SizedBox(width: 16),
            // ── Message ────────────────────────────────────────────────────
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 20 / 14,
                  color: _accentColor,
                ),
              ),
            ),
            // ── Close button ───────────────────────────────────────────────
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (onClose != null) {
                  onClose!();
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                }
              },
              child: Opacity(
                opacity: 0.7,
                child: Icon(Icons.close, size: 16, color: _accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
