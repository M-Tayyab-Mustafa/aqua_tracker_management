// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Sale {
  final int date;
  final int bottles;
  final double amount;
  Sale({
    required this.date,
    required this.bottles,
    required this.amount,
  });

  Sale copyWith({
    int? date,
    int? bottles,
    double? amount,
  }) {
    return Sale(
      date: date ?? this.date,
      bottles: bottles ?? this.bottles,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date,
      'bottles': bottles,
      'amount': amount,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      date: map['date'] as int,
      bottles: map['bottles'] as int,
      amount: double.parse(map['amount'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory Sale.fromJson(String source) => Sale.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Sale(date: $date, bottles: $bottles, amount: $amount)';

  @override
  bool operator ==(covariant Sale other) {
    if (identical(this, other)) return true;

    return other.date == date && other.bottles == bottles && other.amount == amount;
  }

  @override
  int get hashCode => date.hashCode ^ bottles.hashCode ^ amount.hashCode;
}
