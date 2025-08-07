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
@   3. Decrypt a sequence of numbers using the private key.
@
@ To Compile and Run:
@ as -o rsa_arm.o rsa_arm.s
@ gcc -o rsa_arm rsa_arm.o
@ ./rsa_arm
@ =============================================================================

.data
@ --- String Constants for Prompts and Formatting ---
prompt_menu:      .asciz "\n--- RSA Algorithm Menu ---\n1. Generate Keys\n2. Encrypt a Message\n3. Decrypt a Message\n4. Exit\nEnter your choice: "
prompt_p:         .asciz "Enter the first prime number (p < 50): "
prompt_q:         .asciz "Enter the second prime number (q < 50): "
prompt_e:         .asciz "Enter a public key exponent (e): "
prompt_msg:       .asciz "Enter a message to encrypt: "
prompt_decrypt:   .asciz "Enter the encrypted numbers, separated by spaces.\nPress Enter after the last number, then Ctrl+D to finish:\n"

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
info_decrypted_hdr: .asciz "Decrypted message: %s"
info_newline:     .asciz "\n"

@ --- Format Specifiers for scanf and printf ---
format_int:       .asciz " %d"      @ Leading space consumes whitespace/newlines.
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
ciphertext_buffer: .space 1024 @ Buffer for up to 256 encrypted integers
decrypted_msg_buffer: .space 256 @ Buffer for the final decrypted message

.text
.global main

@ =============================================================================
@ clear_input_buffer: Reads from stdin until a newline or EOF is found.
@ =============================================================================
clear_input_buffer:
    push {r3, lr}     @ Push even number of registers for 8-byte stack alignment
.L_clear_loop:
    bl getchar
    cmp r0, #'\n'
    beq .L_clear_end
    cmp r0, #-1
    beq .L_clear_end
    b .L_clear_loop
.L_clear_end:
    pop {r3, pc}

@ =============================================================================
@ is_prime: Checks if a number in r0 is prime.
@ =============================================================================
is_prime:
    push {r3, lr}       @ Push even number of registers for 8-byte stack alignment
    mov r1, r0
    cmp r1, #1
    ble .L_not_prime
    cmp r1, #3
    ble .L_is_prime

    mov r2, r1
    mov r3, #2
    udiv r0, r2, r3
    mul r0, r3, r0
    cmp r0, r2
    beq .L_not_prime

    mov r3, #3
    udiv r0, r2, r3
    mul r0, r3, r0
    cmp r0, r2
    beq .L_not_prime

    mov r2, #5
.L_prime_loop:
    mul r3, r2, r2
    cmp r3, r1
    bgt .L_is_prime

    udiv r0, r1, r2
    mul r0, r2, r0
    cmp r0, r1
    beq .L_not_prime

    add r3, r2, #2
    udiv r0, r1, r3
    mul r0, r3, r0
    cmp r0, r1
    beq .L_not_prime

    add r2, r2, #6
    b .L_prime_loop

.L_is_prime:
    mov r0, #1
    pop {r3, pc}

.L_not_prime:
    mov r0, #0
    pop {r3, pc}

@ =============================================================================
@ gcd: Calculates the greatest common divisor of two numbers.
@ =============================================================================
gcd:
    push {r3, lr}       @ Push even number of registers for 8-byte stack alignment
.L_gcd_loop:
    cmp r1, #0
    beq .L_gcd_end
    sdiv r2, r0, r1
    mls r3, r2, r1, r0
    mov r0, r1
    mov r1, r3
    b .L_gcd_loop
.L_gcd_end:
    pop {r3, pc}

@ =============================================================================
@ extended_gcd: Extended Euclidean Algorithm to find modular inverse.
@ =============================================================================
extended_gcd:
    push {r4-r10, lr}   @ Push 8 registers for alignment
    mov r4, r0
    mov r5, r1

    mov r6, #0
    mov r7, #1
    mov r8, #1
    mov r9, #0

.L_ext_gcd_loop:
    cmp r5, #0
    beq .L_ext_gcd_end

    sdiv r10, r4, r5
    mls r3, r10, r5, r4
    mov r4, r5
    mov r5, r3

    mul r2, r10, r7
    sub r2, r9, r2
    mov r9, r7
    mov r7, r2

    mul r2, r10, r6
    sub r2, r8, r2
    mov r8, r6
    mov r6, r2
    
    b .L_ext_gcd_loop

