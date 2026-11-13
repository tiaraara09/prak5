import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/app_user.dart';
import '../models/transaction_model.dart';

/// Pengelola database SQLite lokal (satu file: expense_tracker.db).
/// Tabel: users, transactions, histories.
class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._(); // singleton instance

  Database? _db; // instance database SQLite (null jika belum dibuka)

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'expense_tracker.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async { // buat tabel-tabel saat pertama kali database dibuat
        await db.execute(''' // 
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            salt TEXT NOT NULL,
            nim TEXT NOT NULL DEFAULT '',
            address TEXT NOT NULL DEFAULT '',
            phone TEXT NOT NULL DEFAULT '',
            major TEXT NOT NULL DEFAULT ''
          )''');
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            amount INTEGER NOT NULL,
            category TEXT NOT NULL,
            type TEXT NOT NULL,
            date TEXT NOT NULL,
            FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
          )''');
        await db.execute('''
          CREATE TABLE histories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            kind TEXT NOT NULL,
            detail TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
          )''');
      },
    );
  }

  // ---------------------------------------------------------------- USERS
  Future<int> insertUser(AppUser user) async {
    final db = await database;
    return db.insert('users', user.toMap()..remove('id'));
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final db = await database;
    final rows = await db.query('users', where: 'email = ?', whereArgs: [email], limit: 1);
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  Future<AppUser?> getUserById(int id) async {
    final db = await database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  Future<void> updateProfile(AppUser u) async {
    final db = await database;
    await db.update(
      'users',
      {'name': u.name, 'nim': u.nim, 'address': u.address, 'phone': u.phone, 'major': u.major},
      where: 'id = ?',
      whereArgs: [u.id],
    );
  }

  // --------------------------------------------------------- TRANSACTIONS
  Future<int> insertTransaction(TransactionModel t) async {
    final db = await database;
    return db.insert('transactions', t.toMap()..remove('id'));
  }

  Future<void> updateTransaction(TransactionModel t) async {
    final db = await database;
    await db.update(
      'transactions',
      t.toMap()..remove('id'),
      where: 'id = ? AND user_id = ?',
      whereArgs: [t.id, t.userId],
    );
  }

  Future<void> deleteTransaction(int id, int userId) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ? AND user_id = ?', whereArgs: [id, userId]);
  }

  Future<List<TransactionModel>> getTransactions(int userId) async {
    final db = await database;
    final rows = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(TransactionModel.fromMap).toList();
  }

  /// Total pemasukan & pengeluaran: {'income': ..., 'expense': ...}
  Future<Map<String, int>> getTotals(int userId) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT type, SUM(amount) AS total FROM transactions WHERE user_id = ? GROUP BY type',
      [userId],
    );
    var income = 0;
    var expense = 0;
    for (final r in rows) {
      final total = (r['total'] as num?)?.toInt() ?? 0;
      if (r['type'] == 'income') {
        income = total;
      } else {
        expense = total;
      }
    }
    return {'income': income, 'expense': expense};
  }

  // ------------------------------------------------------------ HISTORIES
  Future<void> insertHistory(int userId, String kind, String detail) async {
    final db = await database;
    await db.insert('histories', {
      'user_id': userId,
      'kind': kind,
      'detail': detail,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, Object?>>> getHistories(int userId, String kind, {int limit = 8}) async {
    final db = await database;
    return db.query(
      'histories',
      where: 'user_id = ? AND kind = ?',
      whereArgs: [userId, kind],
      orderBy: 'id DESC',
      limit: limit,
    );
  }

  Future<void> clearHistories(int userId, String kind) async {
    final db = await database;
    await db.delete('histories', where: 'user_id = ? AND kind = ?', whereArgs: [userId, kind]);
  }
}
