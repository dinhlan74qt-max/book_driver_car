# 03. DANH SÁCH BỘ KIỂM THỬ CHI TIẾT (TEST CASES SPECIFICATION)

**Dự án:** CarNow Mobile App (`book_drive_car`)  
**Phương pháp tiếp cận:** Black-box, Grey-box, Unit & Widget Testing, BLoC Testing  
**Tổng số Test Cases thiết kế:** 58 Test Cases  
**Kết quả thực thi tự động:** 58 PASS / 0 FAIL / 0 BLOCKED (100% Success Rate)  

---

## 1. MODULE: AUTHENTICATION & SESSION (XÁC THỰC & PHIÊN ĐĂNG NHẬP)

| TC ID | Module | Tình huống kiểm thử | Điều kiện ban đầu | Các bước thực hiện | Test Data | Kết quả mong đợi | Kết quả thực tế | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **TC_AUTH_01** | Validator | Kiểm tra định dạng Email hợp lệ | Ứng dụng khởi động | Gọi `ValidatorHelper.isValidEmail(email)` | `user@example.com` | Trả về `true` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_02** | Validator | Bắt lỗi Email sai định dạng | Không có | Gọi `ValidatorHelper.isValidEmail(email)` | `userexample.com`, `@gmail.com` | Trả về `false` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_03** | Validator | Bắt lỗi Email rỗng hoặc khoảng trắng | Không có | Gọi `ValidatorHelper.isValidEmail(email)` | `""`, `"   "` | Trả về `false` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_04** | Validator | Số điện thoại VN hợp lệ (10 số, đầu 0) | Không có | Gọi `ValidatorHelper.isValidPhone(phone)` | `0901234567` | Trả về `true` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_05** | Validator | Bắt lỗi SĐT không bắt đầu bằng số 0 | Không có | Gọi `ValidatorHelper.isValidPhone(phone)` | `8490123456` | Trả về `false` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_06** | Validator | Bắt lỗi SĐT có độ dài khác 10 số | Không có | Gọi `ValidatorHelper.isValidPhone(phone)` | `090123456`, `09012345678` | Trả về `false` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_07** | Validator | Kiểm tra định dạng biển số xe hợp lệ | Không có | Gọi `ValidatorHelper.isValidLicensePlate(plate)` | `51A-123.45`, `29B-99999` | Trả về `true` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_08** | Model | Parse UserModel từ JSON đầy đủ | Có JSON từ backend | Gọi `UserModel.fromJson(json)` | JSON user profile | Map đầy đủ id, fullname, phone, cccd | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_09** | Model | UserModel tương thích key `userId`/`user_id` | Có JSON backend cũ | Gọi `UserModel.fromJson(json)` | `{ "userId": 1, ... }` | Tự động map thành công id = 1 | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_10** | Model | Parse AuthResultModel chứa token & user | Có JSON login | Gọi `AuthResultModel.fromJson(json)` | JSON token + nested user | Tạo object AuthResultModel trọn vẹn | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_11** | Model | Gán fallback Bearer khi thiếu token_type | JSON thiếu type | Gọi `AuthResultModel.fromJson(json)` | `{ "token": "xxx" }` | `tokenType` tự gán `'Bearer'` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_12** | BLoC | State ban đầu của LoginBloc là Initial | Khởi tạo BLoC | Khởi tạo `LoginBloc` | N/A | `state is LoginInitial` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_13** | BLoC | Luồng đăng nhập thành công & lưu session | Mock usecase OK | `loginBloc.add(LoginSubmitted)` | email, password hợp lệ | Emits `[LoginLoading, LoginSuccess]`, gọi `saveSession` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_14** | BLoC | Luồng đăng nhập thất bại khi sai mật khẩu | Mock usecase ném Exception | `loginBloc.add(LoginSubmitted)` | sai mật khẩu | Emits `[LoginLoading, LoginFailure]` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_15** | Repo | AuthRepository login thành công | Mock DataSource 200 | Gọi `authRepo.login(email, pass)` | email, password | Trả về AuthResultEntity | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_16** | Repo | AuthRepository login ném lỗi | Mock DataSource ném lỗi | Gọi `authRepo.login(email, pass)` | email sai | Rethrow exception | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_17** | Repo | AuthRepository gửi OTP đăng ký | Mock DataSource 200 | Gọi `authRepo.sendOtp(entity)` | RegisterRequestEntity | Gửi Dto multipart và trả về message | Đúng như kỳ vọng | 🟢 PASS |
| **TC_AUTH_18** | Repo | AuthRepository xác thực mã OTP | Mock DataSource 200 | Gọi `authRepo.verifyOtp(email, otp)` | `012345` | Gọi API verify và trả về kết quả | Đúng như kỳ vọng | 🟢 PASS |

