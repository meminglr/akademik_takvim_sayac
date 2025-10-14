import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:akademik_takvim_sayac/home.dart';
// Filters UI moved into Home
import 'categories.dart';
import 'package:akademik_takvim_sayac/list.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // Default only exam counters enabled
  final Set<String> _enabledCategories = {EventCategories.exams};

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('enabledCategories');
    if (saved != null && saved.isNotEmpty) {
      setState(() {
        _enabledCategories
          ..clear()
          ..addAll(saved);
      });
    }
  }

  void _toggleCategory(String category, bool enabled) {
    setState(() {
      if (enabled) {
        _enabledCategories.add(category);
      } else {
        _enabledCategories.remove(category);
      }
    });
    _savePrefs();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('enabledCategories', _enabledCategories.toList());
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Home(
        enabledCategories: _enabledCategories,
        onToggleCategory: _toggleCategory,
      ),
      const _FullCalendarTable(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maun Akademik Sayaç'),
        centerTitle: true,
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Sayaçlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_chart_rounded),
            label: 'Tablo',
          ),
        ],
      ),
    );
  }
}

class _FullCalendarTable extends StatelessWidget {
  const _FullCalendarTable();

  @override
  Widget build(BuildContext context) {
    final rows = akademikTakvim
        .map(
          (e) => DataRow(
            cells: [
              DataCell(_cell(e.period, maxW: 90)),
              DataCell(_cell(_fmt(e.start), maxW: 84, mono: true)),
              DataCell(_cell(_fmt(e.end), maxW: 84, mono: true)),
              DataCell(_cell(e.title, maxW: 260)),
              DataCell(_cell(e.notes ?? '-', maxW: 200)),
            ],
          ),
        )
        .toList();

    final columns = const [
      DataColumn(label: Text('Dönem')),
      DataColumn(label: Text('Başlangıç')),
      DataColumn(label: Text('Bitiş')),
      DataColumn(label: Text('Başlık')),
      DataColumn(label: Text('Not')),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns,
          rows: rows,
          columnSpacing: 12,
          horizontalMargin: 8,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 44,
          headingRowHeight: 40,
        ),
      ),
    );
  }

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final yy = (d.year % 100).toString().padLeft(2, '0');
    return "${two(d.day)}.${two(d.month)}.$yy";
  }

  Widget _cell(String text, {double? maxW, bool mono = false}) {
    final child = Text(
      text,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: mono
          ? const TextStyle(fontFeatures: [FontFeature.tabularFigures()])
          : null,
    );
    if (maxW != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: child,
      );
    }
    return child;
  }
}
