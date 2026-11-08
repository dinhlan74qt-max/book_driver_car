import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/auth/domain/entities/user_entity.dart';
import 'package:book_drive_car/features/favorite/presentation/manager/favorite_manager.dart';
import 'package:book_drive_car/features/favorite/presentation/view/favorite_vehicles_screen.dart';
import 'package:book_drive_car/features/profile/domain/entities/verification_entity.dart';
import 'package:book_drive_car/features/profile/domain/repositories/verification_repository.dart';
import 'package:book_drive_car/features/profile/presentation/view/identity_verification/identity_verification_screen.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/owner_booking_list_screen.dart';
import 'package:book_drive_car/features/profile/presentation/view/security/change_password_screen.dart';
import 'package:book_drive_car/features/profile/presentation/view/vehicle_management/rental_management_screen.dart';
import 'package:book_drive_car/features/welcome/presentation/view/welcome_screen.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/core/theme/theme_controller.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_status_badge.dart';
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
    _AvatarPreset(icon: Icons.person_rounded, color: Color(0xFF2563EB)),
    _AvatarPreset(icon: Icons.face_rounded, color: Color(0xFFF59E0B)),
    _AvatarPreset(
      icon: Icons.directions_car_filled_rounded,
      color: Color(0xFF0284C7),
    ),
    _AvatarPreset(
      icon: Icons.sports_motorsports_rounded,
      color: Color(0xFF8B5CF6),
    ),
    _AvatarPreset(icon: Icons.electric_car_rounded, color: Color(0xFF10B981)),
    _AvatarPreset(icon: Icons.stars_rounded, color: Color(0xFFEA580C)),
    _AvatarPreset(icon: Icons.shield_rounded, color: Color(0xFF3B82F6)),
    _AvatarPreset(icon: Icons.rocket_launch_rounded, color: Color(0xFFEC4899)),
    _AvatarPreset(
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFFEAB308),
    ),
    _AvatarPreset(icon: Icons.smart_toy_rounded, color: Color(0xFF06B6D4)),
    _AvatarPreset(icon: Icons.flight_takeoff_rounded, color: Color(0xFF6366F1)),
    _AvatarPreset(icon: Icons.bolt_rounded, color: Color(0xFFEF4444)),
    _AvatarPreset(icon: Icons.spa_rounded, color: Color(0xFF14B8A6)),
    _AvatarPreset(icon: Icons.diamond_rounded, color: Color(0xFFA855F7)),
    _AvatarPreset(icon: Icons.military_tech_rounded, color: Color(0xFFD97706)),
    _AvatarPreset(
      icon: Icons.sentiment_very_satisfied_rounded,
      color: Color(0xFF84CC16),
    ),
  ];

  int _avatarIndex = 0;
  UserEntity? _user;
  VerificationData _verificationData = const VerificationData();

  @override
  void initState() {
    super.initState();
    _loadUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FavoriteManager.instance.loadFavorites();
      }
    });
  }

  Future<void> _loadUser() async {
    final user = await sl<UserLocalStorage>().getUser();
    final localAvatarIdx = await sl<UserLocalStorage>().getLocalAvatarIndex();
    final vData = await sl<VerificationRepository>().syncVerification();

    if (mounted) {
      setState(() {
        _user = user;
        if (localAvatarIdx >= 0 && localAvatarIdx < _avatarPresets.length) {
          _avatarIndex = localAvatarIdx;
        } else {
          _avatarIndex = 0;
        }
        _verificationData = vData;
      });
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
                _InfoRow(
                  label: 'Họ tên',
                  value: user.fullname.isNotEmpty ? user.fullname : '—',
                ),
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
                _InfoRow(
                  label: 'Vai trò',
                  value: user.role.isNotEmpty ? user.role : 'user',
                ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  'Chọn biểu tượng đại diện phù hợp (dữ liệu được lưu trên thiết bị của bạn).',
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _avatarPresets.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.0,
                        ),
                    itemBuilder: (context, index) {
                      final preset = _avatarPresets[index];
                      final active = index == _avatarIndex;
                      return TapScale(
                        onTap: () async {
                          setState(() => _avatarIndex = index);
                          setModalState(() {});
                          await sl<UserLocalStorage>().saveLocalAvatarIndex(
                            index,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            AppToast.show(
                              context,
                              message: 'Đã cập nhật avatar thành công',
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: active
                                ? preset.color.withValues(
                                    alpha: isDark ? 0.28 : 0.16,
                                  )
                                : preset.color.withValues(
                                    alpha: isDark ? 0.10 : 0.06,
                                  ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active
                                  ? preset.color
                                  : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.border),
                              width: active ? 2.2 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: preset.color.withValues(
                                  alpha: active ? 0.25 : 0.05,
                                ),
                                blurRadius: active ? 14 : 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(preset.icon, color: preset.color, size: 34),
                              if (active)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      size: 16,
                                      color: preset.color,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
                child: Builder(
                  builder: (ctx) {
                    final isDark = Theme.of(ctx).brightness == Brightness.dark;
                    return OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Future.microtask(_showAvatarPicker);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        side: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Đổi avatar',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showThemePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final currentMode = themeController.themeMode;

        void onSelectTheme(ThemeMode mode, BuildContext tileCtx) async {
          Offset? tapPos;
          try {
            final renderBox = tileCtx.findRenderObject() as RenderBox?;
            if (renderBox != null && renderBox.hasSize) {
              tapPos =
                  renderBox.localToGlobal(renderBox.size.center(Offset.zero));
            }
          } catch (_) {}

          Navigator.of(ctx).pop();
          // Delay nhỏ để bottom sheet đóng mượt mà trước khi kích hoạt hiệu ứng ripple
          await Future.delayed(const Duration(milliseconds: 140));
          themeController.setThemeMode(mode, origin: tapPos);
        }

        return _BottomSheetShell(
          title: 'Chế độ giao diện',
          subtitle: 'Lựa chọn phong cách hiển thị ứng dụng CarNow',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(
                builder: (tileCtx) => _ThemeOptionTile(
                  icon: Icons.light_mode_rounded,
                  title: 'Giao diện Sáng (Ocean Navy & White)',
                  subtitle: 'Nền sáng thanh lịch, sắc xanh navy hiện đại',
                  isSelected: currentMode == ThemeMode.light,
                  onTap: () => onSelectTheme(ThemeMode.light, tileCtx),
                ),
              ),
              const SizedBox(height: 10),
              Builder(
                builder: (tileCtx) => _ThemeOptionTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Giao diện Tối (Midnight & Surface Navy)',
                  subtitle: 'Nền đen nửa đêm, dịu mắt và tiết kiệm pin',
                  isSelected: currentMode == ThemeMode.dark,
                  onTap: () => onSelectTheme(ThemeMode.dark, tileCtx),
                ),
              ),
              const SizedBox(height: 10),
              Builder(
                builder: (tileCtx) => _ThemeOptionTile(
                  icon: Icons.brightness_auto_rounded,
                  title: 'Tự động theo hệ thống',
                  subtitle: 'Đồng bộ tự động với chế độ máy điện thoại',
                  isSelected: currentMode == ThemeMode.system,
                  onTap: () => onSelectTheme(ThemeMode.system, tileCtx),
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
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          title: Text(
            'Đăng xuất',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Bạn có muốn đăng xuất khỏi tài khoản hiện tại không?',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = AppColors.getSurface(context);
    final borderColor = AppColors.getBorder(context);
    final bgColor = AppColors.getBackground(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);
    final textTertiary = AppColors.getTextMuted(context);

    final safeIndex =
        (_avatarIndex >= 0 && _avatarIndex < _avatarPresets.length)
        ? _avatarIndex
        : 0;
    final preset = _avatarPresets[safeIndex];
    final userName = _user?.fullname ?? '';
    final userEmail = _user?.email ?? '';
    final phone = _user?.phone ?? '';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileHero(
                preset: preset,
                userName: userName.isNotEmpty ? userName : 'Khách hàng',
                userEmail: userEmail.isNotEmpty ? userEmail : '—',
                phone: phone.isNotEmpty ? phone : '—',
                verificationData: _verificationData,
                onTapAvatar: _showAvatarOptions,
                onTapAccount: _showAccountDetail,
              ),
              const SizedBox(height: 16),

              // ── CARD TRẠNG THÁI XÁC MINH DANH TÍNH ───────────────────────
              _VerificationCard(
                data: _verificationData,
                onTap: _openVerificationForm,
              ),
              const SizedBox(height: 24),

              // ── MỤC XE YÊU THÍCH ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Yêu Thích & Đã Lưu',
                      style: AppTypography.headingSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor),
                  boxShadow: isDark ? null : AppColors.shadowSm,
                ),
                child: _MenuActionItem(
                  icon: Icons.favorite_rounded,
                  iconColor: Colors.redAccent,
                  title: 'Danh sách xe yêu thích',
                  subtitle: 'Các mẫu xe bạn đã lưu và quan tâm',
                  trailing: AnimatedBuilder(
                    animation: FavoriteManager.instance,
                    builder: (_, __) {
                      final count = FavoriteManager.instance.favorites.length;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count xe',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FavoriteVehiclesScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ── SECTION 1: QUẢN LÝ XE & KINH DOANH (OWNER SUITE) ──────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dành Cho Chủ Xe',
                      style: AppTypography.headingSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor),
                  boxShadow: isDark ? null : AppColors.shadowSm,
                ),
                child: Column(
                  children: [
                    _MenuActionItem(
                      icon: Icons.directions_car_filled_rounded,
                      iconColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primary,
                      title: 'Đăng ký & Quản lý xe',
                      subtitle:
                          'Danh sách xe cho thuê, giá thuê và trạng thái xe',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RentalManagementScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 64, color: borderColor),
                    _MenuActionItem(
                      icon: Icons.assignment_rounded,
                      iconColor: isDark
                          ? AppColors.darkAccent
                          : AppColors.accent,
                      title: 'Đơn đặt xe của tôi',
                      subtitle: 'Xem duyệt các yêu cầu thuê từ khách hàng',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OwnerBookingListScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── SECTION 2: CÀI ĐẶT & TÀI KHOẢN ─────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkAccent
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tài Khoản & Bảo Mật',
                      style: AppTypography.headingSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor),
                  boxShadow: isDark ? null : AppColors.shadowSm,
                ),
                child: Column(
                  children: [
                    _MenuActionItem(
                      icon: Icons.badge_outlined,
                      iconColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primaryLight,
                      title: 'Thông tin tài khoản & CCCD',
                      subtitle: 'Xem hồ sơ cá nhân và số định danh',
                      onTap: _showAccountDetail,
                    ),
                    Divider(height: 1, indent: 64, color: borderColor),
                    _MenuActionItem(
                      icon: Icons.face_rounded,
                      iconColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primary,
                      title: 'Đổi ảnh đại diện',
                      subtitle: 'Tùy chọn phong cách biểu tượng đại diện',
                      onTap: _showAvatarPicker,
                    ),
                    Divider(height: 1, indent: 64, color: borderColor),
                    _MenuActionItem(
                      icon: Icons.lock_outline_rounded,
                      iconColor: isDark
                          ? AppColors.darkWarning
                          : AppColors.warning,
                      title: 'Đổi mật khẩu',
                      subtitle: 'Cập nhật mật khẩu để tăng bảo mật tài khoản',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 64, color: borderColor),
                    _MenuActionItem(
                      icon: Icons.palette_outlined,
                      iconColor: isDark
                          ? AppColors.darkAccent
                          : AppColors.accent,
                      title: 'Chế độ giao diện',
                      subtitle: themeController.themeMode == ThemeMode.dark
                          ? 'Giao diện Tối'
                          : (themeController.themeMode == ThemeMode.light
                                ? 'Giao diện Sáng '
                                : 'Tự động'),
                      onTap: _showThemePicker,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── SECTION 3: HỖ TRỢ & PHÁP LÝ ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSecondary
                            : AppColors.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hỗ Trợ & Pháp Lý',
                      style: AppTypography.headingSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor),
                  boxShadow: isDark ? null : AppColors.shadowSm,
                ),
                child: Column(
                  children: [
                    _MenuActionItem(
                      icon: Icons.support_agent_rounded,
                      iconColor: isDark
                          ? AppColors.darkSuccess
                          : AppColors.success,
                      title: 'Trung tâm trợ giúp 24/7',
                      subtitle: 'Tổng đài giải đáp thắc mắc và xử lý sự cố',
                      onTap: () => _showSimpleMessage(
                        'Hỗ trợ khách hàng',
                        'Hotline CSKH: 1900 6868\nEmail: hotro@carnow.vn\nThời gian làm việc: 24/7.',
                      ),
                    ),
                    Divider(height: 1, indent: 64, color: borderColor),
                    _MenuActionItem(
                      icon: Icons.gavel_rounded,
                      iconColor: isDark
                          ? AppColors.darkSecondary
                          : AppColors.textSecondary,
                      title: 'Điều khoản dịch vụ & Chính sách bảo mật',
                      subtitle:
                          'Quy định đặt thuê xe và điều kiện hoạt động nền tảng',
                      onTap: () => _showSimpleMessage(
                        'Điều khoản & Chính sách',
                        'CarNow cam kết bảo vệ toàn vẹn dữ liệu cá nhân của người dùng và đảm bảo giao dịch thuê xe minh bạch, hợp pháp.',
                      ),
                    ),
                    Divider(height: 1, indent: 64, color: borderColor),
                    _MenuActionItem(
                      icon: Icons.delete_outline_rounded,
                      iconColor: isDark
                          ? AppColors.darkDanger
                          : AppColors.danger,
                      title: 'Yêu cầu xoá tài khoản',
                      subtitle:
                          'Gửi yêu cầu xoá dữ liệu vĩnh viễn khỏi hệ thống',
                      danger: true,
                      onTap: () => _showSimpleMessage(
                        'Yêu cầu xóa tài khoản',
                        'Yêu cầu xoá tài khoản sẽ được tiếp nhận và xử lý trong vòng 24h làm việc sau khi kiểm tra không còn đơn xe đang thực hiện.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              AppButton(
                text: 'Đăng xuất tài khoản',
                variant: AppButtonVariant.outline,
                width: double.infinity,
                onPressed: _logout,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'CarNow Version 2.4.0 • Build 2026',
                  style: AppTypography.caption.copyWith(color: textTertiary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuActionItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;
  final Widget? trailing;

  const _MenuActionItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);
    final textMuted = AppColors.getTextMuted(context);

    return TapScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.16 : 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: danger ? AppColors.danger : textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 6),
            ],
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: danger ? AppColors.danger : textMuted,
            ),
          ],
        ),
      ),
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
                        color: preset.color.withValues(alpha: 0.22),
                        border: Border.all(
                          color: preset.color.withValues(alpha: 0.55),
                          width: 2.2,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = AppColors.getSurface(context);
    final borderColor = AppColors.getBorder(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                    color: borderColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(color: textSecondary, height: 1.5),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: textSecondary, height: 1.45)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getSurface(context);
    final borderColor = AppColors.getBorder(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);
    final color = danger
        ? AppColors.getDanger(context)
        : AppColors.getPrimary(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TapScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
            boxShadow: isDark
                ? null
                : [
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
                  color: color.withValues(alpha: isDark ? 0.16 : 0.08),
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
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textSecondary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowBg = AppColors.getSurfaceSecondary(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rowBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
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
                color: valueColor ?? textPrimary,
              ),
            ),
          ),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = AppColors.getSurface(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);
    final dividerColor = AppColors.getDivider(context);

    Color borderColor;
    IconData icon;
    String title;
    String subtitle;
    String buttonText;

    switch (status) {
      case VerificationStatus.unverified:
        borderColor = AppColors.getWarning(context);
        icon = Icons.warning_amber_rounded;
        title = 'Xác minh danh tính để bắt đầu thuê xe';
        subtitle = 'Nộp CCCD & Bằng lái xe để mở khoá tính năng đặt thuê xe';
        buttonText = 'Xác minh ngay';
        break;
      case VerificationStatus.pending:
        borderColor = AppColors.getPrimary(context);
        icon = Icons.access_time_rounded;
        title = 'Hồ sơ đang được xét duyệt';
        final timeStr = data.submittedAt != null
            ? DateFormat('HH:mm dd/MM').format(data.submittedAt!)
            : 'mới đây';
        subtitle = 'Đã gửi lúc $timeStr • Dự kiến duyệt trong vòng 24h';
        buttonText = 'Xem hồ sơ';
        break;
      case VerificationStatus.verified:
        borderColor = AppColors.getSuccess(context);
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
        borderColor = AppColors.getDanger(context);
        icon = Icons.cancel_rounded;
        title = 'Hồ sơ bị từ chối';
        subtitle =
            data.rejectionReason ??
            'Thông tin hoặc ảnh giấy tờ không đủ điều kiện xét duyệt.';
        buttonText = 'Xem & Nộp lại';
        break;
      case VerificationStatus.expired:
        borderColor = AppColors.getWarning(context);
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
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor.withValues(alpha: isDark ? 0.6 : 0.4),
            width: 1.2,
          ),
          boxShadow: isDark ? null : AppColors.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: isDark ? 0.20 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: borderColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleSmall.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: AppTypography.caption.copyWith(
                          color: textSecondary,
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
            Divider(height: 1, color: dividerColor),
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
                    color: borderColor.withValues(alpha: 0.10),
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

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.getPrimary(context);
    final surfaceColor = AppColors.getSurface(context);
    final borderColor = AppColors.getBorder(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);

    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.10)
              : surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : surfaceColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? activeColor : textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: activeColor, size: 22),
          ],
        ),
      ),
    );
  }
}
