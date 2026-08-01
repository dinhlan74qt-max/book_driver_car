import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

Future<Uint8List?> showVehicleLandscapeCropper(
  BuildContext context, {
  required Uint8List bytes,
  required String title,
  double aspectRatio = 16 / 10,
}) {
  return showModalBottomSheet<Uint8List>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: _VehicleLandscapeCropperSheet(
          bytes: bytes,
          title: title,
          aspectRatio: aspectRatio,
        ),
      );
    },
  );
}

class _VehicleLandscapeCropperSheet extends StatefulWidget {
  final Uint8List bytes;
  final String title;
  final double aspectRatio;

  const _VehicleLandscapeCropperSheet({
    required this.bytes,
    required this.title,
    required this.aspectRatio,
  });

  @override
  State<_VehicleLandscapeCropperSheet> createState() =>
      _VehicleLandscapeCropperSheetState();
}

class _VehicleLandscapeCropperSheetState
    extends State<_VehicleLandscapeCropperSheet> {
  final TransformationController _controller = TransformationController();

  ui.Image? _sourceImage;
  Size? _cropSize;
  bool _isLoading = true;
  bool _isExporting = false;
  bool _didInitialize = false;
  bool _isAdjustingTransform = false;

  double _minScale = 1.0;
  double _maxScale = 4.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTransformChanged);
    _loadImage();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTransformChanged);
    _controller.dispose();
    _sourceImage?.dispose();
    super.dispose();
  }

  void _handleTransformChanged() {
    if (_isAdjustingTransform || _isLoading) return;

    final image = _sourceImage;
    final cropSize = _cropSize;
    if (image == null || cropSize == null || !_didInitialize) return;

    final matrix = _controller.value;
    final scale = matrix.getMaxScaleOnAxis();
    final targetScale = scale < _minScale ? _minScale : scale;
    final scaledWidth = image.width * targetScale;
    final scaledHeight = image.height * targetScale;

    double dx;
    double dy;

    if (scaledWidth <= cropSize.width) {
      dx = (cropSize.width - scaledWidth) / 2;
    } else {
      dx = matrix.storage[12].clamp(cropSize.width - scaledWidth, 0.0).toDouble();
    }

    if (scaledHeight <= cropSize.height) {
      dy = (cropSize.height - scaledHeight) / 2;
    } else {
      dy = matrix.storage[13].clamp(cropSize.height - scaledHeight, 0.0).toDouble();
    }

    final needsClamp =
        (scale - targetScale).abs() > 0.001 ||
        (matrix.storage[12] - dx).abs() > 0.5 ||
        (matrix.storage[13] - dy).abs() > 0.5;

    if (!needsClamp) return;

    _isAdjustingTransform = true;
    _controller.value = Matrix4.identity()
      ..setEntry(0, 0, targetScale)
      ..setEntry(1, 1, targetScale)
      ..setTranslationRaw(dx, dy, 0);
    _isAdjustingTransform = false;
  }

  Future<void> _loadImage() async {
    try {
      final codec = await ui.instantiateImageCodec(widget.bytes);
      final frame = await codec.getNextFrame();
      codec.dispose();

      if (!mounted) {
        frame.image.dispose();
        return;
      }

      setState(() {
        _sourceImage = frame.image;
        _isLoading = false;
      });
      _syncInitialTransform();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
    }
  }

  void _syncInitialTransform() {
    final image = _sourceImage;
    final cropSize = _cropSize;
    if (image == null || cropSize == null || _didInitialize) return;

    final coverScale = math.max(
      cropSize.width / image.width,
      cropSize.height / image.height,
    );
    final dx = (cropSize.width - image.width * coverScale) / 2;
    final dy = (cropSize.height - image.height * coverScale) / 2;

    _controller.value = Matrix4.identity()
      ..setEntry(0, 0, coverScale)
      ..setEntry(1, 1, coverScale)
      ..setTranslationRaw(dx, dy, 0);

    _minScale = coverScale;
    _maxScale = coverScale * 4;
    _didInitialize = true;
    setState(() {});
  }

  Rect _viewportToImageRect(Size cropSize) {
    final image = _sourceImage;
    if (image == null) return Rect.zero;

    final topLeft = _controller.toScene(Offset.zero);
    final bottomRight = _controller.toScene(
      Offset(cropSize.width, cropSize.height),
    );

    final left = topLeft.dx.clamp(0.0, image.width.toDouble());
    final top = topLeft.dy.clamp(0.0, image.height.toDouble());
    final right = bottomRight.dx.clamp(0.0, image.width.toDouble());
    final bottom = bottomRight.dy.clamp(0.0, image.height.toDouble());

    return Rect.fromLTRB(
      math.min(left, right),
      math.min(top, bottom),
      math.max(left, right),
      math.max(top, bottom),
    );
  }

  Future<void> _confirmCrop() async {
    final image = _sourceImage;
    final cropSize = _cropSize;
    if (image == null || cropSize == null || _isExporting) return;

    setState(() => _isExporting = true);

    try {
      final sourceRect = _viewportToImageRect(cropSize);
      final targetWidth = 1600;
      final targetHeight = (targetWidth / widget.aspectRatio).round();

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..filterQuality = FilterQuality.high;
      final destRect = Rect.fromLTWH(
        0,
        0,
        targetWidth.toDouble(),
        targetHeight.toDouble(),
      );

      canvas.drawImageRect(image, sourceRect, destRect, paint);
      final picture = recorder.endRecording();
      final exported = await picture.toImage(targetWidth, targetHeight);
      final data = await exported.toByteData(format: ui.ImageByteFormat.png);
      exported.dispose();

      if (!mounted) return;
      Navigator.of(context).pop(data?.buffer.asUint8List());
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final sheetHeight = media.size.height * 0.92;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: sheetHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 46,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Kéo và chụp bằng 2 ngón để canh khung ảnh ngang.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isExporting
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth - 32;
                  final frameWidth = math.max(
                    0.0,
                    math.min(availableWidth, 560.0),
                  );
                  final frameHeight = frameWidth / widget.aspectRatio;
                  final cropSize = Size(frameWidth, frameHeight);

                  if (_cropSize != cropSize) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      setState(() => _cropSize = cropSize);
                      _syncInitialTransform();
                    });
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              width: cropSize.width,
                              height: cropSize.height,
                              child: _isLoading || _sourceImage == null
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFFF2F5F9),
                                                  Color(0xFFE7EEF5),
                                                ],
                                              ),
                                            ),
                                          ),
                                          InteractiveViewer(
                                            transformationController:
                                                _controller,
                                            constrained: false,
                                            panEnabled: true,
                                            scaleEnabled: true,
                                            minScale: _minScale,
                                            maxScale: _maxScale,
                                            boundaryMargin: EdgeInsets.zero,
                                            clipBehavior: Clip.hardEdge,
                                            child: SizedBox(
                                              width:
                                                  _sourceImage!.width.toDouble(),
                                              height: _sourceImage!.height
                                                  .toDouble(),
                                              child: RawImage(
                                                image: _sourceImage,
                                                fit: BoxFit.fill,
                                                filterQuality:
                                                    FilterQuality.high,
                                              ),
                                            ),
                                          ),
                                          const _CropFrameOverlay(),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: const [
                            _CropHintChip(
                              icon: Icons.open_with_rounded,
                              label: 'Kéo để canh khung',
                            ),
                            SizedBox(width: 10),
                            _CropHintChip(
                              icon: Icons.zoom_in_rounded,
                              label: 'Phóng to bằng 2 ngón',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SafeArea(
                          top: false,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isExporting ? null : _confirmCrop,
                              icon: _isExporting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.check_rounded),
                              label: Text(
                                _isExporting ? 'Đang lưu...' : 'Dùng ảnh này',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropFrameOverlay extends StatelessWidget {
  const _CropFrameOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(0.9),
            width: 1.4,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _CropGridPainter(),
              ),
            ),
            Positioned(
              left: 14,
              top: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Tỷ lệ ngang',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.72)
      ..strokeWidth = 1;

    final thirdWidth = size.width / 3;
    final thirdHeight = size.height / 3;

    for (var i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(thirdWidth * i, 0),
        Offset(thirdWidth * i, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, thirdHeight * i),
        Offset(size.width, thirdHeight * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CropHintChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CropHintChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
