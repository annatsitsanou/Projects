#include <stdio.h>
	#include <uart.h>
	#include <string.h>
	#include <stdlib.h>

	extern int myhash(char table[]);
	extern int factorial(int x);
	int letterToNumber(char a);

	int main(void){
		
		
		int i;
		char *str;  										/*this variable will hold the string that is given*/
		int table[100];									/*this variable is only used for a few extra printfs*/
		char s1[100];										/*this variable will be used to print the hash*/
		char s2[100];										/*this variable will be used to print the factorial*/
		str = malloc(100*sizeof(char));
		
		uart_init(115200);
		uart_enable();
		
		printf("Give me a string: ");
		scanf("%s", str);
		printf("\nNumber of characters in the string: %d", (int)strlen(str));
		
		/*this for loop is used to print the characters given and the integer values they correspond to*/
		for(i = 0; i < (int)strlen(str); i++){
			table[i] = letterToNumber(str[i]);  /* turns a character to an integer and loads to the table */
			printf("\ncharacter %c is the number %d",  str[i], table[i]);
		}
		/*the following sprintfs convert the integers returned by the assembly functions in to strings so they can be printed by uart_print*/ 
		sprintf(s1, "The hash of the string is  %d", myhash(str));
		sprintf(s2, "The factorial of the one digit hash is %d", factorial(myhash(str)));
		uart_print(s1);
		uart_print("\r\n");
		uart_print(s2);
		return 0;
		
	}
	
	
	
	
	/*this functions is ONLY used to turn the characters to the integers they correspond for presentation purposes and to help with the debugging*/

	int letterToNumber(char a){
		
		int number;
		
		switch(a){
			case 'A':
				number = 10;
				break;
			case 'B':
				number = 42;
				break;
			case 'C':
				number = 12;
				break;
			case 'D':
				number = 21;
				break;
			case 'E':
				number = 7;
				break;
			case 'F':
				number = 5;
				break;
			case 'G':
				number = 67;
				break;
			case 'H':
				number = 48;
				break;
			case 'I':
				number = 69;
				break;
			case 'J':
				number = 2;
				break;
			case 'K':
				number = 36;
				break;
			case 'L':
				number = 3;
				break;
			case 'M':
				number = 19;
				break;
			case 'N':
				number = 1;
				break;
			case 'O':
				number = 14;
				break;
			case 'P':
				number = 51;
				break;
			case 'Q':
				number = 71;
				break;
			case 'R':
				number = 8;
				break;
			case 'S':
				number = 26;
				break;
			case 'T':
				number = 54;
				break;
			case 'U':
				number = 75;
				break;
			case 'V':
				number = 15;
				break;
			case 'W':
				number = 6;
				break;
			case 'X':
				number = 59;
				break;
			case 'Y':
				number = 13;
				break;
			case 'Z':
				number = 25;
				break;
			case '1':
				number = -1;
				break;
			case '2':
				number = -2;
				break;
			case '3':
				number = -3;
				break;
			case '4':
				number = -4;
				break;
			case '5':
				number = -5;
				break;
			case '6':
				number = -6;
				break;
			case '7':
				number = -7;
				break;
			case '8':
				number = -8;
				break;
			case '9':
				number = -9;
				break;
			default:
				number = 0;
				break;
		}
		return number;
	}
	
	
	
	
	
