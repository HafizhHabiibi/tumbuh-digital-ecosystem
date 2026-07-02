class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Auth
  static const String login = '/auth/login/mobile';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String changePassword = '/auth/change-password';

  // Orang Tua & Anak
  static const String profil = '/orang-tua/profil';
  static const String daftarAnak = '/orang-tua/anak';
  static String detailAnak(String id) => '/orang-tua/anak/$id';

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
  static const String updateFcmToken = '/notifikasi/update-token';

  // Jadwal
  static const String jadwal = '/jadwal';
  static String detailJadwal(int id) => '/jadwal/$id';
}
