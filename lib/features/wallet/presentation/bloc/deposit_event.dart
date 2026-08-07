abstract class DepositEvent {
  const DepositEvent();
}

class DepositSubmitted extends DepositEvent {
  final int amount;
  const DepositSubmitted(this.amount);
}