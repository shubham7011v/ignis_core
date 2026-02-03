import 'package:equatable/equatable.dart';

enum RsvpStatus { pending, accepted, declined }

class Guest extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final RsvpStatus rsvpStatus;
  final bool isInvitationSent;

  const Guest({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.rsvpStatus = RsvpStatus.pending,
    this.isInvitationSent = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    phoneNumber,
    rsvpStatus,
    isInvitationSent,
  ];

  Guest copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    RsvpStatus? rsvpStatus,
    bool? isInvitationSent,
  }) {
    return Guest(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
      isInvitationSent: isInvitationSent ?? this.isInvitationSent,
    );
  }

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      rsvpStatus: RsvpStatus.values.firstWhere(
        (e) => e.toString() == 'RsvpStatus.${json['rsvpStatus']}',
        orElse: () => RsvpStatus.pending,
      ),
      isInvitationSent: (json['isInvitationSent'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'rsvpStatus': rsvpStatus.toString().split('.').last,
      'isInvitationSent': isInvitationSent,
    };
  }
}
