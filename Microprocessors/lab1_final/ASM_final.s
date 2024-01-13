.global myhash
    .p2align 2
    .type myhash,%function

myhash:                @Function "myhash" entry point
    .fnstart
		   push {lr}
           mov    r2, #0          @moves the value 0 to r2
	loop:  ldrb    r1, [r0], #1   @loads one byte of the value that is located in the address of the function's argument with an offset of 1 byte 
           
		   cmp    r1, #0		  @compares the value of the register with the value of the last slot of the table
		   beq    end_procedure
		   
		   
		   @if the value of the register is not '\0' it compares the value with each following character
		   @if the character is a letter, it adds the value that the letter is equivalent to in the table given to r2
		   @if the character is a number, it subtracts the value of the integer it corresponds to from r2
		   @in any other case, it branches to loop
		   cmp    r1, #'A'		   
           it eq
		   addeq  r2, r2, 10
		   beq    loop
           
		   cmp    r1, #'B'		   
           it eq
		   addeq  r2, r2, 42
		   beq    loop
		   
		   cmp    r1, #'C'		   
           it eq
		   addeq  r2, r2, 12
		   beq    loop
		   
		   cmp    r1, #'D'		   
           it eq
		   addeq  r2, r2, 21
		   beq    loop
		   
		   cmp    r1, #'E'		   
           it eq
		   addeq  r2, r2, 7
		   beq    loop
		   
		   cmp    r1, #'F'		   
           it eq
		   addeq  r2, r2, 5
		   beq    loop
		   
		   cmp    r1, #'G'		   
           it eq
		   addeq  r2, r2, 67
		   beq    loop
		   
		   cmp    r1, #'H'		   
           it eq
		   addeq  r2, r2, 48
		   beq    loop
		   
		   cmp    r1, #'I'		   
           it eq
		   addeq  r2, r2, 69
		   beq    loop
		   
		   cmp    r1, #'J'		   
           it eq
		   addeq  r2, r2, 2
		   beq    loop
		   
		   cmp    r1, #'K'		   
           it eq
		   addeq  r2, r2, 36
		   beq    loop
		   
		   cmp    r1, #'L'		   
           it eq
		   addeq  r2, r2, 3
		   beq    loop
		   
		   cmp    r1, #'M'		   
           it eq
		   addeq  r2, r2, 19
		   beq    loop
		   
		   cmp    r1, #'N'		   
           it eq
		   addeq  r2, r2, 1
		   beq    loop
		   
		   cmp    r1, #'O'		   
           it eq
		   addeq  r2, r2, 14
		   beq    loop
		   
		   cmp    r1, #'P'		   
           it eq
		   addeq  r2, r2, 51
		   beq    loop
		   
		   cmp    r1, #'Q'		   
           it eq
		   addeq  r2, r2, 71
		   beq    loop
		   
		   cmp    r1, #'R'		   
           it eq
		   addeq  r2, r2, 8
		   beq    loop
		   
		   cmp    r1, #'S'		   
           it eq
		   addeq  r2, r2, 26
		   beq    loop
		   
		   cmp    r1, #'T'		   
           it eq
		   addeq  r2, r2, 54
		   beq    loop
		   
		   cmp    r1, #'U'		   
           it eq
		   addeq  r2, r2, 75
		   beq    loop
		   
		   cmp    r1, #'V'		   
           it eq
		   addeq  r2, r2, 15
		   beq    loop
		   
		   cmp    r1, #'W'		   
           it eq
		   addeq  r2, r2, 6
		   beq    loop
		   
		   cmp    r1, #'X'		   
           it eq
		   addeq  r2, r2, 59
		   beq    loop
		   
		   cmp    r1, #'Y'		   
           it eq
		   addeq  r2, r2, 13
		   beq    loop
		   
		   cmp    r1, #'Z'		   
           it eq
		   addeq  r2, r2, 25
		   beq    loop
		   
		   cmp    r1, #'1'		   
           it eq
		   subeq  r2, r2, 1
		   beq    loop
		   
		   cmp    r1, #'2'		   
           it eq
		   subeq  r2, r2, 2
		   beq    loop
		   
		   cmp    r1, #'3'		   
           it eq
		   subeq  r2, r2, 3
		   beq    loop
		   
		   cmp    r1, #'4'		   
           it eq
		   subeq  r2, r2, 4
		   beq    loop
		   
		   cmp    r1, #'5'		   
           it eq
		   subeq  r2, r2, 5
		   beq    loop
		   
		   cmp    r1, #'6'		   
           it eq
		   subeq  r2, r2, 6
		   beq    loop
		   
		   cmp    r1, #'7'		   
           it eq
		   subeq  r2, r2, 7
		   beq    loop
		   
		   cmp    r1, #'8'		   
           it eq
		   subeq  r2, r2, 8
		   beq    loop
		   
		   cmp    r1, #'9'		   
           it eq
		   subeq  r2, r2, 9
		   b    loop          @if the value of the register is not a number or a capital letter, it branches to loop


	end_procedure:
		   cmp r2, #0			@checks if the hash computed is negative and, if it is, moves the value 0xff to the register r2 
		   it lt
		   movlt r2, #0xff
		   
		   mov r0, r2			@moves the value of the hash to the return register
		   pop{lr}
		   bx lr
    .fnend
	
	.global factorial
    .p2align 2
    .type factorial,%function

factorial:            @function "factorial" entry point
    .fnstart
            push {lr}
            mov   r1, r0          @moves the argument of the function to r1
            mov   r2, #0          @moves the value 0 to r2
    comp:    cmp   r1, #10         @compares the value with 10 so we can check if the argument has two or more digits
            mov   r3, #0            @moves the value 0 to r3
            bge   loop1
            add   r1, r1, r2       @adds the final digit, so r1 now contains the one digit hash number
            cmp  r1, #10
            bge   two_digits_after_addition  @if after the first addition the number is still greater than 10, it branches to two_digits_after_addition
            mov   r2, #1
            b      fact

    two_digits_after_addition:		
            mov   r2, #0			          @clears the register r2 so it can be used anew for the repeatition of comp 
            b comp

    loop1:  sub   r1, r1, #10     @subtracts the value 10 from the argument
            add   r3, r3, #1      @counts how many times the value 10 is subtracted from the argument
            cmp   r1, #10          @checks if the argument still has two or more digits
            bge   loop1           @if the comparison above is true, repeats the loop1
            add   r2, r2, r1      @if r1 has 1 digit, adds the digit to r2
            mov   r1, r3          @moves the value of r3 to r1 so it can be compared with 10 and, if it's true, repeat the process above
            b     comp

    fact:   mul   r2, r2, r1      @multiplies r2 with the value of r1
            sub   r1, r1, #1      @subtracts 1 from r1
            cmp   r1, #0          @compares r1 with zero
            bne   fact            @if r1 is not equal to zero, branch to fact
            mov   r0, r2          @moves the value of r2 to r0, so r0 now contains the factorial of the on difgit hash number
            pop {lr}
            bx lr
    .fnend