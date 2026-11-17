#include <stdint.h>
#include <stdbool.h>

#define RCC_BASE       0x40023800UL
#define GPIOA_BASE     0x40020000UL
#define GPIOC_BASE     0x40020800UL

#define REG(addr)      (*(volatile uint32_t *)(addr))
#define RCC_AHB1ENR    REG(RCC_BASE + 0x30UL)

typedef struct {
    volatile uint32_t MODER;
    volatile uint32_t OTYPER;
    volatile uint32_t OSPEEDR;
    volatile uint32_t PUPDR;
    volatile uint32_t IDR;
    volatile uint32_t ODR;
    volatile uint32_t BSRR;
    volatile uint32_t LCKR;
    volatile uint32_t AFRL;
    volatile uint32_t AFRH;
} gpio_regs_t;

#define GPIO_A ((gpio_regs_t *)GPIOA_BASE)
#define GPIO_C ((gpio_regs_t *)GPIOC_BASE)

typedef enum {
    GPIO_MODE_IN     = 0,
    GPIO_MODE_OUT    = 1,
    GPIO_MODE_AF     = 2,
    GPIO_MODE_ANALOG = 3
} gpio_mode_t;

typedef enum {
    GPIO_PULL_NONE = 0,
    GPIO_PULL_UP   = 1,
    GPIO_PULL_DOWN = 2
} gpio_pull_t;

void gpio_set_mode(gpio_regs_t *port, uint16_t pin,
                   gpio_mode_t mode)
{
    uint32_t shift = (uint32_t)pin * 2U;
    uint32_t v = port->MODER;

    v &= ~(3U << shift);
    v |= (uint32_t)mode << shift;

    port->MODER = v;
}

void gpio_set_pull(gpio_regs_t *port, uint16_t pin,
                   gpio_pull_t pull)
{
    uint32_t shift = (uint32_t)pin * 2U;
    uint32_t v = port->PUPDR;

    v &= ~(3U << shift);
    v |= (uint32_t)pull << shift;

    port->PUPDR = v;
}

void gpio_write(gpio_regs_t *port, uint16_t pin, bool level)
{
    port->BSRR = level
        ? (1U << pin)
        : (1U << (pin + 16U));
}

bool gpio_read(const gpio_regs_t *port, uint16_t pin)
{
    return ((port->IDR >> pin) & 1U) != 0U;
}

void gpio_toggle(gpio_regs_t *port, uint16_t pin)
{
    uint32_t mask = 1U << pin;
    uint32_t odr = port->ODR;

    port->BSRR = ((odr & mask) << 16U) | (~odr & mask);
}

int main(void)
{
    // GPIOA, GPIOC 클록 활성화
    RCC_AHB1ENR |= (1U << 0) | (1U << 2);
    (void)RCC_AHB1ENR;

    // PA5: 초기 LOW, push-pull, 출력 모드
    gpio_write(GPIO_A, 5, false);
    GPIO_A->OTYPER &= ~(1U << 5);
    gpio_set_mode(GPIO_A, 5, GPIO_MODE_OUT);

    // PC13: 입력, pull-up
    gpio_set_mode(GPIO_C, 13, GPIO_MODE_IN);
    gpio_set_pull(GPIO_C, 13, GPIO_PULL_UP);

    while (1)
    {
        // 버튼을 누르면 LOW인 회로 기준
        bool pressed = !gpio_read(GPIO_C, 13);
        gpio_write(GPIO_A, 5, pressed);
    }
}
