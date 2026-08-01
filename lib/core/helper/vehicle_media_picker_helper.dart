import 'dart:typed_data';

import 'package:book_drive_car/core/helper/vehicle_image_cropper.dart';
import 'package:book_drive_car/core/helper/vehicle_media_permission_helper.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VehiclePickedMedia {
  final String name;
  final Uint8List bytes;

  const VehiclePickedMedia({
    required this.name,
    required this.bytes,
  });
}

class VehicleMediaPickerHelper {
  final ImagePicker _imagePicker = ImagePicker();
  final VehicleMediaPermissionHelper _permissionHelper =
      const VehicleMediaPermissionHelper();

  Future<VehiclePickedMedia?> pickFromGallery(
    BuildContext context, {
    bool cropLandscape = true,
    String cropTitle = 'Cắt ảnh xe',
  }) async {
    final hasPermission = await _permissionHelper.ensureGalleryPermission(
      context,
    );
    if (!hasPermission) return null;

    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (file == null) {
      AppToast.show(
        context,
        message: 'Bạn chưa chọn ảnh nào.',
        type: AppToastType.info,
      );
      return null;
    }

    final bytes = await file.readAsBytes();
    if (!cropLandscape) {
      return VehiclePickedMedia(name: file.name, bytes: bytes);
    }

    final croppedBytes = await showVehicleLandscapeCropper(
      context,
      bytes: bytes,
      title: cropTitle,
    );
    if (croppedBytes == null) return null;

    return VehiclePickedMedia(name: file.name, bytes: croppedBytes);
  }

  Future<VehiclePickedMedia?> pickFromCamera(
    BuildContext context, {
    bool cropLandscape = true,
    String cropTitle = 'Cắt ảnh xe',
  }) async {
    final hasPermission = await _permissionHelper.ensureCameraPermission(
      context,
    );
    if (!hasPermission) return null;

    final file = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (file == null) {
      AppToast.show(
        context,
        message: 'Bạn chưa chụp ảnh nào.',
        type: AppToastType.info,
      );
      return null;
    }

    final bytes = await file.readAsBytes();
    if (!cropLandscape) {
      return VehiclePickedMedia(name: file.name, bytes: bytes);
    }

    final croppedBytes = await showVehicleLandscapeCropper(
      context,
      bytes: bytes,
      title: cropTitle,
    );
    if (croppedBytes == null) return null;

    return VehiclePickedMedia(name: file.name, bytes: croppedBytes);
  }
}
