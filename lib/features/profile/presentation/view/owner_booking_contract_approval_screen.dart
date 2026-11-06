import 'dart:typed_data';

import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/auth/domain/entities/user_entity.dart';
import 'package:book_drive_car/features/profile/domain/entities/owner_booking_entity.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/owner_booking_cubit.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_status_badge.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:signature/signature.dart';

class OwnerBookingContractApprovalScreen extends StatefulWidget {
  final OwnerBookingEntity booking;

  const OwnerBookingContractApprovalScreen({super.key, required this.booking});

  @override
  State<OwnerBookingContractApprovalScreen> createState() =>
      _OwnerBookingContractApprovalScreenState();
}

class _OwnerBookingContractApprovalScreenState
    extends State<OwnerBookingContractApprovalScreen> {
  late final SignatureController _signatureController;
  Uint8List? _contractPdfBytes;
  UserEntity? _owner;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3.2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _init();
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final storage = sl<UserLocalStorage>();
      final dio = sl<Dio>();
      final owner = await storage.getUser();
      Uint8List? pdfBytes;

      final url = widget.booking.contractImage?.trim() ?? '';
      debugPrint(
        '[OwnerBookingContractApproval][_init] bookingId=${widget.booking.id}',
      );
      debugPrint(
        '[OwnerBookingContractApproval][_init] bookingCode=${widget.booking.bookingCode}',
      );
      debugPrint(
        '[OwnerBookingContractApproval][_init] contractImage=${url.isEmpty ? "[empty]" : url}',
      );
      if (url.isNotEmpty) {
        final response = await dio.get<List<int>>(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            validateStatus: (_) => true,
          ),
        );
        debugPrint(
          '[OwnerBookingContractApproval][_init] HTTP ${response.statusCode} '
          'contentType=${response.headers.value(Headers.contentTypeHeader)} '
          'contentLength=${response.headers.value(Headers.contentLengthHeader)}',
        );
        final data = response.data;
        final byteLength = data?.length ?? 0;
        debugPrint(
          '[OwnerBookingContractApproval][_init] pdfBytesLength=$byteLength',
        );
        if (response.statusCode == 200 &&
            data != null &&
            data.isNotEmpty &&
            (response.headers.value(Headers.contentTypeHeader) ?? '').contains(
              'pdf',
            )) {
          pdfBytes = Uint8List.fromList(data);
        } else if (response.statusCode == 200 &&
            data != null &&
            data.isNotEmpty) {
          pdfBytes = Uint8List.fromList(data);
          debugPrint(
            '[OwnerBookingContractApproval][_init] warning=received bytes but content-type is not pdf',
          );
        }
      } else {
        debugPrint(
          '[OwnerBookingContractApproval][_init] skipped download because contractImage is empty',
        );
      }

      if (!mounted) return;
      setState(() {
        _owner = owner;
        _contractPdfBytes = pdfBytes;
        _loading = false;
        _error = pdfBytes == null
            ? 'Không tải được tài liệu PDF. Bạn vẫn có thể tải lại hoặc liên hệ backend nếu link lỗi.'
            : null;
      });
    } catch (e) {
      debugPrint('[OwnerBookingContractApproval][_init] error=$e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _formatDate(DateTime value) {
    return DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(value);
  }

  String _formatCurrency(num value) {
    return NumberFormat.decimalPattern('vi_VN').format(value);
  }

  Future<pw.ThemeData> _loadTheme() async {
    final regularFont = pw.Font.ttf(
      (await rootBundle.load('assets/fonts/arialuni.ttf')).buffer.asByteData(),
    );
    final boldFont = pw.Font.ttf(
      (await rootBundle.load('assets/fonts/arialbd.ttf')).buffer.asByteData(),
    );
    return pw.ThemeData.withFont(base: regularFont, bold: boldFont);
  }

  Future<Uint8List> _buildSignedPdf(Uint8List signatureBytes) async {
    final doc = pw.Document(theme: await _loadTheme());
    final signatureImage = pw.MemoryImage(signatureBytes);
    final ownerName = _owner?.fullname ?? 'Chủ xe';
    final ownerPhone = _owner?.phone ?? 'Không có';
    final ownerEmail = _owner?.email ?? 'Không có';
    final contractUrl = widget.booking.contractImage?.trim() ?? '';

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: pdf.PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
        ),
        build: (_) => [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'XÁC NHẬN DUYỆT HỢP ĐỒNG',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Ngày ký: ${_formatDate(DateTime.now())}'),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          _pdfHeading('THÔNG TIN GIAO DỊCH'),
          _pdfLine('Mã booking', widget.booking.bookingCode),
          _pdfLine('Xe', widget.booking.vehicleName),
          _pdfLine('Biển số', widget.booking.licensePlate),
          _pdfLine('Người thuê', widget.booking.renterName),
          _pdfLine('Số điện thoại', widget.booking.renterPhone),
          _pdfLine('Từ ngày', _formatDate(widget.booking.startDate)),
          _pdfLine('Đến ngày', _formatDate(widget.booking.endDate)),
          _pdfLine(
            'Tổng tiền',
            '${_formatCurrency(widget.booking.totalPrice)} VNĐ',
          ),
          if (contractUrl.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            _pdfLine('Tài liệu gốc', contractUrl),
          ],
          pw.SizedBox(height: 16),
          _pdfHeading('XÁC NHẬN CỦA CHỦ XE'),
          pw.SizedBox(height: 8),
          pw.Text(
            'Tôi xác nhận đã đọc, hiểu và đồng ý duyệt hợp đồng thuê xe nêu trên.',
            style: const pw.TextStyle(fontSize: 11.4, height: 1.45),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BÊN A - CHỦ XE',
                      style: pw.TextStyle(
                        fontSize: 12.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('Họ và tên: $ownerName'),
                    pw.SizedBox(height: 4),
                    pw.Text('Số điện thoại: $ownerPhone'),
                    pw.SizedBox(height: 4),
                    pw.Text('Email: $ownerEmail'),
                    pw.SizedBox(height: 8),
                    pw.Text('Chữ ký:'),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      height: 96,
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(
                            color: pdf.PdfColors.black,
                            width: 1,
                          ),
                        ),
                      ),
                      child: pw.Center(
                        child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BÊN B - NGƯỜI THUÊ',
                      style: pw.TextStyle(
                        fontSize: 12.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('Họ và tên: ${widget.booking.renterName}'),
                    pw.SizedBox(height: 4),
                    pw.Text('Số điện thoại: ${widget.booking.renterPhone}'),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Đã ký trong hợp đồng gốc hiển thị bên trên.',
                      style: const pw.TextStyle(fontSize: 11.2),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      height: 96,
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(
                            color: pdf.PdfColors.black,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Bản xác nhận này được tạo sau khi chủ xe duyệt đơn trên nền tảng.',
            style: const pw.TextStyle(fontSize: 11.2, height: 1.45),
          ),
        ],
      ),
    );

    return doc.save();
  }

  Future<Uint8List> _buildFinalApprovedPdf(Uint8List signatureBytes) async {
    final originalBytes = _contractPdfBytes;
    if (originalBytes == null || originalBytes.isEmpty) {
      return _buildSignedPdf(signatureBytes);
    }

    final doc = pw.Document(theme: await _loadTheme());
    final signatureImage = pw.MemoryImage(signatureBytes);
    final ownerName = _owner?.fullname ?? 'Chủ xe';
    final ownerPhone = _owner?.phone ?? 'Không có';
    final ownerEmail = _owner?.email ?? 'Không có';

    await for (final rasterPage in Printing.raster(originalBytes, dpi: 150)) {
      final pageImage = pw.MemoryImage(await rasterPage.toPng());
      doc.addPage(
        pw.Page(
          pageFormat: pdf.PdfPageFormat(
            rasterPage.width.toDouble(),
            rasterPage.height.toDouble(),
          ),
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Image(pageImage, fit: pw.BoxFit.fill),
          ),
        ),
      );
    }

    doc.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: pdf.PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
        ),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'XÁC NHẬN DUYỆT HỢP ĐỒNG',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Bên dưới là chữ ký xác nhận của chủ xe. Hợp đồng gốc của bên thuê đã được giữ nguyên ở các trang trước.',
              style: const pw.TextStyle(fontSize: 11.5, height: 1.45),
            ),
            pw.SizedBox(height: 18),
            pw.Text(
              'BÊN A - CHỦ XE',
              style: pw.TextStyle(
                fontSize: 12.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text('Họ và tên: $ownerName'),
            pw.SizedBox(height: 4),
            pw.Text('Số điện thoại: $ownerPhone'),
            pw.SizedBox(height: 4),
            pw.Text('Email: $ownerEmail'),
            pw.SizedBox(height: 8),
            pw.Text('Chữ ký:'),
            pw.SizedBox(height: 8),
            pw.Container(
              height: 110,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: pdf.PdfColors.black, width: 1),
              ),
              child: pw.Center(
                child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              'BÊN B - NGƯỜI THUÊ',
              style: pw.TextStyle(
                fontSize: 12.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text('Họ và tên: ${widget.booking.renterName}'),
            pw.SizedBox(height: 4),
            pw.Text('Số điện thoại: ${widget.booking.renterPhone}'),
            pw.SizedBox(height: 4),
            pw.Text(
              'Chữ ký của người thuê đã nằm trong hợp đồng gốc ở các trang trước.',
              style: const pw.TextStyle(fontSize: 11.5, height: 1.45),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  pw.Widget _pdfHeading(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: 13.2, fontWeight: pw.FontWeight.bold),
    );
  }

  pw.Widget _pdfLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4),
      child: pw.Text(
        '$label: $value',
        style: const pw.TextStyle(fontSize: 11.2, height: 1.35),
      ),
    );
  }

  Future<void> _approve() async {
    if (_submitting) return;
    if (_signatureController.isEmpty) {
      AppToast.show(
        context,
        message: 'Vui lòng ký xác nhận trước khi duyệt đơn',
        type: AppToastType.warning,
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final signatureBytes = await _signatureController.toPngBytes();
      if (signatureBytes == null || signatureBytes.isEmpty) {
        throw Exception('Không xuất được chữ ký');
      }

      final pdfBytes = await _buildFinalApprovedPdf(signatureBytes);
      final success = await context
          .read<OwnerBookingCubit>()
          .approveBookingWithContract(
            id: widget.booking.id,
            contractPdfBytes: pdfBytes,
            contractPdfFileName:
                'owner_signed_${DateTime.now().millisecondsSinceEpoch}.pdf',
          );

      if (!mounted) return;
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        AppToast.show(
          context,
          message: 'Không thể duyệt hợp đồng. Vui lòng thử lại!',
          type: AppToastType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surfacePrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: TapScale(
              onTap: _submitting ? null : () => Navigator.of(context).pop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duyệt & Ký Hợp Đồng',
              style: AppTypography.headingMd.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${widget.booking.vehicleName} • #${widget.booking.bookingCode}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Contract PDF Card
                          Container(
                            height: 380,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderLight),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.borderLight,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.description_outlined,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Văn bản hợp đồng thuê',
                                          style: AppTypography.labelLarge.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (_contractPdfBytes != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'PDF Sẵn sàng',
                                            style: AppTypography.caption.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: _contractPdfBytes != null
                                      ? Stack(
                                          children: [
                                            PdfPreview(
                                              build: (_) async =>
                                                  _contractPdfBytes!,
                                              canChangePageFormat: false,
                                              canChangeOrientation: false,
                                              canDebug: false,
                                              allowPrinting: false,
                                              allowSharing: false,
                                              pdfFileName:
                                                  'contract_${widget.booking.bookingCode}.pdf',
                                            ),
                                            if (_error != null)
                                              Positioned(
                                                left: 12,
                                                right: 12,
                                                top: 12,
                                                child: Material(
                                                  color: Colors.amber.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  elevation: 2,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(12),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.info_outline,
                                                          size: 18,
                                                          color: Colors.amber,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            _error!,
                                                            style: AppTypography
                                                                .bodySmall
                                                                .copyWith(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: _submitting
                                                              ? null
                                                              : _init,
                                                          child: const Text(
                                                            'Tải lại',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        )
                                      : Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(24),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.picture_as_pdf_outlined,
                                                  size: 44,
                                                  color: AppColors.textTertiary,
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  _error ??
                                                      'Không tải được tài liệu PDF.',
                                                  textAlign: TextAlign.center,
                                                  style: AppTypography.bodySmall
                                                      .copyWith(
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                TextButton.icon(
                                                  onPressed: _submitting
                                                      ? null
                                                      : _init,
                                                  icon: const Icon(
                                                    Icons.refresh_rounded,
                                                    size: 18,
                                                  ),
                                                  label: const Text('Thử lại'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Signature Card
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderLight),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.draw_rounded,
                                          size: 20,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Chữ ký chủ xe (Bên A)',
                                          style: AppTypography.labelLarge
                                              .copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TapScale(
                                      onTap: _submitting
                                          ? null
                                          : _signatureController.clear,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfacePrimary,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppColors.borderLight,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.refresh_rounded,
                                              size: 15,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Ký lại',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Ký vào ô bên dưới để xác nhận duyệt hợp đồng và đồng ý bàn giao xe.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.borderLight,
                                      width: 1.5,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 20,
                                        right: 20,
                                        bottom: 36,
                                        child: Container(
                                          height: 1,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      Positioned(
                                        right: 16,
                                        bottom: 12,
                                        child: Text(
                                          'Ký tại đây',
                                          style: AppTypography.caption.copyWith(
                                            color: Colors.grey.shade400,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                      Signature(
                                        controller: _signatureController,
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // Sticky Bottom Dock
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.surfacePrimary,
                border: const Border(
                  top: BorderSide(color: AppColors.borderLight),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: AppButton(
                      text: 'Hủy',
                      variant: AppButtonVariant.outline,
                      height: 48,
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: 'Xác nhận & Duyệt đơn',
                      variant: AppButtonVariant.primary,
                      height: 48,
                      icon: Icons.verified_rounded,
                      isLoading: _submitting,
                      onPressed: _approve,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
