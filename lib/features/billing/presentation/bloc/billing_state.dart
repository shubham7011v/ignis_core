import 'package:equatable/equatable.dart';

abstract class BillingState extends Equatable {
  const BillingState();

  @override
  List<Object> get props => [];
}

class BillingInitial extends BillingState {}

class BillingLoading extends BillingState {}

class BillingAvailable extends BillingState {
  final bool isPremium;

  const BillingAvailable({this.isPremium = false});

  @override
  List<Object> get props => [isPremium];
}

class BillingError extends BillingState {
  final String message;

  const BillingError(this.message);

  @override
  List<Object> get props => [message];
}
