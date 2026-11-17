/*
 * counter_task.c
 *
 *  Created on: 2026. 11. 10.
 *      Author: kccistc
 */
#include "counter_task.h"
#include "../../../driver/fnd/fnd.h"
#include "../event_task/event_task.h"
#include <stdint.h>

typedef enum {STOP,RUN,CLEAR} counter_state_t;

static uint16_t number = 0;
static int state;
void counter_task_init(void)
{
	number = 0;
	state = STOP;
}
void counter_task(void)
{
	switch(state)
	{
	case STOP:
		if(btn_status == BTN_RUN_STOP)
		{
			state = RUN;
		}
		else if(btn_status == BTN_CLEAR)
		{
			state = CLEAR;
		}

		break;
	case RUN:
		number++;
		if(btn_status == BTN_RUN_STOP)
		{
			state = STOP;
		}
		break;
	case CLEAR:
		number = 0;
		state = STOP;
		break;
	default:
		break;
	}
	btn_status = BTN_NO;
	fnd_set_number(number/10U);

}
