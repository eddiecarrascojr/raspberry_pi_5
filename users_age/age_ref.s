.data

prompt:
    .asciz "Please enter your age: "
prompt_len = . - prompt

before_read_msg: .asciz "\n--- Values Before 'read' Syscall ---\n"
after_read_msg:  .asciz "\n--- Values After 'read' Syscall ---\n"
before_write_msg:.asciz "\n--- Values Before 'write' Syscall ---\n"
reg_x0_msg:      .asciz "x0: "
reg_x1_msg:      .asciz "x1: "
reg_x2_msg:      .asciz "x2: "
reg_x3_msg:      .asciz "x3: "

hex_prefix: .asciz "0x"
hex_chars:  .asciz "0123456789abcdef"
hex_buffer: .space 20

output_msg:
    .asciz "You are\t"
output_msg_len = . - output_msg

output_end:
    .asciz "\tyears old.\n"
output_end_len = . - output_end

.align 2
input_buffer:
    .space 4

.text

print_register_hex:
    mov x1, x0
    ldr x2, =hex_buffer
    mov x3, #60

print_hex_loop:
    lsr x4, x1, x3
    and x4, x4, #0xF
    ldr x5, =hex_chars
    ldrb w5, [x5, x4]
    strb w5, [x2], #1
    subs x3, x3, #4
    b.ge print_hex_loop

    mov w5, #'\n'
    strb w5, [x2]

    mov x0, #1
    ldr x1, =hex_prefix
    mov x2, #2
    mov x8, #64
    svc #0

    mov x0, #1
    ldr x1, =hex_buffer
    mov x2, #17
    mov x8, #64
    svc #0

    ret

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

    sub sp, sp, #32
    stp x0, x1, [sp, #0]
    stp x2, x3, [sp, #16]

    ldr x1, =before_read_msg
    mov x2, #37
    mov x0, #1
    mov x8, #64
    svc #0

    ldr x1, =reg_x0_msg
    mov x2, #4
    svc #0
    ldr x0, [sp, #0]
    bl print_register_hex

    ldr x1, =reg_x1_msg
    mov x2, #4
    mov x0, #1
    mov x8, #64
    svc #0
    ldr x0, [sp, #8]
    bl print_register_hex

    ldr x1, =reg_x2_msg
    mov x2, #4
    mov x0, #1
    mov x8, #64
    svc #0
    ldr x0, [sp, #16]
    bl print_register_hex

    ldp x0, x1, [sp, #0]
    ldp x2, x3, [sp, #16]
    add sp, sp, #32

    svc #0
    mov x19, x0

    ldr x1, =after_read_msg
    mov x2, #36
    mov x0, #1
    mov x8, #64
    svc #0
    ldr x1, =reg_x0_msg
    mov x2, #4
    svc #0
    mov x0, x19
    bl print_register_hex

    mov x0, #1
    ldr x1, =output_msg
    mov x2, #output_msg_len
    mov x8, #64

    sub sp, sp, #32
    stp x0, x1, [sp, #0]
    stp x2, x3, [sp, #16]
    ldr x1, =before_write_msg
    mov x2, #38
    mov x0, #1
    mov x8, #64
    svc #0
    ldr x1, =reg_x0_msg
    mov x2, #4
    svc #0
    ldr x0, [sp, #0]
    bl print_register_hex
    ldr x1, =reg_x1_msg
    mov x2, #4
    mov x0, #1
    mov x8, #64
    svc #0
    ldr x0, [sp, #8]
    bl print_register_hex
    ldr x1, =reg_x2_msg
    mov x2, #4
    mov x0, #1
    mov x8, #64
    svc #0
    ldr x0, [sp, #16]
    bl print_register_hex
    ldp x0, x1, [sp, #0]
    ldp x2, x3, [sp, #16]
    add sp, sp, #32

    svc #0

    mov x0, #0
    mov x8, #93
    svc #0
