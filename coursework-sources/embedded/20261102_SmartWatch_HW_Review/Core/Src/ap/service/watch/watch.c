/*
 * watch.c
 *
 *  Created on: 2026. 11. 2.
 *      Author: kccistc
 */
#include "watch.h"
#include <stdint.h>

ds_datetime_t watch_datetime;
ds_date_t watch_date;
ds_time_t watch_time;



void watch_task(void)
{

	static uint8_t prevHour = 0xFF;// 첫 호출에서 반드시 읽도록 범위 밖 값으로 시작
	ds_getTime(&watch_time);           // 1초에 한 번 시간 읽기
	if (watch_time.hour == prevHour) {
		return;
	}
	prevHour = watch_time.hour;
	ds_getDate(&watch_date);           // 시가 바뀔 때만 날짜 읽기

}

ds_date_t *watch_getDate(void)
{
	return &watch_date;
}

ds_time_t *watch_getTime(void)
{
	return &watch_time;
}

ds_datetime_t *watch_getDateTime(void)
{
	return &watch_datetime;
}
