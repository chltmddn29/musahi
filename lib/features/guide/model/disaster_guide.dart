/// 행동요령 한 단계.
class GuideStep {
  final String title;
  final String description;

  const GuideStep(this.title, this.description);
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
      GuideStep(
        '탁자 아래로 몸을 보호하세요',
        '흔들리는 동안 탁자 아래로 들어가 다리를 꽉 잡고 머리를 보호합니다.',
      ),
      GuideStep(
        '흔들림이 멈추면 전기와 가스를 차단하세요',
        '가스 밸브와 전기를 잠그고, 문을 열어 출구를 확보합니다.',
      ),
      GuideStep(
        '계단을 이용해 밖으로 나가세요',
        '엘리베이터는 타지 말고, 건물과 담장에서 떨어져 이동합니다.',
      ),
      GuideStep(
        '넓은 공간으로 대피하세요',
        '가방 등으로 머리를 보호하며 운동장이나 공원처럼 넓은 곳으로 이동합니다.',
      ),
      GuideStep(
        '공식 정보를 따르세요',
        '재난문자·라디오 등으로 정보를 확인하고, 확인되지 않은 소문은 믿지 않습니다.',
      ),
    ],
  );

  static const heavyRain = DisasterGuide(
    category: '호우',
    steps: [
      GuideStep(
        '기상 정보를 수시로 확인하세요',
        '재난문자·TV·라디오로 호우 특보와 대피 안내를 확인합니다.',
      ),
      GuideStep(
        '하천과 저지대에 가까이 가지 마세요',
        '하천변 산책로, 계곡, 방파제에서는 즉시 벗어납니다.',
      ),
      GuideStep(
        '지하 공간에서 바로 나오세요',
        '지하주차장·반지하에 물이 차기 시작하면 문이 열리지 않을 수 있으니 곧바로 지상으로 올라갑니다.',
      ),
      GuideStep(
        '물에 잠긴 도로는 건너지 마세요',
        '물살이 약해 보여도 걸어서나 차로 지나가지 않습니다.',
      ),
      GuideStep(
        '대피 권고가 내려지면 즉시 대피하세요',
        '전기와 가스를 차단하고 가까운 대피소로 이동합니다.',
      ),
    ],
  );

  static const typhoon = DisasterGuide(
    category: '태풍',
    steps: [
      GuideStep(
        '외출을 자제하세요',
        '태풍 특보 중에는 실내에 머물며 기상 정보를 확인합니다.',
      ),
      GuideStep(
        '창문을 단단히 고정하세요',
        '창틀을 고정하고, 깨질 수 있는 유리창에서 떨어져 지냅니다.',
      ),
      GuideStep(
        '바람에 날릴 물건을 치우세요',
        '화분·간판 등 날아갈 수 있는 물건을 실내로 옮기거나 단단히 묶습니다.',
      ),
      GuideStep(
        '해안가와 공사장 근처에 가지 마세요',
        '높은 파도에 휩쓸리거나 떨어지는 물체에 다칠 수 있습니다.',
      ),
      GuideStep(
        '정전에 대비하세요',
        '손전등, 보조배터리, 식수를 미리 챙겨 둡니다.',
      ),
    ],
  );

  static const heatWave = DisasterGuide(
    category: '폭염',
    needsShelter: false,
    steps: [
      GuideStep(
        '물을 자주 마시세요',
        '목이 마르지 않아도 규칙적으로 물을 마십니다.',
      ),
      GuideStep(
        '한낮에는 야외 활동을 피하세요',
        '가장 더운 오후 2시~5시에는 외출과 야외 작업을 줄입니다.',
      ),
      GuideStep(
        '시원한 곳에 머무르세요',
        '헐렁하고 밝은 옷을 입고, 가까운 무더위쉼터를 이용합니다.',
      ),
      GuideStep(
        '어지러우면 바로 쉬세요',
        '두통·어지러움·메스꺼움이 느껴지면 시원한 곳에서 쉬고, 증상이 계속되면 119에 연락합니다.',
      ),
      GuideStep(
        '주변 사람을 살펴주세요',
        '어르신과 어린이 등 더위에 약한 이웃의 안부를 확인합니다.',
      ),
    ],
  );
}
