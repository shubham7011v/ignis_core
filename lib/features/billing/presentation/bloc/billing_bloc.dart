import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/billing_repository.dart';
import 'billing_event.dart';
import 'billing_state.dart';
import '../../../../core/utils/app_logger.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final BillingRepository billingRepository;
  StreamSubscription<bool>? _premiumSubscription;

  BillingBloc({required this.billingRepository}) : super(BillingInitial()) {
    on<BillingStarted>(_onStarted);
    on<PurchasePremiumRequested>(_onPurchaseRequested);
    on<RestorePurchasesRequested>(_onRestoreRequested);
    on<_PremiumStatusUpdated>(_onPremiumStatusUpdated);
  }

  Future<void> _onStarted(
    BillingStarted event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      await billingRepository.initialize();

      _premiumSubscription?.cancel();
      _premiumSubscription = billingRepository.isPremiumStream.listen((
        isPremium,
      ) {
        AppLogger.info('BillingBloc: Premium Status Changed -> $isPremium');
        // Since we are inside a listener, we should use add() to trigger a new state
        // if we want to be safe, but Emitter is available here if we handle it carefully.
        // However, standard Bloc pattern with external streams usually pipes them to events.
        // For simplicity in this generated code, we'll assume we handle it via a custom event or just re-emit here if possible
        // But since `emit` is scoped to the handler, we can't call it from the listener callback easily without a new event.
        // Let's create a private event _PremiumStatusUpdated.
        if (!isClosed) {
          add(_PremiumStatusUpdated(isPremium));
        }
      });
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onPurchaseRequested(
    PurchasePremiumRequested event,
    Emitter<BillingState> emit,
  ) async {
    try {
      await billingRepository.purchasePremium();
    } catch (e) {
      emit(BillingError('Purchase failed: $e'));
      // Revert to available after error
      add(const _PremiumStatusUpdated(false));
    }
  }

  Future<void> _onRestoreRequested(
    RestorePurchasesRequested event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      await billingRepository.restorePurchases();
      // Status update comes from stream
    } catch (e) {
      emit(BillingError('Restore failed: $e'));
    }
  }

  // Handling the internal event
  Future<void> _onPremiumStatusUpdated(
    _PremiumStatusUpdated event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingAvailable(isPremium: event.isPremium));
  }

  @override
  Future<void> close() {
    _premiumSubscription?.cancel();
    return super.close();
  }
}

// Internal event (not exposed in billing_event.dart to keep API clean)
class _PremiumStatusUpdated extends BillingEvent {
  final bool isPremium;
  const _PremiumStatusUpdated(this.isPremium);
}
