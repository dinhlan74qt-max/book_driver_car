# BÁO CÁO ĐỀ XUẤT ĐỀ TÀI VÀ ĐẶC TẢ YÊU CẦU NGHIỆP VỤ

**HỌC PHẦN:** ĐỒ ÁN CHUYÊN NGÀNH  
**TÊN ĐỀ TÀI:** XÂY DỰNG ỨNG DỤNG DI ĐỘNG CHO THUÊ XE TỰ LÁI VÀ KẾT NỐI CHỦ XE THÔNG MINH (CARNOW)  
**NỀN TẢNG THỰC HIỆN:** FLUTTER (MOBILE APP) & JAVA SPRING BOOT, MYSQL BACKEND  

---

## PHẦN I. ĐỀ XUẤT ĐỀ TÀI (PROJECT PROPOSAL)

### 1.1. Tính cấp thiết của đề tài (Lý do chọn đề tài)
Trong bối cảnh nền kinh tế chia sẻ (Sharing Economy) phát triển mạnh mẽ và nhu cầu du lịch, trải nghiệm cá nhân hóa ngày càng tăng cao tại Việt Nam:
1. **Nhu cầu thuê xe tự lái tăng trưởng nhanh:** Khách hàng, đặc biệt là giới trẻ và các gia đình, có xu hướng muốn tự chủ lịch trình, yêu thích trải nghiệm cầm lái các dòng xe đời mới (đặc biệt là làn sóng xe điện VinFast, SUV thông minh) thay vì đi tour hoặc thuê xe có tài xế.
2. **Nguồn lực phương tiện nhàn rỗi lớn:** Nhiều chủ sở hữu ô tô cá nhân không sử dụng xe thường xuyên trong tuần. Họ có nhu cầu cho thuê xe an toàn để tạo thêm dòng tiền bù đắp chi phí bảo dưỡng, gửi xe và khấu hao phương tiện.
3. **Bất cập của mô hình thuê xe truyền thống:**
   - Thủ tục phức tạp: Đòi hỏi giữ lại sổ hộ khẩu giấy, giấy chứng nhận quyền sử dụng đất hoặc tiền mặt đặt cọc lớn.
   - Hợp đồng thủ công: Hợp đồng giấy dễ thất lạc, thiếu tính ràng buộc pháp lý số hóa tức thời.
   - Khó khăn trong thanh toán & quản lý lịch trình: Không có nền tảng trung gian bảo đảm quyền lợi tài chính cho cả hai bên khi xảy ra hủy chuyến hoặc sự cố kỹ thuật.

Chính vì vậy, đề tài **"Xây dựng ứng dụng di động cho thuê xe tự lái và kết nối chủ xe thông minh - CarNow"** được đề xuất nhằm giải quyết trọn vẹn bài toán kết nối cung - cầu, số hóa toàn diện từ quy trình định danh, đặt xe, ký hợp đồng điện tử đến thanh toán ví nội bộ.

---

### 1.2. Mục tiêu của đề tài

#### Mục tiêu tổng quát:
Xây dựng một hệ sinh thái ứng dụng di động hoàn chỉnh trên nền tảng Android/iOS, đóng vai trò là sàn giao dịch trung gian kết nối người thuê xe (Renter) và chủ sở hữu xe (Car Owner) một cách an toàn, minh bạch và nhanh chóng.

