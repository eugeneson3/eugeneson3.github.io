/*
 * motor_control_task.c
 *
 *  Created on: 2026. 11. 12.
 *      Author: kccistc
 */
#include "motor_control_task.h"
#include "../../../driver/DC_Motor/dcmotor.h"
#include "../../message.h"

extern TIM_HandleTypeDef htim3;



static motor_t motor_L, motor_R;
typedef enum {STOP,RUN,LEFT,RIGHT} motor_state_t;
static motor_state_t motor_state = STOP;

static btn_status_t btn_status = BTN_NO;

void motor_control_task_init()
{
	motor_init(&motor_L, &htim3, TIM_CHANNEL_1, GPIOB, GPIO_PIN_6, GPIOA, GPIO_PIN_7);
	motor_init(&motor_R, &htim3, TIM_CHANNEL_3, GPIOA, GPIO_PIN_6, GPIOA, GPIO_PIN_5);
	motor_set_speed(900);
}
void motor_control_task()
{
	osEvent evt;
	evt = osMessageGet(btnQueHandle, 100);
	if(evt.status == osEventMessage)
	{
		btn_status = evt.value.v;
	}
	else
	{
		btn_status = BTN_NO;
	}
	switch(motor_state)
	{
	case STOP:
		if(btn_status == BTN_RUN_STOP){
			motor_state = RUN;
		}
		else if(btn_status == BTN_LEFT){
			motor_state = LEFT;
		}
		else if(btn_status == BTN_RIGHT){
			motor_state = RIGHT;
		}
		car_Stop(&motor_L, &motor_R);
		break;
	case RUN:
		if(btn_status == BTN_RUN_STOP){
			motor_state = STOP;
		}
		else if(btn_status == BTN_LEFT){
			motor_state = LEFT;
		}
		else if(btn_status == BTN_RIGHT){
			motor_state = RIGHT;
		}
		car_goForward(&motor_L, &motor_R);
		break;
	case LEFT:
		if(btn_status == BTN_RUN_STOP){
			motor_state = STOP;
		}
		else if(btn_status == BTN_LEFT){
			motor_state = LEFT;
		}
		else if(btn_status == BTN_RIGHT){
			motor_state = RIGHT;
		}
		car_goLeft(&motor_L, &motor_R);
		break;
	case RIGHT:
		if(btn_status == BTN_RUN_STOP){
			motor_state = STOP;
		}
		else if(btn_status == BTN_LEFT){
			motor_state = LEFT;
		}
		else if(btn_status == BTN_RIGHT){
			motor_state = RIGHT;
		}
		car_goRight(&motor_L, &motor_R);
		break;
	default:
		car_Stop(&motor_L, &motor_R);
		break;
	}
}
