import 'package:flutter_template/di.config.dart';
import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import 'package:data/di.dart' as data;
import 'package:domain/di.dart' as domain;
import 'package:presentation/di.dart' as presentation;

final di = GetIt.instance;

@InjectableInit()
GetIt configureDependencies() {
  data.configureDependencies(getIt: di);
  domain.configureDependencies(getIt: di);
  presentation.configureDependencies(getIt: di);

  return di.init();
}
