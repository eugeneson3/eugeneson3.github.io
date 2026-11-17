/*
 * display.c
 *
 *  Created on: 2026. 10. 20.
 *      Author: kccistc
 */
#include "display.h"
#include "../../driver/fnd/fnd.h"
#include "../../driver/led/led.h"

static stopWatchTime_t *pStopWatchTime;
static timeClockTime_t *pTimeClockTime;
static void Disp_StopWatchTime(void);
static void Disp_TimeClockTime(void);
enum {STOPWATCH_RUN, STOPWATCH_STOP};
enum {TIMECLOCK_MODE, STOPWATCH_MODE};
led_t ledTimeClock, ledStopWatch;
led_t ledStopWatchRun, ledStopWatchStop;

void Disp_init(void)
{
    led_init(&ledTimeClock, GPIOB, GPIO_PIN_15);
    led_init(&ledStopWatch, GPIOB, GPIO_PIN_14);
    led_init(&ledStopWatchRun, GPIOB, GPIO_PIN_13);
    led_init(&ledStopWatchStop, GPIOC, GPIO_PIN_4);
}
void Disp_ledSetMode(int mode){
	if (mode == TIME_CLOCK_MODE){
		led_on(&ledTimeClock);
		led_off(&ledStopWatch);
	}
	else{
		led_off(&ledTimeClock);
		led_on(&ledStopWatch);
	}
}

void Disp_setTimeClockTime(timeClockTime_t *pTime)
{
	pTimeClockTime = pTime;
	Disp_TimeClockTime();
}
void Disp_setStopWatchTime(stopWatchTime_t *pTime)
{
	pStopWatchTime = pTime;
	Disp_StopWatchTime();
}

// 스톱워치 시간을 FND 형식(SS.mm)으로 변환해서 출력
static void Disp_StopWatchTime(void)
{
	uint16_t num;
	num = (pStopWatchTime->min % 10 * 1000) + (pStopWatchTime->sec * 10) + (pStopWatchTime->msec / 10);

	fnd_set_num(num);
	fnd_set_dp(FND_DIGIT_1, FND_DP_ON);
	fnd_set_dp(FND_DIGIT_2, FND_DP_OFF);

	if (pStopWatchTime->msec < 50) {
		fnd_set_dp(FND_DIGIT_3, FND_DP_OFF);
	}
	else {
		fnd_set_dp(FND_DIGIT_3, FND_DP_ON);
	}
}

void Disp_setStopWatchState(int state){
	if (state == STOPWATCH_RUN){
		led_on(&ledStopWatchRun);
		led_off(&ledStopWatchStop);
	}
	else{
		led_on(&ledStopWatchStop);
		led_off(&ledStopWatchRun);
	}
}

static void Disp_TimeClockTime(void)
{
	uint16_t num;
	fnd_set_dp(FND_DIGIT_1, FND_DP_OFF);
	fnd_set_dp(FND_DIGIT_3, FND_DP_OFF);
	num = (pTimeClockTime->min * 100) + pTimeClockTime->sec;
	fnd_set_num(num);

	if (pTimeClockTime->msec < 50) {
		fnd_set_dp(FND_DIGIT_2, FND_DP_ON);
	}
	else {
		fnd_set_dp(FND_DIGIT_2, FND_DP_OFF);
	}
}
void Disp_ISR(void)
{
	fnd_show_number();
}
