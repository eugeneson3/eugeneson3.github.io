/*
 * lcd.h
 *
 *  Created on: 2026. 10. 21.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_LCD_LCD_H_
#define SRC_DRIVER_LCD_LCD_H_

#include "stm32f4xx_hal.h"
void Lcd_backlightOn(void);
void Lcd_backlightOff(void);
void Lcd_writeCmdData(uint8_t data);
void Lcd_writeCharData(uint8_t data);
void Lcd_Init(void);




#endif /* SRC_DRIVER_LCD_LCD_H_ */
