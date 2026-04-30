import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_state.dart';
import 'login_page.dart';
import 'create_store_page.dart';
import '../../../shell/pages/main_app_shell.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          return const MainAppShell();
        }

        if (state is AuthNeedsStore) {
          return CreateStorePage(state: state);
        }

        if (state is AuthError) {
          // แสดง error และกลับไปหน้า login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          });
          return const LoginPage();
        }

        // Default: ไปหน้า login
        return const LoginPage();
      },
    );
  }
}
