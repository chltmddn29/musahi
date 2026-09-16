# musahi

## 관심지역(SGIS Open API) 자격증명 설정

`관심지역 관리` 화면은 통계청 SGIS Open API를 사용하며, `consumer_key`/`consumer_secret`을
`--dart-define-from-file`로 주입받는다(`lib/features/setting/presentation/setting_detail/region_manage_page.dart`).

1. `config/dev.json.example`을 `config/dev.json`으로 복사한다. (`config/dev.json`은
   `.gitignore`에 포함되어 있어 커밋되지 않는다.)
2. [SGIS Open API](https://sgis.kostat.go.kr/developer/html/openApi/api/dataApi.html)에서
   발급받은 키를 `config/dev.json`에 채운다.
3. 아래처럼 `--dart-define-from-file` 옵션과 함께 실행/빌드한다.

```bash
flutter run --dart-define-from-file=config/dev.json
```

키를 설정하지 않으면 관심지역 검색 기능만 동작하지 않고 나머지 앱 기능은 정상 동작한다.
