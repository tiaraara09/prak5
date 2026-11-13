import 'package:flutter/material.dart';

import '../logic/dart_basics.dart';

/// Menampilkan hasil kode Praktikum 1 (List, Set, Map, perulangan, OOP & pewarisan).
class DartBasicsScreen extends StatelessWidget {
  const DartBasicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = <String, ({String desc, List<String> lines})>{
      'List': (
        desc: 'Kumpulan data berurutan dengan index (seperti array).',
        lines: demoList(),
      ),
      'Set': (
        desc: 'Kumpulan data tanpa index dan tanpa duplikasi.',
        lines: demoSet(),
      ),
      'Map': (
        desc: 'Pasangan key-value. Key yang sama akan ditimpa nilai terakhir.',
        lines: demoMap(),
      ),
      'OOP': (
        desc: 'Class, object, property, method, dan pewarisan (extends).',
        lines: demoOop(),
      ),
    };

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dart Dasar & OOP'),
          backgroundColor: Colors.blueGrey.shade800,
          foregroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [for (final t in tabs.keys) Tab(text: t)],
          ),
        ),
        body: TabBarView(
          children: [
            for (final entry in tabs.entries)
              _DemoPage(description: entry.value.desc, lines: entry.value.lines),
          ],
        ),
      ),
    );
  }
}

class _DemoPage extends StatelessWidget {
  final String description;
  final List<String> lines;
  const _DemoPage({required this.description, required this.lines});

  @override
  Widget build(BuildContext context) {
    const mono = TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText.rich(
              TextSpan(
                children: [
                  for (final line in lines)
                    TextSpan(
                      text: '$line\n',
                      style: mono.copyWith(
                        color: line.startsWith('> ')
                            ? const Color(0xFF7EE787)
                            : const Color(0xFFD4D4D4),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
