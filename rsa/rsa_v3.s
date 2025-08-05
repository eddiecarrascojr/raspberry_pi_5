.global _start

.equ SYS_EXIT, 1
.equ SYS_READ, 3
.equ SYS_WRITE, 4
.equ SYS_OPEN, 5
.equ SYS_CLOSE, 6
.equ SYS_CREAT, 8

.equ STDIN, 0
.equ STDOUT, 1

.equ O_RDONLY, 0x0000
.equ O_WRONLY, 0x0001
.equ O_CREAT,  0x0040
.equ O_TRUNC,  0x0200

.data
p_val:          .word 0
q_val:          .word 0
n_val:          .word 0
phi_n_val:      .word 0
e_val:          .word 0
d_val:          .word 0

prompt_p:       .asciz "Enter prime p (<50): "
len_prompt_p:   .word . - prompt_p
prompt_q:       .asciz "Enter prime q (<50): "
len_prompt_q:   .word . - prompt_q
prompt_e:       .asciz "Enter public exponent e: "
len_prompt_e:   .word . - prompt_e
prompt_message: .asciz "Enter message for encryption (max 255 chars): "
len_prompt_message: .word . - prompt_message

msg_keys_generated: .asciz "Keys generated successfully!\n"
len_msg_keys_generated: .word . - msg_keys_generated
msg_invalid_prime:  .asciz "Invalid prime number. Please enter a prime < 50.\n"
len_msg_invalid_prime: .word . - msg_invalid_prime
msg_e_invalid:      .asciz "Invalid 'e'. Must be 1 < e < phi(n) and gcd(e, phi(n))=1.\n"
len_msg_e_invalid:  .word . - msg_e_invalid
msg_public_key:     .asciz "Public Key (n, e): ("
len_msg_public_key: .word . - msg_public_key
msg_private_key:    .asciz "Private Key (n, d): ("
len_msg_private_key: .word . - msg_private_key
msg_comma_space:    .asciz ", "
len_msg_comma_space: .word . - msg_comma_space
msg_paren_newline:  .asciz ")\n"
len_msg_paren_newline: .word . - msg_paren_newline
msg_encrypted:      .asciz "Message encrypted to encrypted.txt\n"
len_msg_encrypted:  .word . - msg_encrypted
msg_file_error:     .asciz "File operation error.\n"
len_msg_file_error: .word . - msg_file_error
msg_newline:        .asciz "\n"
len_msg_newline:    .word . - msg_newline

encrypted_file_name: .asciz "encrypted.txt"
plaintext_file_name: .asciz "plaintext.txt"

input_buffer:   .space 64
message_buffer: .space 256
output_buffer:  .space 32
read_file_buffer: .space 256

space_char:     .ascii " "
null_char:      .byte 0

.text
_start:
    BL generate_keys_routine
    BL encrypt_message_routine
    B exit_program

exit_program:
    MOV R7, #SYS_EXIT
    SVC #0

generate_keys_routine:
    PUSH {LR}

.get_p_loop:
    LDR R0, =STDOUT
    LDR R1, =prompt_p
    LDR R2, =len_prompt_p
    MOV R7, #SYS_WRITE
    SVC #0

    LDR R0, =STDIN
    LDR R1, =input_buffer
    MOV R2, #64
    MOV R7, #SYS_READ
    SVC #0
    MOV R1, R0
    LDR R0, =input_buffer
    CMP R1, #0
    BLE .invalid_p_q
    SUB R1, R1, #1
    MOV R10, #0
    STRB R10, [R0, R1]
    BL atoi
    MOV R4, R0

    CMP R4, #50
    BGE .invalid_p_q
    MOV R0, R4
    BL is_prime
    CMP R0, #0
    BEQ .invalid_p_q
    B .p_valid

.invalid_p_q:
    LDR R0, =STDOUT
    LDR R1, =msg_invalid_prime
    LDR R2, =len_msg_invalid_prime
    MOV R7, #SYS_WRITE
    SVC #0
    B .get_p_loop
.p_valid:
    LDR R0, =p_val
    STR R4, [R0]

.get_q_loop:
    LDR R0, =STDOUT
    LDR R1, =prompt_q
    LDR R2, =len_prompt_q
    MOV R7, #SYS_WRITE
    SVC #0

    LDR R0, =STDIN
    LDR R1, =input_buffer
    MOV R2, #64
    MOV R7, #SYS_READ
    SVC #0
    MOV R1, R0
    LDR R0, =input_buffer
    CMP R1, #0
    BLE .invalid_p_q_loop
    SUB R1, R1, #1
    MOV R10, #0
    STRB R10, [R0, R1]
    BL atoi
    MOV R5, R0

    CMP R5, #50
    BGE .invalid_p_q_loop
    MOV R0, R5
    BL is_prime
    CMP R0, #0
    BEQ .invalid_p_q_loop
    LDR R0, =p_val
    LDR R0, [R0]
    CMP R5, R0
    BEQ .invalid_p_q_loop
    B .q_valid

