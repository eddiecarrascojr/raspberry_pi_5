.global _start

.equ STDIN, 0
.equ STDOUT, 1
.equ SYS_READ, 3
.equ SYS_WRITE, 4
.equ SYS_EXIT, 1

.data
p_prompt: .asciz "Enter a positive integer p: "
p_prompt_len = . - p_prompt

q_prompt: .asciz "Enter a positive integer q: "
q_prompt_len = . - q_prompt

message_prompt: .asciz "Enter a message: "
message_prompt_len = . - message_prompt

p_not_prime_msg: .asciz "Error: p is not prime.\n"
p_not_prime_msg_len = . - p_not_prime_msg

q_not_prime_msg: .asciz "Error: q is not prime.\n"
q_not_prime_msg_len = . - q_not_prime_msg

p_too_large_msg: .asciz "Error: p must be less than 50.\n"
p_too_large_msg_len = . - p_too_large_msg

q_too_large_msg: .asciz "Error: q must be less than 50.\n"
q_too_large_msg_len = . - q_too_large_msg

n_result_msg: .asciz "n = "
n_result_msg_len = . - n_result_msg

totient_result_msg: .asciz "Phi(n) = "
totient_result_msg_len = . - totient_result_msg

newline: .asciz "\n"
newline_len = . - newline

input_buffer: .space 20
output_buffer: .space 20
user_message_buffer: .space 100 @ Buffer for user's message (max 99 chars + null)

.text
_start:
    @ First, prompt and read the user's message
    ldr r0, =STDOUT
    ldr r1, =message_prompt
    ldr r2, =message_prompt_len
    bl print_string

    ldr r0, =STDIN
    ldr r1, =user_message_buffer
    ldr r2, =100 @ Max bytes to read for message
    bl read_string_to_buffer
    mov r9, r0 @ Save message length in r9 (callee-saved)
    mov r10, r1 @ Save message buffer address in r10 (callee-saved)

    @ Now, prompt user for p
    ldr r0, =STDOUT
    ldr r1, =p_prompt
    ldr r2, =p_prompt_len
    bl print_string

    ldr r0, =STDIN
    ldr r1, =input_buffer
    ldr r2, =20
    bl read_string_to_buffer

    mov r1, r0
    ldr r0, =input_buffer
    bl atoi
    mov r4, r0 @ p_val

    @ Check if p is less than 50
    cmp r4, #50
    bge p_is_too_large

    mov r0, r4
    bl is_prime
    cmp r0, #0
    beq p_is_not_prime

    @ Prompt user for q
    ldr r0, =STDOUT
    ldr r1, =q_prompt
    ldr r2, =q_prompt_len
    bl print_string

    ldr r0, =STDIN
    ldr r1, =input_buffer
    ldr r2, =20
    bl read_string_to_buffer

    mov r1, r0
    ldr r0, =input_buffer
    bl atoi
    mov r5, r0 @ q_val

    @ Check if q is less than 50
    cmp r5, #50
    bge q_is_too_large

    mov r0, r5
    bl is_prime
    cmp r0, #0
    beq q_is_not_prime

    @ Both p and q are prime and less than 50, calculate n = p * q
    mul r6, r4, r5 @ n = p * q

    @ Calculate totient Phi(n) = (p-1)*(q-1)
    mov r0, r4 @ p_val to r0
    mov r1, r5 @ q_val to r1
    bl calculate_totient
    mov r11, r0 @ Save totient result in r11 (callee-saved)

    @ Print the user's message (saved earlier)
    mov r2, r9 @ Restore message length from r9
    mov r1, r10 @ Restore message buffer address from r10
    ldr r0, =STDOUT
    bl print_string

    @ Print a newline after the message for better formatting
    ldr r0, =STDOUT
    ldr r1, =newline
    ldr r2, =newline_len
    bl print_string

    @ Print "n = " message
    ldr r0, =STDOUT
    ldr r1, =n_result_msg
    ldr r2, =n_result_msg_len
    bl print_string

    @ Print the value of n
    mov r0, r6
    ldr r1, =output_buffer
    bl itoa
    mov r2, r0
    ldr r1, =output_buffer
    ldr r0, =STDOUT
    bl print_string

    @ Print a newline character
    ldr r0, =STDOUT
    ldr r1, =newline
    ldr r2, =newline_len
    bl print_string

    @ Print "Phi(n) = " message
    ldr r0, =STDOUT
    ldr r1, =totient_result_msg
    ldr r2, =totient_result_msg_len
    bl print_string

    @ Print the value of Phi(n)
    mov r0, r11 @ Move totient_val to r0 for itoa
    ldr r1, =output_buffer
    bl itoa
    mov r2, r0
    ldr r1, =output_buffer
    ldr r0, =STDOUT
    bl print_string

    @ Print a newline character
    ldr r0, =STDOUT
    ldr r1, =newline
    ldr r2, =newline_len
    bl print_string

    b exit_program

