import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/auth/domain/entities/user_entity.dart';
import 'package:book_drive_car/features/home/data/datasources/booking_remote_data_source.dart';
import 'package:book_drive_car/features/profile/data/datasources/verification_local_datasource.dart';
import 'package:book_drive_car/features/profile/domain/entities/verification_entity.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:book_drive_car/features/profile/presentation/view/identity_verification/identity_verification_screen.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/owner_booking_list_screen.dart';
import 'package:book_drive_car/features/profile/presentation/view/vehicle_management/rental_management_screen.dart';
import 'package:book_drive_car/features/welcome/presentation/view/welcome_screen.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<_AvatarPreset> _avatarPresets = const [
    _AvatarPreset(icon: Icons.person_rounded, color: AppColors.primary),
    _AvatarPreset(icon: Icons.face_rounded, color: AppColors.accent),
    _AvatarPreset(icon: Icons.account_circle_rounded, color: AppColors.success),
    _AvatarPreset(icon: Icons.badge_rounded, color: AppColors.danger),
  ];

  int _avatarIndex = 0;
  UserEntity? _user;
  VerificationData _verificationData = const VerificationData();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await sl<UserLocalStorage>().getUser();
    final verificationLocal = sl<VerificationLocalDataSource>();
    final current = await verificationLocal.getVerificationData();
    VerificationData vData = current;

    // Ưu tiên lấy trạng thái xác minh từ server (endpoint chuyên biệt)
    try {
      final serverStatus = await _fetchVerificationStatusFromServer();
      if (serverStatus != null && serverStatus != current.status) {
        vData = current.copyWith(status: serverStatus);
        await verificationLocal.saveVerificationData(vData);
      }
    } catch (_) {
      // Nếu endpoint status không tồn tại → fallback: dùng checkVerified
      try {
        final serverUser = await sl<BookingRemoteDataSource>().checkVerified();
        vData = current.copyWith(
          status: VerificationStatus.verified,
          fullName: serverUser.fullname,
          cccdNumber: serverUser.cccd ?? current.cccdNumber,
          address: serverUser.addressText.isNotEmpty
              ? serverUser.addressText
              : current.address,
        );
        await verificationLocal.saveVerificationData(vData);
      } catch (_) {
        // Giữ nguyên trạng thái local nếu không kết nối được server.
      }
    }

    if (mounted) {
      setState(() {
        _user = user;
        _verificationData = vData;
      });
    }
  }

  /// Gọi GET /api/users/veri/status để lấy trạng thái xác minh hiện tại.
  /// Trả về null nếu endpoint chưa tồn tại hoặc không hỗ trợ.
  Future<VerificationStatus?> _fetchVerificationStatusFromServer() async {
    try {
      final dio = sl<Dio>();
      final token = await sl<UserLocalStorage>().getToken();
      final response = await dio.get(
        ApiConstants.verificationStatus,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
          validateStatus: (code) => code != null && code < 500,
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final raw = data is Map ? (data['data'] ?? data['status'] ?? data) : data;
        final statusStr = raw is String ? raw : (raw is Map ? raw['status'] : null);
        if (statusStr != null) {
          return VerificationStatus.fromString(statusStr.toString());
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _openVerificationForm() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            IdentityVerificationScreen(initialData: _verificationData),
      ),
    );
    if (result == true) {
      await _loadUser();
    }
  }

  Future<void> _showAccountDetail() async {
    final user = _user;
    final vData = _verificationData; // snapshot tại thời điểm mở bottom sheet
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _BottomSheetShell(
          title: 'Tài khoản của tôi',
          subtitle: 'Thông tin cá nhân và trạng thái xác thực',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user != null) ...[
                _InfoRow(label: 'Họ tên', value: user.fullname.isNotEmpty ? user.fullname : '—'),
                _InfoRow(
                  label: 'Email',
                  value: user.email.isNotEmpty ? user.email : '—',
                ),
                _InfoRow(
                  label: 'Số điện thoại',
                  value: user.phone.isNotEmpty ? user.phone : '—',
                ),
                if (user.cccd?.isNotEmpty == true)
                  _InfoRow(label: 'CCCD', value: user.cccd!),
                _InfoRow(label: 'Vai trò', value: user.role.isNotEmpty ? user.role : 'user'),
                _InfoRow(
                  label: 'Trạng thái',
                  value: vData.status.label,
                  valueColor: vData.status.color,
                ),
              ] else
                const Text(
                  'Không thể tải thông tin tài khoản.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAvatarPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return _BottomSheetShell(
              title: 'Cập nhật avatar',
              subtitle:
                  'Chọn một avatar phù hợp để làm mới hồ sơ cá nhân của bạn.',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(_avatarPresets.length, (index) {
                  final preset = _avatarPresets[index];
                  final active = index == _avatarIndex;
                  return TapScale(
                    onTap: () {
                      setState(() => _avatarIndex = index);
                      setModalState(() {});
                      Navigator.of(context).pop();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: preset.color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: active ? preset.color : AppColors.border,
                          width: active ? 1.6 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: preset.color.withValues(
                              alpha: active ? 0.18 : 0.06,
                            ),
                            blurRadius: active ? 18 : 12,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(preset.icon, color: preset.color, size: 36),
                    ),
                  );
                }),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAvatarOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _BottomSheetShell(
          title: 'Avatar & tài khoản',
          subtitle:
              'Bạn có thể xem thông tin tài khoản hoặc đổi avatar ngay tại đây.',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Future.microtask(_showAccountDetail);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Xem tài khoản',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Future.microtask(_showAvatarPicker);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Đổi avatar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSimpleMessage(String title, String message) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _BottomSheetShell(
          title: title,
          subtitle: message,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Đóng',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text(
          'Bạn có muốn đăng xuất khỏi tài khoản hiện tại không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    await sl<UserLocalStorage>().clear();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) => const WelcomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final preset = _avatarPresets[_avatarIndex];
    final userName = _user?.fullname ?? '';
    final userEmail = _user?.email ?? '';
    final phone = _user?.phone ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0C1017),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: _LuxuryProfileBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LuxuryProfileHero(
                    preset: preset,
                    userName: userName.isNotEmpty ? userName : 'Người dùng',
                    userEmail: userEmail.isNotEmpty ? userEmail : '—',
                    phone: phone.isNotEmpty ? phone : '—',
                    verificationData: _verificationData,
                    onTapAvatar: _showAvatarOptions,
                    onTapAccount: _showAccountDetail,
                  ),
                  const SizedBox(height: 14),

                  // ── CARD TRẠNG THÁI XÁC MINH DANH TÍNH ───────────────────────
                  _VerificationCard(
                    data: _verificationData,
                    onTap: _openVerificationForm,
                  ),
                  const SizedBox(height: 18),

                  const _LuxurySectionTitle(
                    title: 'Khu vực cá nhân',
                    subtitle: 'Các tính năng nhanh cho tài khoản và xe của bạn',
                  ),
                  const SizedBox(height: 12),
                  _LuxuryActionTile(
                    icon: Icons.directions_car_rounded,
                    title: 'Đăng ký cho thuê xe',
                    subtitle: 'Mở trang quản lý xe cho thuê của bạn',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RentalManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _LuxuryActionTile(
                    icon: Icons.lock_reset_rounded,
                    title: 'Đổi mật khẩu',
                    subtitle: 'Cập nhật mật khẩu để tăng bảo mật tài khoản',
                    onTap: () => _showSimpleMessage(
                      'Đổi mật khẩu',
                      'Màn đổi mật khẩu sẽ được kết nối ở bước tiếp theo.',
                    ),
                  ),
                  _LuxuryActionTile(
                    icon: Icons.delete_outline_rounded,
                    title: 'Yêu cầu xoá tài khoản',
                    subtitle: 'Gửi yêu cầu xoá dữ liệu tài khoản',
                    danger: true,
                    onTap: () => _showSimpleMessage(
                      'Xóa tài khoản',
                      'Bạn có thể gửi yêu cầu xoá tài khoản từ đây.',
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: TapScale(
                      onTap: _logout,
                      child: Container(
                        width: 230,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.danger.withValues(alpha: 0.96),
                              const Color(0xFFB71C1C),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.danger.withValues(alpha: 0.26),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Đăng xuất',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(child: _ProfileBackground()),
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileHero(
                preset: preset,
                userName: userName.isNotEmpty ? userName : 'Người dùng',
                userEmail: userEmail.isNotEmpty ? userEmail : '—',
                phone: phone.isNotEmpty ? phone : '—',
                verificationData: _verificationData,
                onTapAvatar: _showAvatarOptions,
                onTapAccount: _showAccountDetail,
              ),
              const SizedBox(height: 18),
              _SectionTitle(
                title: 'Khu vực cá nhân',
                subtitle: 'Các tính năng nhanh cho tài khoản và xe của bạn',
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.directions_car_rounded,
                title: 'Đăng ký cho thuê xe',
                subtitle: 'Mở trang quản lý xe cho thuê của bạn',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RentalManagementScreen(),
                    ),
                  );
                },
              ),
              _ActionTile(
                icon: Icons.lock_reset_rounded,
                title: 'Đổi mật khẩu',
                subtitle: 'Cập nhật mật khẩu để tăng bảo mật tài khoản',
                onTap: () => _showSimpleMessage(
                  'Đổi mật khẩu',
                  'Màn đổi mật khẩu sẽ được kết nối ở bước tiếp theo.',
                ),
              ),
              _ActionTile(
                icon: Icons.delete_outline_rounded,
                title: 'Yêu cầu xoá tài khoản',
                subtitle: 'Gửi yêu cầu xoá dữ liệu tài khoản',
                danger: true,
                onTap: () => _showSimpleMessage(
                  'Xóa tài khoản',
                  'Bạn có thể gửi yêu cầu xoá tài khoản từ đây.',
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: TapScale(
                  onTap: _logout,
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.danger.withValues(alpha: 0.24),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Đăng xuất',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileBackground extends StatelessWidget {
  const _ProfileBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7F8FA), Color(0xFFF3F4F7), Color(0xFFF7F8FA)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -60,
            child: _GlowOrb(
              size: 220,
              colors: [
                AppColors.primary.withValues(alpha: 0.10),
                Colors.transparent,
              ],
            ),
          ),
          Positioned(
            top: 180,
            left: -80,
            child: _GlowOrb(
              size: 180,
              colors: [
                AppColors.accent.withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _GlowOrb({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final _AvatarPreset preset;
  final String userName;
  final String userEmail;
  final String phone;
  final VerificationData verificationData;
  final VoidCallback onTapAvatar;
  final VoidCallback onTapAccount;

  const _ProfileHero({
    required this.preset,
    required this.userName,
    required this.userEmail,
    required this.phone,
    required this.verificationData,
    required this.onTapAvatar,
    required this.onTapAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F141B),
            const Color(0xFF16202B),
            AppColors.primary.withValues(alpha: 0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.20),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onTapAvatar,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 2,
                        ),
                      ),
                      child: Icon(preset.icon, color: Colors.white, size: 38),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: preset.color.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 14,
                          color: preset.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TapScale(
                  onTap: onTapAccount,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ProfileBadge(
                            label: verificationData.status.label,
                            icon: verificationData.status.icon,
                          ),
                          _ProfileBadge(
                            label: 'Đang hoạt động',
                            icon: Icons.bolt_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    phone,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _BottomSheetShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ProfileBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPreset {
  final IconData icon;
  final Color color;

  const _AvatarPreset({required this.icon, required this.color});
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool danger;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TapScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxuryProfileBackground extends StatelessWidget {
  const _LuxuryProfileBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C1017), Color(0xFF151A24), Color(0xFFF7F8FA)],
          stops: [0.0, 0.42, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -60,
            child: _LuxuryGlow(
              size: 220,
              colors: [
                AppColors.headlightAmber.withValues(alpha: 0.22),
                Colors.transparent,
              ],
            ),
          ),
          Positioned(
            top: 180,
            left: -80,
            child: _LuxuryGlow(
              size: 180,
              colors: [
                AppColors.pageAccents[2].withValues(alpha: 0.18),
                Colors.transparent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxuryGlow extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _LuxuryGlow({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _LuxuryProfileHero extends StatelessWidget {
  final _AvatarPreset preset;
  final String userName;
  final String userEmail;
  final String phone;
  final VerificationData verificationData;
  final VoidCallback onTapAvatar;
  final VoidCallback onTapAccount;

  const _LuxuryProfileHero({
    required this.preset,
    required this.userName,
    required this.userEmail,
    required this.phone,
    required this.verificationData,
    required this.onTapAvatar,
    required this.onTapAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F141B),
            const Color(0xFF16202B),
            AppColors.primary.withValues(alpha: 0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onTapAvatar,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 2,
                        ),
                      ),
                      child: Icon(preset.icon, color: Colors.white, size: 38),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: preset.color.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 14,
                          color: preset.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TapScale(
                  onTap: onTapAccount,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ProfileBadge(
                            label: verificationData.status.label,
                            icon: verificationData.status.icon,
                          ),
                          _ProfileBadge(
                            label: 'Đang hoạt động',
                            icon: Icons.bolt_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    phone,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxurySectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _LuxurySectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _LuxuryActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool danger;
  final VoidCallback onTap;

  const _LuxuryActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.headlightAmber;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TapScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F6F1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.18),
                      color.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

// ── WIDGET CARD TRẠNG THÁI XÁC MINH DANH TÍNH (PROFILE) ───────────────────────

class _VerificationCard extends StatelessWidget {
  final VerificationData data;
  final VoidCallback onTap;

  const _VerificationCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = data.status;
    Color cardColor;
    Color borderColor;
    IconData icon;
    String title;
    String subtitle;
    String buttonText;

    switch (status) {
      case VerificationStatus.unverified:
        cardColor = const Color(0xFF1E293B);
        borderColor = const Color(0xFFFFA000);
        icon = Icons.warning_amber_rounded;
        title = 'Xác minh danh tính để bắt đầu thuê xe';
        subtitle = 'Nộp CCCD & Bằng lái xe để mở khoá tính năng đặt thuê xe';
        buttonText = 'Xác minh ngay';
        break;
      case VerificationStatus.pending:
        cardColor = const Color(0xFF1E293B);
        borderColor = const Color(0xFF1976D2);
        icon = Icons.access_time_rounded;
        title = 'Hồ sơ đang được xét duyệt';
        final timeStr = data.submittedAt != null
            ? DateFormat('HH:mm dd/MM').format(data.submittedAt!)
            : 'mới đây';
        subtitle = 'Đã gửi lúc $timeStr • Dự kiến duyệt trong vòng 24h';
        buttonText = 'Xem hồ sơ';
        break;
      case VerificationStatus.verified:
        cardColor = const Color(0xFF0F291E);
        borderColor = const Color(0xFF388E3C);
        icon = Icons.verified_user_rounded;
        title = 'Đã xác minh danh tính';
        final expiryStr = data.licenseExpiryDate?.isNotEmpty == true
            ? data.licenseExpiryDate
            : 'Dài hạn';
        subtitle =
            'Hạng bằng: ${data.licenseClass ?? "B2"} • Hạn GPLX: $expiryStr';
        buttonText = 'Xem thông tin';
        break;
      case VerificationStatus.rejected:
        cardColor = const Color(0xFF2D1619);
        borderColor = const Color(0xFFD32F2F);
        icon = Icons.cancel_rounded;
        title = 'Hồ sơ bị từ chối';
        subtitle =
            data.rejectionReason ??
            'Thông tin hoặc ảnh giấy tờ không đủ điều kiện xét duyệt.';
        buttonText = 'Xem & Nộp lại';
        break;
      case VerificationStatus.expired:
        cardColor = const Color(0xFF2E1C0C);
        borderColor = const Color(0xFFE65100);
        icon = Icons.running_with_errors_rounded;
        title = 'Giấy phép lái xe hết hạn';
        subtitle = 'Cần cập nhật GPLX mới để tiếp tục sử dụng dịch vụ thuê xe.';
        buttonText = 'Cập nhật ngay';
        break;
    }

    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.6),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: borderColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.75),
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.white12),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: borderColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: borderColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: borderColor,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
