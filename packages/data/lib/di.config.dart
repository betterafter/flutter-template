// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:data/core/network/network_module.dart' as _i497;
import 'package:data/data/payment/datasource/payment.remote.datasource.dart'
    as _i51;
import 'package:data/data/payment/mapper/payment.mapper.dart' as _i323;
import 'package:data/data/payment/repository/payment.repository.dart' as _i1033;
import 'package:data/data/ranking/datasource/ranking.remote.datasource.dart'
    as _i256;
import 'package:data/data/ranking/mapper/ranking.mapper.dart' as _i835;
import 'package:data/data/ranking/repository/ranking.repository.dart' as _i457;
import 'package:dio/dio.dart' as _i361;
import 'package:domain/domain/payment/repository/payment.repository.dart'
    as _i30;
import 'package:domain/domain/ranking/repository/ranking.repository.dart'
    as _i19;
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
    final networkModule = _$NetworkModule();
    gh.factory<_i323.PaymentMapper>(() => _i323.PaymentMapper());
    gh.factory<_i835.RankingMapper>(() => _i835.RankingMapper());
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio());
    gh.factory<_i51.PaymentRemoteDatasource>(
        () => _i51.PaymentRemoteDatasource(gh<_i361.Dio>()));
    gh.factory<_i256.RankingRemoteDatasource>(
        () => _i256.RankingRemoteDatasource(gh<_i361.Dio>()));
    gh.factory<_i19.RankingRepository>(() => _i457.RankingRepositoryImpl(
          gh<_i256.RankingRemoteDatasource>(),
          gh<_i835.RankingMapper>(),
        ));
    gh.factory<_i30.PaymentRepository>(() => _i1033.PaymentRepositoryImpl(
          gh<_i51.PaymentRemoteDatasource>(),
          gh<_i323.PaymentMapper>(),
        ));
    return this;
  }
}

class _$NetworkModule extends _i497.NetworkModule {}
