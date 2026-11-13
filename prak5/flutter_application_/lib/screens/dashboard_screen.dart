import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/transaction_model.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/dashboard_widgets.dart';
import 'add_transaction_screen.dart';

/// Halaman utama (Modul I + II): sapaan, kartu saldo, tombol aksi, daftar transaksi.
/// Semua angka berasal dari SQLite, bukan data statis.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TransactionModel> _items = [];
  int _income = 0;
  int _expense = 0;
  bool _loading = true;

  int get _uid => AuthService.instance.currentUser!.id!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await DbHelper.instance.getTransactions(_uid);
    final totals = await DbHelper.instance.getTotals(_uid);
    if (!mounted) return;
    setState(() {
      _items = items;
      _income = totals['income'] ?? 0;
      _expense = totals['expense'] ?? 0;
      _loading = false;
    });
  }

  Future<void> _openForm({
    TransactionModel? edit,
    String type = 'expense',
    String? category,
  }) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          transaction: edit,
          initialType: type,
          initialCategory: category,
        ),
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _delete(TransactionModel t) async {
    // Hapus dari daftar lebih dulu agar widget Dismissible tidak tertinggal di layar.
    setState(() => _items.removeWhere((e) => e.id == t.id));
    await DbHelper.instance.deleteTransaction(t.id!, _uid);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${t.title}" dihapus')),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(onReturn: _load),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GreetingWidget(name: user.firstName),
                    const SizedBox(height: 20),
                    BalanceCardWidget(
                      balance: _income - _expense,
                      income: _income,
                      expense: _expense,
                    ),
                    const SizedBox(height: 20),
                    ActionButtonsWidget(
                      onIncome: () => _openForm(type: 'income'),
                      onExpense: () => _openForm(type: 'expense'),
                      onTransfer: () => _openForm(type: 'expense', category: 'Transfer'),
                    ),
                    const SizedBox(height: 20),
                    RecentTransactionsWidget(
                      items: _items,
                      onTap: (t) => _openForm(edit: t, type: t.type),
                      onDelete: _delete,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
