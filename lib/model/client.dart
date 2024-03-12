// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'location.dart';

class Client {
  String name;
  String contact;
  String email;
  String branch;
  String companyName;
  String uid;
  bool onVacations;
  String token;
  List<Location> locations;

  Client({
    required this.name,
    required this.contact,
    required this.email,
    required this.branch,
    required this.companyName,
    required this.uid,
    required this.onVacations,
    required this.token,
    required this.locations,
  });

  Client copyWith({
    String? name,
    String? contact,
    String? email,
    String? branch,
    String? companyName,
    String? uid,
    bool? onVacations,
    String? token,
    List<Location>? locations,
  }) {
    return Client(
      name: name ?? this.name,
      contact: contact ?? this.contact,
      email: email ?? this.email,
      branch: branch ?? this.branch,
      companyName: companyName ?? this.companyName,
      uid: uid ?? this.uid,
      onVacations: onVacations ?? this.onVacations,
      token: token ?? this.token,
      locations: locations ?? this.locations,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'contact': contact,
      'email': email,
      'branch': branch,
      'company_name': companyName,
      'uid': uid,
      'on_vacations': onVacations,
      'token': token,
      'locations': locations.map((e) => e.toMap()).toList(),
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      name: map['name'] as String,
      contact: map['contact'] as String,
      email: map['email'] as String,
      branch: map['branch'] as String,
      companyName: map['company_name'] as String,
      uid: map['uid'] as String,
      onVacations: map['on_vacations'],
      token: map['token'],
      locations: map['locations'].map<Location>((location) => Location.fromMap(location as Map<String, dynamic>)).toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Client.fromJson(String source) => Client.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Client(name: $name, contact: $contact, email: $email, branch: $branch, company_name: $companyName, uid: $uid, location: $locations, on_vacations: $onVacations, token: $token)';
  }

  @override
  bool operator ==(covariant Client other) {
    if (identical(this, other)) return true;

    return other.name == name && other.contact == contact && other.email == email && other.branch == branch && other.companyName == companyName && other.uid == uid && other.locations == locations && other.onVacations == onVacations && other.token == token;
  }

  @override
  int get hashCode {
    return name.hashCode ^ contact.hashCode ^ email.hashCode ^ branch.hashCode ^ companyName.hashCode ^ uid.hashCode ^ locations.hashCode ^ onVacations.hashCode ^ token.hashCode;
  }
}
