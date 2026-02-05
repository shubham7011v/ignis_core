import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/config/app_config.dart';
import '../bloc/admin_bloc.dart';
import '../widgets/admin_login_view.dart';
import 'admin_dashboard_tab.dart';
import 'admin_orders_tab.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminBloc(
        repository: sl.adminRepository,
        orderRepository: sl.orderRepository,
      ),
      child: const _AdminView(),
    );
  }
}

class _AdminView extends StatefulWidget {
  const _AdminView();

  @override
  State<_AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<_AdminView> {
  @override
  void initState() {
    super.initState();
    _checkAuthorization();
  }

  void _checkAuthorization() {
    final user = FirebaseAuth.instance.currentUser;
    final config = AppConfig.instance;

    if (user != null &&
        (config.isAdmin || config.adminUids.contains(user.uid))) {
      context.read<AdminBloc>().add(AdminLogin());
    } else {
      context.read<AdminBloc>().add(AdminLogout());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black, // Matrix style
        appBar: AppBar(
          title: const Text('SERVER ADMIN'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.greenAccent,
          bottom: const TabBar(
            indicatorColor: Colors.greenAccent,
            labelColor: Colors.greenAccent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'DASHBOARD'),
              Tab(icon: Icon(Icons.list_alt), text: 'ORDERS'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<AdminBloc>().add(LoadAdminData());
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AdminBloc>().add(AdminLogout());
              },
            ),
          ],
        ),
        body: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state is AdminInitial || state is AdminError) {
              String? errorMessage;
              if (state is AdminError) {
                errorMessage = state.message;
                // Show snackbar for persistent error feedback
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                });
              }
              return AdminLoginView(errorMessage: errorMessage);
            }

            if (state is AdminLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.greenAccent),
              );
            }

            if (state is AdminAuthenticated) {
              return TabBarView(
                children: [
                  AdminDashboardTab(state: state),
                  AdminOrdersTab(orders: state.orders),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
