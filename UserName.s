.global _start

.section .data
prompt:       .asciz "Enter your age: "
msg_start:    .asciz "Your age is:\t\""
msg_end:      .asciz "\"\tyears old\n"

.section .bss
age:    .skip 4    @ space to store age input (e.g., "23\n")

.section .text
_start:
    @ Print prompt
    mov r0, #1              @ stdout
    ldr r1, =prompt
    mov r2, #16             @ length of prompt string
    mov r7, #4              @ syscall: write
    svc 0

    @ Read age from user
    mov r0, #0              @ stdin
    ldr r1, =age
    mov r2, #4              @ read up to 4 bytes
    mov r7, #3              @ syscall: read
    svc 0

    @ Output "Your age is:	\""
    mov r0, #1
    ldr r1, =msg_start
    mov r2, #16             @ includes tab and quote
    mov r7, #4
    svc 0

    @ Output user input (age)
    mov r0, #1
    ldr r1, =age
    mov r2, #2              @ assuming 2-digit age (excluding newline)
    mov r7, #4
    svc 0

    @ Output "\"	years old\n"
    mov r0, #1
    ldr r1, =msg_end
    mov r2, #13             @ quote + tab + "years old\n"
    mov r7, #4
    svc 0

    @ Exit
    mov r0, #0
    mov r7, #1
    svc 0
