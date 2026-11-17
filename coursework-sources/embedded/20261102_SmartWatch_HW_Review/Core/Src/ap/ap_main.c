/*
 * ap_main.c
 *
 *  Created on: 2026. 10. 30.
 *      Author: rhoblack
 */


#include <string.h>
#include "ap_main.h"
#include "stm32f4xx_hal.h"
#include "main.h"
#include <stdio.h>
#include "service/watch/watch.h"
#include "service/stopwatch/stopwatch.h"
#include "service/sound/sound.h"
#include "../driver/button/button.h"
#include "../driver/lcd/lcd.h"
#include "../driver/HCSR04/HCSR04.h"
#include "../driver/button/button.h"
#include "../driver/ds3231/ds3231.h"
#include "../driver/DHT11/DHT11.h"
#include "../common/queue/que_buffer.h"

#define BTN_EVENT_Q_SIZE 		6
extern I2C_HandleTypeDef hi2c1;
extern stopwatch_t stopwatch_state;
static TIM_HandleTypeDef sr04_timer;
static void ruler_timer_init(void)
{
	uint32_t timerClock = HAL_RCC_GetPCLK2Freq();
	if ((RCC->CFGR & RCC_CFGR_PPRE2) != 0U) timerClock *= 2U;
	__HAL_RCC_TIM10_CLK_ENABLE();
	sr04_timer.Instance = TIM10;
	sr04_timer.Init.Prescaler = timerClock / 1000000U - 1U;
	sr04_timer.Init.CounterMode = TIM_COUNTERMODE_UP;
	sr04_timer.Init.Period = 65535U;
	sr04_timer.Init.ClockDivision = TIM_CLOCKDIVISION_DIV1;
	sr04_timer.Init.AutoReloadPreload = TIM_AUTORELOAD_PRELOAD_DISABLE;
	if (HAL_TIM_Base_Init(&sr04_timer) != HAL_OK) Error_Handler();
}

typedef enum
{
	btnChangeModeEvent = 0,
	btnEvent_1,
	btnEvent_2,
	btnEvent_3
}btn_event_t;

typedef enum
{
	MODE_CALENDAR = 0,
	MODE_RULER,
	MODE_TEMPHUMID,
	MODE_STOPWATCH
}smartwatch_mode_t;
const char *dec2day[]= {"???","MON","TUE","WED","THR","FRI","SAT","SUN"};
smartwatch_mode_t smartWatchMode = MODE_CALENDAR;
que_buf_t que_btnEvent;
btn_event_t btnEventArray[BTN_EVENT_Q_SIZE];
button_t btnUP,btn1, btn2, btn3;
dht11_data_t curTempHumid;
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
	if (GPIO_Pin == GPIO_PIN_6) {
		HCSR04_echoISR();
	}
}
void ap_init()
{
	HAL_NVIC_DisableIRQ(EXTI9_5_IRQn);
	sound_init();
	Lcd_init(&hi2c1);
	button_init(&btn1, GPIOC, GPIO_PIN_0);
	button_init(&btn2, GPIOC, GPIO_PIN_1);
	button_init(&btn3, GPIOC, GPIO_PIN_3);
	button_init(&btnUP, GPIOC, GPIO_PIN_13);

	dht11_init(GPIOC, GPIO_PIN_8);
	que_buf_init(&que_btnEvent, btnEventArray, sizeof(btn_event_t), BTN_EVENT_Q_SIZE);
	ruler_timer_init();
	HCSR04_init(GPIOC, GPIO_PIN_5, GPIOC, GPIO_PIN_6, &sr04_timer);
	__HAL_GPIO_EXTI_CLEAR_IT(GPIO_PIN_6);
	HAL_NVIC_ClearPendingIRQ(EXTI9_5_IRQn);
	HAL_NVIC_EnableIRQ(EXTI9_5_IRQn);
}
/* Write exactly one LCD row, only when its contents change. */
static void display_line(uint8_t row, const char *text)
{
	static char previous[2][17];
	char line[17];
	snprintf(line, sizeof(line), "%-16.16s", text);
	if (strcmp(previous[row], line) != 0) {
		Lcd_writeStringXY(row, 0, line);
		memcpy(previous[row], line, sizeof(line));
	}
}

