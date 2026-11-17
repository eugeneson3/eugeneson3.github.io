# Sources 구조

`Sources`가 HDL/XDC/IP 원본의 홈 폴더입니다. 같은 내용의 파일은 줄바꿈과 끝 공백을 정규화한 뒤 한 벌만 남겼습니다. 이름이 같아도 로직이나 포트가 다른 파일은 별도 프로젝트/변형 폴더에 보존했습니다.

## 핵심 기능 구분

| 폴더 | 기능 | 다른 버전과의 구분 |
|---|---|---|
| `projects/stopwatch_only` | 순수 stopwatch | UART, watch, sensor 없음 |
| `projects/watch_only` | 시계 단독 | stopwatch/UART/sensor 없음 |
| `projects/stopwatch_watch_basic` | 시계 + stopwatch | UART와 sensor 없음 |
| `projects/stopwatch_watch_revised` | 시계 + stopwatch 수정본 | 수정된 debounce/control/stopwatch/top만 보존하고 나머지는 basic 공유 |
| `projects/uart_basic` | UART loopback 기본 | stopwatch/sensor 없음; lecture RX 구현 포함 |
| `projects/uart_stopwatch` | UART + 시계/stopwatch | sensor 없음; UART RX와 FND/top 구현이 basic과 다름 |
| `projects/sensors_sr04_dht11` | SR04 + DHT11 센서 실습 | 시계/UART 통합 전 센서 단독 버전 |
| `projects/uart_sensor_stopwatch_current` | UART + sensor + 시계/stopwatch 현재 통합본 | `sensor_periodic_reader`가 있는 현재 top |
| `projects/uart_sensor_stopwatch_team_submission` | UART + sensor + 시계/stopwatch 팀 제출 변형 | 별도 top과 FIFO를 보존; 공통 하위 모듈은 current/basic에서 공유 |
| `projects/uart_sensor_stopwatch_minseok_prototype` | 팀 통합 전 별도 프로토타입 | 모듈명과 내부 구조가 달라 독립 보존 |
| `projects/uart_sensor_stopwatch_prototype2_variant` | 오래된 부분 통합 변형 | 고유 DHT11/FND/top만 보존; 완성 통합본으로 취급하지 않음 |
| `projects/fifo_basic` | FIFO 단독 | UART 없음 |
| `projects/uart_fifo_loopback` | UART + FIFO loopback | FIFO와 UART 구현이 단독 버전과 달라 별도 보존 |

## 폴더 규칙

- `src`: 합성 대상 HDL
- `sim`: testbench
- `constraints`: XDC
- `ip`: 직접 보존해야 하는 IP descriptor
- `shared`: 내용이 완전히 같은 파일을 여러 프로젝트가 공동 사용
- `manifests`: 프로젝트별 합성/정적 컴파일에 넣을 정확한 HDL 목록

변형 폴더에 파일이 적은 것은 누락이 아닙니다. 공통 파일을 복사하지 않고 manifest에서 canonical 파일을 참조하기 때문입니다. 예를 들어 `uart_sensor_stopwatch_team_submission`은 자체 `top_watch_stopwatch.v`와 `fifo.v`만 가지며 나머지는 current/basic 구현을 사용합니다.

## 검사

저장소 루트에서 다음 명령을 실행하면 canonical 경로, 중복, 로컬 Vivado 경로를 검사합니다.

```powershell
./tools/check_source_layout.ps1
```

대표 기능군을 Vivado Verilog compiler로 검사하려면 다음처럼 manifest를 넘깁니다.

```powershell
xvlog -f Sources/manifests/uart_sensor_stopwatch_current.f
```
