/*
 * ap_main.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: kccistc
 */
#include "ap_main.h"
#include "stopwatch/stopwatch.h"
#include "watch/watch.h"
#include "../driver/button/button.h"
#include "../driver/led/led.h"
#include "../driver/fnd/fnd.h"

static uint8_t flag = 0;
static uint8_t is_stopwatch = 0;

led_t led_watch;
led_t led_stopwatch;
led_t led_run;
led_t led_stop;

button_t btn_toggle;
button_t btn_run_stop;
button_t btn_clear;

extern TIM_HandleTypeDef htim3;

uint16_t tick_dot = 0;
uint16_t tick_time;
volatile uint32_t time = 0;


void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
	if(htim->Instance == TIM3){
		fnd_show_number(flag);

		if (tick_dot == 500 - 1){
			tick_dot = 0;
			flag = !flag;
		}
		else {
			tick_dot ++;
		}
		if (tick_time == 1000 - 1){
			time++;
			tick_time = 0;
		}
		else {
			tick_time++;
		}
		if(time == 86400){
			time = 0;
		}


	}// if clause end
}// void statement end

void GPIO_Init(void){
	HAL_TIM_Base_Start_IT(&htim3);
	led_init(&led_watch, GPIOB, GPIO_PIN_15);
	led_init(&led_stopwatch, GPIOB, GPIO_PIN_14);
	led_init(&led_stop, GPIOB, GPIO_PIN_13);
	led_init(&led_run, GPIOC, GPIO_PIN_4);

	button_init(&btn_toggle, GPIOC, GPIO_PIN_0);
	button_init(&btn_run_stop, GPIOC, GPIO_PIN_1);
	button_init(&btn_clear, GPIOC, GPIO_PIN_3);
}

int ap_main(void){

	GPIO_Init();
	Stopwatch_Init();

	while(1){
		Stopwatch_Task(is_stopwatch);
		Watch_Task(is_stopwatch);
		if(button_getState(&btn_toggle) == ACT_PUSH){
			is_stopwatch = !is_stopwatch;
		}

	}
	return 0;
}
