/*
 * distance.c
 *
 *  Created on: 2026. 10. 29.
 *      Author: kccistc
 */

#include "distance.h"
#include "../../../driver/HCSR04/HCSR04.h"
#include <stdbool.h>
#include <stdio.h>


#define DISTANCE_MIN_INTERVAL_MS 60U
#define sr04_trig_port GPIOC
#define sr04_trig_pin  GPIO_PIN_5
#define sr04_echo_port GPIOC
#define sr04_echo_pin  GPIO_PIN_6
#define sr04_tim       (&htim10)
extern TIM_HandleTypeDef htim10;




typedef enum {
    DIST_IDLE,
    DIST_PENDING,
    DIST_MEASURING
} distance_state_t;

static distance_state_t dist_state = DIST_IDLE;
static uint32_t last_finish_ms;
static uint32_t distance_cm;
static uint32_t echo_us;


void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
    if (GPIO_Pin == sr04_echo_pin) {
        HCSR04_echoISR();
    }
}


void distance_init(void)
{
    HCSR04_init(sr04_trig_port, sr04_trig_pin,
                sr04_echo_port, sr04_echo_pin, sr04_tim);
    last_finish_ms = HAL_GetTick();
}

uint32_t echo_to_cm(uint32_t echo_us)
{
    return echo_us * 17U / 1000U;
}

bool distance_request(void)
{
    if (dist_state != DIST_IDLE) {
        return false;
    }
    dist_state = DIST_PENDING;
    return true;
}

void distance_task(void)
{
    switch (dist_state) {
    case DIST_PENDING:
        if (HAL_GetTick() - last_finish_ms < DISTANCE_MIN_INTERVAL_MS) {
            return;
        }
        if (HCSR04_start() == HCSR04_OK) {
            dist_state = DIST_MEASURING;
        } else {
            dist_state = DIST_IDLE;
            last_finish_ms = HAL_GetTick();
            printf("fail: Echo busy\r\n");
        }
        break;

    case DIST_MEASURING: {
        hcsr04_status_t st = HCSR04_getResult(&echo_us);
        if (st == HCSR04_IN_PROGRESS) {
            return;
        }
        dist_state = DIST_IDLE;
        last_finish_ms = HAL_GetTick();
        if (st == HCSR04_OK) {
            distance_cm = echo_to_cm(echo_us);
            printf("distance: %3lucm\r\n", (unsigned long)distance_cm);
        } else if (st == HCSR04_ERR_OUT_OF_RANGE) {
            printf("fail: Out of range (>400cm or timeout)\r\n");
        } else {
            printf("fail: no valid Echo (status=%d)\r\n", (int)st);
        }
        break;
    }

    case DIST_IDLE:
    	break;
    default:
        break;
    }
}
//distance_state_t distance_get(uint16_t *distance_cm)
//{
//	*distance_cm = echo_us * 17 / 1000;
//	return DISTANCE_OK;
//}
