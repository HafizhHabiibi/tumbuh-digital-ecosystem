import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profil_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/user_model.dart';

// ── Service Provider ──────────────────────────

final profilServiceProvider = Provider<ProfilService>((ref) {
  return ProfilService();
});

// ── Profil Provider ───────────────────────────

final profilProvider = FutureProvider<UserModel>((ref) async {
  return ref.watch(profilServiceProvider).getProfil();
});

// ── Ubah Password State ───────────────────────

class UbahPasswordState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const UbahPasswordState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  UbahPasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return UbahPasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// ── Ubah Password Notifier ────────────────────

class UbahPasswordNotifier extends StateNotifier<UbahPasswordState> {
  final Ref _ref;

  UbahPasswordNotifier(this._ref) : super(const UbahPasswordState());

  Future<bool> ubahPassword({
    required String passwordLama,
    required String passwordBaru,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    try {
      await _ref.read(authProvider.notifier).changePassword(
            passwordLama: passwordLama,
            passwordBaru: passwordBaru,
          );

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void reset() {
    state = const UbahPasswordState();
  }
}

// ── Provider ──────────────────────────────────

final ubahPasswordProvider =
    StateNotifierProvider<UbahPasswordNotifier, UbahPasswordState>((ref) {
  return UbahPasswordNotifier(ref);
});
