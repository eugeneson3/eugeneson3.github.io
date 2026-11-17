/*
 * button_task.c
 *
 *  Created on: 2026. 11. 12.
 *      Author: kccistc
 */
#include "button_task.h"
#include "cmsis_os.h" //CMSIS/RTOS 함수 및 자료형 사용
#include "../../../driver/button/button.h"
#include "../../message.h"

static button_t btn_run_stop, btn_l,btn_r;

void button_task_init(void)
{
	button_init(&btn_run_stop, GPIOC,GPIO_PIN_0);
	button_init(&btn_l, GPIOC,GPIO_PIN_1);
	button_init(&btn_r, GPIOC,GPIO_PIN_2);
}

void button_task(void)
{
	if(button_getState(&btn_run_stop) == ACT_RELEASE){
		osMessagePut(btnQueHandle,BTN_RUN_STOP, 10);
	}
	else if(button_getState(&btn_l) == ACT_RELEASE){
		osMessagePut(btnQueHandle,BTN_LEFT, 10);
	}
	else if(button_getState(&btn_r) == ACT_RELEASE){
		osMessagePut(btnQueHandle,BTN_RIGHT, 10);
	}
}
