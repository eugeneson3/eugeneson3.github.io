#ifndef SRC_DRIVER_FND_FND_H_
#define SRC_DRIVER_FND_FND_H_

#include "stm32f4xx_hal.h"

void fnd_set_num(uint16_t n);

void fnd_show_number(uint8_t flag);
uint16_t fnd_get_num(void);
#endif /*SRC_DRIVER_FND_FND_H_ */
