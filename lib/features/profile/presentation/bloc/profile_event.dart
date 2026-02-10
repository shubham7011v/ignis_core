import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileViewRequested extends ProfileEvent {
  final String userId;

  const ProfileViewRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}
