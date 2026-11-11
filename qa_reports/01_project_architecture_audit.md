# 01. BÁO CÁO KIỂM TOÁN KIẾN TRÚC DỰ ÁN (PROJECT ARCHITECTURE AUDIT)

**Dự án:** CarNow Mobile App (`book_drive_car`)  
**Nền tảng:** Flutter 3.x / Dart 3.12+  
**Kiến trúc chủ đạo:** Clean Architecture kết hợp BLoC/Cubit Pattern  
**Vai trò:** Senior QA Engineer & Software Test Architect  
**Ngày thực hiện kiểm toán:** 11/11/2026  

---

## 1. TỔNG QUAN CẤU TRÚC KHO NGUỒN (REPOSITORY STRUCTURE)

Dự án được phân chia thành 4 khu vực chính trong thư mục `lib/`:
```text
lib/
├── core/                  # Hạ tầng dùng chung cốt lõi (DI, Storage, Theme, Helpers, Utils)
│   ├── di/                # Dependency Injection (GetIt & Injectable)
│   ├── helper/            # Formatters, Validators, Location, Media Picker & Cropper
│   ├── storage/           # UserLocalStorage (SharedPreferences)
│   ├── theme/             # ThemeController, AppColors, AppTypography, Ripple Transitions
│   └── utils/             # ResponsiveUtils
├── features/              # Các Module chức năng nghiệp vụ (Feature-Driven Clean Architecture)
│   ├── ai_assistant/      # Trợ lý AI hỏi đáp xe và chính sách thuê
│   ├── auth/              # Xác thực người dùng (Login, Register, OTP Verification)
│   ├── favorite/          # Quản lý danh sách xe yêu thích
│   ├── home/              # Khám phá, Tìm kiếm, Đặt lịch xe, Ký hợp đồng điện tử
│   ├── onboarding/        # Giới thiệu ứng dụng đa slide
│   ├── profile/           # Quản lý hồ sơ, KYC CCCD, Quản lý xe chủ xe & duyệt đơn
│   ├── rental/            # Quản lý chuyến thuê của Renter, Hủy chuyến, Xem hợp đồng
│   ├── splash/            # Màn hình Splash khởi động & định tuyến session
│   ├── wallet/            # Ví điện tử CarNow Pay (Số dư, Nạp VietQR, Rút tiền ngân hàng)
│   └── welcome/           # Màn hình chào mừng ban đầu
├── shared/                # Thành phần UI & Services tái sử dụng giữa các feature
│   ├── constants/         # ApiConstants, AppKeys
│   ├── services/          # CarQuery API, Province Open API
│   └── widget/            # AppButton, AppCard, AppToast, AppStatusBadge, BottomNavigationBar
└── test/ (trong lib/)     # Thư mục chứa 14 file Unit, Widget và BLoC Tests
```

---

## 2. ĐÁNH GIÁ CHI TIẾT TỪNG TẦNG KIẾN TRÚC (CLEAN ARCHITECTURE ASSESSMENT)

### 2.1. Phân chia trách nhiệm giữa các Layer (Layer Separation)
* **Domain Layer (Entities & Use Cases):**
  * Đạt chuẩn: Các Entity kế thừa `Equatable` hoặc POJO thuần túy, không bị phụ thuộc vào UI hay thư viện bên thứ 3.
  * Các Use Case (`Login`, `CreateBooking`, `GetMyWallet`, `Withdraw`, `CancelBooking`) tuân thủ Single Responsibility Principle (mỗi Use Case xử lý 1 hành vi nghiệp vụ).
* **Data Layer (Data Sources, Models, Repositories):**
  * `RemoteDataSource` sử dụng `Dio` và trích xuất lỗi qua `_extractErrorMessage`.
  * Các Model (`CarModel`, `BookingModel`, `AuthResultModel`) thực hiện mapping JSON an toàn với nhiều cơ chế fallback.
* **Presentation Layer (BLoC/Cubit & Views):**
  * Sử dụng `flutter_bloc` với phân tách rõ rệt giữa Event, State và BLoC.
  * Tách biệt logic nghiệp vụ khỏi UI thông qua các luồng phát State: `Loading`, `Success/Loaded`, `Failure/Error`.

