import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:musahi/features/shelter/model/shelter.dart';

enum LocationError {
  timeout,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

/// 화면이 [error]에 맞는 안내 문구를 보여줄 수 있는 위치 오류.
class LocationException implements Exception {
  final LocationError error;

  const LocationException(this.error);

  @override
  String toString() => 'LocationException: ${error.name}';
}

class LocationService {
  LocationService._();

  static final instance = LocationService._();

  /// 실내 등 GPS가 약할 때 로딩이 끝나지 않는 것을 막는다.
  static const _timeLimit = Duration(seconds: 10);

  /// 이보다 오래된 마지막 위치는 다른 장소일 수 있어 쓰지 않는다.
  static const _lastKnownMaxAge = Duration(minutes: 5);

  /// 권한을 확인·요청한 뒤 현재 위치를 반환한다.
  /// 제한 시간 안에 못 받으면 최근([_lastKnownMaxAge] 이내)에 알려진 위치를 쓴다.
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
      if (lastKnown != null && isRecent(lastKnown.timestamp, DateTime.now())) {
        return lastKnown;
      }
      throw const LocationException(LocationError.timeout);
    }
  }

  /// [recordedAt]이 [now] 기준으로 쓸 만큼 최근인지.
  @visibleForTesting
  static bool isRecent(DateTime recordedAt, DateTime now) =>
      now.difference(recordedAt) <= _lastKnownMaxAge;

  Future<void> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationError.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    switch (permission) {
      case LocationPermission.denied:
        throw const LocationException(LocationError.permissionDenied);
      case LocationPermission.deniedForever:
        throw const LocationException(LocationError.permissionDeniedForever);
      default:
        return;
    }
  }
}
