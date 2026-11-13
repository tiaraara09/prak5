import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../logic/laundry.dart';
import '../services/auth_service.dart';
import '../utils/format.dart';
import '../utils/validators.dart';
import '../widgets/history_section.dart';

class LaundryScreen extends StatefulWidget {
  const LaundryScreen({super.key});

  @override
  State<LaundryScreen> createState() => _LaundryScreenState();
}

class _LaundryScreenState extends State<LaundryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  String _packageCode = laundryPackages.first.code;
  bool _useOop = true;
  LaundryResult? _result;
  String _resultLabel = '';
  int _historyVersion = 0;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;
    final kg = parseAngka(_weightController.text)!;
    final package = laundryPackages.firstWhere((p) => p.code == _packageCode);

    // Dua pendekatan menghasilkan angka yang sama.
    final result = _useOop
        ? LaundryOrder(package, kg).toResult()
        : hitungLaundryProsedural(_packageCode, kg);

    setState(() {
      _result = result;
      _resultLabel = '${package.name} • ${formatAngka(kg)} kg';
    });
    await DbHelper.instance.insertHistory(
      AuthService.instance.currentUser!.id!,
      'laundry',
      '$_resultLabel → ${formatRupiah(result.total)} (diskon ${result.discountPercent}%)',
    );
    if (mounted) setState(() => _historyVersion++);
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    final style = TextStyle(
      fontSize: bold ? 20 : 15,
      fontWeight: bold ? FontWeight.bold : FontWeight.w500,
      color: color ?? Colors.white,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Laundry'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              segments: const <ButtonSegment<bool>>[
                ButtonSegment<bool>(value: false, label: Text('Prosedural'), icon: Icon(Icons.functions)),
                ButtonSegment<bool>(value: true, label: Text('OOP'), icon: Icon(Icons.account_tree_outlined)),
              ],
              selected: {_useOop},
              onSelectionChanged: (s) => setState(() => _useOop = s.first),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _packageCode,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Paket laundry',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_laundry_service_outlined),
                    ),
                    items: laundryPackages
                        .map((p) => DropdownMenuItem<String>(
                              value: p.code,
                              child: Text('${p.name} - ${formatRupiah(p.pricePerKg)}/kg'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _packageCode = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Berat cucian (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scale_outlined),
                    ),
                    validator: (v) => validatePositiveNumber(v, 'Berat'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _calculate,
              icon: const Icon(Icons.receipt_long),
              label: const Text('Hitung Tagihan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Diskon 5% untuk total ≥ Rp 50.000 dan 10% untuk total > Rp 100.000.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (r != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.teal.shade700, Colors.teal.shade400]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _row('Paket', _resultLabel),
                    _row('Subtotal', formatRupiah(r.subtotal)),
                    _row('Diskon (${r.discountPercent}%)', '- ${formatRupiah(r.discount)}'),
                    const Divider(color: Colors.white54),
                    _row('Total bayar', formatRupiah(r.total), bold: true),
                    const SizedBox(height: 4),
                    Text('Dihitung dengan: ${_useOop ? 'OOP' : 'Prosedural'}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            HistorySection(kind: 'laundry', version: _historyVersion),
          ],
        ),
      ),
    );
  }
}
