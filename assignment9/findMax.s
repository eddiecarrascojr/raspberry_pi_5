# =============================================================================
# Program:      Max of 3 Integers
# Author:       Gemini
# Description:  A 32-bit ARM assembly program that prompts for three integer
#               values, finds the largest of the three using a dedicated
#               function, and prints the result.
# =============================================================================

.global main

# =============================================================================
# Data Section
# Defines constants and strings used in the program.
# =============================================================================
.data
prompt1:      .asciz "Enter the first integer: "
prompt2:      .asciz "Enter the second integer: "
prompt3:      .asciz "Enter the third integer: "
format_str:   .asciz "%d"
result_msg:   .asciz "The largest value is: %d\n"

# Since we need to store the input from scanf, we need space for them.
# We'll align to a 4-byte boundary for word-sized data.
.align 4
input_val1:   .word 0
input_val2:   .word 0
input_val3:   .word 0


# =============================================================================
# Text Section
# Contains the executable code.
# =============================================================================
.text
.align 2

# -----------------------------------------------------------------------------
# findMaxOf3(int val1, int val2, int val3)
# Description:  Compares three integer values and returns the largest.
# Arguments:
#   r0: The first integer (val1)
#   r1: The second integer (val2)
#   r2: The third integer (val3)
# Returns:
#   r0: The largest of the three integers.
# -----------------------------------------------------------------------------
findMaxOf3:
    push {lr}           # Push Link Register to the stack to preserve it

    # Compare the first two values (val1 and val2 in r0 and r1)
    cmp r0, r1          # Compare r0 with r1
    bge val1_is_ge      # If r0 >= r1, branch to val1_is_ge

    # If we are here, it means val2 > val1 (r1 > r0)
    # Now we need to compare val2 and val3 (r1 and r2)
    cmp r1, r2          # Compare r1 with r2
    bge val2_is_max     # If r1 >= r2, then r1 is the max
    
    # If we are here, it means val3 > val2 > val1 (r2 > r1 > r0)
    mov r0, r2          # So, move r2 (val3) into r0 as the return value
    b findMax_exit      # Jump to the exit

val1_is_ge:
    # If we are here, it means val1 >= val2 (r0 >= r1)
    # Now we need to compare val1 and val3 (r0 and r2)
    cmp r0, r2          # Compare r0 with r2
    bge findMax_exit    # If r0 >= r2, r0 is already the max, so we can exit
    
    # If we are here, it means val3 > val1 >= val2 (r2 > r0 >= r1)
    mov r0, r2          # So, move r2 (val3) into r0 as the return value
    b findMax_exit      # Jump to the exit

val2_is_max:
    # If we are here, it means val2 > val1 AND val2 >= val3
    mov r0, r1          # So, move r1 (val2) into r0 as the return value

findMax_exit:
    pop {pc}            # Pop the return address from the stack into the PC


# -----------------------------------------------------------------------------
# main
# Description:  The main entry point of the program.
# -----------------------------------------------------------------------------
main:
    push {ip, lr}       # Push IP and Link Register to the stack

    # Prompt for and read the first value
    ldr r0, =prompt1    # Load address of the first prompt message
    bl printf           # Call printf to display it
    ldr r0, =format_str # Load address of the format string for scanf
    ldr r1, =input_val1 # Load address where the first input will be stored
    bl scanf            # Call scanf to read the integer

    # Prompt for and read the second value
    ldr r0, =prompt2    # Load address of the second prompt message
    bl printf           # Call printf
    ldr r0, =format_str # Load address of the format string for scanf
    ldr r1, =input_val2 # Load address for the second input
    bl scanf            # Call scanf

    # Prompt for and read the third value
    ldr r0, =prompt3    # Load address of the third prompt message
    bl printf           # Call printf
    ldr r0, =format_str # Load address of the format string for scanf
    ldr r1, =input_val3 # Load address for the third input
    bl scanf            # Call scanf

    # Prepare arguments for the findMaxOf3 function call
    ldr r0, =input_val1 # Load address of the first value
    ldr r0, [r0]        # Dereference to get the actual value into r0
    ldr r1, =input_val2 # Load address of the second value
    ldr r1, [r1]        # Dereference to get the actual value into r1
    ldr r2, =input_val3 # Load address of the third value
    ldr r2, [r2]        # Dereference to get the actual value into r2

    # Call the function to find the maximum
    bl findMaxOf3       # Branch and Link to the function
                        # The result will be in r0 upon return

    # Prepare arguments to print the result
    mov r1, r0          # Move the result from findMaxOf3 (in r0) to r1 for printf
    ldr r0, =result_msg # Load the address of the result message string into r0
    bl printf           # Call printf to display the final result

    # Exit the program
    mov r0, #0          # Return 0 to the OS
    pop {ip, pc}        # Pop IP and PC to return from main
