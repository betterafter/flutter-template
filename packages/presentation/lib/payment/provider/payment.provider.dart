import 'package:domain/domain/payment/usecase/payment.usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

final paymentUsecaseProvider = Provider<PaymentUsecase>(
  (ref) => GetIt.I<PaymentUsecase>(),
);