.invalid_p_q_loop:
    LDR R0, =STDOUT
    LDR R1, =msg_invalid_prime
    LDR R2, =len_msg_invalid_prime
    MOV R7, #SYS_WRITE
    SVC #0
    B .get_q_loop
.q_valid:
    LDR R0, =q_val
    STR R5, [R0]

    LDR R0, =p_val
    LDR R0, [R0]
    LDR R1, =q_val
    LDR R1, [R1]
    MUL R6, R0, R1
    LDR R0, =n_val
    STR R6, [R0]

    LDR R0, =p_val
    LDR R0, [R0]
    SUB R0, R0, #1
    LDR R1, =q_val
    LDR R1, [R1]
    SUB R1, R1, #1
    MUL R7, R0, R1
    LDR R0, =phi_n_val
    STR R7, [R0]

    MOV R0, R7
    BL cpubexp
    LDR R1, =e_val
    STR R0, [R1]

    LDR R0, =e_val
    LDR R0, [R0]
    LDR R1, =phi_n_val
    LDR R1, [R1]
    BL cprivexp
    LDR R1, =d_val
    STR R0, [R1]

    LDR R0, =STDOUT
    LDR R1, =msg_public_key
    LDR R2, =len_msg_public_key
    MOV R7, #SYS_WRITE
    SVC #0

    LDR R0, =n_val
    LDR R0, [R0]
    LDR R1, =output_buffer
    BL itoa
    LDR R0, =STDOUT
    LDR R1, =output_buffer
    MOV R2, R0
    MOV R7, #SYS_WRITE
    SVC #0

    LDR R0, =STDOUT
    LDR R1, =msg_comma_space
    LDR R2, =len_msg_comma_space
    MOV R7, #SYS_WRITE
    SVC #0

    LDR R0, =e_val
    LDR R0, [R0]
    LDR R1, =output_buffer
    BL itoa
    LDR R0, =STDOUT
    LDR R1, =output_buffer
    MOV R2, R0
    MOV R7, #SYS_WRITE
    SVC #0

    LDR R0, =STDOUT
    LDR R1, =msg_paren_newline
    LDR R2, =len_msg_paren_newline
    MOV R7, #SYS_WRITE
    SVC #0

    LDR R0, =STDOUT
    LDR R1, =msg_private_key
    LDR R2, =len_msg_private_key
    MOV R7, #SYS_WRITE
    SVC #0

    LDR R0, =n_val
    LDR R0, [R0]
    LDR R1, =output_buffer
    BL itoa
    LDR R0, =STDOUT
    LDR R1, =output_buffer
    MOV R2, R0
    MOV R7, #SYS_WRITE
    SVC #0

    LDR R0, =STDOUT
    LDR R1, =msg_comma_space
    LDR R2, =len_msg_comma_space
    MOV R7, #SYS_WRITE
    SVC #0

    LDR R0, =d_val
    LDR R0, [R0]
    LDR R1, =output_buffer
    BL itoa
    LDR R0, =STDOUT
    LDR R1, =output_buffer
    MOV R2, R0
    MOV R7, #SYS_WRITE
    SVC #0

    LDR R0, =STDOUT
    LDR R1, =msg_paren_newline
    LDR R2, =len_msg_paren_newline
    MOV R7, #SYS_WRITE
    SVC #0

    LDR R0, =STDOUT
    LDR R1, =msg_keys_generated
    LDR R2, =len_msg_keys_generated
    MOV R7, #SYS_WRITE
    SVC #0

    POP {LR}
    BX LR

encrypt_message_routine:
    PUSH {LR}

    LDR R0, =n_val
    LDR R0, [R0]
    CMP R0, #0
    BEQ .no_keys_encrypt

    LDR R0, =STDOUT
    LDR R1, =prompt_message
    LDR R2, =len_prompt_message
    MOV R7, #SYS_WRITE
    SVC #0

    LDR R0, =STDIN
    LDR R1, =message_buffer
    MOV R2, #255
    MOV R7, #SYS_READ
    SVC #0
    MOV R5, R0
    CMP R5, #0
    BEQ .encrypt_done_early

    SUB R5, R5, #1
    LDR R0, =message_buffer
    ADD R0, R0, R5
    MOV R10, #0
    STRB R10, [R0]

    LDR R0, =encrypted_file_name
    MOV R1, #(O_CREAT | O_WRONLY | O_TRUNC)
    MOV R2, #0666
    MOV R7, #SYS_CREAT
    SVC #0
    CMP R0, #0
    BLT .file_error_encrypt
    MOV R4, R0

    MOV R6, #0