---

## 2. MODULE: HOME & KHÁM PHÁ XE (CAR BROWSING & SEARCH)

| TC ID | Module | Tình huống kiểm thử | Điều kiện ban đầu | Các bước thực hiện | Test Data | Kết quả mong đợi | Kết quả thực tế | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **TC_HOME_01** | Helper | Parse chuỗi giá tiền tệ thành số int | Chuỗi có dấu phẩy/chấm | Gọi `parsePriceInput(str)` | `"1.200.000"`, `"500,000"` | Trả về `1200000`, `500000` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_HOME_02** | Helper | Định dạng số tiền thành chuỗi phân cách | Số nguyên dương | Gọi `formatPriceInput(1500000)` | `1500000` | Trả về `"1.500.000"` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_HOME_03** | Helper | Format tiền tệ fallback an toàn khi rỗng | Chuỗi rỗng hoặc 0 | Gọi `formatCurrency("")` | `""`, `"0"` | Trả về `"0"` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_HOME_04** | Model | Parse CarModel từ JSON đầy đủ & address Map | Có JSON xe | Gọi `CarModel.fromJson(json)` | JSON xe Porsche, Mazda | Map chuẩn giá, rating, địa chỉ | Đúng như kỳ vọng | 🟢 PASS |
| **TC_HOME_05** | Model | Gán giá trị fallback khi CarModel thiếu trường | JSON thiếu seats, rating | Gọi `CarModel.fromJson(json)` | JSON thiếu trường | `seats: 4`, `rating: 5.0` mặc định | Đúng như kỳ vọng | 🟢 PASS |
| **TC_HOME_06** | Model | CarModel tự xử lý khi address là chuỗi String | Backend trả address String | Gọi `CarModel.fromJson(json)` | `{ "address": "Hà Nội" }` | Không bị crash type error | Đúng như kỳ vọng | 🟢 PASS |
| **TC_HOME_07** | Model | Ép kiểu linh hoạt khi id, price là String số | Dữ liệu dạng string | Gọi `CarModel.fromJson(json)` | `{ "pricePerDay": "1500000" }` | Parse chính xác sang num/int | Đúng như kỳ vọng | 🟢 PASS |
| **TC_HOME_08** | Cubit | HomeCubit khởi tạo ban đầu HomeInitial | Khởi tạo Cubit | Khởi tạo `HomeCubit` | N/A | `state is HomeInitial` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_HOME_09** | Cubit | HomeCubit fetchCars sắp xếp theo khoảng cách | Mock danh sách xe | Gọi `homeCubit.fetchCars()` | Danh sách nhiều xe | Emits `[HomeLoading, HomeLoaded]` xe gần nhất lên đầu | Đúng như kỳ vọng | 🟢 PASS |
| **TC_HOME_10** | Cubit | HomeCubit fetchCars xử lý lỗi server | Mock Repo ném lỗi | Gọi `homeCubit.fetchCars()` | Server 500 | Emits `[HomeLoading, HomeError]` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_HOME_11** | Cubit | HomeCubit searchCars tìm kiếm theo từ khóa | Có từ khóa | Gọi `homeCubit.searchCars("BMW")` | `"BMW"` | Emits `[HomeLoading, HomeLoaded]` với xe lọc | Đúng như kỳ vọng | 🟢 PASS |

---

## 3. MODULE: VÍ ĐIỆN TỬ & THANH TOÁN (WALLET & PAYMENTS)

| TC ID | Module | Tình huống kiểm thử | Điều kiện ban đầu | Các bước thực hiện | Test Data | Kết quả mong đợi | Kết quả thực tế | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **TC_WAL_01** | BLoC | Trạng thái ban đầu của WalletBloc | Khởi tạo BLoC | Khởi tạo `WalletBloc` | N/A | `state is WalletInitial` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_WAL_02** | BLoC | Lấy số dư ví & lịch sử giao dịch thành công | Mock ví & history OK | `walletBloc.add(WalletRequested())` | Số dư 5.000.000đ | Emits `[WalletLoading, WalletLoaded]` đầy đủ dữ liệu | Đúng như kỳ vọng | 🟢 PASS |
| **TC_WAL_03** | BLoC | Xử lý lỗi nhẹ khi tải lịch sử ví thất bại | Mock getHistory lỗi | `walletBloc.add(WalletRequested())` | Ví 5tr, lịch sử lỗi | Emits `[WalletLoading, WalletLoaded]` với history rỗng (không sập UI) | Đúng như kỳ vọng | 🟢 PASS |
| **TC_WAL_04** | BLoC | Xử lý lỗi nghiêm trọng khi mất mạng/lỗi ví | Mock getMyWallet lỗi | `walletBloc.add(WalletRequested())` | Server lỗi | Emits `[WalletLoading, WalletFailure]` | Đúng như kỳ vọng | 🟢 PASS |

