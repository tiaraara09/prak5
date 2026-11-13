import 'dart:math';

/// Demo Dart Dasar & OOP (Praktikum 1). Setiap fungsi menjalankan kode yang sama
/// dengan modul, tetapi hasil `print` dikumpulkan ke daftar baris agar bisa
/// ditampilkan di layar. Baris berawalan "> " adalah kode, sisanya adalah output.

List<String> demoList() {
  final out = <String>[];
  void run(String code, Object? result) {
    out.add('> $code');
    out.add('  $result');
  }

  final fruits = <String>['Apel', 'Alpukat', 'Nanas', 'Mangga', 'Pisang'];
  run('print(fruits)', fruits);
  fruits.add('Jeruk');
  run("fruits.add('Jeruk')", fruits);
  fruits.remove('Alpukat');
  run("fruits.remove('Alpukat')", fruits);
  fruits[0] = 'Semangka';
  run("fruits[0] = 'Semangka'", fruits);
  fruits.sort();
  run('fruits.sort()', fruits);
  fruits.shuffle(Random(7));
  run('fruits.shuffle()', fruits);
  run('fruits.length', fruits.length);
  run('fruits.first', fruits.first);
  run('fruits.last', fruits.last);
  run("fruits.contains('Mangga')", fruits.contains('Mangga'));
  run("fruits.indexOf('Pisang')", fruits.indexOf('Pisang'));
  run('fruits.isEmpty', fruits.isEmpty);
  run('fruits.isNotEmpty', fruits.isNotEmpty);

  out.add('> for (var fruit in fruits) print(fruit)');
  for (final fruit in fruits) {
    out.add('  $fruit');
  }
  out.add('> for (var i = 0; i < fruits.length; i++) print(fruits[i])');
  for (var i = 0; i < fruits.length; i++) {
    out.add('  [$i] ${fruits[i]}');
  }
  return out;
}

List<String> demoSet() {
  final out = <String>[];
  void run(String code, Object? result) {
    out.add('> $code');
    out.add('  $result');
  }

  final animals = <String>{'Kucing', 'Anjing', 'Kelinci', 'Burung'};
  run('print(animals)', animals);
  animals.add('Ikan');
  run("animals.add('Ikan')", animals);
  run("animals.add('Kucing')  // duplikat ditolak", animals.add('Kucing'));
  animals.remove('Kelinci');
  run("animals.remove('Kelinci')", animals);
  run('animals.length', animals.length);
  run("animals.contains('Anjing')", animals.contains('Anjing'));
  run('animals.isEmpty', animals.isEmpty);
  run('animals.isNotEmpty', animals.isNotEmpty);
  out.add('> for (var animal in animals) print(animal)');
  for (final a in animals) {
    out.add('  $a');
  }
  out.add('> animals.elementAt(i)  // Set tidak punya index []');
  for (var i = 0; i < animals.length; i++) {
    out.add('  $i -> ${animals.elementAt(i)}');
  }
  return out;
}

List<String> demoMap() {
  final out = <String>[];
  void run(String code, Object? result) {
    out.add('> $code');
    out.add('  $result');
  }

  final prices = <String, String>{
    'Laptop': '10.000.000',
    'Mouse': '200.000',
    'Keyboard': '500.000',
    'Monitor': '2.000.000',
  };
  run('print(productPrices)', prices);
  prices['Printer'] = '1.500.000';
  run("productPrices['Printer'] = '1.500.000'", prices);
  prices.remove('Mouse');
  run("productPrices.remove('Mouse')", prices);
  prices['Laptop'] = '9.500.000';
  run("productPrices['Laptop'] = '9.500.000'", prices);
  run('productPrices.length', prices.length);
  run("productPrices.containsKey('Keyboard')", prices.containsKey('Keyboard'));
  run("productPrices.containsValue('2.000.000')", prices.containsValue('2.000.000'));
  run('productPrices.keys', prices.keys);
  run('productPrices.values', prices.values);
  out.add('> productPrices.forEach((key, value) => print("\$key: \$value"))');
  prices.forEach((key, value) => out.add('  $key: $value'));
  return out;
}

// --------------------------------------------------------------- OOP
class Car {
  String color = '';
  String brand = '';
  int year = 0;

  String drive() => 'The $color $brand is driving.';
  String honk() => 'The $color $brand is honking.';
}

// Pewarisan (inheritance)
class Animal {
  String eat() => 'The animal is eating.';
}

class Dog extends Animal {
  String bark() => 'The dog is barking.';
}

class Cat extends Animal {
  String meow() => 'The cat is meowing.';
}

List<String> demoOop() {
  final car1 = Car()
    ..color = 'Red'
    ..brand = 'Toyota'
    ..year = 2020;
  final cat1 = Cat();
  final dog1 = Dog();
  return [
    '> var car1 = Car();  // membuat object',
    "  color = 'Red', brand = 'Toyota', year = 2020",
    '> car1.drive()',
    '  ${car1.drive()}',
    '> car1.honk()',
    '  ${car1.honk()}',
    "> print('Car 1: \${car1.color}, \${car1.brand}, \${car1.year}')",
    '  Car 1: ${car1.color}, ${car1.brand}, ${car1.year}',
    '> class Cat extends Animal  // pewarisan',
    '> cat1.eat()  // method milik Animal',
    '  ${cat1.eat()}',
    '> cat1.meow()',
    '  ${cat1.meow()}',
    '> class Dog extends Animal',
    '> dog1.eat()',
    '  ${dog1.eat()}',
    '> dog1.bark()',
    '  ${dog1.bark()}',
  ];
}
