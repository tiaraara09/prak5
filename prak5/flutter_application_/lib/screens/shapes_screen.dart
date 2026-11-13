import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../logic/shapes.dart';
import '../services/auth_service.dart';
import '../utils/format.dart';
import '../utils/validators.dart';
import '../widgets/history_section.dart';

class ShapesScreen extends StatefulWidget {
  const ShapesScreen({super.key});

  @override
  State<ShapesScreen> createState() => _ShapesScreenState();
}

class _ShapesScreenState extends State<ShapesScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller disimpan per bangun supaya tidak di-dispose saat field masih tampil.
  final Map<String, List<TextEditingController>> _controllerCache = {};

  bool _useOop = true;
  String _jenis = 'Luas';
  late Bangun _bangun;
  String? _resultText;
  int _historyVersion = 0;

  List<Bangun> get _options => daftarBangun.where((b) => b.jenis == _jenis).toList();

  List<TextEditingController> get _controllers => _controllerCache.putIfAbsent(
        _bangun.nama,
        () => List.generate(_bangun.sisi.length, (_) => TextEditingController()),
      );

  @override
  void initState() {
    super.initState();
    _bangun = _options.first;
  }

  @override
  void dispose() {
    for (final list in _controllerCache.values) {
      for (final c in list) {
        c.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;
    final values = _controllers.map((c) => parseAngka(c.text)!).toList();
    final value = _useOop
        ? _bangun.hitung(values)
        : hitungProsedural(_bangun.nama, values);

    final text =
        '${_bangun.jenis} ${_bangun.nama} = ${formatAngka(value, maxDecimals: 2)} ${_bangun.satuan}';
    setState(() => _resultText = text);

    final inputs = [
      for (var i = 0; i < values.length; i++) '${_bangun.sisi[i]} ${formatAngka(values[i])}'
    ].join(', ');
    await DbHelper.instance.insertHistory(
      AuthService.instance.currentUser!.id!,
      'bangun',
      '$text  ($inputs)',
    );
    if (mounted) setState(() => _historyVersion++);
  }

  @override
  Widget build(BuildContext context) {
    final options = _options;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bangun Datar & Ruang'),
        backgroundColor: Colors.deepOrange,
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
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(value: 'Luas', label: Text('Bangun Datar (Luas)')),
                ButtonSegment<String>(value: 'Volume', label: Text('Bangun Ruang (Volume)')),
              ],
              selected: {_jenis},
              onSelectionChanged: (s) {
                setState(() {
                  _jenis = s.first;
                  _bangun = _options.first;
                  _resultText = null;
                });
              },
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    key: ValueKey(_jenis),
                    value: _bangun.nama,
                    decoration: const InputDecoration(
                      labelText: 'Pilih bangun',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: options
                        .map((b) => DropdownMenuItem<String>(value: b.nama, child: Text(b.nama)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _bangun = options.firstWhere((b) => b.nama == v);
                        _resultText = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < _bangun.sisi.length; i++) ...[
                    TextFormField(
                      key: ValueKey('${_bangun.nama}-$i'),
                      controller: _controllers[i],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: _bangun.sisi[i],
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.straighten),
                      ),
                      validator: (v) => validatePositiveNumber(v, _bangun.sisi[i]),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: Text('Hitung ${_bangun.jenis}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            if (_resultText != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.deepOrange.shade700, Colors.deepOrange.shade400]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(_resultText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Dihitung dengan: ${_useOop ? 'OOP' : 'Prosedural'}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            HistorySection(kind: 'bangun', version: _historyVersion),
          ],
        ),
      ),
    );
  }
}
