/*
 * lcd.h
 *
 *  Created on: 2026. 10. 21.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_LCD_LCD_H_
#define SRC_DRIVER_LCD_LCD_H_

#include "stm32f4xx_hal.h"
void lcd_backlightOn(void);
void lcd_backlightOff(void);
void lcd_writeCmdData(uint8_t data);
void lcd_writeCharData(uint8_t data);
void lcd_init(void);
void lcd_writeString(const char *str);
void lcd_gotoXY(uint8_t row, uint8_t col);
void lcd_writeStringXY(uint8_t row, uint8_t col, const char *str);

#endif /* SRC_DRIVER_LCD_LCD_H_ */
