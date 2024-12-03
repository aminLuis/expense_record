class Expense {
  final DateTime date;
  final String description;
  final double amount;
  final String category;

  Expense({
    required this.date,
    required this.description,
    required this.amount,
    required this.category
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'description': description,
    'amount': amount,
    'category': category
  };

static Expense fromJson(Map<String, dynamic> json) {
  return Expense(
    date: DateTime.parse(json['date']),
    description: json['description'],
    amount: json['amount'],
    category: json['category']
  );
}

 @override
  String toString() =>
      'Expense(date: $date, description: $description, amount: $amount, category: $category)';

}