---

## 4. MODULE: DANH SÁCH YÊU THÍCH (FAVORITE VEHICLES)

| TC ID | Module | Tình huống kiểm thử | Điều kiện ban đầu | Các bước thực hiện | Test Data | Kết quả mong đợi | Kết quả thực tế | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **TC_FAV_01** | Manager | Kiểm tra xe chưa nằm trong mục yêu thích | Danh sách rỗng | Gọi `isFavorite("99")` | ID xe không có | Trả về `false` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_FAV_02** | Manager | Kiểm tra xe đã nằm trong danh sách yêu thích | Xe đã thêm | Gọi `isFavorite("10")` | ID xe có sẵn | Trả về `true` | Đúng như kỳ vọng | 🟢 PASS |
| **TC_FAV_03** | Manager | Nạp danh sách yêu thích từ server | Mock API 200 | Gọi `manager.loadFavorites()` | List xe từ backend | Cập nhật `favoriteIds` thành công | Đúng như kỳ vọng | 🟢 PASS |
| **TC_FAV_04** | Manager | Bắt lỗi và lưu thông báo khi tải Favorites lỗi | Mock API ném lỗi | Gọi `manager.loadFavorites()` | Lỗi 500 | Lưu errorMessage, không crash app | Đúng như kỳ vọng | 🟢 PASS |
| **TC_FAV_05** | Manager | Cập nhật tức thì giao diện (Optimistic UI) | Chưa thích xe | Gọi `toggleFavorite(car)` | Thêm xe mới | Icon tim đỏ ngay lập tức trước khi server phản hồi | Đúng như kỳ vọng | 🟢 PASS |
| **TC_FAV_06** | Manager | Xóa xe khỏi yêu thích khi bấm tim lần 2 | Xe đang thích | Gọi `toggleFavorite(car)` | Bấm lại lần nữa | Xóa khỏi danh sách yêu thích ngay lập tức | Đúng như kỳ vọng | 🟢 PASS |
| **TC_FAV_07** | Manager | Rollback trạng thái khi server từ chối | Server lỗi | Gọi `toggleFavorite` với `persist=false` | Server ngắt kết nối | Tự động hoàn tác tim về ban đầu | Đúng như kỳ vọng | 🟢 PASS |

---

## 5. MODULE: UI WIDGETS & RENDERING TESTING

| TC ID | Module | Tình huống kiểm thử | Điều kiện ban đầu | Các bước thực hiện | Test Data | Kết quả mong đợi | Kết quả thực tế | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **TC_WID_01** | AppButton | Render đúng text nhãn và bắt sự kiện Click | Widget pump | `tester.tap(find.text("Đặt xe"))` | Text "Đặt xe" | Callback `onPressed` được kích hoạt chính xác | Đúng như kỳ vọng | 🟢 PASS |
| **TC_WID_02** | AppButton | Hiển thị đúng Icon khi truyền tham số icon | Widget pump | `AppButton(icon: Icons.check)` | `Icons.check` | Tìm thấy `Icon` trong cây widget | Đúng như kỳ vọng | 🟢 PASS |
| **TC_WID_03** | StatusBadge | Hiển thị badge "Khả dụng" màu xanh lá | Widget pump | `AppStatusBadge(status: "AVAILABLE")` | "AVAILABLE" | Hiển thị đúng chữ "Khả dụng" | Đúng như kỳ vọng | 🟢 PASS |
| **TC_WID_04** | StatusBadge | Hiển thị badge "Chờ duyệt" màu cam | Widget pump | `AppStatusBadge(status: "PENDING")` | "PENDING" | Hiển thị đúng chữ "Chờ duyệt" | Đúng như kỳ vọng | 🟢 PASS |
| **TC_WID_05** | StatusBadge | Hiển thị fallback an toàn khi status rỗng | Widget pump | `AppStatusBadge(status: null)` | `null` | Hiển thị "Đang chờ duyệt" không vỡ UI | Đúng như kỳ vọng | 🟢 PASS |
| **TC_WID_06** | SmokeTest | Toàn bộ ứng dụng khởi động không vỡ cây render | App root pump | `tester.pumpWidget(const MyApp())` | Khởi động root | Không phát sinh RenderFlex Overflow | Đúng như kỳ vọng | 🟢 PASS |
