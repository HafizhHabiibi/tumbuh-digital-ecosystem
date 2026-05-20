import 'package:flutter/material.dart';

class DetailAnakScreen extends StatelessWidget {
  final String anakId;
  const DetailAnakScreen({
    super.key,
    required this.anakId,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Anak')),
      body: Center(
        child: Text('Detail Anak ID: $anakId'),
      ),
    );
  }
}
