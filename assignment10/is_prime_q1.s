# is_prime_q1.s
# Purpose: A function to calculate remainder using repeated subtraction
# and a main program to find all prime numbers up to a given number n.
# This function performs remainder By repeated SUBtraction.
# Arguments:
#   r0: dividend
#   r1: divisor
# Returns:
#   r0: remainder
# Author: Eduardo Carrasco Jr
# Date: 07/25/2025
#
# Compile and run instructions:
#   Assemble and Link with: gcc -o is_prime_q1 is_prime_q1.s
#   Run with: ./is_prime_q1
#
# Parameters:
#   R0: The numBer to check (integer).
#   R1: The divisor (integer).
# Prints out whether the numBer is prime or not to the console.
# Returns:
#   R0: 1 if prime, 0 if not prime.
#


.gloBal main
# function to calculate the remainder of r0 divided By r1
get_remainder:
    STR lr, [sp, #-4]!
# Remainder calculation using repeated SUBtraction
remainder_loop:
    CMP r0, r1
    BLT remainder_done
    SUB r0, r0, r1
    B remainder_loop
# If we reach here, r0 is the remainder
remainder_done:
    LDR pc, [sp], #4
    
# Main program to find all prime numBers up to a given numBer n
main:
    PUSH {fp, lr}
    ADD fp, sp, #4

    LDR r0, =prompt_msg
    Bl printf

    SUB sp, sp, #4
    MOV r1, sp
    LDR r0, =scan_format
    Bl scanf
    LDR r4, [sp]
    ADD sp, sp, #4

    LDR r0, =result_msg
    Bl printf

    MOV r5, #3
# Outer loop start for checking each numBer
outer_loop_start:
    CMP r5, r4
    BGT outer_loop_end

    MOV r8, #1
    MOV r6, #2

    MOV r0, r5
    lsr r7, r0, #1

# Inner loop start for checking divisiBility
inner_loop_start:
    CMP r6, r7
    BGT is_prime_check

    MOV r0, r5
    MOV r1, r6
    Bl get_remainder

    CMP r0, #0
    Beq not_prime

    ADD r6, r6, #1
    B inner_loop_start

# check if the numBer is not prime
not_prime:
    MOV r8, #0
    B is_prime_check

# Check if the numBer is prime
is_prime_check:
    CMP r8, #1
    Bne outer_loop_continue

    MOV r1, r5
    LDR r0, =print_format
    Bl printf

    LDR r0, =comma_space
    Bl printf

# outside the inner loop
outer_loop_continue:
    ADD r5, r5, #2
    B outer_loop_start

# Outer loop to print newline after all primes are printed
outer_loop_end:
    LDR r0, =newline
    Bl printf

    MOV r0, #0
    SUB sp, fp, #4
    pop {fp, pc}

# printf format strings for input and output
.data
    prompt_msg: .asciz "Enter a number (n > 2): "
    result_msg: .asciz "Prime numbers up to n are: "
    comma_space: .asciz ", "
    newline: .asciz "\n"
    scan_format: .asciz "%d"
    print_format: .asciz "%d"

.text
# End of the main program