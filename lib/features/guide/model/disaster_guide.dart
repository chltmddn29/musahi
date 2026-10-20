/// 행동요령 한 단계. 문구는 [id]로 `AppLocalizations.guideStepTitle`과
/// `guideStepDescription`에서 찾는다.
class GuideStep {
  final String id;

  const GuideStep(this.id);
}

/// 재난 유형별 행동요령. 행정안전부 국민행동요령을 요약했다.
class DisasterGuide {
  final String category;
  final List<GuideStep> steps;

  /// 대피가 필요한 유형인지. false면 "가까운 대피소 보기" 버튼을 숨긴다.
  final bool needsShelter;

  const DisasterGuide({
    required this.category,
    required this.steps,
    this.needsShelter = true,
  });

  /// 재난문자 유형(dstSeNm)에 맞는 행동요령. 없으면 null.
  static DisasterGuide? of(String category) {
    for (final guide in all) {
      if (guide.category == category) return guide;
    }
    return null;
  }

  static const all = [earthquake, heavyRain, typhoon, heatWave];

  static const earthquake = DisasterGuide(
    category: '지진',
    steps: [
      GuideStep('earthquake1'),
      GuideStep('earthquake2'),
      GuideStep('earthquake3'),
      GuideStep('earthquake4'),
      GuideStep('earthquake5'),
    ],
  );

  static const heavyRain = DisasterGuide(
    category: '호우',
    steps: [
      GuideStep('heavyRain1'),
      GuideStep('heavyRain2'),
      GuideStep('heavyRain3'),
      GuideStep('heavyRain4'),
      GuideStep('heavyRain5'),
    ],
  );

  static const typhoon = DisasterGuide(
    category: '태풍',
    steps: [
      GuideStep('typhoon1'),
      GuideStep('typhoon2'),
      GuideStep('typhoon3'),
      GuideStep('typhoon4'),
      GuideStep('typhoon5'),
    ],
  );

  static const heatWave = DisasterGuide(
    category: '폭염',
    needsShelter: false,
    steps: [
      GuideStep('heatWave1'),
      GuideStep('heatWave2'),
      GuideStep('heatWave3'),
      GuideStep('heatWave4'),
      GuideStep('heatWave5'),
    ],
  );
}
