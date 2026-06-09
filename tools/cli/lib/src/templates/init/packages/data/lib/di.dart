import 'package:data/di.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@InjectableInit()
void configureDependencies({required GetIt getIt}) => getIt.init();
