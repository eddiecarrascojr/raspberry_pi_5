.global _start

.data
    .align 4

    prompt_max:         .asciz "Enter the maximum value for your secret number: "
    len_prompt_max      = . - prompt_max

    prompt_guess:       .asciz "Is your number "
    len_prompt_guess    = . - prompt_guess

    prompt_feedback:    .asciz "? (h/l/c): "
    len_prompt_feedback = . - prompt_feedback

    msg_correct:        .asciz "Great! I guessed your number!\n"
    len_msg_correct     = . - msg_correct

    msg_invalid_input:  .asciz "Invalid input. Please enter 'h', 'l', or 'c'.\n"
    len_msg_invalid_input = . - msg_invalid_input

    newline:            .asciz "\n"
    len_newline         = . - newline

    input_buffer:       .space 16   @ Buffer for reading user input (e.g., max value, feedback char)
    num_buffer:         .space 16   @ Buffer for converting integer to string for printing

.text
_start:
    @ --- Prompt for maximum value ---
    ldr r0, =prompt_max
    bl _print_string_len @ R0 = string address, R1 = string length
    ldr r1, =len_prompt_max
    bl _print_string

    @ Read maximum value from user
    ldr r0, =input_buffer   @ R0 = buffer address
    mov r1, #16             @ R1 = buffer size
    bl _read_line           @ Reads line into input_buffer, returns length in R0
    mov r1, r0              @ Save length to R1 for _atoi
    ldr r0, =input_buffer   @ R0 = buffer address
    bl _atoi                @ Converts string in buffer to integer, returns int in R0
    mov r4, r0              @ Store max_value in R4 (high)

    @ Initialize binary search bounds
    mov r5, #1              @ R5 = low (start from 1)
    mov r6, r4              @ R6 = high (initially max_value)

guess_loop:
    @ Check if low > high (should not happen in a correct binary search with honest user)
    cmp r5, r6
    bgt exit_error          @ If low > high, something went wrong

    @ Calculate guess = (low + high) / 2
    add r0, r5, r6          @ R0 = low + high
    lsr r0, r0, #1          @ R0 = (low + high) / 2 (integer division)
    mov r7, r0              @ Store current guess in R7

    @ --- Prompt with the guess ---
    ldr r0, =prompt_guess
    ldr r1, =len_prompt_guess
    bl _print_string

    mov r0, r7              @ R0 = guess
    bl _print_int           @ Print the guessed number

    ldr r0, =prompt_feedback
    ldr r1, =len_prompt_feedback
    bl _print_string

    @ Read user feedback
    ldr r0, =input_buffer   @ R0 = buffer address
    mov r1, #2              @ R1 = buffer size (1 char + newline)
    bl _read_line           @ Read feedback into input_buffer, returns length in R0
    ldr r0, =input_buffer   @ R0 = address of feedback char
    ldrb r0, [r0]           @ Load the first byte (the feedback character) into R0

    @ Process feedback
    cmp r0, #'c'            @ Is it 'c'?
    beq correct_guess       @ If yes, branch to correct_guess

    cmp r0, #'h'            @ Is it 'h'?
    beq handle_higher       @ If yes, branch to handle_higher

    cmp r0, #'l'            @ Is it 'l'?
    beq handle_lower        @ If yes, branch to handle_lower

    @ Invalid input
    ldr r0, =msg_invalid_input
    ldr r1, =len_msg_invalid_input
    bl _print_string
    b guess_loop            @ Loop again for valid input

handle_higher:
    add r5, r7, #1          @ low = guess + 1
    b guess_loop            @ Continue guessing

handle_lower:
    sub r6, r7, #1          @ high = guess - 1
    b guess_loop            @ Continue guessing

correct_guess:
    ldr r0, =msg_correct
    ldr r1, =len_msg_correct
    bl _print_string
    b exit_program

exit_error:
    @ This path should theoretically not be reached with honest user input
    @ and correct binary search logic.
    mov r0, #1              @ Exit with error code 1
    mov r7, #1              @ SYS_EXIT
    svc #0

exit_program:
    mov r0, #0              @ Exit with success code 0
    mov r7, #1              @ SYS_EXIT
    svc #0

