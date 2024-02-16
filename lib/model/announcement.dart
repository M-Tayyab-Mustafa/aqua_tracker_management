// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Announcement {
  final int date;
  final String title;
  final String detail;

  Announcement({
    required this.date,
    required this.title,
    required this.detail,
  });

  Announcement copyWith({
    int? date,
    String? title,
    String? detail,
  }) {
    return Announcement(
      date: date ?? this.date,
      title: title ?? this.title,
      detail: detail ?? this.detail,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date,
      'title': title,
      'detail': detail,
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      date: map['date'] as int,
      title: map['title'] as String,
      detail: map['detail'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Announcement.fromJson(String source) => Announcement.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Announcement(date: $date, title: $title, detail: $detail)';

  @override
  bool operator ==(covariant Announcement other) {
    if (identical(this, other)) return true;

    return other.date == date && other.title == title && other.detail == detail;
  }

  @override
  int get hashCode => date.hashCode ^ title.hashCode ^ detail.hashCode;
}
