import 'package:geolocator/geolocator.dart';
import 'package:musahi/features/shelter/model/shelter.dart';

/// 사용자에게 그대로 보여줄 수 있는 위치 오류.
class LocationException implements Exception {
  final String message;

  const LocationException(this.message);

  @override
  String toString() => message;
}

class LocationService {
  LocationService._();

  static final instance = LocationService._();

  /// 권한을 확인·요청한 뒤 현재 위치를 반환한다.
  Future<Coordinate> currentLocation() async {
    await _ensurePermission();
    final position = await Geolocator.getCurrentPosition();
    return Coordinate(position.latitude, position.longitude);
  }

  Future<void> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException('위치 서비스가 꺼져 있습니다. 설정에서 켜 주세요.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    switch (permission) {
      case LocationPermission.denied:
        throw const LocationException('가까운 대피소를 찾으려면 위치 권한이 필요합니다.');
      case LocationPermission.deniedForever:
        throw const LocationException('설정에서 위치 권한을 허용해 주세요.');
      default:
        return;
    }
  }
}
