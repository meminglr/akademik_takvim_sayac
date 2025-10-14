import 'package:akademik_takvim_sayac/shell.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3B82F6),
        scaffoldBackgroundColor: const Color(0xFFF7F7F8),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            side: BorderSide(color: Color(0xFFE6E6E9), width: 1),
          ),
        ),
        textTheme: const TextTheme(
          titleMedium: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF0F172A),
          ),
          bodyMedium: TextStyle(fontSize: 13.5, color: Color(0xFF475569)),
        ),
      ),
      home: const AppShell(),
    );
  }
}
