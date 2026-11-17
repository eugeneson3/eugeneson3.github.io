/*
 * dcmotor.c
 *
 *  Created on: 2026. 11. 11.
 *      Author: kccistc
 */
#include "dcmotor.h"

static uint16_t motor_speed = 0;

void motor_init(motor_t *motor, TIM_HandleTypeDef *htim,
		uint32_t Ch,
		GPIO_TypeDef* GPIO1, uint16_t GPIO1_Pin,
		GPIO_TypeDef* GPIO2, uint16_t GPIO2_Pin)
{
	motor->htim = htim;
	motor->Ch= Ch;
	motor->GPIO1 = GPIO1;
	motor->GPIO1_Pin= GPIO1_Pin;
	motor->GPIO2 = GPIO2;
	motor->GPIO2_Pin= GPIO2_Pin;
}

void motor_set_speed(uint16_t speed)
{
	if (speed>999) 		speed = 999;
	else if (speed<1) 	speed = 1;
	motor_speed = speed;
}
void car_Stop(motor_t *motor_left, motor_t *motor_right)
{

	HAL_TIM_PWM_Stop(motor_left->htim,motor_left->Ch);
	HAL_TIM_PWM_Stop(motor_right->htim,motor_right->Ch);
}
void car_goForward(motor_t *motor_left, motor_t *motor_right)
{

	HAL_TIM_PWM_Start(motor_left->htim,motor_left->Ch);
	HAL_TIM_PWM_Start(motor_right->htim,motor_right->Ch);

	//left
	__HAL_TIM_SET_COMPARE(motor_left->htim,motor_left->Ch,motor_speed-1);
	HAL_GPIO_WritePin(motor_left->GPIO1, motor_left->GPIO1_Pin, GPIO_PIN_SET);
	HAL_GPIO_WritePin(motor_left->GPIO2, motor_left->GPIO2_Pin, GPIO_PIN_RESET);

	__HAL_TIM_SET_COMPARE(motor_right->htim,motor_right->Ch,motor_speed-1);
	HAL_GPIO_WritePin(motor_right->GPIO1, motor_right->GPIO1_Pin, GPIO_PIN_SET);
	HAL_GPIO_WritePin(motor_right->GPIO2, motor_right->GPIO2_Pin, GPIO_PIN_RESET);

}
void car_goBackward(motor_t *motor_left, motor_t *motor_right)
{
	HAL_TIM_PWM_Start(motor_left->htim,motor_left->Ch);
	HAL_TIM_PWM_Start(motor_right->htim,motor_right->Ch);

	//left
	__HAL_TIM_SET_COMPARE(motor_left->htim,motor_left->Ch,motor_speed-1);
	HAL_GPIO_WritePin(motor_left->GPIO1, motor_left->GPIO1_Pin, GPIO_PIN_RESET);
	HAL_GPIO_WritePin(motor_left->GPIO2, motor_left->GPIO2_Pin, GPIO_PIN_SET);
	//right
	__HAL_TIM_SET_COMPARE(motor_right->htim,motor_right->Ch,motor_speed-1);
	HAL_GPIO_WritePin(motor_right->GPIO1, motor_right->GPIO1_Pin, GPIO_PIN_RESET);
	HAL_GPIO_WritePin(motor_right->GPIO2, motor_right->GPIO2_Pin, GPIO_PIN_SET);
}
void car_goLeft(motor_t *motor_left, motor_t *motor_right)
{
	HAL_TIM_PWM_Start(motor_left->htim,motor_left->Ch);
	HAL_TIM_PWM_Start(motor_right->htim,motor_right->Ch);

	//left
	__HAL_TIM_SET_COMPARE(motor_left->htim,motor_left->Ch,motor_speed-1);
	HAL_GPIO_WritePin(motor_left->GPIO1, motor_left->GPIO1_Pin, GPIO_PIN_RESET);
	HAL_GPIO_WritePin(motor_left->GPIO2, motor_left->GPIO2_Pin, GPIO_PIN_SET);
	//right
	__HAL_TIM_SET_COMPARE(motor_right->htim,motor_right->Ch,motor_speed-1);
	HAL_GPIO_WritePin(motor_right->GPIO1, motor_right->GPIO1_Pin, GPIO_PIN_SET);
	HAL_GPIO_WritePin(motor_right->GPIO2, motor_right->GPIO2_Pin, GPIO_PIN_RESET);
}
void car_goRight(motor_t *motor_left, motor_t *motor_right)
{
	HAL_TIM_PWM_Start(motor_left->htim,motor_left->Ch);
	HAL_TIM_PWM_Start(motor_right->htim,motor_right->Ch);

	//left
	__HAL_TIM_SET_COMPARE(motor_left->htim,motor_left->Ch,motor_speed-1);
	HAL_GPIO_WritePin(motor_left->GPIO1, motor_left->GPIO1_Pin, GPIO_PIN_SET);
	HAL_GPIO_WritePin(motor_left->GPIO2, motor_left->GPIO2_Pin, GPIO_PIN_RESET);
	//right
	__HAL_TIM_SET_COMPARE(motor_right->htim,motor_right->Ch,motor_speed-1);
	HAL_GPIO_WritePin(motor_right->GPIO1, motor_right->GPIO1_Pin, GPIO_PIN_RESET);
	HAL_GPIO_WritePin(motor_right->GPIO2, motor_right->GPIO2_Pin, GPIO_PIN_SET);
}
