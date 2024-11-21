class Expense {
  final DateTime date;
  final String description;
  final double amount;

  Expense({
    required this.date,
    required this.description,
    required this.amount
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'description': description,
    'amount': amount
  };

static Expense fromJson(Map<String, dynamic> json) {
  return Expense(
    date: DateTime.parse(json['date']),
    description: json['description'],
    amount: json['amount']
  );
}

}