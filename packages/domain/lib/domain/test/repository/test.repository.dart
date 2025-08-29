import 'package:domain/domain.dart';

abstract class TestRepository {
  Future<List<TestEntity>> getTests();
}
