# 05. BÁO CÁO KIỂM TOÁN AN TOÀN THÔNG TIN & BẢO MẬT (SECURITY AUDIT REPORT)

**Dự án:** CarNow Mobile App (`book_drive_car`)  
**Tiêu chuẩn đánh giá:** OWASP Mobile Top 10 & CWE (Common Weakness Enumeration)  
**Phạm vi:** Phân tích mã nguồn Client-side & Tích hợp API Backend  
**Ngày kiểm toán:** 11/11/2026  

---

## 1. MA TRẬN ĐÁNH GIÁ OWASP MOBILE TOP 10

| Mã OWASP | Hạng mục an toàn | Đánh giá | Rủi ro phát hiện trong CarNow |
| :--- | :--- | :---: | :--- |
| **M1: Improper Credential Usage** | Sử dụng thông tin đăng nhập sai | 🟡 MEDIUM | Token JWT lưu dạng plaintext trong SharedPreferences. |
| **M2: Inadequate Supply Chain** | Chuỗi cung ứng mã nguồn & thư viện | 🟢 LOW | Dependencies phổ biến, có khóa version trong `pubspec.lock`. |
| **M3: Insecure Authentication** | Xác thực người dùng không an toàn | 🟢 LOW | Xác thực qua JWT Bearer Token, có OTP đăng ký tài khoản. |
| **M4: Insufficient Input Validation**| Kiểm tra dữ liệu đầu vào | 🟢 LOW | Có bộ `ValidatorHelper` kiểm tra chặt chẽ Email, SĐT, Biển số. |
| **M5: Insecure Communication** | Truyền thông tin mạng không an toàn | 🔴 **HIGH** | Toàn bộ API chạy qua giao thức **HTTP bản rõ (Port 8080)**. |
| **M6: Inadequate Privacy Controls** | Kiểm soát quyền riêng tư | 🟡 MEDIUM | Lưu CCCD và số điện thoại trong Local Storage không mã hóa. |
| **M7: Insufficient Binary Protection**| Bảo vệ mã nhị phân | 🟡 MEDIUM | Thư mục `test` nằm trong `lib/` làm lộ cấu trúc Mock trong file APK. |
| **M8: Security Misconfiguration** | Cấu hình sai bảo mật | 🟡 MEDIUM | `validateStatus: (_) => true` trong Dio bỏ qua cảnh báo lỗi HTTP. |
| **M9: Insecure Data Storage** | Lưu trữ dữ liệu thiết bị không an toàn | 🟡 MEDIUM | Thiếu Keystore/Keychain cho thông tin tài chính ví. |
| **M10: Insufficient Cryptography** | Mật mã học không đủ mạnh | 🟢 LOW | Mã QR VietQR và chữ ký hợp đồng được sinh đúng chuẩn. |

---

## 2. PHÂN TÍCH CHUYÊN SÂU CÁC LỖ HỔNG BẢO MẬT TRỌNG YẾU

### 2.1. Lỗ hổng M5 / CWE-319: Truyền thông mạng không mã hóa (Cleartext HTTP)
* **Thực trạng:** `ApiConstants.baseUrl = "http://thuexetulai.click:8080"`
* **Phân tích nguy cơ:**
  1. Khi người dùng nạp tiền VietQR (`/api/my-wallet/deposit`) hoặc rút tiền (`/api/withdraw`), toàn bộ thông tin gồm: Số tài khoản ngân hàng, Tên chủ tài khoản, Số tiền giao dịch, Mã giao dịch được truyền đi mà không có lớp mã hóa TLS/SSL.
  2. Bất kỳ thiết bị nào cùng mạng Wi-Fi (hoặc nhà cung cấp mạng trung gian) đều có thể bắt gói tin (Sniffing qua Wireshark) để đọc trộm thông tin hoặc giả mạo phản hồi server.
* **Yêu cầu bắt buộc:**
  * Bật HTTPS trên cổng 443 với chứng chỉ SSL (Let's Encrypt / Cloudflare).
  * Chặn hoàn toàn Cleartext Traffic trên Android (`android:usesCleartextTraffic="false"` trong `AndroidManifest.xml`).

---

### 2.2. Lỗ hổng M1 & M9 / CWE-312: Lưu trữ Token không an toàn (Insecure Storage)
* **Thực trạng tại `UserLocalStorage`:**
  ```dart
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_token, token);
  await prefs.setString(_user, jsonEncode(_userToMap(user)));
  ```
* **Phân tích:**
  * Android lưu SharedPreferences trong file XML thuần tại thư mục ứng dụng. Khi người dùng bật tính năng Backup ADB (`adb backup`) hoặc sử dụng thiết bị đã Root, token này có thể bị trích xuất dễ dàng.
* **Khuyến nghị nâng cấp:** Sử dụng `flutter_secure_storage`:
  * Trên Android: Tự động mã hóa AES bằng khóa lưu trong Hardware Keystore.
  * Trên iOS: Lưu an toàn trong Keychain với cờ `kSecAttrAccessibleAfterFirstUnlock`.

---

### 2.3. Đối soát luồng Thanh toán & Giao dịch (Client vs Backend Trust Boundary)
* **Nguyên tắc vàng:** *Không bao giờ tin tưởng dữ liệu kiểm tra từ phía Client.*
* **Đánh giá luồng Nạp tiền VietQR:**
  * **Điểm tốt:** Ứng dụng chỉ nhận URL mã QR và TransactionCode từ Server, việc kiểm tra tiền vào tài khoản thực tế được Backend xử lý thông qua Webhook / Bank API. Client chỉ hiển thị giao diện hướng dẫn chuyển khoản.
* **Đánh giá luồng Đặt cọc thuê xe:**
  * Client gửi `BookingRequestEntity` lên Server.
  * **Cần lưu ý ở Backend:** Backend phải độc lập tính toán lại tổng tiền thuê dựa trên giá gốc của xe trong Database (`pricePerDay * days`), tuyệt đối không nhận trường tổng tiền do Client tự tính gửi lên để tránh gian lận sửa giá gói tin HTTP.

---

### 2.4. Rò rỉ thông tin qua Log (Information Exposure through Logs)
* Tại `BookingRemoteDataSourceImpl:178`:
  ```dart
  debugPrint('[BookingRemoteDataSource][checkVerified] auth=${authHeader ?? "[none]"}');
  ```
  Token JWT đầy đủ được in ra console trong chế độ Debug. Cần đảm bảo hàm này chỉ in 6 ký tự đầu và cuối của Token để tránh lộ credential trong môi trường kiểm thử chia sẻ log:
  ```dart
  debugPrint('auth=${authHeader != null ? "${authHeader.substring(0, 15)}..." : "[none]"}');
  ```
