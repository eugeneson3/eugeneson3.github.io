// 사이트에 표시되는 모든 내용은 이 파일만 고치면 됩니다.

export const profile = {
  name: '홍길동',
  role: 'Full-stack Developer',
  tagline: '문제를 정의하고, 단순한 구조로 해결하는 개발자입니다.',
  location: 'Seoul, Korea',
  email: 'you@example.com',
  links: [
    { label: 'GitHub', href: 'https://github.com/your-id' },
    { label: 'LinkedIn', href: 'https://www.linkedin.com/in/your-id' },
    { label: 'Blog', href: 'https://your-blog.example.com' },
  ],
  resume: '/resume.pdf', // public/resume.pdf 에 파일을 넣으세요. 없으면 '' 로 두면 버튼이 숨겨집니다.
  about: [
    'N년차 개발자로 웹 서비스의 설계부터 배포·운영까지 전 과정을 경험했습니다.',
    '성능과 유지보수성을 함께 고려한 코드를 지향하며, 팀이 더 빠르게 움직일 수 있는 도구와 프로세스를 만드는 데 관심이 많습니다.',
  ],
};

export const skills: { group: string; items: string[] }[] = [
  { group: 'Frontend', items: ['TypeScript', 'React', 'Next.js', 'Astro', 'CSS'] },
  { group: 'Backend', items: ['Node.js', 'NestJS', 'Python', 'PostgreSQL', 'Redis'] },
  { group: 'DevOps', items: ['Docker', 'AWS', 'GitHub Actions', 'Nginx'] },
];

export type Project = {
  title: string;
  period: string;
  summary: string;
  stack: string[];
  // 펼쳤을 때 보이는 상세 내용
  problem: string;
  approach: string[];
  result: string[];
  links?: { label: string; href: string }[];
};

export const projects: Project[] = [
  {
    title: '실시간 주문 대시보드',
    period: '2025.03 – 2025.09',
    summary: '매장 주문 현황을 실시간으로 모니터링하는 사내 대시보드',
    stack: ['React', 'WebSocket', 'NestJS', 'PostgreSQL'],
    problem: '주문 현황을 새로고침으로만 확인할 수 있어 피크 타임 대응이 늦었습니다.',
    approach: [
      'WebSocket 기반 이벤트 스트림으로 폴링을 대체',
      '주문 상태를 이벤트 소싱 방식으로 저장해 이력 추적 가능하게 설계',
      '가상 스크롤로 수천 건 목록 렌더링 최적화',
    ],
    result: ['주문 처리 지연 40% 감소', '서버 요청 수 90% 감소'],
    links: [
      { label: 'GitHub', href: 'https://github.com/your-id/project-a' },
    ],
  },
  {
    title: '개인 블로그 엔진',
    period: '2024.10 – 2024.12',
    summary: 'Markdown 기반 정적 블로그 생성기',
    stack: ['TypeScript', 'Astro', 'MDX'],
    problem: '기존 블로그 플랫폼은 코드 하이라이팅과 커스터마이징에 제약이 많았습니다.',
    approach: [
      'MDX로 글 안에 인터랙티브 컴포넌트 삽입',
      '빌드 타임에 OG 이미지 자동 생성',
    ],
    result: ['Lighthouse 전 항목 100점', '빌드 시간 3초 이내'],
    links: [
      { label: 'Demo', href: 'https://example.com' },
      { label: 'GitHub', href: 'https://github.com/your-id/project-b' },
    ],
  },
  {
    title: 'CLI 배포 자동화 도구',
    period: '2024.05 – 2024.07',
    summary: '사내 서비스 배포 절차를 명령어 하나로 묶은 CLI',
    stack: ['Node.js', 'Docker', 'AWS'],
    problem: '배포마다 12단계의 수동 절차가 필요해 실수가 잦았습니다.',
    approach: [
      '배포 단계를 선언형 설정 파일로 정의',
      '실패 시 자동 롤백 및 Slack 알림',
    ],
    result: ['배포 시간 30분 → 5분', '배포 관련 장애 0건 (6개월)'],
  },
];

export const experience: {
  company: string;
  role: string;
  period: string;
  details: string[];
}[] = [
  {
    company: '○○ 주식회사',
    role: 'Software Engineer',
    period: '2023.01 – 현재',
    details: [
      '주문/결제 도메인 백엔드 API 설계 및 개발',
      '레거시 모놀리스를 서비스 단위로 분리',
      '신규 입사자 온보딩 문서 및 개발 환경 자동화',
    ],
  },
  {
    company: '△△ 스타트업',
    role: 'Frontend Developer (Intern)',
    period: '2022.06 – 2022.12',
    details: ['React 기반 어드민 페이지 개발', '디자인 시스템 컴포넌트 구축'],
  },
];
