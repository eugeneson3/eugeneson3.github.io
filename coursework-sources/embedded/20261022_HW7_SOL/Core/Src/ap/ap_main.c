/*
 * ap_main.c
 *
 *  Created on: 2026. 10. 16.
 *      Author: rhoblack
 */

#include "ap_main.h"
#include "StopWatch/StopWatch.h"
#include "TimeClock/TimeClock.h"
#include "Display/Display.h"
#include "../driver/fnd/fnd.h"
#include "../driver/button/button.h"
#include "../driver/led/led.h"
#include "../driver/ds3231/ds3231.h"

static ds_datetime_t set_dt = {
		  .date = {.year = 26, .month = 10, .date = 22, .day = 4},
		  .time = {.hour = 15, .min = 36, .sec = 20}
};

enum {TIME_CLOCK_MODE, STOP_WATCH_MODE};

extern TIM_HandleTypeDef htim3;
extern TIM_HandleTypeDef htim4;

button_t btnMode;

int modeState = TIME_CLOCK_MODE;


void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
	if (htim->Instance == TIM3) {
		//fnd_show_number();
		Disp_ISR();
	}
	else if (htim->Instance == TIM4) {
		TimeClock_ISR();
		StopWatch_ISR();
	}
}

void ap_init(void)
{
	StopWatch_init();
	TimeClock_init();
	Disp_init();

	button_init(&btnMode, GPIOC, GPIO_PIN_0);

	HAL_TIM_Base_Start_IT(&htim3);
	HAL_TIM_Base_Start_IT(&htim4);
}

void ap_timeClockMode(void)
{
	if (button_getState(&btnMode) == ACT_RELEASE) {
		modeState = STOP_WATCH_MODE;
	}
	TimeClock_task();

	TimeClock_t *pTimeClockTime = TimeClock_getTimeData();
	Disp_setTimeClockTime((timeClockTime_t *)pTimeClockTime);
	Disp_setMode(modeState);
}

void ap_stopWatchMode(void)
{
	if (button_getState(&btnMode) == ACT_RELEASE) {
		modeState = TIME_CLOCK_MODE;
	}
	StopWatch_task();
	TimeClock_task();   // 스톱워치 모드에서도 윗줄 RTC 시간 갱신

	stopWatch_t *pStopWatchTime = StopWatch_getTimeData();
	Disp_setStopWatchTime((stopWatchTime_t *)pStopWatchTime);
	Disp_setMode(modeState);

	stopWatch_state_t stopWatchState = StopWatch_getState();
	Disp_setStopWatchState(stopWatchState);
}

int ap_main(void)
{
	//ds_setTimeDate(&set_dt);

	ap_init();

	while(1) // super loop
	{
		switch (modeState)
		{
		case TIME_CLOCK_MODE:
			ap_timeClockMode();
			break;
		case STOP_WATCH_MODE:
			ap_stopWatchMode();
			break;
		default:
			break;
		}
	}
	return 0;
}
