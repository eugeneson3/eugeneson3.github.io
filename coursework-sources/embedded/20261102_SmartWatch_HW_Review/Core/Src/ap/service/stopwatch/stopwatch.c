/*
 * stopwatch.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: kccistc
 */

#include "stopwatch.h"
#include "../../../driver/button/button.h"
#include "../../../driver/led/led.h"
#include "../../../driver/fnd/fnd.h"


typedef struct {
	uint8_t min;
	uint8_t sec;
	uint8_t msec;	// 10ms 단위 (0~99)
} stopwatch_time_t;

static void stopwatch_stop();
static void stopwatch_run();
static void stopwatch_clear();

static void stopwatch_inc_time(stopwatch_time_t *t);
static void stopwatch_clear_time(stopwatch_time_t *t);
static uint16_t stopwatch_to_num(const stopwatch_time_t *t);


stopwatch_t stopwatch_state;
static stopwatch_time_t sw_time;
static uint16_t prevTime;
 uint16_t tick_time;	// 10ms마다 0~99 반복

extern led_t led_run;
extern led_t led_stop;
extern led_t led_watch;
extern led_t led_stopwatch;

extern button_t btn_run_stop;
extern button_t btn_clear;

void Stopwatch_Init(void){
	stopwatch_clear_time(&sw_time);
	stopwatch_set_state(STOP);
}

void stopwatch_set_state(stopwatch_t s){
	stopwatch_state = s;
	if (s == RUN) {
		prevTime = tick_time;	// STOP 동안 흐른 시간이 한꺼번에 더해지는 것 방지
//		led_off(&led_stop);
//		led_on(&led_run);
	} else {
//		led_off(&led_run);
//		led_on(&led_stop);
	}
}

static void stopwatch_inc_time(stopwatch_time_t *t){
	if(++t->msec >= 100){
		t->msec = 0;
		if(++t->sec >= 60){
			t->sec = 0;
			if(++t->min >= 100){
				t->min = 0;
			}
		}
	}
}

static void stopwatch_clear_time(stopwatch_time_t *t){
	t->min = 0;
	t->sec = 0;
	t->msec = 0;
}

// FND 4자리용 SS.cc
static uint16_t stopwatch_to_num(const stopwatch_time_t *t){
	return t->sec * 100 + t->msec;
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
//
//	if (is_stopwatch == 1){
//		fnd_set_dp(FND_DIGIT_1, FND_DP_OFF);
//		fnd_set_dp(FND_DIGIT_2, FND_DP_ON);
//		fnd_set_dp(FND_DIGIT_3, FND_DP_OFF);
//		fnd_set_dp(FND_DIGIT_4, FND_DP_OFF);
//
//		fnd_set_num(stopwatch_to_num(&sw_time));
//		led_on(&led_stopwatch);
//		led_off(&led_watch);
//	}
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

	// 지나간 10ms 틱 수만큼 증가 (HAL_Delay 등으로 놓친 틱도 따라잡음)
	uint16_t now = tick_time;
	uint16_t diff = (now + 100 - prevTime) % 100;
	prevTime = now;
	while(diff--){
		stopwatch_inc_time(&sw_time);
	}
}

static void stopwatch_clear(){
	stopwatch_clear_time(&sw_time);
	stopwatch_set_state(STOP);
}
