import '../../domain/models/guest.dart';
import '../../domain/repositories/guests_repository.dart';

class GuestsRepositoryImpl implements GuestsRepository {
  final List<Guest> _mockGuests = [
    const Guest(
      id: '1',
      name: 'Aditya Sharma',
      phoneNumber: '+91 98765 43210',
      rsvpStatus: RsvpStatus.accepted,
      isInvitationSent: true,
    ),
    const Guest(
      id: '2',
      name: 'Priya Verma',
      phoneNumber: '+91 87654 32109',
      rsvpStatus: RsvpStatus.pending,
      isInvitationSent: true,
    ),
    const Guest(
      id: '3',
      name: 'Rahul Khanna',
      phoneNumber: '+91 76543 21098',
      rsvpStatus: RsvpStatus.declined,
      isInvitationSent: false,
    ),
  ];

  @override
  Future<List<Guest>> getGuests() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockGuests);
  }

  @override
  Future<void> addGuest(Guest guest) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockGuests.add(guest);
  }

  @override
  Future<void> updateGuest(Guest guest) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockGuests.indexWhere((g) => g.id == guest.id);
    if (index != -1) {
      _mockGuests[index] = guest;
    }
  }

  @override
  Future<void> removeGuest(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockGuests.removeWhere((g) => g.id == id);
  }
}
