class ApiConstants {
  ApiConstants._();

  // Base URL — ganti IP sesuai jaringan kalau test di device fisik
  static const String baseUrl = 'http://localhost:3000/api';

  // Auth
  static const String login = '/auth/login/mobile';
  static const String forgotPassword = '/auth/forgot-password';
  static const String changePassword = '/auth/change-password';

  // Orang Tua & Anak
  static const String profil = '/orang-tua/profil';
  static const String daftarAnak = '/orang-tua/anak';
  static String detailAnak(int id) => '/orang-tua/anak/$id';

  // Pengukuran
  static String pengukuranAnak(int id) => '/orang-tua/anak/$id/pengukuran';
  static String detailPengukuran(int id) => '/pengukuran/$id';
  static String insightPengukuran(int id) => '/pengukuran/$id/insight';

  // Pemberian
  static String pemberianAnak(int id) => '/orang-tua/anak/$id/pemberian';

  // Rujukan
  static String rujukanAnak(int id) => '/orang-tua/anak/$id/rujukan';

  // Notifikasi
  static const String notifikasi = '/notifikasi';
  static const String notifikasiBelumDibaca = '/notifikasi/belum-dibaca';
  static String bacaNotifikasi(int id) => '/notifikasi/$id/baca';
  static const String bacaSemuaNotifikasi = '/notifikasi/baca-semua';

  // Jadwal
  static const String jadwal = '/jadwal';
  static String detailJadwal(int id) => '/jadwal/$id';
}