---

## 3. CÁC ĐIỂM YẾU KIẾN TRÚC & ANTI-PATTERNS PHÁT HIỆN

### 🔴 Vấn đề 1: Kiến trúc thư mục kiểm thử đặt sai vị trí (`lib/test` thay vì `test/`)
* **Hiện trạng:** Bộ 14 file kiểm thử được đặt bên trong `lib/test/`.
* **Rủi ro kiến trúc:**
  1. Theo chuẩn Flutter, toàn bộ file trong `lib/` sẽ được trình biên dịch gom vào gói bundle APK/IPA phát hành.
  2. Các gói `dev_dependencies` như `flutter_test`, `mocktail` bị import vào `lib/`, gây ra cảnh báo `depend_on_referenced_packages` trên trình phân tích tĩnh Dart Analyzer.
  3. Làm tăng kích thước file cài đặt và có nguy cơ lộ test fixtures, mock data trong môi trường Production.
* **Đề xuất khắc phục:** Di chuyển thư mục `lib/test/` ra thư mục gốc `test/` của dự án.

### 🔴 Vấn đề 2: "God Widget" (Widget nguyên khối quá lớn - Vi phạm SRP)
* **Hiện trạng:**
  * `profile_screen.dart`: **1,984 dòng code** trong 1 file duy nhất.
  * `rental_screen.dart`: **1,773 dòng code** trong 1 file duy nhất.
  * `vehicle_registration_screen.dart`: **1,250+ dòng code**.
* **Hậu quả:**
  * Khó kiểm thử Widget (Widget Testing gần như không thể cô lập từng thành phần).
  * Khó bảo trì, xung đột code khi nhiều lập trình viên cùng làm việc.
  * Chứa nhiều đoạn code thừa (Unused Elements) như `_ProfileBackground`, `_SectionTitle`, `_LuxuryProfileHero`, `_buildContractWidgets` không hề được gọi đến nhưng vẫn nằm trong file.
* **Đề xuất:** Refactor tách nhỏ các màn hình này thành các Sub-Widgets theo Atomic Design (`components/`, `sections/`).

### 🟡 Vấn đề 3: Đăng ký Dependency Injection chồng chéo (Dual DI Pattern)
* **Hiện trạng tại `injection_container.dart`:**
  * Dự án vừa kích hoạt tự động `@InjectableInit()` qua `sl.init()`, vừa thực hiện đăng ký thủ công hàng loạt bằng `if (!sl.isRegistered<T>()) sl.registerLazySingleton<T>(...)` từ dòng 61 đến dòng 298.
* **Đánh giá:** Đây là giải pháp chắp vá (workaround) khi `build_runner` chưa sinh đủ file hoặc xung đột factory. Cần chuẩn hóa dứt điểm: Hoặc sử dụng 100% Injectable qua `@injectable` annotations, hoặc tổ chức thủ công rõ ràng theo module.

---

## 4. BẢNG TỔNG KẾT ĐÁNH GIÁ NGUYÊN TẮC THIẾT KẾ (DESIGN PRINCIPLES)

| Tiêu chuẩn | Đánh giá | Nhận xét chi tiết |
| :--- | :---: | :--- |
| **Clean Architecture** | 8.5/10 | Phân tầng rõ rệt (Data - Domain - Presentation), Dependency Direction chuẩn. |
| **SOLID - SRP** | 6.5/10 | UseCases & BLoC làm tốt; Views (`profile_screen`, `rental_screen`) ôm đồm quá nhiều việc. |
| **SOLID - DIP** | 9.0/10 | 100% Repositories đều có Interface trừu tượng ở Domain, Data layer implement. |
| **State Management** | 9.0/10 | BLoC/Cubit đồng nhất trên toàn bộ tính năng, quản lý State an toàn. |
| **Packaging & Modularity** | 7.0/10 | Tổ chức Feature-driven tốt nhưng đặt nhầm thư mục `test` vào `lib`. |
| **TỔNG ĐIỂM KIẾN TRÚC** | **8.0 / 10** | **Khá tốt - Đủ điều kiện sản xuất sau khi dọn dẹp các God Widgets.** |
