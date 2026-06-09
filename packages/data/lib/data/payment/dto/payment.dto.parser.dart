import 'package:data/data/payment/dto/payment.dto.dart';

List<PaymentDto> parsePaymentDtoList(List<dynamic> jsonList) {
  return jsonList
      .map((json) => PaymentDto.fromJson(json as Map<String, dynamic>))
      .toList();
}
