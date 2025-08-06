@ =============================================================================
@ RSA Algorithm Implementation in ARMv7-A (32-bit) Assembly
@ Author: Gemini
@ Date:   August 5, 2024
@
@ Description:
@ This program implements the RSA algorithm for a Raspberry Pi running an
@ ARMv7-A compatible OS (like Raspberry Pi OS 32-bit).
@ It allows a user to:
@   1. Generate public and private keys from two prime numbers (p and q).
@   2. Encrypt a string message using the generated public key.
@
@ To Compile and Run:
@ as -o rsa_arm.o rsa_arm.s
@ gcc -o rsa_arm rsa_arm.o
@ ./rsa_arm
@ =============================================================================

.data
@ --- String Constants for Prompts and Formatting ---
prompt_menu:      .asciz "\n--- RSA Algorithm Menu ---\n1. Generate Keys\n2. Encrypt a Message\n3. Exit\nEnter your choice: "
prompt_p:         .asciz "Enter the first prime number (p < 50): "
prompt_q:         .asciz "Enter the second prime number (q < 50): "
prompt_e:         .asciz "Enter a public key exponent (e): "
prompt_msg:       .asciz "Enter a message to encrypt: "

err_not_prime:    .asciz "Error: One or both numbers are not prime. Please try again.\n"
err_e_cond1:      .asciz "Error: e must be greater than 1.\n"
err_e_cond2:      .asciz "Error: e must be less than phi(n).\n"
err_e_coprime:    .asciz "Error: e is not co-prime to phi(n). gcd(e, phi) must be 1.\n"
err_no_keys:      .asciz "Error: You must generate keys first.\n"
err_invalid_choice: .asciz "Error: Invalid choice. Please try again.\n"

info_calculating: .asciz "Calculating...\n"
info_pub_key:     .asciz "Public Key (e, n) is: {%d, %d}\n"
info_priv_key:    .asciz "Private Key (d, n) is: {%d, %d}\n"
info_ciphertext_hdr: .asciz "Encrypted message (as numbers):\n"
info_newline:     .asciz "\n"

@ --- Format Specifiers for scanf and printf ---
format_int:       .asciz "%d"
format_str:       .asciz " %[^\n]" @ Read a full line of text
format_num_space: .asciz "%d "      @ Print a number followed by a space

@ --- Global Variables and Buffers ---
.align 4
p_val:            .word 0
q_val:            .word 0
n_val:            .word 0
phi_n_val:        .word 0
e_val:            .word 0
d_val:            .word 0
keys_generated_flag: .word 0 @ 0 = false, 1 = true
msg_buffer:       .space 256 @ Buffer to hold the string message

.text
.global main

@ =============================================================================
@ clear_input_buffer: Reads from stdin until a newline or EOF is found.
@   This is crucial for preventing infinite loops on invalid input.
@   Clobbers: r0
@ =============================================================================
clear_input_buffer:
    push {lr}
.L_clear_loop:
    bl getchar
    cmp r0, #'\n'      @ Compare with newline character
    beq .L_clear_end
    cmp r0, #-1       @ Compare with EOF (-1)
    beq .L_clear_end
    b .L_clear_loop
.L_clear_end:
    pop {pc}

@ =============================================================================
@ is_prime: Checks if a number in r0 is prime.
@   - r0: The integer to check.
@   Returns:
@   - r0: 1 if prime, 0 otherwise.
@   Clobbers: r1, r2, r3
@ =============================================================================
is_prime:
    push {lr}
    mov r1, r0          @ r1 = n, the number to check
    cmp r1, #1
    ble .L_not_prime    @ Numbers <= 1 are not prime

    cmp r1, #3
    ble .L_is_prime     @ 2 and 3 are prime

    @ Check if divisible by 2 or 3
    mov r2, r1
    mov r3, #2
    udiv r0, r2, r3
    mul r0, r3, r0
    cmp r0, r2
    beq .L_not_prime    @ Divisible by 2

    mov r3, #3
    udiv r0, r2, r3
    mul r0, r3, r0
    cmp r0, r2
    beq .L_not_prime    @ Divisible by 3

    @ Check factors of the form 6k +/- 1 up to sqrt(n)
    mov r2, #5          @ Start checking from i = 5
