# Portfolio

Astro 기반 정적 포트폴리오 사이트입니다.

## 내용 수정

`src/data/profile.ts` 파일 하나만 고치면 이름, 소개, 기술 스택, 프로젝트, 경력, 연락처가 모두 바뀝니다.
이력서 PDF는 `public/resume.pdf`에 넣으세요.

## 로컬 실행

```bash
npm install
npm run dev
```

## GitHub Pages 배포

1. GitHub에 `<your-id>.github.io` 이름으로 레포를 만들고 push 합니다.
2. 레포 **Settings → Pages → Source** 를 **GitHub Actions** 로 바꿉니다.
3. `astro.config.mjs` 의 `site` 를 본인 주소로 바꿉니다.
4. `main` 브랜치에 push 하면 `.github/workflows/deploy.yml` 이 자동으로 배포합니다.
