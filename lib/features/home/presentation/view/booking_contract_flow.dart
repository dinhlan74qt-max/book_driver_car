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

  String _vehicleName() {
    final model = widget.car.model?.trim();
    return (model != null && model.isNotEmpty) ? model : widget.car.name;
  }

  String _vehicleLocation() {
    return widget.car.location.trim().isNotEmpty
        ? widget.car.location
        : 'Chưa cập nhật';
  }

  String _ownerAddressText() {
    return widget.renter.addressText.isNotEmpty
        ? widget.renter.addressText
        : 'Chưa cập nhật';
  }

  int _rentalDays() {
    final days = widget.request.endDate
        .difference(widget.request.startDate)
        .inDays;
    return days <= 0 ? 1 : days;
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

  List<_ContractSection> _contractSections() {
    final vehicleName = _vehicleName();
    final vehicleLicensePlate =
        widget.car.licensePlate?.trim().isNotEmpty == true
        ? widget.car.licensePlate!
        : 'Chưa cập nhật';
    final vehicleColor = widget.car.color?.trim().isNotEmpty == true
        ? widget.car.color!
        : 'Chưa cập nhật';
    final vehicleYear = widget.car.year?.toString() ?? 'Chưa cập nhật';
    final vehicleFuel = widget.car.fuelType?.trim().isNotEmpty == true
        ? widget.car.fuelType!
        : 'Chưa cập nhật';
    final vehicleTransmission =
        widget.car.transmission?.trim().isNotEmpty == true
        ? widget.car.transmission!
        : 'Chưa cập nhật';
    final pricePerDayText = '${_formatCurrency(widget.car.pricePerDay)} VNĐ';
    final totalEstimated =
        '${_formatCurrency(widget.car.pricePerDay * _rentalDays())} VNĐ';
    final rentalStart = _formatDateTime(widget.request.startDate);
    final rentalEnd = _formatDateTime(widget.request.endDate);
    final rentalLocation = _vehicleLocation();

    return [
      _ContractSection(
        title: 'BÊN A - CHỦ XE / BÊN CHO THUÊ',
        lines: const [
          'Họ và tên: Chủ xe sẽ xác nhận sau',
          'Số điện thoại: Chủ xe sẽ xác nhận sau',
          'Email: Chủ xe sẽ xác nhận sau',
          'Địa chỉ: Chủ xe sẽ xác nhận sau',
          'Mã người dùng: Chủ xe sẽ xác nhận sau',
          'Sau đây gọi là “Bên A” hoặc “Chủ xe”.',
        ],
      ),
      _ContractSection(
        title: 'BÊN B - NGƯỜI THUÊ',
        lines: [
          'Họ và tên: ${widget.renter.fullname}',
          'Số điện thoại: ${widget.renter.phone}',
          'Email: ${widget.renter.email}',
          'Địa chỉ: ${_ownerAddressText()}',
          'Mã người dùng: ${widget.renter.cccd ?? 'Chưa cập nhật'}',
          'Thông tin giấy phép lái xe: Chưa cập nhật',
          'Sau đây gọi là “Bên B” hoặc “Người thuê”.',
        ],
      ),
      _ContractSection(
        title: 'THÔNG TIN VỀ NỀN TẢNG',
        paragraphs: const [
          'Tên nền tảng: BOOK DRIVE CAR',
          'Book Drive Car là nền tảng công nghệ hỗ trợ Bên A và Bên B tìm kiếm, đặt xe, trao đổi thông tin, quản lý giao dịch và lưu trữ thông tin hợp đồng.',
          'Book Drive Car không phải là bên cho thuê xe và không phải là chủ sở hữu phương tiện trong giao dịch này.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 1. ĐỐI TƯỢNG HỢP ĐỒNG',
        paragraphs: const [
          'Bên A đồng ý cho Bên B thuê phương tiện được mô tả trong hợp đồng này.',
          'Bên B đồng ý thuê và sử dụng phương tiện theo đúng thời gian, mục đích và các điều kiện đã được hai bên thống nhất.',
          'Book Drive Car cung cấp nền tảng để hỗ trợ hai bên thực hiện giao dịch.',
          'Hợp đồng này được tạo dựa trên thông tin giao dịch được ghi nhận trên hệ thống Book Drive Car tại thời điểm hai bên xác nhận.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 2. THÔNG TIN PHƯƠNG TIỆN',
        tableRows: [
          ['Mã phương tiện', '[VEHICLE-ID]'],
          ['Hãng xe', widget.car.brand],
          ['Dòng xe', widget.car.model ?? widget.car.name],
          ['Phiên bản', _vehicleName()],
          ['Biển số', vehicleLicensePlate],
          ['Màu xe', vehicleColor],
          ['Năm sản xuất', vehicleYear],
          ['Số chỗ', widget.car.seats.toString()],
          ['Loại nhiên liệu', vehicleFuel],
          ['Hộp số', vehicleTransmission],
          ['Số km tại thời điểm nhận', '[ODO]'],
          ['Mức nhiên liệu/pin', '[FUEL/BATTERY]'],
        ],
        paragraphs: const [
          'Bên A xác nhận phương tiện được cung cấp cho Bên B phù hợp với thông tin đã đăng trên Book Drive Car, ngoại trừ những thay đổi đã được hai bên thống nhất và ghi nhận.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 3. THỜI HẠN VÀ ĐỊA ĐIỂM THUÊ',
        lines: [
          'Thời gian nhận xe: $rentalStart',
          'Thời gian trả xe dự kiến: $rentalEnd',
          'Tổng thời gian thuê: ${_rentalDays()} ngày',
          'Địa điểm nhận xe: $rentalLocation',
          'Địa điểm trả xe: $rentalLocation',
        ],
        paragraphs: const [
          'Bên B có trách nhiệm nhận và trả phương tiện theo thời gian và địa điểm đã xác nhận.',
          'Mọi thay đổi về thời gian hoặc địa điểm phải được hai bên thống nhất và được ghi nhận trên hệ thống khi có thể.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 4. GIÁ THUÊ VÀ GIÁ TRỊ HỢP ĐỒNG',
        lines: [
          'Đơn giá thuê: $pricePerDayText/ngày',
          'Số ngày thuê: ${_rentalDays()} ngày',
          'Tiền thuê xe: ${_formatCurrency(widget.car.pricePerDay * _rentalDays())} VNĐ',
          'Tổng giá trị giao dịch: $totalEstimated',
        ],
        paragraphs: const [
          'Các khoản tiền được hiển thị trên Book Drive Car trước khi Bên B xác nhận đặt xe.',
          'Giá trị cuối cùng của giao dịch được xác định theo thông tin được hệ thống ghi nhận tại thời điểm giao dịch được xác nhận, bao gồm các khoản phát sinh đã được hai bên chấp thuận.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 5. PHÍ DỊCH VỤ BOOK DRIVE CAR',
        paragraphs: const [
          'Book Drive Car là nền tảng trung gian hỗ trợ kết nối Bên A và Bên B.',
          'Đối với giao dịch được thực hiện thông qua nền tảng, Book Drive Car thu 10% phí dịch vụ tính trên giá trị tiền thuê xe theo chính sách của nền tảng.',
          'Phí dịch vụ này được ghi nhận riêng trong thông tin giao dịch và được khấu trừ theo quy trình thanh toán của nền tảng.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 6. PHƯƠNG THỨC THANH TOÁN',
        lines: const [
          'Tổng tiền: [XXX.XXX VNĐ]',
          'Đã thanh toán: [XXX.XXX VNĐ]',
          'Còn lại: [XXX.XXX VNĐ]',
          'Tiền đặt cọc: [XXX.XXX VNĐ]',
        ],
        paragraphs: const [
          'Bên B thực hiện thanh toán theo phương thức được Book Drive Car hỗ trợ tại thời điểm đặt xe.',
          'Book Drive Car ghi nhận trạng thái thanh toán của giao dịch trên hệ thống.',
          'Việc chuyển khoản hoặc giải ngân cho Bên A được thực hiện theo quy trình thanh toán của nền tảng.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 7. BÀN GIAO XE',
        bullets: const [
          'Khi bàn giao xe, Bên A và Bên B cùng kiểm tra tình trạng phương tiện.',
          'Các thông tin cần ghi nhận gồm số km trên đồng hồ, mức nhiên liệu hoặc pin, tình trạng ngoại thất, tình trạng nội thất, các vết trầy xước hoặc hư hỏng có sẵn, lốp xe và các trang thiết bị đi kèm, các phụ kiện được bàn giao và hình ảnh phương tiện tại thời điểm bàn giao.',
          'Bên B có quyền kiểm tra phương tiện trước khi nhận.',
          'Nếu phát hiện tình trạng phương tiện khác đáng kể so với thông tin đã được xác nhận, Bên B có quyền yêu cầu Bên A giải thích và hai bên có thể thống nhất việc tiếp tục hoặc xử lý giao dịch theo quy định của nền tảng.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 8. TRÁCH NHIỆM CỦA BÊN A - CHỦ XE',
        bullets: const [
          'Cung cấp phương tiện đúng với thông tin đã đăng ký.',
          'Bảo đảm mình có quyền hợp pháp để cho thuê phương tiện.',
          'Cung cấp phương tiện trong tình trạng phù hợp để sử dụng.',
          'Cung cấp giấy tờ cần thiết liên quan đến phương tiện theo quy định áp dụng.',
          'Bảo đảm phương tiện không có tình trạng nguy hiểm mà Bên A biết nhưng cố tình không thông báo.',
          'Bàn giao xe đúng thời gian và địa điểm đã xác nhận.',
          'Cung cấp các phụ kiện đã cam kết.',
          'Thông báo cho Bên B về các đặc điểm hoặc vấn đề cần lưu ý khi sử dụng xe.',
          'Phối hợp giải quyết sự cố phát sinh trong thời gian thuê.',
          'Thực hiện việc hoàn trả tiền đặt cọc hoặc khoản tiền thuộc trách nhiệm của Bên A theo kết quả giao dịch.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 9. TRÁCH NHIỆM CỦA BÊN B - NGƯỜI THUÊ',
        bullets: const [
          'Cung cấp thông tin cá nhân chính xác.',
          'Cung cấp giấy tờ cần thiết theo yêu cầu của giao dịch.',
          'Sử dụng phương tiện đúng mục đích.',
          'Tuân thủ quy định pháp luật khi điều khiển phương tiện.',
          'Bảo quản phương tiện trong thời gian thuê.',
          'Không tự ý thay đổi kết cấu hoặc tình trạng phương tiện.',
          'Không sử dụng phương tiện vào mục đích trái pháp luật.',
          'Không tự ý chuyển giao phương tiện cho người khác sử dụng nếu chưa được phép.',
          'Thông báo kịp thời cho Bên A khi phương tiện xảy ra sự cố.',
          'Trả xe đúng thời gian và địa điểm đã thống nhất.',
          'Thanh toán các khoản tiền thuộc trách nhiệm của mình.',
          'Bồi hoàn các thiệt hại do lỗi của mình gây ra theo thỏa thuận và quy định áp dụng.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 10. QUY ĐỊNH SỬ DỤNG PHƯƠNG TIỆN',
        bullets: const [
          'Bên B cam kết không sử dụng phương tiện cho mục đích trái pháp luật.',
          'Không dùng để vận chuyển hàng hóa hoặc hành khách trái quy định.',
          'Không dùng cho các hoạt động nguy hiểm hoặc trái phép.',
          'Không tự ý thay đổi kết cấu phương tiện.',
          'Không thực hiện các hành vi có thể gây hư hỏng nghiêm trọng cho phương tiện.',
          'Bên B phải sử dụng phương tiện phù hợp với đặc tính và hướng dẫn sử dụng của phương tiện.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 11. TRẢ XE',
        bullets: const [
          'Khi kết thúc thời gian thuê, Bên B phải trả phương tiện đúng thời gian, đúng địa điểm, đúng phương tiện, với các phụ kiện đi kèm và trong tình trạng phù hợp với hao mòn thông thường.',
          'Hai bên thực hiện kiểm tra tình trạng xe khi trả.',
          'Các thông tin có thể được ghi nhận gồm số km khi trả, mức nhiên liệu/pin, tình trạng xe, phụ kiện và hình ảnh khi trả.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 12. TRẢ XE TRỄ',
        paragraphs: const [
          'Nếu Bên B trả xe muộn so với thời gian đã thỏa thuận, khoản phí phát sinh được xác định theo chính sách đã được hiển thị cho Bên B trước khi xác nhận giao dịch hoặc theo thỏa thuận giữa hai bên.',
          'Bên B có trách nhiệm thông báo sớm cho Bên A nếu dự kiến không thể trả xe đúng thời gian.',
          'Trường hợp việc trả xe trễ làm ảnh hưởng đến giao dịch tiếp theo, các bên phối hợp với Book Drive Car để xử lý.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 13. HƯ HỎNG VÀ BỒI HOÀN',
        paragraphs: const [
          'Nếu phương tiện bị hư hỏng trong thời gian thuê, hai bên cần xác định nguyên nhân và mức độ thiệt hại.',
          'Trường hợp thiệt hại phát sinh do lỗi của Bên B, Bên B có trách nhiệm thanh toán khoản chi phí hợp lý tương ứng với thiệt hại thực tế theo thỏa thuận và quy định áp dụng.',
          'Trường hợp thiệt hại không do lỗi của Bên B hoặc thuộc hao mòn thông thường, Bên B không phải chịu trách nhiệm đối với phần thiệt hại đó.',
          'Book Drive Car có thể hỗ trợ hai bên lưu trữ hình ảnh, thông tin và bằng chứng liên quan để phục vụ việc giải quyết.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 14. TAI NẠN VÀ SỰ CỐ',
        paragraphs: const [
          'Khi xảy ra tai nạn hoặc sự cố nghiêm trọng, Bên B phải ưu tiên bảo đảm an toàn cho người liên quan và thông báo cho Bên A trong thời gian sớm nhất có thể.',
          'Bên B không được cố ý che giấu hoặc làm sai lệch thông tin về sự cố.',
          'Bên A có trách nhiệm phối hợp cung cấp thông tin liên quan đến phương tiện.',
          'Book Drive Car hỗ trợ kết nối thông tin giữa hai bên trong phạm vi chức năng của nền tảng.',
          'Việc xác định trách nhiệm đối với thiệt hại được thực hiện dựa trên thông tin, bằng chứng và quy định áp dụng.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 15. TIỀN ĐẶT CỌC',
        paragraphs: const [
          'Nếu giao dịch có tiền đặt cọc, số tiền đặt cọc được sử dụng theo thỏa thuận của giao dịch nhằm bảo đảm các nghĩa vụ của Bên B trong thời gian thuê.',
          'Sau khi Bên B trả xe và hai bên hoàn tất kiểm tra, tiền đặt cọc được xử lý theo kết quả giao dịch.',
          'Nếu có tranh chấp về thiệt hại hoặc nghĩa vụ phát sinh, phần tiền liên quan có thể được tạm giữ theo quy trình xử lý của nền tảng cho đến khi có kết quả.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 16. HỦY GIAO DỊCH',
        paragraphs: const [
          'Việc hủy giao dịch của Bên A hoặc Bên B được thực hiện theo chính sách hủy được hiển thị tại thời điểm đặt xe.',
          'Tùy thời điểm hủy và nguyên nhân hủy, giao dịch có thể phát sinh hoàn tiền, phí hủy, khoản bồi hoàn hoặc các khoản điều chỉnh khác theo chính sách giao dịch.',
          'Book Drive Car ghi nhận lịch sử hủy trên hệ thống.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 17. VAI TRÒ CỦA BOOK DRIVE CAR',
        bullets: const [
          'Đăng tải thông tin phương tiện.',
          'Tìm kiếm phương tiện.',
          'Kết nối Chủ xe và Người thuê.',
          'Tạo và quản lý booking.',
          'Hỗ trợ thanh toán theo chức năng của hệ thống.',
          'Lưu trữ thông tin giao dịch.',
          'Hỗ trợ trao đổi và xử lý khiếu nại.',
        ],
        paragraphs: const [
          'Book Drive Car không trực tiếp sở hữu hoặc cho thuê phương tiện trong giao dịch này.',
          'Việc Book Drive Car cung cấp nền tảng không làm thay đổi trách nhiệm của Bên A và Bên B đối với các nghĩa vụ mà mỗi bên đã cam kết trong Hợp đồng.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 18. HỦY HỢP ĐỒNG',
        paragraphs: const [
          'Hợp đồng chấm dứt khi thời gian thuê kết thúc và các nghĩa vụ đã được hoàn tất.',
          'Hai bên thống nhất chấm dứt giao dịch.',
          'Giao dịch bị hủy theo chính sách của nền tảng.',
          'Có sự kiện khiến giao dịch không thể tiếp tục thực hiện.',
          'Việc chấm dứt hợp đồng không làm mất các nghĩa vụ đã phát sinh trước thời điểm chấm dứt.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 19. GIẢI QUYẾT TRANH CHẤP',
        paragraphs: const [
          'Các bên ưu tiên giải quyết tranh chấp bằng thương lượng và thiện chí.',
          'Khi phát sinh tranh chấp, Bên A và Bên B có trách nhiệm cung cấp các thông tin, hình ảnh, chứng từ và dữ liệu liên quan.',
          'Book Drive Car có thể hỗ trợ cung cấp lịch sử giao dịch, thông tin booking và các dữ liệu được lưu trữ trên hệ thống trong phạm vi phù hợp.',
          'Nếu các bên không thể tự giải quyết, tranh chấp được xử lý theo quy định pháp luật có thẩm quyền.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 20. XÁC NHẬN THÔNG TIN',
        paragraphs: const ['Bên A - Chủ xe xác nhận:'],
        bullets: const [
          'Thông tin cá nhân là chính xác.',
          'Tôi có quyền hợp pháp đối với phương tiện.',
          'Thông tin phương tiện cung cấp là chính xác.',
          'Tôi đồng ý cho thuê phương tiện theo các điều kiện của giao dịch.',
          'Tôi đã kiểm tra thông tin giao dịch.',
          'Bên B - Người thuê xác nhận:',
          'Thông tin cá nhân là chính xác.',
          'Tôi đã kiểm tra thông tin phương tiện.',
          'Tôi đồng ý thuê phương tiện theo thời gian và giá đã xác nhận.',
          'Tôi hiểu các nghĩa vụ trong thời gian thuê.',
          'Tôi đồng ý với các khoản phí được hiển thị trong giao dịch.',
        ],
      ),
      _ContractSection(
        title: 'ĐIỀU 21. LƯU TRỮ HỢP ĐỒNG',
        paragraphs: const [
          'Sau khi hai bên hoàn tất việc ký kết, hệ thống tạo và lưu trữ bản hợp đồng bao gồm nội dung hợp đồng, thông tin Chủ xe, thông tin Người thuê, thông tin phương tiện, thông tin booking, giá thuê, phí dịch vụ nền tảng 10%, chữ ký của Bên A, chữ ký của Bên B, thời gian ký, mã hợp đồng và phiên bản hợp đồng.',
          'Bản hợp đồng được lưu trên hệ thống Book Drive Car để hai bên có thể xem lại trong lịch sử giao dịch.',
        ],
      ),
    ];
  }

  List<Widget> _buildContractWidgets() {
    return _contractSections()
        .map((section) => _FlutterContractSectionView(section: section))
        .toList();
  }

  List<pw.Widget> _buildPdfSections() {
    return _contractSections().map(_buildPdfSection).toList();
  }

  pw.Widget _buildPdfSection(_ContractSection section) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            section.title,
            style: pw.TextStyle(fontSize: 13.4, fontWeight: pw.FontWeight.bold),
          ),
          if (section.paragraphs.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            ...section.paragraphs.map(
              (text) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Text(
                  text,
                  style: const pw.TextStyle(fontSize: 11.2, height: 1.45),
                ),
              ),
            ),
          ],
          if (section.lines.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            ...section.lines.map(
              (text) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Text(
                  text,
                  style: const pw.TextStyle(fontSize: 11.2, height: 1.45),
                ),
              ),
            ),
          ],
          if (section.tableRows.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _pdfTable(section.tableRows),
          ],
          if (section.bullets.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            ...section.bullets.map(
              (text) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('•  ', style: const pw.TextStyle(fontSize: 11.2)),
                    pw.Expanded(
                      child: pw.Text(
                        text,
                        style: const pw.TextStyle(fontSize: 11.2, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<Uint8List> _buildSignedPdf(Uint8List renterSignatureBytes) async {
    final document = pw.Document(theme: await _loadPdfTheme());
    final renterSignatureImage = pw.MemoryImage(renterSignatureBytes);

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: pdf.PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(28, 30, 28, 28),
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
          pw.SizedBox(height: 16),
          pw.Text(
            'Hôm nay, ngày ${_todayText()}, thông qua nền tảng BOOK DRIVE CAR, các bên thống nhất ký kết hợp đồng cho thuê xe với các thông tin sau:',
            style: const pw.TextStyle(fontSize: 11.3, height: 1.45),
          ),
          pw.SizedBox(height: 12),
          ..._buildPdfSections(),
          pw.SizedBox(height: 8),
          pw.Text(
            'XÁC NHẬN VÀ KÝ KẾT HỢP ĐỒNG',
            style: pw.TextStyle(fontSize: 13.4, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Bên A và Bên B xác nhận đã đọc, hiểu và đồng ý với toàn bộ nội dung của Hợp đồng này.',
            style: const pw.TextStyle(fontSize: 11.2, height: 1.45),
          ),
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
                      pw.Text(
                        'BÊN A - CHỦ XE',
                        style: pw.TextStyle(
                          fontSize: 12.8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Họ và tên: .....................................',
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text('Chữ ký:'),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        height: 92,
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
                      pw.Text(
                        'BÊN B - NGƯỜI THUÊ',
                        style: pw.TextStyle(
                          fontSize: 12.8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text('Họ và tên: ${widget.renter.fullname}'),
                      pw.SizedBox(height: 8),
                      pw.Text('Chữ ký:'),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        height: 92,
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
          pw.SizedBox(height: 14),
          pw.Text(
            'XÁC NHẬN CỦA BOOK DRIVE CAR',
            style: pw.TextStyle(fontSize: 12.8, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Book Drive Car'),
          pw.SizedBox(height: 4),
          pw.Text(
            'Book Drive Car xác nhận giao dịch và hợp đồng đã được hai bên thực hiện thông qua nền tảng.',
            style: const pw.TextStyle(fontSize: 11.2, height: 1.45),
          ),
        ],
      ),
    );

    return document.save();
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
          fontSize: 10.7,
          height: 1.35,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  Widget _uiMetaLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12.0,
          height: 1.45,
          color: Colors.black,
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
      debugPrint(
        '[BookingContractScreen][_submitContract] signatureBytesLength=${signatureBytes.length}',
      );
      final fileName =
          'contract_signed_${DateTime.now().millisecondsSinceEpoch}.pdf';
      debugPrint(
        '[BookingContractScreen][_submitContract] pdfBytesLength=${pdfBytes.length} fileName=$fileName',
      );
      final bookingRequest = BookingRequestEntity(
        vehicleId: widget.request.vehicleId,
        startDate: widget.request.startDate,
        endDate: widget.request.endDate,
        note: widget.request.note,
        contractPdfBytes: pdfBytes,
        contractPdfFileName: fileName,
      );
      final booking = await sl<BookingRemoteDataSource>().createBooking(
        bookingRequest,
      );

      if (!mounted) return;
      Navigator.of(context).pop(booking);
    } catch (e, st) {
      debugPrint(
        '[BookingContractScreen][_submitContract] error=$e',
      );
      debugPrint(
        '[BookingContractScreen][_submitContract] stackTrace=$st',
      );
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
    final contractSections = _contractSections();

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
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 30),
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    height: 1.35,
                                    letterSpacing: 0.2,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ngày ký: ${_todayText()}',
                            style: const TextStyle(
                              fontSize: 12.4,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Hôm nay, ngày ${_todayText()}, thông qua nền tảng BOOK DRIVE CAR, các bên thống nhất ký kết hợp đồng cho thuê xe với các thông tin sau:',
                            style: const TextStyle(
                              fontSize: 12.2,
                              height: 1.45,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _uiMetaLine('Người thuê', widget.renter.fullname),
                          _uiMetaLine('Xe', _vehicleName()),
                          _uiMetaLine(
                            'Biển số',
                            widget.car.licensePlate?.trim().isNotEmpty == true
                                ? widget.car.licensePlate!
                                : 'Chưa cập nhật',
                          ),
                          _uiMetaLine(
                            'Thời gian thuê',
                            '${_formatDateTime(widget.request.startDate)} - ${_formatDateTime(widget.request.endDate)}',
                          ),
                          const SizedBox(height: 18),
                          ...contractSections.expand(
                            (section) => [
                              _FlutterContractSectionView(section: section),
                              const SizedBox(height: 14),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'XÁC NHẬN VÀ KÝ KẾT HỢP ĐỒNG',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Bên A và Bên B xác nhận đã đọc, hiểu và đồng ý với toàn bộ nội dung của Hợp đồng này.',
                            style: TextStyle(
                              fontSize: 12.2,
                              height: 1.45,
                              color: Colors.black,
                            ),
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
                                          'Chữ ký người thuê sẽ được chèn vào PDF khi xác nhận',
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
                'Vui lòng ký hợp đồng để hoàn tất việc đặt xe.',
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

class _FlutterContractSectionView extends StatelessWidget {
  final _ContractSection section;

  const _FlutterContractSectionView({required this.section});

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
            _FlutterContractTable(rows: section.tableRows),
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

class _FlutterContractTable extends StatelessWidget {
  final List<List<String>> rows;

  const _FlutterContractTable({required this.rows});

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
                _FlutterContractCell(text: row[0], bold: true),
                _FlutterContractCell(text: row[1]),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _FlutterContractCell extends StatelessWidget {
  final String text;
  final bool bold;

  const _FlutterContractCell({required this.text, this.bold = false});

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
