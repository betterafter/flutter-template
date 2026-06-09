import 'package:domain/domain/payment/entity/payment.entity.dart';
import 'package:domain/domain/payment/repository/payment.repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class PaymentUsecase {
  PaymentUsecase({required this.paymentRepository});

  final PaymentRepository paymentRepository;

  Future<List<PaymentEntity>> getPayments() {
    return paymentRepository.getPayments();
  }
}
