import '../models/guest.dart';

abstract class GuestsRepository {
  Future<List<Guest>> getGuests();
  Future<void> addGuest(Guest guest);
  Future<void> updateGuest(Guest guest);
  Future<void> removeGuest(String id);
}
