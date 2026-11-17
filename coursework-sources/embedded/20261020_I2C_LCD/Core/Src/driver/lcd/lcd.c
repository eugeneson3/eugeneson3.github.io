/*
 * lcd.c
 *
 *  Created on: 2026. 10. 21.
 *      Author: kccistc
 */
#include "lcd.h"
#include <stdint.h>

uint8_t lcdData = 0; // bit 0 = Rs, bit 7 = DB7

#define LCD_RS		0
#define LCD_RW		1
#define LCD_EN		2
#define LCD_BL		3

#define LCD_DB4		4
#define LCD_DB5		5
#define LCD_DB6		6
#define LCD_DB7		7

extern I2C_HandleTypeDef hi2c1;
//HAL_StatusTypeDef HAL_I2C_Master_Transmit
//(I2C_HandleTypeDef *hi2c, uint16_t DevAddress, uint8_t *pData, uint16_t Size, uint32_t Timeout)

void Lcd_sendData(uint8_t data){
	HAL_I2C_Master_Transmit(&hi2c1, 0x27<<1, &data, 1, 100);
}

void Lcd_cmdMode(){
	lcdData &= ~(1<<LCD_RS);
}

void Lcd_dataMode(){
	lcdData |= (1<<LCD_RS);
}
// Low = Write
void Lcd_writeMode(){
	lcdData &= ~(1<<LCD_RW);
}

void Lcd_enHigh(void){
	lcdData |= (1<<LCD_EN);
	Lcd_sendData(lcdData);
}

void Lcd_enLow(void){
	lcdData &= ~(1<<LCD_EN);
	Lcd_sendData(lcdData);
}

void Lcd_backlightOn(void){
	lcdData |= (1<<LCD_BL);
	Lcd_sendData(lcdData);
}

void Lcd_backlightOff(void){
	lcdData &= ~(1<<LCD_BL);
	Lcd_sendData(lcdData);

}

void Lcd_writeNibble(uint8_t data){
	// send upper 4 bit with P7~P4
	lcdData = (lcdData & 0x0f)|(data & 0xf0);
	Lcd_enHigh();
	Lcd_enLow(); // LCD latches data on falling edge of EN
}

void Lcd_writeByte(uint8_t data){
	// Upper Nibble transmission
	Lcd_writeNibble(data);
	data <<=4;
	// Lower Nibble transmission
	Lcd_writeNibble(data);

}


void Lcd_writeCmdData(uint8_t data){
	Lcd_cmdMode();
	Lcd_writeMode();
	Lcd_writeByte(data);
}
void Lcd_writeCharData(uint8_t data){
	Lcd_dataMode();
	Lcd_writeMode();
	Lcd_writeByte(data);
}

void Lcd_Init(){
	HAL_Delay(40); // wait 15ms when Vdd > 4.5V, 40ms when Vdd > 2.7V
	Lcd_cmdMode();
	Lcd_writeMode();
	Lcd_writeNibble(0x30);
	HAL_Delay(5); // wait time > 4.1ms
	Lcd_writeNibble(0x30);
	HAL_Delay(1); // wait time > 100us
	Lcd_writeNibble(0x30);


	Lcd_writeNibble(0x20);

	Lcd_writeByte(0x28); // Function set 4bit

	Lcd_writeByte(0x08); // Display off
	Lcd_writeByte(0x01); // Display Clear
	Lcd_writeByte(0x06); // Entry mode
	Lcd_writeByte(0x0C); // Display on
	Lcd_backlightOn();



}
