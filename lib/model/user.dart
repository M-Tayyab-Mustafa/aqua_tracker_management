// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class User {
  String name;
  String email;
  String contact;
  String imageUrl;
  String branch;
  String companyName;
  String uid;
  String post;
  bool onVacation;
  String deviceToken;
  User({
    required this.name,
    required this.email,
    required this.contact,
    required this.imageUrl,
    required this.branch,
    required this.companyName,
    required this.uid,
    required this.post,
    required this.onVacation,
    required this.deviceToken,
  });

  User copyWith({
    String? name,
    String? email,
    String? contact,
    String? imageUrl,
    String? branch,
    String? companyName,
    String? uid,
    String? post,
    bool? onVacation,
    String? deviceToken,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      imageUrl: imageUrl ?? this.imageUrl,
      branch: branch ?? this.branch,
      companyName: companyName ?? this.companyName,
      uid: uid ?? this.uid,
      post: post ?? this.post,
      onVacation: onVacation ?? this.onVacation,
      deviceToken: deviceToken ?? this.deviceToken,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'contact': contact,
      'image_url': imageUrl,
      'branch': branch,
      'company_name': companyName,
      'uid': uid,
      'post': post,
      'on_vacation': onVacation,
      'token': deviceToken,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      email: map['email'],
      contact: map['contact'],
      imageUrl: map['image_url'],
      branch: map['branch'],
      companyName: map['company_name'],
      uid: map['uid'],
      post: map['post'],
      onVacation: map['on_vacation'],
      deviceToken: map['token'],
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(name: $name, email: $email, contact: $contact, image_url: $imageUrl, branch: $branch, company_name: $companyName, uid: $uid, post: $post, on_vacation: $onVacation, token: $deviceToken)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.email == email &&
        other.contact == contact &&
        other.imageUrl == imageUrl &&
        other.branch == branch &&
        other.companyName == companyName &&
        other.uid == uid &&
        other.post == post &&
        other.onVacation == onVacation &&
        other.deviceToken == deviceToken;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        email.hashCode ^
        contact.hashCode ^
        imageUrl.hashCode ^
        branch.hashCode ^
        companyName.hashCode ^
        uid.hashCode ^
        post.hashCode ^
        onVacation.hashCode ^
        deviceToken.hashCode;
  }
}
