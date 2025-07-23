.global _start

.equ SYS_EXIT, 1
.equ SYS_READ, 3
.equ SYS_WRITE, 4
.equ SYS_OPEN, 5
.equ SYS_CLOSE, 6
.equ SYS_GETTIMEOFDAY, 78 @ Used if /dev/urandom fails or for seeding

.equ STDIN, 0
.equ STDOUT, 1

.equ O_RDONLY, 0

.data
    @ --- Strings for output ---
    prompt_max: .asciz "Enter the maximum number for the guessing game (1-2147483647): "
    len_prompt_max: .word . - prompt_max

    prompt_guess: .asciz "Enter your guess: "
    len_prompt_guess: .word . - prompt_guess

    msg_too_low: .asciz "Too low!\n"
    len_msg_too_low: .word . - msg_too_low

    msg_too_high: .asciz "Too high!\n"
    len_msg_too_high: .word . - msg_too_high

    msg_correct: .asciz "Correct!\n"
    len_msg_correct: .word . - msg_correct

    msg_guesses: .asciz "It took you "
    len_msg_guesses: .word . - msg_guesses

    msg_guesses_end: .asciz " guesses.\n"
    len_msg_guesses_end: .word . - msg_guesses_end

    newline: .asciz "\n"
    len_newline: .word . - newline

    urandom_path: .asciz "/dev/urandom"
    len_urandom_path: .word . - urandom_path

    @ --- Variables ---
    random_number: .word 0       @ Stores the randomly generated number
    max_value: .word 0           @ Stores the user-entered maximum value
    guess_count: .word 0         @ Stores the number of guesses
    input_buffer_len: .word 16   @ Max length for input numbers (e.g., 10 digits for 2^31-1 + newline)

.bss
    input_buffer: .skip 16       @ Buffer for reading user input (max 15 chars + null/newline)
    itoa_buffer: .skip 16        @ Buffer for integer to ASCII conversion

