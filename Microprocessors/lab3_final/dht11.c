#include "dht11.h"
#include "platform.h"
#include "stm32f4xx_rcc.h"
#include "stm32f4xx_usart.h"
#include "stm32f4xx_gpio.h"
#include "delay.h"
#include "uart.h"
#include "queue.h"
#include "stdio.h"

uint8_t dht11_start(void);
uint8_t dht11_read_byte(void);
uint8_t dht11_read(dht11_TypeDef *dht11);
void dht11_init(dht11_TypeDef *dht11, uint8_t hum, uint8_t tmp, Pin pin);

/*initialises the variable that contains the data received from the sensor and with the values given when its called */
void dht11_init(dht11_TypeDef *dht11, uint8_t hum, uint8_t tmp, Pin pin){
	dht11->humidity = hum;
	dht11->temperature = tmp;
	dht11->pin = pin;
	gpio_set_mode(DHT11_PIN, Output);													/*sets the pin mode to output, so the mcu can send a signal to the sensor*/
	gpio_set(DHT11_PIN, 1);																		/*sends high voltage signal to the sensor(free status)*/
}
/*starts the communication between the sensor and the microprocessor*/
uint8_t dht11_start(void){
/*uart_print(" start ");*/
		
	
	gpio_set(DHT11_PIN, 0);						                  /*lowers the voltage to signal the sensor*/
	delay_ms(18);																				/*delays the for 18ms to keep the voltage to low for that period of time*/

	gpio_set(DHT11_PIN, 1);															/*turns the voltage from low to high and keeps it there for 20us, using the following instruction*/
	delay_us(20);
	
	gpio_set_mode(DHT11_PIN, Input);										/*turns the mode of the pin to input, so it can receive signals from the sensor*/
		
		while(1){                                       /*waits until the signal turns send by the sensor turns to low*/
		if(gpio_get(DHT11_PIN) == 0){
				break;
			}
		}
		
		delay_us(80);                                     /*delays 80us, the amount of time the sensor sends low voltage signsl*/
	
		if(gpio_get(DHT11_PIN) == 0){											/*if the signal continues to be zero, there is an error and returns zero*/
			/*uart_print("start2 = 0\r\n");*/
			return 0;
		}
		while(1){																					/*waits until the signal turns to low to prepare the mcu to receive data*/
			if(gpio_get(DHT11_PIN) == 0){
				break;
			} 
		}

		return 1;
}

/*reads 1 byte of the data send by the sensor*/
uint8_t dht11_read_byte(void) {
	uint8_t data = 0;                                   /*this variable contains the 1 byte send by the sensor*/
	int j;																							/*this variable is used in the for loop*/

	
	
	for (j = 0; j < 8; ++j) {														/*this loop repaets the process of reading a bit 8 times to get 1 byte*/
		
		
		while(1){																					/*waits until the signal of the sensor turns from low to high(50us)*/
			if(gpio_get(DHT11_PIN)){
				break;
			}
		}
			delay_us(28);																		/*delays 28us, the amount of time the signal remains high to transmit the bit 0*/
		
			if(gpio_get(DHT11_PIN)){												/*if the sugnal of the pin is high, meaning the bit transmitted is 1*/
				
					data |= (1 << (7-j));												/*shifts the bit 1 left the amount of times it takes to put it in the correct place of the byte and stores it in data*/
				
					delay_us(42);																/*delays 42us more so it reaches the 70us it takes to transmit bit 1 and the sensor is ready to send the next bit*/
				}
					
		
		}
		
		return data;
}

/*starts the reading of the data and stores them to the variables of dht11 if the communication was successfull*/
uint8_t dht11_read(dht11_TypeDef *dht11) {

	if (dht11_start()) {																/*calls the function dht11_start and if it returns 1:*/
		uint16_t sum;
		
		uint8_t hum_b1 = dht11_read_byte();								/*stores the first byte read in the variable hum_b1*/
		uint8_t hum_b2 = dht11_read_byte();								/*stores the second byte read in the variable hum_b2*/
		uint8_t tmp_b1 = dht11_read_byte();								/*stores the third byte read in the variable tmp_b1*/
		uint8_t tmp_b2 = dht11_read_byte();								/*stores the fourth byte read in the variable tmp_b2*/
		uint16_t check_sum = dht11_read_byte();						/*stores the fifth byte read in the variable c_sum*/
		
		gpio_set_mode(DHT11_PIN, Output);									/*sets the pin mode to output, so the mcu can send a signal to the sensor*/
	  gpio_set(DHT11_PIN, 1);							              /*sends high voltage signal to the sensor(free status)*/
		
		sum = hum_b1 + hum_b2 + tmp_b1 + tmp_b2;					/*stores in variable sum the sum of the 4 first bytes read*/
		if (check_sum == sum ) {													/*if the sum is equal to the fifth byte the communication was successfull*/
			dht11->humidity = hum_b1;												/*stores the integral byte of the humidity at the variable humidity of dht11*/
			dht11->temperature = tmp_b1;										/*stores the integral byte of the temperature at the variable temperature of dht11*/
			return 1;
		}
	}

	return 0;
}


