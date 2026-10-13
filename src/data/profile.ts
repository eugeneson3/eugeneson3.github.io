// 사이트에 표시되는 모든 내용은 이 파일만 고치면 됩니다.

export const profile = {
  name: '손승원',
  role: 'Digital Design & Verification Engineer (신입)',
  tagline: 'RTL을 직접 설계하고, UVM으로 버그를 찾아 숫자로 증명하는 검증 엔지니어를 목표로 합니다.',
  location: 'Korea',
  email: 'davison2500@gmail.com',
  links: [{ label: 'GitHub', href: 'https://github.com/eugeneson3' }],
  resume: '', // public/resume.pdf 를 넣고 '/resume.pdf' 로 바꾸면 이력서 버튼이 생깁니다.
  about: [
    '전자정보통신공학을 전공하고, PVD 장비 업체에서 반도체 장비 운영·유지보수를 경험했습니다. 이후 AI 캠퍼스 반도체설계 과정에서 Verilog/SystemVerilog로 FIFO, UART, 센서 컨트롤러, RISC-V CPU까지 직접 설계하고 FPGA에서 동작을 확인했습니다.',
    'UVM 테스트벤치로 9만 개 이상의 명령을 자동 검사해 시프트 연산 버그를 찾아낸 경험을 계기로, 칩이 "왜 맞는지"를 증명하는 검증(DV) 직무를 목표로 하고 있습니다.',
  ],
};

export const skills: { group: string; items: string[] }[] = [
  { group: 'RTL', items: ['Verilog', 'SystemVerilog', 'FSM 설계', 'RISC-V RV32I', 'APB', 'UART'] },
  { group: 'Verification', items: ['UVM', 'Constrained Random', 'Functional Coverage', 'Scoreboard'] },
  { group: 'FPGA / Tools', items: ['Basys3', 'Vivado', 'ILA', 'Waveform 디버깅'] },
  { group: 'Etc', items: ['C', 'Python', 'Keras (On-device AI)', 'Git'] },
];

export type Project = {
  title: string;
  period: string;
  team: string; // 예: '개인', '4인 팀'
  role?: string; // 팀 프로젝트에서 본인이 맡은 부분
  summary: string;
  stack: string[];
  // 펼쳤을 때 보이는 상세 내용
  problem: string;
  approach: string[];
  result: string[];
  links?: { label: string; href: string }[];
  // 사진: public/projects/ 폴더에 넣고 '/projects/파일명.png' 처럼 적습니다.
  images?: { src: string; caption?: string }[];
  // 영상: YouTube 주소를 그대로 붙여넣습니다.
  video?: string;
};

