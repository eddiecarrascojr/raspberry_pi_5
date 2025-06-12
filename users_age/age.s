// File: age_program.s
.data

prompt:
    .asciz "Please enter your age: "
prompt_len = . - prompt

output_msg:
    .asciz "You are "
output_msg_len = . - output_msg

output_end:
    .asciz " years old.\n"
output_end_len = . - output_end

// Buffer to store user input. .space allocates bytes.
.align 2
input_buffer:
    .space 4 // Enough for a 3-digit age + newline

.text
.global _start

_start:
    // 1. Prompt for user's age using the 'write' syscall
    mov x0, #1              // 1 = stdout (standard output file descriptor)
    ldr x1, =prompt         // Load address of the prompt message into x1
    mov x2, #prompt_len     // Load length of the prompt message into x2
    mov x8, #64             // 64 = 'write' syscall number for ARM64
    svc #0                  // Make the system call to the kernel

    // 2. Read user's input using the 'read' syscall
    mov x0, #0              // 0 = stdin (standard input file descriptor)
    ldr x1, =input_buffer   // Load address of the input buffer into x1
    mov x2, #4              // Maximum number of bytes to read
    mov x8, #63             // 63 = 'read' syscall number for ARM64
    svc #0                  // Make the system call
    // The number of bytes actually read is returned in x0.
    // Let's save this value so we can use it later.
    mov x3, x0              // Save the number of bytes read into x3

    // 3. Print the first part of the output message: "You are "
    mov x0, #1
    ldr x1, =output_msg
    mov x2, #output_msg_len
    mov x8, #64
    svc #0

    // 4. Print the user's age (which is in the buffer)
    mov x0, #1
    ldr x1, =input_buffer
    // The 'read' syscall includes the 'Enter' key (\n). We don't want to print that.
    sub x2, x3, #1          // Subtract 1 from the length to exclude the newline
    mov x8, #64
    svc #0

    // 5. Print the last part of the output message: " years old.\n"
    mov x0, #1
    ldr x1, =output_end
    mov x2, #output_end_len
    mov x8, #64
    svc #0

    // 6. Exit the program
    mov x0, #0              // 0 = exit code (success)
    mov x8, #93             // 93 = 'exit' syscall number for ARM64
    svc #0                  // Make the system call
