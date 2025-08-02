# Program:      Fibonacci Recursive calculator
# Author:       Eddie Carrasco Jr
# Date:         8/1/2025
# Description:  This program calculates the nth Fibonacci number using a
#               recursive function. It prompts the user for a positive integer 'n',
#               computes F(n), and prints the result.
#
# To assemble and link on a Raspberry Pi:
#   as -o fibonacci_recusively.o fibonacci_recusively.s
#   gcc -o fibonacci_recusively fibonacci_recusively.o
#   ./fibonacci_recusively
#
# fib: Recursive function to calculate the nth Fibonacci number
#   Calculates F(n) where F(n) = F(n-1) + F(n-2)
#   Base cases: F(0) = 0, F(1) = 1
#   Input:
#       r0: The integer n
#   Output:
#       r0: The nth Fibonacci number


.global main

// Main program entry point.
main:
    // Prompt the user for input.
    MOV r0, #1
    LDR r1, =prompt_msg
    MOV r2, #prompt_msg_len
    MOV r7, #4
    SWI 0

    // Read user input.
    MOV r0, #0
    LDR r1, =input_buffer 
    MOV r2, #16
    MOV r7, #3
    SWI 0
    
    // Convert input string to integer.
    LDR r0, =input_buffer
    BL atoi_custom
    LDR r1, =input_n
    STR r0, [r1]

    // Call the recursive Fibonacci function.
    LDR r0, [r1]
    BL fib_recursive
    
    // Store the result.
    LDR r1, =result_fib
    STR r0, [r1]

    // Print the final result.
    BL print_result

    // Exit the program.
    MOV r0, #0
    MOV r7, #1
    SWI 0


// Recursive Fibonacci function.
// r0 = n
// returns: r0 = F(n)
fib_recursive:
    PUSH {r4, lr}     
    MOV r4, r0

    // Check for base cases
    CMP r0, #0
    BEQ fib_zero_exit
    CMP r0, #1
    BEQ fib_one_exit

    // Calculate F(n-1)
    SUB r0, r4, #1
    BL fib_recursive
    MOV r1, r0  

    // Calculate F(n-2)
    SUB r0, r4, #2
    BL fib_recursive 
    
    // ADD the two results
    ADD r0, r0, r1
    B fib_return

fib_zero_exit:
    MOV r0, #0
    B fib_return
    
fib_one_exit:
    MOV r0, #1
    
fib_return:
    POP {r4, lr} 
    BX lr

// Converts a null-terminated ASCII string to an integer.
// r0 = address of string
// returns: r0 = integer value
atoi_custom:
    PUSH {r1, r2, r3, lr}
    MOV r1, #0
    MOV r2, #0
    MOV r3, #0

atoi_loop:
    LDRB r2, [r0]
    CMP r2, #0
    BEQ atoi_done

    CMP r2, #'0'
    blt atoi_next_char
    CMP r2, #'9'
    BGT atoi_next_char

    SUB r3, r2, #'0'
    MOV r4, #10
    mul r5, r1, r4
    MOV r1, r5
    ADD r1, r1, r3

atoi_next_char:
    ADD r0, r0, #1
    B atoi_loop

atoi_done:
    MOV r0, r1
    POP {r1, r2, r3, lr}
    BX lr

// A function to print the final output string.
print_result:
    PUSH {r1, r2, r3, lr}
    
    // Print "F("
    MOV r0, #1
    LDR r1, =f_paren_msg
    MOV r2, #2
    MOV r7, #4
    SWI 0
    
    // Print the value of n
    LDR r0, =input_n
    LDR r0, [r0]
    BL itoa_custom
    MOV r1, r0
    MOV r0, #1
    MOV r2, r3
    MOV r7, #4
    SWI 0
    
    // Print ") = "
    MOV r0, #1
    LDR r1, =eq_msg
    MOV r2, #4
    MOV r7, #4
    SWI 0
    
    // Print the result
    LDR r0, =result_fib
    LDR r0, [r0]
    BL itoa_custom
    MOV r1, r0
    MOV r0, #1
    MOV r2, r3
    MOV r7, #4
    SWI 0
    
    // Print the newline character
    MOV r0, #1
    LDR r1, =newline_char
    MOV r2, #1
    MOV r7, #4
    SWI 0
    
    POP {r1, r2, r3, lr}
    BX lr
    
// Converts an integer to a null-terminated ASCII string.
itoa_custom:
    PUSH {r1, r2, r4, r5, r6, lr}
    LDR r1, =output_buffer + 19
    MOV r2, #0
    MOV r4, #10
    MOV r5, r1
# Print out the outer loop
itoa_loop:
    udiv r6, r0, r4
    mls r1, r6, r4, r0
    ADD r1, r1, #'0'
    strB r1, [r5]
    SUB r5, r5, #1
    MOV r0, r6
    ADD r2, r2, #1
    CMP r0, #0
    BNE itoa_loop

    ADD r5, r5, #1
    MOV r0, r5
    MOV r3, r2
    POP {r1, r2, r4, r5, r6, lr}
    BX lr

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
