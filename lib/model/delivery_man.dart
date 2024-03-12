// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Employee {
  String uid;
  String name;
  String companyName;
  String branch;
  String email;
  String contact;
  String imageUrl;
  String post;
  bool onVacations;
  Employee({
    required this.uid,
    required this.name,
    required this.companyName,
    required this.branch,
    required this.email,
    required this.contact,
    required this.imageUrl,
    required this.post,
    required this.onVacations,
  });

  Employee copyWith({
    String? uid,
    String? name,
    String? companyName,
    String? branch,
    String? email,
    String? contact,
    String? imageUrl,
    String? post,
    bool? onVacations,
  }) {
    return Employee(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      branch: branch ?? this.branch,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      imageUrl: imageUrl ?? this.imageUrl,
      post: post ?? this.post,
      onVacations: onVacations ?? this.onVacations,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'company_name': companyName,
      'branch': branch,
      'email': email,
      'contact': contact,
      'image_url': imageUrl,
      'post': post,
      'on_vacations': onVacations,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      uid: map['uid'] as String,
      name: map['name'] as String,
      companyName: map['company_name'] as String,
      branch: map['branch'] as String,
      email: map['email'] as String,
      contact: map['contact'] as String,
      imageUrl: map['image_url'] as String,
      post: map['post'] as String,
      onVacations: map['on_vacations'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Employee.fromJson(String source) => Employee.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DeliveryMan(uid: $uid, name: $name, company_name: $companyName, branch: $branch, email: $email, contact: $contact, image_url: $imageUrl, post: $post, on_vacations: $onVacations)';
  }

  @override
  bool operator ==(covariant Employee other) {
    if (identical(this, other)) return true;

    return other.uid == uid && other.name == name && other.companyName == companyName && other.branch == branch && other.email == email && other.contact == contact && other.imageUrl == imageUrl && other.post == post && other.onVacations == onVacations;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ name.hashCode ^ companyName.hashCode ^ branch.hashCode ^ email.hashCode ^ contact.hashCode ^ imageUrl.hashCode ^ post.hashCode ^ onVacations.hashCode;
  }
}
