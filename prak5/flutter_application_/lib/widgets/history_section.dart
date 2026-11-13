import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../services/auth_service.dart';
import '../utils/format.dart';

/// Riwayat perhitungan yang tersimpan di SQLite (per pengguna & per jenis alat).
/// Ubah [version] dari parent untuk memuat ulang setelah ada data baru.
class HistorySection extends StatefulWidget {
  final String kind;
  final int version;
  const HistorySection({super.key, required this.kind, required this.version});

  @override
  State<HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<HistorySection> {
  List<Map<String, Object?>> _rows = [];

  int get _uid => AuthService.instance.currentUser!.id!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant HistorySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.version != widget.version) _load();
  }

  Future<void> _load() async {
    final rows = await DbHelper.instance.getHistories(_uid, widget.kind);
    if (!mounted) return;
    setState(() => _rows = rows);
  }

  Future<void> _clear() async {
    await DbHelper.instance.clearHistories(_uid, widget.kind);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Riwayat Terakhir',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (_rows.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clear,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Hapus'),
                  ),
              ],
            ),
            if (_rows.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Belum ada riwayat. Hasil perhitungan akan tersimpan di sini.',
                    style: TextStyle(color: Colors.grey)),
              )
            else
              for (final r in _rows)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history, color: Colors.grey),
                  title: Text(r['detail'] as String),
                  subtitle: Text(formatWaktu(DateTime.parse(r['created_at'] as String))),
                ),
          ],
        ),
      ),
    );
  }
}
