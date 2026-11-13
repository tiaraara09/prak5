import 'package:flutter/services.dart';

/// Memformat angka dengan pemisah ribuan titik saat diketik:
/// 20000 -> 20.000, 1500000 -> 1.500.000. Karakter non-angka otomatis dibuang.
class ThousandsSeparatorFormatter extends TextInputFormatter {
  const ThousandsSeparatorFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text;
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }
    digits = digits.replaceFirst(RegExp(r'^0+(?=\d)'), ''); // "007" -> "7"
    final formatted =
        digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

    // Pertahankan posisi kursor: hitung jumlah digit di kiri kursor lalu cari posisinya di teks baru.
    final cursor = newValue.selection.baseOffset.clamp(0, raw.length);
    final digitsBeforeCursor =
        raw.substring(0, cursor).replaceAll(RegExp(r'[^0-9]'), '').length;
    var offset = 0;
    var seen = 0;
    while (offset < formatted.length && seen < digitsBeforeCursor) {
      if (formatted[offset] != '.') seen++;
      offset++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
