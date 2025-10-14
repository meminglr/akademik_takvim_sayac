import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:akademik_takvim_sayac/home.dart';
import 'package:akademik_takvim_sayac/filters_page.dart';
import 'categories.dart';

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
      Home(enabledCategories: _enabledCategories),
      FiltersPage(
        enabledCategories: _enabledCategories,
        onChanged: _toggleCategory,
      ),
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
            icon: Icon(Icons.tune_rounded),
            label: 'Filtreler',
          ),
        ],
      ),
    );
  }
}
