#
# ARM Assembly Program: Convert Feet and Inches to Total Inches
# Program Name: feet_to_inches.s
# Author: Eduardo Carrasco Jr
# Date: 06/21/2025
#
# Inputs: 
#   - Integer of feet
#   - r4 as integer of feet
#   - Integer of inches
#   - r2 as integer of inches
# Outputs:
#   - Integer of total inches
#   - r0 as integer of total inches
#
.text
.global main

main:
    # Function Prologue: Save lr and r4 to the stack.
    SUB sp, sp, #8      
    STR lr, [sp, #4]   
    STR r4, [sp, #0]    

    # Prompt for the number of feet
    LDR r0, =prompt_feet
    BL printf

    # Read the number of feet from the user
    SUB sp, sp, #4          
    MOV r1, sp              
    LDR r0, =format_string
    BL scanf
    LDR r4, [sp]            
    ADD sp, sp, #4          

    # Prompt for the number of inches
    LDR r0, =prompt_inches
    BL printf               

    # Read the number of inches from the user
    SUB sp, sp, #4          
    MOV r1, sp              
    LDR r0, =format_string
    BL scanf
    LDR r2, [sp]            
    ADD sp, sp, #4          

    # Calculation: r0 = (feet * 12) + inches
    MOV r3, #12             
    MUL r1, r4, r3          # r1 = feet * 12
    ADD r0, r1, r2          # r0 = (feet * 12) + inches

    # Print the final result
    MOV r1, r0              # Move the final result into r1 (the 2nd argument for printf)
    LDR r0, =output_string  # Load the format string into r0 (the 1st argument for printf)
    BL printf               

    # Function Epilogue: Restore registers and return from main.
    LDR r4, [sp, #0]    
    LDR lr, [sp, #4]    
    ADD sp, sp, #8      
    MOV pc, lr          
    
.data
    prompt_feet:    .asciz "Enter the number of feet: "
    prompt_inches:  .asciz "Enter the number of inches: "
    format_string:  .asciz "%d"
    output_string:  .asciz "\nTotal inches: %d\n"
