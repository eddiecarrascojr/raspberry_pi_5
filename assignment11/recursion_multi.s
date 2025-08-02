# -----------------------------------------------------------------------------
# recursion_multi.s
# Author:       Eddie Carrasco Jr
# Date:         8/1/2025
# Description:  This program calculates the product of two numbers using recursive
#               successive addition. It prompts the user for two integers: a multiplier (m)
#               and the number of iterations (n).
#
# The recursive logic is as follows:
#   Mult(m, n) = m                            (if n = 1)
#   Mult(m, n) = m + Mult(m, n - 1)         (if n > 1)
#
# To assemble and link on a Raspberry Pi (or any ARM 32-bit system):
#   as -o arm_recursive_multiply.o arm_recursive_multiply.s
#   gcc -o arm_recursive_multiply arm_recursive_multiply.o
#
# To run:
#   ./arm_recursive_multiply
#
# recursive_multiply: Performs multiplication using successive addition.
#
# Arguments:
#   r0: The multiplier (m)
#   r1: The number of iterations (n)
#
# Returns:
#   r0: The result of the multiplication (m * n)
#

.global main

recursive_multiply:
    # Memory allocation for the return address.
    SUB sp, sp, #4
    STR lr, [sp]

    # --- Base Case ---
    # Check if n (in r1) is equal to 1.
    CMP r1, #1
    BEQ return_base_case

    # --- Recursive Step ---
    # If n > 1, we need to calculate m + Mult(m, n - 1).
    PUSH {r0}

    # Decrement n for the next recursive call: n = n - 1
    SUB r1, r1, #1

    # Recursively call the function with Mult(m, n - 1).
    BL recursive_multiply

    # After the recursive call returns, the result of Mult(m, n-1) is in r0.
    POP {r2}

    # Perform the addition: result = m + Mult(m, n - 1)
    # r0 = r0 (result from recursive call) + r2 (original m)
    ADD r0, r0, r2

return_base_case:
    # Manually restore the return address from the stack into the program
    LDR pc, [sp], #4


# main: The main entry point of the program.
main:
    # Set up the stack frame.
    PUSH {fp, lr}
    ADD fp, sp, #4

    # Load the address of the prompt string into r0.
    LDR r0, =prompt_m
    BL printf

    # Load the address of the format string ("%d") into r0.
    LDR r0, =format_int
    LDR r1, =input_m
    BL scanf

    # Load the address of the second prompt string into r0.
    LDR r0, =prompt_n
    BL printf

    # Load the address of the format string ("%d") into r0.
    LDR r0, =format_int
    LDR r1, =input_n
    BL scanf

    # Load the user's first input (m) into r0.
    LDR r1, =input_m
    LDR r0, [r1]
    LDR r1, =input_n
    LDR r1, [r1]

    # Call the recursive multiplication function.
    BL recursive_multiply

    # prepare the values to print the result.
    mov r1, r0
    LDR r0, =result_msg
    BL printf

    # complete stack cleanup.
    MOV r0, #0
    SUB sp, fp, #4
    POP {fp, pc}

# We need to link with the C library for printf and scanf
.extern printf
.extern scanf

.data
# String constants for user prompts and output formatting
prompt_m:       .asciz "Enter the multiplier (m): "
prompt_n:       .asciz "Enter the number of iterations (n): "
result_msg:     .asciz "Result: %d\n"
format_int:     .asciz "%d"

# Memory allocation for user input. .word allocates 4 bytes.
input_m:        .word 0
input_n:        .word 0

.text
# End of the assembly file
