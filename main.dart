import 'package:flutter/material.dart';
import 'package:mas_app/screens/home_screen.dart';
import 'package:mas_app/screens/payments_screen.dart';
import 'package:mas_app/screens/ocr_screen.dart';
import 'package:mas_app/screens/ai_screen.dart';
import 'package:mas_app/screens/settings_screen.dart';

void main() {
  runApp(const MASApp());
}

class MASApp extends StatefulWidget {
  const MASApp({super.key});
  @override
  State<MASApp> createState() => _MASAppState();
}

class _MASAppState extends State<MASApp> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAS – AI Banking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF123D7A),
          primary: const Color(0xFF123D7A),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F2FF),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 110,
          flexibleSpace: Image.asset(
            'assets/app_banner.png',
            fit: BoxFit.cover,
          ),
        ),
        body: IndexedStack(
          index: _index,
          children: const [
            HomeScreen(),
            PaymentsScreen(),
            OCRScreen(),
            AIScreen(),
            SettingsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.send_outlined), selectedIcon: Icon(Icons.send), label: 'Payments'),
            NavigationDestination(icon: Icon(Icons.document_scanner_outlined), selectedIcon: Icon(Icons.document_scanner), label: 'OCR'),
            NavigationDestination(icon: Icon(Icons.smart_toy_outlined), selectedIcon: Icon(Icons.smart_toy), label: 'AI'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
