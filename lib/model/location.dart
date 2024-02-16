// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Location {
  String latitude;
  String longitude;
  String address;

  Location({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  Location copyWith({
    String? latitude,
    String? longitude,
    String? address,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory Location.fromMap(Map<dynamic, dynamic> map) {
    return Location(
      latitude: map['latitude'] as String,
      longitude: map['longitude'] as String,
      address: map['address'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Location.fromJson(String source) => Location.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Location(latitude: $latitude, longitude: $longitude, address: $address)';

  @override
  bool operator ==(covariant Location other) {
    if (identical(this, other)) return true;

    return other.latitude == latitude && other.longitude == longitude && other.address == address;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode ^ address.hashCode;
}