.L_ext_gcd_end:
    mov r0, r9
    cmp r0, #0
    bge .L_d_positive
    add r0, r0, r1

.L_d_positive:
    pop {r4-r10, pc}

@ =============================================================================
@ mod_pow: Performs modular exponentiation (base^exp % mod).
@ =============================================================================
mod_pow:
    push {r3, r4-r7, lr} @ FIXED: Push 6 registers for alignment
    mov r4, r0
    mov r5, r1
    mov r6, r2
    mov r7, #1

    sdiv r0, r4, r6
    mls r4, r0, r6, r4

.L_mod_pow_loop:
    cmp r5, #0
    ble .L_mod_pow_end

    tst r5, #1
    beq .L_mod_pow_skip_mul

    mul r0, r7, r4
    sdiv r1, r0, r6
    mls r7, r1, r6, r0

.L_mod_pow_skip_mul:
    lsr r5, r5, #1

    mul r0, r4, r4
    sdiv r1, r0, r6
    mls r4, r1, r6, r0

    b .L_mod_pow_loop

.L_mod_pow_end:
    mov r0, r7
    pop {r3, r4-r7, pc}

@ =============================================================================
@ cpubexp: Sub-routine for public key exponent (e) calculation and validation.
@ =============================================================================
cpubexp:
    push {r3, r4, r5, lr} @ FIXED: Push 4 registers for alignment
    mov r4, r0

.L_get_e_loop:
    ldr r0, =prompt_e
    bl printf
    
    ldr r0, =format_int
    ldr r1, =e_val
    bl scanf
    bl clear_input_buffer

    ldr r5, =e_val
    ldr r5, [r5]

    cmp r5, #1
    ble .L_e_error1

    cmp r5, r4
    bge .L_e_error2

    mov r0, r5
    mov r1, r4
    bl gcd
    cmp r0, #1
    bne .L_e_error3

    b .L_e_valid

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
    mov r0, r5
    pop {r3, r4, r5, pc}

@ =============================================================================
@ cprivexp: Sub-routine for private key exponent (d) calculation.
@ =============================================================================
cprivexp:
    push {r3, lr}
    bl extended_gcd
    pop {r3, pc}

@ =============================================================================
@ encrypt: Sub-routine for encryption. C = M^e mod n
@ =============================================================================
encrypt:
    push {r3, lr}
    bl mod_pow
    pop {r3, pc}

@ =============================================================================
@ decrypt: Sub-routine for decryption. m = c^d mod n
@ =============================================================================
decrypt:
    push {r3, lr}
    bl mod_pow
    pop {r3, pc}

@ =============================================================================
@ generate_keys_routine: Main logic for key generation.
@ =============================================================================
generate_keys_routine:
    push {r4-r10, lr}
    
.L_get_primes_loop:
    ldr r0, =prompt_p
    bl printf
    ldr r0, =format_int
    ldr r1, =p_val
    bl scanf
    bl clear_input_buffer

    ldr r0, =prompt_q
    bl printf
    ldr r0, =format_int
    ldr r1, =q_val
    bl scanf
    bl clear_input_buffer

    ldr r4, =p_val
    ldr r4, [r4]
    ldr r5, =q_val
    ldr r5, [r5]
    
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

    mul r6, r4, r5
    ldr r0, =n_val
    str r6, [r0]

    sub r4, r4, #1
    sub r5, r5, #1
    mul r7, r4, r5
    ldr r0, =phi_n_val
    str r7, [r0]

    mov r0, r7
    bl cpubexp
    mov r8, r0
    ldr r1, =e_val
    str r8, [r1]

    mov r0, r8
    mov r1, r7
    bl cprivexp
    mov r9, r0
    ldr r1, =d_val
    str r9, [r1]

    ldr r0, =info_pub_key
    mov r1, r8
    mov r2, r6
    bl printf

    ldr r0, =info_priv_key
    mov r1, r9
    mov r2, r6
    bl printf

    ldr r0, =keys_generated_flag
    mov r1, #1
    str r1, [r0]

    pop {r4-r10, pc}

