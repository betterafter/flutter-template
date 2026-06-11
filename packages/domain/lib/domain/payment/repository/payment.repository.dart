import 'package:domain/core/data_state.dart';
import 'package:domain/domain/payment/entity/payment.entity.dart';

abstract class PaymentRepository {
  Future<DataState<List<PaymentEntity>>> getPayments();
}
