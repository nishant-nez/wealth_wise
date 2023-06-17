import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wealth_wise/models/users.dart';
import '../constants/icons.dart';
import './ex_category.dart';
import './expense.dart';

class DatabaseProvider with ChangeNotifier {
  String _searchText = '';
  String get searchText => _searchText;
  set searchText(String value) {
    _searchText = value;
    notifyListeners();
    // when the value of the search text changes it will notify the widgets.
  }

  // in-app memory for holding the Expense categories temporarily
  List<ExpenseCategory> _categories = [];
  List<ExpenseCategory> get categories => _categories;

  List<Expense> _expenses = [];
  // when the search text is empty, return whole list, else search for the value
  List<Expense> get expenses {
    return _searchText != '' ? _expenses.where((e) => e.title.toLowerCase().contains(_searchText.toLowerCase())).toList() : _expenses;
  }

  Database? _database;
  Future<Database> get database async {
    // database directory
    final dbDirectory = await getDatabasesPath();
    // database name
    const dbName = 'expense_tc.db';
    // full path
    final path = join(dbDirectory, dbName);

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb, // will create this separately
    );

    return _database!;
  }

  // _createDb function
  static const cTable = 'categoryTable';
  static const eTable = 'expenseTable';
  static const uTable = 'usersTable';
  Future<void> _createDb(Database db, int version) async {
    // this method runs only once. when the database is being created
    // so create the tables here and if you want to insert some initial values
    // insert it in this function.

    await db.transaction((txn) async {
      // category table
      await txn.execute('''CREATE TABLE $uTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        password TEXT
      )''');

      await txn.execute('''CREATE TABLE $cTable(
        title TEXT,
        entries INTEGER,
        totalAmount TEXT
      )''');
      // expense table
      await txn.execute('''CREATE TABLE $eTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount TEXT,
        date TEXT,
        category TEXT
      )''');

      // insert the initial categories.
      // this will add all the categories to category table and initialize the 'entries' with 0 and 'totalAmount' to 0.0
      // for (int i = 0; i < icons.length; i++) {
      //   await txn.insert(cTable, {
      //     'title': icons.keys.toList()[i],
      //     'entries': 0,
      //     'totalAmount': (0.0).toString(),
      //   });
      // }
    });
  }

  Future<bool> login(Users user) async {
    final db = await database;
    List<Map> result = await db.rawQuery('SELECT * FROM usersTable WHERE username = ? AND password = ?', [user.username, user.password]);

    if (result.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<void> register(Users user) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(uTable, {'username': user.username, 'password': user.password}).then((_) {});
    });
  }
  // method to fetch categories

  Future<List<ExpenseCategory>> fetchCategories() async {
    // get the database
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(cTable).then((data) {
        // 'data' is our fetched value
        // convert it from "Map<String, object>" to "Map<String, dynamic>"
        final converted = List<Map<String, dynamic>>.from(data);
        // create a 'ExpenseCategory'from every 'map' in this 'converted'
        List<ExpenseCategory> nList = List.generate(converted.length, (index) => ExpenseCategory.fromString(converted[index]));
        // set the value of 'categories' to 'nList'
        _categories = nList;
        // return the '_categories'
        return _categories;
      });
    });
  }

  Future<void> viewDatabaseContents() async {
    final db = await database;

    // Fetch and print data from the category table
    final categoryData = await db.query(cTable);
    print('Category Table:');
    categoryData.forEach((row) {
      print(row);
    });

    // Fetch and print data from the expense table
    final expenseData = await db.query(eTable);
    print('Expense Table:');
    expenseData.forEach((row) {
      print(row);
    });
  }

  Future<void> updateCategory(
    String category,
    int nEntries,
    double nTotalAmount,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .update(
        cTable, // category table
        {
          'entries': nEntries, // new value of 'entries'
          'totalAmount': nTotalAmount.toString(), // new value of 'totalAmount'
        },
        where: 'title == ?', // in table where the title ==
        whereArgs: [category], // this category.
      )
          .then((_) {
        // after updating in database. update it in our in-app memory too.
        var file = _categories.firstWhere((element) => element.title == category);
        file.entries = nEntries;
        file.totalAmount = nTotalAmount;
        notifyListeners();
      });
    });
  }
  // method to add an expense to database

  Future<void> addExpense(Expense exp) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .insert(
        cTable,
        {'title': exp.title, 'totalAmount': exp.amount, 'entries': 1},
        conflictAlgorithm: ConflictAlgorithm.replace,
      )
          .then((_) {
        _categories.add(ExpenseCategory(title: exp.title, entries: 1, totalAmount: exp.amount, icon: Icons.circle));
        notifyListeners();
      });
    });
  }

  Future<void> updateExpense(String currentTitle, String newTitle, double newAmount) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .update(
        cTable, // category table
        {
          'title': newTitle, // new value of 'title'
          'totalAmount': newAmount.toString(), // new value of 'totalAmount'
        },
        where: 'title == ?', // in table where the title ==
        whereArgs: [currentTitle], // current title of the expense
      )
          .then((_) {
        // Update the expense in in-app memory too
        final index = _categories.indexWhere((element) => element.title == currentTitle);
        if (index != -1) {
          final updatedCategory = ExpenseCategory(
            title: newTitle,
            entries: _categories[index].entries,
            totalAmount: newAmount,
            icon: _categories[index].icon,
          );
          _categories[index] = updatedCategory;
          notifyListeners();
        }
      });
    });
  }

  Future<void> deleteExpense(int expId, String category, double amount) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(eTable, where: 'id == ?', whereArgs: [expId]).then((_) {
        // remove from in-app memory too
        _expenses.removeWhere((element) => element.id == expId);
        notifyListeners();
        // we have to update the entries and totalamount too

        var ex = findCategory(category);
        updateCategory(category, ex.entries - 1, ex.totalAmount - amount);
      });
    });
  }

  Future<List<Expense>> fetchExpenses(String category) async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(eTable, where: 'category == ?', whereArgs: [category]).then((data) {
        final converted = List<Map<String, dynamic>>.from(data);
        //
        List<Expense> nList = List.generate(converted.length, (index) => Expense.fromString(converted[index]));
        _expenses = nList;
        return _expenses;
      });
    });
  }

  Future<List<Expense>> fetchAllExpenses() async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(eTable).then((data) {
        final converted = List<Map<String, dynamic>>.from(data);
        List<Expense> nList = List.generate(converted.length, (index) => Expense.fromString(converted[index]));
        _expenses = nList;
        return _expenses;
      });
    });
  }

  Future<void> deleteCategory(String name) async {
    final db = await database;

    return await db.transaction((txn) async {
      return await txn.delete(cTable, where: 'title == ?', whereArgs: [name]).then((data) {
        _categories = _categories.where((element) => element.title != name).toList();
        notifyListeners();
      });
    });
  }

  ExpenseCategory findCategory(String title) {
    return _categories.firstWhere((element) => element.title == title);
  }

  Map<String, dynamic> calculateEntriesAndAmount(String category) {
    double total = 0.0;
    var list = _expenses.where((element) => element.category == category);
    for (final i in list) {
      total += i.amount;
    }
    return {'entries': list.length, 'totalAmount': total};
  }

  double calculateTotalExpenses() {
    return _categories.fold(0.0, (previousValue, element) => previousValue + element.totalAmount);
  }

  List<Map<String, dynamic>> calculateWeekExpenses() {
    List<Map<String, dynamic>> data = [];

    // we know that we need 7 entries
    for (int i = 0; i < 7; i++) {
      // 1 total for each entry
      double total = 0.0;
      // subtract i from today to get previous dates.
      final weekDay = DateTime.now().subtract(Duration(days: i));

      // check how many transacitons happened that day
      for (int j = 0; j < _expenses.length; j++) {
        if (_expenses[j].date.year == weekDay.year && _expenses[j].date.month == weekDay.month && _expenses[j].date.day == weekDay.day) {
          // if found then add the amount to total
          total += _expenses[j].amount;
        }
      }

      // add to a list
      data.add({'day': weekDay, 'amount': total});
    }
    // return the list
    return data;
  }
}