.L_prime_loop:
    mul r3, r2, r2      @ r3 = i * i
    cmp r3, r1          @ while (i*i <= n)
    bgt .L_is_prime

    @ Check if n is divisible by i
    udiv r0, r1, r2
    mul r0, r2, r0
    cmp r0, r1
    beq .L_not_prime

    @ Check if n is divisible by i + 2
    add r3, r2, #2
    udiv r0, r1, r3
    mul r0, r3, r0
    cmp r0, r1
    beq .L_not_prime

    add r2, r2, #6      @ i = i + 6
    b .L_prime_loop

.L_is_prime:
    mov r0, #1
    pop {pc}

.L_not_prime:
    mov r0, #0
    pop {pc}

@ =============================================================================
@ gcd: Calculates the greatest common divisor of two numbers.
@   - r0: First integer (a)
@   - r1: Second integer (b)
@   Returns:
@   - r0: The gcd of a and b.
@   Clobbers: r2, r3
@ =============================================================================
gcd:
    push {lr}
.L_gcd_loop:
    cmp r1, #0
    beq .L_gcd_end
    sdiv r2, r0, r1     @ r2 = r0 / r1
    mls r3, r2, r1, r0  @ r3 = r0 - (r2 * r1) which is r0 % r1
    mov r0, r1
    mov r1, r3
    b .L_gcd_loop
.L_gcd_end:
    pop {pc}

@ =============================================================================
@ extended_gcd: Extended Euclidean Algorithm to find modular inverse.
@   d = e^-1 mod phi_n
@   Solves for x in: e*x + phi_n*y = gcd(e, phi_n)
@   - r0: e
@   - r1: phi_n
@   Returns:
@   - r0: d (the modular inverse of e mod phi_n)
@   Clobbers: r2-r10
@ =============================================================================
extended_gcd:
    push {r4-r10, lr}
    mov r4, r0          @ r4 = e (original a)
    mov r5, r1          @ r5 = phi_n (original b)

    mov r6, #0          @ y = 0
    mov r7, #1          @ x = 1
    mov r8, #1          @ lasty = 1
    mov r9, #0          @ lastx = 0

.L_ext_gcd_loop:
    cmp r5, #0
    beq .L_ext_gcd_end

    @ Quotient and Remainder
    sdiv r10, r4, r5    @ r10 = quotient = a / b
    
    @ Remainder calculation: a % b
    mls r3, r10, r5, r4 @ r3 = a - (quotient * b) = a % b
    
    mov r4, r5          @ a = b
    mov r5, r3          @ b = remainder

    @ Update x and y
    mul r2, r10, r7
    sub r2, r9, r2      @ temp_x = lastx - quotient * x
    mov r9, r7
    mov r7, r2

    mul r2, r10, r6
    sub r2, r8, r2      @ temp_y = lasty - quotient * y
    mov r8, r6
    mov r6, r2
    
    b .L_ext_gcd_loop

.L_ext_gcd_end:
    @ Our 'd' is lastx, which is in r9.
    @ We need to ensure it's positive.
    mov r0, r9
    mov r1, r1          @ r1 still holds original phi_n from caller
    cmp r0, #0
    bge .L_d_positive
    add r0, r0, r1      @ If d is negative, d = d + phi_n

.L_d_positive:
    pop {r4-r10, pc}

@ =============================================================================
@ mod_pow: Performs modular exponentiation (base^exp % mod).
@   - r0: base
@   - r1: exponent
@   - r2: modulus
@   Returns:
@   - r0: result
@   Clobbers: r3-r7
@ =============================================================================
mod_pow:
    push {r4-r7, lr}
    mov r4, r0          @ r4 = base
    mov r5, r1          @ r5 = exp
    mov r6, r2          @ r6 = mod
    mov r7, #1          @ r7 = result = 1

    @ base = base % mod
    sdiv r0, r4, r6
    mls r4, r0, r6, r4  @ r4 = r4 - (r0 * r6) = base % mod

.L_mod_pow_loop:
    cmp r5, #0
    ble .L_mod_pow_end

    @ if (exp is odd)
    tst r5, #1
    beq .L_mod_pow_skip_mul

    @ result = (result * base) % mod
    mul r0, r7, r4
    sdiv r1, r0, r6
    mls r7, r1, r6, r0  @ r7 = r0 - (r1 * r6)

