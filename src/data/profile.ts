import projectData from './projects.json';
import courseData from './coursework.json';

// 프로젝트 본문은 projects.json, 설계 과제 목록은 coursework.json에서 편집합니다.
export const profile = {
  name: '손승원',
  role: 'RTL Design · Verification · Embedded Systems',
  tagline: 'SystemVerilog RTL 설계, UVM 검증 및 STM32 기반 임베디드 시스템 구현 기록입니다.',
  email: 'davison2500@gmail.com',
  links: [{ label: 'GitHub', href: 'https://github.com/eugeneson3' }],
  // resume: '/resume.pdf',
  // about: [],
};

export type Project = (typeof projectData)[number];
export const projects = projectData;
export const coursework = courseData;
export const projectCategories = ['RTL 설계·검증', '임베디드', '개발 도구'];

export const experience: {
  company: string;
  role: string;
  period: string;
  details: string[];
}[] = [
  {
    company: 'AI 캠퍼스 반도체설계 1기',
    role: '교육 과정',
    period: '2026.07. – 2027.02.',
    details: [
      'Verilog/SystemVerilog RTL 설계, FPGA 구현, UVM 검증',
      'RISC-V CPU 설계 및 APB 버스 시스템 팀 프로젝트',
      'On-device AI(머신러닝/CNN), 임베디드 C',
    ],
  },
  {
    company: '연진에스텍',
    role: 'PVD 장비 영업팀',
    period: '2025.04 – 2025.07',
    details: [
      'PVD 장비 운영 및 유지보수',
      '고객 장비 사용 문의 대응',
      '영국 장비 사용법·유지보수·제품 교육 이수 (2025.06)',
    ],
  },
  {
    company: '전남대학교',
    role: '전자컴퓨터공학부 전자정보통신공학전공 학사',
    period: '2019.03 – 2023.02',
    details: [],
  },
];

// 자격 항목은 확인된 자료를 추가한 후 표시합니다.
// export const certs = [];
