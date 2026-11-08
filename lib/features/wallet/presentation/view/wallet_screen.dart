import 'dart:async';

import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/wallet/domain/entities/deposit_result_entity.dart';
import 'package:book_drive_car/features/wallet/domain/usecases/withdraw.dart';
import 'package:book_drive_car/features/wallet/domain/entities/withdraw_request_entity.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/deposit_bloc.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/deposit_event.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/deposit_state.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:book_drive_car/features/wallet/presentation/view/wallet_deposit_qr_screen.dart';
import 'package:book_drive_car/features/wallet/domain/entities/wallet_transaction_entity.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_empty_state.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/staggered_fade_in.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with TickerProviderStateMixin {
  late final WalletBloc _walletBloc;
  late final DepositBloc _depositBloc;
  List<WalletTransactionEntity> _transactions = const [];

  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _withdrawBankController = TextEditingController();
  final TextEditingController _withdrawAccountNumberController =
      TextEditingController();
  final TextEditingController _withdrawAccountNameController =
      TextEditingController();
  final TextEditingController _withdrawAmountController =
      TextEditingController();
  final List<int> _quickAmounts = const [100000, 200000, 500000, 1000000];

  late final AnimationController _panelController;
  late final AnimationController _withdrawPanelController;

  bool _panelOpen = false;
  bool _withdrawPanelOpen = false;
  bool _isFormattingDepositAmount = false;
  bool _isFormattingWithdrawAmount = false;
  bool _isSubmittingWithdraw = false;
  int? _selectedAmount;
  int? _lastSubmittedAmount;
  int? _currentBalance;
  String? _walletError;
  Completer<void>? _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _walletBloc = sl<WalletBloc>();
    _depositBloc = sl<DepositBloc>();
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _withdrawPanelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _walletBloc.add(const WalletRequested());
      }
    });
  }

  @override
  void dispose() {
    _panelController.dispose();
    _withdrawPanelController.dispose();
    _customAmountController.dispose();
    _withdrawBankController.dispose();
    _withdrawAccountNumberController.dispose();
    _withdrawAccountNameController.dispose();
    _withdrawAmountController.dispose();
    _walletBloc.close();
    _depositBloc.close();
    super.dispose();
  }

  void _togglePanel() {
    if (_depositBloc.state is DepositLoading) return;
    if (_withdrawPanelOpen) {
      setState(() => _withdrawPanelOpen = false);
      _withdrawPanelController.reverse();
    }
    setState(() => _panelOpen = !_panelOpen);
    if (_panelOpen) {
      _panelController.forward();
    } else {
      _panelController.reverse();
    }
  }

  void _toggleWithdrawPanel() {
    if (_isSubmittingWithdraw) return;
    if (_panelOpen) {
      setState(() => _panelOpen = false);
      _panelController.reverse();
    }
    setState(() => _withdrawPanelOpen = !_withdrawPanelOpen);
    if (_withdrawPanelOpen) {
      _withdrawPanelController.forward();
    } else {
      _withdrawPanelController.reverse();
    }
  }

  void _selectQuickAmount(int amount) {
    setState(() {
      _selectedAmount = amount;
      _isFormattingDepositAmount = true;
      _customAmountController.text =
          NumberFormat.decimalPattern('vi_VN').format(amount);
      _isFormattingDepositAmount = false;
    });
  }

  void _onCustomAmountChanged(String value) {
    if (_isFormattingDepositAmount) return;

    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      setState(() => _selectedAmount = null);
      return;
    }

    final parsed = int.tryParse(digits) ?? 0;
    final formatted = NumberFormat.decimalPattern('vi_VN').format(parsed);

    _isFormattingDepositAmount = true;
    _customAmountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    _isFormattingDepositAmount = false;

    setState(() {
      _selectedAmount = _quickAmounts.contains(parsed) ? parsed : null;
    });
  }

  void _onWithdrawAmountChanged(String value) {
    if (_isFormattingWithdrawAmount) return;

    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;

    final parsed = int.tryParse(digits) ?? 0;
    final formatted = NumberFormat.decimalPattern('vi_VN').format(parsed);

    _isFormattingWithdrawAmount = true;
    _withdrawAmountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    _isFormattingWithdrawAmount = false;
  }

  void _refreshWallet() {
    _walletBloc.add(const WalletRequested());
  }

  Future<void> _submitWithdraw() async {
    if (_isSubmittingWithdraw) return;

    final bankName = _withdrawBankController.text.trim();
    final accountNumber = _withdrawAccountNumberController.text.trim();
    final accountName = _withdrawAccountNameController.text.trim();
    final amount =
        int.tryParse(
          _withdrawAmountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;

    if (bankName.isEmpty ||
        accountNumber.isEmpty ||
        accountName.isEmpty ||
        amount <= 0) {
      AppToast.show(
        context,
        message: 'Vui lòng nhập đầy đủ thông tin rút tiền.',
        type: AppToastType.error,
      );
      return;
    }

    setState(() {
      _isSubmittingWithdraw = true;
    });

    try {
      final message = await sl<Withdraw>()
          .call(
            WithdrawRequestEntity(
              amount: amount,
              bankName: bankName,
              bankAccount: accountNumber,
              accountHolder: accountName,
            ),
          )
          .timeout(const Duration(seconds: 12));

      if (!mounted) return;

      setState(() {
        _withdrawPanelOpen = false;
      });
      _withdrawPanelController.reverse();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppToast.show(context, message: message, type: AppToastType.success);
        _refreshWallet();
      });
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingWithdraw = false;
        });
      }
    }
  }

  Future<void> _handlePullToRefresh() {
    final completer = Completer<void>();
    _refreshCompleter = completer;
    _refreshWallet();
    return completer.future;
  }

  void _confirmTopup() {
    if (_depositBloc.state is DepositLoading) return;

    final rawAmountText = _customAmountController.text.trim();
    final parsedCustomAmount = int.tryParse(
      rawAmountText.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    final amount = _selectedAmount ?? parsedCustomAmount ?? 0;
    if (amount <= 0) {
      AppToast.show(
        context,
        message: 'Vui lòng nhập số tiền hợp lệ',
        type: AppToastType.warning,
      );
      return;
    }

    _lastSubmittedAmount = amount;
    _depositBloc.add(DepositSubmitted(amount));
  }

  Future<void> _openDepositQr(DepositResultEntity result) async {
    final amount = _lastSubmittedAmount ?? 0;
    setState(() {
      _panelOpen = false;
      _selectedAmount = null;
      _customAmountController.clear();
    });
    _panelController.reverse();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WalletDepositQrScreen(
          amount: amount,
          qrCodeUrl: result.qrCodeUrl,
          transactionCode: result.transactionCode,
        ),
      ),
    );

    if (!mounted) return;
    _refreshWallet();
  }

  void _showTransactionDetail(BuildContext context, WalletTransactionEntity tx) {
    final priceFormat = NumberFormat.decimalPattern('vi_VN');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TransactionDetailSheet(
        tx: tx,
        priceFormat: priceFormat,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.decimalPattern('vi_VN');

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _walletBloc),
        BlocProvider.value(value: _depositBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<WalletBloc, WalletState>(
            listener: (context, state) {
              if (state is WalletLoaded) {
                _currentBalance = state.wallet.balance;
                _transactions = state.history.reversed.toList();
                _walletError = null;
                if (_refreshCompleter != null &&
                    !(_refreshCompleter?.isCompleted ?? true)) {
                  _refreshCompleter?.complete();
                }
              }

              if (state is WalletFailure) {
                _walletError = state.error;
                if (_refreshCompleter != null &&
                    !(_refreshCompleter?.isCompleted ?? true)) {
                  _refreshCompleter?.complete();
                }
                AppToast.show(context, message: state.error, type: AppToastType.error);
              }
            },
          ),
          BlocListener<DepositBloc, DepositState>(
            listener: (context, state) async {
              if (state is DepositSuccess) {
                await _openDepositQr(state.result);
              }

              if (state is DepositFailure) {
                AppToast.show(context, message: state.error, type: AppToastType.error);
              }
            },
          ),
        ],
        child: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
            final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

            return Scaffold(
              backgroundColor: bgColor,
              body: SafeArea(
                child: RefreshIndicator(
                  color: primaryColor,
                  onRefresh: _handlePullToRefresh,
                  child: BlocBuilder<WalletBloc, WalletState>(
                    builder: (context, state) {
                      final bool isInitialLoading =
                          state is WalletLoading && _currentBalance == null;
                      final bool isRefreshing =
                          state is WalletLoading && _currentBalance != null;
                      final int displayBalance = _currentBalance ?? 0;

                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        children: [
                          if (isRefreshing) ...[
                            const ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(999)),
                              child: LinearProgressIndicator(
                                minHeight: 2.5,
                                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                          StaggeredFadeIn(
                            index: 0,
                            child: _WalletHeroCard(
                              balance: displayBalance,
                              isLoading: isInitialLoading,
                              hasError:
                                  _walletError != null && _currentBalance == null,
                              errorText: _walletError,
                              priceFormat: priceFormat,
                            ),
                          ),
                          const SizedBox(height: 18),
                          StaggeredFadeIn(
                            index: 1,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _WalletActionTile(
                                    title: 'Nạp tiền',
                                    subtitle: 'Tạo mã QR thanh toán nhanh',
                                    icon: Icons.qr_code_2_rounded,
                                    accent: AppColors.primary,
                                    onTap: _togglePanel,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _WalletActionTile(
                                    title: 'Rút tiền',
                                    subtitle: 'Rút về tài khoản ngân hàng',
                                    icon: Icons.account_balance_rounded,
                                    accent: AppColors.accent,
                                    onTap: _toggleWithdrawPanel,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizeTransition(
                            sizeFactor: CurvedAnimation(
                              parent: _panelController,
                              curve: Curves.easeInOutCubic,
                            ),
                            axisAlignment: -1,
                            child: FadeTransition(
                              opacity: _panelController,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: _TopupPanel(
                                  quickAmounts: _quickAmounts,
                                  selectedAmount: _selectedAmount,
                                  controller: _customAmountController,
                                  isLoading: _depositBloc.state is DepositLoading,
                                  onSelectAmount: _selectQuickAmount,
                                  onCustomChanged: _onCustomAmountChanged,
                                  onConfirm: _confirmTopup,
                                ),
                              ),
                            ),
                          ),
                          SizeTransition(
                            sizeFactor: CurvedAnimation(
                              parent: _withdrawPanelController,
                              curve: Curves.easeInOutCubic,
                            ),
                            axisAlignment: -1,
                            child: FadeTransition(
                              opacity: _withdrawPanelController,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: _WithdrawPanel(
                                  bankController: _withdrawBankController,
                                  accountNumberController:
                                      _withdrawAccountNumberController,
                                  accountNameController:
                                      _withdrawAccountNameController,
                                  amountController: _withdrawAmountController,
                                  isLoading: _isSubmittingWithdraw,
                                  onAmountChanged: _onWithdrawAmountChanged,
                                  onConfirm: _submitWithdraw,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          StaggeredFadeIn(
                            index: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Lịch sử giao dịch',
                                  style: AppTypography.titleLarge,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    'Gần đây',
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (_transactions.isEmpty)
                            const StaggeredFadeIn(
                              index: 3,
                              child: AppEmptyState(
                                icon: Icons.receipt_long_rounded,
                                title: 'Chưa có lịch sử giao dịch',
                                subtitle: 'Khi nạp tiền hoặc hoàn tất đơn thuê, dữ liệu sẽ hiển thị ở đây.',
                              ),
                            )
                          else
                            ..._transactions.asMap().entries.map((entry) {
                              final index = entry.key;
                              final tx = entry.value;
                              final isPositive = tx.isCredit;
                              final createdAtText = tx.createdAt == null
                                  ? 'Vừa xong'
                                  : DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt!);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: StaggeredFadeIn(
                                  index: 3 + index,
                                  child: _TransactionCard(
                                    title: tx.description,
                                    dateText: createdAtText,
                                    amountText:
                                        '${isPositive ? '+' : '-'}${priceFormat.format(tx.amount.abs())}đ',
                                    isPositive: isPositive,
                                    onTap: () => _showTransactionDetail(context, tx),
                                  ),
                                ),
                              );
                            }),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WalletHeroCard extends StatelessWidget {
  final int balance;
  final bool isLoading;
  final bool hasError;
  final String? errorText;
  final NumberFormat priceFormat;

  const _WalletHeroCard({
    required this.balance,
    required this.isLoading,
    required this.hasError,
    required this.errorText,
    required this.priceFormat,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.accent;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF06111C),
                  Color(0xFF0B1F33),
                  Color(0xFF13324F),
                ]
              : const [
                  Color(0xFF082236),
                  AppColors.primary,
                  Color(0xFF1B4F72),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary).withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: accentColor.withValues(alpha: 0.2),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Ví CarNow Pay',
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      size: 13,
                      color: accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Bảo mật',
                      style: AppTypography.dataLabel.copyWith(
                        color: Colors.white,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Số dư khả dụng',
            style: AppTypography.caption.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isLoading
                ? 'Đang đồng bộ...'
                : hasError
                    ? (errorText ?? 'Lỗi tải số dư')
                    : '${priceFormat.format(balance)}đ',
            style: AppTypography.displayLarge.copyWith(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _WalletActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? null : AppColors.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: accent.withValues(alpha: isDark ? 0.2 : 0.10),
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                fontSize: 15.5,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                fontSize: 11.5,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String title;
  final String dateText;
  final String amountText;
  final bool isPositive;
  final VoidCallback? onTap;

  const _TransactionCard({
    required this.title,
    required this.dateText,
    required this.amountText,
    required this.isPositive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final accent = isPositive
        ? (isDark ? const Color(0xFF81C69A) : AppColors.success)
        : (isDark ? const Color(0xFFE18B83) : AppColors.danger);

    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? null : AppColors.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.2 : 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isPositive ? Icons.south_west_rounded : Icons.north_east_rounded,
                size: 20,
                color: accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateText,
                    style: AppTypography.caption.copyWith(color: textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              amountText,
              style: AppTypography.priceMedium.copyWith(
                fontSize: 15,
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: textSecondary.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionDetailSheet extends StatelessWidget {
  final WalletTransactionEntity tx;
  final NumberFormat priceFormat;

  const _TransactionDetailSheet({
    required this.tx,
    required this.priceFormat,
  });

  String _formatFullDate(DateTime? dt) {
    if (dt == null) return 'Không xác định';
    return DateFormat('HH:mm:ss - dd/MM/yyyy').format(dt);
  }

  String _typeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'DEPOSIT':
      case 'TOPUP':
        return 'Nạp tiền vào ví (VietQR)';
      case 'WITHDRAW':
        return 'Rút tiền về tài khoản';
      case 'PAYMENT':
        return 'Thanh toán thuê xe';
      case 'REFUND':
        return 'Hoàn tiền giao dịch';
      case 'PENALTY':
      case 'FEE':
        return 'Khấu trừ phí';
      default:
        return type.isEmpty ? 'Giao dịch ví' : type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final bgColor =
        isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final isPositive = tx.isCredit;
    final accentColor = isPositive
        ? (isDark ? const Color(0xFF81C69A) : AppColors.success)
        : (isDark ? const Color(0xFFE18B83) : AppColors.danger);

    final txCode = 'GD-${tx.id.toString().padLeft(6, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chi tiết giao dịch',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hero Amount Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accentColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isDark ? 0.25 : 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPositive
                        ? Icons.south_west_rounded
                        : Icons.north_east_rounded,
                    color: accentColor,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${isPositive ? '+' : '-'}${priceFormat.format(tx.amount.abs())} đ',
                  style: AppTypography.priceLarge.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Thành công',
                    style: AppTypography.caption.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Information Table Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                _buildRow(
                  label: 'Mã giao dịch',
                  valueWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        txCode,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      TapScale(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: txCode));
                          AppToast.show(
                            context,
                            message: 'Đã sao chép mã giao dịch: $txCode',
                            type: AppToastType.success,
                          );
                        },
                        child: Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  textSecondary: textSecondary,
                ),
                Divider(height: 20, color: borderColor),
                _buildRow(
                  label: 'Loại giao dịch',
                  valueText: _typeLabel(tx.transactionType),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                Divider(height: 20, color: borderColor),
                _buildRow(
                  label: 'Thời gian',
                  valueText: _formatFullDate(tx.createdAt),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                if (tx.walletBalance != null) ...[
                  Divider(height: 20, color: borderColor),
                  _buildRow(
                    label: 'Số dư ví sau GD',
                    valueText: '${priceFormat.format(tx.walletBalance)} đ',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ],
                Divider(height: 20, color: borderColor),
                _buildRow(
                  label: 'Nội dung',
                  valueText: tx.description.isNotEmpty
                      ? tx.description
                      : 'Không có ghi chú',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isMultiline: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Close Button
          AppButton(
            text: 'Đóng',
            width: double.infinity,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required String label,
    String? valueText,
    Widget? valueWidget,
    Color? textPrimary,
    required Color textSecondary,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment:
          isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: textSecondary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: valueWidget ??
              Text(
                valueText ?? '',
                textAlign: TextAlign.end,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
        ),
      ],
    );
  }
}

class _TopupPanel extends StatelessWidget {
  final List<int> quickAmounts;
  final int? selectedAmount;
  final TextEditingController controller;
  final bool isLoading;
  final ValueChanged<int> onSelectAmount;
  final ValueChanged<String> onCustomChanged;
  final VoidCallback onConfirm;

  const _TopupPanel({
    required this.quickAmounts,
    required this.selectedAmount,
    required this.controller,
    required this.isLoading,
    required this.onSelectAmount,
    required this.onCustomChanged,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.decimalPattern('vi_VN');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final chipBg = isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSubtle;
    final selectedChipBg = isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? null : AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn mệnh giá nạp',
            style: AppTypography.titleMedium.copyWith(color: textPrimary),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: quickAmounts.map((amount) {
              final isSelected = selectedAmount == amount;
              return TapScale(
                onTap: isLoading ? null : () => onSelectAmount(amount),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? primaryColor : borderColor,
                      width: isSelected ? 1.6 : 1,
                    ),
                    color: isSelected ? selectedChipBg : chipBg,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${priceFormat.format(amount)}đ',
                    style: AppTypography.titleSmall.copyWith(
                      color: isSelected ? primaryColor : textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Hoặc nhập số tiền khác',
            style: AppTypography.caption.copyWith(color: textSecondary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: !isLoading,
            keyboardType: TextInputType.number,
            style: TextStyle(color: textPrimary),
            onChanged: onCustomChanged,
            decoration: const InputDecoration(
              hintText: 'Nhập số tiền (đ)',
              prefixIcon: Icon(Icons.payments_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            text: 'Xác nhận tạo mã nạp',
            width: double.infinity,
            isLoading: isLoading,
            onPressed: onConfirm,
            icon: const Icon(Icons.qr_code_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _WithdrawPanel extends StatelessWidget {
  final TextEditingController bankController;
  final TextEditingController accountNumberController;
  final TextEditingController accountNameController;
  final TextEditingController amountController;
  final bool isLoading;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onConfirm;

  const _WithdrawPanel({
    required this.bankController,
    required this.accountNumberController,
    required this.accountNameController,
    required this.amountController,
    required this.isLoading,
    required this.onAmountChanged,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? null : AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rút tiền về tài khoản ngân hàng',
            style: AppTypography.titleMedium.copyWith(color: textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Nhập thông tin tài khoản nhận tiền và số tiền muốn rút.',
            style: AppTypography.body.copyWith(color: textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: bankController,
            enabled: !isLoading,
            style: TextStyle(color: textPrimary),
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Tên ngân hàng',
              hintText: 'Ví dụ: Vietcombank, MBBank...',
              prefixIcon: Icon(Icons.account_balance_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: accountNumberController,
            enabled: !isLoading,
            style: TextStyle(color: textPrimary),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Số tài khoản',
              hintText: 'Nhập số tài khoản ngân hàng',
              prefixIcon: Icon(Icons.numbers_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: accountNameController,
            enabled: !isLoading,
            style: TextStyle(color: textPrimary),
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Tên chủ tài khoản',
              hintText: 'NGUYEN VAN A',
              prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            enabled: !isLoading,
            style: TextStyle(color: textPrimary),
            keyboardType: TextInputType.number,
            onChanged: onAmountChanged,
            decoration: const InputDecoration(
              labelText: 'Số tiền muốn rút',
              hintText: 'Ví dụ: 500.000',
              prefixIcon: Icon(Icons.monetization_on_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            text: 'Xác nhận rút tiền',
            variant: AppButtonVariant.secondary,
            width: double.infinity,
            isLoading: isLoading,
            onPressed: onConfirm,
            icon: const Icon(Icons.check_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}
