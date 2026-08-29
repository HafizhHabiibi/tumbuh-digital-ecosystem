import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/dashboard/screens/detail_anak_screen.dart';
import '../features/pengukuran/screens/riwayat_pengukuran_screen.dart';
import '../features/pengukuran/screens/detail_pengukuran_screen.dart';
import '../features/pengukuran/screens/grafik_pertumbuhan_screen.dart';
import '../features/pemberian/screens/riwayat_pemberian_screen.dart';
import '../features/rujukan/screens/status_rujukan_screen.dart';
import '../features/notifikasi/screens/notifikasi_screen.dart';
import '../features/jadwal/screens/jadwal_screen.dart';
import '../features/profil/screens/profil_screen.dart';
import '../core/services/fcm_service.dart';

// ── Route Names ───────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String detailAnak = '/anak/:anakId';
  static const String riwayatPengukuran = '/anak/:anakId/pengukuran';
  static const String detailPengukuran = '/pengukuran/:pengukuranId';
  static const String grafikPertumbuhan = '/anak/:anakId/grafik';
  static const String riwayatPemberian = '/anak/:anakId/pemberian';
  static const String statusRujukan = '/anak/:anakId/rujukan';
  static const String notifikasi = '/notifikasi';
  static const String jadwal = '/jadwal';
  static const String profil = '/profil';
}

// ── Router Provider ───────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: FcmService.navigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isSplashPage = state.matchedLocation == AppRoutes.splash;
      final isLoggedIn = authState.isLoggedIn;
      final isAuthPage = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.forgotPassword;

      if (authState.status == AuthStatus.initializing) {
        return isSplashPage ? null : AppRoutes.splash;
      }

      if (!isLoggedIn && !isAuthPage) return AppRoutes.login;

      if (isLoggedIn && (isAuthPage || isSplashPage)) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      // ── Auth ──────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ── Dashboard ─────────────────────────
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // ── Anak ──────────────────────────────
      GoRoute(
        path: AppRoutes.detailAnak,
        name: 'detailAnak',
        builder: (context, state) {
          final anakId = state.pathParameters['anakId']!;
          return DetailAnakScreen(anakId: anakId);
        },
      ),

      // ── Pengukuran ────────────────────────
      GoRoute(
        path: AppRoutes.riwayatPengukuran,
        name: 'riwayatPengukuran',
        builder: (context, state) {
          final anakId = state.pathParameters['anakId']!;
          return RiwayatPengukuranScreen(anakId: anakId);
        },
      ),
      GoRoute(
        path: AppRoutes.detailPengukuran,
        name: 'detailPengukuran',
        builder: (context, state) {
          final pengukuranId = int.parse(
            state.pathParameters['pengukuranId']!,
          );
          return DetailPengukuranScreen(pengukuranId: pengukuranId);
        },
      ),
      GoRoute(
        path: AppRoutes.grafikPertumbuhan,
        name: 'grafikPertumbuhan',
        builder: (context, state) {
          final anakId = state.pathParameters['anakId']!;
          return GrafikPertumbuhanScreen(anakId: anakId);
        },
      ),

      // ── Pemberian ─────────────────────────
      GoRoute(
        path: AppRoutes.riwayatPemberian,
        name: 'riwayatPemberian',
        builder: (context, state) {
          final anakId = state.pathParameters['anakId']!;
          return RiwayatPemberianScreen(anakId: anakId);
        },
      ),

      // ── Rujukan ───────────────────────────
      GoRoute(
        path: AppRoutes.statusRujukan,
        name: 'statusRujukan',
        builder: (context, state) {
          final anakId = state.pathParameters['anakId']!;
          return StatusRujukanScreen(anakId: anakId);
        },
      ),

      // ── Notifikasi ────────────────────────
      GoRoute(
        path: AppRoutes.notifikasi,
        name: 'notifikasi',
        builder: (context, state) => const NotifikasiScreen(),
      ),

      // ── Jadwal ────────────────────────────
      GoRoute(
        path: AppRoutes.jadwal,
        name: 'jadwal',
        builder: (context, state) => const JadwalScreen(),
      ),

      // ── Profil ────────────────────────────
      GoRoute(
        path: AppRoutes.profil,
        name: 'profil',
        builder: (context, state) => const ProfilScreen(),
      ),
    ],
  );
});
