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
        category = m['dstSeNm'] ?? '기타';
}