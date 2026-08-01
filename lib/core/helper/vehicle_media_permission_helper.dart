import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class VehicleMediaPermissionHelper {
  const VehicleMediaPermissionHelper();

  Future<bool> ensureCameraPermission(BuildContext context) async {
    return _ensurePermission(
      context,
      permission: Permission.camera,
      deniedMessage: 'Cần quyền camera để chụp ảnh xe.',
      permanentlyDeniedMessage:
          'Quyền camera đã bị từ chối vĩnh viễn. Hãy mở cài đặt để cấp lại.',
    );
  }

  Future<bool> ensureGalleryPermission(BuildContext context) async {
    return _ensurePermission(
      context,
      permission: Permission.photos,
      deniedMessage: 'Cần quyền thư viện ảnh để chọn ảnh từ máy.',
      permanentlyDeniedMessage:
          'Quyền thư viện ảnh đã bị từ chối vĩnh viễn. Hãy mở cài đặt để cấp lại.',
    );
  }

  Future<bool> _ensurePermission(
    BuildContext context, {
    required Permission permission,
    required String deniedMessage,
    required String permanentlyDeniedMessage,
  }) async {
    final status = await permission.status;
    if (status.isGranted || status.isLimited) {
      return true;
    }

    final result = await permission.request();
    if (result.isGranted || result.isLimited) {
      return true;
    }

    final message = result.isPermanentlyDenied
        ? permanentlyDeniedMessage
        : deniedMessage;

    AppToast.show(
      context,
      message: message,
      type: AppToastType.warning,
    );

    if (result.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }
}
