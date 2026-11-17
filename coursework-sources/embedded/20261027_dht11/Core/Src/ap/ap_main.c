/*
 * ap_main.c
 *
 *  Created on: 2026. 10. 28.
 *      Author: kccistc
 */

#include "ap_main.h"
#include "service/temp_humid/temp_humid.h"
#include "service/display/display.h"

#include <stdio.h>


void HAL_GPIO_EXIT_Callback(uint16_t GPIO_Pin)
{
	if(GPIO_Pin_6)
	{

	}
}

int ap_main(void)
{

	TH_init();
	display_init(); // 	Lcd_init(); 대신 레이어 1개씩만 전달해보자

	while(1)
	{
		TH_task();
		display_task();
	}
	return 0;
	}