.L_mod_pow_skip_mul:
    @ exp = exp >> 1 (exp = exp / 2)
    lsr r5, r5, #1

    @ base = (base * base) % mod
    mul r0, r4, r4
    sdiv r1, r0, r6
    mls r4, r1, r6, r0  @ r4 = r0 - (r1 * r6)

    b .L_mod_pow_loop

.L_mod_pow_end:
    mov r0, r7
    pop {r4-r7, pc}

@ =============================================================================
@ cpubexp: Sub-routine for public key exponent (e) calculation and validation.
@   Assumes n and phi_n have been calculated.
@   - r0: phi_n
@   Returns:
@   - r0: The validated public exponent 'e'
@ =============================================================================
cpubexp:
    push {r4-r5, lr}
    mov r4, r0          @ r4 = phi_n

.L_get_e_loop:
    @ Prompt for e
    ldr r0, =prompt_e
    bl printf
    
    @ Read e
    ldr r0, =format_int
    ldr r1, =e_val
    bl scanf
    bl clear_input_buffer

    ldr r5, =e_val
    ldr r5, [r5]        @ r5 = e

    @ Check 1: e > 1
    cmp r5, #1
    ble .L_e_error1

    @ Check 2: e < phi_n
    cmp r5, r4
    bge .L_e_error2

    @ Check 3: gcd(e, phi_n) == 1
    mov r0, r5
    mov r1, r4
    bl gcd
    cmp r0, #1
    bne .L_e_error3

    b .L_e_valid      @ All checks passed

.L_e_error1:
    ldr r0, =err_e_cond1
    bl printf
    b .L_get_e_loop

.L_e_error2:
    ldr r0, =err_e_cond2
    bl printf
    b .L_get_e_loop

.L_e_error3:
    ldr r0, =err_e_coprime
    bl printf
    b .L_get_e_loop

.L_e_valid:
    mov r0, r5          @ Return validated e
    pop {r4-r5, pc}

@ =============================================================================
@ cprivexp: Sub-routine for private key exponent (d) calculation.
@   - r0: e
@   - r1: phi_n
@   Returns:
@   - r0: The private exponent 'd'
@ =============================================================================
cprivexp:
    push {lr}
    @ We just need to call the extended gcd function
    @ r0 and r1 are already set correctly by the caller
    bl extended_gcd
    pop {pc}

@ =============================================================================
@ encrypt: Sub-routine for encryption. C = M^e mod n
@   - r0: message (M)
@   - r1: exponent (e)
@   - r2: modulus (n)
@   Returns:
@   - r0: ciphertext (C)
@ =============================================================================
encrypt:
    push {lr}
    @ We just need to call the modular exponentiation function
    @ r0, r1, r2 are already set correctly by the caller
    bl mod_pow
    pop {pc}

@ =============================================================================
@ generate_keys_routine: Main logic for key generation.
@ =============================================================================
generate_keys_routine:
    push {r4-r10, lr}

.L_get_primes_loop:
    @ --- Get p ---
    ldr r0, =prompt_p
    bl printf
    ldr r0, =format_int
    ldr r1, =p_val
    bl scanf
    bl clear_input_buffer

    @ --- Get q ---
    ldr r0, =prompt_q
    bl printf
    ldr r0, =format_int
    ldr r1, =q_val
    bl scanf
    bl clear_input_buffer

    @ --- Validate Primes ---
    ldr r4, =p_val
    ldr r4, [r4]        @ r4 = p
    ldr r5, =q_val
    ldr r5, [r5]        @ r5 = q
    
    mov r0, r4
    bl is_prime
    cmp r0, #0
    beq .L_prime_error

    mov r0, r5
    bl is_prime
    cmp r0, #0
    beq .L_prime_error

    b .L_primes_ok

.L_prime_error:
    ldr r0, =err_not_prime
    bl printf
    b .L_get_primes_loop