int ap_main(void)
{
	ap_init();
	sound_power();
	uint32_t watchTick = HAL_GetTick() - 250U;
	uint32_t rulerTick = HAL_GetTick() - 100U;
	uint8_t measuring = 0;
	smartwatch_mode_t previousMode = MODE_STOPWATCH;
	char buff[30];
	char rulerText[30] = "Distance: ---CM";
	ds_time_t curTime = {0};
	ds_date_t curDate = {0};
	uint16_t echo_cm = 0;
	while (1) {
		sound_task();
		if (button_getState(&btnUP) == ACT_RELEASE) {
			smartWatchMode = (smartWatchMode + 1) % 4;
		}
		btn_event_t event;

		if (button_getState(&btn1) == ACT_RELEASE) {
			event = btnEvent_1; que_put(&que_btnEvent, &event);
		}
		if (button_getState(&btn2) == ACT_RELEASE) {
			event = btnEvent_2; que_put(&que_btnEvent, &event);
		}
		if (button_getState(&btn3) == ACT_RELEASE) {
			event = btnEvent_3; que_put(&que_btnEvent, &event);
		}


		if (que_get(&que_btnEvent, &event)) {
			if(smartWatchMode != MODE_STOPWATCH){
				if (event == btnEvent_1) sound_button();
				else if (event == btnEvent_2) sound_error();
				else if (event == btnEvent_3) sound_alarm();
			}
			else
			{
				if (event == btnEvent_1) stopwatch_set_state(RUN);
				else if (event == btnEvent_2) sound_error();
				else if (event == btnEvent_3) sound_alarm();
			}
		}
		uint32_t now = HAL_GetTick();
		if (now - watchTick >= 250U) {
			watchTick = now;
			watch_task();
			curTime = *watch_getTime();
			curDate = *watch_getDate();
			snprintf(buff, sizeof(buff), "TIME:%02u:%02u:%02u",
					(unsigned)curTime.hour, (unsigned)curTime.min, (unsigned)curTime.sec);
			display_line(0, buff);
		}
		/* Consume a completed result before allowing another trigger. */
		if (measuring) {
			hcsr04_status_t status = HCSR04_getResult(&echo_cm);
			if (status != HCSR04_IN_PROGRESS) {
				measuring = 0;
				if (status == HCSR04_OK && echo_cm > 0U && echo_cm <= 400U) {
					snprintf(rulerText, sizeof(rulerText), "Distance: %03uCM", (unsigned)echo_cm);
				} else {
					snprintf(rulerText, sizeof(rulerText), "Distance: ERROR");
				}
			}
		}
		if (smartWatchMode != previousMode) {
			previousMode = smartWatchMode;
			if (smartWatchMode == MODE_RULER) rulerTick = now - 100U;
		}
		switch (smartWatchMode) {
		case MODE_CALENDAR:
			snprintf(buff, sizeof(buff), "20%02u.%02u.%02u %s",
					(unsigned)curDate.year, (unsigned)curDate.month, (unsigned)curDate.date,
					curDate.day <= 7U ? dec2day[curDate.day] : "???");
			display_line(1, buff);
			break;
		case MODE_RULER:
			if (!measuring && now - rulerTick >= 100U) {
				rulerTick = now;
				if (HCSR04_start() == HCSR04_OK) measuring = 1;
				else snprintf(rulerText, sizeof(rulerText), "Distance: BUSY");
			}
			display_line(1, rulerText);
			break;
		case MODE_TEMPHUMID:
			if(dht11_read(&curTempHumid) == DHT11_OK)
			{
				snprintf(buff, sizeof(buff), "TEMP/HUM: %d,%d",curTempHumid.t_int,curTempHumid.h_int);
				display_line(1,buff);

			}
			break;
		case MODE_STOPWATCH:
			display_line(1, "STOPWATCH: N/A");
			break;
		}
	}
	return 0;
}
