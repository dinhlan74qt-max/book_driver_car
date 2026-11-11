# 04. BÁO CÁO PHÂN LOẠI LỖI PHẦN MỀM (BUG CLASSIFICATION REPORT)

**Dự án:** CarNow Mobile App (`book_drive_car`)  
**Tiêu chuẩn phân loại:** ISTQB Defect Severity Classification  
**Tổng số khiếm khuyết phát hiện:** 8 Lỗi (0 S0, 2 S1, 4 S2, 2 S3)  

---

## 1. BẢNG TỔNG HỢP DANH SÁCH LỖI (DEFECT SUMMARY MATRIX)

| Bug ID | Tiêu đề lỗi | Module ảnh hưởng | Mức độ nghiêm trọng (Severity) | Độ ưu tiên (Priority) | Trạng thái xác minh |
| :---: | :--- | :--- | :---: | :---: | :---: |
| **BUG-01** | Truyền tải dữ liệu nhạy cảm qua giao thức HTTP không mã hóa | Network / Core | **S1 - High** | **P0 - Khẩn cấp** | Đã xác nhận qua Source |
| **BUG-02** | Nguy cơ crash ứng dụng do gọi BuildContext sau tác vụ Async | Media Picker / Core | **S1 - High** | **P1 - Cao** | Đã xác nhận qua Analyzer |
| **BUG-03** | Thiếu Null-safety fallback gây crash màn hình Nạp tiền VietQR | Wallet / Data Model | **S2 - Medium** | **P1 - Cao** | Đã xác nhận qua Source |
| **BUG-04** | Nuốt ngoại lệ hệ thống do `return` bên trong khối `finally` | Rental / Presentation | **S2 - Medium** | **P2 - Trung bình** | Đã xác nhận qua Analyzer |
| **BUG-05** | Lưu trữ JWT Token không mã hóa trong SharedPreferences | Auth / Storage | **S2 - Medium** | **P2 - Trung bình** | Đã xác nhận qua Source |
| **BUG-06** | Thư mục Test đặt trong `lib/` gây phình gói APK & lộ mã kiểm thử | Project Architecture | **S2 - Medium** | **P2 - Trung bình** | Đã xác nhận qua Architecture |
| **BUG-07** | Chuỗi thông báo fallback bị lỗi font ký tự UTF-8 | Wallet / Remote DataSource | **S3 - Low** | **P3 - Thấp** | Đã xác nhận qua Source |
| **BUG-08** | Lạm dụng hàm `print()` đồng bộ trong môi trường phát hành | Auth / BLoC | **S3 - Low** | **P3 - Thấp** | Đã xác nhận qua Source |

---

## 2. CHI TIẾT TỪNG LỖI & PHƯƠNG ÁN KHẮC PHỤC

### 🐛 BUG-01: Truyền tải dữ liệu nhạy cảm qua giao thức HTTP không mã hóa (Port 8080)
* **File Path:** `lib/shared/constants/api_constants.dart` (Dòng 2 - 5)
* **Đoạn code:**
  ```dart
  static const String baseUrl = _devicePhysical;
  static const String _devicePhysical = "http://thuexetulai.click:8080";
  ```
* **Mô tả chi tiết:** Toàn bộ API của ứng dụng (bao gồm Đăng nhập, Gửi OTP, Xác thực CCCD, Đặt cọc thuê xe, Nạp ví VietQR, Rút tiền ngân hàng) đang được gửi qua giao thức HTTP bản rõ (Cleartext).
* **Rủi ro bảo mật (CWE-319):** Trong môi trường mạng Wi-Fi công cộng, kẻ tấn công dễ dàng thực hiện tấn công Man-in-the-Middle (MitM) để đánh cắp Token JWT, mã OTP, số CCCD và can thiệp số tiền giao dịch.
* **Biện pháp khắc phục (Recommended Fix):** Cấu hình SSL/TLS trên Reverse Proxy (Nginx/Cloudflare) của máy chủ Backend và đổi `baseUrl` sang giao thức `https://`.

---

### 🐛 BUG-02: Nguy cơ crash ứng dụng do gọi BuildContext sau tác vụ Async
* **File Path:**
  * `lib/core/helper/vehicle_media_permission_helper.dart` (Dòng 49)
  * `lib/core/helper/vehicle_media_picker_helper.dart` (Dòng 43, 56, 84, 97)
  * `lib/features/wallet/presentation/view/wallet_screen.dart` (Dòng 354)
* **Đoạn code ví dụ:**
  ```dart
  final image = await ImagePicker().pickImage(source: source);
  // Thiếu kiểm tra mounted
  Navigator.of(context).pop(); // Crash nếu widget đã bị dispose trong lúc user chọn ảnh
  ```
