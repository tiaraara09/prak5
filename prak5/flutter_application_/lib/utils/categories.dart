import 'package:flutter/material.dart';

const List<String> expenseCategories = ['Makanan', 'Transportasi', 'Hiburan', 'Transfer', 'Lainnya'];
const List<String> incomeCategories = ['Gaji', 'Bonus', 'Lainnya'];

IconData categoryIcon(String category) {
  switch (category) {
    case 'Makanan':
      return Icons.fastfood;
    case 'Transportasi':
      return Icons.directions_car;
    case 'Hiburan':
      return Icons.movie;
    case 'Transfer':
      return Icons.swap_horiz;
    case 'Gaji':
      return Icons.attach_money;
    case 'Bonus':
      return Icons.card_giftcard;
    default:
      return Icons.category;
  }
}

Color categoryColor(String category) {
  switch (category) {
    case 'Makanan':
      return Colors.redAccent;
    case 'Transportasi':
      return Colors.blueAccent;
    case 'Hiburan':
      return Colors.purple;
    case 'Transfer':
      return Colors.indigo;
    case 'Gaji':
      return Colors.green;
    case 'Bonus':
      return Colors.teal;
    default:
      return Colors.blueGrey;
  }
}
