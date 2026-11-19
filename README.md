# 포트폴리오 편집

[배포 사이트](https://eugeneson3.github.io/)

## 내용 수정

- 프로젝트 설명, 영상, 소스코드 링크는 `src/data/projects.json`에서 편집합니다.
- 설계 과제 목록은 `src/data/coursework.json`에서 편집합니다.
- 이름, 연락처 및 경력은 `src/data/profile.ts`에서 편집합니다.
- 화면 구성은 `src/pages/`, 공통 스타일은 `src/styles/global.css`에서 편집합니다.

프로젝트의 `slug`에 따라 `/projects/slug/` 상세 페이지가 생성됩니다. 기존 주소를 유지하려면 `slug`를 유지합니다.

## 프로젝트 구성 및 계층도

- `components`: 부품·개발 환경의 이름, 수량, 역할입니다.
- `wiring`: 장치별 핀 연결과 신호의 동작입니다. 버전별 배선은 별도 그룹으로 작성합니다.
- `operation`: 입력부터 출력까지의 동작 순서입니다.
- `architectures`: Application, Service, Driver, HAL, Hardware 순서의 계층도입니다. RTL·UVM 프로젝트는 실제 설계·검증 계층을 사용합니다.

계층도는 `layers` 순서대로 위에서 아래로 표시됩니다. 각 계층의 `nodes`에 파일명과 역할을 작성하고, `path`에는 해당 프로젝트 저장소의 상대 경로를 지정합니다. 파일을 누르면 GitHub 소스로 이동합니다. 하드웨어처럼 연결할 파일이 없는 항목은 `path`를 빈 문자열로 둡니다.

`sourceNote`에는 공개 소스와 최종 시연 버전의 차이를 작성합니다. 결과 수치와 담당 업무는 실제 검증 기록을 기준으로 작성합니다.

## 이미지와 영상

이미지는 `public/projects/`에 추가하고 `images` 배열의 `src`에 `/projects/파일명`을 지정합니다. `caption`에는 이미지 설명을 작성합니다.

YouTube 영상은 `videos` 배열에 `id`와 `title`을 추가합니다. `id`에는 영상 주소의 영상 ID를 입력합니다. 빈 배열인 항목은 화면에서 생략됩니다.

## 배포 확인

GitHub 웹 편집기에서 파일을 수정하고 main 브랜치에 커밋하면 GitHub Actions가 빌드와 배포를 실행합니다. Actions에서 해당 커밋의 작업이 성공한 뒤 사이트를 새로고침합니다.

## 로컬 검증

```sh
npm ci
npm run build
npm run dev
```

프로젝트 소스는 각 개별 저장소에서 관리합니다. 사이트의 설명과 실제 소스 버전이 일치하는지 확인한 후 수정합니다.

## 과제 소스

- [디지털 설계 및 검증](coursework-sources/digital-design/README.md)
- [STM32 임베디드 실습](coursework-sources/embedded/README.md)

과제 소스는 위 폴더에 수록하였습니다. 프로젝트별 소스는 각 프로젝트 페이지에서 독립 저장소로 연결됩니다.
