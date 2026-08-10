class WithdrawRequestEntity {
  final int amount;
  final String bankName;
  final String bankAccount;
  final String accountHolder;

  WithdrawRequestEntity({
    required this.amount,
    required this.bankName,
    required this.bankAccount,
    required this.accountHolder,
  });
}