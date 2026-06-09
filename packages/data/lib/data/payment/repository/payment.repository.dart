import 'package:data/data/payment/datasource/payment.remote.datasource.dart';
import 'package:data/data/payment/mapper/payment.mapper.dart';
import 'package:domain/domain/payment/entity/payment.entity.dart';
import 'package:domain/domain/payment/repository/payment.repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: PaymentRepository)
class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(
    this._remoteDatasource,
    this._mapper,
  );

  final PaymentRemoteDatasource _remoteDatasource;
  final PaymentMapper _mapper;

  @override
  Future<List<PaymentEntity>> getPayments() async {
    final dtos = await _remoteDatasource.getPayments();
    return _mapper.toEntityList(dtos);
  }
}
