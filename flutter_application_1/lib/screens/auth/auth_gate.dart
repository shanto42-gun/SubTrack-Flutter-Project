import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

/// The AuthGate determines whether to show the authenticated HomeScreen or the LoginScreen.
/// It also listens to live auth state changes (login, logout, token expiry).
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<AuthState>? _authSubscription;
  bool _isLoading = true;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _checkInitialSession();
  }

  void _checkInitialSession() {
    _session = supabase.auth.currentSession;
    setState(() {
      _isLoading = false;
    });

    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _session = data.session;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_session != null) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
