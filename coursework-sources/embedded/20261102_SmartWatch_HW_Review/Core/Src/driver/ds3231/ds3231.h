/*
 * ds3231.h
 *
 *  Created on: 2026. 10. 22.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_DS3231_DS3231_H_
#define SRC_DRIVER_DS3231_DS3231_H_

#include "stm32f4xx_hal.h"

typedef struct {
	uint8_t sec;
	uint8_t min;
	uint8_t hour;
}ds_time_t;

typedef struct {
	uint8_t day;
	uint8_t date;
	uint8_t month;
	uint8_t year;
}ds_date_t;

typedef struct {
	ds_date_t date;
	ds_time_t time;
}ds_datetime_t;

void ds_getTime(ds_time_t *t);
void ds_setTime(const ds_time_t *t);
void ds_getDate(ds_date_t *t);
void ds_setDate(const ds_date_t *t);
void ds_getTimeDate(ds_datetime_t *dt);
void ds_setTimeDate(ds_datetime_t *dt);

#endif /* SRC_DRIVER_DS3231_DS3231_H_ */
