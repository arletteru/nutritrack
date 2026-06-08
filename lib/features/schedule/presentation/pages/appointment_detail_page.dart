import 'package:flutter/material.dart';

class AppointmentDetailPage extends StatelessWidget {
  const AppointmentDetailPage({super.key, required this.appointmentId});
  final String appointmentId;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detalle de cita')),
    body: Center(child: Text('Cita: $appointmentId')),
  );
}
