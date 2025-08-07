# =============================================================================
#
# To Compile and Run:
# as -o rsa_main.o rsa_main.s
# as -o rsa_library.o rsa_library.s
# gcc -o rsa rsa_main.o rsa_library.o
# ./rsa
# =============================================================================

.data
# --- String Constants for Prompts and Formatting ---
prompt_menu:      .asciz "\n--- RSA Algorithm Menu ---\n1. Generate Keys\n2. Encrypt a Message\n3. Decrypt a Message\n4. Exit\nEnter your choice: "
prompt_p:         .asciz "Enter the first prime number (p < 50): "
prompt_q:         .asciz "Enter the second prime number (q < 50): "
prompt_e:         .asciz "Enter a public key exponent (e): "
prompt_msg:       .asciz "Enter a message to encrypt: "
prompt_decrypt:   .asciz "Enter the encrypted numbers, separated by spaces.\nPress Enter after the last number, then Ctrl+D to finish:\n"

# Error Messages
err_not_prime:    .asciz "Error: One or both numbers are not prime. Please try again.\n"
err_e_cond1:      .asciz "Error: e must be greater than 1.\n"
err_e_cond2:      .asciz "Error: e must be less than phi(n).\n"
err_e_coprime:    .asciz "Error: e is not co-prime to phi(n). gcd(e, phi) must be 1.\n"
err_no_keys:      .asciz "Error: You must generate keys first.\n"
err_invalid_choice: .asciz "Error: Invalid choice. Please try again.\n"

# Information Messages
info_calculating: .asciz "Calculating...\n"
info_pub_key:     .asciz "Public Key (e, n) is: {%d, %d}\n"
info_priv_key:    .asciz "Private Key (d, n) is: {%d, %d}\n"
info_ciphertext_hdr: .asciz "Encrypted message (as numbers):\n"
info_decrypted_hdr: .asciz "Decrypted message: %s"
info_newline:     .asciz "\n"

# Format for scanf and printf
format_int:       .asciz " %d"
format_str:       .asciz " %[^\n]"
format_num_space: .asciz "%d "

# Global Variables and Buffers
.align 4
p_val:            .word 0
q_val:            .word 0
n_val:            .word 0
phi_n_val:        .word 0
e_val:            .word 0
d_val:            .word 0
keys_generated_flag: .word 0
msg_buffer:       .space 256
ciphertext_buffer: .space 1024
decrypted_msg_buffer: .space 256

.text
.global main

# External Function Declarations
.global is_prime, cpubexp, cprivexp, encrypt, decrypt

# =============================================================================
# generate_keys_routine: Main logic for key generation.
# =============================================================================
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

# Get and Validate Public Exponent e
.L_get_e_loop:
    ldr r0, =prompt_e
    bl printf
    ldr r0, =format_int
    ldr r1, =e_val
    bl scanf
    bl clear_input_buffer
    
    ldr r0, =e_val
    ldr r0, [r0]        # r0 = e
    mov r1, r7          # r1 = phi_n
    bl cpubexp          # Library call to validate e
    
    cmp r0, #0
    beq .L_e_valid

    # Handle errors based on return code from cpubexp
    cmp r0, #1
    ldr r0, =err_e_cond1
    beq .L_print_e_error
    
    cmp r0, #2
    ldr r0, =err_e_cond2
    beq .L_print_e_error
    
    cmp r0, #3
    ldr r0, =err_e_coprime
    beq .L_print_e_error

# Error for e value
.L_print_e_error:
    bl printf
    b .L_get_e_loop

# Check if e is valid
.L_e_valid:
    ldr r8, =e_val
    ldr r8, [r8]

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

# =============================================================================
# encrypt_routine: Main logic for string encryption.
# =============================================================================
encrypt_routine:
    push {r3, r4-r7, lr}

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

# Loop through each character in the message
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
# End of character loop
.L_encrypt_end_loop:
    ldr r0, =info_newline
    bl printf
    b .L_encrypt_end
# End of encryption routine
.L_encrypt_no_keys:
    ldr r0, =err_no_keys
    bl printf
# Pop the stack and return values
.L_encrypt_end:
    pop {r3, r4-r7, pc}

# =============================================================================
# decrypt_routine: Main logic for string decryption.
# =============================================================================
decrypt_routine:
    push {r3, r4-r9, lr}

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

# =============================================================================
# main: The main entry point of the program.
# =============================================================================
main:
    push {fp, lr}
    mov fp, sp

# Use loop to display menu and handle choices until the user exits or program fails
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
# Choices for RSA operations
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

@ =============================================================================
@ clear_input_buffer: Reads from stdin until a newline or EOF is found.
@ =============================================================================
clear_input_buffer:
    push {r3, lr}
.L_clear_loop:
    bl getchar
    cmp r0, #'\n'
    beq .L_clear_end
    cmp r0, #-1
    beq .L_clear_end
    b .L_clear_loop
.L_clear_end:
    pop {r3, pc}