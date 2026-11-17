/*
 * stepmotor.c
 *
 *  Created on: 2026. 10. 24.
 *      Author: kccistc
 */



stepMotor_pin_t stepMotorPinSec = {
		.port = {GPIOA,GPIOA,GPIOA,GPIOB},
		.pin = {GPIO_PIN_0,GPIO_PIN_1,GPIO_PIN_4,GPIO_PIN_0}
};

stepMotor_t motor_sec = {
		.pin = &stepMotorPinSec,
		.stepCounter = 0
};

volatile uint8_t isrFlag = 0;

void ClockHands_setPeriodUs(uint16_t us){
	__HAL_TIM_SET_AUTORELOAD(&htim9, us - 1);
	__HAL_TIM_SET_COUNTER(&htim9, 0);	/* avoid waiting for a full 16-bit wrap */
}

void ClockHands_setFlag(void){
	isrFlag = 1;
}
void ClockHands_clearFlag(void){
	isrFlag = 0;
}
void ClockHands_ISR(void){
	ClockHands_setFlag();
}
void ClockHands_Task(void){
	if(isrFlag == 0){
		return;
	}
	ClockHands_clearFlag();
	StepMotor_stepPhase(&motor_sec,STEPMOTOR_ORIENTATION_CW);
}
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
	if(htim->Instance == TIM9){
		ClockHands_ISR();
	}
}

//while (1)
//{
//
//	ClockHands_Task();
//	if(button_getState(&btn_up)== ACT_RELEASE){
//		ClockHands_setPeriodUs(CLOCKHANDS_PERIOD_SLOW_US);
//	}
//	else if (button_getState(&btn_down) == ACT_RELEASE){
//		ClockHands_setPeriodUs(CLOCKHANDS_PERIOD_FAST_US);
//	}
//}
