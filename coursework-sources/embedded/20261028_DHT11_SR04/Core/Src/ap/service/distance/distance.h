/*
 * distance.h
 *
 *  Created on: 2026. 10. 29.
 *      Author: kccistc
 */

#ifndef SRC_AP_SERVICE_DISTANCE_DISTANCE_H_
#define SRC_AP_SERVICE_DISTANCE_DISTANCE_H_

#include <stdbool.h>
#include <stdint.h>

void distance_init(void);
bool distance_request(void);
void distance_task(void);
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin);

#endif /* SRC_AP_SERVICE_DISTANCE_DISTANCE_H_ */
