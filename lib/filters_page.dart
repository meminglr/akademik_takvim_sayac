import 'package:flutter/material.dart';
import 'categories.dart';

class FiltersPage extends StatelessWidget {
  const FiltersPage({
    super.key,
    required this.enabledCategories,
    required this.onChanged,
  });

  final Set<String> enabledCategories;
  final void Function(String category, bool enabled) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Gösterilecek bölümleri seçin',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        ...EventCategories.all.map(
          (cat) => SwitchListTile.adaptive(
            title: Text(cat),
            value: enabledCategories.contains(cat),
            onChanged: (v) => onChanged(cat, v),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilledButton.tonal(
            onPressed: () {
              // Reset to default: only exams
              for (final cat in EventCategories.all) {
                onChanged(cat, cat == EventCategories.exams);
              }
            },
            child: const Text('Varsayılanı Yükle (Sadece sınavlar)'),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
