# =============================================================================
# Program:      Recursive Fibonacci Calculator
# Author:       Gemini
# Date:         2024-07-31
# Description:  This program calculates the nth Fibonacci number using a
#               recursive function. It prompts the user for an integer 'n',
#               computes F(n), and prints the result.
# Target:       ARMv7-A (32-bit), suitable for Raspberry Pi 5
#
# To assemble and link on a Raspberry Pi:
#   as -o fib.o fib.s
#   gcc -o fib fib.o
#   ./fib
#
# fib: Recursive function to calculate the nth Fibonacci number
#   Calculates F(n) where F(n) = F(n-1) + F(n-2)
#   Base cases: F(0) = 0, F(1) = 1
#   Input:
#       r0: The integer n
#   Output:
#       r0: The nth Fibonacci number
# -----------------------------------------------------------------------------

.data

// Text and data for the program's messages.
prompt_msg:
    .ascii "Enter a non-negative integer (n) to calculate F(n): \0"
prompt_msg_len = . - prompt_msg

input_buffer:
    .space 16

input_n:
    .word 0

result_fib:
    .word 0

// A static buffer to hold the output strings from itoa_custom.
output_buffer:
    .space 20

// Individual strings for printing
f_paren_msg:
    .ascii "F(\0"
f_paren_len = . - f_paren_msg

eq_msg:
    .ascii ") = \0"
eq_len = . - eq_msg

newline_char:
    .ascii "\n\0"
newline_len = . - newline_char


.text
.section .text
.global _start

// Main program entry point.
_start:
    // Prompt the user for input.
    mov r0, #1                   // file descriptor: stdout
    ldr r1, =prompt_msg          // address of string
    mov r2, #prompt_msg_len      // length of string
    mov r7, #4                   // write syscall
    swi 0

    // Read user input.
    mov r0, #0                   // file descriptor: stdin
    ldr r1, =input_buffer        // address of buffer
    mov r2, #16                  // max length
    mov r7, #3                   // read syscall
    swi 0
    
    // Convert input string to integer.
    ldr r0, =input_buffer
    bl atoi_custom
    ldr r1, =input_n
    str r0, [r1]

    // Call the recursive Fibonacci function.
    ldr r0, [r1]
    bl fib_recursive
    
    // Store the result.
    ldr r1, =result_fib
    str r0, [r1]

    // Print the final result.
    bl print_result

    // Exit the program.
    mov r0, #0
    mov r7, #1
    swi 0


// Recursive Fibonacci function.
// r0 = n
// returns: r0 = F(n)
fib_recursive:
    push {r4, lr}     
    mov r4, r0

    // Check for base cases
    cmp r0, #0
    beq fib_zero_exit
    cmp r0, #1
    beq fib_one_exit

    // Calculate F(n-1)
    sub r0, r4, #1
    bl fib_recursive
    mov r1, r0  

    // Calculate F(n-2)
    sub r0, r4, #2
    bl fib_recursive 
    
    // Add the two results
    add r0, r0, r1
    b fib_return

fib_zero_exit:
    mov r0, #0
    b fib_return
    
fib_one_exit:
    mov r0, #1
    
fib_return:
    pop {r4, lr} 
    bx lr

// Converts a null-terminated ASCII string to an integer.
// r0 = address of string
// returns: r0 = integer value
atoi_custom:
    push {r1, r2, r3, lr}
    mov r1, #0
    mov r2, #0
    mov r3, #0

atoi_loop:
    ldrb r2, [r0]
    cmp r2, #0
    beq atoi_done

    cmp r2, #'0'
    blt atoi_next_char
    cmp r2, #'9'
    bgt atoi_next_char

    sub r3, r2, #'0'
    mov r4, #10
    mul r5, r1, r4
    mov r1, r5
    add r1, r1, r3

atoi_next_char:
    add r0, r0, #1
    b atoi_loop

atoi_done:
    mov r0, r1
    pop {r1, r2, r3, lr}
    bx lr

// A function to print the final output string.
print_result:
    push {r1, r2, r3, lr}
    
    // Print "F("
    mov r0, #1
    ldr r1, =f_paren_msg
    mov r2, #2
    mov r7, #4
    swi 0
    
    // Print the value of n
    ldr r0, =input_n
    ldr r0, [r0]
    bl itoa_custom
    mov r1, r0
    mov r0, #1
    mov r2, r3
    mov r7, #4
    swi 0
    
    // Print ") = "
    mov r0, #1
    ldr r1, =eq_msg
    mov r2, #4
    mov r7, #4
    swi 0
    
    // Print the result
    ldr r0, =result_fib
    ldr r0, [r0]
    bl itoa_custom
    mov r1, r0
    mov r0, #1
    mov r2, r3
    mov r7, #4
    swi 0
    
    // Print the newline character
    mov r0, #1
    ldr r1, =newline_char
    mov r2, #1
    mov r7, #4
    swi 0
    
    pop {r1, r2, r3, lr}
    bx lr
    
// Converts an integer to a null-terminated ASCII string.
// r0 = integer
// returns: r0 = address of string, r3 = length of string
itoa_custom:
    push {r1, r2, r4, r5, r6, lr}
    ldr r1, =output_buffer + 19
    mov r2, #0
    mov r4, #10
    mov r5, r1
    
itoa_loop:
    udiv r6, r0, r4
    mls r1, r6, r4, r0
    add r1, r1, #'0'
    strb r1, [r5]
    sub r5, r5, #1
    mov r0, r6
    add r2, r2, #1
    cmp r0, #0
    bne itoa_loop
    
    add r5, r5, #1
    mov r0, r5
    mov r3, r2
    pop {r1, r2, r4, r5, r6, lr}
    bx lr
