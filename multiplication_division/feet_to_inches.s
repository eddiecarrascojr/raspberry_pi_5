#
# ARM Assembly Program: Reads in feet and inches,
# then converts it to total inches and prints the result.
# Program Name: feet_to_inches.s
# Author: Eduardo Carrasco Jr
# Date: 06/21/2025
# Purpose: Reads in user for a feet and inches,
# then converts it to total inches, and prints the result.
#
# Inputs: 
#   - Integer of total feet
#   - r0 as integer of feet
#   - Integer of total inches
#   - r1 as integer of inches
# Outputs:
#   - Integer of total inches
#   - r0 as integer of inches
#

.text
.global main

main:
    # Function Prologue: Manually save the Link Register to the stack.
    SUB sp, sp, #4     
    STR lr, [sp, #0]    

    # Prompt for and read the number of feet
    LDR r0, =prompt_feet 
    BL printf            

    LDR r0, =format_string # Load address of format string for scanf
    LDR r1, =input_feet    
    BL scanf             

    # Prompt for and read the number of inches
    LDR r0, =prompt_inches 
    BL printf       

    LDR r0, =format_string  
    LDR r1, =input_inches   
    BL scanf             

    # Load the values from memory into registers
    LDR r1, =input_feet
    LDR r1, [r1]            # r1 = value of input_feet
    LDR r2, =input_inches
    LDR r2, [r2]            # r2 = value of input_inches

    # Perform the multiplication
    MOV r3, #12             # r3 = 12
    # r0 = feet * 12
    MUL r0, r1, r3          

    # Perform r0 = (feet * 12) + inches
    ADD r0, r0, r2          

    # Print the result
    MOV r1, r0              
    LDR r0, =output_string  
    BL printf               

    # Manually restore the Link Register and return.
    LDR lr, [sp, #0]    
    ADD sp, sp, #4      
    MOV pc, lr          

# The .data section remains unchanged as it is perfectly fine.
.data
    # Prompts the users for total feet.
    prompt_feet:    .asciz "Enter the number of feet: "
    # Prompts the users for total inches.
    prompt_inches:  .asciz "Enter the number of inches: "
    # Format string for scanf to read an integer.
    format_string:  .asciz "%d"
    # Output string for displaying the total inches.
    output_string:  .asciz "\nTotal inches: %d\n"
    # Memory locations to store user input in feet.
    input_feet:     .word 0
    # Memory locations to store user input in inches.
    input_inches:   .word 0
