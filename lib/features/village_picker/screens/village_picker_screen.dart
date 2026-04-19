import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/village_provider.dart';
import '../../../core/utils/localization.dart';

class VillagePickerScreen extends ConsumerWidget {
  const VillagePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final villages = ref.watch(villagesProvider);
    final selectedVillage = ref.watch(activeVillageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l('village_picker_title'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l('select_village_hint'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: villages.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final village = villages[index];
                  final isSelected = selectedVillage?.id == village.id;
                  return Card(
                    child: ListTile(
                      title: Text(
                        village.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        village.nameEn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle)
                          : const Icon(Icons.radio_button_unchecked),
                      onTap: () {
                        ref.read(activeVillageProvider.notifier).state = village;
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
