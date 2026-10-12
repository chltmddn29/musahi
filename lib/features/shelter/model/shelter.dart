class Coordinate {
  final double latitude;
  final double longitude;

  const Coordinate(this.latitude, this.longitude);
}

class Shelter {
  final String id;
  final String name;
  final String address;
  final Coordinate location;
  final int distanceMeters;

  const Shelter({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.distanceMeters,
  });

  factory Shelter.fromJson(Map<String, dynamic> json) => Shelter(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String,
    location: Coordinate(
      (json['lat'] as num).toDouble(),
      (json['lng'] as num).toDouble(),
    ),
    distanceMeters: (json['distanceMeters'] as num).toInt(),
  );
}
