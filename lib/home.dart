import 'package:akademik_takvim_sayac/list.dart';
import 'package:akademik_takvim_sayac/categories.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.enabledCategories,
    required this.onToggleCategory,
  });

  final Set<String> enabledCategories;
  final void Function(String category, bool enabled) onToggleCategory;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String selectedTerm = 'Güz';
  String searchQuery = '';
  bool showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  static const _prefsSelectedTermKey = 'selectedTerm';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedTerm();
  }

  Future<void> _loadSelectedTerm() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_prefsSelectedTermKey);
    if (value == 'Güz' || value == 'Bahar' || value == 'Diğer') {
      setState(() => selectedTerm = value!);
    }
  }

  Future<void> _saveSelectedTerm() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsSelectedTermKey, selectedTerm);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final filteredItems = akademikTakvim.where((item) {
      final category = deriveCategory(item);
      final q = searchQuery.trim().toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          item.title.toLowerCase().contains(q) ||
          (item.notes?.toLowerCase().contains(q) ?? false);
      final periodMatches = selectedTerm == 'Diğer'
          ? (item.period != 'Güz' && item.period != 'Bahar')
          : item.period == selectedTerm;
      return periodMatches &&
          item.end.isAfter(now) &&
          widget.enabledCategories.contains(category) &&
          matchesQuery;
    }).toList();

    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'Güz', label: Text('Güz')),
                          ButtonSegment(value: 'Bahar', label: Text('Bahar')),
                          ButtonSegment(value: 'Diğer', label: Text('Diğer')),
                        ],
                        selected: {selectedTerm},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            selectedTerm = newSelection.first;
                          });
                          _saveSelectedTerm();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Filtreler',
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          useSafeArea: true,
                          isScrollControlled: true,
                          showDragHandle: true,
                          builder: (ctx) {
                            final localEnabled = Set<String>.of(
                              widget.enabledCategories,
                            );
                            return FractionallySizedBox(
                              heightFactor: 0.9,
                              child: StatefulBuilder(
                                builder: (context, setModalState) {
                                  return ListView(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          16,
                                          16,
                                          16,
                                          8,
                                        ),
                                        child: Text(
                                          'Gösterilecek bölümleri seçin',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      ...EventCategories.all.map(
                                        (cat) => SwitchListTile.adaptive(
                                          title: Text(cat),
                                          value: localEnabled.contains(cat),
                                          onChanged: (v) {
                                            setModalState(() {
                                              if (v) {
                                                localEnabled.add(cat);
                                              } else {
                                                localEnabled.remove(cat);
                                              }
                                            });
                                            widget.onToggleCategory(cat, v);
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: FilledButton.tonal(
                                          onPressed: () {
                                            setModalState(() {
                                              localEnabled
                                                ..clear()
                                                ..add(EventCategories.exams);
                                            });
                                            for (final cat
                                                in EventCategories.all) {
                                              widget.onToggleCategory(
                                                cat,
                                                cat == EventCategories.exams,
                                              );
                                            }
                                          },
                                          child: const Text(
                                            'Varsayılanı Yükle (Sadece sınavlar)',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.tune_rounded),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () {
                        setState(() => showSearch = !showSearch);
                        if (showSearch) {
                          // Delay focus to next frame to ensure TextField is built
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _searchFocusNode.requestFocus();
                          });
                        } else {
                          _searchFocusNode.unfocus();
                        }
                      },
                      icon: Icon(
                        showSearch ? Icons.close_rounded : Icons.search_rounded,
                      ),
                      tooltip: 'Ara',
                    ),
                  ],
                ),
                if (showSearch) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (v) => setState(() => searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Ara (başlık/notlar)',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: searchQuery.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => setState(() {
                                searchQuery = '';
                                _searchController.clear();
                                _searchFocusNode.requestFocus();
                              }),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.search,
                    autofocus: true,
                  ),
                ],
              ],
            ),
          ),
          if (filteredItems.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.inbox_rounded, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Gösterilecek sayaç yok',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 6),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Üstteki filtre düğmesinden göstermek istediğiniz bölümleri seçebilirsiniz.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (itemBuilder, index) {
                  var item = filteredItems[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.event,
                                size: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDateRange(item.start, item.end),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_isSameDay(item.start, item.end))
                            _CountdownBox(
                              color: _endColor(item.end, now, context),
                              child: _buildCountdownContent(
                                context: context,
                                label: 'Etkinliğe kalan',
                                target: item.end,
                                now: now,
                                finishedText: 'Bitti',
                                color: _endColor(item.end, now, context),
                              ),
                            )
                          else ...[
                            _CountdownBox(
                              color: _startColor(item.start, now, context),
                              child: _buildCountdownContent(
                                context: context,
                                label: 'Başlangıca kalan',
                                target: item.start,
                                now: now,
                                finishedText: 'Başladı',
                                color: _startColor(item.start, now, context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _CountdownBox(
                              color: _endColor(item.end, now, context),
                              child: _buildCountdownContent(
                                context: context,
                                label: 'Bitişe kalan',
                                target: item.end,
                                now: now,
                                finishedText: 'Bitti',
                                color: _endColor(item.end, now, context),
                              ),
                            ),
                          ],
                          if (item.notes != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              item.notes!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    String two(int n) => n.toString().padLeft(2, '0');
    final startStr = "${two(start.day)}.${two(start.month)}.${start.year}";
    final endStr = "${two(end.day)}.${two(end.month)}.${end.year}";
    return "$startStr - $endStr";
  }

  String _remainingWeeksDays(DateTime end, DateTime now) {
    final totalDays = end.isAfter(now) ? end.difference(now).inDays : 0;
    final weeks = totalDays ~/ 7;
    final days = totalDays % 7;
    if (weeks > 0 && days > 0) return "$weeks hafta $days gün";
    if (weeks > 0) return "$weeks hafta";
    return "$days gün";
  }

  // Themed helpers
  Color _startColor(DateTime start, DateTime now, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (now.isAfter(start)) return cs.secondary;
    final days = start.difference(now).inDays;
    if (days <= 3) return cs.error;
    if (days <= 14) return cs.tertiary;
    return cs.primary;
  }

  Color _endColor(DateTime end, DateTime now, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (now.isAfter(end)) return cs.outline;
    final days = end.difference(now).inDays;
    if (days <= 3) return cs.error;
    if (days <= 14) return cs.tertiary;
    return cs.primary;
  }

  Widget _buildCountdownContent({
    required BuildContext context,
    required String label,
    required DateTime target,
    required DateTime now,
    required String finishedText,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final isFinished = !target.isAfter(now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 8, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.timer_rounded, size: 18, color: color),
            const SizedBox(width: 8),
            if (!isFinished)
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                child: TimerCountdown(endTime: target),
              )
            else
              Text(
                finishedText,
                style: textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Kalan: ' + _remainingWeeksDays(target, now),
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _CountdownBox extends StatelessWidget {
  const _CountdownBox({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: child,
    );
  }
}
