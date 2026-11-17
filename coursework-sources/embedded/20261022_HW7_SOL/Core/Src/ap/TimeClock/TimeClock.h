/*
 * TimeClock.h
 *
 *  Created on: 2026. 10. 19.
 *      Author: rhoblack
 */

#ifndef SRC_AP_TIMECLOCK_TIMECLOCK_H_
#define SRC_AP_TIMECLOCK_TIMECLOCK_H_
#include "stm32f4xx_hal.h"
#include "../../driver/ds3231/ds3231.h"

typedef struct {
	uint8_t hour;
	uint8_t min;
	uint8_t sec;
	uint8_t msec;
} TimeClock_t;


void TimeClock_init(void);
TimeClock_t *TimeClock_getTimeData(void);
ds_time_t *TimeClock_getRtcTime(void);
ds_date_t *TimeClock_getRtcDate(void);
void TimeClock_ISR(void);
void TimeClock_task(void);

#endif /* SRC_AP_TIMECLOCK_TIMECLOCK_H_ */
