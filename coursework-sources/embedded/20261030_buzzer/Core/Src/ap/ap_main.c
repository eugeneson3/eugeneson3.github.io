/*
 * ap_main.c
 *
 *  Created on: 2026. 10. 30.
 *      Author: kccistc
 */

#include "ap_main.h"
#include "service/sound/sound.h"
#include "../driver/button/button.h"
#include "../driver/lcd/lcd.h"
#include <stdio.h>

extern I2C_HandleTypeDef hi2c1;

#define btn_1_GPIO GPIOC
#define btn_1_Pin GPIO_PIN_0
#define btn_2_GPIO GPIOC
#define btn_2_Pin GPIO_PIN_1
#define btn_3_GPIO GPIOC
#define btn_3_Pin GPIO_PIN_3


int ap_main(void)
{
	button_t btn_1;
	button_t btn_2;
	button_t btn_3;
	button_init(&btn_1, btn_1_GPIO, btn_1_Pin);
	button_init(&btn_2, btn_2_GPIO, btn_2_Pin);
	button_init(&btn_3, btn_3_GPIO, btn_3_Pin);
	sound_init();
	lcd_init();
	char buff[30];
	sprintf(buff,"power on");
	lcd_writeStringXY(0, 0, buff);
	playPowerSound();
	uint8_t state = 0;
	uint32_t counter = 0;
	while(1)
	{
		if(button_getState(&btn_1) == ACT_RELEASE)
		{
			playPowerSound();
			state = 0;
		}
		if(button_getState(&btn_2) == ACT_RELEASE)
		{
			playChirpSound();
			state = 1;
		}
		if(button_getState(&btn_3) == ACT_RELEASE)
		{
			playErrorSound();
			state = 2;
		}
		switch(state)
		{
		case 0:
			sprintf(buff,"count: %04d",counter);
			lcd_writeStringXY(1, 0, buff);
			break;

		case 1:
			sprintf(buff,"count: %04d",counter++);
			lcd_writeStringXY(1, 0, buff);
			break;

		case 2:
			counter = 0;
			sprintf(buff,"count: %04d",counter);
			lcd_writeStringXY(1, 0, buff);
			break;

		default:
			counter = 0;
			sprintf(buff,"count: %04d",counter);
			lcd_writeStringXY(1, 0, buff);
			break;

		}
	}
	return 0;
}
