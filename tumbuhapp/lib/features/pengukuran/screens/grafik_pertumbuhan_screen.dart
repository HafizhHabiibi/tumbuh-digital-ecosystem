import 'package:flutter/material.dart';

class GrafikPertumbuhanScreen extends StatelessWidget {
  final String anakId;
  const GrafikPertumbuhanScreen({
    super.key,
    required this.anakId,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grafik Pertumbuhan')),
      body: Center(
        child: Text('Grafik Anak: $anakId'),
      ),
    );
  }
}
