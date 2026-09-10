import 'package:flutter/foundation.dart';

/// 앱 전역 텍스트 크기 단계 (0=작게, 1=보통, 2=크게, 3=매우크게).
///
/// 별도 상태관리 패키지가 없어 [goRouter]처럼 전역 [ValueNotifier]로 관리한다.
/// 값을 읽을 화면은 `ValueListenableBuilder`로 구독하면 된다.
final ValueNotifier<int> textSizeStep = ValueNotifier<int>(1);
