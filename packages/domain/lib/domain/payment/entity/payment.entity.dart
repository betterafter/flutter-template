class PaymentEntity {
  const PaymentEntity({
    required this.id,
    required this.amount,
    required this.status,
  });

  final String id;
  final int amount;
  final String status;
}
