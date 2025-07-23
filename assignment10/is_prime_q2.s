.global _start

.data
    prompt_msg: .asciz "Enter a number (-1 to quit): "
    prompt_len = . - prompt_msg

    prime_str: .asciz "Number "
    prime_str_len = . - prime_str

    is_prime_str: .asciz " is prime\n"
    is_prime_str_len = . - is_prime_str

    not_prime_str: .asciz " is not prime\n"
    not_prime_str_len = . - not_prime_str

    error_invalid_input_str: .asciz "Error: Invalid input (0, 1, 2, or negative other than -1).\n"
    error_invalid_input_len = . - error_invalid_input_str

    newline_str: .asciz "\n"
    newline_len = . - newline_str

    input_buffer: .space 20   @ Buffer for user input (e.g., "2147483647\n\0")
    output_buffer: .space 20  @ Buffer for converting integer to string for printing

.text
_start:
    b main_loop

@ Subroutine: print_string
@ R0: Address of the string to print
@ R1: Length of the string
print_string:
    push {r4, lr}           @ Save r4 and Link Register
    mov r2, r1              @ Length of string
    mov r1, r0              @ Address of string
    mov r0, #1              @ File descriptor (stdout)
    mov r7, #4              @ sys_write system call number
    svc #0                  @ Call kernel
    pop {r4, lr}            @ Restore r4 and Link Register
    bx lr                   @ Return

@ Subroutine: read_input
@ R0: Address of buffer to store input
@ R1: Maximum bytes to read
@ Returns: Number of bytes read in R0
read_input:
    push {lr}               @ Save Link Register
    mov r2, r1              @ Max bytes to read
    mov r1, r0              @ Buffer address
    mov r0, #0              @ File descriptor (stdin)
    mov r7, #3              @ sys_read system call number
    svc #0                  @ Call kernel
    pop {lr}                @ Restore Link Register
    bx lr                   @ Return

@ Subroutine: atoi (ASCII to Integer)
@ R0: Address of the null-terminated string
@ Returns: Integer value in R0
atoi:
    push {r1, r2, r3, r4, lr} @ Save registers and Link Register
    mov r4, r0                @ Save string address in r4
    mov r0, #0                @ Initialize result to 0
    mov r1, #1                @ Initialize sign to 1 (positive)
    ldrb r2, [r4]             @ Load first character

    cmp r2, #'-'              @ Check for negative sign
    bne atoi_check_plus
    mov r1, #-1               @ Set sign to negative
    add r4, r4, #1            @ Advance string pointer
    ldrb r2, [r4]             @ Load next character
    b atoi_loop_start

atoi_check_plus:
    cmp r2, #'+'              @ Check for positive sign (optional, but good practice)
    bne atoi_loop_start
    add r4, r4, #1            @ Advance string pointer
    ldrb r2, [r4]             @ Load next character

atoi_loop_start:
    cmp r2, #'0'              @ Check if character is a digit
    blt atoi_end_loop         @ If less than '0', end loop
    cmp r2, #'9'
    bgt atoi_end_loop         @ If greater than '9', end loop

    sub r2, r2, #'0'          @ Convert ASCII digit to integer
    mul r0, r0, #10           @ Multiply current result by 10
    add r0, r0, r2            @ Add current digit
    add r4, r4, #1            @ Advance string pointer
    ldrb r2, [r4]             @ Load next character
    b atoi_loop_start         @ Continue loop

atoi_end_loop:
    mul r0, r0, r1            @ Apply sign to the result
    pop {r1, r2, r3, r4, lr}  @ Restore registers and Link Register
    bx lr                     @ Return

