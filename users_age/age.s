.data

prompt:
    .asciz "Please enter your age: "
prompt_len = . - prompt

output_msg:
    .asciz "'You are "
output_msg_len = . - output_msg

tab_char:
    .ascii "\t"
tab_len = 1

output_end:
    .asciz "years old.'\n"
output_end_len = . - output_end

.align 2
input_buffer:
    .space 4

.text
.global _start

_start:
    mov x0, #1
    ldr x1, =prompt
    mov x2, #prompt_len
    mov x8, #64
    svc #0

    mov x0, #0
    ldr x1, =input_buffer
    mov x2, #4
    mov x8, #63
    svc #0
    mov x3, x0

    mov x0, #1
    ldr x1, =output_msg
    mov x2, #output_msg_len
    mov x8, #64
    svc #0

    mov x0, #1
    ldr x1, =tab_char
    mov x2, #tab_len
    mov x8, #64
    svc #0

    mov x0, #1
    ldr x1, =input_buffer
    sub x2, x3, #1
    mov x8, #64
    svc #0

    mov x0, #1
    ldr x1, =tab_char
    mov x2, #tab_len
    mov x8, #64
    svc #0

    mov x0, #1
    ldr x1, =output_end
    mov x2, #output_end_len
    mov x8, #64
    svc #0

    mov x0, #0
    mov x8, #93
    svc #0
