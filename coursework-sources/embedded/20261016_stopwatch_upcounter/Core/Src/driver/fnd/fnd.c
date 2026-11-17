#include "fnd.h"

#define FND_DIGIT_1 0
#define FND_DIGIT_2 1
#define FND_DIGIT_3 2
#define FND_DIGIT_4 3

typedef struct {
	GPIO_TypeDef* GPIOx;
	uint16_t GPIO_Pin;
}seg_port_t;
static void fnd_all_off(void);
static void fnd_sel_digit(int digit);
static void fnd_disp_num(int number);
static void fnd_disp_num_dot(int number);


static volatile uint16_t num = 0;

void fnd_set_num(uint16_t n){
	num = n;
}

uint16_t fnd_get_num(void){
	return num;
}

static void fnd_all_off(void){
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_SET); // D1
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, GPIO_PIN_SET); // D2
	HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, GPIO_PIN_SET); // D3
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_10, GPIO_PIN_SET); // D4
};
static void fnd_sel_digit(int digit){
	switch(digit){
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
};
seg_port_t seg_port[8] = {
		{GPIOA,GPIO_PIN_6},
		{GPIOA,GPIO_PIN_9},
		{GPIOB,GPIO_PIN_5},
		{GPIOB,GPIO_PIN_10},
		{GPIOA,GPIO_PIN_8},
		{GPIOA,GPIO_PIN_7},
		{GPIOB,GPIO_PIN_3},
		{GPIOB,GPIO_PIN_4}
};
int seg_port_data[10][8] = {
		// A  B  C  D  E  F  G
		{ 1, 1, 1, 1, 1, 1, 0, 0 }, // 0
		{ 0, 1, 1, 0, 0, 0, 0, 0 }, // 1
		{ 1, 1, 0, 1, 1, 0, 1, 0 }, // 2
		{ 1, 1, 1, 1, 0, 0, 1, 0 }, // 3
		{ 0, 1, 1, 0, 0, 1, 1, 0 }, // 4
		{ 1, 0, 1, 1, 0, 1, 1, 0 }, // 5
		{ 1, 0, 1, 1, 1, 1, 1, 0 }, // 6
		{ 1, 1, 1, 0, 0, 1, 0, 0 }, // 7
		{ 1, 1, 1, 1, 1, 1, 1, 0 }, // 8
		{ 1, 1, 1, 1, 0, 1, 1, 0 }  // 9
};
static void fnd_disp_num(int number){
	for (int i = 0; i <8; i++){
				HAL_GPIO_WritePin(seg_port[i].GPIOx,seg_port[i].GPIO_Pin,seg_port_data[number][i]);
			}
};
static void fnd_disp_num_dot(int number){

	for (int i = 0; i <7; i++){
		HAL_GPIO_WritePin(seg_port[i].GPIOx,seg_port[i].GPIO_Pin,seg_port_data[number][i]);
			}
		HAL_GPIO_WritePin(seg_port[7].GPIOx,seg_port[7].GPIO_Pin,1);

};
void fnd_show_number(uint8_t flag){
	static int state = 0;
	uint16_t display_num = num;
	fnd_all_off();
	switch(state){
	case 0:
	fnd_disp_num(display_num/1000%10);
	fnd_sel_digit(FND_DIGIT_1);
	break;

	case 1:
	if(flag == 1){
		fnd_disp_num_dot(display_num/100%10);
	}
	else{
		fnd_disp_num(display_num/100%10);
	}
	fnd_sel_digit(FND_DIGIT_2);
	break;

	case 2:
	fnd_disp_num(display_num/10%10);
	fnd_sel_digit(FND_DIGIT_3);
	break;

	case 3:
	fnd_disp_num(display_num%10);
	fnd_sel_digit(FND_DIGIT_4);
	break;

	default:
	break;
	}
	state = (state + 1)% 4;
};
