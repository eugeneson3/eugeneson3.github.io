
#ifndef SRC_DRIVER_FND_FND_H_
#define SRC_DRIVER_FND_FND_H_

#include "stm32f4xx_hal.h"  // Inc -> main.h에 있음

void fnd_show_number(void); // main.c 에서 사용 될 함수.
void fnd_set_number(uint16_t setnumber);

#endif /* SRC_DRIVER_FND_FND_H_ */
