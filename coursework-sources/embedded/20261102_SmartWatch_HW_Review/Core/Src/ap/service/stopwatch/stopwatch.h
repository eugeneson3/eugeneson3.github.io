/*
 * stopwatch.h
 *
 *  Created on: 2026. 10. 16.
 *      Author: kccistc
 */

#ifndef SRC_AP_STOPWATCH_STOPWATCH_H_
#define SRC_AP_STOPWATCH_STOPWATCH_H_
#include <stdint.h>
typedef enum {STOP, RUN, CLEAR} stopwatch_t;

void Stopwatch_Task(uint8_t is_stopwatch);
void Stopwatch_Init(void);
void stopwatch_set_state(stopwatch_t s);

#endif /* SRC_AP_STOPWATCH_STOPWATCH_H_ */
