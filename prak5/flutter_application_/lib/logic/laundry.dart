/// Mini Laundry (Latihan Praktikum 1 - Kelas B), dua pendekatan:
///  1) PROSEDURAL : kumpulan fungsi biasa
///  2) OOP        : kelas paket (pewarisan) + kelas pesanan
///
/// Aturan: Cuci+Setrika 6.000/kg, Cuci 4.000/kg, Setrika 3.000/kg.
/// Total >= 50.000 diskon 5%; total > 100.000 diskon 10%.

class LaundryResult {
  final int subtotal;
  final int discountPercent;
  final int discount;
  final int total;
  const LaundryResult({
    required this.subtotal,
    required this.discountPercent,
    required this.discount,
    required this.total,
  });
}

// ====================================================== 1) PROSEDURAL
int hargaPerKgProsedural(String kode) {
  switch (kode) {
    case 'cuci_setrika':
      return 6000;
    case 'cuci':
      return 4000;
    case 'setrika':
      return 3000;
    default:
      throw ArgumentError('Paket tidak dikenal: $kode');
  }
}

int persenDiskonProsedural(int subtotal) {
  if (subtotal > 100000) return 10;
  if (subtotal >= 50000) return 5;
  return 0;
}

LaundryResult hitungLaundryProsedural(String kode, double kg) {
  final subtotal = (hargaPerKgProsedural(kode) * kg).round();
  final persen = persenDiskonProsedural(subtotal);
  final diskon = (subtotal * persen / 100).round();
  return LaundryResult(
    subtotal: subtotal,
    discountPercent: persen,
    discount: diskon,
    total: subtotal - diskon,
  );
}

// ============================================================= 2) OOP
abstract class LaundryPackage {
  const LaundryPackage();
  String get code;
  String get name;
  int get pricePerKg;
}

class WashIronPackage extends LaundryPackage {
  const WashIronPackage();
  @override
  String get code => 'cuci_setrika';
  @override
  String get name => 'Cuci & Setrika';
  @override
  int get pricePerKg => 6000;
}

class WashPackage extends LaundryPackage {
  const WashPackage();
  @override
  String get code => 'cuci';
  @override
  String get name => 'Cuci';
  @override
  int get pricePerKg => 4000;
}

class IronPackage extends LaundryPackage {
  const IronPackage();
  @override
  String get code => 'setrika';
  @override
  String get name => 'Setrika';
  @override
  int get pricePerKg => 3000;
}

const List<LaundryPackage> laundryPackages = [
  WashIronPackage(),
  WashPackage(),
  IronPackage(),
];

class LaundryOrder {
  final LaundryPackage package;
  final double weightKg;
  const LaundryOrder(this.package, this.weightKg);

  int get subtotal => (package.pricePerKg * weightKg).round();

  int get discountPercent {
    if (subtotal > 100000) return 10;
    if (subtotal >= 50000) return 5;
    return 0;
  }

  int get discount => (subtotal * discountPercent / 100).round();
  int get total => subtotal - discount;

  LaundryResult toResult() => LaundryResult(
        subtotal: subtotal,
        discountPercent: discountPercent,
        discount: discount,
        total: total,
      );
}
