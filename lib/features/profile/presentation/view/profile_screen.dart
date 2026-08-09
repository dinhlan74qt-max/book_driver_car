import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/auth/domain/entities/user_entity.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking_list_screen.dart';
import 'package:book_drive_car/features/profile/presentation/view/rental_management_screen.dart';
import 'package:book_drive_car/features/welcome/presentation/view/welcome_screen.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await sl<UserLocalStorage>().getUser();
    if (mounted) setState(() => _user = user);
  }

  Future<void> _showAccountDetail() async {
    final user = _user;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
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
              const Text('Tài khoản của tôi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              if (user != null) ...[
                _InfoRow(label: 'Họ tên', value: user.fullname ?? '—'),
                _InfoRow(label: 'Email', value: user.email.isNotEmpty ? user.email : '—'),
                _InfoRow(label: 'Số điện thoại', value: user.phone?.isNotEmpty == true ? user.phone! : '—'),
                if (user.cccd?.isNotEmpty == true)
                  _InfoRow(label: 'CCCD', value: user.cccd!),
                _InfoRow(label: 'Vai trò', value: user.role ?? 'user'),
                _InfoRow(label: 'Trạng thái', value: 'Đã xác thực', valueColor: AppColors.success),
              ] else
                const Text('Không thể tải thông tin tài khoản.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
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
            return Container(
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
                  const Text('Cập nhật avatar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text(
                    'Chọn một avatar phù hợp để làm mới hồ sơ cá nhân của bạn.',
                    style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
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
                        child: Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color: preset.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: active ? preset.color : AppColors.border, width: active ? 1.6 : 1),
                          ),
                          child: Icon(preset.icon, color: preset.color, size: 34),
                        ),
                      );
                    }),
                  ),
                ],
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
        return Container(
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
              const Text('Avatar & tài khoản', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text(
                'Bạn có thể xem thông tin tài khoản hoặc đổi avatar ngay tại đây.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Future.microtask(_showAccountDetail);
                  },
                  child: const Text('Xem tài khoản'),
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
                  child: const Text('Đổi avatar'),
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
        return Container(
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
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(message, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ),
            ],
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
        content: const Text('Bạn có muốn đăng xuất khỏi tài khoản hiện tại không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Đăng xuất')),
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
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final preset = _avatarPresets[_avatarIndex];
    final userName = _user?.fullname ?? '';
    final userEmail = _user?.email ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.85, red: 30),
                  AppColors.accent.withValues(alpha: 0.92),
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _showAvatarOptions,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
                            ),
                            child: Icon(preset.icon, color: Colors.white, size: 36),
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
                                border: Border.all(color: preset.color.withValues(alpha: 0.2)),
                              ),
                              child: Icon(Icons.edit_rounded, size: 14, color: preset.color),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TapScale(
                        onTap: _showAccountDetail,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    userName.isNotEmpty ? userName : 'Người dùng',
                                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: Colors.white),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail.isNotEmpty ? userEmail : '—',
                              style: const TextStyle(color: Colors.white70, fontSize: 13.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: const [
                                _ProfileBadge(label: 'Đã xác thực', icon: Icons.verified_rounded),
                                _ProfileBadge(label: 'Thành viên Pro', icon: Icons.workspace_premium_rounded),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _ActionTile(
            icon: Icons.directions_car_rounded,
            title: 'Đăng ký cho thuê xe',
            subtitle: 'Mở trang quản lý xe cho thuê của bạn',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RentalManagementScreen()),
              );
            },
          ),_ActionTile(
            icon: Icons.receipt_long_rounded,
            title: 'Quản lý đơn đặt xe',
            subtitle: 'Duyệt yêu cầu thuê & theo dõi các chuyến đi',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerBookingListScreen())),
          ),
          _ActionTile(
            icon: Icons.lock_reset_rounded,
            title: 'Đổi mật khẩu',
            subtitle: 'Cập nhật mật khẩu để bảo mật tài khoản',
            onTap: () => _showSimpleMessage('Đổi mật khẩu', 'Màn đổi mật khẩu sẽ được kết nối ở bước tiếp theo.'),
          ),
          _ActionTile(
            icon: Icons.delete_outline_rounded,
            title: 'Yêu cầu xóa tài khoản',
            subtitle: 'Gửi yêu cầu xóa dữ liệu tài khoản',
            danger: true,
            onTap: () => _showSimpleMessage('Xóa tài khoản', 'Bạn có thể gửi yêu cầu xóa tài khoản từ đây.'),
          ),
          const SizedBox(height: 18),
          Center(
            child: TapScale(
              onTap: _logout,
              child: Container(
                width: 220,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Đăng xuất',
                      style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AvatarPreset {
  final IconData icon;
  final Color color;

  const _AvatarPreset({
    required this.icon,
    required this.color,
  });
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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
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
                    Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
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
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
