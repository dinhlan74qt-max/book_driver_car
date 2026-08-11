import 'dart:typed_data';

import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/features/home/data/datasources/booking_remote_data_source.dart';
import 'package:book_drive_car/features/home/domain/entities/booking_request_entity.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/domain/entities/verified_user_entity.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:signature/signature.dart';

class BookingContractScreen extends StatefulWidget {
  final CarEntity car;
  final BookingRequestEntity request;
  final VerifiedUserEntity renter;

  const BookingContractScreen({
    super.key,
    required this.car,
    required this.request,
    required this.renter,
  });

  @override
  State<BookingContractScreen> createState() => _BookingContractScreenState();
}

class _BookingContractScreenState extends State<BookingContractScreen> {
  late final SignatureController _renterSignatureController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _renterSignatureController = SignatureController(
      penStrokeWidth: 3.0,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _renterSignatureController.dispose();
    super.dispose();
  }

  String _formatCurrency(num value) {
    return NumberFormat.decimalPattern('vi_VN').format(value);
  }

  String _todayText() {
    return DateFormat('dd/MM/yyyy', 'vi_VN').format(DateTime.now());
  }

  String _formatDateTime(DateTime value) {
    return DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(value);
  }

  String _vehicleLocation() {
    return widget.car.location.trim().isNotEmpty
        ? widget.car.location
        : 'Không có';
  }

  Future<pw.ThemeData> _loadPdfTheme() async {
    final regularFont = pw.Font.ttf(
      (await rootBundle.load('assets/fonts/arialuni.ttf')).buffer.asByteData(),
    );
    final boldFont = pw.Font.ttf(
      (await rootBundle.load('assets/fonts/arialbd.ttf')).buffer.asByteData(),
    );

    return pw.ThemeData.withFont(base: regularFont, bold: boldFont);
  }

