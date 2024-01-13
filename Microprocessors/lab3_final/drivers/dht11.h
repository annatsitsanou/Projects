#ifndef DHT11_H_
#define DHT11_H_


#include <stm32f4xx_rcc.h>
#include <stm32f4xx_gpio.h>

#include "gpio.h"

/*define DHT11 PIN*/

#define DHT11_PIN  PA_9																													/*defines the pin of the board connected to the sensor */

/*contains the types of data received from the sensor*/
typedef struct {
    uint8_t humidity;
    uint8_t temperature;
    Pin pin;
} dht11_TypeDef;


uint8_t dht11_read_byte(void);                                                  /*read 1 byte of the data send from the sensor*/ 
uint8_t dht11_read(dht11_TypeDef *dht11);                                        /*starts the reading of the data and puts the data to the corresponding variables*/
uint8_t dht11_start(void);                                                      /*starts the process to prepare the mcu and the sensor to communicate*/
void dht11_init(dht11_TypeDef *dht11, uint8_t hum, uint8_t tmp, Pin pin);		 /*initialises the sensor*/
#endif /* DHT11_H_ */






