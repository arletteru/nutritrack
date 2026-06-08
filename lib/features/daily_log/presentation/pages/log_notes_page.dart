import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/theme.dart';

class LogNotesPage extends HookConsumerWidget {
  const LogNotesPage({super.key, required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesCtrl = useTextEditingController();
    final mood = useState(3);

    return Scaffold(
      appBar: AppBar(title: const Text('Nota del día')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Cómo te sientes hoy?', style: context.textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (i) {
                final score = i + 1;
                final emojis = ['😞','😕','😐','🙂','😄'];
                return GestureDetector(
                  onTap: () => mood.value = score,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: mood.value == score
                          ? context.colors.primaryContainer
                          : context.colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(context.radiusMd),
                      border: Border.all(
                        color: mood.value == score ? context.colors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(child: Text(emojis[i], style: const TextStyle(fontSize: 24))),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Text('Notas libres', style: context.textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '¿Cómo fue tu día? ¿Hubo algo difícil?',
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(width: double.infinity, height: 52,
              child: FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Guardar nota'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