#### Mục tiêu cụ thể:
1. **Số hóa thủ tục xác thực danh tính (eKYC):** Kiểm duyệt trực tuyến CCCD gắn chip và Giấy phép lái xe (GPLX) đảm bảo người thuê đủ điều kiện pháp lý điều khiển xe.
2. **Ký kết hợp đồng điện tử hai bên (Digital Signature):** Tích hợp công nghệ tạo tài liệu PDF pháp lý và vùng chữ ký số cảm ứng cho cả Bên thuê (Bên B) và Chủ xe (Bên A) ngay trên điện thoại.
3. **Tích hợp Ví điện tử nội bộ (E-Wallet & VietQR):** Hỗ trợ nạp tiền tự động qua mã VietQR NAPAS 24/7, tự động khấu trừ đặt cọc, giải ngân doanh thu và hỗ trợ rút tiền về ngân hàng.
4. **Theo dõi và quản lý hành trình lăn bánh:** Hiển thị trạng thái xe theo thời gian thực, đếm ngược thời hạn trả xe, hỗ trợ liên lạc trực tiếp và cứu hộ khẩn cấp 24/7.
5. **Định hướng phát triển Trí tuệ nhân tạo (AI Engine):** Đặt nền tảng kiến trúc sẵn sàng để tích hợp Module AI tìm kiếm và đề xuất xe thông minh dựa trên ngôn ngữ tự nhiên (NLP) và lịch sử hành vi của người dùng trong giai đoạn hoàn thiện đồ án.

---

### 1.3. Đối tượng và phạm vi nghiên cứu

* **Đối tượng nghiên cứu:**
  - Quy trình nghiệp vụ vận hành của thị trường cho thuê xe tự lái.
  - Các quy định pháp luật về giao dịch điện tử, hợp đồng dân sự thuê tài sản tại Việt Nam.
  - Quy trình định danh điện tử eKYC và các cổng thanh toán QR code liên ngân hàng.
  - Công nghệ lập trình đa nền tảng Flutter và kiến trúc Clean Architecture.
* **Phạm vi ứng dụng:**
  - Triển khai ứng dụng di động cho hai nhóm tác nhân chính: Khách thuê xe và Chủ xe.
  - Hỗ trợ mạng lưới tìm kiếm và định vị xe tại 63 tỉnh thành trên toàn quốc.

---

### 1.4. Công nghệ và kiến trúc dự kiến áp dụng

* **Frontend Mobile:**
  - Ngôn ngữ & Framework: **Dart / Flutter** (hỗ trợ đồng thời Android và iOS).
  - Quản lý trạng thái (State Management): **BLoC / Cubit Pattern**.
  - Kiến trúc ứng dụng: **Clean Architecture** (Presentation, Domain, Data layers) kết hợp Dependency Injection (`get_it`).
  - Xử lý tài liệu và chữ ký: Thư viện `pdf`, `printing`, `signature`.
  - Phông chữ & Giao diện: Thiết kế chuẩn Google Design, Google Fonts (`Sora`, `Inter`, `JetBrains Mono`).
* **Backend & Cơ sở dữ liệu:**
  - Ngôn ngữ & Framework: **Java (Spring Boot Framework)**.
  - Kiến trúc Backend: **Layered Architecture (Controller - Service - Repository)** cung cấp hệ thống RESTful API chuẩn hóa.
  - Quản lý truy xuất dữ liệu (ORM): **Spring Data JPA / Hibernate** ánh xạ tự động các thực thể nghiệp vụ (User, Vehicle, Booking, Contract, Wallet...).
  - Cơ sở dữ liệu: **Hệ quản trị CSDL quan hệ MySQL (MySQL Server)**, hỗ trợ giao dịch ACID nghiêm ngặt bảo đảm tính chính xác khi xử lý tiền cọc, số dư ví và trạng thái xe.
  - Bảo mật & Phân quyền: **Spring Security kết hợp JSON Web Token (JWT)**, kiểm soát truy cập phân quyền chặt chẽ giữa Khách thuê (ROLE_USER/RENTER), Chủ xe (ROLE_OWNER) và Quản trị viên (ROLE_ADMIN).
* **Định hướng tích hợp AI (Future Extension):**
  - Tích hợp mô hình AI (Large Language Model / Embedding) cho tính năng **"AI Smart Vehicle Search"**: Người dùng nhập câu lệnh tự nhiên (Ví dụ: *"Tìm xe 7 chỗ gầm cao đi Đà Lạt cùng gia đình 3 ngày cuối tuần, giá dưới 1.5 triệu/ngày"*), hệ thống tự động trích xuất thuộc tính (seats: 7, type: SUV/crossover, budget <= 1.5M, location: Đà Lạt) và xếp hạng xe phù hợp nhất.

---

### 1.5. Kế hoạch triển khai đề tài

