import 'package:flutter/material.dart';

class StatusRujukanScreen extends StatelessWidget {
  final String anakId;
  const StatusRujukanScreen({
    super.key,
    required this.anakId,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Rujukan')),
      body: Center(
        child: Text('Status Rujukan Anak: $anakId'),
      ),
    );
  }
}
