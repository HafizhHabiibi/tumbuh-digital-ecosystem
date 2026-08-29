import '../config/app_config.dart';

class ApiConstants {
  ApiConstants._();

  static const String _environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static final AppConfig configuration = AppConfig.resolve(
    environment: _environment,
    baseUrl: _configuredBaseUrl,
  );

  static String get baseUrl => configuration.baseUrl;

  static void validateConfiguration() {
    configuration;
  }

  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String changePassword = '/auth/change-password';

  // Orang Tua & Anak
  static const String profil = '/orang-tua/profile';
  static const String daftarAnak = '/orang-tua/anak';
  static String detailAnak(String id) => '/orang-tua/anak/$id';

  // Laporan
  static String laporanAnak(String id) => '/laporan/anak/$id';

  // Pengukuran
  static String pengukuranAnak(String id) => '/orang-tua/anak/$id/pengukuran';
  static String insightPengukuran(int id) => '/pengukuran/$id/insight';

  // Pemberian
  static String pemberianAnak(String id) => '/orang-tua/anak/$id/pemberian';

  // Rujukan
  static String rujukanAnak(String id) => '/orang-tua/anak/$id/rujukan';

  // Notifikasi
  static const String notifikasi = '/notifikasi';
  static const String notifikasiBelumDibaca = '/notifikasi/belum-dibaca';
  static String bacaNotifikasi(int id) => '/notifikasi/$id/baca';
  static const String bacaSemuaNotifikasi = '/notifikasi/baca-semua';
  static const String updateFcmToken = '/orang-tua/update-fcm-token';

  // Jadwal
  static const String jadwal = '/jadwal';
  static String detailJadwal(int id) => '/jadwal/$id';
}
