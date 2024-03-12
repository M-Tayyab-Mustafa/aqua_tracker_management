import 'dart:convert';

import 'package:flutter/foundation.dart';

class MonthReport {
  num totalBottles;
  Map<String, Details> details;

  MonthReport({
    required this.totalBottles,
    required this.details,
  });

  MonthReport copyWith({
    num? totalBottles,
    Map<String, Details>? details,
  }) {
    return MonthReport(
      totalBottles: totalBottles ?? this.totalBottles,
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'total_bottles': totalBottles,
      'details': details.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory MonthReport.fromMap(Map<String, dynamic> map) {
    return MonthReport(
      totalBottles: map['total_bottles'],
      details: Map<String, Details>.from((map['details'] as Map).map((key, value) => MapEntry(key, Details.fromMap(value)))),
    );
  }

  String toJson() => json.encode(toMap());

  factory MonthReport.fromJson(String source) => MonthReport.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'MonthReport(total_bottles: $totalBottles, details: $details)';

  @override
  bool operator ==(covariant MonthReport other) {
    if (identical(this, other)) return true;

    return other.totalBottles == totalBottles && mapEquals(other.details, details);
  }

  @override
  int get hashCode => totalBottles.hashCode ^ details.hashCode;
}

class YearlyReport {
  int date;
  String payment;
  int paymentStatus;
  MonthReport monthReport;

  YearlyReport({
    required this.date,
    required this.payment,
    required this.paymentStatus,
    required this.monthReport,
  });

  YearlyReport copyWith({
    int? date,
    String? payment,
    int? paymentStatus,
    MonthReport? monthReport,
  }) {
    return YearlyReport(
      date: date ?? this.date,
      payment: payment ?? this.payment,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      monthReport: monthReport ?? this.monthReport,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date,
      'payment': payment,
      'payment_status': paymentStatus,
      'details': monthReport.details.map((key, value) => MapEntry(key, value.toMap())),
      'total_bottles': monthReport.totalBottles,
    };
  }

  factory YearlyReport.fromMap(Map<String, dynamic> map) {
    return YearlyReport(
      date: map['date'],
      payment: map['payment'] as String,
      paymentStatus: map['payment_status'],
      monthReport: MonthReport.fromMap(map),
    );
  }

  String toJson() => json.encode(toMap());

  factory YearlyReport.fromJson(String source) => YearlyReport.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Payment(date: $date, payment: $payment, paymentStatus: $paymentStatus, monthReport: $monthReport)';
  }

  @override
  bool operator ==(covariant YearlyReport other) {
    if (identical(this, other)) return true;

    return other.date == date && other.payment == payment && other.paymentStatus == paymentStatus && other.monthReport == monthReport;
  }

  @override
  int get hashCode {
    return date.hashCode ^ payment.hashCode ^ paymentStatus.hashCode ^ monthReport.hashCode;
  }
}

class Details {
  int bottles;
  bool approved;

  Details({
    required this.bottles,
    required this.approved,
  });

  Details copyWith({
    int? bottles,
    bool? approved,
  }) {
    return Details(
      bottles: bottles ?? this.bottles,
      approved: approved ?? this.approved,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bottles': bottles,
      'approved': approved,
    };
  }

  factory Details.fromMap(Map<String, dynamic> map) {
    return Details(
      bottles: map['bottles'] as int,
      approved: map['approved'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Details.fromJson(String source) => Details.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'MoreDetail(bottles: $bottles, approved: $approved)';

  @override
  bool operator ==(covariant Details other) {
    if (identical(this, other)) return true;

    return other.bottles == bottles && other.approved == approved;
  }

  @override
  int get hashCode => bottles.hashCode ^ approved.hashCode;
}

class PaymentMethod {
  final String accountNo;
  final String title;
  final String ownerName;

  PaymentMethod({
    required this.accountNo,
    required this.title,
    required this.ownerName,
  });

  PaymentMethod copyWith({
    String? accountNo,
    String? title,
    String? ownerName,
  }) {
    return PaymentMethod(
      accountNo: accountNo ?? this.accountNo,
      title: title ?? this.title,
      ownerName: ownerName ?? this.ownerName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'account_no': accountNo,
      'title': title,
      'owner_name': ownerName,
    };
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      accountNo: map['account_no'] as String,
      title: map['title'] as String,
      ownerName: map['owner_name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymentMethod.fromJson(String source) => PaymentMethod.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'PaymentMethod(account_no: $accountNo, title: $title, owner_name: $ownerName)';

  @override
  bool operator ==(covariant PaymentMethod other) {
    if (identical(this, other)) return true;

    return other.accountNo == accountNo && other.title == title && other.ownerName == ownerName;
  }

  @override
  int get hashCode => accountNo.hashCode ^ title.hashCode ^ ownerName.hashCode;
}