| Giai đoạn | Nội dung thực hiện | Kết quả dự kiến |
| :--- | :--- | :--- |
| **Giai đoạn 1** | Khảo sát nhu cầu, phân tích nghiệp vụ, thiết kế Wireframe/Figma UI/UX. | Báo cáo đặc tả nghiệp vụ, bộ thiết kế giao diện hoàn chỉnh (Figma). |
| **Giai đoạn 2** | Xây dựng Core Framework Flutter, Clean Architecture, BLoC, màn hình Auth & eKYC. | Hoàn thành module xác thực người dùng, quét/nhập giấy tờ CCCD, GPLX. |
| **Giai đoạn 3** | Xây dựng chức năng Tìm kiếm xe, Chi tiết xe, Bộ lọc, DatePicker, Đặt cọc. | Hoàn thiện luồng duyệt và đặt xe từ phía khách hàng. |
| **Giai đoạn 4** | Phát triển Hợp đồng điện tử, Chữ ký số 2 bên, Hệ thống Ví điện tử VietQR. | Hoàn thành việc ký hợp đồng xuất PDF, nạp/rút tiền qua Ví. |
| **Giai đoạn 5** | Xây dựng phân hệ Quản lý đội xe cho Chủ xe, Quản lý đơn thuê, Đánh giá 5 sao. | Hoàn thiện đầy đủ hai chiều tương tác giữa Khách và Chủ xe. |
| **Giai đoạn 6** | Nghiên cứu và tích hợp Module AI Tìm kiếm xe thông minh, tối ưu hóa và đóng gói. | Sản phẩm hoàn chỉnh sẵn sàng báo cáo hội đồng tốt nghiệp/đồ án. |

---

## PHẦN II. ĐẶC TẢ YÊU CẦU NGHIỆP VỤ (BUSINESS REQUIREMENTS)

### 2.1. Phân loại Tác nhân hệ thống (System Actors)

1. **Khách thuê xe (Renter):** Người có nhu cầu tìm kiếm, đặt thuê xe tự lái phục vụ công tác, du lịch.
2. **Chủ sở hữu xe (Car Owner):** Người sở hữu ô tô nhàn rỗi, muốn đăng ký đưa xe lên sàn CarNow để kinh doanh cho thuê.
3. **Quản trị viên (Admin):** Kiểm duyệt thông tin xe đăng ký mới, thẩm định hồ sơ định danh eKYC, xử lý tranh chấp và khiếu nại.

---

### 2.2. Yêu cầu nghiệp vụ chi tiết theo từng phân hệ

#### 📌 Phân hệ 1: Xác thực & Định danh người dùng (Authentication & eKYC)
* **YC-01.1 (Đăng ký / Đăng nhập):** Hỗ trợ đăng ký tài khoản qua số điện thoại/email, thiết lập mật khẩu bảo mật và xác minh qua mã OTP 6 số gửi về thiết bị.
* **YC-01.2 (Quy trình xác minh danh tính eKYC):**
  - Khách thuê và chủ xe bắt buộc phải hoàn tất xác minh trước khi phát sinh giao dịch.
  - Quy trình gồm các bước:
    1. Nhập thông tin cơ bản: Họ tên, Ngày sinh, Số CCCD, Địa chỉ thường trú.
    2. Chụp/tải lên ảnh CCCD gắn chip (Mặt trước & Mặt sau).
    3. Cung cấp thông tin Giấy phép lái xe: Số bằng, Hạng (B1, B2, C...), Ngày cấp, Hạn sử dụng, Ảnh 2 mặt GPLX.
    4. Chụp ảnh chân dung khuôn mặt (Selfie) đối khớp dữ liệu.
    5. Cung cấp số điện thoại người liên hệ khẩn cấp (Người thân).
    6. Đọc và tích chọn cam kết tuân thủ quy chế an toàn giao thông.
* **YC-01.3 (Quản lý hồ sơ cá nhân):** Xem thông tin cá nhân, kiểm tra huy hiệu trạng thái `ĐÃ XÁC THỰC` (KYC Verified), đổi avatar nhận diện, đổi mật khẩu và đăng xuất an toàn.

