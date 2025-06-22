#
# ARM AssemBLy Program: Reads in inches,
# then converts it to total inches and total feet. Thenprints the result.
# Program Name: inches_to_feet.s
# Author: Eduardo Carrasco Jr
# Date: 06/21/2025
# Purpose: Reads in user for a feet and inches,
# then converts it to total inches, and prints the result.
#
# Inputs: 
#   - Integer of total inches
#   - r0 as integer of inches

# Outputs:
#   - Integer of total feet
#   - r0 as integer of feet
#   - Integer of total inches
#   - r1 as integer of inches
#

.text
.global main

main:

    # Allocate the stack for the frame pointer and link register.
    SUB     sp, sp, #4
    STR     fp, [sp, #0]
    STR     lr, [sp, #4]
    MOV     fp, sp

    # Prompt for input
    LDR r0, =prompt_message
    BL printf

    # Load the address of the scanf format STRing into r0
    LDR r0, =scanf_format
    LDR r1, =input_inches
    BL scanf


    # Load the address of our input variaBLe
    LDR r1, =input_inches
    # r4 now holds the total inches
    LDR r4, [r1] 

    # We need to calculate feet = total_inches / 12
    MOV r0, r4     
    MOV r1, #12      
    # The __aeabi_idiv function performs integer division
    # It returns the result in r0 (r0 = r0 / r1)
    BL __aeabi_idiv
    MOV r5, r0       # r5 now holds the calculated feet

   
    # Calculate inches = total_inches - (feet * 12)
    MOV r0, r5
    # MOVe feet (r5) into r0 for multiplication      
    MOV r1, #12  
    # r2 = r5 * 12 (feet * 12)    
    mul r2, r0, r1   

    # r6 = r4 - r2 (total_inches - (feet * 12))
    SUB r6, r4, r2   

    # Print the result
    LDR r0, =output_format
    MOV r1, r4
    MOV r2, r5
    MOV r3, r6
    BL printf


    # Set exit code to 0 (successful execution)
    MOV     r0, #0
    # Restore the old frame pointer from the stack.
    LDR     fp, [sp, #0]
    # Restore the link register from the stack.
    LDR     lr, [sp, #4]
    # Deallocate the 8 bytes from the stack.
    add     sp, sp, #8
    # Return to the calling function by MOVing lr to the program counter.
    MOV     pc, lr

.data
    # STRing for the input prompt
    prompt_message: .asciz "Enter total inches: "
    # STRing format for scanf to read a decimal integer
    scanf_format: .asciz "%d"
    # STRing format for the final output using printf
    # %d inches is %d feet and %d inches.
    output_format: .asciz "%d inches is %d feet and %d inches.\n"
    # VariaBLe to store the integer read from scanf
    input_inches: .word 0