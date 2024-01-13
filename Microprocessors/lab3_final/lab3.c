#include <stdio.h>
#include <gpio.h>
#include <uart.h>
#include <string.h>
#include <stdlib.h>
#include <leds.h>
#include <platform.h>
#include <queue.h>
#include <timer.h>
#include <dht11.h>
#include <delay.h>


void uart_rx_isr(uint8_t a);
void tmp(void);
void switch_press_isr(int status);
void timer_isr(void);
void print_isr(void);

static int aemFlag = 0;                                                        /*Flag to check if the AEM was given*/
static int tmpFlag = 0;                                                        /*0 -> off, 1 -> on, 2 -> blink*/
static int switchFlag = 0;                                                     /*Flag to check if the switch is pressed*/
static int switchCount = 0;                                                    /*this variable counts how many times the switch is pressed*/
static Queue rx_queue;                                                       	 /*this variable will be used to hold the given AEM in the callback(in function uart-rx_isr)*/
static int aemCount = 0;																											 /*counts the number of characters of the AEM*/
static int getTempFlag = 0;																										 /*Flag to check if the timer has hit*/
volatile uint32_t our_timer_period;																						 /*variable that represents the period of the timer*/
static dht11_TypeDef dht11; 																								   /*variable that contains the data send by the sensor*/
static int counter = 0;

/*static char test[100];*/



int main(void){
		uint8_t i, j = 0;

	  __enable_irq();																/*enables all interrupts*/
		queue_init(&rx_queue, 128);										/*initializes a queue*/
	
		uart_init(115200);														/*initializes uart*/
		uart_set_rx_callback(uart_rx_isr);						/*when there is an interrupt initiates callback and calls funtion uart_rx_isr*/
	  uart_enable();																/*enables uart*/
	
		leds_init();																	/*sets LED to mode Output*/
    leds_set(0,0,0);															/*sets LED to zero*/
		
		dht11_init(&dht11, 0, 0, DHT11_PIN);					/*initialises dht11*/
    
		uart_print("Give me your AEM: \r\n");         
	
		while(1){																			/*waits until the AEM is given and flag equals 1*/
			if(aemFlag==1)
				break;
		}
	  
		our_timer_period = 2;													/*sets the period of the timer to 2s*/
 
    timer_init(1000000);													/*initialises the timer with the period 1s*/
    timer_set_callback(timer_isr);								/*when the timer hits, initiates callback and calls function timer_isr*/
    timer_enable();																/*enables timer*/ 
	
		
	  gpio_set_mode(P_SW, PullUp);     			        /*initializes switch to mode PullUp*/
    gpio_set_trigger(P_SW, Rising);			        	/*sets trigger to Rising, meaning that the interrupts are triggered when the switch goes from low to high*/
    gpio_set_callback(P_SW, switch_press_isr);		/*when there is an interrupt initiates callback and calls funtion button_press__isr*/
	  

		
    


		while(1){
				if(switchFlag == 1){															/*if the flag is 1, meaning the button is pressed*/		
					switchCount++;																			
					if(switchCount == 1){
						i = rx_queue.data[aemCount - 1] - '0';		      /*i holds the last digit of aem, j holds the second to last digit and time_period gets their sum.*/
						j = rx_queue.data[aemCount - 2] - '0';
						our_timer_period = (uint32_t)(i + j);         /*e.g. if(i+j == 2) then our_timer_period = 2| pdf*/
					}
					else if(switchCount % 2 != 0){									/*if the switch is pressed odd number of times the our_timer_period becomes 3 seconds.*/
						our_timer_period = 3;
					}
					else if(switchCount % 2 == 0){									/*if the switch is pressed even number of times the our_timer_period becomes 4 seconds.*/
						our_timer_period = 4;
					}
					switchFlag = 0;
				}
				
				if(getTempFlag == 1){															/*checks if the timer has hit*/
					dht11_read(&dht11);															/*calls the function to start the communication with the sensor*/
					tmp();																					/*calls this funtion to change the flags concerning the value of the temperature*/
					getTempFlag = 0;
				}
				
								
				if(switchFlag == 0){
					if(tmpFlag == 1){
							gpio_set(P_LED_R, 1);								/*activates the LED*/
					}
					else if(tmpFlag == 0){
							gpio_set(P_LED_R, 0);								/*deactivates the LED*/
					}
					else if(tmpFlag == 2){
							while(tmpFlag ==2 && switchFlag == 0){																	/*blinks the LED*/
								gpio_toggle(P_LED_R);
								delay_ms(1000);
							}
					}
						aemCount = 0;                              /*c is set to zero in order to count characters all over again.*/
						rx_queue.head = 0;                  /*the next two instructions restore the variables tail and head to zero, so that the queue can be used again.*/
						rx_queue.tail = 0;
						tmpFlag = 0;												/*turns the flag back to zero so it can be used again*/
				}
		}		


}

/*when the interrupt is triggered adds characters given from the keyboard to a Queue until it finds the character 'enter',
then it changes the ledFlag to 1, to signal the program*/
void uart_rx_isr(uint8_t a){
    if((char)a != '\r'){
        queue_enqueue(&rx_queue, a);                                       /*the characters given are saved in the array rx_queue.data*/
        aemCount++;  
                                                                           /*counts the number of characters given*/
    }
    else{
				aemFlag = 1;
    }
}

/*uses a counter which increases by 1 every time the timer hits(every second) until it reaches the value of our_timer_period variable Then it changes the value
of the flag to 1 and sets the counter back to zero.*/
void timer_isr(void){
		if(counter < (int)our_timer_period){
			counter++;
		}
		else if(counter == (int)our_timer_period){
			counter = 0;
			getTempFlag = 1;
		}
	}
/*changes the value of the flag depending on the temperature*/
void tmp(void){
		
	if(((int)dht11.temperature) >= 20 && ((int)dht11.temperature) <= 25){
			tmpFlag = 2;			/*blink LED if temp is between 20?C and 25?C*/
		}
		else if(((int)dht11.temperature) < 20){
			tmpFlag = 0;      /*turn off led if temp < 20?C*/
		}
		else{
			tmpFlag = 1;      /*turn on led if temp > 25?C*/
		}
		print_isr();
}

/*prints the temperature and the sampling rate*/
void print_isr(void){
	char s1[100], s2[100];
	sprintf(s1, "The temperature is %d degrees Celsius \r\n", (int)dht11.temperature);
	uart_print(s1);
	sprintf(s2, "The sampling rate is %d \r\n", our_timer_period);
	uart_print(s2);
}
/*hanges the value of the flag to 1*/
void switch_press_isr(int status){
			switchFlag = 1;
}


