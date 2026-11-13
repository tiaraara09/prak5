import 'package:flutter/material.dart';

import 'database/db_helper.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //memastikan binding widget sudah siap sebelum menjalankan kode lainnya
  await DbHelper.instance.database; // buka / buat database SQLite
  final user = await AuthService.instance.restoreSession(); // cek sesi login tersimpan
  runApp(MyApp(startLoggedIn: user != null));
}

class MyApp extends StatelessWidget {
  final bool startLoggedIn;
  const MyApp({super.key, required this.startLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: startLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
