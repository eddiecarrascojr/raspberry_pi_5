.data
@ Define the strings that will be used by scanf and printf.
@ The 'asciz' directive creates null-terminated strings.
format_string:  .asciz "%d"  @ Format for scanf to read a decimal integer
prompt_string:  .asciz "Enter an integer: " @ Prompt message for the user
result_string:  .asciz "You entered: %d. The negative value is: %d\n" @ Result output

.text
.global main @ Make the main function visible to the linker (gcc)

@ -----------------------------------------------------------------------------
@ main: The main entry point of the program
@ -----------------------------------------------------------------------------
main:
    @ Manually save the link register and allocate stack space.
    @ We need 4 bytes for the integer and 4 bytes to save the link register.
    @ We allocate 8 bytes to keep the stack 8-byte aligned per AAPCS.
    sub     sp, sp, #8      @ Allocate 8 bytes on the stack.
    str     lr, [sp, #4]    @ Save the link register (lr) on the stack at a 4-byte offset.
                            @ This is necessary because calls to printf/scanf will overwrite lr.

    @ --- Prompt the user and read the integer using scanf ---

    ldr     r0, =prompt_string @ Load the address of the prompt string into r0
    bl      printf          @ Call printf to display the prompt

    ldr     r0, =format_string @ Load the address of the format string ("%d") into r0
    mov     r1, sp          @ Pass the stack pointer as the address for scanf to store the integer.
                            @ The integer will be stored at [sp, #0].
    bl      scanf           @ Call scanf to read the integer from the user.

    @ --- Load the number and perform two's complement negation ---

    ldr     r2, [sp, #0]    @ Load the integer value from the stack [sp] into r2.
                            @ r2 now holds the number the user entered.

    @ Perform Two's Complement:
    @ 1. One's Complement (flip all the bits)
    mvn     r3, r2          @ r3 = ~r2. MVN (Move Not) performs a bitwise NOT.
                            @ This is the one's complement.

    @ 2. Add 1
    add     r3, r3, #1      @ r3 = r3 + 1. This completes the two's complement operation.
                            @ r3 now holds the negative value of the number in r2.

    @ --- Print the original and negated numbers ---

    ldr     r0, =result_string @ Load the address of our result format string into r0
    mov     r1, r2          @ Move the original number (from r2) into r1 (2nd arg for printf)
    mov     r2, r3          @ Move the negated number (from r3) into r2 (3rd arg for printf)
    bl      printf          @ Call printf to display the final result

    @ --- Clean up and exit ---

    mov     r0, #0          @ Set the return code to 0 (success)
    ldr     lr, [sp, #4]    @ Restore the saved link register from the stack.
    add     sp, sp, #8      @ Deallocate the 8 bytes of stack space.
    mov     pc, lr          @ Return from main by moving the restored address into the program counter.