  Future<Uint8List> _buildSignedPdf(Uint8List renterSignatureBytes) async {
    final document = pw.Document(theme: await _loadPdfTheme());
    final renterSignatureImage = pw.MemoryImage(renterSignatureBytes);
    final startText = _formatDateTime(widget.request.startDate);
    final endText = _formatDateTime(widget.request.endDate);

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: pdf.PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(28, 34, 28, 28),
        ),
        build: (pw.Context context) => <pw.Widget>[
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM',
                  style: pw.TextStyle(
                    fontSize: 12.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Độc lập - Tự do - Hạnh phúc',
                  style: pw.TextStyle(
                    fontSize: 12.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 14),
                pw.Text(
                  'HỢP ĐỒNG CHO THUÊ XE',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text('Ngày ký: ${_todayText()}'),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Hôm nay, ngày ${_todayText()}, thông qua nền tảng BOOK DRIVE CAR, các bên thống nhất ký kết hợp đồng cho thuê xe với các thông tin sau:',
            style: const pw.TextStyle(fontSize: 11.3, height: 1.45),
          ),
          pw.SizedBox(height: 12),
          _pdfHeading('BÊN A - CHỦ XE / BÊN CHO THUÊ'),
          _pdfLine('Họ và tên', 'Chủ xe sẽ xác nhận sau'),
          _pdfLine('Số điện thoại', 'Chủ xe sẽ xác nhận sau'),
          _pdfLine('Email', 'Chủ xe sẽ xác nhận sau'),
          _pdfLine('Địa chỉ', 'Chủ xe sẽ xác nhận sau'),
          _pdfLine('Mã người dùng', 'Chủ xe sẽ xác nhận sau'),
          pw.SizedBox(height: 10),
          _pdfHeading('BÊN B - NGƯỜI THUÊ'),
          _pdfLine('Họ và tên', widget.renter.fullname),
          _pdfLine('Số điện thoại', widget.renter.phone),
          _pdfLine('Email', widget.renter.email),
          _pdfLine(
            'Địa chỉ',
            widget.renter.addressText.isNotEmpty
                ? widget.renter.addressText
                : 'Không có',
          ),
          _pdfLine(
            'CCCD',
            widget.renter.cccd?.trim().isNotEmpty == true
                ? widget.renter.cccd!
                : 'Không có',
          ),
          pw.SizedBox(height: 10),
          _pdfHeading('THÔNG TIN PHƯƠNG TIỆN'),
          _pdfTable([
            ['Hãng xe', widget.car.brand],
            ['Dòng xe', widget.car.model ?? widget.car.name],
            ['Biển số', widget.car.licensePlate ?? 'Không có'],
            ['Màu xe', widget.car.color ?? 'Không có'],
            ['Năm sản xuất', widget.car.year?.toString() ?? 'Không có'],
            ['Số chỗ', widget.car.seats.toString()],
            ['Loại nhiên liệu', widget.car.fuelType ?? 'Không có'],
            ['Hộp số', widget.car.transmission ?? 'Không có'],
            ['Giá thuê/ngày', '${_formatCurrency(widget.car.pricePerDay)} VNĐ'],
            ['Địa điểm nhận xe', _vehicleLocation()],
          ]),
          pw.SizedBox(height: 10),
          _pdfHeading('THÔNG TIN ĐẶT XE'),
          _pdfLine('Thời gian nhận xe', startText),
          _pdfLine('Thời gian trả xe', endText),
          _pdfLine(
            'Tổng số ngày thuê',
            '${widget.request.endDate.difference(widget.request.startDate).inDays} ngày',
          ),
          _pdfLine(
            'Tổng tiền dự kiến',
            '${_formatCurrency(widget.car.pricePerDay * widget.request.endDate.difference(widget.request.startDate).inDays)} VNĐ',
          ),
          pw.SizedBox(height: 10),
          _pdfHeading('ĐIỀU KHOẢN CHÍNH'),
          _pdfBullets(const [
            'Bên B xác nhận đã đọc, hiểu và đồng ý với thông tin đặt xe trên hệ thống.',
            'Bên B sử dụng xe đúng mục đích, đúng thời gian và đúng địa điểm đã thỏa thuận.',
            'Bên A chịu trách nhiệm bàn giao xe đúng mô tả và đúng thời gian xác nhận.',
            'Book Drive Car là nền tảng trung gian hỗ trợ giao dịch và lưu trữ hợp đồng.',
            'Hợp đồng này chỉ có hiệu lực khi hệ thống ghi nhận đủ thông tin cần thiết.',
          ]),
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.only(right: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _pdfHeading('BÊN A - CHỦ XE'),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Họ và tên: .....................................',
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text('Chữ ký:'),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        height: 90,
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: pdf.PdfColors.black,
                              width: 1,
                            ),
                          ),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'Chủ xe ký sau khi xác nhận đơn',
                            style: pw.TextStyle(
                              fontSize: 10.2,
                              fontStyle: pw.FontStyle.italic,
                              color: pdf.PdfColors.grey700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _pdfHeading('BÊN B - NGƯỜI THUÊ'),
                      pw.SizedBox(height: 8),
                      pw.Text('Họ và tên: ${widget.renter.fullname}'),
                      pw.SizedBox(height: 8),
                      pw.Text('Chữ ký:'),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        height: 90,
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: pdf.PdfColors.black,
                              width: 1,
                            ),
                          ),
                        ),
                        child: pw.Center(
                          child: pw.Image(
                            renterSignatureImage,
                            fit: pw.BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Lưu ý: chữ ký của Bên A sẽ được bổ sung khi chủ xe xác nhận đơn hàng trên hệ thống.',
            style: pw.TextStyle(fontSize: 10.4, fontStyle: pw.FontStyle.italic),
          ),
        ],
      ),
    );

    return document.save();
  }

  Widget _uiLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12.0,
          height: 1.4,
          color: Colors.black,
        ),
      ),
    );
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

  pw.Widget _pdfBullets(List<String> items) {
    return pw.Column(
      children: items
          .map(
            (item) => pw.Padding(
              padding: const pw.EdgeInsets.only(top: 3),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('•  ', style: const pw.TextStyle(fontSize: 11.2)),
                  pw.Expanded(
                    child: pw.Text(
                      item,
                      style: const pw.TextStyle(fontSize: 11.2, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _pdfTable(List<List<String>> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: pdf.PdfColors.black, width: 0.6),
      columnWidths: const {
        0: pw.FlexColumnWidth(2.5),
        1: pw.FlexColumnWidth(4.5),
      },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: rows
          .map(
            (row) => pw.TableRow(
              children: [_pdfCell(row[0], bold: true), _pdfCell(row[1])],
            ),
          )
          .toList(),
    );
  }

  pw.Widget _pdfCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10.6,
          height: 1.3,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _submitContract() async {
    if (_isSubmitting) return;
    if (_renterSignatureController.isEmpty) {
      AppToast.show(
        context,
        message: 'Vui lòng ký tên trước khi xác nhận hợp đồng',
        type: AppToastType.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final signatureBytes = await _renterSignatureController.toPngBytes();
      if (signatureBytes == null || signatureBytes.isEmpty) {
        throw Exception('Không xuất được chữ ký');
      }

      final pdfBytes = await _buildSignedPdf(signatureBytes);
      final fileName =
          'contract_signed_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await sl<BookingRemoteDataSource>().uploadContractPdf(
        pdfBytes: pdfBytes,
        fileName: fileName,
      );

      final booking = await sl<BookingRemoteDataSource>().createBooking(
        widget.request,
      );

      if (!mounted) return;
      Navigator.of(context).pop(booking);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
                    onTap: _isSubmitting
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(30, 28, 30, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Column(
                              children: [
                                Text(
                                  'HỢP ĐỒNG CHO THUÊ XE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    height: 1.35,
                                    letterSpacing: 0.2,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Ngày ký: ${_todayText()}',
                            style: const TextStyle(
                              fontSize: 12.4,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _uiLine('Người thuê', widget.renter.fullname),
                          _uiLine('Xe', widget.car.name),
                          _uiLine(
                            'Biển số',
                            widget.car.licensePlate ?? 'Không có',
                          ),
                          _uiLine(
                            'Thời gian thuê',
                            '${_formatDateTime(widget.request.startDate)} - ${_formatDateTime(widget.request.endDate)}',
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 260,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Signature(
                                    controller: _renterSignatureController,
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
                                          'Ký của người thuê xe.',
                                          style: TextStyle(fontSize: 11.5),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _isSubmitting
                                            ? null
                                            : _renterSignatureController.clear,
                                        child: const Text('Xóa chữ ký'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Bên A sẽ ký sau khi xác nhận đơn hàng trên hệ thống.',
                            style: TextStyle(
                              fontSize: 12.2,
                              height: 1.45,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'BÊN A - CHỦ XE',
                                      style: TextStyle(
                                        fontSize: 12.8,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Họ và tên: .....................................',
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 80,
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'BÊN B - NGƯỜI THUÊ',
                                      style: TextStyle(
                                        fontSize: 12.8,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Họ và tên: ${widget.renter.fullname}',
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 80,
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Chữ ký người thuê được chèn vào PDF khi xác nhận',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 10.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Ký xong rồi bấm “Ký hợp đồng” để hệ thống tạo PDF, gửi lên server và tạo đơn đặt xe.',
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
                      onPressed: () => Navigator.of(context).pop(),
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
                      onPressed: _isSubmitting ? null : _submitContract,
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
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Ký hợp đồng',
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
