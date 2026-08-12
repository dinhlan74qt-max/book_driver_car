# BẢNG TỔNG HỢP CÁC FILE ĐÃ TỐI ƯU & CHỨC NĂNG TỪNG FILE

Tài liệu này mô tả chi tiết kiến trúc thư mục mới, danh sách các file đã được tái cấu trúc (refactor), tách nhỏ (modularize) và chức năng cụ thể của từng thành phần trong dự án.

---

## 1. 🛡️ Module Profile: Xác Minh Danh Tính (KYC - Identity Verification)
Thư mục: `lib/features/profile/presentation/view/identity_verification/`

| Đường dẫn File | Loại | Chức năng chính |
| :--- | :--- | :--- |
| **`identity_verification_screen.dart`** | **Màn hình Host** | Quản lý Controller, State máy (6 bước), kiểm tra hợp lệ dữ liệu (validation), tự động tính tuổi, kiểm tra hạn GPLX và gọi API nộp hồ sơ xác minh KYC. |
| **`widgets/verification_step_indicator.dart`** | **Widget UI** | Hiển thị thanh tiến trình 6 bước có thể bấm chuyển bước nhanh, hiển thị icon tick xanh khi bước hợp lệ hoặc viền sáng cho bước hiện tại. |
| **`widgets/verification_image_picker_box.dart`** | **Widget UI** | Khung chụp và chọn ảnh giấy tờ (mặt trước / sau). Hiển thị icon CCCD/GPLX làm watermark nền, badge camera và preview ảnh sau khi chọn. |
| **`widgets/step1_basic_info_section.dart`** | **Widget UI (Bước 1)** | Nhập họ tên, ngày sinh (có DatePicker), số CCCD, địa chỉ thường trú. Tự động cảnh báo nếu người dùng dưới 21 tuổi. |
| **`widgets/step2_cccd_section.dart`** | **Widget UI (Bước 2)** | Khu vực tải / chụp 2 mặt Căn cước công dân (Mặt trước + Mặt sau). |
| **`widgets/step3_driver_license_section.dart`** | **Widget UI (Bước 3)** | Nhập thông tin Giấy phép lái xe: Số bằng lái, hạng xe (B1, B2, C,...), ngày cấp, ngày hết hạn (tự động cảnh báo bằng hết hạn) và tải 2 mặt bằng lái. |
| **`widgets/step4_selfie_section.dart`** | **Widget UI (Bước 4)** | Hướng dẫn và khu vực chụp ảnh selfie chân dung khuôn mặt cầm CCCD chính chủ. |
| **`widgets/step5_emergency_contact_section.dart`** | **Widget UI (Bước 5)** | Form nhập thông tin người liên hệ khẩn cấp (Họ tên, số điện thoại, mối quan hệ: Bố/Mẹ, Vợ/Chồng, Anh/Chị,...). |
| **`widgets/step6_agreement_section.dart`** | **Widget UI (Bước 6)** | Bảng tóm tắt toàn bộ hồ sơ đã điền để người dùng rà soát lần cuối trước khi tích chọn cam kết điều khoản và nộp hồ sơ. |

---

## 2. 📋 Module Profile: Quản Lý Đơn Thuê Của Chủ Xe (Owner Booking)
Thư mục: `lib/features/profile/presentation/view/owner_booking/`

| Đường dẫn File | Loại | Chức năng chính |
| :--- | :--- | :--- |
| **`owner_booking_list_screen.dart`** | **Màn hình Host** | Hiển thị danh sách các đơn đặt thuê xe của chủ xe. Tích hợp thanh tìm kiếm real-time theo tên khách/tên xe, bộ lọc trạng thái và kéo để làm mới (Pull-to-refresh). |
| **`owner_booking_detail_screen.dart`** | **Màn hình Chi tiết** | Xem toàn bộ chi tiết 1 đơn thuê (Thông tin khách hàng, lịch trình nhận/trả, thông số xe, tổng tiền, các nút duyệt đơn / hủy đơn / hoàn thành). |
| **`widgets/owner_booking_kpi_banner.dart`** | **Widget UI** | Banner thống kê số liệu nhanh: Tổng số đơn, số đơn đang chờ duyệt, và tổng doanh thu ước tính của chủ xe. |
| **`widgets/owner_booking_order_card.dart`** | **Widget UI** | Thẻ đơn hàng (Order Card) hiển thị ảnh xe, mã đơn, tên xe, tên khách thuê, ngày thuê, tổng tiền và badge trạng thái có màu tương ứng. |
| **`widgets/owner_booking_filter_chip.dart`** | **Widget UI** | Nút bấm dạng Filter Chip để lọc đơn theo trạng thái (Tất cả, Chờ duyệt, Đã duyệt, Đang thuê, Hoàn thành, Đã hủy). |
| **`widgets/owner_booking_empty_state.dart`** | **Widget UI** | Giao diện thông báo khi danh sách đơn trống hoặc không tìm thấy kết quả phù hợp với từ khóa tìm kiếm. |
| **`widgets/owner_booking_shimmer_loading.dart`** | **Widget UI** | Hiệu ứng khung xương (Shimmer Skeleton Loading) mượt mà trong lúc tải dữ liệu đơn hàng từ server. |

---

## 3. 🚗 Module Profile: Quản Lý Phương Tiện Của Chủ Xe (Vehicle Management)
Thư mục: `lib/features/profile/presentation/view/vehicle_management/`

