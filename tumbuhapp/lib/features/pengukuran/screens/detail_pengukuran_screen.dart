import 'package:flutter/material.dart';

class DetailPengukuranScreen extends StatelessWidget {
  final int pengukuranId;
  const DetailPengukuranScreen({
    super.key,
    required this.pengukuranId,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengukuran')),
      body: Center(
        child: Text('Pengukuran ID: $pengukuranId'),
      ),
    );
  }
}
