import 'package:data/data/payment/dto/payment.dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'payment.api.g.dart';

@RestApi()
abstract class PaymentApi {
  factory PaymentApi(Dio dio, {String baseUrl}) = _PaymentApi;

  @GET('/api/payments')
  Future<List<PaymentDto>> getPayments();
}
