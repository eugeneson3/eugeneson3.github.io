/*
 * watch.h
 *
 *  Created on: 2026. 11. 2.
 *      Author: kccistc
 */

#ifndef SRC_AP_SERVICE_WATCH_WATCH_H_
#define SRC_AP_SERVICE_WATCH_WATCH_H_
#include "../../../driver/ds3231/ds3231.h"

void watch_task(void);

ds_date_t *watch_getDate(void);

ds_time_t *watch_getTime(void);
ds_datetime_t *watch_getDateTime(void);
#endif /* SRC_AP_SERVICE_WATCH_WATCH_H_ */
