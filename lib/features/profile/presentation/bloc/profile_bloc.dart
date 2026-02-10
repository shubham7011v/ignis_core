import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../../core/error/failure.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;
  StreamSubscription? _historySubscription;

  ProfileBloc({required ProfileRepository repository})
    : _repository = repository,
      super(ProfileInitial()) {
    on<ProfileViewRequested>(_onViewRequested);
  }

  @override
  Future<void> close() {
    _historySubscription?.cancel();
    return super.close();
  }

  Future<void> _onViewRequested(
    ProfileViewRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final profile = await _repository.getProfile(event.userId);
      final currentUser = FirebaseAuth.instance.currentUser;
      final isOwnProfile = currentUser?.uid == event.userId;

      emit(ProfileLoaded(profile: profile, isOwnProfile: isOwnProfile));
    } catch (e) {
      emit(ProfileError(ServerFailure('Failed to load profile: $e')));
    }
  }
}
