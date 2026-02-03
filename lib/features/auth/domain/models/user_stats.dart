import 'package:equatable/equatable.dart';

class UserStats extends Equatable {
  final String userId;
  final String name;
  final int invitationsCreated;
  final int guestsCount;
  final int rsvpsReceived;

  const UserStats({
    required this.userId,
    required this.name,
    this.invitationsCreated = 0,
    this.guestsCount = 0,
    this.rsvpsReceived = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      invitationsCreated: json['invitationsCreated'] as int? ?? 0,
      guestsCount: json['guestsCount'] as int? ?? 0,
      rsvpsReceived: json['rsvpsReceived'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'invitationsCreated': invitationsCreated,
      'guestsCount': guestsCount,
      'rsvpsReceived': rsvpsReceived,
    };
  }

  @override
  List<Object?> get props => [
    userId,
    name,
    invitationsCreated,
    guestsCount,
    rsvpsReceived,
  ];
}
