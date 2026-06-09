// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:data/data/payment/datasource/payment.remote.datasource.dart'
    as _i51;
import 'package:data/data/payment/mapper/payment.mapper.dart' as _i323;
import 'package:data/data/payment/repository/payment.repository.dart' as _i1033;
import 'package:domain/domain/payment/repository/payment.repository.dart'
    as _i30;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i51.PaymentRemoteDatasource>(
        () => _i51.PaymentRemoteDatasource());
    gh.factory<_i323.PaymentMapper>(() => _i323.PaymentMapper());
    gh.factory<_i30.PaymentRepository>(() => _i1033.PaymentRepositoryImpl(
          gh<_i51.PaymentRemoteDatasource>(),
          gh<_i323.PaymentMapper>(),
        ));
    return this;
  }
}
