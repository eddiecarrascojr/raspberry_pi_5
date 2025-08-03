#
# ARM AssemBLy Program: Encryption and Decryption using RSA
# Program Name: rsa_implementation.s
# Authors: Eduardo Carrasco Jr, Bryon Proctor, Kyla Ugwu, and Peyton Marrone.
# Date: 06/21/2025
# Purpose: Reads in user message to encrypt using RSA algorithm.
#
# Inputs: 
#   - String message to encrypt as well as two integers.
#   - r0 the message to encrypt
#   - r1 the first integer
#   - r2 the second integer
#
# -----------------------------------------------------------------------------
# rsa_key_prime_check.s
#
# An ARMv7 assembly program that prompts a user for a message and two integers,
# p and q. It then verifies that both p and q are prime numbers before
# proceeding. If they are not prime, it will loop until valid primes are entered.
#
# To compile and run:
# as -o rsa_key_prime_check.o rsa_key_prime_check.s
# gcc -o rsa_key_prime_check rsa_key_prime_check.o 
# ./rsa_key_prime_check
# -----------------------------------------------------------------------------

.global main

# External functions from the C library (libc)
.extern printf
.extern fgets
.extern sscanf


isPrime:
    push {r1-r7, lr}

    # --- Handle base cases ---
    cmp r0, #1
    ble not_prime 

    cmp r0, #2
    beq is_prime

    tst r0, #1
    beq not_prime

    # --- Calculate integer square root of n (r0) to optimize the loop. We only need to check for divisors up to sqrt(n).
    mov r1, #1
    mov r2, r0
isqrt_loop:
    mul r3, r1, r1
    cmp r3, r2
    bgt isqrt_done 
    add r1, #1
    b isqrt_loop

isqrt_done:
    mov r4, r1 
    # --- Main primality test loop ---
    mov r1, #3 
    
prime_check_loop:
    cmp r1, r4
    bgt is_prime 

    # Perform division: n / i. We check the remainder.
    udiv r2, r0, r1  
    mul r3, r2, r1
    sub r3, r0, r3
    
    cmp r3, #0
    beq not_prime

    add r1, #2
    b prime_check_loop

is_prime:
    mov r0, #1
    b isPrime_exit

not_prime:
    mov r0, #0  
    b isPrime_exit

isPrime_exit:
    pop {r1-r7, lr} 
    bx lr

# -----------------------------------------------------------------------------
# main: The main entry point of the program.
# -----------------------------------------------------------------------------
main:
    push {ip, lr}

    # --- Print welcome message ---
    ldr r0, =welcome_msg
    bl printf

    # --- Prompt for and read the message ---
    ldr r0, =prompt_msg
    bl printf
    ldr r0, =msg_buffer
    mov r1, #256 
    mov r2, stdin
    bl fgets

input_loop:
    # --- Prompt for P ---
    ldr r0, =prompt_p
    bl printf
    ldr r0, =input_buffer_p
    mov r1, #16
    mov r2, stdin 
    bl fgets

    # Convert string p to integer
    ldr r0, =input_buffer_p
    ldr r1, =int_format
    ldr r2, =p_val
    bl sscanf

    # --- Prompt for Q ---
    ldr r0, =prompt_q
    bl printf
    ldr r0, =input_buffer_q
    mov r1, #16
    mov r2, stdin
    bl fgets

    # Convert string q to integer
    ldr r0, =input_buffer_q
    ldr r1, =int_format
    ldr r2, =q_val
    bl sscanf

    # --- Check if P is prime ---
    ldr r1, =p_val
    ldr r0, [r1]
    bl isPrime
    mov r5, r0

    # --- Check if Q is prime ---
    ldr r1, =q_val
    ldr r0, [r1]
    bl isPrime
    mov r6, r0

    # --- Validate results ---
    cmp r5, #1
    it eq
    cmpeq r6, #1
    beq primes_are_valid

    # --- If one or both are not prime, show error and loop ---
    ldr r0, =error_msg
    bl printf
    b input_loop

primes_are_valid:
    # --- Print success and final message ---
    ldr r0, =success_msg
    bl printf
    
    ldr r0, =final_msg
    ldr r1, =msg_buffer
    bl printf

    # --- Exit the program ---
    mov r0, #0 
    pop {ip, pc}

# Define stdin for use with fgets
.set stdin, 0

.data
    # --- String Constants ---
    welcome_msg:    .asciz "--- RSA Prime Number Validator ---\n"
    prompt_msg:     .asciz "Please enter the message to encrypt: "
    prompt_p:       .asciz "Enter the first prime number (p): "
    prompt_q:       .asciz "Enter the second prime number (q): "
    error_msg:      .asciz "\nError: Both p and q must be prime numbers. Please try again.\n\n"
    success_msg:    .asciz "\nSuccess! p and q are both prime.\n"
    final_msg:      .asciz "The message you entered was: %s\n"
    
    # --- Format Strings for sscanf/printf ---
    int_format:     .asciz "%d"
    
    # --- BSS (Block Started by Symbol) - Uninitialized Data ---
    .bss
    .align 4
    input_buffer_p: .space 16         # Buffer to read integer p as a string
    input_buffer_q: .space 16         # Buffer to read integer q as a string
    msg_buffer:     .space 256        # Buffer for the user's message
    p_val:          .space 4          # 4 bytes to store integer p
    q_val:          .space 4          # 4 bytes to store integer q

.text
.align 4

# End of rsa_team implementation