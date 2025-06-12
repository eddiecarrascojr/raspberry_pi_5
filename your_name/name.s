.data
    prompt: .ascii "Enter your name: "
    prompt_len = . - prompt
    newline: .asciz "\n"
    buffer_size = 128
    name_buffer: .space buffer_size

.text
.global _start

_start:
    # Print the prompt string 
    mov x0, #1
    adrp x1, prompt
    add x1, x1, :lo12:prompt
    mov x2, #prompt_len
    mov x8, #64
    svc #0

    # Read the name from stdin
    mov x0, #0
    adrp x1, name_buffer
    add x1, x1, :lo12:name_buffer
    mov x2, #buffer_size-1
    mov x8, #63
    svc #0
    mov x19, x0

    # Add a null terminator to the read strin
    cmp x19, #0
    ble .exit

    add x1, x1, x19
    mov w0, #0
    strb w0, [x1]

    # Print a newline character
    mov x0, #1
    adrp x1, newline
    add x1, x1, :lo12:newline
    mov x2, #1
    mov x8, #64
    svc #0

    # Print the entered name
    mov x0, #1
    adrp x1, name_buffer
    add x1, x1, :lo12:name_buffer
    mov x2, x19
    mov x8, #64
    svc #0

.exit:
    # Exit the program
    mov x0, #0
    mov x8, #93
    svc #0
