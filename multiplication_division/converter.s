.data
@ The .data section is used to declare initialized data or constants.

prompt_msg:
    .asciz "Enter a temperature in Fahrenheit: "

scanf_format:
    .asciz "%d"  @ Format string for scanf to read a decimal integer

result_msg:
    .asciz "%d degrees Fahrenheit is %d degrees Celsius.\n"


.text
@ The .text section contains the executable code.
.global main

@ --- Main Program Entry Point ---
@ The 'main' function orchestrates the program flow.
main:
    @ Manually save Link Register and IP to the stack to maintain 8-byte alignment
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

    ldr r4, [sp]            @ Load the user's Fahrenheit value from the stack into r4.
    add sp, sp, #4          @ Deallocate the 4 bytes from the stack, cleaning up.
    
    @ 3. Call the conversion function
    mov r0, r4              @ Move the Fahrenheit value into r0 to pass it as the first argument.
    bl fahrenheit_to_celsius @ Call our conversion function. The result (Celsius)
                            @ will be returned in r0.

    @ 4. Print the final result
    mov r2, r0              @ Move the Celsius result (from r0) into r2 (for the 3rd printf argument)
    mov r1, r4              @ Move the original Fahrenheit value (from r4) into r1 (for the 2nd printf argument)
    ldr r0, =result_msg     @ Load the result message address into r0 (1st printf argument)
    bl printf               @ Call printf to display the result.

    @ 5. Exit the program cleanly
    mov r0, #0              @ Return 0 from main to indicate successful execution
    
    @ Manually restore IP and PC (from saved LR) and return from main
    ldr ip, [sp, #0]        @ Restore IP from the stack
    ldr pc, [sp, #4]        @ Restore PC with the saved LR value, causing a return.

@ --- Fahrenheit to Celsius Converter Function ---
@ Converts a temperature from degrees Fahrenheit to Celsius.
@ Adheres to the ARM Procedure Call Standard (AAPCS).
@ Formula: C = (F - 32) * 5 / 9
@
@ Input:
@   r0: Fahrenheit temperature (integer)
@
@ Output:
@   r0: Celsius temperature (integer)
@
.global fahrenheit_to_celsius

fahrenheit_to_celsius:
    @ Manually save the Link Register to the stack
    sub sp, sp, #4          @ Decrement stack pointer to make space
    str lr, [sp]            @ Store the Link Register at the new top of the stack
    
    @ r0 already contains Fahrenheit (F) as the first argument
    
    @ C = F - 32
    sub r0, r0, #32         @ r0 = r0 - 32
    
    @ C = (F - 32) * 5
    mov r1, #5              @ Load the constant 5 into a register.
    mul r1, r0, r1          @ r1 = r0 * r1  (i.e., (F - 32) * 5)

    @ C = ((F - 32) * 5) / 9
    mov r2, #9              @ Load the constant 9 into a register
    sdiv r0, r1, r2         @ r0 = r1 / r2 (Signed Division). The final result is now in r0.

    @ Manually restore the Program Counter from the stack and return
    ldr pc, [sp], #4        @ Load PC from the stack and add 4 to SP (post-indexed addressing)
