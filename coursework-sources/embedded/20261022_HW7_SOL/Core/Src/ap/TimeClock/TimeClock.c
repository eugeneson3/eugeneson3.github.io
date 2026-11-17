/*
 * TimeClock.c
 *
 *  Created on: 2026. 10. 19.
 *      Author: rhoblack
 */
#include "TimeClock.h"
#include "../../driver/fnd/fnd.h"



static TimeClock_t timeClockData; // 중심 데이터
static ds_time_t rtc_time;
static ds_date_t rtc_date;

void TimeClock_init(void)
{
	timeClockData.hour = 0;
	timeClockData.min = 0;
	timeClockData.sec = 0;
	timeClockData.msec = 0;
}

TimeClock_t *TimeClock_getTimeData(void)
{
	return &timeClockData;
}

ds_time_t *TimeClock_getRtcTime(void)
{
	return &rtc_time;
}

ds_date_t *TimeClock_getRtcDate(void)
{
	return &rtc_date;
}

static void TimeClock_incMSec(void)
{
	if (timeClockData.msec < 99) {
		timeClockData.msec++;
		return;
	}
	timeClockData.msec = 0;
	if (timeClockData.sec < 59) {
		timeClockData.sec++;
		return;
	}
	timeClockData.sec = 0;
	if (timeClockData.min < 59) {
		timeClockData.min++;
		return;
	}
	timeClockData.min = 0;
	if (timeClockData.hour < 23) {
		timeClockData.hour++;
		return;
	}
	timeClockData.hour = 0;
}

//static void TimeClock_dispTime(void)
//{
//	uint16_t num;
//
//	num = (timeClockData.min * 100) + timeClockData.sec;
//	fnd_set_num(num);
//
//	if (timeClockData.msec < 50) {
//		fnd_set_dp(FND_DIGIT_2, FND_DP_ON);
//	}
//	else {
//		fnd_set_dp(FND_DIGIT_2, FND_DP_OFF);
//	}
//}

void TimeClock_ISR(void)
{
	TimeClock_incMSec();
}

void TimeClock_task(void)
{
	static uint8_t prevSec = 0xFF;   // 첫 호출에서 반드시 읽도록 범위 밖 값으로 시작
	static uint8_t prevHour = 0xFF;

	if (timeClockData.sec == prevSec) {
		return;
	}
	prevSec = timeClockData.sec;
	ds_getTime(&rtc_time);           // 1초에 한 번 시간 읽기

	if (rtc_time.hour == prevHour) {
		return;
	}
	prevHour = rtc_time.hour;
	ds_getDate(&rtc_date);           // 시가 바뀔 때만 날짜 읽기
}