* **Rủi ro:** Khi người dùng mở hộp thoại chọn ảnh và bấm phím Home/Back để thoát màn hình, khi `ImagePicker` trả về kết quả, việc truy cập `context` đã bị hủy sẽ ném lỗi runtime không bắt được.
* **Biện pháp khắc phục:** Bổ sung `if (!context.mounted) return;` hoặc `if (!mounted) return;` ngay sau mọi câu lệnh `await`.

---

### 🐛 BUG-03: Thiếu Null-safety fallback gây crash màn hình Nạp tiền VietQR
* **File Path:** `lib/features/wallet/data/models/deposit_result_model.dart` (Dòng 9 - 14)
* **Đoạn code:**
  ```dart
  factory DepositResultModel.fromJson(Map<String, dynamic> json) {
    return DepositResultModel(
      qrCodeUrl: json['qrCodeUrl'], // Bắt buộc non-nullable String
      transactionCode: json['transactionCode'],
    );
  }
  ```
* **Nguyên nhân:** Trong `DepositResultEntity`, `qrCodeUrl` và `transactionCode` được khai báo là `required String`. Nếu Backend gặp sự cố hoặc trả về `{ "qrCodeUrl": null }`, ứng dụng sẽ crash ngay lập tức vì lỗi `type 'Null' is not a subtype of type 'String'`.
* **Biện pháp khắc phục:**
  ```dart
  factory DepositResultModel.fromJson(Map<String, dynamic> json) {
    return DepositResultModel(
      qrCodeUrl: json['qrCodeUrl']?.toString() ?? '',
      transactionCode: json['transactionCode']?.toString() ?? '',
    );
  }
  ```

---

### 🐛 BUG-04: Nuốt ngoại lệ hệ thống do `return` bên trong khối `finally`
* **File Path:** `lib/features/rental/presentation/view/rental_screen.dart` (Dòng 124)
* **Nguyên nhân:** Đặt câu lệnh `if (!mounted) return;` trong khối `finally`. Theo quy chuẩn ngôn ngữ Dart, lệnh điều khiển dòng chảy (`return`, `break`, `continue`) đặt trong `finally` sẽ triệt tiêu bất kỳ ngoại lệ nào chưa được bắt ở khối `try/catch`.
* **Biện pháp khắc phục:** Bỏ `return` trong `finally`, thay bằng kiểm tra điều kiện an toàn:
  ```dart
  } finally {
    if (mounted) {
      setState(() {
        _initialLoading = false;
        _refreshing = false;
      });
    }
  }
  ```

---

### 🐛 BUG-05: Lưu trữ JWT Token không mã hóa trong SharedPreferences
* **File Path:** `lib/core/storage/user_local_storage.dart` (Dòng 28 - 37)
* **Mô tả:** Token đăng nhập và thông tin người dùng được lưu trực tiếp dạng Text trong `SharedPreferences` (file XML trong `/data/data/.../shared_prefs/`).
* **Rủi ro:** Thiết bị Android bị Root hoặc cài phần mềm độc hại có thể đọc trộm file này để chiếm đoạt tài khoản.
* **Biện pháp khắc phục:** Chuyển sang sử dụng thư viện `flutter_secure_storage` (sử dụng Android Keystore và iOS Keychain).

---

### 🐛 BUG-06: Thư mục Test đặt trong `lib/` gây phình gói APK & lộ mã kiểm thử
* **File Path:** `lib/test/`
* **Nguy cơ:** Gây ra 22 cảnh báo lint `depend_on_referenced_packages`. Mã nguồn kiểm thử và các đối tượng Mocktail bị biên dịch vào gói Release.
* **Biện pháp khắc phục:** Di chuyển toàn bộ thư mục `lib/test` ra thư mục gốc `test/`.

---

### 🐛 BUG-07: Chuỗi thông báo fallback bị lỗi font ký tự UTF-8
* **File Path:** `lib/features/wallet/data/datasources/wallet_remote_data_source.dart` (Dòng 243, 248)
* **Đoạn code:**
  * `return 'T?o l?nh rút ti?n thành công';`
  * `fallback: 'Rút ti?n th?t b?i (${response.statusCode})'`
* **Hậu quả:** Người dùng nhìn thấy chuỗi ký tự bị lỗi dấu hỏi chấm `?` khi mạng gặp sự cố.
* **Biện pháp khắc phục:** Lưu file với định dạng chuẩn **UTF-8 with BOM / UTF-8**.

---

### 🐛 BUG-08: Lạm dụng hàm `print()` đồng bộ trong môi trường phát hành
* **File Path:** `lib/features/auth/presentation/bloc/login_bloc.dart` (Dòng 34)
* **Đoạn code:** `print(e.toString());`
* **Hậu quả:** Không thể tắt log khi build release, ảnh hưởng nhẹ đến hiệu năng và lộ chi tiết lỗi.
* **Biện pháp khắc phục:** Thay bằng `debugPrint` hoặc logging framework.
