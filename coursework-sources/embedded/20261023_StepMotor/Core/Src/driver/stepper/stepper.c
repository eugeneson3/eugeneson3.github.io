#include "stepper.h"

#define HALF_STEP_COUNT     8u

/* Half-step sequence A, AB, B, BC, C, CD, D, DA. Bit n drives IN(n+1). */
static const uint8_t k_half_step[HALF_STEP_COUNT] = {
	0x1, 0x3, 0x2, 0x6, 0x4, 0xC, 0x8, 0x9,
};

static stepper_pin_t s_pin[STEPPER_PHASES];
static uint8_t       s_index;

static void enable_port_clock(const GPIO_TypeDef *port)
{
	if (port == GPIOA)      { __HAL_RCC_GPIOA_CLK_ENABLE(); }
	else if (port == GPIOB) { __HAL_RCC_GPIOB_CLK_ENABLE(); }
	else if (port == GPIOC) { __HAL_RCC_GPIOC_CLK_ENABLE(); }
}

static void write_coils(uint8_t mask)
{
	for (unsigned i = 0; i < STEPPER_PHASES; i++) {
		/* BSRR: one atomic write per pin (low half sets, high half resets). */
		s_pin[i].port->BSRR = ((mask >> i) & 1u)
		                    ? (uint32_t)s_pin[i].pin
		                    : ((uint32_t)s_pin[i].pin << 16u);
	}
}

void stepper_init(const stepper_pin_t pins[STEPPER_PHASES])
{
	GPIO_InitTypeDef init = {0};

	init.Mode  = GPIO_MODE_OUTPUT_PP;
	init.Pull  = GPIO_NOPULL;
	init.Speed = GPIO_SPEED_FREQ_LOW;

	for (unsigned i = 0; i < STEPPER_PHASES; i++) {
		s_pin[i] = pins[i];
		enable_port_clock(s_pin[i].port);
		HAL_GPIO_WritePin(s_pin[i].port, s_pin[i].pin, GPIO_PIN_RESET);
		init.Pin = s_pin[i].pin;
		HAL_GPIO_Init(s_pin[i].port, &init);
	}
	s_index = 0;
}

void stepper_step(stepper_dir_t dir)
{
	s_index = (uint8_t)((s_index + HALF_STEP_COUNT + (unsigned)(int)dir) % HALF_STEP_COUNT);
	write_coils(k_half_step[s_index]);
}

void stepper_release(void)
{
	write_coils(0);
}

void stepper_write_raw(uint8_t mask)
{
	write_coils(mask);
}
