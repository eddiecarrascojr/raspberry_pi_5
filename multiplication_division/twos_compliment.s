
#
# ARM AssemBLy Program: Reads in integer then performs two's complement negation
# Program Name: twos_compliment.s
# Author: Eduardo Carrasco Jr
# Date: 06/21/2025
# Purpose: Reads in user for an integer,
# then performs two's complement negation, and prints the result.
#
# Inputs: 
#   - Integer of number to negate
#   - r0 as integer of inches

# Outputs:
#   - Integer of negated number
#   - r0 as integer of negated number
#


.text
.global main

main:
    # Manual stack 
    sub     sp, sp, #8
    str     lr, [sp, #4]

    # Prompt the user
    ldr     r0, =prompt_string
    bl      printf

    # Read an integer from the user
    ldr     r0, =format_string
    mov     r1, sp
    bl      scanf

    # Load the integer that scanf just wrote from the stack into r2
    ldr     r2, [sp, #0]

    # Perform Two's Complement
    # r3 = ~r2 (one's complement)
    mvn     r3, r2
    # r3 = r3 + 1 (completes the two's complement)
    add     r3, r3, #1

    # Print the original number and its negative value
    ldr     r0, =result_string
    mov     r1, r2             
    mov     r2, r3             
    bl      printf

    mov     r0, #0             
    ldr     lr, [sp, #4]
    add     sp, sp, #8
    mov     pc, lr

.data
    prompt_string:  .asciz "Enter an integer: "
    format_string:  .asciz "%d"
    result_string:  .asciz "The negative value is: -%d\n"