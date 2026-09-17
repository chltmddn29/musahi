class RegionItem {
  final String addrName;
  final String cd;
  final String fullAddr;
  final String yCoor;
  final String xCoor;
  final String? notificationCode;

  RegionItem({
    required this.addrName,
    required this.cd,
    required this.fullAddr,
    required this.yCoor,
    required this.xCoor,
    this.notificationCode,
  });

  /// 시/도부터 이어지는 전체 주소. SGIS가 비워서 줄 때만 현재 단계 이름으로 대체.
  String get displayName => fullAddr.isNotEmpty ? fullAddr : addrName;

  factory RegionItem.fromJson(Map<String, dynamic> json) {
    return RegionItem(
      addrName: json['addr_name'] as String? ?? '',
      cd: json['cd'] as String? ?? '',
      fullAddr: json['full_addr'] as String? ?? '',
      yCoor: json['y_coor'] as String? ?? '',
      xCoor: json['x_coor'] as String? ?? '',
      notificationCode: json['notification_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'addr_name': addrName,
    'cd': cd,
    'full_addr': fullAddr,
    'y_coor': yCoor,
    'x_coor': xCoor,
    'notification_code': notificationCode,
  };

  RegionItem withNotificationCode(String code) => RegionItem(
    addrName: addrName,
    cd: cd,
    fullAddr: fullAddr,
    yCoor: yCoor,
    xCoor: xCoor,
    notificationCode: code,
  );

  factory RegionItem.fromDisasterRegion(Map<String, dynamic> data) {
    final code = data['code'];
    final name = data['name'];
    if (code is! String ||
        !RegExp(r'^[0-9]+$').hasMatch(code) ||
        name is! String ||
        name.trim().isEmpty) {
      throw const FormatException('Invalid disaster region');
    }
    return RegionItem(
      addrName: name.trim(),
      cd: code,
      fullAddr: name.trim(),
      yCoor: '',
      xCoor: '',
      notificationCode: code,
    );
  }
}

/// 선택 경로와 정확히 일치하는 가장 세분화된 재난문자 수신지역을 찾는다.
///
/// 동·읍·면에 대한 수신지역 코드가 없으면 상위 시군구·시도 코드까지 차례로
/// 찾는다. 이름이 비슷한 다른 지역을 구독하지 않도록 부분 일치는 사용하지 않는다.
String? resolveNotificationCode(
  List<RegionItem> selectionPath,
  Iterable<RegionItem> notificationRegions,
) {
  final codesByName = <String, Set<String>>{};
  for (final region in notificationRegions) {
    final code = region.notificationCode;
    if (code == null) continue;
    codesByName
        .putIfAbsent(normalizeRegionName(region.displayName), () => {})
        .add(code);
  }

  for (var length = selectionPath.length; length > 0; length--) {
    final name = selectionPath
        .take(length)
        .map((region) => region.addrName)
        .join(' ');
    final codes = codesByName[normalizeRegionName(name)];
    if (codes != null && codes.length == 1) return codes.single;
  }
  return null;
}

String normalizeRegionName(String name) =>
    name.trim().replaceAll(RegExp(r'\s+'), ' ');