p_is_not_prime:
    ldr r0, =STDOUT
    ldr r1, =p_not_prime_msg
    ldr r2, =p_not_prime_msg_len
    bl print_string
    b exit_program

q_is_not_prime:
    ldr r0, =STDOUT
    ldr r1, =q_not_prime_msg
    ldr r2, =q_not_prime_msg_len
    bl print_string
    b exit_program

p_is_too_large:
    ldr r0, =STDOUT
    ldr r1, =p_too_large_msg
    ldr r2, =p_too_large_msg_len
    bl print_string
    b exit_program

q_is_too_large:
    ldr r0, =STDOUT
    ldr r1, =q_too_large_msg
    ldr r2, =q_too_large_msg_len
    bl print_string
    b exit_program

exit_program:
    mov r0, #0
    mov r7, #SYS_EXIT
    svc #0

read_string_to_buffer:
    push {r4, lr}
    mov r7, #SYS_READ
    svc #0
    mov r4, r0

    cmp r4, #0
    beq .no_input_read

    sub r3, r4, #1
    ldrb r2, [r1, r3]
    cmp r2, #10
    bne .no_newline_found

    mov r2, #0
    strb r2, [r1, r3]
    sub r4, r4, #1

.no_newline_found:
    mov r2, #0
    strb r2, [r1, r4]

.no_input_read:
    mov r0, r4
    pop {r4, lr}
    bx lr

print_string:
    push {lr}
    mov r7, #SYS_WRITE
    svc #0
    pop {lr}
    bx lr

atoi:
    push {r1, r2, r3, r8, r12, lr}
    mov r1, #0
    mov r2, #0
    ldr r12, =10

atoi_loop:
    ldrb r3, [r0, r2]
    cmp r3, #0
    beq atoi_done

    sub r3, r3, #'0'
    mul r8, r1, r12
    add r1, r8, r3
    add r2, r2, #1
    b atoi_loop

atoi_done:
    mov r0, r1
    pop {r1, r2, r3, r8, r12, lr}
    bx lr

itoa:
    push {r2-r12, lr}
    mov r2, r1
    mov r3, #0
    mov r5, #10

    cmp r0, #0
    bne .itoa_loop_start

    mov r6, #'0'
    strb r6, [r1]
    add r1, r1, #1
    mov r3, #1
    b .itoa_done

.itoa_loop_start:
    mov r6, r0
    mov r7, r1

.itoa_loop:
    udiv r8, r6, r5
    mul r9, r8, r5
    sub r10, r6, r9
    add r10, r10, #'0'
    strb r10, [r7]
    add r7, r7, #1
    add r3, r3, #1

    mov r6, r8
    cmp r6, #0
    bne .itoa_loop

.itoa_done:
    mov r4, #0
    strb r4, [r7]

    mov r6, r1
    sub r7, r7, #1

.itoa_reverse_loop_cond:
    cmp r6, r7
    bge .itoa_reverse_done

.itoa_reverse_loop:
    ldrb r8, [r6]
    ldrb r9, [r7]
    strb r9, [r6]
    strb r8, [r7]
    add r6, r6, #1
    sub r7, r7, #1
    b .itoa_reverse_loop_cond

.itoa_reverse_done:
    mov r0, r3
    pop {r2-r12, lr}
    bx lr

is_prime:
    push {r1-r3, lr}

    cmp r0, #1
    ble .not_prime_val

    cmp r0, #2
    beq .is_prime_val

    mov r1, r0, lsr #1
    lsl r1, r1, #1
    cmp r1, r0
    beq .not_prime_val

    mov r1, #3

.prime_loop_cond:
    mul r2, r1, r1
    cmp r2, r0
    bgt .is_prime_val

.prime_loop:
    sdiv r2, r0, r1
    mul r3, r2, r1
    cmp r3, r0
    beq .not_prime_val

    add r1, r1, #2
    b .prime_loop_cond

.is_prime_val:
    mov r0, #1
    b .prime_exit

.not_prime_val:
    mov r0, #0

.prime_exit:
    pop {r1-r3, lr}
    bx lr

calculate_totient:
    push {r2, lr} @ Save r2 and link register
    sub r0, r0, #1 @ r0 = p - 1
    sub r1, r1, #1 @ r1 = q - 1
    mul r2, r0, r1 @ r2 = (p-1) * (q-1) - result stored in r2
    mov r0, r2 @ Move result from r2 to r0 for return
    pop {r2, lr} @ Restore r2 and link register
    bx lr @ Return from function
