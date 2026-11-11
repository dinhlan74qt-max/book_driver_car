# 02. BÁO CÁO PHÂN TÍCH TĨNH MÃ NGUỒN (STATIC CODE ANALYSIS REPORT)

**Lệnh thực thi:** `dart analyze lib`  
**Công cụ phân tích:** Dart Analysis Server (Dart SDK 3.12.0)  
**Ngày chạy kiểm tra:** 11/11/2026  
**Tổng số vấn đề phát hiện (Issues):** 221 issues (0 Errors, 59 Warnings, 162 Infos)  

---

## 1. PHÂN BỐ CÁC VẤN ĐỀ THEO MỨC ĐỘ (SEVERITY BREAKDOWN)

| Mức độ | Số lượng | Tỷ lệ | Đánh giá tác động |
| :--- | :---: | :---: | :--- |
| **Error (Compile Error)** | **0** | 0% | Mã nguồn biên dịch thành công 100%, không có lỗi cú pháp chết người. |
| **Warning (Cảnh báo logic & thừa code)** | **59** | 26.7% | Biến thừa, hàm không dùng, non-null assertion vô hiệu, cast thừa. |
| **Info / Lint (Quy chuẩn mã nguồn & Deprecation)** | **162** | 73.3% | BuildContext async gaps, API cũ sắp gỡ bỏ, import sai tầng. |
| **TỔNG CỘNG** | **221** | 100% | |

---

## 2. PHÂN TÍCH CHI TIẾT CÁC NHÓM LỖI & RỦI RO CHÍNH

### 🔴 Nhóm 1: Nguy cơ Crash ứng dụng khi Async (`use_build_context_synchronously`)
* **Vị trí phát hiện:**
  * `core\helper\vehicle_media_permission_helper.dart:49:7`
  * `core\helper\vehicle_media_picker_helper.dart:43:9, 56:7, 84:9, 97:7`
  * `features\profile\presentation\view\owner_booking_contract_approval_screen.dart:350:29`
  * `features\profile\presentation\view\vehicle_management\rental_management_screen.dart:87:39`
  * `features\wallet\presentation\view\wallet_screen.dart:354:31`
  * `features\onboarding\presentation\view\onboarding_screen.dart:63:18`
* **Nguyên nhân kỹ thuật:** Sử dụng `BuildContext` (để hiển thị Toast, SnackBar hoặc Navigator) sau khi thực hiện các tác vụ bất đồng bộ (`await picker`, `await permission`, `await future`) mà không kiểm tra cờ `if (!mounted) return;` hoặc `if (!context.mounted) return;`.
* **Hậu quả:** Nếu người dùng bấm Back hoặc chuyển màn hình trong khi hộp thoại chọn ảnh / quyền đang mở, khi tiến trình hoàn tất và gọi `context`, Flutter sẽ ném ngoại lệ:  
  `Exception: Looking up a deactivated widget's ancestor is unsafe`.

---

### 🔴 Nhóm 2: Nuốt ngoại lệ nguy hiểm trong khối Finally (`control_flow_in_finally`)
* **Vị trí phát hiện:** `features\rental\presentation\view\rental_screen.dart:124:21`
* **Đoạn code vi phạm:**
  ```dart
  } finally {
    if (!mounted) return; // <-- Vi phạm control_flow_in_finally
    setState(() {
      _initialLoading = false;
      _refreshing = false;
    });
  }
  ```
* **Nguy cơ:** Việc dùng lệnh `return` bên trong khối `finally` sẽ ghi đè và làm biến mất bất kỳ ngoại lệ nào chưa được bắt ở khối `try/catch`, khiến lỗi bị che giấu hoàn toàn, lập trình viên không thể trace log.

---

### 🟡 Nhóm 3: Nhập khẩu sai quy tắc phụ thuộc (`depend_on_referenced_packages`)
* **Vị trí phát hiện:** Toàn bộ các file trong `lib/test/` và `booking_remote_data_source.dart:10:8`, `vehicle_remote_data_source.dart:11:8`, `rental_remote_data_source.dart:9:8`.
* **Chi tiết:**
  1. Gói `http_parser` được import trực tiếp trong các remote data sources nhưng **chưa được khai báo chính thức** trong `dependencies` của `pubspec.yaml` (đang ăn theo gián tiếp qua Dio/Http).
  2. Các gói `flutter_test`, `mocktail` thuộc `dev_dependencies` nhưng bị import vào thư mục `lib/test/`.
* **Khuyến nghị:** Khai báo trực tiếp `http_parser: ^4.0.2` vào `pubspec.yaml` và đưa thư mục test ra ngoài `lib/`.

---

### 🟡 Nhóm 4: Lạm dụng hàm in Console trong môi trường Production (`avoid_print`)
* **Vị trí phát hiện:**
  * `features\auth\presentation\bloc\login_bloc.dart:34:7`: `print(e.toString());`
  * `features\profile\data\datasources\vehicle_remote_data_source.dart:126, 143, 146, 150`
* **Rủi ro:** Hàm `print` đồng bộ có thể làm nghẽn Main Isolate khi in chuỗi dài, đồng thời có thể rò rỉ dữ liệu nhạy cảm ra logcat trên thiết bị người dùng.
* **Khắc phục:** Thay thế bằng `debugPrint()` hoặc Logger framework (như `talker_flutter` hoặc `logger`).

---

### 🔵 Nhóm 5: Sử dụng API cũ đã bị Deprecated (`deprecated_member_use`)
* **Vị trí:** Hơn 45 cảnh báo liên quan đến `withOpacity` tại `vehicle_registration_widgets.dart`, `rental_screen.dart`, `vehicle_image_cropper.dart`.
* **Khắc phục:** Thay thế `color.withOpacity(0.5)` bằng cú pháp Flutter mới `color.withValues(alpha: 0.5)` để tránh mất độ chính xác kênh màu (precision loss).

---

## 3. TỔNG KẾT STATIC ANALYSIS

| Chỉ số | Giá trị thực tế | Ngưỡng chuẩn Production | Đánh giá |
| :--- | :---: | :---: | :---: |
| **Lỗi biên dịch (Compile Errors)** | **0** | 0 | 🟢 ĐẠT |
| **Cảnh báo nguy hiểm (High-Risk Warnings)** | **7** (async context & finally) | 0 | 🟡 CẦN SỬA |
| **Code thừa / Dead Code (Unused)** | **42** | < 10 | 🟡 CẦN DỌN DẸP |
| **Quy chuẩn mã nguồn (Lint / Clean code)** | **172** | < 50 | 🟡 KHÁ |
