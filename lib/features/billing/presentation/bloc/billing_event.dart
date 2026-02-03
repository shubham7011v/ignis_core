import 'package:equatable/equatable.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object> get props => [];
}

class BillingStarted extends BillingEvent {}

class PurchasePremiumRequested extends BillingEvent {}

class RestorePurchasesRequested extends BillingEvent {}
