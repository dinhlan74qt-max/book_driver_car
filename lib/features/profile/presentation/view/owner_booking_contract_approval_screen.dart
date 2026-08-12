import 'dart:typed_data';

import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/auth/domain/entities/user_entity.dart';
import 'package:book_drive_car/features/profile/domain/entities/owner_booking_entity.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/owner_booking_cubit.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
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
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  TapScale(
                    onTap: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 26,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                color: Colors.white,
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
                                                color: Colors.amber.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.info_outline,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          _error!,
                                                          style:
                                                              const TextStyle(
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
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                _error ??
                                                    'Không tải được tài liệu PDF.',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              TextButton(
                                                onPressed: _submitting
                                                    ? null
                                                    : _init,
                                                child: const Text('Tải lại'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Signature(
                                      controller: _signatureController,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            'Ký xác nhận của chủ xe (Bên A).',
                                            style: TextStyle(fontSize: 11.5),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: _submitting
                                              ? null
                                              : _signatureController.clear,
                                          child: const Text('Xóa chữ ký'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Ký xong rồi bấm "Duyệt đơn" để gửi trạng thái xác nhận kèm file PDF lên server.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withValues(alpha: 0.65),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black26),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _approve,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.black26,
                        disabledForegroundColor: Colors.white70,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Duyệt đơn',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
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
