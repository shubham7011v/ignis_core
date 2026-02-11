import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/admin_repository.dart';
import '../../data/models/admin_user.dart';
import '../../data/models/admin_template.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import '../../../orders/domain/entities/order_status.dart';

// --- Events ---
abstract class AdminEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminLogin extends AdminEvent {}

class LoadAdminData extends AdminEvent {}

class BroadcastMessageEvent extends AdminEvent {
  final String title;
  final String body;
  BroadcastMessageEvent(this.title, this.body);
  @override
  List<Object?> get props => [title, body];
}

class UpdateOrderStatusEvent extends AdminEvent {
  final String orderId;
  final OrderStatus status;
  final String? videoUrl;

  UpdateOrderStatusEvent(this.orderId, this.status, {this.videoUrl});

  @override
  List<Object?> get props => [orderId, status, videoUrl];
}

class CreateTemplateEvent extends AdminEvent {
  final AdminTemplate template;
  CreateTemplateEvent(this.template);
  @override
  List<Object?> get props => [template];
}

class UpdateTemplateEvent extends AdminEvent {
  final AdminTemplate template;
  UpdateTemplateEvent(this.template);
  @override
  List<Object?> get props => [template];
}

class DeleteTemplateEvent extends AdminEvent {
  final String templateId;
  DeleteTemplateEvent(this.templateId);
  @override
  List<Object?> get props => [templateId];
}

class UpdateConfigEvent extends AdminEvent {
  final Map<String, dynamic> config;
  UpdateConfigEvent(this.config);
  @override
  List<Object?> get props => [config];
}

class AdminLogout extends AdminEvent {}

// --- States ---
abstract class AdminState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminAuthenticated extends AdminState {
  final Map<String, dynamic> stats;
  final List<Order> orders;
  final List<AdminUser> users;
  final List<AdminTemplate> templates;

  AdminAuthenticated({
    required this.stats,
    required this.orders,
    required this.users,
    required this.templates,
  });

  @override
  List<Object?> get props => [stats, orders, users, templates];

  AdminAuthenticated copyWith({
    Map<String, dynamic>? stats,
    List<Order>? orders,
    List<AdminUser>? users,
    List<AdminTemplate>? templates,
  }) {
    return AdminAuthenticated(
      stats: stats ?? this.stats,
      orders: orders ?? this.orders,
      users: users ?? this.users,
      templates: templates ?? this.templates,
    );
  }
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository repository;
  final OrderRepository orderRepository;

  AdminBloc({required this.repository, required this.orderRepository})
    : super(AdminInitial()) {
    on<AdminLogin>(_onLogin);
    on<LoadAdminData>(_onLoadData);
    on<BroadcastMessageEvent>(_onBroadcast);
    on<UpdateConfigEvent>(_onUpdateConfig);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<CreateTemplateEvent>(_onCreateTemplate);
    on<UpdateTemplateEvent>(_onUpdateTemplate);
    on<DeleteTemplateEvent>(_onDeleteTemplate);
    on<AdminLogout>((_, emit) {
      emit(AdminInitial());
    });
  }

  Future<void> _onLogin(AdminLogin event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final results = await Future.wait([
        repository.getStats(),
        orderRepository.getAllOrders(),
        repository.getUsers(),
        repository.getTemplates(),
      ]);
      final stats = results[0] as Map<String, dynamic>;
      final orders = results[1] as List<Order>;
      final users = results[2] as List<AdminUser>;
      final templates = results[3] as List<AdminTemplate>;

      emit(
        AdminAuthenticated(
          stats: stats,
          orders: orders,
          users: users,
          templates: templates,
        ),
      );
    } catch (e) {
      emit(AdminError("Authorization Failed. Error: $e"));
    }
  }

  Future<void> _onLoadData(
    LoadAdminData event,
    Emitter<AdminState> emit,
  ) async {
    if (state is! AdminAuthenticated) return;
    try {
      final results = await Future.wait([
        repository.getStats(),
        orderRepository.getAllOrders(),
        repository.getUsers(),
        repository.getTemplates(),
      ]);
      final stats = results[0] as Map<String, dynamic>;
      final orders = results[1] as List<Order>;
      final users = results[2] as List<AdminUser>;
      final templates = results[3] as List<AdminTemplate>;

      emit(
        AdminAuthenticated(
          stats: stats,
          orders: orders,
          users: users,
          templates: templates,
        ),
      );
    } catch (e) {
      emit(AdminError("Failed to refresh data: $e"));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await orderRepository.updateOrderStatus(
        event.orderId,
        event.status,
        videoUrl: event.videoUrl,
      );
      add(LoadAdminData());
    } catch (e) {
      emit(AdminError("Failed to update status: $e"));
    }
  }

  Future<void> _onBroadcast(
    BroadcastMessageEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await repository.broadcastMessage(event.title, event.body);
      // Optional: Emit success message via side-effect or ephemeral state if needed
    } catch (e) {
      emit(AdminError("Broadcast failed: $e"));
    }
  }

  Future<void> _onUpdateConfig(
    UpdateConfigEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await repository.updateConfig(event.config);
      // No reload needed for config unless we display it back
    } catch (e) {
      emit(AdminError("Config update failed: $e"));
    }
  }

  Future<void> _onCreateTemplate(
    CreateTemplateEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await repository.createTemplate(event.template);
      add(LoadAdminData());
    } catch (e) {
      emit(AdminError("Failed to create template: $e"));
    }
  }

  Future<void> _onUpdateTemplate(
    UpdateTemplateEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await repository.updateTemplate(event.template);
      add(LoadAdminData());
    } catch (e) {
      emit(AdminError("Failed to update template: $e"));
    }
  }

  Future<void> _onDeleteTemplate(
    DeleteTemplateEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await repository.deleteTemplate(event.templateId);
      add(LoadAdminData());
    } catch (e) {
      emit(AdminError("Failed to delete template: $e"));
    }
  }
}
