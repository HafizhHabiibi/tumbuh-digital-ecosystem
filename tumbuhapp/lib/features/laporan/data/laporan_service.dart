import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';

import '../../../core/constant/api_constants.dart';
import '../../../core/network/dio_client.dart';

typedef SavePdf = Future<String?> Function(String name, Uint8List bytes);

class LaporanDownloadResult {
  final String fileName;
  final String savedLocation;

  const LaporanDownloadResult({
    required this.fileName,
    required this.savedLocation,
  });
}

class LaporanDownloadException implements Exception {
  final String message;
  final int? statusCode;

  const LaporanDownloadException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class LaporanDownloadCancelled implements Exception {
  const LaporanDownloadCancelled();
}

class LaporanService {
  final Dio _dio;
  final SavePdf _savePdf;

  LaporanService({Dio? dio, SavePdf? savePdf})
      : _dio = dio ?? DioClient.instance,
        _savePdf = savePdf ?? _saveWithDialog;

  Future<LaporanDownloadResult> downloadLaporanAnak(String anakId) async {
    try {
      final response = await _dio.get<List<int>>(
        ApiConstants.laporanAnak(anakId),
        options: Options(
          responseType: ResponseType.bytes,
          headers: const {'Accept': 'application/pdf'},
        ),
      );

      final data = response.data;
      if (data == null || data.isEmpty) {
        throw const LaporanDownloadException('File laporan kosong');
      }

      final bytes = data is Uint8List ? data : Uint8List.fromList(data);
      if (!_isPdf(bytes)) {
        throw const LaporanDownloadException(
          'Respons laporan bukan file PDF yang valid',
        );
      }

      final fileName = _extractFileName(
        response.headers.value('content-disposition'),
        fallback: 'laporan-pertumbuhan.pdf',
      );
      final savedLocation = await _savePdf(fileName, bytes);
      if (savedLocation == null || savedLocation.isEmpty) {
        throw const LaporanDownloadCancelled();
      }

      return LaporanDownloadResult(
        fileName: fileName,
        savedLocation: savedLocation,
      );
    } on DioException catch (error) {
      throw LaporanDownloadException(
        _readBackendError(error),
        statusCode: error.response?.statusCode,
      );
    }
  }

  static Future<String?> _saveWithDialog(
    String fileName,
    Uint8List bytes,
  ) {
    final nameWithoutExtension = fileName.toLowerCase().endsWith('.pdf')
        ? fileName.substring(0, fileName.length - 4)
        : fileName;
    return FileSaver.instance.saveAs(
      name: nameWithoutExtension,
      bytes: bytes,
      fileExtension: 'pdf',
      mimeType: MimeType.pdf,
    );
  }

  static bool _isPdf(Uint8List bytes) {
    const signature = [0x25, 0x50, 0x44, 0x46, 0x2D]; // %PDF-
    if (bytes.length < signature.length) return false;
    for (var index = 0; index < signature.length; index++) {
      if (bytes[index] != signature[index]) return false;
    }
    return true;
  }

  static String _extractFileName(
    String? contentDisposition, {
    required String fallback,
  }) {
    if (contentDisposition == null || contentDisposition.isEmpty) {
      return fallback;
    }

    final encoded = RegExp(
      r"filename\*=UTF-8''([^;]+)",
      caseSensitive: false,
    ).firstMatch(contentDisposition)?.group(1);
    final regular = RegExp(
      r'filename\s*=\s*"?([^";]+)',
      caseSensitive: false,
    ).firstMatch(contentDisposition)?.group(1);

    var candidate = encoded ?? regular;
    if (candidate == null || candidate.trim().isEmpty) return fallback;
    var safeCandidate = candidate.trim();
    try {
      safeCandidate = Uri.decodeComponent(safeCandidate);
    } on FormatException {
      // Gunakan nilai mentah jika filename* dari server tidak valid.
    }

    safeCandidate = safeCandidate
        .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '-')
        .replaceAll(RegExp(r'\s+'), ' ');
    if (safeCandidate.isEmpty) return fallback;
    return safeCandidate.toLowerCase().endsWith('.pdf')
        ? safeCandidate
        : '$safeCandidate.pdf';
  }

  static String _readBackendError(DioException error) {
    final data = error.response?.data;
    try {
      dynamic decoded = data;
      if (data is List<int>) {
        decoded = jsonDecode(utf8.decode(data));
      } else if (data is String) {
        decoded = jsonDecode(data);
      }
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {
      // Fallback ke pesan yang sudah dinormalisasi interceptor.
    }
    return error.error?.toString() ??
        error.message ??
        'Laporan gagal diunduh, silakan coba lagi';
  }
}
