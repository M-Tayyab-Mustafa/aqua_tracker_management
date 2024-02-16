// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Employee {
  String uid;
  String name;
  String email;
  String password;
  String contact;
  String imageUrl;
  String companyName;
  String branch;
  String post;
  String token;
  bool onVacation;

  Employee({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    required this.contact,
    required this.imageUrl,
    required this.companyName,
    required this.branch,
    required this.post,
    required this.token,
    required this.onVacation,
  });

  Employee copyWith({
    String? uid,
    String? name,
    String? email,
    String? password,
    String? contact,
    String? imageUrl,
    String? companyName,
    String? branch,
    String? post,
    String? token,
    bool? onVacation,
  }) {
    return Employee(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      contact: contact ?? this.contact,
      imageUrl: imageUrl ?? this.imageUrl,
      companyName: companyName ?? this.companyName,
      branch: branch ?? this.branch,
      post: post ?? this.post,
      token: token ?? this.token,
      onVacation: onVacation ?? this.onVacation,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'contact': contact,
      'image_url': imageUrl,
      'company_name': companyName,
      'branch': branch,
      'post': post,
      'token': token,
      'on_vacation': onVacation,
    };
  }

  factory Employee.fromMap(Map<dynamic, dynamic> map) {
    return Employee(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      contact: map['contact'] as String,
      imageUrl: map['image_url'] as String,
      companyName: map['company_name'] as String,
      branch: map['branch'] as String,
      post: map['post'] as String,
      token: map['token'] as String,
      onVacation: map['on_vacation'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Employee.fromJson(String source) => Employee.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(uid: $uid, name: $name, email: $email, password: $password, contact: $contact, image_url: $imageUrl, company_name: $companyName, branch: $branch, post: $post, token: $token, on_vacation: $onVacation)';
  }

  @override
  bool operator ==(covariant Employee other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.name == name &&
        other.email == email &&
        other.password == password &&
        other.contact == contact &&
        other.imageUrl == imageUrl &&
        other.companyName == companyName &&
        other.branch == branch &&
        other.post == post &&
        other.token == token &&
        other.onVacation == onVacation;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        email.hashCode ^
        password.hashCode ^
        contact.hashCode ^
        imageUrl.hashCode ^
        companyName.hashCode ^
        branch.hashCode ^
        post.hashCode ^
        token.hashCode ^
        onVacation.hashCode;
  }
}
