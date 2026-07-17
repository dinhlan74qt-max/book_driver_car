import 'package:book_drive_car/core/shared/data/mock_data/mock_data.dart';
import 'package:book_drive_car/core/shared/data/models/wallet_transaction_model.dart';
import 'package:book_drive_car/core/shared/widget/staggered_fade_in.dart';
import 'package:book_drive_car/core/shared/widget/tap_scale.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with TickerProviderStateMixin {
  int _balance = MockData.initialWalletBalance;
  late List<WalletTransaction> _transactions;

  bool _panelOpen = false;
  int? _selectedAmount;
  final TextEditingController _customAmountController = TextEditingController();

  late final AnimationController _panelController;
  late final AnimationController _successController;
  bool _showSuccess = false;
  int _lastTopupAmount = 0;

  final List<int> _quickAmounts = const [100000, 200000, 500000, 1000000];

  @override
  void initState() {
    super.initState();
    _transactions = List.of(MockData.transactions.reversed);
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    _panelController.dispose();
    _successController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() => _panelOpen = !_panelOpen);
    if (_panelOpen) {
      _panelController.forward();
    } else {
      _panelController.reverse();
    }
  }

  void _selectQuickAmount(int amount) {
    setState(() {
      _selectedAmount = amount;
      _customAmountController.clear();
    });
  }

  Future<void> _confirmTopup() async {
    final amount = _selectedAmount ?? int.tryParse(_customAmountController.text) ?? 0;
    if (amount <= 0) return;

    setState(() {
      _showSuccess = true;
      _lastTopupAmount = amount;
    });
    _successController.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    setState(() {
      _balance += amount;
      _transactions.insert(
        0,
        WalletTransaction(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Nạp tiền qua VNPay',
          amount: amount,
          type: TxType.topup,
          createdAt: DateTime.now(),
        ),
      );
      _showSuccess = false;
      _panelOpen = false;
      _selectedAmount = null;
      _customAmountController.clear();
    });
    _panelController.reverse();
  }

  Future<void> _openWithdrawSheet() async {
    final amountController = TextEditingController();
    final bankController = TextEditingController();
    final accountController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: DraggableScrollableSheet(
            initialChildSize: 0.72,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
                    const Text('Rút tiền', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    const Text(
                      'Nhập số tiền và thông tin ngân hàng để tạo yêu cầu rút tiền.',
                      style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    const Text('Số tiền', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Nhập số tiền muốn rút'),
                    ),
                    const SizedBox(height: 14),
                    const Text('Tên ngân hàng', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: bankController,
                      decoration: const InputDecoration(hintText: 'Ví dụ: Vietcombank'),
                    ),
                    const SizedBox(height: 14),
                    const Text('Số tài khoản', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: accountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Nhập số tài khoản'),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final amount = int.tryParse(amountController.text.trim()) ?? 0;
                          if (amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
                            );
                            return;
                          }
                          if (amount > _balance) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Số dư không đủ để rút')),
                            );
                            return;
                          }

                          Navigator.of(context).pop();
                          setState(() {
                            _balance -= amount;
                            _transactions.insert(
                              0,
                              WalletTransaction(
                                id: 'wd_${DateTime.now().millisecondsSinceEpoch}',
                                title: 'Rút tiền về ${bankController.text.trim().isEmpty ? 'ngân hàng' : bankController.text.trim()}',
                                amount: -amount,
                                type: TxType.payment,
                                createdAt: DateTime.now(),
                              ),
                            );
                          });
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(content: Text('Đã tạo yêu cầu rút tiền')),
                          );
                        },
                        child: const Text('Tạo yêu cầu rút tiền'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    amountController.dispose();
    bankController.dispose();
    accountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.decimalPattern('vi_VN');

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            StaggeredFadeIn(
              index: 0,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withBlue(100),
                      AppColors.accent.withOpacity(0.9),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ví của tôi',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Quản lý số dư, nạp tiền và giao dịch một cách rõ ràng hơn.',
                      style: TextStyle(color: Colors.white.withOpacity(0.78), height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniMetric(
                            value: '${priceFormat.format(_balance)}đ',
                            label: 'Số dư hiện tại',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MiniMetric(
                            value: '${_transactions.length}',
                            label: 'Giao dịch',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            StaggeredFadeIn(
              index: 1,
              child: Row(
                children: [
                  Expanded(
                    child: TapScale(
                      onTap: _togglePanel,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
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
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.add_card_rounded, color: AppColors.primary),
                            ),
                            const SizedBox(height: 12),
                            const Text('Nạp tiền', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            const Text(
                              'Chọn mệnh giá nhanh hoặc nhập số tiền.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TapScale(
                      onTap: _openWithdrawSheet,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
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
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.payments_rounded, color: AppColors.accent),
                            ),
                            const SizedBox(height: 12),
                            const Text('Rút tiền', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            const Text(
                              'Tạo yêu cầu rút tiền về ngân hàng.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizeTransition(
              sizeFactor: CurvedAnimation(parent: _panelController, curve: Curves.easeInOutCubic),
              axisAlignment: -1,
              child: FadeTransition(
                opacity: _panelController,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _TopupPanel(
                    quickAmounts: _quickAmounts,
                    selectedAmount: _selectedAmount,
                    controller: _customAmountController,
                    onSelectAmount: _selectQuickAmount,
                    onCustomChanged: (val) => setState(() {
                      _selectedAmount = null;
                    }),
                    onConfirm: _confirmTopup,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            StaggeredFadeIn(
              index: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lịch sử giao dịch', style: Theme.of(context).textTheme.titleMedium),
                  Text('Mới nhất', style: const TextStyle(color: AppColors.textSecondary)),
                ],
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
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border.withOpacity(0.8)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (isPositive ? AppColors.success : AppColors.danger).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isPositive ? Icons.south_west_rounded : Icons.north_east_rounded,
                            size: 18,
                            color: isPositive ? AppColors.success : AppColors.danger,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx.title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 3),
                              Text(
                                DateFormat('dd/MM/yyyy').format(tx.createdAt),
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isPositive ? '+' : ''}${priceFormat.format(tx.amount)}đ',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isPositive ? AppColors.success : AppColors.danger,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        if (_showSuccess)
          _SuccessOverlay(
            controller: _successController,
            amount: _lastTopupAmount,
          ),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String value;
  final String label;

  const _MiniMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.78), fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _TopupPanel extends StatelessWidget {
  final List<int> quickAmounts;
  final int? selectedAmount;
  final TextEditingController controller;
  final ValueChanged<int> onSelectAmount;
  final ValueChanged<String> onCustomChanged;
  final VoidCallback onConfirm;

  const _TopupPanel({
    required this.quickAmounts,
    required this.selectedAmount,
    required this.controller,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chọn mệnh giá', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
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
                onTap: () => onSelectAmount(amount),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.border,
                      width: isSelected ? 1.4 : 1,
                    ),
                    color: isSelected ? AppColors.accent.withOpacity(0.07) : AppColors.background,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${priceFormat.format(amount)}đ',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isSelected ? AppColors.accent : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Text('Hoặc nhập số tiền khác', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: onCustomChanged,
            decoration: const InputDecoration(hintText: 'Nhập số tiền'),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              child: const Text('Xác nhận nạp tiền'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessOverlay extends StatelessWidget {
  final AnimationController controller;
  final int amount;

  const _SuccessOverlay({required this.controller, required this.amount});

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.decimalPattern('vi_VN');
    return Positioned.fill(
      child: FadeTransition(
        opacity: controller,
        child: Container(
          color: Colors.white.withOpacity(0.96),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: CurvedAnimation(parent: controller, curve: Curves.elasticOut),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: AppColors.success, size: 36),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Nạp tiền thành công', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  '+${priceFormat.format(amount)}đ vào ví',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
