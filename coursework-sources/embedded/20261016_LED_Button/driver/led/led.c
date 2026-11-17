/*
 * led.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: kccistc
 */
#include "led.h"

//typedef struct{
//	GPIO_TypeDef* GPIOx;
//	uint16_t GPIO_Pin;
//}led_t;

void led_on(const led_t *led){
	HAL_GPIO_WritePin(led->GPIOx, led->GPIO_Pin, SET);
}
void led_off(const led_t *led){
	HAL_GPIO_WritePin(led->GPIOx, led->GPIO_Pin, RESET);
}
void led_toggle(const led_t *led){
	HAL_GPIO_TogglePin(led->GPIOx, led->GPIO_Pin);
}