@ --- Helper function: _print_string ---
@ Prints a null-terminated string to stdout.
@ R0: Address of the string.
@ R1: Length of the string.
_print_string:
    push {r4, lr}           @ Save R4 and Link Register
    mov r4, r0              @ Save string address to R4
    mov r0, #1              @ File descriptor for stdout
    mov r1, r4              @ Address of string
    @ R2 (length) is passed by caller
    mov r7, #4              @ SYS_WRITE (syscall number for write)
    svc #0                  @ Call kernel
    pop {r4, lr}            @ Restore R4 and Link Register
    bx lr                   @ Return

@ --- Helper function: _print_string_len ---
@ Calculates string length and then prints.
@ R0: Address of the string.
_print_string_len:
    push {r0, lr}           @ Save R0 and LR
    bl _strlen              @ Call _strlen, returns length in R0
    mov r1, r0              @ Move length to R1 for _print_string
    pop {r0, lr}            @ Restore R0 and LR
    b _print_string         @ Jump to _print_string (tail call optimization)

@ --- Helper function: _strlen ---
@ Calculates the length of a null-terminated string.
@ R0: Address of the string.
@ Returns: Length of the string in R0.
_strlen:
    push {r1, lr}           @ Save R1 and Link Register
    mov r1, #0              @ Initialize length counter
_strlen_loop:
    ldrb r2, [r0, r1]       @ Load byte from string + offset
    cmp r2, #0              @ Check if it's the null terminator
    beq _strlen_end         @ If yes, end loop
    add r1, r1, #1          @ Increment length
    b _strlen_loop          @ Continue loop
_strlen_end:
    mov r0, r1              @ Move length to R0 for return
    pop {r1, lr}            @ Restore R1 and Link Register
    bx lr                   @ Return

@ --- Helper function: _read_line ---
@ Reads a line from stdin into a buffer.
@ R0: Address of the buffer.
@ R1: Maximum size of the buffer.
@ Returns: Number of bytes read (excluding newline, if present) in R0.
_read_line:
    push {r4, lr}           @ Save R4 and Link Register
    mov r4, r0              @ Save buffer address to R4
    mov r0, #0              @ File descriptor for stdin
    mov r1, r4              @ Address of buffer
    @ R2 (buffer size) is passed by caller
    mov r7, #3              @ SYS_READ (syscall number for read)
    svc #0                  @ Call kernel
    mov r1, r0              @ R1 now holds bytes read
    cmp r1, #0              @ Check if anything was read
    ble _read_line_end      @ If not, return 0

    @ Null-terminate the string, and remove trailing newline if present
    mov r2, #0              @ R2 = index
_null_terminate_loop:
    cmp r2, r1              @ Check if we reached the end of read bytes
    beq _null_terminate_end @ If yes, break
    ldrb r3, [r4, r2]       @ Load byte
    cmp r3, #10             @ Check for newline (ASCII 10)
    beq _handle_newline     @ If newline, handle it
    add r2, r2, #1          @ Increment index
    b _null_terminate_loop
