const List<String> _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
];

String _two(int n) => n.toString().padLeft(2, '0');

/// 5000000 -> "Rp 5.000.000"
String formatRupiah(num value, {bool prefix = true}) {
  final negative = value < 0;
  final digits = value.abs().round().toString();
  final grouped =
      digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  return '${negative ? '-' : ''}${prefix ? 'Rp ' : ''}$grouped';
}

/// "13 Sep 2026"
String formatTanggal(DateTime d) => '${_two(d.day)} ${_bulan[d.month - 1]} ${d.year}';

/// "13 Sep 2026 14:05"
String formatWaktu(DateTime d) => '${formatTanggal(d)} ${_two(d.hour)}:${_two(d.minute)}';

/// "13/09/2026" (format input DD/MM/YYYY)
String formatTanggalInput(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

/// "2026-09-13" (format penyimpanan di SQLite, urut alfabet = urut tanggal)
String toDbDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

/// Mengubah "DD/MM/YYYY" menjadi DateTime; null bila format/tanggal tidak valid (mis. 31/02/2026).
DateTime? parseTanggalInput(String text) {
  final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(text.trim());
  if (m == null) return null;
  final d = int.parse(m.group(1)!);
  final mo = int.parse(m.group(2)!);
  final y = int.parse(m.group(3)!);
  final dt = DateTime(y, mo, d);
  if (dt.year != y || dt.month != mo || dt.day != d) return null;
  return dt;
}

/// 12.5 -> "12.5", 12.0 -> "12", 3.14159265 -> "3.1416"
String formatAngka(double v, {int maxDecimals = 4}) {
  if (v.isNaN || v.isInfinite) return v.toString();
  var s = v.toStringAsFixed(maxDecimals);
  if (s.contains('.')) {
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
  }
  return s;
}

/// Menerima "12,5" maupun "12.5".
double? parseAngka(String text) => double.tryParse(text.trim().replaceAll(',', '.'));

/// "1.500.000" -> 1500000 (null bila bukan angka)
int? parseRupiah(String text) => int.tryParse(text.replaceAll('.', '').trim());
