import 'package:data/di.config.dart';
import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';

@InjectableInit()
void configureDependencies({required GetIt getIt}) => getIt.init();