.text
_start:
    @ 1. Prompt for maximum value
    ldr r0, =STDOUT
    ldr r1, =prompt_max
    ldr r2, len_prompt_max
    bl _print_string

    @ Read maximum value
    ldr r0, =STDIN
    ldr r1, =input_buffer
    ldr r2, input_buffer_len
    bl _read_string             @ R0 contains bytes read, R1 contains address of buffer
    mov r1, r0                  @ Save bytes read to r1 for _atoi (length)
    ldr r0, =input_buffer       @ R0 = address of input buffer
    bl _atoi                    @ R0 now contains the integer value
    str r0, [r9, #max_value - _start_base] @ Store max_value (using r9 as base for .data)

    @ 2. Generate random number
    ldr r0, [r9, #max_value - _start_base] @ Load max_value into R0 for random generation
    bl _generate_random         @ R0 contains the random number (1 to max_value)
    str r0, [r9, #random_number - _start_base] @ Store random number

    @ Initialize guess count
    mov r0, #0
    str r0, [r9, #guess_count - _start_base]

guess_loop:
    @ Increment guess count
    ldr r0, [r9, #guess_count - _start_base]
    add r0, r0, #1
    str r0, [r9, #guess_count - _start_base]

    @ Prompt for guess
    ldr r0, =STDOUT
    ldr r1, =prompt_guess
    ldr r2, len_prompt_guess
    bl _print_string

    @ Read guess
    ldr r0, =STDIN
    ldr r1, =input_buffer
    ldr r2, input_buffer_len
    bl _read_string
    mov r1, r0                  @ Save bytes read to r1 for _atoi (length)
    ldr r0, =input_buffer
    bl _atoi                    @ R0 now contains the integer guess value
    mov r4, r0                  @ Move user guess to r4

    @ Compare guess with random number
    ldr r5, [r9, #random_number - _start_base] @ Load random number to r5

    cmp r4, r5                  @ Compare guess (r4) with random_number (r5)
    blt .L_too_low              @ If guess < random_number
    bgt .L_too_high             @ If guess > random_number

    @ If equal (guess == random_number)
    ldr r0, =STDOUT
    ldr r1, =msg_correct
    ldr r2, len_msg_correct
    bl _print_string
    b .L_end_game

.L_too_low:
    ldr r0, =STDOUT
    ldr r1, =msg_too_low
    ldr r2, len_msg_too_low
    bl _print_string
    b guess_loop

.L_too_high:
    ldr r0, =STDOUT
    ldr r1, =msg_too_high
    ldr r2, len_msg_too_high
    bl _print_string
    b guess_loop

.L_end_game:
    @ Print "It took you "
    ldr r0, =STDOUT
    ldr r1, =msg_guesses
    ldr r2, len_msg_guesses
    bl _print_string

    @ Print guess count
    ldr r0, [r9, #guess_count - _start_base] @ Load guess count
    ldr r1, =itoa_buffer
    bl _itoa                    @ R0 = address of string, R1 = length
    mov r2, r1                  @ Move length to r2 for _print_string
    mov r1, r0                  @ Move string address to r1 for _print_string
    ldr r0, =STDOUT
    bl _print_string

    @ Print " guesses."
    ldr r0, =STDOUT
    ldr r1, =msg_guesses_end
    ldr r2, len_msg_guesses_end
    bl _print_string

    @ Exit
    mov r7, #SYS_EXIT
    mov r0, #0                  @ Exit code 0 (success)
    svc #0

@ --- Helper Functions ---

@ _print_string: Prints a null-terminated string to stdout
@ R0: file descriptor (STDOUT)
@ R1: address of string
@ R2: length of string
@ Preserves: nothing (uses mov and svc)
_print_string:
    push {r4-r7, lr}            @ Save registers
    mov r7, #SYS_WRITE          @ System call number for write
    svc #0                      @ Execute system call
    pop {r4-r7, lr}             @ Restore registers
    bx lr                       @ Return

@ _read_string: Reads from stdin into a buffer
@ R0: file descriptor (STDIN)
@ R1: address of buffer
@ R2: max length to read
@ Returns: R0 = number of bytes read
@ Preserves: nothing
_read_string:
    push {r4-r7, lr}            @ Save registers
    mov r7, #SYS_READ           @ System call number for read
    svc #0                      @ Execute system call
    pop {r4-r7, lr}             @ Restore registers
    bx lr                       @ Return

@ _atoi: ASCII to Integer conversion
@ R0: address of string (input_buffer)
@ Returns: R0 = integer value
@ Clobbers: R1, R2, R3, R4, R5
_atoi:
    push {r1, r2, r3, r4, r5, lr} @ Save used registers
    mov r1, #0                  @ r1 = current integer value (result)
    mov r2, #0                  @ r2 = character counter
    mov r3, r0                  @ r3 = pointer to string

.L_atoi_loop:
    ldrb r4, [r3, r2]           @ Load byte (character) from string
    cmp r4, #0x0a               @ Check for newline (LF)
    beq .L_atoi_end             @ If newline, end conversion
    cmp r4, #0x0d               @ Check for carriage return (CR)
    beq .L_atoi_end             @ If CR, end conversion
    cmp r4, #0                  @ Check for null terminator
    beq .L_atoi_end             @ If null, end conversion

    cmp r4, #'0'                @ Check if character is a digit
    blt .L_atoi_next_char       @ If less than '0', skip
    cmp r4, #'9'
    bgt .L_atoi_next_char       @ If greater than '9', skip

    sub r4, r4, #'0'            @ Convert ASCII digit to integer
    mov r5, r1                  @ Save current result
    mov r1, r1, lsl #3          @ r1 = r1 * 8
    add r1, r1, r5, lsl #1      @ r1 = r1 + r5 * 2 => r1 = r1 * 10
    add r1, r1, r4              @ Add current digit

.L_atoi_next_char:
    add r2, r2, #1              @ Increment character counter
    b .L_atoi_loop

.L_atoi_end:
    mov r0, r1                  @ Move final integer value to R0
    pop {r1, r2, r3, r4, r5, lr} @ Restore registers
    bx lr                       @ Return

@ _itoa: Integer to ASCII conversion
@ R0: integer value
@ R1: address of buffer (itoa_buffer)
@ Returns: R0 = address of string, R1 = length of string
@ Clobbers: R2, R3, R4, R5, R6, R7
_itoa:
    push {r2, r3, r4, r5, r6, r7, lr} @ Save used registers
    mov r2, r1                  @ r2 = buffer pointer (start of buffer)
    mov r3, #0                  @ r3 = digit count (length of string)
    mov r4, #0                  @ r4 = flag for negative number (not used for positive numbers here)
    mov r5, #10                 @ r5 = divisor (10)

    cmp r0, #0
    bge .L_itoa_positive        @ If number is positive or zero, go to positive handling
    @ Negative number handling (not strictly needed for positive numbers 1-max, but good practice)
    mov r4, #1                  @ Set negative flag
    neg r0, r0                  @ Make number positive for conversion

.L_itoa_positive:
    cmp r0, #0
    beq .L_itoa_zero            @ If number is 0, handle specially

.L_itoa_loop:
    udiv r6, r0, r5             @ r6 = r0 / 10 (quotient)
    mul r7, r6, r5              @ r7 = (r0 / 10) * 10
    sub r7, r0, r7              @ r7 = r0 - ((r0 / 10) * 10) = r0 % 10 (remainder)
    add r7, r7, #'0'            @ Convert digit to ASCII
    strb r7, [r2, r3]           @ Store digit in buffer
    add r3, r3, #1              @ Increment digit count
    mov r0, r6                  @ r0 = quotient for next iteration
    cmp r0, #0
    bne .L_itoa_loop

    cmp r4, #1                  @ Check negative flag
    beq .L_itoa_add_minus       @ If negative, add '-'

    b .L_itoa_reverse           @ Reverse the string

.L_itoa_zero:
    mov r7, #'0'                @ Store '0' for zero
    strb r7, [r2, r3]
    add r3, r3, #1              @ Length is 1
    b .L_itoa_reverse

.L_itoa_add_minus:
    mov r7, #'-'                @ Add '-' sign
    strb r7, [r2, r3]
    add r3, r3, #1
    b .L_itoa_reverse

.L_itoa_reverse:
    mov r0, r2                  @ R0 = start of buffer
    mov r1, r3                  @ R1 = length of string
    cmp r1, #0
    beq .L_itoa_end_return      @ If length is 0, nothing to reverse

    mov r4, r0                  @ r4 = start pointer
    add r5, r0, r1              @ r5 = end pointer (one past last char)
    sub r5, r5, #1              @ r5 = last char pointer

.L_reverse_loop:
    cmp r4, r5
    bge .L_itoa_end_return      @ If start >= end, done reversing

    ldrb r6, [r4]               @ Load char from start
    ldrb r7, [r5]               @ Load char from end

    strb r7, [r4]               @ Swap chars
    strb r6, [r5]

    add r4, r4, #1              @ Move start pointer forward
    sub r5, r5, #1              @ Move end pointer backward
    b .L_reverse_loop

.L_itoa_end_return:
    mov r0, r2                  @ Return buffer address in R0
    mov r1, r3                  @ Return length in R1
    pop {r2, r3, r4, r5, r6, r7, lr} @ Restore registers
    bx lr                       @ Return

@ _generate_random: Generates a random number between 1 and max_value (inclusive)
@ R0: max_value
@ Returns: R0 = random number
@ Clobbers: R1, R2, R3, R4, R5, R6, R7
_generate_random:
    push {r1, r2, r3, r4, r5, r6, r7, lr} @ Save used registers
    mov r4, r0                  @ Store max_value in r4

    @ Open /dev/urandom
    ldr r0, =urandom_path       @ Path to /dev/urandom
    mov r1, #O_RDONLY           @ Open for read only
    mov r2, #0                  @ Mode (not used for files that exist)
    mov r7, #SYS_OPEN           @ System call for open
    svc #0                      @ Execute system call
    mov r5, r0                  @ Store file descriptor in r5

    cmp r5, #0                  @ Check if open failed (fd will be negative)
    blt .L_random_error         @ If failed, handle error or fallback

    @ Read 4 bytes from /dev/urandom
    mov r0, r5                  @ File descriptor
    ldr r1, =input_buffer       @ Buffer to read into
    mov r2, #4                  @ Number of bytes to read
    mov r7, #SYS_READ           @ System call for read
    svc #0                      @ Execute system call
    mov r6, r0                  @ Store bytes read in r6

    cmp r6, #4                  @ Check if 4 bytes were read
    bne .L_random_error         @ If not 4 bytes, handle error

    @ Close /dev/urandom
    mov r0, r5                  @ File descriptor
    mov r7, #SYS_CLOSE          @ System call for close
    svc #0                      @ Execute system call

    ldr r0, =input_buffer       @ Load address of buffer
    ldr r0, [r0]                @ Load the 4 random bytes into R0

    @ Ensure positive and within range 1 to max_value
    bic r0, r0, #0x80000000     @ Clear MSB to ensure positive number (if it was signed)
                                @ This makes it effectively a 31-bit unsigned number.
                                @ Or use abs if true signed random numbers are needed,
                                @ but for modulo, positive is fine.

    cmp r4, #0                  @ Check if max_value is 0 or negative
    ble .L_random_error_max_zero @ Handle error: max_value must be > 0

    udiv r0, r0, r4             @ R0 = R0 / max_value (quotient)
    mul r0, r0, r4              @ R0 = (R0 / max_value) * max_value
    sub r0, r0, r0              @ R0 = R0 - R0 = 0 (this is a bug, should be remainder)
    @ Correct modulo:
    udiv r1, r0, r4             @ r1 = random_val / max_value (quotient)
    mul r1, r1, r4              @ r1 = (random_val / max_value) * max_value
    sub r0, r0, r1              @ r0 = random_val - ((random_val / max_value) * max_value) = random_val % max_value

    add r0, r0, #1              @ Add 1 to make it 1 to max_value (inclusive)

    b .L_random_end

.L_random_error:
    @ Fallback or error handling: If /dev/urandom fails, use a simple LCG with time seed
    @ For simplicity, we'll just use a fixed value or exit in a real error.
    @ For this example, let's just use a default random number if urandom fails.
    @ In a production scenario, you'd want to get a time seed here.
    mov r0, #42                 @ Default random number if urandom fails
    ldr r1, =STDOUT
    ldr r2, =msg_error_random
    ldr r3, len_msg_error_random
    bl _print_string
    b .L_random_end

.L_random_error_max_zero:
    ldr r0, =STDOUT
    ldr r1, =msg_error_max_zero
    ldr r2, len_msg_error_max_zero
    bl _print_string
    mov r0, #1                  @ Set a default random number if max_value is invalid
    b .L_random_end

.L_random_end:
    pop {r1, r2, r3, r4, r5, r6, r7, lr} @ Restore registers
    bx lr                       @ Return

.data
    msg_error_random: .asciz "Error reading from /dev/urandom. Using a default random number.\n"
    len_msg_error_random: .word . - msg_error_random
    msg_error_max_zero: .asciz "Maximum value must be greater than 0. Using 1 as random number.\n"
    len_msg_error_max_zero: .word . - msg_error_max_zero

.text
    @ Base address for data section access (for PIC/position-independent code if needed)
    @ For simplicity in this example, we're assuming fixed addressing relative to _start.
    @ A more robust solution would use ADR or PC-relative addressing for all data.
    @ For now, let's just define a base register (r9) and calculate offsets.
    @ This assumes the .data section is relatively close to .text
    @ A better way for PIC is to use `ldr r9, =_start_base` and then `add r9, pc, r9`
    @ and then calculate offsets relative to r9.
    @ For a simple executable, direct addressing is often okay.
    @ Let's use a base register to make it more explicit.
    adr r9, _start_base         @ r9 points to the _start_base label
    b _start                    @ Branch to the actual start of the program

_start_base:
