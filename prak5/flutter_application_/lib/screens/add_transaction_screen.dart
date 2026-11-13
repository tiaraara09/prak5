import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/transaction_model.dart';
import '../services/auth_service.dart';
import '../utils/categories.dart';
import '../utils/format.dart';
import '../utils/thousands_formatter.dart';

/// Form input transaksi (Modul III): TextEditingController, Form + GlobalKey,
/// DropdownButtonFormField, validator, dan Tugas input Tanggal (wajib diisi, showDatePicker).
/// Dipakai untuk tambah baru maupun ubah ([transaction] != null).
class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;
  final String initialType;
  final String? initialCategory;

  const AddTransactionScreen({
    super.key,
    this.transaction,
    this.initialType = 'expense',
    this.initialCategory,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // GlobalKey untuk mengontrol form dan memicu validasi
  final _formKey = GlobalKey<FormState>();

  // Controller untuk mengambil teks dari input
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  late String _type;
  late String _selectedCategory;
  bool _saving = false;

  bool get _isEdit => widget.transaction != null;
  List<String> get _categories => _type == 'income' ? incomeCategories : expenseCategories;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _type = t?.type ?? widget.initialType;
    final wanted = t?.category ?? widget.initialCategory;
    _selectedCategory = (wanted != null && _categories.contains(wanted)) ? wanted : _categories.first;
    _titleController.text = t?.title ?? '';
    _amountController.text = t == null ? '' : formatRupiah(t.amount, prefix: false);
    _dateController.text = formatTanggalInput(t?.date ?? DateTime.now());
  }

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup untuk mencegah memory leak
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final first = DateTime(2000);
    final last = DateTime(2100);
    var initial = parseTanggalInput(_dateController.text) ?? DateTime.now();
    if (initial.isBefore(first) || initial.isAfter(last)) initial = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      setState(() => _dateController.text = formatTanggalInput(picked));
    }
  }

  Future<void> _save() async {
    // Jalankan validasi seluruh field
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final messenger = ScaffoldMessenger.of(context);
    final uid = AuthService.instance.currentUser!.id!;
    final model = TransactionModel(
      id: widget.transaction?.id,
      userId: uid,
      title: _titleController.text.trim(),
      amount: parseRupiah(_amountController.text)!,
      category: _selectedCategory,
      type: _type,
      date: parseTanggalInput(_dateController.text)!,
    );

    if (_isEdit) {
      await DbHelper.instance.updateTransaction(model);
    } else {
      await DbHelper.instance.insertTransaction(model);
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text('Tersimpan: ${model.title} (${formatRupiah(model.amount)})'),
        backgroundColor: Colors.green,
      ),
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Ubah Transaksi' : 'Catat Transaksi Baru'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      // SingleChildScrollView mencegah error layout saat keyboard muncul
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Jenis transaksi
              SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: 'expense',
                    label: Text('Pengeluaran'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment<String>(
                    value: 'income',
                    label: Text('Pemasukan'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) {
                  setState(() {
                    _type = s.first;
                    if (!_categories.contains(_selectedCategory)) {
                      _selectedCategory = _categories.first;
                    }
                  });
                },
              ),
              const SizedBox(height: 20),

              // Input 1: Judul Transaksi
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Judul Transaksi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul transaksi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input 2: Nominal (keyboard angka)
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: const [ThousandsSeparatorFormatter()], // 20000 -> 20.000 saat diketik
                decoration: const InputDecoration(
                  labelText: 'Nominal (Rp)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nominal wajib diisi';
                  final n = parseRupiah(value);
                  if (n == null) return 'Harus berupa angka bulat yang valid';
                  if (n <= 0) return 'Nominal harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input 3: Kategori Dropdown
              DropdownButtonFormField<String>(
                key: ValueKey(_type),
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(value: category, child: Text(category));
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue == null) return;
                  setState(() => _selectedCategory = newValue);
                },
              ),
              const SizedBox(height: 16),

              // Input 4 (Tugas): Tanggal - ketik DD/MM/YYYY atau pilih lewat showDatePicker
              TextFormField(
                controller: _dateController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: 'Tanggal Transaksi',
                  hintText: 'DD/MM/YYYY',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.event),
                  suffixIcon: IconButton(
                    tooltip: 'Pilih tanggal',
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _pickDate,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Tanggal wajib diisi';
                  if (parseTanggalInput(value) == null) {
                    return 'Gunakan format DD/MM/YYYY dengan tanggal yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _saving ? null : _save,
                child: const Text(
                  'Simpan Transaksi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
