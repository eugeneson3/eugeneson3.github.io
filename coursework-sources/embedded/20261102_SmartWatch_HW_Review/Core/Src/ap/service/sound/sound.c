/*
 * sound.c
 *
 *  Created on: 2026. 10. 30.
 *      Author: rhoblack
 */

#include "sound.h"
#include "../../../driver/buzzer/buzzer.h"

#define C4	262
#define D4	294
#define E4	330
#define F4	349
#define G4	392
#define A4	440
#define B4	494
#define C5	(C4*2)
#define D5	(D4*2)
#define E5	(E4*2)
#define F5	(F4*2)
#define G5	(G4*2)
#define A5	(A4*2)
#define B5	(B4*2)
#define C6	(C5*2)
#define D6	(D5*2)
#define E6	(E5*2)
#define F6	(F5*2)
#define G6	(G5*2)
#define A6	(A5*2)
#define B6	(B5*2)
#define C7	(C6*2)
#define D7	(D6*2)
#define E7	(E6*2)
#define F7	(F6*2)
#define G7	(G6*2)
#define A7	(A6*2)
#define B7	(B6*2)

extern TIM_HandleTypeDef htim1;

void sound_init(void)
{
	buzzer_init(&htim1, TIM_CHANNEL_4);
}

typedef struct { uint16_t hz, ms; } sound_note_t;
static const sound_note_t powerNotes[] = {{C6,100},{E6,100},{G6,100},{C7,200}};
static const sound_note_t buttonNotes[] = {{G6,40},{C7,60}};
static const sound_note_t errorNotes[] = {{A7,150},{0,60},{A7,150}};
static const sound_note_t alarmNotes[] = {{C7,100},{0,100},{C7,100},{0,100},{C7,100},{0,100}};
static const sound_note_t musicNotes[] = {{330,236},{0,14}, {349,236},{0,14}, {330,236}, {0,14},{294,236},{0,14},
	    {262,236}, {0,14}, {294,236},{0,14}};
static const sound_note_t *sequence;
static uint32_t noteTick;
static uint8_t noteCount, noteIndex;
static void sound_start(const sound_note_t *notes, uint8_t count)
{
    sequence = notes; noteCount = count; noteIndex = 0;
    noteTick = HAL_GetTick(); buzzer_on(notes[0].hz);
}
void sound_task(void)
{
    if (!sequence) return;
    uint32_t now = HAL_GetTick();
    while (sequence && now - noteTick >= sequence[noteIndex].ms) {
        noteTick += sequence[noteIndex].ms;
        if (++noteIndex == noteCount) { sequence = NULL; buzzer_off(); }
        else buzzer_on(sequence[noteIndex].hz);
    }
}
void sound_power(void) { sound_start(powerNotes, 4); }
void sound_button(void) { sound_start(buttonNotes, 2); }
void sound_error(void) { sound_start(errorNotes, 3); }
void sound_alarm(void) { sound_start(musicNotes, 12); }