@ Subroutine: itoa (Integer to ASCII)
@ R0: Integer value
@ R1: Address of buffer to store ASCII string
@ Returns: Length of the string in R0
itoa:
    push {r4, r5, r6, r7, lr} @ Save registers and Link Register
    mov r4, r1                @ Save buffer address in r4
    mov r5, #0                @ r5 will store string length
    mov r6, #0                @ r6 will be used as index for buffer

    cmp r0, #0                @ Check if number is 0
    beq itoa_handle_zero

    mov r7, #0                @ r7 = 0, flag for negative number

    cmp r0, #0                @ Check if number is negative
    bge itoa_positive
    mov r7, #1                @ Set negative flag
    mvn r0, r0                @ Invert bits (two's complement negation)
    add r0, r0, #1            @ Add 1 for two's complement negation

itoa_positive:
    mov r2, #10               @ Divisor (10)
    mov r3, sp                @ Use stack as temporary storage for digits
    sub sp, sp, #16           @ Allocate space on stack for up to 10 digits + sign

itoa_loop:
    cmp r0, #0                @ Loop while number > 0
    beq itoa_store_digits

    mov r1, r0                @ Copy number to r1 for division
    bl __aeabi_uidivmod       @ Call ARM's unsigned integer division/modulo
                              @ R0 = quotient, R1 = remainder (after divmod)

    add r1, r1, #'0'          @ Convert remainder to ASCII digit
    strb r1, [r3, #-1]!       @ Store digit on stack (pre-decrement)
    add r5, r5, #1            @ Increment length
    b itoa_loop               @ Continue loop

itoa_store_digits:
    cmp r7, #1                @ Check if original number was negative
    beq itoa_add_minus
    b itoa_copy_to_buffer

itoa_add_minus:
    mov r1, #'-'              @ Add '-' sign
    strb r1, [r3, #-1]!       @ Store '-' on stack
    add r5, r5, #1            @ Increment length

itoa_copy_to_buffer:
    ldr r1, [r3], #1          @ Load digit from stack (post-increment)
    strb r1, [r4, r6]         @ Store digit in output buffer
    add r6, r6, #1            @ Increment buffer index
    cmp r5, r6                @ Compare length with current index
    bne itoa_copy_to_buffer   @ Continue copying until all digits are moved

    strb r6, [r4, r6]         @ Add null terminator (this is incorrect, should be #0)
    mov r1, #0
    strb r1, [r4, r6]         @ Add null terminator

    add sp, sp, #16           @ Deallocate stack space
    mov r0, r5                @ Return length in r0
    pop {r4, r5, r6, r7, lr}  @ Restore registers and Link Register
    bx lr                     @ Return

itoa_handle_zero:
    mov r1, #'0'              @ Store '0' character
    strb r1, [r4]             @ Store '0' in buffer
    mov r1, #0                @ Null terminator
    strb r1, [r4, #1]         @ Store null terminator after '0'
    mov r0, #1                @ Length is 1
    pop {r4, r5, r6, r7, lr}  @ Restore registers and Link Register
    bx lr                     @ Return

@ Subroutine: is_prime
@ R0: Integer value (n)
@ Returns: 1 in R0 if prime, 0 if not prime
is_prime:
    push {r1, r2, r3, r4, r5, lr} @ Save registers and Link Register
    mov r4, r0                    @ Save original n in r4

    cmp r4, #2                    @ If n < 2, not prime
    blt not_prime_result

    cmp r4, #2                    @ If n == 2, prime
    beq is_prime_result

    and r1, r4, #1                @ Check if n is even (n % 2 == 0)
    cmp r1, #0
    beq not_prime_result          @ If even and > 2, not prime

    mov r1, #3                    @ Start divisor 'i' from 3
    mov r2, r4                    @ r2 = n for division

    @ Calculate loop limit (n/2 for simplicity, though sqrt(n) is more efficient)
    @ UDIV R3, R4, #2             @ R3 = n / 2 (limit) - not direct instruction
    mov r3, r4                    @ Copy n to r3
    mov r5, #2                    @ Divisor
    bl __aeabi_uidivmod           @ R0 = quotient (n/2), R1 = remainder
    mov r3, r0                    @ r3 now holds n/2 (our loop limit)

prime_check_loop:
    cmp r1, r3                    @ Compare current divisor 'i' with limit (n/2)
    bgt is_prime_result           @ If i > limit, it's prime

    mov r0, r4                    @ Load n into r0 for division
    mov r2, r1                    @ Load i into r2 for division
    bl __aeabi_uidivmod           @ R0 = quotient (n/i), R1 = remainder (n % i)

    cmp r1, #0                    @ Check if remainder is 0
    beq not_prime_result          @ If remainder is 0, n is not prime

    add r1, r1, #2                @ Increment divisor 'i' by 2 (skip even numbers)
    b prime_check_loop            @ Continue loop

is_prime_result:
    mov r0, #1                    @ Set return value to 1 (prime)
    b prime_end

not_prime_result:
    mov r0, #0                    @ Set return value to 0 (not prime)

prime_end:
    pop {r1, r2, r3, r4, r5, lr}  @ Restore registers and Link Register
    bx lr                         @ Return

main_loop:
    @ Prompt user for input
    ldr r0, =prompt_msg
    ldr r1, =prompt_len
    bl print_string

    @ Read input into buffer
    ldr r0, =input_buffer
    mov r1, #20                     @ Max bytes to read
    bl read_input
    mov r5, r0                      @ Save bytes read (length) in r5

    @ Null-terminate the input string (replace newline with null)
    ldr r0, =input_buffer
    sub r5, r5, #1                  @ Adjust length to point to newline
    strb #0, [r0, r5]               @ Replace newline with null terminator

    @ Convert input string to integer
    ldr r0, =input_buffer
    bl atoi
    mov r4, r0                      @ Save the integer value in r4 (original number)

    @ Check for -1 to quit
    cmp r4, #-1
    beq exit_program

    @ Error check: 0, 1, 2, or any negative number other than -1
    cmp r4, #3                      @ Check if number is < 3
    bge check_prime_logic           @ If >= 3, proceed to prime check

    cmp r4, #0                      @ If number is 0, 1, 2 or negative (excluding -1)
    blt print_invalid_error         @ If negative (and not -1), it's an error
    cmp r4, #0
    beq print_invalid_error         @ If 0, it's an error
    cmp r4, #1
    beq print_invalid_error         @ If 1, it's an error
    cmp r4, #2
    beq print_invalid_error         @ If 2, it's an error (as per prompt, 2 should be prime, but user asked for error for 0, 1, 2)
                                    @ Re-reading the prompt: "print an error if 0, 1, 2 or any negative number other than -1 are entered."
                                    @ This means 2 should be an error. This is unusual for prime numbers, but I will follow the prompt.
                                    @ If 2 was meant to be prime, the condition would be `cmp r4, #0; blt print_invalid_error; cmp r4, #1; beq print_invalid_error; cmp r4, #0; beq print_invalid_error`

check_prime_logic:
    @ Call is_prime subroutine
    mov r0, r4                      @ Pass the number to is_prime
    bl is_prime
    mov r6, r0                      @ Save prime check result (1 for prime, 0 for not prime) in r6

    @ Convert original number to string for printing
    mov r0, r4                      @ Number to convert
    ldr r1, =output_buffer          @ Buffer for string
    bl itoa
    mov r5, r0                      @ Save length of converted number string

    @ Print "Number "
    ldr r0, =prime_str
    ldr r1, =prime_str_len
    bl print_string

    @ Print the number itself
    ldr r0, =output_buffer
    mov r1, r5                      @ Length of the number string
    bl print_string

    @ Print " is prime" or " is not prime"
    cmp r6, #1                      @ Check prime result
    beq print_is_prime

print_is_not_prime:
    ldr r0, =not_prime_str
    ldr r1, =not_prime_str_len
    bl print_string
    b main_loop

print_is_prime:
    ldr r0, =is_prime_str
    ldr r1, =is_prime_str_len
    bl print_string
    b main_loop

print_invalid_error:
    ldr r0, =error_invalid_input_str
    ldr r1, =error_invalid_input_len
    bl print_string
    b main_loop

exit_program:
    mov r0, #0                      @ Exit code 0
    mov r7, #1                      @ sys_exit system call number
    svc #0                          @ Call kernel
