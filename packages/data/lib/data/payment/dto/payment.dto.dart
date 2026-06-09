class PaymentDto {
  const PaymentDto({
    required this.id,
    required this.amount,
    required this.status,
  });

  final String id;
  final int amount;
  final String status;

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    return PaymentDto(
      id: json['id'] as String,
      amount: json['amount'] as int,
      status: json['status'] as String,
    );
  }
}
