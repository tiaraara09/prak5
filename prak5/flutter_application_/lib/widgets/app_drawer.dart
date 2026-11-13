import 'package:flutter/material.dart';

import '../screens/calculator_screen.dart';
import '../screens/dart_basics_screen.dart';
import '../screens/laundry_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/shapes_screen.dart';
import '../services/auth_service.dart';

/// Menu samping: akses ke seluruh modul praktikum selain Expense Tracker.
class AppDrawer extends StatelessWidget {
  /// Dipanggil saat kembali dari halaman lain (agar dashboard memuat ulang data).
  final VoidCallback onReturn;
  const AppDrawer({super.key, required this.onReturn});

  Future<void> _open(BuildContext context, Widget page) async {
    final nav = Navigator.of(context);
    nav.pop(); // tutup drawer
    await nav.push(MaterialPageRoute(builder: (_) => page));
    onReturn();
  }

  Future<void> _logout(BuildContext context) async {
    final nav = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Data Anda tetap tersimpan di perangkat ini.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Keluar')),
        ],
      ),
    );
    if (ok != true) return;
    await AuthService.instance.logout();
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser!;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF4527A0), Color(0xFF1976D2)]),
            ),
            accountName: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(user.initials,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4527A0))),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Beranda'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profil Saya'),
            onTap: () => _open(context, const ProfileScreen()),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Text('Alat Bantu', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('Kalkulator'),
            onTap: () => _open(context, const CalculatorScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.local_laundry_service_outlined),
            title: const Text('Mini Laundry'),
            onTap: () => _open(context, const LaundryScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Bangun Datar & Ruang'),
            onTap: () => _open(context, const ShapesScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Dart Dasar & OOP'),
            onTap: () => _open(context, const DartBasicsScreen()),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
