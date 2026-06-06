import 'package:dio/dio.dart';

class ErrorUtils {
  ErrorUtils._();

  static String getCleanErrorMessage(dynamic e) {
    if (e is DioException) {
      // Prioritaskan pesan custom dari backend (e.g. data['message']) yang sudah disimpan di e.error
      if (e.error != null) {
        return e.error.toString();
      }
      if (e.message != null) {
        return e.message!;
      }
      final statusCode = e.response?.statusCode;
      return 'Terjadi kesalahan jaringan${statusCode != null ? " (Status: $statusCode)" : ""}';
    }
    return e.toString().replaceAll('Exception: ', '');
  }
}
