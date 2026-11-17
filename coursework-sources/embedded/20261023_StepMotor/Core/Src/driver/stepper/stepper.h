/**
 * @file    stepper.h
 * @brief   28BYJ-48 (5-wire unipolar) driver for a ULN2003 board, half-step.
 *
 * One call to stepper_step() advances the rotor by exactly one half-step.
 * The caller decides the speed by choosing when to call it, so the driver
 * never blocks. Not re-entrant: call it from a single context (e.g. one ISR).
 */
#ifndef DRIVER_STEPPER_STEPPER_H_
#define DRIVER_STEPPER_STEPPER_H_

#include "stm32f4xx_hal.h"

#define STEPPER_PHASES      4u      /**< IN1..IN4 */

typedef struct {
	GPIO_TypeDef *port;
	uint16_t      pin;
} stepper_pin_t;

typedef enum {
	STEPPER_CW  = +1,   /**< IN1 -> IN2 -> IN3 -> IN4 order (flip if wired the other way) */
	STEPPER_CCW = -1,
} stepper_dir_t;

/**
 * Configure the four pins as push-pull outputs (clock enable included) and
 * leave every coil de-energised. @param pins IN1, IN2, IN3, IN4 in that order.
 */
void stepper_init(const stepper_pin_t pins[STEPPER_PHASES]);

/** Advance one half-step (4096 per output-shaft revolution, nominal). */
void stepper_step(stepper_dir_t dir);

/** De-energise all coils: no holding torque, no heat. */
void stepper_release(void);

/** Bring-up helper: drive the coils directly (bit n = IN(n+1)). */
void stepper_write_raw(uint8_t mask);

#endif /* DRIVER_STEPPER_STEPPER_H_ */
