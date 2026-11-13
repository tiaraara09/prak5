import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

/// Profil (Latihan Praktikum 2): foto/avatar, nama, NIM, alamat, nomor HP, jurusan,
/// memakai Text, Container, ElevatedButton, Icon, Image (asset & network), CircleAvatar,
/// Row, dan Column. Data profil tersimpan di SQLite dan dapat diedit.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _logoUrl =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/01/Logo_Unand.svg/600px-Logo_Unand.svg.png';

  AppUser get _user => AuthService.instance.currentUser!;

  String _val(String s) => s.trim().isEmpty ? 'Belum diisi' : s;

  Future<void> _edit() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ProfileEditSheet(user: _user),
    );
    if (saved == true && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil diperbarui'), backgroundColor: Colors.green),
      );
    }
  }

  Widget _info(IconData icon, String label, String value) {
    final empty = value.trim().isEmpty;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withAlpha(30),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(
        _val(value),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: empty ? Colors.grey : Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = _user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header (Container + BoxDecoration)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        u.initials,
                        style: const TextStyle(
                            fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(u.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(u.email, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  // Image.asset (logo aplikasi) dan Image.network (logo kampus) dalam satu Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset('assets/images/logo.png', width: 44, height: 44),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.network(
                          _logoUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.school, size: 40, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _info(Icons.badge_outlined, 'NIM', u.nim),
                    const Divider(height: 1),
                    _info(Icons.home_outlined, 'Alamat', u.address),
                    const Divider(height: 1),
                    _info(Icons.phone_outlined, 'Nomor HP', u.phone),
                    const Divider(height: 1),
                    _info(Icons.school_outlined, 'Jurusan', u.major),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _edit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profil',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileEditSheet extends StatefulWidget {
  final AppUser user;
  const _ProfileEditSheet({required this.user});

  @override
  State<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<_ProfileEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _nim;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _major;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _name = TextEditingController(text: u.name);
    _nim = TextEditingController(text: u.nim);
    _address = TextEditingController(text: u.address);
    _phone = TextEditingController(text: u.phone);
    _major = TextEditingController(text: u.major);
  }

  @override
  void dispose() {
    _name.dispose();
    _nim.dispose();
    _address.dispose();
    _phone.dispose();
    _major.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final updated = widget.user.copyWith(
      name: _name.text.trim(),
      nim: _nim.text.trim(),
      address: _address.text.trim(),
      phone: _phone.text.trim(),
      major: _major.text.trim(),
    );
    await DbHelper.instance.updateProfile(updated);
    await AuthService.instance.refreshUser();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Edit Profil',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: _dec('Nama Lengkap', Icons.person_outline),
                validator: (v) => validateRequired(v, 'Nama'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nim,
                decoration: _dec('NIM', Icons.badge_outlined),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                decoration: _dec('Alamat', Icons.home_outlined),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: _dec('Nomor HP', Icons.phone_outlined),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return null;
                  if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(s)) {
                    return 'Nomor HP harus 8-15 digit angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _major,
                decoration: _dec('Jurusan', Icons.school_outlined),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _save,
                child: const Text('Simpan Perubahan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
