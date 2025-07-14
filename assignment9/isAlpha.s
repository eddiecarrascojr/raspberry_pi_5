# -----------------------------------------------------------------------------
# is_alpha.s
# A program to check if a user-input character is alphabetic.
# The check is implemented using a logical operation.
# To assemble and link on a Raspberry Pi (or similar ARM system):
# as -o is_alpha.o is_alpha.s
# gcc -o is_alpha is_alpha.o
# ./is_alpha
# -----------------------------------------------------------------------------

.data
# Data section for strings used by printf and scanf
prompt_msg:     .asciz "Enter a character: "
format_char:    .asciz " %c" # Note the space to consume leading whitespace
result_alpha:   .asciz "'%c' is an alphabetic character.\n"
result_not_alpha: .asciz "'%c' is NOT an alphabetic character.\n"

.bss
# Uninitialized data section to store the user's input character
.align 4
input_char:     .byte 0

.text
.global main

# -----------------------------------------------------------------------------
# is_alpha function
# Checks if a character is in the range 'a'-'z' or 'A'-'Z'.
# Input: R0 - The character to check.
# Output: R0 - 1 if the character is alphabetic, 0 otherwise.
# Clobbers: R1
# -----------------------------------------------------------------------------
is_alpha:
    STMFD SP!, {LR}         # Push Link Register to the stack

    # The core idea is to unify the case of the character to uppercase
    # and then perform a single range check.
    # 'a' (0x61) differs from 'A' (0x41) by bit 5 (0x20).
    # 'z' (0x7A) differs from 'Z' (0x5A) by bit 5 (0x20).
    # The BIC (Bit Clear) instruction is a logical operation that can
    # clear this bit, effectively converting any lowercase letter to its
    # uppercase equivalent, while leaving uppercase letters and other
    # characters unchanged.

    BIC   R1, R0, #0x20     # Logical operation: Force character to uppercase.
                            # R1 now holds an uppercase version of the char in R0.

    # Now, we only need to check if R1 is in the range 'A' to 'Z'.
    # We can do this efficiently by subtracting 'A' and checking if the
    # result is between 0 and ('Z' - 'A').

    SUB   R1, R1, #'A'      # R1 = R1 - 'A'. If R0 was 'A', R1 is now 0.
    CMP   R1, #'Z' - 'A'    # Compare with the size of the alphabet (25).

    # Use conditional execution based on the result of the CMP.
    # MOVLS will execute only if the condition is LS (Lower or Same),
    # meaning R1 was between 0 and 25 inclusive.
    # MOVHI will execute only if the condition is HI (Higher),
    # meaning R1 was greater than 25.
    MOVLS R0, #1            # If LS, it's a letter. Set result R0 to 1.
    MOVHI R0, #0            # If HI, it's not a letter. Set result R0 to 0.

    LDMFD SP!, {PC}         # Pop program counter from stack to return (and restore LR)


# -----------------------------------------------------------------------------
# main function
# The main entry point of the program.
# -----------------------------------------------------------------------------
main:
    STMFD SP!, {LR}         # Push Link Register to the stack

    # Prompt the user for input
    LDR   R0, =prompt_msg   # R0 = address of the prompt message
    BL    printf            # Call printf to display the prompt

    # Read a single character from the user
    LDR   R0, =format_char  # R0 = address of the format string "%c"
    LDR   R1, =input_char   # R1 = address of where to store the character
    BL    scanf             # Call scanf to read the input

    # Prepare to call our is_alpha function
    LDRB  R0, [R1]          # Load the byte (character) from memory into R0
    MOV   R2, R0            # Save a copy of the original character in R2 for the final message
    BL    is_alpha          # Call our function. Result will be in R0.

    # Check the result from the is_alpha function
    CMP   R0, #1            # Compare the result with 1
    MOVEQ R0, #1            # If it was 1, keep it 1 (for the branch check)
    MOVNE R0, #0            # If it was not 1, set to 0

    # Branch to the appropriate print statement
    CMP   R0, #1            # Compare again to set flags for branching
    BEQ   print_alpha       # If result is 1, branch to print the "is alpha" message

print_not_alpha:
    # Print the "not alphabetic" message
    LDR   R0, =result_not_alpha # R0 = address of the "not alpha" string
    MOV   R1, R2            # R1 = the original character we saved
    BL    printf            # Call printf
    B     exit              # Branch to the exit

print_alpha:
    # Print the "is alphabetic" message
    LDR   R0, =result_alpha   # R0 = address of the "is alpha" string
    MOV   R1, R2            # R1 = the original character we saved
    BL    printf            # Call printf

exit:
    MOV   R0, #0              # Return 0 from main
    LDMFD SP!, {PC}         # Pop program counter from stack to return

# External functions from the C library
.global printf
.global scanf
