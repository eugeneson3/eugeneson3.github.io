# Portfolio

Astro 기반 정적 포트폴리오 사이트입니다. → https://eugeneson3.github.io

## 내용 수정

`src/data/profile.ts` 파일 하나만 고치면 이름, 소개, 기술 스택, 프로젝트, 과제, 경력, 연락처가 모두 바뀝니다.

### 사진 넣기
1. 이미지 파일을 `public/projects/` 폴더에 넣습니다. (예: `public/projects/fifo-wave.png`)
2. `profile.ts`의 해당 프로젝트에 추가합니다.
   ```ts
   images: [{ src: '/projects/fifo-wave.png', caption: 'FIFO 파형' }],
   ```

### 동영상 넣기
YouTube에 올린 뒤(일부 공개 가능) 주소를 붙여넣습니다. 영상 파일을 레포에 직접 넣지 마세요.
```ts
video: 'https://youtu.be/영상ID',
```

## 반영(배포)
```bash
git add -A
git commit -m "내용 수정"
git push
```
push 후 1~2분 뒤 사이트에 자동 반영됩니다.

GitHub 웹사이트에서 `src/data/profile.ts` → 연필 아이콘으로 직접 고치고 Commit해도 똑같이 반영됩니다.

## 로컬 미리보기
```bash
npm run dev
```
