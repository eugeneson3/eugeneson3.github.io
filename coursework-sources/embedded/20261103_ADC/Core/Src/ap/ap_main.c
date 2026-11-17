/*
 * ap_main.c
 *
 *  Created on: 2026. 11. 3.
 *      Author: kccistc
 */
#include "ap_main.h"
#include "../driver/lcd/lcd.h"
#include <stdio.h>
#include "stm32f4xx_hal.h"

extern ADC_HandleTypeDef hadc1;
extern DMA_HandleTypeDef hdma_adc1;
extern  I2C_HandleTypeDef hi2c1;
extern UART_HandleTypeDef huart2;

#define ADC_CH_COUNT 		2
volatile uint16_t value[ADC_CH_COUNT] = {0};

uint8_t adcCpltFlag = 0;
void HAL_ADC_ConvCpltCallback(ADC_HandleTypeDef *hadc)
{

		adcCpltFlag = 1; // True

}
void ap_init()
{
	char buff[30];
	Lcd_init(&hi2c1);
	HAL_ADC_Start_DMA(&hadc1, (uint32_t *)value, ADC_CH_COUNT);
	sprintf(buff,"Hello STM32!");
	Lcd_writeStringXY(0,0,buff);

}
void ap_main()
{
	ap_init();
	uint16_t vout[2];
	uint16_t pout[2];
	char buff[30];
	int count_x = 0;
	int count_y = 0;
	uint32_t prevTime = 0;


	while(1)
	{
		if(adcCpltFlag == 1)
		{
//			adcCpltFlag = 0;
		pout[0] = 100- (uint16_t)(value[0]*100/4095);
		vout[0] = (uint16_t)(value[0]*3300/4095);

		pout[1] = 100- (uint16_t)(value[1]*100/4095);
		vout[1] = (uint16_t)(value[1]*3300/4095);
		printf ("ADC vl: %04d, pl: %03d%%, voltage1: %04d, v2: %04d, p2: %03d%% , voltage2: %04d\n",
				value[0], pout[0], vout[0], value[1], pout[1], vout[1]);






		if(HAL_GetTick() - prevTime >250){
			if(value[0]<1024)
			{
				count_y = count_y + 2;
			}
			else if (value[0]<1948)
			{
				count_y = count_y + 1;
			}
			else if (value[0] < 3300 && value[0] >2230)
			{
				count_y = count_y - 1;
			}
			else if (value[0] >=3300)
			{
				count_y = count_y - 2;
			}

			if(value[1]<1024)
			{
				count_x = count_x - 2;
			}
			else if (value[1]<1948)
			{
				count_x = count_x - 1;
			}
			else if (value[1] < 3300 && value[1] >2248)
			{
				count_x = count_x + 1;
			}
			else if (value[1] >=3300)
			{
				count_x = count_x + 2;
			}
			sprintf(buff,"v2:%04d,x:%3d",value[1],count_x);
			Lcd_writeStringXY(0,0,buff);
			sprintf(buff,"v1:%04d,y:%3d",value[0],count_y);
			Lcd_writeStringXY(1,0,buff);
			prevTime = HAL_GetTick();
		}
		}

		//			HAL_ADC_Start_IT(&hadc1);
	}
}
