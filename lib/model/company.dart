// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Company {
  String name;
  String logo;
  double bottlePrice;

  Company({
    required this.name,
    required this.logo,
    required this.bottlePrice,
  });

  Company copyWith({
    String? name,
    String? logo,
    double? bottlePrice,
  }) {
    return Company(
      name: name ?? this.name,
      logo: logo ?? this.logo,
      bottlePrice: bottlePrice ?? this.bottlePrice,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'logo': logo,
      'bottle_price': bottlePrice,
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      name: map['name'],
      logo: map['logo'],
      bottlePrice: double.parse(map['bottle_price'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory Company.fromJson(String source) =>
      Company.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Company(name: $name, logo: $logo, bottle_price: $bottlePrice)';

  @override
  bool operator ==(covariant Company other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.logo == logo &&
        other.bottlePrice == bottlePrice;
  }

  @override
  int get hashCode => name.hashCode ^ logo.hashCode ^ bottlePrice.hashCode;
}
