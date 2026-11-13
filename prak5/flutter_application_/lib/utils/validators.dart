String? validateRequired(String? v, String label) {
  if (v == null || v.trim().isEmpty) return '$label tidak boleh kosong';
  return null;
}

String? validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
    return 'Format email tidak valid (contoh: nama@email.com)';
  }
  return null;
}

String? validatePositiveNumber(String? v, String label) {
  if (v == null || v.trim().isEmpty) return '$label wajib diisi';
  final n = double.tryParse(v.trim().replaceAll(',', '.'));
  if (n == null) return '$label harus berupa angka';
  if (n <= 0) return '$label harus lebih dari 0';
  return null;
}
