import 'dart:math' as math;

/// Luas Bangun Datar & Volume Bangun Ruang (Latihan Praktikum 1 - Kelas A),
/// dengan dua pendekatan: PROSEDURAL (fungsi) dan OOP (kelas + pewarisan).

// ====================================================== 1) PROSEDURAL
double luasPersegi(double sisi) => sisi * sisi;
double luasPersegiPanjang(double p, double l) => p * l;
double luasSegitiga(double alas, double tinggi) => 0.5 * alas * tinggi;
double luasLingkaran(double r) => math.pi * r * r;

double volumeKubus(double sisi) => sisi * sisi * sisi;
double volumeBalok(double p, double l, double t) => p * l * t;
double volumeTabung(double r, double t) => math.pi * r * r * t;
double volumeBola(double r) => 4 / 3 * math.pi * r * r * r;

double hitungProsedural(String nama, List<double> v) {
  switch (nama) {
    case 'Persegi':
      return luasPersegi(v[0]);
    case 'Persegi Panjang':
      return luasPersegiPanjang(v[0], v[1]);
    case 'Segitiga':
      return luasSegitiga(v[0], v[1]);
    case 'Lingkaran':
      return luasLingkaran(v[0]);
    case 'Kubus':
      return volumeKubus(v[0]);
    case 'Balok':
      return volumeBalok(v[0], v[1], v[2]);
    case 'Tabung':
      return volumeTabung(v[0], v[1]);
    case 'Bola':
      return volumeBola(v[0]);
    default:
      throw ArgumentError('Bangun tidak dikenal: $nama');
  }
}

// ============================================================= 2) OOP
abstract class Bangun {
  const Bangun();
  String get nama;

  /// 'Luas' (bangun datar) atau 'Volume' (bangun ruang)
  String get jenis;

  /// Label input yang dibutuhkan, urut sesuai [hitung].
  List<String> get sisi;
  double hitung(List<double> v);

  String get satuan => jenis == 'Luas' ? 'satuan²' : 'satuan³';
}

abstract class BangunDatar extends Bangun {
  const BangunDatar();
  @override
  String get jenis => 'Luas';
}

abstract class BangunRuang extends Bangun {
  const BangunRuang();
  @override
  String get jenis => 'Volume';
}

class Persegi extends BangunDatar {
  const Persegi();
  @override
  String get nama => 'Persegi';
  @override
  List<String> get sisi => ['Sisi'];
  @override
  double hitung(List<double> v) => v[0] * v[0];
}

class PersegiPanjang extends BangunDatar {
  const PersegiPanjang();
  @override
  String get nama => 'Persegi Panjang';
  @override
  List<String> get sisi => ['Panjang', 'Lebar'];
  @override
  double hitung(List<double> v) => v[0] * v[1];
}

class Segitiga extends BangunDatar {
  const Segitiga();
  @override
  String get nama => 'Segitiga';
  @override
  List<String> get sisi => ['Alas', 'Tinggi'];
  @override
  double hitung(List<double> v) => 0.5 * v[0] * v[1];
}

class Lingkaran extends BangunDatar {
  const Lingkaran();
  @override
  String get nama => 'Lingkaran';
  @override
  List<String> get sisi => ['Jari-jari'];
  @override
  double hitung(List<double> v) => math.pi * v[0] * v[0];
}

class Kubus extends BangunRuang {
  const Kubus();
  @override
  String get nama => 'Kubus';
  @override
  List<String> get sisi => ['Sisi'];
  @override
  double hitung(List<double> v) => v[0] * v[0] * v[0];
}

class Balok extends BangunRuang {
  const Balok();
  @override
  String get nama => 'Balok';
  @override
  List<String> get sisi => ['Panjang', 'Lebar', 'Tinggi'];
  @override
  double hitung(List<double> v) => v[0] * v[1] * v[2];
}

class Tabung extends BangunRuang {
  const Tabung();
  @override
  String get nama => 'Tabung';
  @override
  List<String> get sisi => ['Jari-jari', 'Tinggi'];
  @override
  double hitung(List<double> v) => math.pi * v[0] * v[0] * v[1];
}

class Bola extends BangunRuang {
  const Bola();
  @override
  String get nama => 'Bola';
  @override
  List<String> get sisi => ['Jari-jari'];
  @override
  double hitung(List<double> v) => 4 / 3 * math.pi * v[0] * v[0] * v[0];
}

const List<Bangun> daftarBangun = [
  Persegi(),
  PersegiPanjang(),
  Segitiga(),
  Lingkaran(),
  Kubus(),
  Balok(),
  Tabung(),
  Bola(),
];
