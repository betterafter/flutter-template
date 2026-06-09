import 'package:data/data/payment/dto/payment.dto.dart';
import 'package:domain/domain/payment/entity/payment.entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class PaymentMapper {
  PaymentEntity toEntity(PaymentDto dto) {
    return PaymentEntity(
      id: dto.id,
      amount: dto.amount,
      status: dto.status,
    );
  }

  List<PaymentEntity> toEntityList(List<PaymentDto> dtos) {
    return dtos.map(toEntity).toList();
  }
}
