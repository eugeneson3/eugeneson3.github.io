/*
 * buzzer.c
 *
 *  Created on: 2026. 10. 30.
 *      Author: kccistc
 */
#include "buzzer.h"
extern TIM_HandleTypeDef htim1;

TIM_HandleTypeDef *buzzer_htim;
uint32_t buzzerChannel = 0;

void buzzer_init(TIM_HandleTypeDef *htim, uint32_t channel)
{
	buzzer_htim = htim;
	buzzerChannel = channel;
	__HAL_TIM_SET_COMPARE(buzzer_htim,buzzerChannel,0);
	HAL_TIM_PWM_Start(buzzer_htim, buzzerChannel);

}
void buzzer_off(void)
{
	__HAL_TIM_SET_COMPARE(buzzer_htim,buzzerChannel,0);

}

void buzzer_on(uint32_t freq_hz)
{
	if(freq_hz == 0)
	{
		buzzer_off();
		return;
	}
	else if(freq_hz < 20)
	{
		freq_hz = 20;
	}
	else if(freq_hz > 20000)
	{
		freq_hz = 20000;
	}

	uint32_t arr = 1000000/freq_hz - 1;
	uint32_t ccr = (arr + 1)/2; // dividing by 2 means 50% duty cycle

	__HAL_TIM_SET_AUTORELOAD(&htim1,arr);
	__HAL_TIM_SET_COMPARE(&htim1,TIM_CHANNEL_4,ccr);
}

