import 'package:flutter/material.dart';

class RiwayatPengukuranScreen extends StatelessWidget {
  final String anakId;
  const RiwayatPengukuranScreen({
    super.key,
    required this.anakId,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pengukuran')),
      body: Center(
        child: Text('Riwayat Pengukuran Anak: $anakId'),
      ),
    );
  }
}
