/*
 * fnd.c
 *
 *  Created on: 2026. 10. 14.
 *      Author: rhoblack
 */

#include "fnd.h"



#define SEG_DP_ON	10
#define SEG_DP_OFF	11


typedef struct {
	GPIO_TypeDef* GPIOx;
	uint16_t GPIO_Pin;
}segPort_t;


static void fnd_allOff(void);
static void fnd_selDigit(int digit);
static void fnd_dispNumber(int number);

static uint16_t num = 0;
static uint16_t dp = 0;

void fnd_setDp(int dig, uint16_t state)
{
	if (state == FND_DP_ON) {
		dp |= (1<<dig); // ex) dp |= (1<<FND_DIGIT_2); dp |= (1<<1); => 2bxx1x
	}
	else {
		dp &= ~(1<<dig); // ex) dp &= ~(1<<FND_DIGIT_2); dp &= ~(1<<1); => 2bxx0x
	}

}

uint16_t fnd_getDp(void)
{
	return dp;
}

void fnd_setNum(uint16_t n)
{
	num = n;
}

uint16_t fnd_getNum(void)
{
	return num;
}

static void fnd_allOff(void)
{
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_SET); // D1
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, GPIO_PIN_SET); // D2
	HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, GPIO_PIN_SET); // D3
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_10, GPIO_PIN_SET); // D4
}

static void fnd_selDigit(int digit)
{
	switch (digit)
	{
	case 0:
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_RESET); // D1
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, GPIO_PIN_SET); // D2
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, GPIO_PIN_SET); // D3
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_10, GPIO_PIN_SET); // D4
		break;
	case 1:
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_SET); // D1
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, GPIO_PIN_RESET); // D2
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, GPIO_PIN_SET); // D3
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_10, GPIO_PIN_SET); // D4
		break;
	case 2:
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_SET); // D1
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, GPIO_PIN_SET); // D2
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, GPIO_PIN_RESET); // D3
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_10, GPIO_PIN_SET); // D4
		break;
	case 3:
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_SET); // D1
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, GPIO_PIN_SET); // D2
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, GPIO_PIN_SET); // D3
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_10, GPIO_PIN_RESET); // D4
		break;
	}
}

static void fnd_dispNumber(int number)
{
	segPort_t segFont[8] = {
			{GPIOA, GPIO_PIN_6},
			{GPIOA, GPIO_PIN_9},
			{GPIOB, GPIO_PIN_5},
			{GPIOB, GPIO_PIN_10},
			{GPIOA, GPIO_PIN_8},
			{GPIOA, GPIO_PIN_7},
			{GPIOB, GPIO_PIN_3},
			{GPIOB, GPIO_PIN_4}
	};

	int segFontData[12][8] = {
			{1, 1, 1, 1, 1, 1, 0, 0}, // 0
			{0, 1, 1, 0, 0, 0, 0, 0}, // 1
			{1, 1, 0, 1, 1, 0, 1, 0}, // 2
			{1, 1, 1, 1, 0, 0, 1, 0}, // 3
			{0, 1, 1, 0, 0, 1, 1, 0}, // 4
			{1, 0, 1, 1, 0, 1, 1, 0}, // 5
			{1, 0, 1, 1, 1, 1, 1, 0}, // 6
			{1, 1, 1, 0, 0, 0, 0, 0}, // 7
			{1, 1, 1, 1, 1, 1, 1, 0}, // 8
			{1, 1, 1, 1, 0, 1, 1, 0}, // 9
			{0, 0, 0, 0, 0, 0, 0, 1}, // 10: dp on
			{0, 0, 0, 0, 0, 0, 0, 0}, // 11: dp off
	};

	for (int i=0; i<8; i++) {
		HAL_GPIO_WritePin(segFont[i].GPIOx, segFont[i].GPIO_Pin, segFontData[number][i]);
	}
}

void fnd_showNumber(void)
{
	static int state = 0; // 함수가 끝나도 변수값 유지.

	//int data = number;
	int data = fnd_getNum();
	int dpData = fnd_getDp();

	fnd_allOff();
	switch(state)
	{
	case 0: // digit 1, 1000
		fnd_dispNumber(data / 1000 % 10);
		fnd_selDigit(FND_DIGIT_1);
		break;
	case 1: // digit 2, 100
		fnd_dispNumber(data / 100 % 10);
		fnd_selDigit(FND_DIGIT_2);
		break;
	case 2: // digit 3, 10
		fnd_dispNumber(data / 10 % 10);
		fnd_selDigit(FND_DIGIT_3);
		break;
	case 3: // digit 4, 1
		fnd_dispNumber(data % 10);
		fnd_selDigit(FND_DIGIT_4);
		break;
	case 4: // digit 1, dp
		if ((dpData & (1<<FND_DIGIT_1)) == 0) {
			fnd_dispNumber(SEG_DP_OFF); // dp off
		}
		else {
			fnd_dispNumber(SEG_DP_ON); // dp on
		}
		fnd_selDigit(FND_DIGIT_1);
		break;
	case 5: // digit 2, dp
		if ((dpData & (1<<FND_DIGIT_2)) == 0) {
			fnd_dispNumber(SEG_DP_OFF); // dp off
		}
		else {
			fnd_dispNumber(SEG_DP_ON); // dp on
		}
		fnd_selDigit(FND_DIGIT_2);
		break;
	case 6: // digit 3, dp
		if ((dpData & (1<<FND_DIGIT_3)) == 0) {
			fnd_dispNumber(SEG_DP_OFF); // dp off
		}
		else {
			fnd_dispNumber(SEG_DP_ON); // dp on
		}
		fnd_selDigit(FND_DIGIT_3);
		break;
	case 7: // digit 4, dp
		if ((dpData & (1<<FND_DIGIT_4)) == 0) {
			fnd_dispNumber(SEG_DP_OFF); // dp off
		}
		else {
			fnd_dispNumber(SEG_DP_ON); // dp on
		}
		fnd_selDigit(FND_DIGIT_4);
		break;
	default:
		break;
	}
	//HAL_Delay(1);
	state = (state + 1) % 8;
}
