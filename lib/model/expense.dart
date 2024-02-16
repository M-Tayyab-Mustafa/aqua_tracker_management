// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Expense {
  final int date;
  final String costName;
  final String details;
  final double amount;
  Expense({
    required this.date,
    required this.costName,
    required this.details,
    required this.amount,
  });

  Expense copyWith({
    int? date,
    String? costName,
    String? details,
    double? amount,
  }) {
    return Expense(
      date: date ?? this.date,
      costName: costName ?? this.costName,
      details: details ?? this.details,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date,
      'cost_name': costName,
      'details': details,
      'amount': amount,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      date: map['date'],
      costName: map['cost_name'] as String,
      details: map['details'] as String,
      amount: double.parse(map['amount'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory Expense.fromJson(String source) => Expense.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Expenses(date: $date, cost_name: $costName, details: $details, amount: $amount)';
  }

  @override
  bool operator ==(covariant Expense other) {
    if (identical(this, other)) return true;

    return other.date == date && other.costName == costName && other.details == details && other.amount == amount;
  }

  @override
  int get hashCode {
    return date.hashCode ^ costName.hashCode ^ details.hashCode ^ amount.hashCode;
  }
}
