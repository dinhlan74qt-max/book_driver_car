import 'dart:async';

import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/wallet/domain/entities/deposit_result_entity.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/deposit_bloc.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/deposit_event.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/deposit_state.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:book_drive_car/features/wallet/presentation/view/wallet_deposit_qr_screen.dart';
import 'package:book_drive_car/shared/data/mock_data/mock_data.dart';
import 'package:book_drive_car/shared/data/models/wallet_transaction_model.dart';
import 'package:book_drive_car/shared/widget/staggered_fade_in.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late final List<WalletTransaction> _transactions;

  final TextEditingController _customAmountController = TextEditingController();
  final List<int> _quickAmounts = const [100000, 200000, 500000, 1000000];

  late final AnimationController _panelController;

  bool _panelOpen = false;
  bool _isFormattingDepositAmount = false;
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
    _transactions = List.of(MockData.transactions.reversed);
    _panelController = AnimationController(
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
    _customAmountController.dispose();
    _walletBloc.close();
    _depositBloc.close();
    super.dispose();
  }

  void _togglePanel() {
    if (_depositBloc.state is DepositLoading) return;
    setState(() => _panelOpen = !_panelOpen);
    if (_panelOpen) {
      _panelController.forward();
    } else {
      _panelController.reverse();
    }
  }

  void _selectQuickAmount(int amount) {
    final formatted = NumberFormat.decimalPattern('vi_VN').format(amount);
    setState(() {
      _selectedAmount = amount;
    });
    _isFormattingDepositAmount = true;
    _customAmountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    _isFormattingDepositAmount = false;
  }

  void _onCustomAmountChanged(String value) {
    if (_isFormattingDepositAmount) return;

    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      if (_selectedAmount != null) {
        setState(() => _selectedAmount = null);
      }
      return;
    }

    final parsedAmount = int.tryParse(digitsOnly);
    final formatted = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(parsedAmount ?? 0);

    if (formatted != value) {
      _isFormattingDepositAmount = true;
      _customAmountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      _isFormattingDepositAmount = false;
    }

    final matchedQuickAmount = _quickAmounts.contains(parsedAmount)
        ? parsedAmount
        : null;
    if (_selectedAmount != matchedQuickAmount) {
      setState(() => _selectedAmount = matchedQuickAmount);
    }
  }

  void _refreshWallet() {
    _walletBloc.add(const WalletRequested());
  }

  Future<void> _showWithdrawSheetV2() async {
    final rootContext = context;
    final bankController = TextEditingController();
    final accountNumberController = TextEditingController();
    final accountNameController = TextEditingController();
    final amountController = TextEditingController();
    bool isFormattingAmount = false;

    void formatAmountField() {
      if (isFormattingAmount) return;

      final digitsOnly = amountController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      if (digitsOnly.isEmpty) return;

      final formatted = NumberFormat.decimalPattern(
        'vi_VN',
      ).format(int.parse(digitsOnly));
      if (formatted == amountController.text) return;

      isFormattingAmount = true;
      amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      isFormattingAmount = false;
    }

    amountController.addListener(formatAmountField);

    await showModalBottomSheet<void>(
      context: rootContext,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      requestFocus: false,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: FractionallySizedBox(
                heightFactor: 0.84,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
                      const Text(
                        'Rút tiền',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Điền thông tin ngân hàng và số tiền muốn rút.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: bankController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Tên ngân hàng',
                          hintText: 'Ví dụ: Vietcombank',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: accountNumberController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Số tài khoản',
                          hintText: 'Nhập số tài khoản',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: accountNameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Tên chủ tài khoản',
                          hintText: 'Nhập họ và tên',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Số tiền muốn rút',
                          hintText: 'Ví dụ: 500.000',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final bankName = bankController.text.trim();
                            final accountNumber = accountNumberController.text
                                .trim();
                            final accountName = accountNameController.text
                                .trim();
                            final amount =
                                int.tryParse(
                                  amountController.text.replaceAll(
                                    RegExp(r'[^0-9]'),
                                    '',
                                  ),
                                ) ??
                                0;

                            if (bankName.isEmpty ||
                                accountNumber.isEmpty ||
                                accountName.isEmpty ||
                                amount <= 0) {
                              ScaffoldMessenger.of(rootContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Vui lòng nhập đầy đủ thông tin rút tiền.',
                                  ),
                                ),
                              );
                              return;
                            }

                            Navigator.of(sheetContext).pop();
                            ScaffoldMessenger.of(rootContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã gửi yêu cầu rút ${NumberFormat.decimalPattern('vi_VN').format(amount)} đ đến $bankName.',
                                ),
                              ),
                            );
                          },
                          child: const Text('Xác nhận rút tiền'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    amountController.removeListener(formatAmountField);
    bankController.dispose();
    accountNumberController.dispose();
    accountNameController.dispose();
    amountController.dispose();
  }

  Future<void> _showWithdrawSheet() async {
    final amountController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.42,
          minChildSize: 0.34,
          maxChildSize: 0.7,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  20 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
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
                    const Text(
                      'Rút tiền',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nhập số tiền muốn rút từ ví. Màn hình này đang ở dạng giao diện, bạn có thể nối API rút tiền sau.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Số tiền muốn rút',
                        hintText: 'Ví dụ: 500000',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Tính năng rút tiền sẽ được kết nối sau.',
                              ),
                            ),
                          );
                        },
                        child: const Text('Xác nhận rút tiền'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    amountController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error)));
              }
            },
          ),
          BlocListener<DepositBloc, DepositState>(
            listener: (context, state) async {
              if (state is DepositSuccess) {
                await _openDepositQr(state.result);
              }

              if (state is DepositFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error)));
              }
            },
          ),
        ],
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0E1118),
                    Color(0xFF151A24),
                    Color(0xFFF5F6F8),
                  ],
                  stops: [0.0, 0.34, 1.0],
                ),
              ),
            ),
            Positioned(
              top: -80,
              right: -55,
              child: _LuxuryGlow(
                size: 220,
                colors: [
                  AppColors.headlightAmber.withOpacity(0.22),
                  AppColors.accent.withOpacity(0.0),
                ],
              ),
            ),
            Positioned(
              top: 150,
              left: -70,
              child: _LuxuryGlow(
                size: 180,
                colors: [
                  AppColors.pageAccents[2].withOpacity(0.15),
                  AppColors.pageAccents[2].withOpacity(0.0),
                ],
              ),
            ),
            RefreshIndicator(
              color: AppColors.headlightAmber,
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
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                    children: [
                      if (isRefreshing) ...[
                        const SizedBox(height: 2),
                        const ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                          child: LinearProgressIndicator(minHeight: 2.5),
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
                      const SizedBox(height: 16),
                      StaggeredFadeIn(
                        index: 1,
                        child: Row(
                          children: [
                            Expanded(
                              child: _WalletActionTile(
                                title: 'Nạp tiền',
                                subtitle:
                                    'Chọn số tiền rồi mở mã QR từ server.',
                                icon: Icons.qr_code_2_rounded,
                                accent: AppColors.headlightAmber,
                                onTap: _togglePanel,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _WalletActionTile(
                                title: 'Rút tiền',
                                subtitle:
                                    'Rút tiền từ số dư khả dụng trong ví.',
                                icon: Icons.payments_outlined,
                                accent: AppColors.pageAccents[2],
                                onTap: _showWithdrawSheetV2,
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
                      const SizedBox(height: 18),
                      StaggeredFadeIn(
                        index: 2,
                        child: const _SectionHeader(
                          title: 'Lịch sử giao dịch',
                          action: 'Mới nhất',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._transactions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final tx = entry.value;
                        final isPositive = tx.amount > 0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: StaggeredFadeIn(
                            index: 3 + index,
                            child: _TransactionCard(
                              title: tx.title,
                              dateText: DateFormat(
                                'dd/MM/yyyy',
                              ).format(tx.createdAt),
                              amountText:
                                  '${isPositive ? '+' : ''}${priceFormat.format(tx.amount)}đ',
                              isPositive: isPositive,
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF11161F), Color(0xFF1A2230), Color(0xFF0F1722)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.34),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -12,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.headlightAmber.withOpacity(0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.headlightAmber.withOpacity(0.95),
                          AppColors.accent.withOpacity(0.9),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const _HeroBadge(
                    icon: Icons.workspace_premium_rounded,
                    label: 'Premium Wallet',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Ví của tôi',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Số dư được tải từ server khi mở ví. Kéo xuống để refresh nhanh ngay trên đầu trang.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _HeroStat(
                      label: hasError
                          ? 'Không tải được số dư'
                          : 'Số dư hiện tại',
                      value: isLoading
                          ? 'Đang tải...'
                          : hasError
                          ? (errorText ?? 'Vui lòng thử lại')
                          : '${priceFormat.format(balance)}đ',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeroStat(
                      label: 'Trạng thái',
                      value: isLoading ? 'Đang đồng bộ' : 'Sẵn sàng',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.headlightAmber),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.68),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
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
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.98),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withOpacity(0.75)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [accent.withOpacity(0.16), accent.withOpacity(0.06)],
                ),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 5),
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;

  const _SectionHeader({required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            action,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String title;
  final String dateText;
  final String amountText;
  final bool isPositive;

  const _TransactionCard({
    required this.title,
    required this.dateText,
    required this.amountText,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isPositive ? AppColors.success : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withOpacity(0.75)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
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
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isPositive ? Icons.south_west_rounded : Icons.north_east_rounded,
              size: 20,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amountText,
            style: TextStyle(
              fontSize: 13.8,
              color: accent,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFC),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn mệnh giá',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.7,
            children: quickAmounts.map((amount) {
              final isSelected = selectedAmount == amount;
              return TapScale(
                onTap: isLoading ? null : () => onSelectAmount(amount),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.border,
                      width: isSelected ? 1.4 : 1,
                    ),
                    color: isSelected
                        ? AppColors.accent.withOpacity(0.08)
                        : Colors.white,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${priceFormat.format(amount)}đ',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Text(
            'Hoặc nhập số tiền khác',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: !isLoading,
            keyboardType: TextInputType.number,
            onChanged: onCustomChanged,
            decoration: const InputDecoration(hintText: 'Nhập số tiền'),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onConfirm,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Xác nhận nạp tiền'),
            ),
          ),
        ],
      ),
    );
  }
}
