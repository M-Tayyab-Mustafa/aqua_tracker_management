// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Location {
  String latitude;
  String longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });

  Location copyWith({
    String? latitude,
    String? longitude,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Location.fromMap(Map map) {
    return Location(
      latitude: map['latitude'].toString(),
      longitude: map['longitude'].toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Location.fromJson(String source) => Location.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ClientLocation(latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(covariant Location other) {
    if (identical(this, other)) return true;

    return other.latitude == latitude && other.longitude == longitude;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^ longitude.hashCode;
  }
}
