import 'package:domain/domain.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: TestRepository)
class TestRepositoryImpl implements TestRepository {
  TestRepositoryImpl();

  @override
  Future<List<TestEntity>> getTests() async {
    return [];
  }
}
