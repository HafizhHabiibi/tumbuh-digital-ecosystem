import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_session_controller.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/utils/storage_utils.dart';
import '../../../shared/models/user_model.dart';
import '../data/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

enum AuthStatus { initializing, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initializing,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isLoggedIn => status == AuthStatus.authenticated && user != null;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Future<bool> Function() _hasStoredSession;
  final Future<String?> Function() _getFcmToken;
  late final StreamSubscription<AuthSessionEvent> _sessionSubscription;

  AuthNotifier(
    this._authService, {
    Future<bool> Function()? hasStoredSession,
    Future<String?> Function()? getFcmToken,
    AuthSessionController? sessionController,
  })  : _hasStoredSession = hasStoredSession ?? _defaultHasStoredSession,
        _getFcmToken = getFcmToken ?? FcmService.getToken,
        super(const AuthState()) {
    final controller = sessionController ?? AuthSessionController.instance;
    _sessionSubscription = controller.events.listen((event) {
      if (event == AuthSessionEvent.expired) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
    unawaited(restoreSession());
  }

  static Future<bool> _defaultHasStoredSession() async {
    final accessToken = await StorageUtils.getAccessToken();
    final refreshToken = await StorageUtils.getRefreshToken();
    return (accessToken?.isNotEmpty ?? false) ||
        (refreshToken?.isNotEmpty ?? false);
  }

  Future<void> restoreSession() async {
    state = const AuthState(status: AuthStatus.initializing);
    if (!await _hasStoredSession()) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final user = await _authService.getCurrentUser();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: ErrorUtils.getCleanErrorMessage(error),
      );
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _authService.login(
        email: email,
        password: password,
        fcmToken: await _getFcmToken(),
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: ErrorUtils.getCleanErrorMessage(error),
      );
      return false;
    }
  }

  Future<String?> forgotPassword({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final message = await _authService.forgotPassword(email: email);
      state = state.copyWith(isLoading: false);
      return message;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: ErrorUtils.getCleanErrorMessage(error),
      );
      return null;
    }
  }

  Future<bool> changePassword({
    required String passwordLama,
    required String passwordBaru,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.changePassword(
        passwordLama: passwordLama,
        passwordBaru: passwordBaru,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: ErrorUtils.getCleanErrorMessage(error),
      );
      return false;
    }
  }

  Future<void> logout() async {
    String? errorMessage;
    try {
      await _authService.logout();
    } catch (error) {
      errorMessage = ErrorUtils.getCleanErrorMessage(error);
    } finally {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: errorMessage,
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _sessionSubscription.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
