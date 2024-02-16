// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'location.dart';

class Client {
  String uid;
  String name;
  String email;
  String contact;
  String branch;
  String companyName;
  bool onVacation;
  List<Location> locations;
  String token;
  String password;

  Client({
    required this.uid,
    required this.name,
    required this.email,
    required this.contact,
    required this.branch,
    required this.companyName,
    required this.onVacation,
    required this.locations,
    required this.token,
    required this.password,
  });

  Client copyWith({
    String? uid,
    String? name,
    String? email,
    String? contact,
    String? branch,
    String? companyName,
    bool? onVacation,
    List<Location>? locations,
    String? token,
    String? password,
  }) {
    return Client(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      branch: branch ?? this.branch,
      companyName: companyName ?? this.companyName,
      onVacation: onVacation ?? this.onVacation,
      locations: locations ?? this.locations,
      token: token ?? this.token,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'contact': contact,
      'branch': branch,
      'company_name': companyName,
      'on_vacation': onVacation,
      'locations': locations.map((x) => x.toMap()).toList(),
      'token': token,
      'password': password,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      contact: map['contact'] as String,
      branch: map['branch'] as String,
      companyName: map['company_name'] as String,
      onVacation: map['on_vacation'] as bool,
      locations: List<Location>.from(map['locations'].map<Location>((location) => Location.fromMap(location))),
      token: map['token'] as String,
      password: map['password'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Client.fromJson(String source) => Client.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Client(uid: $uid, name: $name, email: $email, contact: $contact, branch: $branch, company_name: $companyName, on_vacation: $onVacation, locations: $locations, token: $token, password: $password)';
  }

  @override
  bool operator ==(covariant Client other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.name == name &&
        other.email == email &&
        other.contact == contact &&
        other.branch == branch &&
        other.companyName == companyName &&
        other.onVacation == onVacation &&
        listEquals(other.locations, locations) &&
        other.token == token &&
        other.password == password;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        email.hashCode ^
        contact.hashCode ^
        branch.hashCode ^
        companyName.hashCode ^
        onVacation.hashCode ^
        locations.hashCode ^
        token.hashCode ^
        password.hashCode;
  }
}
