#
# ARM AssemBLy Program: Reads in inches,
# then converts it to total inches and total feet. Thenprints the result.
# Program Name: inches_to_feet.s
# Author: Eduardo Carrasco Jr
# Date: 06/21/2025
# Purpose: Reads in user for a feet and inches,
# then converts it to total inches, and prints the result.
#
# Inputs: 
#   - Integer of total inches
#   - r0 as integer of inches

# Outputs:
#   - Integer of total feet
#   - r0 as integer of feet
#   - Integer of total inches
#   - r1 as integer of inches
#

.text
.global main

main:

    @ Function Prologue
    SUB     sp, sp, #4
    STR     fp, [sp, #0]
    STR     lr, [sp, #4]
    MOV     fp, sp

    @ Prompt for user input
    LDR     r0, =prompt_message
    BL      printf

    @ Read the integer from the user
    LDR     r0, =scanf_format
    LDR     r1, =input_inches
    BL      scanf

    @ Load the user's input value into a register
    LDR     r1, =input_inches
    LDR     r4, [r1]

    @ --- Calculation Section ---

    @ Calculate feet
    MOV     r0, r4
    MOV     r1, #12
    BL      __aeabi_idiv
    MOV     r5, r0

    @ Calculate remaining inches
    MOV     r0, r5
    MOV     r1, #12
    mul     r2, r0, r1
    SUB     r6, r4, r2

    @ --- End of Calculation Section ---

    @ Print the final result
    LDR     r0, =output_format
    MOV     r1, r4
    MOV     r2, r5
    MOV     r3, r6
    BL      printf

    @ Function Epilogue
    MOV     r0, #0
    LDR     fp, [sp, #0]
    LDR     lr, [sp, #4]
    add     sp, sp, #8
    MOV     pc, lr

.data
    prompt_message: .asciz "Enter total inches: "
    scanf_format: .asciz "%d"
    output_format: .asciz "%d inches is %d feet and %d inches.\n"
    input_inches: .word 0
    