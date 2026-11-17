/*
 * dcmotor.h
 *
 *  Created on: 2026. 11. 11.
 *      Author: kccistc
 */
#include "stm32f4xx_hal.h"

#ifndef SRC_DRIVER_DC_MOTOR_DCMOTOR_H_
#define SRC_DRIVER_DC_MOTOR_DCMOTOR_H_

typedef struct {
	TIM_HandleTypeDef *htim;
	uint32_t Ch; // stands for Channel
	GPIO_TypeDef* GPIO1;
	uint16_t GPIO1_Pin;
	GPIO_TypeDef* GPIO2;
	uint16_t GPIO2_Pin;
}motor_t;

void motor_init(motor_t *motor, TIM_HandleTypeDef *htim,
		uint32_t Ch,
		GPIO_TypeDef* GPIO1, uint16_t GPIO1_Pin,
		GPIO_TypeDef* GPIO2, uint16_t GPIO2_Pin);
void motor_set_speed(uint16_t speed);

void car_Stop(motor_t *motor_left, motor_t *motor_right);
void car_goForward(motor_t *motor_left, motor_t *motor_right);
void car_goBackward(motor_t *motor_left, motor_t *motor_right);

void car_goLeft(motor_t *motor_left, motor_t *motor_right);
void car_goRight(motor_t *motor_left, motor_t *motor_right);

#endif /* SRC_DRIVER_DC_MOTOR_DCMOTOR_H_ */