@ =============================================================================
@ encrypt_routine: Main logic for string encryption.
@ =============================================================================
encrypt_routine:
    push {r3, r4-r7, lr} @ FIXED: Push 6 registers for alignment

    ldr r0, =keys_generated_flag
    ldr r0, [r0]
    cmp r0, #0
    beq .L_encrypt_no_keys

    ldr r4, =e_val
    ldr r4, [r4]
    ldr r5, =n_val
    ldr r5, [r5]
    
    ldr r0, =prompt_msg
    bl printf
    ldr r0, =format_str
    ldr r1, =msg_buffer
    bl scanf

    ldr r0, =info_ciphertext_hdr
    bl printf
    ldr r7, =msg_buffer

.L_encrypt_char_loop:
    ldrb r6, [r7], #1
    cmp r6, #0
    beq .L_encrypt_end_loop

    mov r0, r6
    mov r1, r4
    mov r2, r5
    bl encrypt

    mov r1, r0
    ldr r0, =format_num_space
    bl printf

    b .L_encrypt_char_loop

.L_encrypt_end_loop:
    ldr r0, =info_newline
    bl printf
    b .L_encrypt_end

.L_encrypt_no_keys:
    ldr r0, =err_no_keys
    bl printf

.L_encrypt_end:
    pop {r3, r4-r7, pc}

@ =============================================================================
@ decrypt_routine: Main logic for string decryption.
@ =============================================================================
decrypt_routine:
    push {r3, r4-r9, lr} @ FIXED: Push 8 registers for alignment

    ldr r0, =keys_generated_flag
    ldr r0, [r0]
    cmp r0, #0
    beq .L_decrypt_no_keys

    ldr r4, =d_val
    ldr r4, [r4]
    ldr r5, =n_val
    ldr r5, [r5]

    ldr r0, =prompt_decrypt
    bl printf
    ldr r6, =ciphertext_buffer
.L_read_cipher_loop:
    ldr r0, =format_int
    ldr r1, =p_val
    bl scanf
    cmp r0, #1
    bne .L_read_cipher_end

    ldr r2, =p_val
    ldr r2, [r2]
    str r2, [r6], #4
    b .L_read_cipher_loop
.L_read_cipher_end:
    bl clear_input_buffer

    ldr r7, =ciphertext_buffer
    ldr r8, =decrypted_msg_buffer
.L_decrypt_char_loop:
    cmp r7, r6
    beq .L_decrypt_end_loop

    ldr r0, [r7], #4
    mov r1, r4
    mov r2, r5
    bl decrypt

    strb r0, [r8], #1

    b .L_decrypt_char_loop

.L_decrypt_end_loop:
    mov r9, #0
    strb r9, [r8]

    ldr r0, =info_decrypted_hdr
    ldr r1, =decrypted_msg_buffer
    bl printf
    
    ldr r0, =info_newline
    bl printf
    b .L_decrypt_end

.L_decrypt_no_keys:
    ldr r0, =err_no_keys
    bl printf

.L_decrypt_end:
    pop {r3, r4-r9, pc}

@ =============================================================================
@ main: The main entry point of the program.
@ =============================================================================
main:
    push {fp, lr}
    mov fp, sp

.L_main_loop:
    ldr r0, =prompt_menu
    bl printf
    ldr r0, =format_int
    ldr r1, =p_val
    bl scanf
    
    cmp r0, #1
    bne .L_exit

    bl clear_input_buffer

    ldr r0, =p_val
    ldr r0, [r0]

    cmp r0, #1
    beq .L_choice_gen_keys
    cmp r0, #2
    beq .L_choice_encrypt
    cmp r0, #3
    beq .L_choice_decrypt
    cmp r0, #4
    beq .L_exit

    ldr r0, =err_invalid_choice
    bl printf
    b .L_main_loop

.L_choice_gen_keys:
    bl generate_keys_routine
    b .L_main_loop

.L_choice_encrypt:
    bl encrypt_routine
    b .L_main_loop

.L_choice_decrypt:
    bl decrypt_routine
    b .L_main_loop

.L_exit:
    mov r0, #0
    mov sp, fp
    pop {fp, pc}
