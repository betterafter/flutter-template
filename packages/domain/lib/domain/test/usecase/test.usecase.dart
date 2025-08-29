import 'package:domain/domain/test/entity/test.entity.dart';
import 'package:domain/domain/test/repository/test.repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class TestUsecase {
  final TestRepository testRepository;

  TestUsecase({required this.testRepository});

  Future<List<TestEntity>> getTests() async {
    return testRepository.getTests();
  }
}
