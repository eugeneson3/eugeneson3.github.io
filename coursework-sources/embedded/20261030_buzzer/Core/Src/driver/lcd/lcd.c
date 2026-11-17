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

void lcd_sendData(uint8_t data){
	HAL_I2C_Master_Transmit(&hi2c1, 0x27<<1, &data, 1, 100);
}

void lcd_cmdMode(){
	lcdData &= ~(1<<LCD_RS);
}

void lcd_dataMode(){
	lcdData |= (1<<LCD_RS);
}
// Low = Write
void lcd_writeMode(){
	lcdData &= ~(1<<LCD_RW);
}

void lcd_enHigh(void){
	lcdData |= (1<<LCD_EN);
	lcd_sendData(lcdData);
}

void lcd_enLow(void){
	lcdData &= ~(1<<LCD_EN);
	lcd_sendData(lcdData);
}

void lcd_backlightOn(void){
	lcdData |= (1<<LCD_BL);
	lcd_sendData(lcdData);
}

void lcd_backlightOff(void){
	lcdData &= ~(1<<LCD_BL);
	lcd_sendData(lcdData);

}

void lcd_writeNibble(uint8_t data){
	// send upper 4 bit with P7~P4
	lcdData = (lcdData & 0x0f)|(data & 0xf0);
	lcd_enHigh();
	lcd_enLow(); // LCD latches data on falling edge of EN
}

void lcd_writeByte(uint8_t data){
	// Upper Nibble transmission
	lcd_writeNibble(data);
	data <<=4;
	// Lower Nibble transmission
	lcd_writeNibble(data);

}


void lcd_writeCmdData(uint8_t data){
	lcd_cmdMode();
	lcd_writeMode();
	lcd_writeByte(data);
}
void lcd_writeCharData(uint8_t data){
	lcd_dataMode();
	lcd_writeMode();
	lcd_writeByte(data);
}

void lcd_init(){
	HAL_Delay(40); // wait 15ms when Vdd > 4.5V, 40ms when Vdd > 2.7V
	lcd_cmdMode();
	lcd_writeMode();
	lcd_writeNibble(0x30);
	HAL_Delay(5); // wait time > 4.1ms
	lcd_writeNibble(0x30);
	HAL_Delay(1); // wait time > 100us
	lcd_writeNibble(0x30);


	lcd_writeNibble(0x20);

	lcd_writeByte(0x28); // Function set 4bit

	lcd_writeByte(0x08); // Display off
	lcd_writeByte(0x01); // Display Clear
	HAL_Delay(2); // clear needs > 1.52ms
	lcd_writeByte(0x06); // Entry mode
	lcd_writeByte(0x0C); // Display on
	lcd_backlightOn();
}

void lcd_writeString(const char *str){
	while (*str) {                   // 문자열 끝('\0')까지
		lcd_writeCharData(*str++);   // 한 글자 보내고 포인터를 다음 글자로
	}
}

void lcd_gotoXY(uint8_t row, uint8_t col){
	col %=16;
	row %=2;

	uint8_t lcdRegAddr = (0x40 * row) + col;
	uint8_t cmd = 0x80 + lcdRegAddr;
	lcd_writeCmdData(cmd);
}
void lcd_writeStringXY(uint8_t row, uint8_t col, const char *str){
	lcd_gotoXY(row,col);
	lcd_writeString(str);
}
