class Expense {
  final int id; // unique id for every expense
  final String title; // what are we spending on
  final double amount; // how much are we spending
  final DateTime date; // when are we spending
  final String category; // which category on we spending

  // constructor
  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  // 'Expense' to 'Map'
  Map<String, dynamic> toMap() => {
        // id will generate automatically
        'title': title,
        'totalAmount': amount.toString()
      };

  // 'Map' to 'Expense'
  factory Expense.fromString(Map<String, dynamic> value) => Expense(
      id: value['id'],
      title: value['title'],
      amount: double.parse(value['amount']),
      date: DateTime.parse(value['date']),
      category: value['category']);
}
