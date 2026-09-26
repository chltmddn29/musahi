import 'dart:async';

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

  /// 실내 등 GPS가 약할 때 로딩이 끝나지 않는 것을 막는다.
  static const _timeLimit = Duration(seconds: 10);

  /// 권한을 확인·요청한 뒤 현재 위치를 반환한다.
  /// 제한 시간 안에 못 받으면 마지막으로 알려진 위치를 쓴다.
  Future<Coordinate> currentLocation() async {
    await _ensurePermission();
    final position = await _currentOrLastKnownPosition();
    return Coordinate(position.latitude, position.longitude);
  }

  Future<Position> _currentOrLastKnownPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: _timeLimit),
      );
    } on TimeoutException {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return lastKnown;
      throw const LocationException('현재 위치를 확인하지 못했습니다. 잠시 후 다시 시도해 주세요.');
    }
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
