/*
 * Display.c
 *
 *  Created on: 2026. 10. 20.
 *      Author: rhoblack
 */

#include "Display.h"
#include "../../driver/fnd/fnd.h"
#include "../../driver/led/led.h"
#include "../../driver/lcd/lcd.h"
#include "../../driver/ds3231/ds3231.h"
#include "../TimeClock/TimeClock.h"
#include <stdio.h>
#include <stdarg.h>
#include <string.h>


enum {TIMECLOCK_MODE, STOPWATCH_MODE};
enum {STOPWATCH_RUN, STOPWATCH_STOP};
const char *dayName[] = {"MON", "TUE", "WED", "THR", "FRI", "SAT", "SUN"};


stopWatchTime_t *pStopWatchTime;
timeClockTime_t *pTimeClockTime;
led_t ledTimeClock, ledStopWatch;
led_t ledStopWatchRun, ledStopWatchStop;
static ds_datetime_t get_dt;
//static ds_datetime_t set_dt = {
//		  .date = {.year = 26, .month = 10, .date = 22, .day = 4},
//		  .time = {.hour = 15, .min = 4, .sec = 0}
//};
void Disp_init(void)
{
	Lcd_init();
	led_init(&ledTimeClock, GPIOB, GPIO_PIN_15);
	led_init(&ledStopWatch, GPIOB, GPIO_PIN_14);
	led_init(&ledStopWatchRun, GPIOC, GPIO_PIN_4);
	led_init(&ledStopWatchStop, GPIOB, GPIO_PIN_13);
}

void Disp_setMode(int mode)
{
	if (mode == TIMECLOCK_MODE){
		led_on(&ledTimeClock);
		led_off(&ledStopWatch);
	}
	else {
		led_off(&ledTimeClock);
		led_on(&ledStopWatch);
	}
}

void Disp_setTimeClockTime(timeClockTime_t * pTime)
{
	pTimeClockTime = pTime;
	Disp_timeClockTime();
}


void Disp_setStopWatchTime(stopWatchTime_t *pTime)
{
	pStopWatchTime = pTime;
	Disp_stopWatchTime();
}

static char prevLine[2][30];   // 줄별로 마지막에 LCD에 쓴 문자열
static uint8_t swForce = 1;    // 스톱워치 모드 진입 직후 즉시 한 번 쓰기

// 이전과 문자열이 다를 때만 I2C로 쓴다
static void Disp_lcdLine(uint8_t row, const char *str)
{
	if (strcmp(prevLine[row], str) == 0) {
		return;
	}
	strcpy(prevLine[row], str);
	Lcd_writeStringXY(row, 0, (char *)str);
}

static void Disp_rtc(void)
{
	char buff[30];
	get_dt.time = *TimeClock_getRtcTime();
	get_dt.date = *TimeClock_getRtcDate();
	sprintf(buff, "TIME:%02d:%02d:%02d", get_dt.time.hour, get_dt.time.min, get_dt.time.sec);
	Disp_lcdLine(0, buff);
}

void Disp_2ndRow(const char *fmt, ...)
{
	char buff[30];
	va_list args;

	va_start(args, fmt);
	vsnprintf(buff, sizeof(buff), fmt, args);
	va_end(args);

	Disp_lcdLine(1, buff);             // 아랫줄만 출력하는 용도
}
void Disp_stopWatchTime(void)
{
	uint16_t num;
	num = ((pStopWatchTime->min % 10) * 1000) + (pStopWatchTime->sec * 10) + (pStopWatchTime->msec / 10 % 10);
	fnd_set_num(num);

	if (pStopWatchTime->msec < 50) {
		fnd_set_dp(FND_DIGIT_3, FND_DP_ON);
	}
	else {
		fnd_set_dp(FND_DIGIT_3, FND_DP_OFF);
	}

	fnd_set_dp(FND_DIGIT_1, FND_DP_ON);
	fnd_set_dp(FND_DIGIT_2, FND_DP_OFF);
	uint8_t lcd_hour = pStopWatchTime->hour;
	uint8_t lcd_min = pStopWatchTime->min;
	uint8_t lcd_sec = pStopWatchTime->sec;
	uint8_t lcd_msec = pStopWatchTime->msec;
	Disp_rtc();

	static uint32_t lastTick = 0;
	if (swForce || (HAL_GetTick() - lastTick >= 55)) {
		lastTick = HAL_GetTick();
		swForce = 0;
		Disp_2ndRow("STOP:%02d:%02d:%02d:%02d",lcd_hour,lcd_min,lcd_sec,lcd_msec);
	}

}

void Disp_timeClockTime(void)
{
	uint16_t num;
	num = (pTimeClockTime->min * 100) + pTimeClockTime->sec;
	fnd_set_num(num);

	if (pTimeClockTime->msec < 50) {
		fnd_set_dp(FND_DIGIT_2, FND_DP_ON);
	}
	else {
		fnd_set_dp(FND_DIGIT_2, FND_DP_OFF);
	}
	fnd_set_dp(FND_DIGIT_1, FND_DP_OFF);
	fnd_set_dp(FND_DIGIT_3, FND_DP_OFF);
	swForce = 1;   // 다음에 스톱워치 모드로 들어오면 즉시 갱신
	Disp_rtc();
	Disp_2ndRow("20%02d.%02d.%02d. %s ",get_dt.date.year,get_dt.date.month,get_dt.date.date,
			(get_dt.date.day >= 1 && get_dt.date.day <= 7) ? dayName[get_dt.date.day-1] : "---");
}


void Disp_setStopWatchState(int state)
{
	if (state == STOPWATCH_RUN){
		led_on(&ledStopWatchRun);
		led_off(&ledStopWatchStop);
	}
	else {
		led_off(&ledStopWatchRun);
		led_on(&ledStopWatchStop);
	}
}


void Disp_ISR(void)
{
	fnd_show_number();
}
















