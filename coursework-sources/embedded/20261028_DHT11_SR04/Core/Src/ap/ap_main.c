#include "ap_main.h"
#include "../driver/button/button.h"
#include "service/temp_humid/temp_humid.h"
#include "service/display/display.h"
#include "service/distance/distance.h"
#include <stdio.h>

static button_t btn;

int ap_main(void)
{
    button_init(&btn, GPIOC, GPIO_PIN_0);
    TH_init();
    distance_init();
    display_init();

    while (1) {
        if (button_getState(&btn) == ACT_RELEASE) {
            distance_request();
        }
        distance_task();
        TH_task();
        display_task();
    }
}
