/*
 * ds3231.c
 *
 *  Created on: 2026. 10. 22.
 *      Author: kccistc
 */

#define DS_I2C_ADDR 		0x68
#define DS_TIMEOUT_MS		10
#define DS_REG_SEC			0x00
#define DS_REG_DAY			0x03


#include "ds3231.h"
#include <stdint.h>
extern I2C_HandleTypeDef hi2c1;


static void ds_getInfo(uint8_t reg, uint8_t *pData,uint16_t Size){

	HAL_I2C_Master_Transmit(&hi2c1, DS_I2C_ADDR <<1, &reg, 1, DS_TIMEOUT_MS);
	HAL_I2C_Master_Receive(&hi2c1, DS_I2C_ADDR <<1, pData, Size, DS_TIMEOUT_MS);
}
static void ds_setInfo(uint8_t reg, uint8_t *pData, uint8_t Size){
	uint8_t buf[8];
	buf[0] = reg;
	for(uint8_t i = 0; i < Size; i++){
		buf[i + 1] = pData[i];
	}
	HAL_I2C_Master_Transmit(&hi2c1, DS_I2C_ADDR << 1, buf, Size + 1, DS_TIMEOUT_MS);
}
static uint8_t bcd2dec(uint8_t bcd){
	return ((bcd >> 4) * 10) + (bcd & 0x0F);
}
static uint8_t dec2bcd(uint8_t dec){
	return ((dec / 10) << 4) | (dec % 10);
}

//Time
void ds_getTime(ds_time_t *t){
	uint8_t buf[3];
	ds_getInfo(DS_REG_SEC,buf,3);
	t->sec = bcd2dec(buf[0] & 0x7F);
	t->min = bcd2dec(buf[1] & 0x7F);
	t->hour = bcd2dec(buf[2] & 0x3F);

}

void ds_setTime(const ds_time_t *t){
	uint8_t buf[3];
	buf[0] = dec2bcd(t->sec);
	buf[1] = dec2bcd(t->min);
	buf[2] = dec2bcd(t->hour);          // bit6=0이라 24시간 모드
	ds_setInfo(DS_REG_SEC, buf, 3);
}
//Date
void ds_getDate(ds_date_t *t){
	uint8_t buf[4];
	ds_getInfo(DS_REG_DAY,buf,4);
	t->day = bcd2dec(buf[0] & 0x07);
	t->date = bcd2dec(buf[1] & 0x3F);
	t->month = bcd2dec(buf[2] & 0x1F);
	t->year = bcd2dec(buf[3]);
}


void ds_setDate(const ds_date_t *t){
	uint8_t buf[4];
	buf[0] = dec2bcd(t->day);
	buf[1] = dec2bcd(t->date);
	buf[2] = dec2bcd(t->month);
	buf[3] = dec2bcd(t->year);
	ds_setInfo(DS_REG_DAY, buf, 4);
}

//TimeDate
void ds_getTimeDate(ds_datetime_t *dt){
	ds_getTime(&dt->time);
	ds_getDate(&dt->date);
}

void ds_setTimeDate(ds_datetime_t *dt){
	ds_setTime(&dt->time);
	ds_setDate(&dt->date);
}


