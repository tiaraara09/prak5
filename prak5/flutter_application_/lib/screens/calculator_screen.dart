import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/db_helper.dart';
import '../services/auth_service.dart';
import '../utils/format.dart';
import '../utils/validators.dart';
import '../widgets/history_section.dart';

/// Kalkulator (Latihan Praktikum 3 - Kelas A): 2 TextFormField, 4 operasi (kabataku),
/// ElevatedButton untuk mengeksekusi, Text untuk hasil. Hasil disimpan ke SQLite.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aController = TextEditingController();
  final _bController = TextEditingController();

  String _result = '0';
  String _expression = 'Hasil perhitungan akan tampil di sini';
  bool _isError = false;
  int _historyVersion = 0;

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    super.dispose();
  }

  Future<void> _calculate(String op) async {
    if (!_formKey.currentState!.validate()) return;
    final a = parseAngka(_aController.text)!;
    final b = parseAngka(_bController.text)!;

    if (op == '÷' && b == 0) {
      setState(() {
        _isError = true;
        _result = 'Error';
        _expression = 'Tidak bisa membagi dengan nol';
      });
      return;
    }

    final double value = switch (op) {
      '+' => a + b,
      '-' => a - b,
      '×' => a * b,
      _ => a / b,
    };
    final expr = '${formatAngka(a)} $op ${formatAngka(b)}';
    setState(() {
      _isError = false;
      _result = formatAngka(value);
      _expression = expr;
    });
    await DbHelper.instance.insertHistory(
      AuthService.instance.currentUser!.id!,
      'kalkulator',
      '$expr = ${formatAngka(value)}',
    );
    if (mounted) setState(() => _historyVersion++);
  }

  Widget _opButton(String op, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _calculate(op),
          child: Text(op, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const numberType = TextInputType.numberWithOptions(decimal: true, signed: true);
    final numberFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isError
                      ? [Colors.red.shade700, Colors.red.shade400]
                      : [Colors.indigo.shade700, Colors.indigo.shade400],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_expression,
                      style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(_result,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _aController,
                    keyboardType: numberType,
                    inputFormatters: [numberFormatter],
                    decoration: const InputDecoration(
                      labelText: 'Angka pertama',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.looks_one_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Angka pertama wajib diisi';
                      if (parseAngka(v) == null) return 'Harus berupa angka';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bController,
                    keyboardType: numberType,
                    inputFormatters: [numberFormatter],
                    decoration: const InputDecoration(
                      labelText: 'Angka kedua',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.looks_two_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Angka kedua wajib diisi';
                      if (parseAngka(v) == null) return 'Harus berupa angka';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _opButton('+', Colors.green),
                _opButton('-', Colors.red),
                _opButton('×', Colors.orange),
                _opButton('÷', Colors.blue),
              ],
            ),
            const SizedBox(height: 20),
            HistorySection(kind: 'kalkulator', version: _historyVersion),
          ],
        ),
      ),
    );
  }
}