---

#### 📌 Phân hệ 2: Khám phá & Tìm kiếm xe (Car Discovery & Search)
* **YC-02.1 (Trang chủ thông minh):**
  - Hiển thị thanh tìm kiếm nhanh theo địa điểm và thời gian.
  - Các thống kê nhanh về hệ thống (500+ xe sẵn sàng, độ phủ 63 tỉnh thành).
  - Danh mục các dòng xe nổi bật, xe điện đời mới, xe tiết kiệm nhiên liệu.
* **YC-02.2 (Tìm kiếm theo tỉnh thành):** Cho phép người dùng duyệt và chọn nhanh xe đang có sẵn tại 63 tỉnh/thành phố trên toàn quốc với giao diện lọc trực quan.
* **YC-02.3 (Bộ lọc nâng cao):** Lọc xe đa tiêu chí:
  - Hãng xe (VinFast, Toyota, Mazda, Hyundai, Kia, Honda...).
  - Số chỗ ngồi (4 chỗ, 5 chỗ, 7 chỗ).
  - Loại nhiên liệu (Xăng, Dầu Diesel, Động cơ Điện).
  - Hộp số (Số tự động AT, Số sàn MT).
  - Khoảng giá thuê / ngày (Tối thiểu - Tối đa).
* **YC-02.4 (Tính năng định hướng AI - AI Smart Vehicle Search):**
  - Cho phép người dùng nhập ngôn ngữ tự nhiên: *"Tìm xe 5 chỗ số tự động, gầm cao tiết kiệm xăng ở Quận 7 trong 2 ngày cuối tuần"*.
  - AI phân tích câu lệnh, tự động gán bộ lọc và xếp hạng những xe phù hợp nhất kèm lời giải thích đề xuất.

---

#### 📌 Phân hệ 3: Chi tiết xe & Quy trình Đặt xe (Car Detail & Booking Flow)
* **YC-03.1 (Xem chi tiết phương tiện):**
  - Bộ sưu tập hình ảnh ngoại thất, nội thất xe thực tế.
  - Bảng thông số kỹ thuật chi tiết: Động cơ, mức tiêu hao nhiên liệu, tính năng an toàn (ABS, Camera 360, Cảm biến áp suất lốp, v.v.).
  - Hồ sơ chủ xe: Tên chủ xe, đánh giá sao uy tín, số chuyến đã thực hiện thành công.
  - Các điều khoản, quy định nhận xe và phụ phí (vượt km, rửa xe, trễ giờ).
* **YC-03.2 (Chọn lịch trình thuê xe):**
  - Chọn ngày/giờ nhận xe và ngày/giờ trả xe qua giao diện Lịch trực quan.
  - Hệ thống tự động tính toán số ngày thuê và tổng chi phí thuê tương ứng.
* **YC-03.3 (Tóm tắt đặt xe & Xác nhận đặt cọc):**
  - Hiển thị bảng kê chi phí minh bạch: Tiền thuê xe, phí dịch vụ sàn, tiền đặt cọc trách nhiệm.
  - Nhập ghi chú giao nhận xe cho chủ xe.
* **YC-03.4 (Kiểm tra số dư và Xử lý thanh toán cọc):**
  - **Trường hợp đủ tiền:** Khấu trừ tiền cọc từ số dư Ví CarNow và chuyển sang bước ký hợp đồng.
  - **Trường hợp không đủ tiền:** Hiển thị màn hình thông báo cảnh báo `Số dư Ví không đủ`, chỉ rõ số tiền cần nạp thêm và cung cấp lối tắt nạp tiền nhanh qua VietQR.

---

#### 📌 Phân hệ 4: Hợp đồng thuê xe điện tử & Chữ ký số (Digital Contract & Signature)
* **YC-04.1 (Tạo hợp đồng điện tử tự động):**
  - Hệ thống tự động tổng hợp thông tin Bên cho thuê (Bên A), Bên thuê (Bên B), thông số xe, biển kiểm soát, thời gian thuê và giá trị giao dịch vào mẫu hợp đồng chuẩn pháp lý.
