import 'package:domain/domain/payment/entity/payment.entity.dart';

abstract class PaymentRepository {
  Future<List<PaymentEntity>> getPayments();
}