_handle_newline:
    strb r2, [r4, #0]       @ Store null terminator at the newline position
    mov r0, r2              @ Return length up to newline
    b _read_line_end

_null_terminate_end:
    strb #0, [r4, r1]       @ Null-terminate at the end of read bytes
    mov r0, r1              @ Return total bytes read
_read_line_end:
    pop {r4, lr}            @ Restore R4 and Link Register
    bx lr                   @ Return

@ --- Helper function: _atoi (ASCII to Integer) ---
@ Converts an ASCII string representing a number to an integer.
@ R0: Address of the string.
@ R1: Length of the string (excluding null terminator/newline).
@ Returns: Integer value in R0.
_atoi:
    push {r4, r5, lr}       @ Save R4, R5, and Link Register
    mov r4, r0              @ R4 = string address
    mov r5, #0              @ R5 = result (integer value)
    mov r2, #0              @ R2 = current index

_atoi_loop:
    cmp r2, r1              @ Compare current index with string length
    bge _atoi_end           @ If index >= length, end loop

    ldrb r0, [r4, r2]       @ Load character from string
    sub r0, r0, #'0'        @ Convert ASCII digit to integer value

    @ Check if it's a valid digit (0-9)
    cmp r0, #0
    blt _atoi_invalid       @ If less than 0, invalid
    cmp r0, #9
    bgt _atoi_invalid       @ If greater than 9, invalid

    mul r5, r5, #10         @ result = result * 10
    add r5, r5, r0          @ result = result + digit

    add r2, r2, #1          @ Increment index
    b _atoi_loop            @ Continue loop

_atoi_invalid:
    mov r5, #0              @ Return 0 for invalid input
    b _atoi_end

_atoi_end:
    mov r0, r5              @ Move result to R0 for return
    pop {r4, r5, lr}        @ Restore R4, R5, and Link Register
    bx lr                   @ Return

@ --- Helper function: _print_int ---
@ Converts an integer to a string and prints it, followed by a newline.
@ R0: Integer to print.
_print_int:
    push {r4, r5, r6, r7, lr} @ Save registers
    mov r4, r0              @ R4 = number to convert
    ldr r5, =num_buffer     @ R5 = buffer address
    mov r6, #0              @ R6 = index for buffer (starts from end)

    @ Handle zero case explicitly
    cmp r4, #0
    bne _int_to_ascii_loop
    mov r0, #'0'
    strb r0, [r5, #0]       @ Store '0' in buffer
    mov r6, #1              @ Length is 1
    b _print_int_done

_int_to_ascii_loop:
    cmp r4, #0              @ Check if number is 0
    beq _int_to_ascii_end   @ If yes, end conversion

    mov r0, r4              @ R0 = current number
    mov r1, #10             @ R1 = divisor (10)
    bl _div_by_10           @ Call division helper: R0 = quotient, R1 = remainder

    add r7, r1, #'0'        @ Convert remainder to ASCII digit
    strb r7, [r5, r6]       @ Store digit in buffer (reversed)
    add r6, r6, #1          @ Increment buffer index
    mov r4, r0              @ Update number to quotient
    b _int_to_ascii_loop

_int_to_ascii_end:
    sub r6, r6, #1          @ Adjust index to point to last digit
    mov r7, #0              @ R7 = temp for swapping
    mov r0, #0              @ R0 = left pointer
    mov r1, r6              @ R1 = right pointer

_reverse_loop:
    cmp r0, r1              @ Compare left and right pointers
    bge _reverse_end        @ If left >= right, done reversing

    ldrb r7, [r5, r0]       @ Load char from left
    ldrb r2, [r5, r1]       @ Load char from right

    strb r2, [r5, r0]       @ Swap
    strb r7, [r5, r1]

    add r0, r0, #1          @ Increment left pointer
    sub r1, r1, #1          @ Decrement right pointer
    b _reverse_loop

_reverse_end:
    @ Null-terminate the string
    add r0, r6, #1          @ R0 = length of number string
    strb #0, [r5, r0]       @ Store null terminator

_print_int_done:
    @ Print the number string
    ldr r0, =num_buffer     @ R0 = buffer address
    add r1, r6, #1          @ R1 = length of string (calculated from num_buffer index)
    bl _print_string        @ Call print string helper

    ldr r0, =newline        @ Print a newline after the number
    ldr r1, =len_newline
    bl _print_string

    pop {r4, r5, r6, r7, lr} @ Restore registers
    bx lr                   @ Return

@ --- Helper function: _div_by_10 ---
@ Divides R0 by 10.
@ R0: Dividend.
@ Returns: R0 = quotient, R1 = remainder.
_div_by_10:
    push {r2, r3, lr}       @ Save registers
    mov r1, #0              @ R1 = remainder (initially 0)
    mov r2, #0              @ R2 = quotient (initially 0)
    mov r3, #10             @ R3 = divisor (10)

_div_loop:
    cmp r0, r3              @ Compare dividend with divisor
    blt _div_end            @ If dividend < divisor, end loop

    sub r0, r0, r3          @ Subtract divisor from dividend
    add r2, r2, #1          @ Increment quotient
    b _div_loop

_div_end:
    mov r1, r0              @ Remainder is the final dividend
    mov r0, r2              @ Quotient is the final quotient
    pop {r2, r3, lr}        @ Restore registers
    bx lr                   @ Return
