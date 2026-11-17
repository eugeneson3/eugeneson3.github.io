/*
 * display.c
 *
 *  Created on: 2026. 10. 28.
 *      Author: kccistc
 */

#include "display.h"
#include "../../../driver/lcd/lcd.h"
#include "../temp_humid/temp_humid.h"
#include <stdio.h>
void display_init(void)
{
	 Lcd_init();
}

void display_task(void)
{
	static uint32_t prevTime = 0;
	if(HAL_GetTick() - prevTime <1000)
	{
		return;
	}
	prevTime = HAL_GetTick();
	char buff[30];
	dht11_data_t thData;
	TH_getTempHumid(&thData);
		snprintf(buff, sizeof(buff), "T:%u.%u H:%u.%u%%",
				thData.t_int, thData.t_dec,
				thData.h_int, thData.h_dec);
		buff[16] = '\0'; // Limit output to one 16-character LCD row.
		Lcd_writeStringXY(1, 0, buff);
	HAL_Delay(2000);
}
