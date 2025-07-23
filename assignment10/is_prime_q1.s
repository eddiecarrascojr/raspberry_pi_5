.global _start

.data
    @ Data section for messages and buffers
    prompt_msg: .ascii "Enter a number (n): "
    prompt_len = . - prompt_msg

    output_buffer: .space 12  @ Buffer for converting integer to ASCII (max 10 digits + newline + null)
    comma_space:   .ascii ", "
    comma_space_len = . - comma_space
    newline:       .ascii "\n"
    newline_len = . - newline
    
    error_msg: .ascii "Error: Division by zero in remainder_func. Exiting.\n"
    error_len = . - error_msg

.bss
    @ BSS section for uninitialized data (e.g., input buffer)
    input_buffer: .space 20 @ Buffer for reading user input string (max 19 chars + newline)
    input_num: .word 0     @ Memory location to store the integer value of 'n'

.text
    @ The entry point of the program
_start:
    @ Prompt the user to enter a number
    mov r0, #1          @ File descriptor for stdout (console output)
    ldr r1, =prompt_msg @ Address of the prompt message
    ldr r2, =prompt_len @ Length of the prompt message
    mov r7, #4          @ System call number for sys_write
    svc #0              @ Execute system call

    @ Read the user's input number
    mov r0, #0          @ File descriptor for stdin (console input)
    ldr r1, =input_buffer @ Address of the input buffer
    mov r2, #20         @ Maximum number of bytes to read
    mov r7, #3          @ System call number for sys_read
    svc #0              @ Execute system call
    mov r4, r0          @ Store the actual number of bytes read in r4 (for ascii_to_int)

    @ Convert the input string (ASCII) to an integer
    ldr r0, =input_buffer @ r0 holds the address of the input string
    mov r1, r4          @ r1 holds the length of the input string
    bl ascii_to_int     @ Call the ascii_to_int subroutine
    ldr r10, =input_num @ Load the address of input_num into r10
    str r0, [r10]       @ Store the converted integer (from r0) into input_num
    mov r10, r0         @ r10 now holds the user-provided integer 'n'

    @ Initialize current number 'i' to 3 (as per problem statement)
    mov r4, #3          @ r4 will hold the current number 'i' being checked for primality

    @ Flag to track if the first prime number has been printed (for comma handling)
    mov r9, #0          @ r9 = 0 (false) if no prime printed yet, 1 (true) otherwise

outer_loop:
    cmp r4, r10         @ Compare current number 'i' (r4) with 'n' (r10)
    bgt exit_program    @ If i > n, we've checked all numbers, so exit the program

    @ Assume current number r4 is prime initially for this iteration
    mov r6, #1          @ r6 = is_prime_flag (1 = true, 0 = false)

    @ Initialize divisor 'j' to 2 for the inner loop
    mov r5, #2          @ r5 will hold the current divisor 'j'

    @ Calculate the limit for the inner loop: i / 2
    @ We use the remainder_func to get the quotient (integer division)
    mov r0, r4          @ r0 = dividend (current number 'i')
    mov r1, #2          @ r1 = divisor (2)
    bl remainder_func   @ Call remainder_func. Quotient will be in r2.
    mov r8, r2          @ r8 now holds the limit (i / 2) for the inner loop

inner_loop:
    cmp r5, r8          @ Compare current divisor 'j' (r5) with the limit (i/2) (r8)
    bgt end_inner_loop  @ If j > limit, inner loop finished without finding a divisor, so 'i' is prime

    @ Call remainder_func to check if 'i' (r4) is divisible by 'j' (r5)
    mov r0, r4          @ r0 = dividend (current number 'i')
    mov r1, r5          @ r1 = divisor (current divisor 'j')
    bl remainder_func   @ Call remainder_func. Remainder will be in r0.

    cmp r0, #0          @ Compare the remainder with 0
    beq not_prime       @ If remainder is 0, 'i' is divisible by 'j', so 'i' is not prime

    add r5, r5, #1      @ Increment divisor j++
    b inner_loop        @ Continue to the next iteration of the inner loop

not_prime:
    mov r6, #0          @ Set the is_prime_flag to false (0)
    b end_inner_loop    @ Exit the inner loop immediately

