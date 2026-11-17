/*
 * sound.c
 *
 *  Created on: 2026. 10. 30.
 *      Author: kccistc
 */
#include "../../../driver/buzzer/buzzer.h"
extern TIM_HandleTypeDef htim1;
#include "star_walkin_notes.h"

#define C4 262
#define D4 293
#define E4 330
#define F4 349
#define G4 392
#define A4 440
#define B4 493

#define C5 C4*2
#define D5 D4*2
#define E5 E4*2
#define F5 F4*2
#define G5 G4*2
#define A5 A4*2
#define B5 B4*2

#define C6 C5*2
#define D6 D5*2
#define E6 E5*2
#define F6 F5*2
#define G6 G5*2
#define A6 A5*2
#define B6 B5*2

#define C7 C6*2
#define D7 D6*2
#define E7 E6*2
#define F7 F6*2
#define G7 G6*2
#define A7 A6*2
#define B7 B6*2
#include "sound.h"
#include "../../../driver/buzzer/buzzer.h"

void sound_init()
{
	buzzer_init(&htim1,TIM_CHANNEL_4);
}
void playChirpSound(void)
{
	buzzer_on(G7);
	HAL_Delay(100);

	buzzer_on(A7);
	HAL_Delay(100);
	buzzer_off();

}
void playErrorSound(void)
{
	buzzer_on(E7);
	HAL_Delay(400);

	buzzer_on(C7);
	HAL_Delay(400);

	buzzer_on(E7);
	HAL_Delay(400);

	buzzer_on(C7);
	HAL_Delay(400);
	buzzer_on(E7);
	HAL_Delay(400);

	buzzer_on(C7);
	HAL_Delay(400);
	buzzer_on(E7);
	HAL_Delay(400);

	buzzer_on(C7);
	HAL_Delay(400);
	buzzer_off();

}
void playPowerSound(void)
{
	buzzer_on(C4); //C4
	HAL_Delay(200);

	buzzer_on(D4);
	HAL_Delay(200);

	buzzer_on(E4);
	HAL_Delay(200);

	buzzer_on(F4);
	HAL_Delay(200);

	buzzer_on(G4);
	HAL_Delay(200);

	buzzer_on(A4);
	HAL_Delay(200);

	buzzer_on(B4); //C5
	HAL_Delay(1000);
	buzzer_off();
}
