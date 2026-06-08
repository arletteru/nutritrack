import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/theme/theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

part 'patient_form_page.g.dart';

@riverpod
class CreatePatientNotifier extends _$CreatePatientNotifier {
  @override
  FutureOr<void> build() => null;

  Future<void> create({
    required String fullName,
    required String email,
    required String expediente,
    required String nutriologistId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final db = FirebaseFirestore.instance;

      // 1. Crear el documento en patients/
      final patientRef = await db.collection('patients').add({
        'fullName': fullName,
        'email': email,
        'expediente': expediente,
        'nutriologistId': nutriologistId,
        'uid': '',
        'status': 'active',
        'assignedAt': FieldValue.serverTimestamp(),
      });

      // 2. Guardar el link email → patientDocId
      //    El punto no está permitido en IDs de Firestore, lo reemplazamos
      final emailKey = email.replaceAll('.', ',');
      await db.collection('patient_links').doc(emailKey).set({
        'patientDocId': patientRef.id,
        'email': email,
        'nutriologistId': nutriologistId,
      });
    });
  }
}

class PatientFormPage extends HookConsumerWidget {
  const PatientFormPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameCtrl = useTextEditingController();
    final emailCtrl = useTextEditingController();
    final expCtrl = useTextEditingController();
    final notifier = ref.read(createPatientProvider.notifier);
    final state = ref.watch(createPatientProvider);

    ref.listen(createPatientProvider, (_, next) {
      if (next is AsyncData && !next.isLoading) {
        context.pop();
      }
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error.toString()),
          backgroundColor: context.colors.error,
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo paciente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Nombre completo'),
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Correo electrónico'),
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: expCtrl,
                decoration: const InputDecoration(
                    labelText: 'Número de expediente'),
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          if (formKey.currentState?.validate() ?? false) {
                            final user = ref
                                .read(authStateChangesProvider).value
                                ;
                            notifier.create(
                              fullName: nameCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              expediente: expCtrl.text.trim(),
                              nutriologistId: user?.uid ?? '',
                            );
                          }
                        },
                  child: state.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text('Guardar paciente'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
