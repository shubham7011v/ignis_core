import '../models/creation.dart';

abstract class CreationsRepository {
  Future<List<Creation>> getCreations();
  Future<void> deleteCreation(String id);
}
