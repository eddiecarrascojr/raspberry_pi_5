# -----------------------------------------------------------------------------
# isAlpha.s
# A program to check if a user-input character is alphabetic.
# The check is implemented using a logical operation.
# Author: Eduardo Carrasco Jr\
# Date: 07/18/2025
# Purpose: Reads in user input for a character,
# checks if it is an alphabetic character (A-Z or a-z),
# and prints the result to the console.
# 
# Parameters:
#   R0: The character to be checked.
# Returns:
#   R0: 1 if the character is alphabetic, 0 otherwise.
#   Prints out the results to the console.
#
# Compile and run instructions:
#   Assemble with: as -o isAlpha.o isAlpha.s
#   Link with: gcc -o isAlpha isAlpha.o
#   Run with: ./isAlpha

#
# -----------------------------------------------------------------------------

.global main

main:
    # Print prompt message
    #  R0 := file descriptor (1 for stdout)
    #  R1 := address of the message
    #  R2 := length of the message
    #  R7 := syscall number (4 for SYS_WRITE)
    MOV R0, #1
    LDR R1, =prompt_msg
    MOV R2, #prompt_len
    MOV R7, #4
    SWI #0 

    # Read the character from user input
    MOV R0, #0
    LDR R1, =input_buffer
    MOV R2, #1
    MOV R7, #3
    SWI #0

    #  Load the character read from the buffer into R0 for the function call
    LDR R1, =input_buffer
    LDRB R0, [R1]

    # Call the is_alpha function
    #  R0 contains the character to check
    BL is_alpha

    # Check if the return value from is_alpha 
    CMP R0, #1
    BEQ .print_is_alpha

# Print for "NOT alphabetic"
.print_not_alpha:
    #  Print the input character itself
    MOV R0, #1
    LDR R1, =input_buffer
    MOV R2, #1
    MOV R7, #4
    SWI #0

    #  Print " is NOT an alphabetic character." message
    MOV R0, #1
    LDR R1, =not_alpha_msg
    MOV R2, #not_alpha_len
    MOV R7, #4
    SWI #0
    B .exit

# Print if character is alphabetic
.print_is_alpha:
    #  Print the input character itself
    MOV R0, #1
    LDR R1, =input_buffer
    MOV R2, #1
    MOV R7, #4
    SWI #0

    #  Print " is an alphabetic character." message
    MOV R0, #1
    LDR R1, =is_alpha_msg
    MOV R2, #is_alpha_len
    MOV R7, #4
    SWI #0

.exit:
    # Exit and clean up
    MOV R0, #0
    MOV R7, #1
    SWI #0

# Function: is_alpha
#  This function checks if a given character is an alphabetic character (A-Z or a-z).
#  It uses conditional moves to set boolean flags (0 or 1) for uppercase and lowercase checks,
#  then combines these flags using a bitwise OR (ORR) instruction, which acts as a logical OR.
# Version 1 
# Uses logical operations to determine if the character is alphabetic.
# 
#  Parameters:
#    R0: The character to be checked.
# 
#  Returns:
#    R0: 1 if the character is alphabetic, 0 otherwise.
# 
is_alpha:
    # Check for uppercase characters (A-Z)
    CMP R0, #'A'
    MOVLT R1, #0 @ Move if Less Than
    MOVGE R1, #1 @ Move if Greater than or Equal

    #  Compare R0 with 'Z' (ASCII 90).
    #  If R0 is greater than 'Z', set R1 to 0 (not uppercase, overrides previous 1 if R0 was > 'Z').
    #  At this point, R1 will be 1 only if 'A' <= R0 <= 'Z', otherwise it will be 0.
    CMP R0, #'Z'
    MOVGT R1, #0 @ Move if Greater Than

    #  --- Check for lowercase characters (a-z) ---
    #  Compare R0 with 'a' (ASCII 97).
    #  If R0 is less than 'a', set R2 to 0 (not lowercase).
    #  Otherwise (R0 >= 'a'), set R2 to 1 (potentially lowercase).
    CMP R0, #'a'
    MOVLT R2, #0
    MOVGE R2, #1

    #  Compare R0 with 'z' (ASCII 122).
    #  If R0 is greater than 'z', set R2 to 0 (not lowercase, overrides previous 1 if R0 was > 'z').
    #  At this point, R2 will be 1 only if 'a' <= R0 <= 'z', otherwise it will be 0.
    CMP R0, #'z'
    MOVGT R2, #0

    #  Logical OR operation
    #  Perform a bitwise OR operation on R1 and R2.
    #  Since R1 and R2 are either 0 or 1, this acts as a boolean logical OR:
    #    - If R1 is 1 (uppercase) OR R2 is 1 (lowercase), R0 will become 1.
    #    - If both R1 and R2 are 0 (neither uppercase nor lowercase), R0 will remain 0.
    ORR R0, R1, R2

    #  Return from the function.
    BX LR

.data
    #  Data section for messages and input buffer
    prompt_msg:     .asciz "Enter a character: "
    prompt_len = . - prompt_msg

    is_alpha_msg:   .asciz " is an alphabetic character.\n"
    is_alpha_len = . - is_alpha_msg

    not_alpha_msg:  .asciz " is NOT an alphabetic character.\n"
    not_alpha_len = . - not_alpha_msg

    input_buffer:   .space 2
.text

#  End of the isAlpha.s