# 디지털 설계 및 검증 과제

Classroom 제출 기록, 발표 자료 및 로컬 소스를 기준으로 구성하였습니다.

[포트폴리오 과제 목록](https://eugeneson3.github.io/coursework/)

| 시기 | 과제 | 소스 |
| --- | --- | --- |
| 2026.09.08 | [RV32I B형 명령어 확장](docs/rv32-b.md) | [소스](labs/2026_09_08_rv32i_btype) |
| 2026.09.04 | [RV32I R형 명령어](docs/rv32-r.md) | [소스](labs/2026_09_04_HW15_rv32i) |
| 2026.09.04 | [RV32I R·S형 시뮬레이션](docs/rv32-rs.md) | [소스](labs/2026_09_04_HW15_rv32i) |
| 2026.09.04 | [RV32I I형 명령어 확장](docs/rv32-i.md) | [소스](labs/2026_09_04_I_type_instruction) |
| 2026.09.02 | [범용 CPU 누적합](docs/rtl-generic-cpu.md) | 발표 자료 수록 |
| 2026.09.01 | [누적합 Datapath·FSM](docs/rtl-sum.md) | 발표 자료 수록 |
| 2026.08.28 | [Counter UVM 실습](docs/uvm-counter.md) | [소스](labs/2026_08_28_counter_uvm) |
| 2026.08.24 | [Adder UVM 실습](docs/uvm-adder.md) | [소스](labs/2026_08_24_adder_UVM) |
| 2026.08.19 | [SystemVerilog 구동·관측 타이밍](docs/sv-timing.md) | [소스](Sources/exercises/register_systemverilog) |
| 2026.08.19 | [fork·join 실행 순서](docs/sv-fork.md) | 발표 자료 수록 |
| 2026.08.11 | [UART·FIFO Loopback](docs/hdl-loopback.md) | [소스](Sources/projects/uart_fifo_loopback) |
| 2026.08.10 | [FIFO 설계](docs/hdl-fifo.md) | [소스](Sources/projects/fifo_basic) |
| 2026.08.07 | [UART TX 시뮬레이션](docs/hdl-uart.md) | [소스](Sources/projects/uart_basic) |
| 2026.07.28 | [0101 패턴 검출기](docs/hdl-detector.md) | [소스](Sources/exercises/detector_0101) |
| 2026.07.28 | [3-button Debounce](docs/hdl-debounce.md) | 발표 자료 수록 |
| 2026.07.25 | [카운터·Control Unit](docs/hdl-counter-control.md) | [소스](Sources/projects/stopwatch_only) |
| 2026.07.23 | [5-state FSM](docs/hdl-fsm.md) | 발표 자료 수록 |
| 2026.07.22 | [10000진 카운터](docs/hdl-counter.md) | [소스](Sources/exercises/counter_10000) |
| 2026.07.21 | [8bit Adder·7-segment 표시](docs/hdl-adder-fnd.md) | [소스](Sources/exercises/adder_fnd_v1) |
| 2026.07.21 | [Clock Divider](docs/hdl-clock.md) | 발표 자료 수록 |
| 2026.07.16 | [8bit Full Adder](docs/hdl-adder.md) | [소스](Sources/exercises/adder_verilog) |

## 실행 환경

각 과제는 독립된 프로젝트입니다.

Sources/manifests의 파일 목록은 원래 작업 폴더 기준입니다. 현재 저장소 루트의 Sources/ 경로에 대응시켜 사용합니다. Vivado에서 해당 RTL·테스트벤치·XDC를 추가합니다. labs/의 SystemVerilog 및 UVM 과제는 각 폴더의 files.f와 UVM 라이브러리 설정을 확인하여 실행합니다.

## 소스 이력

2026년 11월 18일 로컬 소스 스냅샷입니다. [SOURCE_MANIFEST.json](SOURCE_MANIFEST.json)에 원본 상대 경로 및 SHA-256을 기록하였습니다. 공급업체 소스의 기존 저작권 고지를 유지하였습니다.
