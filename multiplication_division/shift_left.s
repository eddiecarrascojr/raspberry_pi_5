#
# Program: shift_left.s
# Author: Eduardo Carrasco Jr
# Date: 11/20/2025
#
# Purpose: Reads in user for an integer,
# then performs a left shift operation to multiply by 10,
#
# Inputs: 
#   - Integer of number to multiply by 10
#   - r0 as integer of number to multiply by 10

# Outputs:
#   - Integer of shifted and multiplied number
#   - r0 as integer of shifted and multiplied number
#

.text
.global main

main:
    # Manually create a stack frame.
    sub     sp, sp, #4
    str     lr, [sp, #0]

    # Print the prompt to the user
    ldr r0, =prompt_str
    bl printf

    # Read user input using scanf ---
    ldr r0, =scanf_format
    mov r1, sp
    bl scanf
    ldr r4, [sp]

    # Calculate r4 * 2
    lsl r1, r4, #1

    # Calculate r4 * 8
    lsl r2, r4, #3

    # Add the two results together: (r4 * 2) + (r4 * 8)
    add r5, r1, r2

    # Print the final result ---
    ldr r0, =result_str
    # The original number (from r4) is the second argument for printf
    mov r1, r4
    mov r2, r5
    bl printf

    # Exit the program
    mov r0, #0
    ldr     lr, [sp, #4]
    add     sp, sp, #8
    bx      lr

.data
    # Prompt the user for input
    prompt_str:   .asciz "Enter an integer: "
    # Format string for scanf to read a integer
    scanf_format: .asciz "%d"
    # Result string for printf to display the output
    result_str:   .asciz "The result of multiplying by 10 is %d.\n"