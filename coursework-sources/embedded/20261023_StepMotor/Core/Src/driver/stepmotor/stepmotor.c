/*
 * stepmotor.c
 *
 *  Created on: 2026. 10. 23.
 *      Author: kccistc
 */

#include "stepmotor.h"

uint8_t step_table[] = {0x01,0x03,0x02,0x06,0x04,0x0c,0x08,0x09}; // IN4,IN3,IN2,IN1

static void StepMotor_writePattern(stepMotor_t *m,uint8_t step){
	for (int i = 0; i < 4; i++){
		GPIO_PinState s = ((step)&(1<<i))? GPIO_PIN_SET:GPIO_PIN_RESET;
		HAL_GPIO_WritePin(m->pin->port[i],m->pin->pin[i],s);
	}
}
void StepMotor_stepPhase(stepMotor_t *m,stepMotor_orientation_t orientation){

	if(orientation == STEPMOTOR_ORIENTATION_CW){
		/* + STEP_COUNT first: 0 - 1 would be -1 and index step_table out of range */
		m->stepCounter = (m->stepCounter + STEP_COUNT - 1) % STEP_COUNT;
	}
	else{
		m->stepCounter = (m->stepCounter + 1);
	}
	StepMotor_writePattern(m, step_table[m->stepCounter%STEP_COUNT]);
}
void StepMotor_release(stepMotor_t *m){
	StepMotor_writePattern(m, 0x00);
}
void StepMotor_setClockHand(){

}

void StepMotor_gotoAngle(timeClockTime_t *desiredTime){
	if((desiredTime - nowTime + 12)>=6){
		StepMotor_stepPhase(m,STEPMOTOR_ORIENTATION_CW);
	}
	else{
		StepMotor_stepPhase(m,STEPMOTOR_ORIENTATION_CCW);
	}
}


