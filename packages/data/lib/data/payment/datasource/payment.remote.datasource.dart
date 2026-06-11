import 'package:data/data/payment/api/payment.api.dart';
import 'package:data/data/payment/dto/payment.dto.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@injectable
class PaymentRemoteDatasource {
  PaymentRemoteDatasource(Dio dio) : _api = PaymentApi(dio);

  final PaymentApi _api;

  Future<List<PaymentDto>> getPayments() => _api.getPayments();
}
