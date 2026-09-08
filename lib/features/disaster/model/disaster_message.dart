class DisasterMessage {
  final int sn;
  final String severity;
  final String regionName;
  final String content;
  final String createdAt;

  DisasterMessage.fromMap(Map<String, dynamic> m)
      : sn = m['sn'] ?? 0,
        severity = m['severity'] ?? '안전안내',
        regionName = (m['rcptnRgnNm'] ?? '').toString().trim(),
        content = m['msgCn'] ?? '',
        createdAt = m['crtDt'] ?? '';
}
