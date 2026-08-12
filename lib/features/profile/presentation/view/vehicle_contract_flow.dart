import 'dart:typed_data';

import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/auth/domain/entities/user_entity.dart';
import 'package:book_drive_car/features/profile/domain/entities/add_vehicle_request_entity.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:signature/signature.dart';

class VehicleContractScreen extends StatefulWidget {
  final AddVehicleRequestEntity request;

  const VehicleContractScreen({super.key, required this.request});

  @override
  State<VehicleContractScreen> createState() => _VehicleContractScreenState();
}

class _VehicleContractScreenState extends State<VehicleContractScreen> {
  UserEntity? _owner;
  bool _isLoading = true;
  final List<bool> _confirmedItems = List<bool>.filled(8, false);

  bool get _allConfirmed => _confirmedItems.every((item) => item);

  @override
  void initState() {
    super.initState();
    _loadOwner();
  }

  Future<void> _loadOwner() async {
    final owner = await sl<UserLocalStorage>().getUser();
    if (!mounted) return;
    setState(() {
      _owner = owner;
      _isLoading = false;
    });
  }

  String _formatCurrency(num value) {
    return NumberFormat.decimalPattern('vi_VN').format(value);
  }

  String get _todayText =>
      DateFormat('dd/MM/yyyy', 'vi_VN').format(DateTime.now());