* **YC-04.2 (Khách thuê ký hợp đồng - Bên B):**
  - Khách thuê đọc các điều khoản và thực hiện ký chữ ký điện tử trực tiếp trên màn hình cảm ứng điện thoại trước khi đơn được gửi đi.
* **YC-04.3 (Chủ xe duyệt và ký hợp đồng - Bên A):**
  - Chủ xe nhận được thông báo yêu cầu thuê xe kèm tài liệu hợp đồng đã có chữ ký Bên B.
  - Chủ xe kiểm tra lại lịch trình, ký tên xác nhận duyệt đơn (Approve) hoặc từ chối (Reject).
* **YC-04.4 (Lưu trữ và xuất văn bản PDF):**
  - Khi cả hai bên ký thành công, hệ thống tự động kết xuất tệp PDF hợp đồng hoàn chỉnh (chứa cả 2 chữ ký số) và cấp mã số hợp đồng lưu trữ trên hệ thống.

---

#### 📌 Phân hệ 5: Quản lý Chuyến đi & Đánh giá (Trip Management & Rating)
* **YC-05.1 (Theo dõi trạng thái đơn thuê):** Quản lý danh sách các chuyến đi theo các tab trạng thái rõ ràng:
  - `CHỜ DUYỆT (PENDING)`: Chờ chủ xe phản hồi xác nhận.
  - `ĐÃ DUYỆT (APPROVED)`: Chủ xe đã ký hợp đồng, sẵn sàng nhận bàn giao xe.
  - `ĐANG THUÊ (RENTING / ONGOING)`: Khách đã nhận xe và đang trong hành trình di chuyển.
  - `HOÀN THÀNH (COMPLETED)`: Xe đã được trả an toàn, thanh quyết toán xong.
  - `ĐÃ HỦY (CANCELLED / REJECTED)`: Đơn bị hủy bởi khách hoặc bị từ chối bởi chủ xe.
* **YC-05.2 (Chính sách hủy đơn minh bạch):**
  - Cho phép khách hủy miễn phí 100% khi đơn ở trạng thái *Chờ duyệt*.
  - Khấu trừ 10% phí hủy khi đơn đã được chủ xe *Đã duyệt*.
  - Khóa quyền hủy khi đơn đang ở trạng thái *Đang thuê*.
* **YC-05.3 (Màn hình hành trình đang lăn bánh):**
  - Đồng hồ đếm ngược thời gian còn lại của chuyến đi.
  - Nút gọi điện thoại liên lạc trực tiếp với Chủ xe.
  - Nút khẩn cấp gọi tổng đài Cứu hộ đường bộ 24/7 (SOS CarNow).
* **YC-05.4 (Đánh giá & Chấm điểm 5 sao):**
  - Sau khi chuyến đi hoàn tất, khách thuê đánh giá sao (1 - 5 sao).
  - Chọn các nhãn nhận xét nhanh (*Xe sạch thơm, Chủ xe thân thiện, Nhận xe đúng hẹn, Pin/xăng đầy đủ...*) và viết nhận xét chi tiết kèm ảnh chụp thực tế.

---

#### 📌 Phân hệ 6: Quản lý Đội xe dành cho Chủ xe (Vehicle Fleet Management)
* **YC-06.1 (Quản lý danh sách xe cá nhân):** Xem danh sách tất cả các xe đang cho thuê, trạng thái hoạt động (*Sẵn sàng cho thuê, Đang có khách thuê, Đang bảo dưỡng*).
* **YC-06.2 (Đăng ký xe mới lên sàn):**
  - Biểu mẫu nhập chi tiết: Hãng xe, Model, Năm sản xuất, Biển kiểm soát, Màu sắc, Số chỗ ngồi, Loại nhiên liệu, Hộp số, Mức giá thuê đề xuất / ngày.
  - Thiết lập địa chỉ nhận xe (Phường/Xã, Quận/Huyện, Tỉnh/Thành phố).
