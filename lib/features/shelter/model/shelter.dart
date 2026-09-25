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
}
