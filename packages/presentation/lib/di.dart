import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import 'package:presentation/di.config.dart';

@InjectableInit()
void configureDependencies({required GetIt getIt}) => getIt.init();