end_inner_loop:
    cmp r6, #1          @ Check if is_prime_flag is true (1)
    bne next_outer_loop @ If not prime, skip printing and move to the next number

    @ If the number is prime, print it
    cmp r9, #1          @ Check if this is the first prime number being printed
    beq print_comma     @ If not the first, print a comma and space before the number

    @ This is the very first prime number, so just print the number
    mov r9, #1          @ Set the first_prime_printed flag to true (1)
    mov r0, r4          @ r0 holds the number to print
    bl print_int        @ Call the print_int subroutine
    b next_outer_loop   @ Move to the next number in the outer loop

print_comma:
    @ Print a comma and a space before the current prime number
    mov r0, #1          @ stdout
    ldr r1, =comma_space @ Address of ", " string
    ldr r2, =comma_space_len @ Length of ", " string
    mov r7, #4          @ sys_write
    svc #0              @ Execute system call

    mov r0, r4          @ r0 holds the number to print
    bl print_int        @ Call the print_int subroutine

next_outer_loop:
    add r4, r4, #1      @ Increment current number i++
    b outer_loop        @ Continue to the next iteration of the outer loop

exit_program:
    @ Print a final newline character for clean output
    mov r0, #1          @ stdout
    ldr r1, =newline    @ Address of newline character
    ldr r2, =newline_len @ Length of newline character
    mov r7, #4          @ sys_write
    svc #0              @ Execute system call

    @ Exit the program cleanly
    mov r0, #0          @ Exit code 0 (success)
    mov r7, #1          @ System call number for sys_exit
    svc #0              @ Execute system call

@ -----------------------------------------------------------------------------
@ Subroutine: remainder_func
@ Description: Calculates dividend % divisor without using mod/rem operators.
@              It uses integer division and subtraction.
@ Input:
@   r0 = dividend
@   r1 = divisor
@ Output:
@   r0 = remainder
@   r2 = quotient (as a side effect, useful for other calculations)
@ Clobbers: r3 (scratch register)
@ -----------------------------------------------------------------------------
remainder_func:
    push {r4, r5, lr}   @ Save registers that might be used by the caller

    cmp r1, #0          @ Check for division by zero
    beq .div_by_zero_error @ If divisor is 0, branch to error handling

    udiv r2, r0, r1     @ Unsigned integer division: r2 = r0 / r1 (quotient)
    mul r3, r2, r1      @ Multiplication: r3 = r2 * r1 (quotient * divisor)
    sub r0, r0, r3      @ Subtraction: r0 = r0 - r3 (dividend - (quotient * divisor) = remainder)

    pop {r4, r5, lr}    @ Restore saved registers
    bx lr               @ Return from subroutine

.div_by_zero_error:
    @ Print an error message and exit the program if division by zero occurs
    mov r0, #1          @ stdout
    ldr r1, =error_msg  @ Address of error message
    ldr r2, =error_len  @ Length of error message
    mov r7, #4          @ sys_write
    svc #0              @ Execute system call
    mov r0, #1          @ Exit code 1 (error)
    mov r7, #1          @ sys_exit
    svc #0              @ Execute system call

@ -----------------------------------------------------------------------------
@ Subroutine: print_int
@ Description: Converts an integer in r0 to its ASCII string representation
@              and prints it to stdout.
@ Input:
@   r0 = integer to print
@ Clobbers: r4, r5, r6, r7, r8 (local scratch registers)
@ -----------------------------------------------------------------------------
print_int:
    push {r4, r5, r6, r7, r8, lr} @ Save registers used by this subroutine

    mov r4, r0          @ Save the original number to be converted
    ldr r1, =output_buffer @ Load the address of the output buffer
    mov r5, r1          @ r5 will be used as a pointer to the current position in the buffer

    @ Handle the special case where the number is zero
    cmp r4, #0
    beq .print_zero     @ If number is 0, branch to print "0" directly

    @ Convert integer to ASCII digits (stored in reverse order in the buffer)
    mov r6, #0          @ r6 will count the number of digits
