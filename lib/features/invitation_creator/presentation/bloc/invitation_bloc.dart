import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/invitation_repository.dart';
import '../../domain/entities/invitation_style.dart';
import 'invitation_event.dart';
import 'invitation_state.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import '../../../billing/domain/services/order_payment_service.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/payment_info.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  final InvitationRepository _repository;
  final OrderRepository _orderRepository;
  final OrderPaymentService _paymentService;

  InvitationBloc({
    required InvitationRepository repository,
    required OrderRepository orderRepository,
    required OrderPaymentService paymentService,
  }) : _repository = repository,
       _orderRepository = orderRepository,
       _paymentService = paymentService,
       super(InvitationState.initial()) {
    on<InvitationStarted>(_onStarted);
    on<StyleSelected>(_onStyleSelected);
    on<DetailsUpdated>(_onDetailsUpdated);
    on<PlaceOrderRequested>(_onPlaceOrderRequested);
    on<TemplateSelected>(_onTemplateSelected);
  }

  Future<void> _onStarted(
    InvitationStarted event,
    Emitter<InvitationState> emit,
  ) async {
    emit(state.copyWith(status: InvitationStatus.loading));
    try {
      final styles = await _repository.getAvailableStyles();
      emit(
        state.copyWith(
          status: InvitationStatus.initial,
          availableStyles: styles,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: InvitationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onStyleSelected(StyleSelected event, Emitter<InvitationState> emit) {
    emit(state.copyWith(selectedStyle: event.style));
  }

  void _onDetailsUpdated(DetailsUpdated event, Emitter<InvitationState> emit) {
    emit(state.copyWith(details: event.details));
  }

  Future<void> _onPlaceOrderRequested(
    PlaceOrderRequested event,
    Emitter<InvitationState> emit,
  ) async {
    if (state.selectedStyle == null) return;

    emit(state.copyWith(status: InvitationStatus.placingOrder));

    try {
      // 1. Initiate Google Play Purchase
      // Using style ID as template ID for now
      final purchaseToken = await _paymentService.purchaseTemplate(
        state.selectedStyle!.id,
      );

      // 2. Create Order on Server with Purchase Token
      final order = Order(
        id: '', // Repository will generate ID
        userId: event.userId,
        styleId: state.selectedStyle!.id,
        details: state.details,
        createdAt: DateTime.now(),
        // Payment info comes from Google Play Token
        paymentInfo: PaymentInfo(
          transactionId: purchaseToken,
          amount: 0.0, // Server knows the price
          currency: 'INR',
          paidAt: DateTime.now(),
          status: 'paid', // We mark as paid locally, server will verify
        ),
      );

      final createdOrder = await _orderRepository.createOrder(order);

      emit(
        state.copyWith(
          status: InvitationStatus.success,
          orderId: createdOrder.id,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: InvitationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onTemplateSelected(
    TemplateSelected event,
    Emitter<InvitationState> emit,
  ) {
    final style = InvitationStyle(
      id: event.template.id,
      name: event.template.title,
      thumbnailUrl: event.template.thumbnailUrl,
      videoTemplateId: event.template.videoUrl,
      categories: [event.template.category],
    );
    emit(state.copyWith(selectedStyle: style));
  }
}