export const projects: Project[] = [
  {
    title: 'RV32I Multi-cycle CPU 설계 · UVM 검증 · APB 버스 확장',
    period: '2026.09',
    team: '4인 팀',
    role: 'RV32I CPU RTL 설계(Datapath, Control Unit FSM), C 누적합 프로그램으로 동작 검증',
    summary: 'RISC-V 기본 정수 명령어 CPU를 설계하고, UVM으로 9만 개 명령을 검증한 뒤 APB 버스로 메모리·주변장치를 연결',
    stack: ['SystemVerilog', 'UVM', 'RISC-V', 'APB', 'FPGA'],
    problem:
      'Single-cycle CPU는 가장 느린 명령어가 클럭 주기를 결정합니다. 이를 Multi-cycle 구조로 개선하고, 설계가 모든 명령어에서 정확한지 체계적으로 증명해야 했습니다.',
    approach: [
      'R/I/S/IL/U/B/J/JL 타입 명령어를 지원하는 Datapath와 Control Unit FSM 설계',
      'C로 작성한 1~10 누적합 프로그램을 어셈블리 단위로 분석하고 파형으로 i=10, sum=55 확인',
      'UVM 환경(sequence · driver · monitor · scoreboard · coverage)에서 Directed 26개 + Random 90,000개 명령을 독립 참조 모델과 비교',
      'CPU ↔ Data Memory 사이에 APB Requester/Completer를 두고 GPIO · FND를 메모리 맵(0x2000_0000~)으로 연결',
    ],
    result: [
      'UVM 검증 중 SLL/SRL/SRA가 rs2 전체를 이동량으로 쓰는 버그 발견 → rs2[4:0]로 수정 후 FAIL 4,072건 → 0건',
      '총 90,170개 명령 PASS, Functional Coverage 99.56% (미달 조합 3개를 찾아 보강 계획 수립)',
      'Basys3 FPGA에서 ILA로 APB 트랜잭션을 관찰하며 스위치 → LED/FND 출력 동작 확인',
    ],
    images: [
      { src: '/projects/rv32i-apb-block.png', caption: 'RV32I CPU + APB 버스 · 주변장치 블록 다이어그램' },
      { src: '/projects/rv32i-uvm-result.png', caption: 'UVM 결과: 90,170개 명령 PASS, Coverage 99.56%' },
    ],
  },
  {
    title: 'FIFO UVM 테스트벤치',
    period: '2026.09',
    team: '개인',
    summary: '동기식 FIFO를 DUT로 UVM 테스트벤치를 구축하고 랜덤 push/pop으로 자동 검증',
    stack: ['SystemVerilog', 'UVM'],
    problem:
      'initial 블록에 신호를 직접 넣는 테스트벤치로는 다양한 입력 조합과 full/empty 경계 상황을 충분히 검사하기 어려웠습니다.',
    approach: [
      'Sequence가 트랜잭션을 만들고 Driver가 DUT를 구동, Monitor가 관찰해 Scoreboard가 기대값과 비교하는 구조',
      'Reset → Push 5 → Pop 5 → 랜덤 Push/Pop 10,000회 시나리오',
      'full/empty 상태가 설계 의도대로 동작하는지 coverage로 확인',
    ],
    result: [
      'Scoreboard 비교 5,355건 중 불일치 0건',
      'push · pop · full · empty 및 교차(cross) 커버리지 포함 Functional Coverage 100%',
      '다른 테스트벤치에서도 재사용 가능한 컴포넌트 구조 확보',
    ],
    images: [{ src: '/projects/fifo-uvm-result.png', caption: 'Coverage 100% · Scoreboard 불일치 0건' }],
  },
  {
    title: 'UART 기반 센서 통신 시스템 (DHT11 · SR04)',
    period: '2026.08',
    team: '2인 팀',
    role: 'Top module 설계(UART · FIFO · 명령 파서 통합), 발표 자료 제작',
    summary: 'PC에서 /get_temp 같은 명령을 보내면 온습도·거리 센서 측정값을 UART와 7-segment로 출력',
    stack: ['Verilog', 'UART', 'FIFO', 'Basys3'],
    problem:
      '비동기로 들어오는 센서 신호와 UART 문자열 명령을 하나의 시스템에서 안정적으로 처리해야 했습니다.',
    approach: [
      '9600 baud의 16배 오버샘플링 tick으로 UART RX 글리치 방지',
      'RX → FIFO → ASCII 디코더 → 명령 파서 → 센서 측정 → 문자열 생성 → UART TX 파이프라인 구성',
      '갱신 중 표시값이 흔들리지 않도록 raw 레지스터에 쓰고 갱신 완료 후 반영',
      '16바이트 FIFO에 push/pop 17회를 넣어 full/empty 경계 동작 검증',
    ],
    result: [
      'DHT11 값이 2배씩 튀는 노이즈를 비트 밀림으로 분석 → edge detector 추가로 해결',
      '시뮬레이션의 이상 상태 천이를 echo 하강과 clk 상승이 겹치는 race condition으로 진단해 테스트벤치 수정',
      '비동기 입력에 synchronizer가 왜 필요한지 실제로 체감',
    ],
    images: [{ src: '/projects/sensor-block.png', caption: 'UART · 센서 · Stopwatch 통합 블록 다이어그램' }],
  },
  {
    title: 'UART 제어 Stopwatch / Watch',
    period: '2026.08',
    team: '개인',
    summary: 'Basys3 보드의 스톱워치·시계를 PC에서 UART 문자(r, s, c, L, R, U, D 등)로 제어',
    stack: ['Verilog', 'UART', 'FSM', 'Basys3'],
    problem: '버튼으로만 조작하던 스톱워치를 PC에서도 원격 제어할 수 있도록 확장해야 했습니다.',
    approach: [
      '100MHz 클럭으로 9600 baud ×16 tick 생성, IDLE/START/DATA/STOP FSM으로 RX/TX 구현',
      'ASCII 코드를 제어 신호로 바꾸는 디코더를 만들고 기존 버튼 신호와 OR로 합침',
      'run/stop 토글 구조가 UART 명령과 맞지 않아 별도 경로로 분리',
    ],
    result: [
      '12개 시나리오 시뮬레이션 및 보드 동작 확인',
      'UART 제어 대상은 토글 방식보다 명시적 상태 명령이 낫다는 설계 교훈 정리',
    ],
    video: 'https://youtu.be/lRf44Yrbjak',
  },
];

// 작은 과제들. 한 줄씩 짧게 보여줍니다.
export const coursework: { title: string; date: string }[] = [
  { title: '8bit Full Adder 구현', date: '2026.07' },
  { title: '8bit Adder + 7-segment 표시', date: '2026.07' },
  { title: 'Clock Divider 설계', date: '2026.07' },
  { title: '0~9999 카운터 설계', date: '2026.07' },
  { title: '5-state FSM 구현 및 검증', date: '2026.07' },
  { title: '카운터 + Control Unit 설계 및 시뮬레이션', date: '2026.07' },
  { title: '3-button Debounce 회로', date: '2026.07' },
  { title: 'UART TX 시뮬레이션', date: '2026.08' },
  { title: 'UART + FIFO Loopback', date: '2026.08' },
  { title: 'FSM 기반 범용 CPU로 1~10 누적합 계산', date: '2026.09' },
  { title: 'RV32I R/S 타입 명령어 구현', date: '2026.09' },
  { title: 'MLP · CNN 분류 모델 실습 (Keras)', date: '2026.09' },
];

export const experience: {
  company: string;
  role: string;
  period: string;
  details: string[];
}[] = [
  {
    company: 'AI 캠퍼스 반도체설계 1기',
    role: '교육 과정',
    period: '2026.07 – 현재',
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
      '영국 출장: 장비 사용법·유지보수·셀링 포인트 교육 (2025.06)',
    ],
  },
  {
    company: '전남대학교',
    role: '전자컴퓨터공학부 전자정보통신공학전공 학사',
    period: '2019.03 – 2023.02',
    details: [],
  },
];

export const certs: { title: string; date: string }[] = [
  { title: 'OPIc IH', date: '2024.09' },
  { title: '통계적 공정관리 전문가', date: '2024.04' },
];