.encrypt_loop:
    CMP R6, R5
    BGE .encrypt_done

    LDR R0, =message_buffer
    LDRB R0, [R0, R6]

    LDR R1, =e_val
    LDR R1, [R1]
    LDR R2, =n_val
    LDR R2, [R2]
    PUSH {R4, R5, R6, LR}
    BL pow
    POP {R4, R5, R6, LR}

    LDR R1, =output_buffer
    PUSH {R0, R4, R5, R6, LR}
    BL itoa
    MOV R7, R0
    POP {R0, R4, R5, R6, LR}

    MOV R0, R4
    LDR R1, =output_buffer
    MOV R2, R7
    MOV R7, #SYS_WRITE
    SVC #0

    MOV R0, R4
    LDR R1, =space_char
    MOV R2, #1
    MOV R7, #SYS_WRITE
    SVC #0

    ADD R6, R6, #1
    B .encrypt_loop

.encrypt_done:
    MOV R0, R4
    MOV R7, #SYS_CLOSE
    SVC #0

    LDR R0, =STDOUT
    LDR R1, =msg_encrypted
    LDR R2, =len_msg_encrypted
    MOV R7, #SYS_WRITE
    SVC #0
    B .encrypt_exit

.encrypt_done_early:
    LDR R0, =STDOUT
    LDR R1, =msg_newline
    LDR R2, =len_msg_newline
    MOV R7, #SYS_WRITE
    SVC #0
    B .encrypt_exit

.file_error_encrypt:
    LDR R0, =STDOUT
    LDR R1, =msg_file_error
    LDR R2, =len_msg_file_error
    MOV R7, #SYS_WRITE
    SVC #0
.encrypt_exit:
    POP {LR}
    BX LR

.no_keys_encrypt:
    LDR R0, =STDOUT
    LDR R1, =msg_no_keys
    LDR R2, =len_msg_no_keys
    MOV R7, #SYS_WRITE
    SVC #0
    POP {LR}
    BX LR

is_prime:
    CMP R0, #2
    BLT .not_prime_val

    CMP R0, #2
    BEQ .is_prime_true_val

    AND R1, R0, #1
    CMP R1, #0
    BEQ .not_prime_val

    MOV R1, #3
.prime_loop_val:
    MUL R2, R1, R1
    CMP R2, R0
    BGT .is_prime_true_val

    PUSH {R0, R1, R2, LR}
    MOV R0, R0
    MOV R1, R1
    BL modulo
    POP {R0, R1, R2, LR}

    CMP R0, #0
    BEQ .not_prime_val

    ADD R1, R1, #2
    B .prime_loop_val

.is_prime_true_val:
    MOV R0, #1
    BX LR

.not_prime_val:
    MOV R0, #0
    BX LR

gcd:
    CMP R1, #0
    BEQ .gcd_done

    PUSH {R0, R1, LR}
    MOV R2, R0
    MOV R0, R0
    MOV R1, R1
    BL modulo
    MOV R1, R0
    MOV R0, R2
    POP {R2, R3, LR}
    MOV R0, R2
    MOV R1, R3
    B gcd

.gcd_done:
    BX LR

modulo:
    CMP R1, #0
    BEQ .mod_error

    UDIV R2, R0, R1
    MUL R3, R2, R1
    SUB R0, R0, R3
    BX LR

.mod_error:
    MOV R0, #-1
    BX LR

pow:
    MOV R3, #1

.pow_loop:
    CMP R1, #0
    BEQ .pow_done

    AND R4, R1, #1
    CMP R4, #1
    BNE .exponent_even

    PUSH {R0, R1, R2, LR}
    MOV R6, R0
    MUL R0, R3, R6
    MOV R1, R2
    BL modulo
    MOV R3, R0
    POP {R0, R1, R2, LR}

.exponent_even:
    PUSH {R0, R1, R2, LR}
    MOV R6, R0
    MUL R0, R6, R0
    MOV R1, R2
    BL modulo
    MOV R0, R0
    POP {R0, R1, R2, LR}

    LSR R1, R1, #1
    B .pow_loop

.pow_done:
    MOV R0, R3
    BX LR