  String _vehicleLocation() {
    return [
      widget.request.address.addressDetail,
      widget.request.address.ward,
      widget.request.address.district,
      widget.request.address.city,
    ].where((value) => value.trim().isNotEmpty).join(', ');
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

  Future<Uint8List> _buildSignedPdf(Uint8List signatureBytes) async {
    final document = pw.Document(theme: await _loadPdfTheme());
    final signatureImage = pw.MemoryImage(signatureBytes);
    final location = _vehicleLocation().isEmpty
        ? 'Không có'
        : _vehicleLocation();

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: pdf.PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
        ),
        build: (context) => [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'THỎA THUẬN ĐĂNG KÝ XE CHO THUÊ TRÊN NỀN TẢNG',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text('Ngày lập: $_todayText'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          _pdfHeading('I. THÔNG TIN CÁC BÊN'),
          _pdfLine('Họ và tên', _ownerName()),
          _pdfLine('Số điện thoại', _ownerPhone()),
          _pdfLine('Email', _ownerEmail()),
          _pdfLine('Địa chỉ', _ownerAddress()),
          _pdfLine('Mã người dùng trên nền tảng', _ownerIdText()),
          pw.SizedBox(height: 12),
          _pdfHeading('II. THÔNG TIN XE ĐĂNG KÝ'),
          _pdfTable([
            ['Hãng xe', widget.request.brand],
            ['Dòng xe', widget.request.model],
            ['Phiên bản', widget.request.vehicleName],
            ['Năm sản xuất', widget.request.year.toString()],
            ['Biển số xe', widget.request.licensePlate],
            ['Màu xe', widget.request.color],
            ['Số chỗ', widget.request.seatCount.toString()],
            ['Loại nhiên liệu', widget.request.fuelType],
            ['Hộp số', widget.request.transmission],
            [
              'Giá thuê/ngày',
              '${_formatCurrency(widget.request.pricePerDay)} VNĐ',
            ],
            ['Địa điểm nhận xe', location],
          ]),
          pw.SizedBox(height: 12),
          _pdfHeading('III. MỤC ĐÍCH ĐĂNG KÝ XE'),
          _pdfBullets(const [
            'Cung cấp thông tin phương tiện để người dùng tìm kiếm và đặt thuê.',
            'Cho phép Nền tảng hiển thị thông tin xe, hình ảnh, giá thuê và địa điểm nhận xe.',
            'Cho phép người dùng gửi yêu cầu đặt thuê xe thông qua hệ thống.',
            'Việc đăng ký xe không đồng nghĩa với việc xe lập tức phát sinh hợp đồng thuê.',
          ]),
          pw.SizedBox(height: 8),
          _pdfHeading('IV. CAM KẾT VỀ QUYỀN ĐỐI VỚI XE'),
          _pdfBullets(const [
            'Chủ xe xác nhận là chủ sở hữu hợp pháp của phương tiện hoặc có quyền hợp pháp để đưa phương tiện vào hoạt động cho thuê.',
            'Chủ xe chịu trách nhiệm về tính chính xác và hợp pháp của các thông tin, giấy tờ đã cung cấp.',
            'Chủ xe thông báo cho Nền tảng nếu quyền sở hữu hoặc quyền sử dụng phương tiện có thay đổi.',
          ]),
          pw.SizedBox(height: 8),
          _pdfHeading('V. CAM KẾT VỀ GIẤY TỜ VÀ TÌNH TRẠNG PHƯƠNG TIỆN'),
          _pdfBullets(const [
            'Xe đăng ký có các giấy tờ cần thiết theo quy định áp dụng.',
            'Thông tin đăng ký phương tiện phù hợp với thông tin được cung cấp trên Nền tảng.',
            'Không cố ý che giấu các thông tin quan trọng liên quan đến tình trạng phương tiện.',
            'Không đăng tải thông tin sai lệch về tình trạng, chất lượng hoặc đặc điểm của xe.',
          ]),
          pw.SizedBox(height: 8),
          _pdfHeading('VI. GIÁ THUÊ XE'),
          _pdfText(
            'Mức giá hiện tại là ${_formatCurrency(widget.request.pricePerDay)} VNĐ/ngày.',
          ),
          pw.SizedBox(height: 8),
          _pdfHeading('VII. PHÍ DỊCH VỤ NỀN TẢNG'),
          _pdfText(
            'Đối với mỗi giao dịch cho thuê xe thành công thông qua Nền tảng, Nền tảng áp dụng phí dịch vụ bằng 5% giá trị tiền thuê xe.',
          ),
          pw.SizedBox(height: 8),
          _pdfHeading('VIII. TRÁCH NHIỆM CỦA CHỦ XE'),
          _pdfBullets(const [
            'Cung cấp thông tin xe chính xác.',
            'Cung cấp giấy tờ theo yêu cầu của Nền tảng.',
            'Đảm bảo xe được mô tả đúng với thực tế.',
            'Cập nhật thông tin khi xe có thay đổi.',
            'Bàn giao xe đúng thời gian và địa điểm đã thỏa thuận với Người thuê.',
          ]),
          pw.SizedBox(height: 8),
          _pdfHeading('IX. QUYỀN CỦA CHỦ XE'),
          _pdfBullets(const [
            'Đăng tải phương tiện trên Nền tảng sau khi đáp ứng yêu cầu của hệ thống.',
            'Thiết lập và cập nhật giá thuê theo chức năng được cung cấp.',
            'Theo dõi các yêu cầu đặt xe và doanh thu từ các giao dịch.',
            'Nhận khoản tiền thuê còn lại sau khi Nền tảng khấu trừ phí dịch vụ.',
          ]),
          pw.SizedBox(height: 8),
          _pdfHeading('X. QUYỀN CỦA NỀN TẢNG'),
          _pdfBullets(const [
            'Kiểm tra thông tin xe do Chủ xe cung cấp.',
            'Yêu cầu Chủ xe bổ sung hoặc cập nhật giấy tờ.',
            'Từ chối đăng tải phương tiện nếu không đáp ứng yêu cầu hệ thống.',
            'Tạm ẩn hoặc tạm ngừng hiển thị xe khi phát hiện thông tin không chính xác.',
            'Khấu trừ phí dịch vụ 5% theo chính sách áp dụng.',
          ]),
          pw.SizedBox(height: 8),
          _pdfHeading('XI. QUẢN LÝ VÀ HIỂN THỊ XE'),
          _pdfText(
            'Sau khi thông tin xe được kiểm tra và được Nền tảng chấp thuận, xe có thể được chuyển sang trạng thái AVAILABLE - Có thể cho thuê.',
          ),
          pw.SizedBox(height: 8),
          _pdfHeading('XII. GIAO DỊCH THUÊ XE'),
          _pdfBullets(const [
            'Mỗi giao dịch thuê xe được xác định bằng một mã đặt xe riêng.',
            'Thông tin giao dịch có thể bao gồm người thuê, chủ xe, xe được thuê, thời gian thuê, địa điểm, giá thuê, tổng tiền, phí dịch vụ và trạng thái giao dịch.',
          ]),
          pw.SizedBox(height: 8),
          _pdfHeading('XIII. HỦY HOẶC TẠM NGƯNG ĐĂNG KÝ XE'),
          _pdfBullets(const [
            'Chủ xe có thể yêu cầu tạm ngừng hoặc ngừng cho thuê phương tiện.',
            'Đối với các giao dịch đã được xác nhận, việc hủy giao dịch sẽ được thực hiện theo chính sách của Nền tảng.',
            'Nếu xe không còn đủ điều kiện cho thuê, Chủ xe có trách nhiệm thông báo cho Nền tảng trong thời gian sớm nhất.',
          ]),
          pw.SizedBox(height: 8),
          _pdfHeading('XIV. XỬ LÝ SỰ CỐ VÀ TRANH CHẤP'),
          _pdfBullets(const [
            'Chủ xe và Người thuê ưu tiên trao đổi thông qua hệ thống của Nền tảng.',
            'Các bên cung cấp thông tin, hình ảnh hoặc tài liệu liên quan khi cần thiết.',
            'Nền tảng hỗ trợ ghi nhận và cung cấp thông tin giao dịch trong phạm vi chức năng của mình.',
          ]),
          pw.SizedBox(height: 8),
          _pdfHeading('XV. BẢO MẬT VÀ THÔNG TIN CÁ NHÂN'),
          _pdfText(
            'Chủ xe đồng ý để Nền tảng thu thập và xử lý các thông tin cần thiết nhằm tạo tài khoản, xác minh thông tin, đăng ký phương tiện, quản lý giao dịch, hỗ trợ khách hàng và giải quyết khiếu nại.',
          ),
          pw.SizedBox(height: 8),
          _pdfHeading('XVI. TÍNH TRUNG THỰC CỦA THÔNG TIN'),
          _pdfBullets(const [
            'Chủ xe chịu trách nhiệm về tính chính xác của thông tin đã cung cấp.',
            'Trường hợp phát hiện thông tin sai lệch, Chủ xe có trách nhiệm chủ động cập nhật hoặc thông báo cho Nền tảng.',
            'Nền tảng có quyền tạm ngừng hoặc chấm dứt việc hiển thị phương tiện nếu phát hiện thông tin giả mạo hoặc cố ý che giấu thông tin quan trọng.',
          ]),
          pw.SizedBox(height: 8),
          _pdfHeading('XVII. HIỆU LỰC CỦA THỎA THUẬN'),
          _pdfText(
            'Thỏa thuận này có hiệu lực kể từ thời điểm Chủ xe hoàn tất việc xác nhận đăng ký xe trên Nền tảng và hệ thống ghi nhận việc chấp thuận.',
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'CHỦ XE',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Họ và tên: ${_ownerName()}'),
          pw.SizedBox(height: 8),
          pw.Text('Chữ ký:'),
          pw.SizedBox(height: 8),
          pw.Container(
            height: 95,
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: pdf.PdfColors.black, width: 1),
              ),
            ),
            child: pw.Center(
              child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
            ),
          ),
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _pdfHeading(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: 13.2, fontWeight: pw.FontWeight.bold),
    );
  }

  pw.Widget _pdfText(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 11.2, height: 1.45),
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

  pw.Widget _pdfLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 3),
      child: pw.Text(
        '$label: $value',
        style: const pw.TextStyle(fontSize: 11.2),
      ),
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

  String _ownerName() {
    final value = _owner?.fullname.trim() ?? '';
    return value.isEmpty ? 'Chủ xe' : value;
  }

  String _ownerPhone() {
    final value = _owner?.phone.trim() ?? '';
    return value.isEmpty ? 'Không có' : value;
  }

  String _ownerEmail() {
    final value = _owner?.email.trim() ?? '';
    return value.isEmpty ? 'Không có' : value;
  }

  String _ownerAddress() {
    final value = _owner?.address?.trim() ?? '';
    return value.isEmpty ? 'Không có' : value;
  }

  String _ownerIdText() {
    return _owner?.id.toString() ?? 'Không có';
  }

  List<_ContractSection> _sections() {
    final location = _vehicleLocation().isEmpty
        ? 'Không có'
        : _vehicleLocation();

    return [
      _ContractSection(
        title: 'I. THÔNG TIN CÁC BÊN',
        paragraphs: const [
          '1. Chủ xe là bên đăng ký phương tiện cho thuê trên Nền tảng.',
          '2. Nền tảng Book Drive Car là bên trung gian cung cấp dịch vụ kết nối giữa chủ xe và người có nhu cầu thuê xe.',
        ],
        lines: [
          'Họ và tên: ${_ownerName()}',
          'Số điện thoại: ${_ownerPhone()}',
          'Email: ${_ownerEmail()}',
        ],
      ),
      _ContractSection(
        title: 'II. THÔNG TIN XE ĐĂNG KÝ',
        tableRows: [
          ['Hãng xe', widget.request.brand],
          ['Dòng xe', widget.request.model],
          ['Phiên bản', widget.request.vehicleName],
          ['Năm sản xuất', widget.request.year.toString()],
          ['Biển số xe', widget.request.licensePlate],
          ['Màu xe', widget.request.color],
          ['Số chỗ', widget.request.seatCount.toString()],
          ['Loại nhiên liệu', widget.request.fuelType],
          ['Hộp số', widget.request.transmission],
          [
            'Giá thuê/ngày',
            '${_formatCurrency(widget.request.pricePerDay)} VNĐ',
          ],
          ['Địa điểm nhận xe', location],
        ],
        lines: const ['Mã xe trên Nền tảng sẽ được hệ thống sinh sau khi lưu.'],
      ),
      _ContractSection(
        title: 'III. MỤC ĐÍCH ĐĂNG KÝ XE',
        bullets: const [
          'Cung cấp thông tin phương tiện để người dùng tìm kiếm và đặt thuê.',
          'Cho phép Nền tảng hiển thị thông tin xe, hình ảnh, giá thuê và địa điểm nhận xe.',
          'Cho phép người dùng gửi yêu cầu đặt thuê xe thông qua hệ thống.',
          'Việc đăng ký xe không đồng nghĩa với việc xe lập tức phát sinh hợp đồng thuê.',
        ],
      ),
      _ContractSection(
        title: 'IV. CAM KẾT VỀ QUYỀN ĐỐI VỚI XE',
        bullets: const [
          'Chủ xe xác nhận là chủ sở hữu hợp pháp của phương tiện hoặc có quyền hợp pháp để đưa phương tiện vào hoạt động cho thuê.',
          'Chủ xe chịu trách nhiệm về tính chính xác và hợp pháp của các thông tin, giấy tờ đã cung cấp.',
          'Chủ xe thông báo cho Nền tảng nếu quyền sở hữu hoặc quyền sử dụng phương tiện có thay đổi.',
        ],
      ),
      _ContractSection(
        title: 'V. CAM KẾT VỀ GIẤY TỜ VÀ TÌNH TRẠNG PHƯƠNG TIỆN',
        bullets: const [
          'Xe đăng ký có các giấy tờ cần thiết theo quy định áp dụng.',
          'Thông tin đăng ký phương tiện phù hợp với thông tin được cung cấp trên Nền tảng.',
          'Không cố ý che giấu các thông tin quan trọng liên quan đến tình trạng phương tiện.',
          'Không đăng tải thông tin sai lệch về tình trạng, chất lượng hoặc đặc điểm của xe.',
        ],
      ),
      _ContractSection(
        title: 'VI. GIÁ THUÊ XE',
        paragraphs: [
          'Chủ xe tự thiết lập giá thuê cho phương tiện trên Nền tảng.',
          'Mức giá hiện tại là ${_formatCurrency(widget.request.pricePerDay)} VNĐ/ngày.',
        ],
      ),
      _ContractSection(
        title: 'VII. PHÍ DỊCH VỤ NỀN TẢNG',
        paragraphs: const [
          'Đối với mỗi giao dịch cho thuê xe thành công thông qua Nền tảng, Nền tảng áp dụng phí dịch vụ bằng 5% giá trị tiền thuê xe.',
        ],
      ),
      _ContractSection(
        title: 'VIII. TRÁCH NHIỆM CỦA CHỦ XE',
        bullets: const [
          'Cung cấp thông tin xe chính xác.',
          'Cung cấp giấy tờ theo yêu cầu của Nền tảng.',
          'Đảm bảo xe được mô tả đúng với thực tế.',
          'Cập nhật thông tin khi xe có thay đổi.',
          'Bàn giao xe đúng thời gian và địa điểm đã thỏa thuận với Người thuê.',
        ],
      ),
      _ContractSection(
        title: 'IX. QUYỀN CỦA CHỦ XE',
        bullets: const [
          'Đăng tải phương tiện trên Nền tảng sau khi đáp ứng yêu cầu của hệ thống.',
          'Thiết lập và cập nhật giá thuê theo chức năng được cung cấp.',
          'Theo dõi các yêu cầu đặt xe và doanh thu từ các giao dịch.',
          'Nhận khoản tiền thuê còn lại sau khi Nền tảng khấu trừ phí dịch vụ.',
        ],
      ),
      _ContractSection(
        title: 'X. QUYỀN CỦA NỀN TẢNG',
        bullets: const [
          'Kiểm tra thông tin xe do Chủ xe cung cấp.',
          'Yêu cầu Chủ xe bổ sung hoặc cập nhật giấy tờ.',
          'Từ chối đăng tải phương tiện nếu không đáp ứng yêu cầu hệ thống.',
          'Tạm ẩn hoặc tạm ngừng hiển thị xe khi phát hiện thông tin không chính xác.',
          'Khấu trừ phí dịch vụ 5% theo chính sách áp dụng.',
        ],
      ),
      _ContractSection(
        title: 'XI. QUẢN LÝ VÀ HIỂN THỊ XE',
        paragraphs: const [
          'Sau khi thông tin xe được kiểm tra và được Nền tảng chấp thuận, xe có thể được chuyển sang trạng thái AVAILABLE - Có thể cho thuê.',
        ],
      ),
      _ContractSection(
        title: 'XII. GIAO DỊCH THUÊ XE',
        paragraphs: const [
          'Mỗi giao dịch thuê xe được xác định bằng một mã đặt xe riêng.',
          'Thông tin giao dịch có thể bao gồm người thuê, chủ xe, xe được thuê, thời gian thuê, địa điểm, giá thuê, tổng tiền, phí dịch vụ và trạng thái giao dịch.',
        ],
      ),
      _ContractSection(
        title: 'XIII. HỦY HOẶC TẠM NGƯNG ĐĂNG KÝ XE',
        bullets: const [
          'Chủ xe có thể yêu cầu tạm ngừng hoặc ngừng cho thuê phương tiện.',
          'Đối với các giao dịch đã được xác nhận, việc hủy giao dịch sẽ được thực hiện theo chính sách của Nền tảng.',
          'Nếu xe không còn đủ điều kiện cho thuê, Chủ xe có trách nhiệm thông báo cho Nền tảng trong thời gian sớm nhất.',
        ],
      ),
      _ContractSection(
        title: 'XIV. XỬ LÝ SỰ CỐ VÀ TRANH CHẤP',
        bullets: const [
          'Chủ xe và Người thuê ưu tiên trao đổi thông qua hệ thống của Nền tảng.',
          'Các bên cung cấp thông tin, hình ảnh hoặc tài liệu liên quan khi cần thiết.',
          'Nền tảng hỗ trợ ghi nhận và cung cấp thông tin giao dịch trong phạm vi chức năng của mình.',
        ],
      ),
      _ContractSection(
        title: 'XV. BẢO MẬT VÀ THÔNG TIN CÁ NHÂN',
        paragraphs: const [
          'Chủ xe đồng ý để Nền tảng thu thập và xử lý các thông tin cần thiết nhằm tạo tài khoản, xác minh thông tin, đăng ký phương tiện, quản lý giao dịch, hỗ trợ khách hàng và giải quyết khiếu nại.',
        ],
      ),
      _ContractSection(
        title: 'XVI. TÍNH TRUNG THỰC CỦA THÔNG TIN',
        bullets: const [
          'Chủ xe chịu trách nhiệm về tính chính xác của thông tin đã cung cấp.',
          'Trường hợp phát hiện thông tin sai lệch, Chủ xe có trách nhiệm chủ động cập nhật hoặc thông báo cho Nền tảng.',
          'Nền tảng có quyền tạm ngừng hoặc chấm dứt việc hiển thị phương tiện nếu phát hiện thông tin giả mạo hoặc cố ý che giấu thông tin quan trọng.',
        ],
      ),
      _ContractSection(
        title: 'XVII. HIỆU LỰC CỦA THỎA THUẬN',
        paragraphs: const [
          'Thỏa thuận này có hiệu lực kể từ thời điểm Chủ xe hoàn tất việc xác nhận đăng ký xe trên Nền tảng và hệ thống ghi nhận việc chấp thuận.',
        ],
      ),
      _ContractSection(
        title: 'XVIII. XÁC NHẬN CỦA CHỦ XE',
        paragraphs: const [
          'Bằng việc xác nhận dưới đây, Chủ xe xác nhận rằng:',
        ],
      ),
    ];
  }

  Future<void> _goToSignatureScreen() async {
    if (_isLoading || !_allConfirmed) return;

    final contractPdfBytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (_) => VehicleSignatureScreen(
          request: widget.request,
          ownerName: _ownerName(),
          ownerPhone: _ownerPhone(),
          ownerEmail: _ownerEmail(),
          ownerAddress: _ownerAddress(),
          userId: _ownerIdText(),
          registrationDateText: _todayText,
        ),
      ),
    );

    if (!mounted || contractPdfBytes == null || contractPdfBytes.isEmpty)
      return;
    Navigator.of(context).pop(contractPdfBytes);
  }

  @override
  Widget build(BuildContext context) {
    final sections = _sections();

    return Scaffold(
      backgroundColor: const Color(0xFFF0ECE3),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Row(
                      children: [
                        TapScale(
                          onTap: () => Navigator.of(context).pop(),
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
                          constraints: const BoxConstraints(maxWidth: 850),
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.fromLTRB(44, 38, 44, 44),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Column(
                                    children: [
                                      const Text(
                                        'THỎA THUẬN ĐĂNG KÝ XE CHO THUÊ TRÊN NỀN TẢNG',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w800,
                                          height: 1.35,
                                          letterSpacing: 0.2,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Ngày lập: $_todayText',
                                        style: const TextStyle(fontSize: 12.5),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                                for (final section in sections) ...[
                                  _PaperSectionWidget(section: section),
                                  const SizedBox(height: 18),
                                ],
                                _ConfirmationChecklist(
                                  items: const [
                                    'Tôi đã kiểm tra và xác nhận thông tin phương tiện là chính xác.',

                                    'Tôi xác nhận mình có quyền hợp pháp để đăng ký phương tiện cho thuê.',

                                    'Tôi xác nhận các giấy tờ cung cấp cho Nền tảng là chính xác.',

                                    'Tôi đã đọc và hiểu các điều khoản của Thỏa thuận đăng ký xe.',

                                    'Tôi đồng ý với mức phí dịch vụ Nền tảng 5% trên giá trị tiền thuê xe theo chính sách áp dụng.',

                                    'Tôi hiểu rằng việc đăng ký xe không tự động tạo ra hợp đồng thuê xe với Người thuê.',

                                    'Tôi đồng ý để Nền tảng hiển thị thông tin và hình ảnh của phương tiện nhằm phục vụ hoạt động cho thuê.',

                                    'Tôi đồng ý cung cấp các thông tin cần thiết để Nền tảng quản lý phương tiện và giao dịch.',
                                  ],
                                  values: _confirmedItems,
                                  onChanged: (index, value) {
                                    setState(() {
                                      _confirmedItems[index] = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'CHỦ XE',
                                  style: TextStyle(
                                    fontSize: 12.8,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('Họ và tên: ${_ownerName()}'),
                                const SizedBox(height: 18),
                                const Text('Chữ ký:'),
                                const SizedBox(height: 10),
                                Container(
                                  height: 88,
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
                                const SizedBox(height: 22),
                                const Text(
                                  'NỀN TẢNG',
                                  style: TextStyle(
                                    fontSize: 12.8,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text('Book Drive Car'),
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
                      _allConfirmed
                          ? 'Hoàn thành!, bạn có thể ký hợp đồng.'
                          : 'Vui lòng chọn đủ xác nhận của chủ xe.',
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
                            onPressed: _allConfirmed
                                ? _goToSignatureScreen
                                : null,
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
                            child: const Text(
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

class VehicleSignatureScreen extends StatefulWidget {
  final AddVehicleRequestEntity request;
  final String ownerName;
  final String ownerPhone;
  final String ownerEmail;
  final String ownerAddress;
  final String userId;
  final String registrationDateText;

  const VehicleSignatureScreen({
    super.key,
    required this.request,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerEmail,
    required this.ownerAddress,
    required this.userId,
    required this.registrationDateText,
  });

  @override
  State<VehicleSignatureScreen> createState() => _VehicleSignatureScreenState();
}

class _VehicleSignatureScreenState extends State<VehicleSignatureScreen> {
  late final SignatureController _signatureController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3.2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  String _formatCurrency(num value) {
    return NumberFormat.decimalPattern('vi_VN').format(value);
  }

  String _vehicleLocation() {
    return [
      widget.request.address.addressDetail,
      widget.request.address.ward,
      widget.request.address.district,
      widget.request.address.city,
    ].where((value) => value.trim().isNotEmpty).join(', ');
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

  Future<Uint8List> _buildSignedPdf(Uint8List signatureBytes) async {
    final document = pw.Document(theme: await _loadPdfTheme());
    final signatureImage = pw.MemoryImage(signatureBytes);
    final location = _vehicleLocation().isEmpty
        ? 'Không có'
        : _vehicleLocation();

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: pdf.PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
        ),
        build: (context) => [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'THỎA THUẬN ĐĂNG KÝ XE CHO THUÊ TRÊN NỀN TẢNG',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text('Ngày lập: ${widget.registrationDateText}'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'I. THÔNG TIN CÁC BÊN',
            style: pw.TextStyle(fontSize: 13.2, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Họ và tên: ${widget.ownerName}',
            style: const pw.TextStyle(fontSize: 11.2),
          ),
          pw.Text(
            'Số điện thoại: ${widget.ownerPhone}',
            style: const pw.TextStyle(fontSize: 11.2),
          ),
          pw.Text(
            'Email: ${widget.ownerEmail}',
            style: const pw.TextStyle(fontSize: 11.2),
          ),
          pw.Text(
            'Địa chỉ: ${widget.ownerAddress}',
            style: const pw.TextStyle(fontSize: 11.2),
          ),
          pw.Text(
            'Mã người dùng trên nền tảng: ${widget.userId}',
            style: const pw.TextStyle(fontSize: 11.2),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'II. THÔNG TIN XE ĐĂNG KÝ',
            style: pw.TextStyle(fontSize: 13.2, fontWeight: pw.FontWeight.bold),
          ),
          _pdfTable([
            ['Hãng xe', widget.request.brand],
            ['Dòng xe', widget.request.model],
            ['Phiên bản', widget.request.vehicleName],
            ['Năm sản xuất', widget.request.year.toString()],
            ['Biển số xe', widget.request.licensePlate],
            ['Màu xe', widget.request.color],
            ['Số chỗ', widget.request.seatCount.toString()],
            ['Loại nhiên liệu', widget.request.fuelType],
            ['Hộp số', widget.request.transmission],
            [
              'Giá thuê/ngày',
              '${NumberFormat.decimalPattern('vi_VN').format(widget.request.pricePerDay)} VNĐ',
            ],
            ['Địa điểm nhận xe', location],
          ]),
          pw.SizedBox(height: 10),
          pw.Text(
            'III. MỤC ĐÍCH ĐĂNG KÝ XE',
            style: pw.TextStyle(fontSize: 13.2, fontWeight: pw.FontWeight.bold),
          ),
          _pdfBullets(const [
            'Cung cấp thông tin phương tiện để người dùng tìm kiếm và đặt thuê.',
            'Cho phép Nền tảng hiển thị thông tin xe, hình ảnh, giá thuê và địa điểm nhận xe.',
            'Cho phép người dùng gửi yêu cầu đặt thuê xe thông qua hệ thống.',
          ]),
          pw.SizedBox(height: 8),
          pw.Text(
            'IV. CAM KẾT VỀ QUYỀN ĐỐI VỚI XE',
            style: pw.TextStyle(fontSize: 13.2, fontWeight: pw.FontWeight.bold),
          ),
          _pdfBullets(const [
            'Chủ xe xác nhận có quyền hợp pháp đối với phương tiện.',
            'Chủ xe chịu trách nhiệm về tính chính xác của các thông tin đã cung cấp.',
          ]),
          pw.SizedBox(height: 8),
          pw.Text(
            'V. CAM KẾT VỀ GIẤY TỜ VÀ TÌNH TRẠNG PHƯƠNG TIỆN',
            style: pw.TextStyle(fontSize: 13.2, fontWeight: pw.FontWeight.bold),
          ),
          _pdfBullets(const [
            'Xe có các giấy tờ cần thiết theo quy định áp dụng.',
            'Không cố ý che giấu thông tin quan trọng về phương tiện.',
          ]),
          pw.SizedBox(height: 8),
          pw.Text(
            'VI. GIÁ THUÊ XE',
            style: pw.TextStyle(fontSize: 13.2, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Mức giá hiện tại là ${NumberFormat.decimalPattern('vi_VN').format(widget.request.pricePerDay)} VNĐ/ngày.',
            style: const pw.TextStyle(fontSize: 11.2),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'VII. PHÍ DỊCH VỤ NỀN TẢNG',
            style: pw.TextStyle(fontSize: 13.2, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Nền tảng áp dụng phí dịch vụ bằng 5% giá trị tiền thuê xe.',
            style: const pw.TextStyle(fontSize: 11.2),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'VIII. TRÁCH NHIỆM CỦA CHỦ XE',
            style: pw.TextStyle(fontSize: 13.2, fontWeight: pw.FontWeight.bold),
          ),
          _pdfBullets(const [
            'Cung cấp thông tin xe chính xác.',
            'Bàn giao xe đúng thời gian và địa điểm đã thỏa thuận.',
            'Cập nhật thông tin khi xe có thay đổi.',
          ]),
          pw.SizedBox(height: 18),
          pw.Text(
            'CHỦ XE',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Họ và tên: ${widget.ownerName}'),
          pw.SizedBox(height: 8),
          pw.Text('Chữ ký:'),
          pw.SizedBox(height: 8),
          pw.Container(
            height: 95,
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: pdf.PdfColors.black, width: 1),
              ),
            ),
            child: pw.Center(
              child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
            ),
          ),
        ],
      ),
    );

    return document.save();
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

  Future<void> _confirmSignature() async {
    if (_isUploading) return;
    if (_signatureController.isEmpty) {
      AppToast.show(
        context,
        message: 'Vui lòng ký trước khi xác nhận',
        type: AppToastType.warning,
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      final signatureBytes = await _signatureController.toPngBytes();
      if (signatureBytes == null || signatureBytes.isEmpty) {
        throw Exception('Không xuất được chữ ký');
      }

      final pdfBytes = await _buildSignedPdf(signatureBytes);
      if (!mounted) return;
      Navigator.of(context).pop(pdfBytes);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
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
                    onTap: _isUploading
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
                    constraints: const BoxConstraints(maxWidth: 850),
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(30, 28, 30, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  'THỎA THUẬN ĐĂNG KÝ XE CHO THUÊ TRÊN NỀN TẢNG',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    height: 1.35,
                                    letterSpacing: 0.2,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Ngày lập: ${widget.registrationDateText}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Ký trực tiếp bên dưới để hoàn tất hợp đồng.',
                            style: TextStyle(
                              fontSize: 12.2,
                              height: 1.45,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 14),
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
                                          'Vẽ chữ ký trong vùng trắng.',
                                          style: TextStyle(fontSize: 11.5),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _isUploading
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
                          const SizedBox(height: 18),
                          const Text(
                            'CHỦ XE',
                            style: TextStyle(
                              fontSize: 12.8,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Họ và tên: ${widget.ownerName}'),
                          const SizedBox(height: 18),
                          const Text(
                            'NỀN TẢNG',
                            style: TextStyle(
                              fontSize: 12.8,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Book Drive Car'),
                        ],
                      ),
                    ),
                  ),
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
                      onPressed: _confirmSignature,
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
                      child: _isUploading
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

class _ContractSection {
  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
  final List<List<String>> tableRows;
  final List<String> lines;

  const _ContractSection({
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
    this.tableRows = const [],
    this.lines = const [],
  });
}

class _PaperSectionWidget extends StatelessWidget {
  final _ContractSection section;

  const _PaperSectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(color: Colors.black, fontSize: 12.2, height: 1.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
            ),
          ),
          if (section.paragraphs.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...section.paragraphs.map(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(text),
              ),
            ),
          ],
          if (section.lines.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...section.lines.map(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(text),
              ),
            ),
          ],
          if (section.tableRows.isNotEmpty) ...[
            const SizedBox(height: 10),
            _PaperTable(rows: section.tableRows),
          ],
          if (section.bullets.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...section.bullets.map(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ', style: TextStyle(height: 1.45)),
                    Expanded(child: Text(text)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaperTable extends StatelessWidget {
  final List<List<String>> rows;

  const _PaperTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {0: FlexColumnWidth(2.6), 1: FlexColumnWidth(4.4)},
      border: TableBorder.all(color: Colors.black, width: 0.6),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows
          .map(
            (row) => TableRow(
              children: [
                _PaperCell(text: row[0], bold: true),
                _PaperCell(text: row[1]),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _PaperCell extends StatelessWidget {
  final String text;
  final bool bold;

  const _PaperCell({required this.text, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.8,
          height: 1.35,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _ConfirmationChecklist extends StatelessWidget {
  final List<String> items;
  final List<bool> values;
  final void Function(int index, bool value) onChanged;

  const _ConfirmationChecklist({
    required this.items,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: InkWell(
            onTap: () => onChanged(index, !values[index]),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: values[index],
                  onChanged: (checked) => onChanged(index, checked ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      items[index],
                      style: const TextStyle(
                        fontSize: 12.2,
                        height: 1.35,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
