@
@ Program: multiply_by_10.s
@ Author: Gemini
@ Date: 2024-06-21
@
@ Description: This program prompts the user for an integer, multiplies it by 10
@              using only logical left shift and add instructions, and then
@              prints the result to the console. This version uses manual
@              stack pointer manipulation to save the link register.
@
@ Logic for multiplying by 10:
@   x * 10 = x * (8 + 2)
@   x * 10 = (x * 8) + (x * 2)
@   In ARM Assembly, this translates to:
@   (x << 3) + (x << 1)  (where << is a logical left shift)
@

.global main

.data
@ Format strings for printf and scanf
prompt_str:   .asciz "Enter an integer: "
scanf_format: .asciz "%d"
result_str:   .asciz "You entered %d. The result of multiplying by 10 is %d.\n"

.text

@ Entry point of the program
main:
    @ Prologue: Manually create a stack frame.
    @ Allocate 8 bytes on the stack: 4 for the local variable and 4 for the link register.
    sub     sp, sp, #8
    @ Save the link register (return address) in the upper 4 bytes of our stack frame.
    str     lr, [sp, #4]

    @ --- Print the prompt to the user ---
    @ Load the address of the prompt string into r0
    ldr r0, =prompt_str
    @ Call printf to display the prompt
    bl printf

    @ --- Read user input using scanf ---
    @ Load the address of the format string for scanf into r0
    ldr r0, =scanf_format
    @ Load the address for the input integer into r1. This is the bottom of our
    @ stack frame, pointed to by sp.
    mov r1, sp
    @ Call scanf to read the integer
    bl scanf

    @ --- Perform the multiplication ---
    @ Load the integer entered by the user from the stack into r4.
    @ It's located at the address pointed to by sp.
    ldr r4, [sp]

    @ Calculate r4 * 2
    @ lsl r1, r4, #1  ; r1 = r4 * 2
    lsl r1, r4, #1

    @ Calculate r4 * 8
    @ lsl r2, r4, #3  ; r2 = r4 * 8
    lsl r2, r4, #3

    @ Add the two results together: (r4 * 2) + (r4 * 8)
    @ add r5, r1, r2  ; r5 = (r4 * 2) + (r4 * 8) = r4 * 10
    add r5, r1, r2

    @ --- Print the final result ---
    @ Load the address of the result string format into r0
    ldr r0, =result_str
    @ The original number (from r4) is the second argument for printf
    mov r1, r4
    @ The calculated result (from r5) is the third argument for printf
    mov r2, r5
    @ Call printf to display the result
    bl printf

    @ --- Epilogue and exit ---
    @ Set the return code to 0 (successful execution)
    mov r0, #0
    @ Restore the link register from the stack.
    ldr     lr, [sp, #4]
    @ Deallocate the space we used on the stack.
    add     sp, sp, #8
    @ Return from main by branching to the address in the link register.
    bx      lr
