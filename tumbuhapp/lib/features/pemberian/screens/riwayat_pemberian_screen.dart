import 'package:flutter/material.dart';

class RiwayatPemberianScreen extends StatelessWidget {
  final String anakId;
  const RiwayatPemberianScreen({
    super.key,
    required this.anakId,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pemberian')),
      body: Center(
        child: Text('Riwayat Pemberian Anak: $anakId'),
      ),
    );
  }
}
