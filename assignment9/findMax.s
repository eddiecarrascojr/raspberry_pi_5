#
# findMax.s
# A program to find the maximum of three user-input integers.
# The comparison is implemented using a series of conditional operations.
# Author: Eduardo Carrasco Jr
# Date: 07/18/2025
# Purpose: Reads in user input for three integers,
# finds the maximum value among them,
# and prints the result to the console.
#
# Compile and run instructions:
#   Assemble with: as -o findMax.o findMax.s
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

    ldr r0, =prompt1_msg
    bl printf

    ldr r0, =scan_fmt
    ldr r1, =val1
    bl scanf

    ldr r0, =prompt2_msg
    bl printf

    ldr r0, =scan_fmt
    ldr r1, =val2
    bl scanf

    ldr r0, =prompt3_msg
    bl printf

    ldr r0, =scan_fmt
    ldr r1, =val3
    bl scanf

    ldr r0, =val1
    ldr r0, [r0]

    ldr r1, =val2
    ldr r1, [r1]

    ldr r2, =val3
    ldr r2, [r2]

    bl findMaxOf3

    ldr r3, =max_val
    str r0, [r3]

    ldr r0, =result_msg
    ldr r3, =max_val
    ldr r1, [r3]
    bl printf

    mov r0, #0
    LDR lr, [sp, #0]
    ADD sp, sp, #4
    bx lr

# Function to find the maximum of three integers
# Parameters:
#   R0: First integer
#   R1: Second integer
#   R2: Third integer
# Returns:
#   R0: Maximum of the three integers
findMaxOf3:
#   Compare R0 and R1
    cmp r0, r1
    # If R0 is greater than R1, keep R0
    movle r0, r1
#   Compare the result with R2
    cmp r0, r2
    # If R0 is less than or equal to R2, set R0 to R2
    movle r0, r2

    bx lr

# Data section for strings and variables
# Printf and scanf format strings
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