.int_to_ascii_loop:
    mov r0, r4          @ r0 = current number (dividend)
    mov r1, #10         @ r1 = divisor (10)
    bl remainder_func   @ Call remainder_func. Remainder (digit) in r0, quotient in r2.
    add r0, r0, #'0'    @ Convert the digit (0-9) to its ASCII character ('0'-'9')
    strb r0, [r5, r6]   @ Store the ASCII digit byte into the buffer at offset r6
    add r6, r6, #1      @ Increment the digit count
    mov r4, r2          @ Move the quotient (r2) to r4 for the next iteration
    cmp r4, #0          @ Check if the quotient is zero
    bne .int_to_ascii_loop @ If not zero, continue converting digits

    @ The digits are now in the buffer in reverse order. Reverse the string in place.
    mov r7, #0          @ r7 = left pointer (index 0)
    sub r8, r6, #1      @ r8 = right pointer (last digit's index)
.reverse_loop:
    cmp r7, r8          @ Compare left and right pointers
    bge .reverse_done   @ If left >= right, string is reversed or has 0/1 char

    ldrb r0, [r5, r7]   @ Load byte from left pointer (char_left)
    ldrb r1, [r5, r8]   @ Load byte from right pointer (char_right)
    strb r1, [r5, r7]   @ Store char_right at left pointer's position
    strb r0, [r5, r8]   @ Store char_left at right pointer's position

    add r7, r7, #1      @ Increment left pointer
    sub r8, r8, #1      @ Decrement right pointer
    b .reverse_loop     @ Continue reversing

.reverse_done:
    @ Print the now correctly ordered ASCII string
    mov r0, #1          @ stdout
    ldr r1, =output_buffer @ Address of the string to print
    mov r2, r6          @ Length of the string (number of digits)
    mov r7, #4          @ sys_write
    svc #0              @ Execute system call

    pop {r4, r5, r6, r7, r8, lr} @ Restore saved registers
    bx lr               @ Return from subroutine

.print_zero:
    @ Special handling for printing the number 0
    mov r0, #1          @ stdout
    ldr r1, =output_buffer @ Address of the output buffer
    mov r2, #1          @ Length is 1 for "0"
    movb r3, #'0'       @ Load ASCII '0' into r3
    strb r3, [r1]       @ Store '0' into the first byte of the buffer
    mov r7, #4          @ sys_write
    svc #0              @ Execute system call
    pop {r4, r5, r6, r7, r8, lr} @ Restore saved registers
    bx lr               @ Return from subroutine

@ -----------------------------------------------------------------------------
@ Subroutine: ascii_to_int
@ Description: Converts an ASCII string (read from input) to its integer value.
@              It stops conversion at a newline character or end of string.
@ Input:
@   r0 = address of the ASCII string
@   r1 = length of the string
@ Output:
@   r0 = converted integer value
@ Clobbers: r4, r5, r6, r7 (local scratch registers)
@ -----------------------------------------------------------------------------
ascii_to_int:
    push {r4, r5, r6, r7, lr} @ Save registers used by this subroutine

    mov r4, r0          @ r4 = address of the string
    mov r5, r1          @ r5 = length of the string
    mov r6, #0          @ r6 = current integer value (accumulator, starts at 0)
    mov r7, #0          @ r7 = current index in the string

.loop_char:
    cmp r7, r5          @ Compare current index with string length
    bge .end_conversion @ If index >= length, we've processed the whole string

    ldrb r0, [r4, r7]   @ Load the character byte from the string at current index
    cmp r0, #10         @ Check for newline character (ASCII 10)
    beq .end_conversion @ If it's a newline, stop conversion (sys_read often includes it)

    sub r0, r0, #'0'    @ Convert ASCII digit to its integer value (e.g., '5' - '0' = 5)
    mul r6, r6, #10     @ Multiply current result by 10 (shift left for next digit)
    add r6, r6, r0      @ Add the new digit to the result

    add r7, r7, #1      @ Increment the index to move to the next character
    b .loop_char        @ Continue processing characters

.end_conversion:
    mov r0, r6          @ Move the final integer result to r0 for return
    pop {r4, r5, r6, r7, lr} @ Restore saved registers
    bx lr               @ Return from subroutine
