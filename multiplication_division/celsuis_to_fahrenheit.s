@ --- ARM Assembly Program: Celsius to Fahrenheit Converter ---
@
@ This program prompts the user for a temperature in Celsius,
@ reads the input, converts it to Fahrenheit, and prints the result.
@ It is designed for a 32-bit ARM architecture, such as a Raspberry Pi
@ running a 32-bit OS.
@
@ This version avoids using PUSH/POP for saving the link register,
@ instead using STR/LDR with manual stack pointer manipulation.
@
@ How to Compile and Run:
@ 1. Save this code as 'converter.s'
@ 2. Assemble: as -o converter.o converter.s
@ 3. Link with GCC: gcc -o converter converter.o
@ 4. Run: ./converter
@

.data
@ The .data section is used to declare initialized data or constants.
@ These labels point to null-terminated strings ('.asciz') for our I/O.

prompt_msg:
    .asciz "Enter a temperature in Celsius: "

scanf_format:
    .asciz "%d"  @ Format string for scanf to read a decimal integer

result_msg:
    .asciz "%d degrees Celsius is %d degrees Fahrenheit.\n"


.text
@ The .text section contains the executable code.
.global main

@ --- Main Program Entry Point ---
@ The 'main' function orchestrates the program flow.
main:
    @ Manually save Link Register and IP to the stack to maintain 8-byte alignment
    @ This is the equivalent of 'push {ip, lr}'
    sub sp, sp, #8          @ Allocate 8 bytes on the stack
    str ip, [sp, #0]        @ Store IP at the new top of the stack
    str lr, [sp, #4]        @ Store LR just above it
    
    @ 1. Prompt the user for input
    ldr r0, =prompt_msg     @ r0 = address of the prompt message (first argument for printf)
    bl printf               @ Branch with Link to the C printf function

    @ 2. Read an integer from the user using scanf
    sub sp, sp, #4          @ Allocate 4 bytes on the stack to store the input value
    mov r1, sp              @ r1 = address of the stack space (second argument for scanf)
    ldr r0, =scanf_format   @ r0 = address of the format string (first argument)
    bl scanf                @ Call the C scanf function to read an integer

    ldr r4, [sp]            @ Load the user's Celsius value from the stack into r4.
                            @ We use r4 because it is a callee-saved register, so its
                            @ value will be preserved across the function call below.
    add sp, sp, #4          @ Deallocate the 4 bytes from the stack, cleaning up.
    
    @ 3. Call the conversion function
    mov r0, r4              @ Move the Celsius value into r0 to pass it as the first argument
                            @ to our conversion function, following the AAPCS standard.
    bl celsius_to_fahrenheit @ Call our conversion function. The result (Fahrenheit)
                            @ will be returned in r0.

    @ 4. Print the final result
    mov r2, r0              @ Move the Fahrenheit result (from r0) into r2 (for the 3rd printf argument)
    mov r1, r4              @ Move the original Celsius value (from r4) into r1 (for the 2nd printf argument)
    ldr r0, =result_msg     @ Load the result message address into r0 (1st printf argument)
    bl printf               @ Call printf to display: "C degrees Celsius is F degrees Fahrenheit."

    @ 5. Exit the program cleanly
    mov r0, #0              @ Return 0 from main to indicate successful execution
    
    @ Manually restore IP and PC (from saved LR) and return from main
    @ This is the equivalent of 'pop {ip, pc}'
    ldr ip, [sp, #0]        @ Restore IP from the stack
    ldr pc, [sp, #4]        @ Restore PC with the saved LR value, causing a return
                            @ Note: sp is not adjusted here because loading into PC
                            @ immediately branches, and the OS will handle the final stack cleanup.


@ --- Celsius to Fahrenheit Converter Function ---
@ Converts a temperature from degrees Celsius to Fahrenheit.
@ Adheres to the ARM Procedure Call Standard (AAPCS).
@ Formula: F = (C * 9 / 5) + 32
@
@ Input:
@   r0: Celsius temperature (integer)
@
@ Output:
@   r0: Fahrenheit temperature (integer)
@
.global celsius_to_fahrenheit

celsius_to_fahrenheit:
    @ Manually save the Link Register to the stack
    @ This is the equivalent of 'push {lr}'
    sub sp, sp, #4          @ Decrement stack pointer to make space
    str lr, [sp]            @ Store the Link Register at the new top of the stack
    
    @ r0 already contains Celsius (C) as the first argument
    
    @ F = C * 9
    mov r1, #9              @ Load the constant 9 into a register. The standard MUL
                            @ instruction operates on two registers.
    mul r1, r0, r1          @ r1 = r0 * r1  (i.e., C * 9)

    @ F = (C * 9) / 5
    mov r2, #5              @ Load the constant 5 into a register
    sdiv r0, r1, r2         @ r0 = r1 / r2 (Signed Division). Result is now in r0.

    @ F = ((C * 9) / 5) + 32
    add r0, r0, #32         @ r0 = r0 + 32. The final result is now in r0.

    @ Manually restore the Program Counter from the stack and return
    @ This is the equivalent of 'pop {pc}'
    ldr pc, [sp], #4        @ Load PC from the stack and add 4 to SP (post-indexed addressing)
