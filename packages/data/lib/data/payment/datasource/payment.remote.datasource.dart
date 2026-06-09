import 'package:data/data/payment/dto/payment.dto.dart';
import 'package:data/data/payment/dto/payment.dto.parser.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class PaymentRemoteDatasource {
  PaymentRemoteDatasource();

  Future<List<PaymentDto>> getPayments() async {
    final jsonList = await _fetchPaymentsJson();
    return compute(parsePaymentDtoList, jsonList);
  }

  Future<List<dynamic>> _fetchPaymentsJson() async {
    // TODO: HTTP 클라이언트로 API 호출 후 response.body를 jsonDecode
    return [
      {'id': '1', 'amount': 10000, 'status': 'completed'},
      {'id': '2', 'amount': 25000, 'status': 'pending'},
    ];
  }
}