cpubexp:
    PUSH {R4, LR}
    MOV R4, R0

.pubexp_loop:
    LDR R0, =STDOUT
    LDR R1, =prompt_e
    LDR R2, =len_prompt_e
    MOV R7, #SYS_WRITE
    SVC #0

    LDR R0, =STDIN
    LDR R1, =input_buffer
    MOV R2, #64
    MOV R7, #SYS_READ
    SVC #0
    MOV R1, R0
    LDR R0, =input_buffer
    CMP R1, #0
    BLE .e_invalid_loop
    SUB R1, R1, #1
    MOV R10, #0
    STRB R10, [R0, R1]
    BL atoi
    MOV R5, R0

    CMP R5, #0
    BLE .e_invalid_loop

    CMP R5, #1
    BLE .e_invalid_loop
    CMP R5, R4
    BGE .e_invalid_loop

    PUSH {R4, R5, LR}
    MOV R0, R5
    MOV R1, R4
    BL gcd
    POP {R4, R5, LR}

    CMP R0, #1
    BNE .e_invalid_loop

    MOV R0, R5
    POP {R4, LR}
    BX LR

.e_invalid_loop:
    LDR R0, =STDOUT
    LDR R1, =msg_e_invalid
    LDR R2, =len_msg_e_invalid
    MOV R7, #SYS_WRITE
    SVC #0
    B .pubexp_loop

cprivexp:
    PUSH {R4, LR}
    MOV R4, R0
    MOV R5, R1

    MOV R2, #1
.d_loop:
    MUL R3, R2, R5
    ADD R3, R3, #1

    PUSH {R0, R1, R2, R3, R4, R5, LR}
    MOV R0, R3
    MOV R1, R4
    BL modulo
    POP {R0, R1, R2, R3, R4, R5, LR}

    CMP R0, #0
    BEQ .d_found

    ADD R2, R2, #1
    B .d_loop

.d_found:
    UDIV R0, R3, R4
    POP {R4, LR}
    BX LR

atoi:
    PUSH {R1-R3, R9, LR}
    MOV R1, #0
    MOV R2, #0
.atoi_loop:
    LDRB R3, [R0, R2]
    CMP R3, #0
    BEQ .atoi_done
    CMP R3, #10
    BEQ .atoi_done
    CMP R3, #'0'
    BLT .atoi_error
    CMP R3, #'9'
    BGT .atoi_error

    SUB R3, R3, #'0'
    MOV R10, #10
    MOV R9, R1
    LSL R1, R9, #3
    LSL R9, R9, #1
    ADD R1, R1, R9
    ADD R1, R1, R3
    ADD R2, R2, #1
    B .atoi_loop
.atoi_done:
    MOV R0, R1
    POP {R1-R3, R9, LR}
    BX LR
.atoi_error:
    MOV R0, #-1
    POP {R1-R3, R9, LR}
    BX LR

itoa:
    PUSH {R2-R7, R9, LR}
    MOV R2, R0
    MOV R3, R1
    MOV R4, #0
    MOV R5, #0

    CMP R2, #0
    BGE .itoa_positive
    MOV R5, #1
    RSB R2, R2, #0
.itoa_positive:
    CMP R2, #0
    BEQ .itoa_zero_case

.itoa_loop:
    MOV R10, #10
    UDIV R6, R2, R10
    MOV R9, R6
    LSL R7, R9, #3
    LSL R9, R9, #1
    ADD R7, R7, R9
    SUB R7, R2, R7
    ADD R7, R7, #'0'
    SUB SP, SP, #1
    STRB R7, [SP]
    ADD R4, R4, #1
    MOV R2, R6
    CMP R2, #0
    BNE .itoa_loop

    CMP R5, #1
    BEQ .itoa_add_minus
    B .itoa_copy_to_buffer

.itoa_add_minus:
    SUB SP, SP, #1
    MOV R10, #'-'
    STRB R10, [SP]
    ADD R4, R4, #1
.itoa_copy_to_buffer:
    MOV R2, #0
.itoa_copy_loop:
    CMP R4, #0
    BEQ .itoa_copy_done
    LDRB R6, [SP], #1
    STRB R6, [R3, R2]
    ADD R2, R2, #1
    SUB R4, R4, #1
    B .itoa_copy_loop

.itoa_zero_case:
    MOV R10, #'0'
    STRB R10, [R3]
    ADD R3, R3, #1
    MOV R2, #1
    B .itoa_copy_done

.itoa_copy_done:
    MOV R10, #0
    STRB R10, [R3, R2]
    MOV R0, R2
    POP {R2-R7, R9, LR}
    BX LR
