# 08. BÁO CÁO ĐÁNH GIÁ CHẤT LƯỢNG TỔNG THỂ (FINAL QA ASSESSMENT & SIGN-OFF)

**Dự án:** CarNow - Ứng dụng thuê xe ô tô tự lái (`book_drive_car`)  
**Tác giả kiểm toán:** Senior QA Engineer & Software Test Architect  
**Ngày phát hành báo cáo:** 11/11/2026  
**Phiên bản ứng dụng:** 1.0.0+1  

---

## 1. TỔNG QUAN DỰ ÁN (PROJECT OVERVIEW)

* **Tên sản phẩm:** CarNow (Hệ thống đặt xe ô tô tự lái và ký hợp đồng điện tử)
* **Ngôn ngữ & Framework:** Flutter 3.x / Dart 3.12+ (Null-safety hoàn toàn)
* **Kiến trúc ứng dụng:** Clean Architecture (Domain - Data - Presentation) kết hợp BLoC/Cubit Pattern
* **Công nghệ tích hợp:** 
  * Quản lý State: `flutter_bloc: ^9.1.1`
  * Dependency Injection: `get_it: ^9.2.1` & `injectable: ^3.0.0`
  * Networking: `dio: ^5.11.0`
  * Bản đồ & Vị trí: `geolocator: ^14.0.3`
  * Thanh toán & Tài liệu: Hợp đồng PDF (`pdf: ^3.11.3`), Chữ ký điện tử (`signature: ^6.3.0`), Mã QR VietQR.

---

## 2. TỔNG KẾT KẾT QUẢ KIỂM THỬ (TESTING & DEFECT SUMMARY)

### 2.1. Kết quả thực thi Test Suite
* **Tổng số Test Cases:** **58 Test Cases**
* **Số ca PASS (Đạt):** **58 (100%)**
* **Số ca FAIL (Trượt):** **0 (0%)**
* **Số ca BLOCKED (Bị chặn):** **0 (0%)**
* **Thời gian thực thi toàn bộ test:** **45.2 giây**

### 2.2. Phân loại lỗi phần mềm phát hiện (Bug Summary)
* **Tổng số Bug:** **8 Khiếm khuyết**
  * **S0 - Critical:** 0 lỗi
  * **S1 - High:** 2 lỗi (Cleartext HTTP và Async BuildContext usage)
  * **S2 - Medium:** 4 lỗi (Null-safety DepositModel, Finally control flow, Plaintext Storage, Thư mục lib/test)
  * **S3 - Low:** 2 lỗi (Lỗi ký tự font UTF-8 fallback, Print console)

---

## 3. BẢNG ĐIỂM CHẤT LƯỢNG PHẦN MỀM (QUALITY SCORE: THANG ĐIỂM 100)

Dựa trên kết quả đo đạc từ kiểm thử thực tế và phân tích tĩnh, điểm số chất lượng của ứng dụng được xếp loại như sau:

| Tiêu chí đánh giá (Criteria) | Trọng số | Điểm đạt được | Bằng chứng & Lý do đánh giá |
| :--- | :---: | :---: | :--- |
| **1. Functional Correctness (Đúng đắn chức năng)** | 30 | **27.0 / 30** | Luồng Đăng nhập, Duyệt xe, Lọc, Ví tiền, Yêu thích hoạt động trơn tru. Bị trừ 3 điểm do Model nạp tiền thiếu fallback null. |
| **2. Code Quality & Architecture (Kiến trúc & Mã nguồn)** | 15 | **12.5 / 15** | Clean Architecture chuẩn chỉ, BLoC nhất quán. Bị trừ 2.5 điểm do God Widget (`profile_screen` gần 2000 dòng) và DI trùng lặp. |
| **3. Test Coverage (Độ bao phủ kiểm thử)** | 15 | **12.0 / 15** | Đạt 58 test cases bao phủ hầu hết các tầng then chốt (~62% coverage). Cần thêm test cho module chủ xe và hủy chuyến. |
| **4. Security (An toàn thông tin & Bảo mật)** | 15 | **9.5 / 15** | Bị trừ 5.5 điểm do kết nối HTTP cleartext (port 8080) và lưu token vào SharedPreferences chưa qua mã hóa phần cứng. |
| **5. Performance & Stability (Hiệu năng & Độ ổn định)** | 10 | **8.5 / 10** | Danh sách xe mượt mà với `cached_network_image`, virtualization tốt. Cần đưa tác vụ PDF sang Background Isolate. |
| **6. UI/UX Quality (Trải nghiệm người dùng)** | 10 | **9.0 / 10** | Hệ thống Design Token chuẩn, Dark/Light mode Ripple Animation phong cách Telegram cực đẹp. Fallback lỗi còn dính lỗi font nhỏ. |
| **7. Error Handling (Xử lý ngoại lệ)** | 5 | **4.5 / 5** | Các Repository đều có `_extractErrorMessage`, BLoC bắt lỗi đầy đủ. Trừ nhẹ lỗi `return` trong `finally`. |
| **TỔNG ĐIỂM CHẤT LƯỢNG (TOTAL QUALITY SCORE)** | **100** | **83.0 / 100** | **HẠNG: TỐT - XUẤT SẮC (GRADE A-)** |

---

## 4. KẾT LUẬN ĐIỀU KIỆN PHÁT HÀNH (RELEASE READINESS VERDICT)

```text
========================================================================
           KẾT LUẬN: READY WITH CONDITIONS (SẴN SÀNG CÓ ĐIỀU KIỆN)
========================================================================
```

Ứng dụng CarNow đã đạt độ hoàn thiện rất cao về kiến trúc, chức năng nghiệp vụ và giao diện. Ứng dụng **hoàn toàn đủ điều kiện xuất sắc để Báo cáo Đồ án / Nghiệm thu phần mềm**.

Tuy nhiên, nếu chuẩn bị **đưa lên Google Play Store và Apple App Store cho người dùng thật**, đội ngũ phát triển bắt buộc phải hoàn thành các điều kiện tiên quyết ở mục 5 bên dưới.

---

## 5. LỘ TRÌNH CẢI THIỆN THEO ĐỘ ƯU TIÊN (PRIORITIZED ROADMAP)

### 🔴 P0 - Phải khắc phục ngay lập tức (Bắt buộc trước khi Release)
1. **Chuyển Backend sang HTTPS:** Cài đặt SSL cho `thuexetulai.click` và đổi `ApiConstants.baseUrl = "https://thuexetulai.click"`.
2. **Khóa Cleartext Traffic:** Đảm bảo `android:usesCleartextTraffic="false"` trên Android và cấu hình `NSAppTransportSecurity` trên iOS.

### 🟡 P1 - Cần sửa trong bản cập nhật tiếp theo
1. **Bổ sung kiểm tra `mounted`:** Thêm `if (!context.mounted) return;` cho các helper chọn ảnh và quyền (`vehicle_media_picker_helper.dart`).
2. **Sửa Null Fallback trong Model Ví:** Thêm `?.toString() ?? ''` vào `DepositResultModel.fromJson`.
3. **Bỏ `return` trong `finally`:** Sửa lại khối `finally` trong `rental_screen.dart`.

### 🔵 P2 - Nên cải thiện về cấu trúc (Technical Debt)
1. **Di chuyển thư mục test:** Đưa `lib/test/` ra thư mục gốc `test/`.
2. **Phân rã God Widgets:** Tách nhỏ `profile_screen.dart` (1984 dòng) thành 4 - 5 widget chuyên biệt.
3. **Mã hóa Token:** Nâng cấp `UserLocalStorage` sử dụng `flutter_secure_storage`.
