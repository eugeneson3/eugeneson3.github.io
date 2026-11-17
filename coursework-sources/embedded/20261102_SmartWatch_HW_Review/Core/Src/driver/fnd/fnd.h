/*
 * fnd.h
 *
 *  Created on: 2026. 10. 14.
 *      Author: rhoblack
 */

#ifndef SRC_DRIVER_FND_FND_H_
#define SRC_DRIVER_FND_FND_H_

#include "stm32f4xx_hal.h"

#define FND_DIGIT_1		0
#define FND_DIGIT_2		1
#define FND_DIGIT_3		2
#define FND_DIGIT_4		3

#define FND_DP_OFF	0
#define FND_DP_ON	1


void fnd_setDp(int dig, uint16_t state);
uint16_t fnd_getDp(void);
void fnd_setNum(uint16_t n);
uint16_t fnd_getNum(void);
void fnd_showNumber(void);


#endif /* SRC_DRIVER_FND_FND_H_ */