| Đường dẫn File | Loại | Chức năng chính |
| :--- | :--- | :--- |
| **`rental_management_screen.dart`** | **Màn hình Hub** | Màn hình trung tâm quản lý hoạt động cho thuê xe của chủ xe (truy cập danh sách xe đã đăng, đơn thuê, thống kê). |
| **`vehicle_registration_screen.dart`** | **Màn hình Form** | Form đăng ký xe mới lên hệ thống (thông tin xe, đăng ký, đăng kiểm, bảo hiểm, hình ảnh xe, biểu giá thuê). |
| **`owner_registered_vehicles_screen.dart`** | **Màn hình Danh sách**| Danh sách toàn bộ xe mà người dùng đã đăng ký lên nền tảng cùng trạng thái duyệt xe. |
| **`vehicle_detail_screen.dart`** | **Màn hình Chi tiết** | Xem chi tiết cấu hình, tình trạng kỹ thuật và lịch trình của 1 xe cụ thể. |

---

## 4. 🏠 Module Home: Trang Chủ & Chi Tiết Xe (Home & Car Detail)
Thư mục: `lib/features/home/presentation/view/`

### 4.1. Phân hệ Trang chủ (`home/`):
| Đường dẫn File | Loại | Chức năng chính |
| :--- | :--- | :--- |
| **`home/home_screen.dart`** | **Màn hình Chính** | Trang chủ ứng dụng. Hiển thị lời chào cá nhân hóa, Hero Banner khuyến mãi, danh sách xe gần bạn, xe đề xuất và thanh tìm kiếm nhanh. |

### 4.2. Phân hệ Chi tiết xe (`car_detail/`):
| Đường dẫn File | Loại | Chức năng chính |
| :--- | :--- | :--- |
| **`car_detail/car_detail_screen.dart`** | **Màn hình Chi tiết** | Hiển thị toàn bộ thông tin chi tiết xe (Gallery ảnh, giá thuê, thông số kỹ thuật, đánh giá từ khách hàng, chủ xe, điều khoản thuê, và nút Đặt xe). |
| **`car_detail/widgets/car_detail_header_widgets.dart`** | **Widget UI** | Cung cấp nền Gradient cao cấp (`LuxuryCarDetailBackground`), hiệu ứng phát sáng mờ (`LuxuryGlow`), nút Glassmorphism trong suốt (`GlassIconButton`) và tiêu đề từng mục (`SectionTitle`). |
| **`car_detail/widgets/car_detail_date_picker_sheet.dart`** | **Widget UI** | Bottom Sheet hiển thị lịch trực quan 3 tháng tiếp theo. Tự động đánh dấu và khóa các ngày đã có người đặt trước từ server, hỗ trợ chọn khoảng ngày thuê linh hoạt. |
| **`car_detail/widgets/car_detail_booking_modal_sheet.dart`** | **Widget UI** | Modal xác nhận đặt xe: tính toán chi tiết số ngày, tổng tiền, ô nhập ghi chú cho chủ xe và gửi yêu cầu đặt xe lên Backend API. |

### 4.3. Phân hệ Tìm kiếm & Lọc xe (`search/`):
| Đường dẫn File | Loại | Chức năng chính |
| :--- | :--- | :--- |
| **`search/search_results_screen.dart`** | **Màn hình Kết quả** | Hiển thị kết quả tìm kiếm xe theo bộ lọc nâng cao (Hãng xe, mẫu xe, loại xe, mức giá, địa điểm). |
| **`search/city_search_screen.dart`** | **Màn hình Tìm kiếm tỉnh/thành** | Cho phép tìm kiếm xe nhanh theo các tỉnh thành phố trên toàn quốc (Hà Nội, TP.HCM, Đà Nẵng,...). |
| **`search/city_cars_result_screen.dart`** | **Màn hình Kết quả theo tỉnh** | Hiển thị danh sách các xe có sẵn để thuê tại 1 thành phố cụ thể được chọn. |
| **`search/all_cars_screen.dart`** | **Màn hình Toàn bộ xe** | Hiển thị danh sách tất cả các xe khả dụng trên toàn bộ hệ thống. |

---

## 5. 🔗 Các file điều hướng và chia sẻ dùng chung được cập nhật
| Đường dẫn File | Nội dung cập nhật |
| :--- | :--- |
| **`lib/shared/widget/bottom_navigation_bar.dart`** | Cập nhật đường dẫn import màn hình `HomeScreen` theo kiến trúc thư mục mới. |
| **`lib/features/splash/presentation/view/splash_screen.dart`** | Cập nhật import `HomeScreen` sau khi hoàn tất kiểm tra trạng thái đăng nhập. |
| **`lib/features/home/presentation/widget/home_car_section.dart`** | Cập nhật import `CarDetailScreen` khi người dùng bấm vào 1 thẻ xe ở trang chủ. |
| **`lib/features/profile/presentation/view/profile_screen.dart`** | Cập nhật import điều hướng sang các sub-folders `identity_verification`, `owner_booking`, `vehicle_management`. |

---

## 🌟 Tóm tắt giá trị kiến trúc mới mang lại:
- **Clean Architecture:** Tách biệt rõ ràng giữa Presentation Screen (State Machine / Controller) và Presentation Widget (Pure UI Components).
- **Kích thước file chuẩn:** Không còn file nào vượt quá 1000 - 1800 dòng. Mỗi file dao động từ 80 - 400 dòng, cực kỳ dễ đọc, kiểm thử và bảo trì.
- **Tái sử dụng cao:** Các widget như DatePicker, ImagePicker, KPI Banner, Shimmer có thể dễ dàng tái sử dụng hoặc tùy biến mà không làm ảnh hưởng màn hình chính.
