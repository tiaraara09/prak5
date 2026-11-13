import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../utils/categories.dart';
import '../utils/format.dart';

/// Warna kartu saldo. (Tugas Modul I: ganti menjadi Colors.teal bila diminta.)
const Color kBalanceCardColor = Colors.blueAccent;

/// Teks statis "No. Rekening" (Tugas Modul I).
const String kAccountNumber = '1234-5678';

// 1. STATELESS WIDGET (Sapaan Pengguna) - Modul I
class GreetingWidget extends StatelessWidget {
  final String name;
  const GreetingWidget({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.person, size: 30, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Selamat datang kembali!',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 2. STATEFUL WIDGET (Kartu Saldo dengan Toggle) - Modul I
class BalanceCardWidget extends StatefulWidget {
  final int balance;
  final int income;
  final int expense;
  const BalanceCardWidget({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  State<BalanceCardWidget> createState() => _BalanceCardWidgetState();
}

class _BalanceCardWidgetState extends State<BalanceCardWidget> {
  bool _isBalanceVisible = true;

  void _toggleVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  Widget _summary(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: kBalanceCardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Saldo Utama',
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                IconButton(
                  icon: Icon(
                    _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: _toggleVisibility,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isBalanceVisible ? formatRupiah(widget.balance) : 'Rp *********',
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text('No. Rekening: $kAccountNumber',
                style: TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summary(Icons.arrow_downward, 'Pemasukan',
                    _isBalanceVisible ? formatRupiah(widget.income) : 'Rp ****'),
                _summary(Icons.arrow_upward, 'Pengeluaran',
                    _isBalanceVisible ? formatRupiah(widget.expense) : 'Rp ****'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 3. WIDGET TOMBOL AKSI (ROW) - Modul II
class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onIncome;
  final VoidCallback onExpense;
  final VoidCallback onTransfer;
  const ActionButtonsWidget({
    super.key,
    required this.onIncome,
    required this.onExpense,
    required this.onTransfer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Icons.arrow_downward, 'Pemasukan', Colors.green, onIncome),
        _buildActionButton(Icons.arrow_upward, 'Pengeluaran', Colors.red, onExpense),
        _buildActionButton(Icons.swap_horiz, 'Transfer', Colors.blue, onTransfer),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(51), // ~20% transparan
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

Future<bool> _confirmDelete(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Hapus transaksi?'),
      content: const Text('Data yang dihapus tidak dapat dikembalikan.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
      ],
    ),
  );
  return result ?? false;
}

// 4. WIDGET DAFTAR TRANSAKSI (COLUMN & LISTTILE) - Modul II
// Pengeluaran = merah, pemasukan = hijau (Tugas Modul II).
class RecentTransactionsWidget extends StatelessWidget {
  final List<TransactionModel> items;
  final void Function(TransactionModel) onTap;
  final void Function(TransactionModel) onDelete;

  const RecentTransactionsWidget({
    super.key,
    required this.items,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Transaksi Terakhir',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        if (items.isNotEmpty)
          const Text('Ketuk untuk mengubah, geser ke kiri untuk menghapus',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Belum ada transaksi.\nKetuk Pemasukan atau Pengeluaran untuk mencatat yang pertama.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      Dismissible(
                        key: ValueKey('tx-${items[i].id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) => _confirmDelete(context),
                        onDismissed: (_) => onDelete(items[i]),
                        child: ListTile(
                          onTap: () => onTap(items[i]),
                          leading: CircleAvatar(
                            backgroundColor: categoryColor(items[i].category),
                            child: Icon(categoryIcon(items[i].category), color: Colors.white),
                          ),
                          title: Text(items[i].title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${formatTanggal(items[i].date)} • ${items[i].category}'),
                          trailing: Text(
                            '${items[i].isIncome ? '+' : '-'} ${formatRupiah(items[i].amount)}',
                            style: TextStyle(
                              color: items[i].isIncome ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (i != items.length - 1) const Divider(height: 1),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
