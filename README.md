# musahi

## 관심지역(SGIS Open API) 자격증명 설정

`관심지역 관리` 화면은 통계청 SGIS Open API를 사용한다. `consumer_key`/`consumer_secret`이
클라이언트 바이너리에 포함되면 디컴파일 등으로 유출될 수 있어, 인증과 조회는 모두
Firebase Functions의 `sgisRegions`(`functions/src/index.ts`)가 대신 수행하고 앱은 이
함수만 호출한다.

로컬에서 함수를 실행/배포하려면 Firebase Functions 시크릿으로 키를 등록한다.

```bash
firebase functions:secrets:set SGIS_CONSUMER_KEY
firebase functions:secrets:set SGIS_CONSUMER_SECRET
```

키를 설정하지 않으면 관심지역 검색 기능만 동작하지 않고 나머지 앱 기능은 정상 동작한다.
