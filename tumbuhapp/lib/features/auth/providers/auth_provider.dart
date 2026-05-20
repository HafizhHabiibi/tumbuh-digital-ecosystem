import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_service.dart';
import '../../../shared/models/user_model.dart';
// import '../../../core/utils/storage_utils.dart';

// ── Service Provider ──────────────────────────

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// ── Auth State ────────────────────────────────

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// ── Auth Notifier ─────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  // ── Login ───────────────────────────────────

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _authService.login(
        email: email,
        password: password,
        fcmToken: null,
      );

      state = state.copyWith(
        user: user,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // ── Forgot Password ─────────────────────────

  Future<String?> forgotPassword({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final message = await _authService.forgotPassword(email: email);
      state = state.copyWith(isLoading: false);
      return message;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  // ── Change Password ─────────────────────────

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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // ── Logout ──────────────────────────────────

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
  }

  // ── Clear Error ─────────────────────────────

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ── Provider ──────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
