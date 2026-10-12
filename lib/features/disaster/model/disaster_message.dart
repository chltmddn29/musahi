class DisasterMessage {
  final int sn;
  final String severity;
  final String regionName;
  final String title;
  final String createdAt;
  final String category;

  DisasterMessage.fromMap(Map<String, dynamic> m)
      : sn = m['sn'] ?? 0,
        severity = m['severity'] ?? '안전안내',
        regionName = (m['rcptnRgnNm'] ?? '').toString().trim(),
        title = m['msgCn'] ?? '',
        createdAt = m['crtDt'] ?? '',
        category = _normalizeCategory(m['dstSeNm']);

  /// 대피가 필요한 재난 유형(dstSeNm).
  static const _shelterCategories = {
    '지진',
    '지진해일',
    '호우',
    '태풍',
    '홍수',
    '산사태',
    '산불',
    '화재',
    '붕괴',
    '폭발',
    '환경오염사고',
    '가스',
    '화생방',
    '민방공',
    '방사능',
  };

  /// 대피소 안내가 필요한 문자인지. 실종·교통·정전 등은 제외하고,
  /// 유형이 '기타'여도 본문에서 대피를 요청하면 포함한다.
  bool get needsShelter =>
      _shelterCategories.contains(category) || title.contains('대피');

  static String _normalizeCategory(dynamic value) {
    final category = (value ?? '').toString().trim();
    return category.isEmpty ? '기타' : category;
  }
}