import '../utils/format.dart';

class TransactionModel {
  final int? id;
  final int userId;
  final String title;
  final int amount;
  final String category;

  /// 'income' (pemasukan) atau 'expense' (pengeluaran)
  final String type;
  final DateTime date;

  const TransactionModel({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });

  bool get isIncome => type == 'income';

  factory TransactionModel.fromMap(Map<String, Object?> m) => TransactionModel(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        title: m['title'] as String,
        amount: (m['amount'] as num).toInt(),
        category: m['category'] as String,
        type: m['type'] as String,
        date: DateTime.parse(m['date'] as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'amount': amount,
        'category': category,
        'type': type,
        'date': toDbDate(date),
      };
}
