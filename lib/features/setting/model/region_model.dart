class RegionItem {
  final String addrName;
  final String cd;
  final String fullAddr;
  final String yCoor;
  final String xCoor;

  RegionItem({
    required this.addrName,
    required this.cd,
    required this.fullAddr,
    required this.yCoor,
    required this.xCoor,
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
    );
  }

  Map<String, dynamic> toJson() => {
    'addr_name': addrName,
    'cd': cd,
    'full_addr': fullAddr,
    'y_coor': yCoor,
    'x_coor': xCoor,
  };
}
