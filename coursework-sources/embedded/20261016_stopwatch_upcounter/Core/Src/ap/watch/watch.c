/*
 * watch.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: kccistc
 */
#include "watch.h"
#include "../../driver/fnd/fnd.h"
#include "../../driver/led/led.h"

extern volatile uint32_t time;

extern led_t led_watch;
extern led_t led_stopwatch;

uint16_t watch_time;
void Watch_Task(uint8_t is_stopwatch){
	uint32_t t = time;
	uint8_t fnd_hr = t/3600;
	uint8_t fnd_min = t%3600/60;
	uint8_t fnd_sec = t%60;


	if(is_stopwatch == 0){
		watch_time = fnd_min*100+fnd_sec;
		fnd_set_num(watch_time);
		led_on(&led_watch);
		led_off(&led_stopwatch);
	}

}