* **YC-06.3 (Thỏa thuận đăng ký xe 8 điều khoản):**
  - Chủ xe bắt buộc đọc và tích chọn xác nhận 8 điều khoản cam kết pháp lý (Quyền sở hữu hợp pháp, tính xác thực của giấy tờ, đồng ý mức phí dịch vụ sàn 5%, cam kết bảo dưỡng an toàn...).
  - Ký chữ ký điện tử xác nhận thỏa thuận đưa xe lên sàn.
* **YC-06.4 (Báo cáo doanh thu & Lịch sử nhận đơn):** Xem thống kê số cuốc xe thành công, tổng doanh thu thực nhận và các yêu cầu đặt xe đang chờ xử lý.

---

#### 📌 Phân hệ 7: Ví điện tử CarNow & Quản lý Giao dịch (E-Wallet & Payments)
* **YC-07.1 (Quản lý số dư ví):**
  - Hiển thị số dư khả dụng theo phong cách thẻ sang trọng (Luxury Card).
  - Trạng thái liên kết ví nội bộ an toàn.
* **YC-07.2 (Nạp tiền tự động qua VietQR):**
  - Hỗ trợ chọn nhanh các mệnh giá nạp (100.000đ, 200.000đ, 500.000đ, 1.000.000đ) hoặc tự nhập số tiền bất kỳ.
  - Tự động sinh mã VietQR chuẩn chuyển khoản liên ngân hàng 24/7 kèm mã giao dịch tự động nhận diện tiền vào ví.
  - Màn hình thông báo Nạp tiền thành công và cộng số dư tức thì.
* **YC-07.3 (Rút tiền về tài khoản ngân hàng):**
  - Khách thuê hoặc chủ xe có thể gửi yêu cầu rút tiền về ngân hàng thụ hưởng (Tên ngân hàng, Số tài khoản, Tên chủ tài khoản, Số tiền rút).
* **YC-07.4 (Lịch sử giao dịch & Biên lai điện tử):**
  - Phân loại rõ ràng biến động số dư: Tiền vào màu xanh `+` (Nạp tiền, Hoàn tiền cọc, Nhận tiền thuê) và tiền ra màu đỏ `-` (Thanh toán cọc, Rút tiền).
  - Chạm vào từng giao dịch để xem biên lai chi tiết: Mã giao dịch, thời gian, số dư sau giao dịch, phí sàn 0đ và nút chia sẻ biên lai.

---

### 2.3. Yêu cầu phi chức năng (Non-Functional Requirements)

1. **Tính bảo mật (Security):**
   - Mật khẩu người dùng được mã hóa một chiều an toàn (BCrypt/Argon2).
   - Xác thực phiên làm việc qua cơ chế JWT (JSON Web Token) với thời gian hết hạn và cơ chế tự làm mới (Refresh Token).
   - Bảo mật tài liệu eKYC: Ảnh chụp CCCD và GPLX được lưu trữ riêng tư, phân quyền truy cập nghiêm ngặt.
2. **Hiệu năng và độ tin cậy (Performance & Reliability):**
   - Thời gian phản hồi của các thao tác tìm kiếm, lọc xe dưới 2 giây.
   - Thao tác ký tên số và render tệp PDF hợp đồng xử lý mượt mà trên thiết bị di động, không gây giật lag (sử dụng luồng xử lý nền Isolate).
3. **Tính tiện dụng & Giao diện (Usability & UI/UX):**
   - Giao diện thiết kế theo chuẩn Dark/Light Luxury Automotive, tông màu chủ đạo Xanh Navy `#1B4F72` và Cam Hổ Phách `#FF7A00`.
   - Bố cục màn hình tối ưu hóa chuẩn tỷ lệ điện thoại thông minh hiện đại (390 x 844px), hỗ trợ Dark mode sang trọng ở các màn hình tìm kiếm xe.
4. **Khả năng bảo trì và mở rộng (Maintainability & Extensibility):**
   - Áp dụng cấu trúc Clean Architecture chuẩn hóa giúp dễ dàng bảo trì và bổ sung các tính năng nâng cao trong tương lai (đặc biệt là Module gợi ý xe thông minh bằng Trí tuệ nhân tạo AI).