.L_primes_ok:
    ldr r0, =info_calculating
    bl printf

    @ --- Calculate n = p * q ---
    mul r6, r4, r5      @ r6 = n
    ldr r0, =n_val
    str r6, [r0]

    @ --- Calculate phi(n) = (p-1) * (q-1) ---
    sub r4, r4, #1      @ r4 = p - 1
    sub r5, r5, #1      @ r5 = q - 1
    mul r7, r4, r5      @ r7 = phi_n
    ldr r0, =phi_n_val
    str r7, [r0]

    @ --- Get Public Exponent e (cpubexp) ---
    mov r0, r7          @ Pass phi_n to cpubexp
    bl cpubexp
    mov r8, r0          @ r8 = e
    ldr r1, =e_val
    str r8, [r1]

    @ --- Get Private Exponent d (cprivexp) ---
    mov r0, r8          @ Pass e to cprivexp
    mov r1, r7          @ Pass phi_n to cprivexp
    bl cprivexp
    mov r9, r0          @ r9 = d
    ldr r1, =d_val
    str r9, [r1]

    @ --- Display Keys ---
    ldr r0, =info_pub_key
    mov r1, r8          @ e
    mov r2, r6          @ n
    bl printf

    ldr r0, =info_priv_key
    mov r1, r9          @ d
    mov r2, r6          @ n
    bl printf

    @ --- Set Flag ---
    ldr r0, =keys_generated_flag
    mov r1, #1
    str r1, [r0]

    pop {r4-r10, pc}

@ =============================================================================
@ encrypt_routine: Main logic for string encryption.
@ =============================================================================
encrypt_routine:
    push {r4-r7, lr}

    @ Check if keys exist
    ldr r0, =keys_generated_flag
    ldr r0, [r0]
    cmp r0, #0
    beq .L_encrypt_no_keys

    @ --- Get values for encryption ---
    ldr r4, =e_val
    ldr r4, [r4]        @ r4 = e
    ldr r5, =n_val
    ldr r5, [r5]        @ r5 = n
    
    @ --- Prompt for message ---
    ldr r0, =prompt_msg
    bl printf
    ldr r0, =format_str
    ldr r1, =msg_buffer
    bl scanf
    @ No need to clear buffer here, %[^\n] consumes the line

    @ --- Print header and set up for loop ---
    ldr r0, =info_ciphertext_hdr
    bl printf
    ldr r7, =msg_buffer @ r7 will be our pointer to the current character

.L_encrypt_char_loop:
    ldrb r6, [r7], #1   @ Load byte (character) and post-increment pointer
    cmp r6, #0          @ Check for null terminator
    beq .L_encrypt_end_loop

    @ --- Call encrypt function for the character ---
    mov r0, r6          @ message (current character's ASCII value)
    mov r1, r4          @ e
    mov r2, r5          @ n
    bl encrypt          @ C = M^e mod n

    @ --- Display the encrypted number ---
    mov r1, r0          @ Move encrypted char to r1 for printing
    ldr r0, =format_num_space
    bl printf

    b .L_encrypt_char_loop

.L_encrypt_end_loop:
    ldr r0, =info_newline @ Print a final newline for clean formatting
    bl printf
    b .L_encrypt_end

.L_encrypt_no_keys:
    ldr r0, =err_no_keys
    bl printf

.L_encrypt_end:
    pop {r4-r7, pc}

@ =============================================================================
@ main: The main entry point of the program.
@ =============================================================================
main:
    push {fp, lr}
    mov fp, sp

.L_main_loop:
    @ Display menu and get user choice
    ldr r0, =prompt_menu
    bl printf
    ldr r0, =format_int
    ldr r1, =p_val      @ Re-use p_val memory for user choice
    bl scanf
    bl clear_input_buffer

    ldr r0, =p_val
    ldr r0, [r0]

    cmp r0, #1
    beq .L_choice_gen_keys
    cmp r0, #2
    beq .L_choice_encrypt
    cmp r0, #3
    beq .L_exit

    @ Invalid choice
    ldr r0, =err_invalid_choice
    bl printf
    b .L_main_loop

.L_choice_gen_keys:
    bl generate_keys_routine
    b .L_main_loop

.L_choice_encrypt:
    bl encrypt_routine
    b .L_main_loop

.L_exit:
    mov r0, #0          @ Return 0
    mov sp, fp
    pop {fp, pc}
