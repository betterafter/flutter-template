import '../utils/file_writer.dart';
import '../utils/paths.dart';

class PaymentExampleWriter {
  const PaymentExampleWriter(this._writer);

  final FileWriter _writer;

  Future<void> write(ProjectPaths project, {required bool force}) async {
    final files = <String, String>{
      project.domainPackage(
        'lib/domain/payment/entity/payment.entity.dart',
      ): _entity,
      project.domainPackage(
        'lib/domain/payment/repository/payment.repository.dart',
      ): _repository,
      project.domainPackage(
        'lib/domain/payment/usecase/payment.usecase.dart',
      ): _usecase,
      project.dataPackage('lib/data/payment/api/payment.api.dart'): _api,
      project.dataPackage('lib/data/payment/dto/payment.dto.dart'): _dto,
      project.dataPackage(
        'lib/data/payment/dto/payment.dto.parser.dart',
      ): _dtoParser,
      project.dataPackage(
        'lib/data/payment/mapper/payment.mapper.dart',
      ): _mapper,
      project.dataPackage(
        'lib/data/payment/datasource/payment.remote.datasource.dart',
      ): _remoteDatasource,
      project.dataPackage(
        'lib/data/payment/repository/payment.repository.dart',
      ): _repositoryImpl,
      project.presentationPackage(
        'lib/payment/provider/payment.provider.dart',
      ): _provider,
      project.presentationPackage('lib/payment/page/payment.page.dart'): _page,
    };

    for (final entry in files.entries) {
      await _writer.writeFile(
        path: entry.key,
        content: entry.value,
        force: force,
      );
    }
  }

  static const _entity = '''
class PaymentEntity {
  const PaymentEntity({
    required this.id,
    required this.amount,
    required this.status,
  });

  final String id;
  final int amount;
  final String status;
}
''';

  static const _repository = '''
import 'package:domain/core/data_state.dart';
import 'package:domain/domain/payment/entity/payment.entity.dart';

abstract class PaymentRepository {
  Future<DataState<List<PaymentEntity>>> getPayments();
}
''';

  static const _usecase = '''
import 'package:domain/core/data_state.dart';
import 'package:domain/domain/payment/entity/payment.entity.dart';
import 'package:domain/domain/payment/repository/payment.repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class PaymentUsecase {
  PaymentUsecase({required this.paymentRepository});

  final PaymentRepository paymentRepository;

  Future<DataState<List<PaymentEntity>>> getPayments() {
    return paymentRepository.getPayments();
  }
}
''';

  static const _api = '''
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
''';

  static const _dto = '''
class PaymentDto {
  const PaymentDto({
    required this.id,
    required this.amount,
    required this.status,
  });

  final String id;
  final int amount;
  final String status;

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    return PaymentDto(
      id: json['id'] as String,
      amount: json['amount'] as int,
      status: json['status'] as String,
    );
  }
}
''';

  static const _dtoParser = '''
import 'package:data/data/payment/dto/payment.dto.dart';

List<PaymentDto> parsePaymentDtoList(List<dynamic> jsonList) {
  return jsonList
      .map((json) => PaymentDto.fromJson(json as Map<String, dynamic>))
      .toList();
}
''';

  static const _mapper = '''
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
''';

  static const _remoteDatasource = '''
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
''';

  static const _repositoryImpl = '''
import 'package:data/core/network/remote.dart';
import 'package:data/data/payment/datasource/payment.remote.datasource.dart';
import 'package:data/data/payment/mapper/payment.mapper.dart';
import 'package:domain/core/data_state.dart';
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
  Future<DataState<List<PaymentEntity>>> getPayments() {
    return remote(() async {
      final dtos = await _remoteDatasource.getPayments();
      return _mapper.toEntityList(dtos);
    });
  }
}
''';

  static const _provider = '''
import 'package:domain/domain/payment/usecase/payment.usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

final paymentUsecaseProvider = Provider<PaymentUsecase>(
  (ref) => GetIt.I<PaymentUsecase>(),
);
''';

  static const _page = '''
import 'package:domain/core/data_state.dart';
import 'package:domain/domain/payment/entity/payment.entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presentation/payment/provider/payment.provider.dart';

class PaymentPage extends ConsumerWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsFuture = ref.read(paymentUsecaseProvider).getPayments();

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: FutureBuilder<DataState<List<PaymentEntity>>>(
        future: paymentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final state = snapshot.data ?? const DataState.initial();

          return state.when(
            initial: () => const Center(child: Text('결제 내역을 불러오는 중입니다.')),
            loading: (_) => const Center(child: CircularProgressIndicator()),
            success: (payments) {
              if (payments.isEmpty) {
                return const Center(child: Text('결제 내역이 없습니다.'));
              }

              return ListView.separated(
                itemCount: payments.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  return ListTile(
                    title: Text('\${payment.amount}원'),
                    subtitle: Text(payment.status),
                    trailing: Text(payment.id),
                  );
                },
              );
            },
            error: (error, message, data) {
              return Center(child: Text(message ?? '오류가 발생했습니다.'));
            },
          );
        },
      ),
    );
  }
}
''';
}
