/*
 * stopwatch.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: kccistc
 */

#include "stopwatch.h"
#include "../../driver/button/button.h"
#include "../../driver/led/led.h"
#include "../../driver/fnd/fnd.h"


typedef enum {STOP, RUN, CLEAR} stopwatch_t;

static void stopwatch_stop();
static void stopwatch_run();
static void stopwatch_clear();

static void stopwatch_set_state(stopwatch_t s);
static stopwatch_t stopwatch_get_state(void);
static void stopwatch_inc_counter(void);
static void stopwatch_clear_counter(void);
static void stopwatch_set_counter(uint16_t c);
static uint16_t stopwatch_get_counter(void);



static stopwatch_t stopwatch_state;
static uint16_t counter;
static uint32_t prevTime;

extern led_t led_run;
extern led_t led_stop;
extern led_t led_watch;
extern led_t led_stopwatch;

extern button_t btn_run_stop;
extern button_t btn_clear;

void Stopwatch_Init(void){
	stopwatch_state = STOP;
	stopwatch_set_state(STOP);
}

static void stopwatch_set_state(stopwatch_t s){
	stopwatch_state = s;
	if (s == RUN) {
		prevTime = HAL_GetTick();
		led_off(&led_stop);
		led_on(&led_run);
	} else {
		led_off(&led_run);
		led_on(&led_stop);
	}
}

static stopwatch_t stopwatch_get_state(void){
	return stopwatch_state;
}

static void stopwatch_inc_counter(void){
	counter++;
}
static void stopwatch_clear_counter(void){
	counter = 0;
}
static void stopwatch_set_counter(uint16_t c){
	counter = c;
}
static uint16_t stopwatch_get_counter(void){
	return counter;
}


void Stopwatch_Task(uint8_t is_stopwatch){

	switch(stopwatch_state){
	case STOP:
		stopwatch_stop();
		break;

	case RUN:
		stopwatch_run();
		break;

	case CLEAR:
		stopwatch_clear();
		break;

	default:
		stopwatch_stop();
		break;
	}
	if (is_stopwatch == 1){
		fnd_set_num(stopwatch_get_counter());
		led_on(&led_stopwatch);
		led_off(&led_watch);

	}
}

static void stopwatch_stop(){
	if(button_getState(&btn_run_stop) == ACT_PUSH){
		stopwatch_set_state(RUN);
	}
	else if (button_getState(&btn_clear)== ACT_RELEASE){
		stopwatch_set_state(CLEAR);
	}
}
static void stopwatch_run(){
	if(button_getState(&btn_run_stop) == ACT_PUSH){
		stopwatch_set_state(STOP);
		return;
	}
	uint32_t curTime = HAL_GetTick();
	uint16_t num = stopwatch_get_counter();
	if(curTime - prevTime < 100U){
		return;
	}
	prevTime = curTime;

	if(num >= 9999) {
		stopwatch_clear_counter();
	}
	else{
		stopwatch_inc_counter();
	}


}
static void stopwatch_clear(){
	stopwatch_clear_counter();
	stopwatch_set_state(STOP);

}
