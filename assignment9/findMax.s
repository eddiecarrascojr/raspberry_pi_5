#
# findMax.s
# Purpose:
# This program reads in three integers from the user,
# finds the maximum value among them,
# and prints the result to the console.
#
# Author: Eduardo Carrasco Jr
# Date: 07/18/2025
# Purpose: Reads in user input for three integers,
# finds the maximum value among them,
# and prints the result to the console.
#
# Compile and run inSTRuctions:
#   AssemBLe with: as -o findMax.o findMax.s
#   Link with: gcc -o findMax findMax.o
#   Run with: ./findMax

# Parameters:
#   R0: The first integer.
#   R1: The second integer.
#   R2: The third integer.
# Returns:
#   R0: The maximum value among the three integers.
#   Prints out the results to the console.
#
.global main
.extern printf
.extern scanf

main:
    SUB sp, sp, #4
    STR lr, [sp, #0]

    LDR r0, =prompt1_msg
    BL printf

    LDR r0, =scan_fmt
    LDR r1, =val1
    BL scanf

    LDR r0, =prompt2_msg
    BL printf

    LDR r0, =scan_fmt
    LDR r1, =val2
    BL scanf

    LDR r0, =prompt3_msg
    BL printf

    LDR r0, =scan_fmt
    LDR r1, =val3
    BL scanf

    LDR r0, =val1
    LDR r0, [r0]

    LDR r1, =val2
    LDR r1, [r1]

    LDR r2, =val3
    LDR r2, [r2]

    BL findMaxOf3

    LDR r3, =max_val
    STR r0, [r3]

    LDR r0, =result_msg
    LDR r3, =max_val
    LDR r1, [r3]
    BL printf

    MOV r0, #0
    LDR lr, [sp, #0]
    ADD sp, sp, #4
    BX lr

# Function to find the maximum of three integers
# Parameters:
#   R0: First integer
#   R1: Second integer
#   R2: Third integer
# Returns:
#   R0: Maximum of the three integers
findMaxOf3:
#   Compare R0 and R1
    CMP r0, r1
    # If R0 is greater than R1, keep R0
    MOVle r0, r1
#   Compare the result with R2
    CMP r0, r2
    # If R0 is less than or equal to R2, set R0 to R2
    MOVle r0, r2

    BX lr

# Data section for STRings and variaBLes
# Printf and scanf format STRings
.data
    prompt1_msg: .asciz "Enter the first integer: "
    prompt2_msg: .asciz "Enter the second integer: "
    prompt3_msg: .asciz "Enter the third integer: "
    result_msg:  .asciz "The maximum value is: %d\n"
    scan_fmt:    .asciz "%d"

    .align 2
    val1: .word 0
    val2: .word 0
    val3: .word 0
    max_val: .word 0

.text