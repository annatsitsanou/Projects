#include <stdio.h>
#include <gpio.h>
#include <uart.h>
#include <string.h>
#include <stdlib.h>
#include <leds.h>
#include <platform.h>
#include <queue.h>

/*functons that will be analyzed below the main function*/
void uart_rx_isr(uint8_t a);
void switch_press_isr(int status);

static int ledFlag = 0;														/*Flag to check if the AEM was given*/
static int switchFlag = 0;												/*Flag to check if the switch is pressed*/
static int counter = 0;                   				/*this variable counts how many times the switch is pressed*/
static Queue rx_queue;														/*this variable will be used to hold the given AEM in the callback(in function uart-rx_isr) */
static int c = 0;																	/*this variable counts the number of characers given from the UART*/


int main(void){

 
	int  j;																  				/*j is used to store the AEM convetred from char to int*/
	
	__enable_irq();																	/*enbles IRQ interrupts*/
    

		
		queue_init(&rx_queue, 128);										/*initializes a queue*/
	
		uart_init(115200);														/*initializes uart*/
		uart_set_rx_callback(uart_rx_isr);						/*when there is an interrupt initiates callback and calls funtion uart_rx_isr*/
	  uart_enable();																/*enables uart*/

    leds_init();																	/*sets LED to mode Output*/
    leds_set(0,0,0);															/*sets LED to zero*/
	
		
		
    

    gpio_set_mode(P_SW, PullUp);     							/*initializes switch to mode PullUp*/
    gpio_set_trigger(P_SW, Rising);								/*sets trigger to Rising, meaning that the interrupts are triggered when the switch goes from low to high*/
    gpio_set_callback(P_SW, switch_press_isr);		/*when there is an interrupt initiates callback and calls funtion switch_press__isr*/
 
   
		

		uart_print("Give me your AEM: \r\n");
  
			
		while(1)
			{
				if(switchFlag == 1){															/*if the flag is 1, meaning the switch is pressed*/		
					char s2[100];																		/*this array is used for the uart_print*/ 
					uart_print("I'm in switch press\r\n");  				/*extra print for testing*/

					if(gpio_get(P_LED_R)){
																													/*if the switch is pressed and the LED is already activated*/
							gpio_set(P_LED_R, 0);												/* deactivates the LED*/
							counter++;																	/*ups the counter by 1*/
							sprintf(s2, "The number of switch has been pressed is: %d\r\n", counter);
							uart_print(s2);															/*prints the number of times the switch was pressed*/
					}
					else{
																													/*if the switch is pressed and the LED is deactivated*/
							gpio_set(P_LED_R, 1);												/*actives LED*/
							counter++;																	/*ups the counter by 1*/
							sprintf(s2, "The number of switch has been pressed is: %d\r\n", counter);
							uart_print(s2);															/*prints the number of times the switch was pressed*/
					}
					switchFlag = 0;																	/*turns the flag back to zero so it can be used again*/
				}					
				
				/*if ledFlag is 1, meaning an AEM was given, and switchFlag is 0(giving priority to the switch)*/
			if(ledFlag == 1 && switchFlag == 0){

				
					
					j = (int)rx_queue.data[c-1] - 48;								/*turns the last character of the AEM to an integer*/
					
					if(j%2 == 0){																		/*if the integer is an even number*/
						gpio_set(P_LED_R, 0);													/*deactivates the LED*/
					}
					else{																						/*if the integer is an odd number*/
						gpio_set(P_LED_R, 1);													/*activates the LED*/
					}	
					c = 0;                              						/*c is set to zero in order to count characters all over again.*/
					rx_queue.head = 0;                 						  /*the next two instructions restore the variables tail and head to zero, so that the queue can be used again.*/
					rx_queue.tail = 0;
					ledFlag = 0;																	 	/*turns the flag back to zero so it can be used again*/
				}
				
			}
		
}
	 
	
/*when the interrupt is triggered adds characters given from the keyboard to a Queue until it finds the character 'enter',
then it changes the ledFlag to 1, to signal the program*/
void uart_rx_isr(uint8_t a){	
	if((char)a != '\r'){
	  queue_enqueue(&rx_queue, a);															/*the characters given are saved in the array rx_queue.data*/
		uart_print("added to queue \r\n");
		c++; 																											/*counts the number of characters given*/
	}
	else{
			
		ledFlag = 1;
		uart_print(" flag = 1 \r\n");
	}

}
 
/*when the interrupt is triggered,
it changes the switchFlag to 1, to signal the program*/
void switch_press_isr(int status){
			switchFlag = 1;
}

