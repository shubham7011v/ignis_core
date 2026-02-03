import 'package:equatable/equatable.dart';
// import '../../../auth/domain/models/user_stats.dart';
import '../../../../core/models/system_status.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeStarted extends HomeEvent {}

class HomeBottomNavTapped extends HomeEvent {
  final int index;
  const HomeBottomNavTapped(this.index);
}

class HomeSystemStatusChanged extends HomeEvent {
  final SystemStatus status;
  const HomeSystemStatusChanged(this.status);
}

class HomeSessionStateChanged extends HomeEvent {
  final bool hasActiveSession;
  const HomeSessionStateChanged(this.hasActiveSession);
}
