#
# ARM Assembly Program: Celsius to Fahrenheit Converter
# Program Name: celsius_to_fahrenheit.s
# Author: Eduardo Carrasco Jr
# Date: 06/21/2025
# Purpose: Reads in user for a temperature in Celsius,
# then converts it to Fahrenheit, and prints the result.
#
# Inputs: 
#   - Integer of temperature in Celsius
#   - r0 as integer of Celsius temperature
# Outputs:
#   - Integer of temperature in Fahrenheit
#   - r0 as integer of Fahrenheit temperature
#

.text
.global main

main:
    # Save return to OS on Stack
    SUB sp, sp, #4          
    STR lr, [sp, #0]            
    
    # Prompt user for input
    LDR r0, =prompt_msg      
    bl printf   

    # Read user input
    LDR r0, =scanf_format
    BL scanf_format


    # r0 already contains Celsius (C) as the first argument
    MOV r1, #9              # Load the constant 9 into a register. 
    # F = C * 9
    MUL r1, r0, r1          

   
    MOV r2, #5              # Load the constant 5 into a register
     # F = (C * 9) / 5
    SDIV r0, r1, r2         

    # F = ((C * 9) / 5) + 32
    ADD r0, r0, #32     # Load 32 into r0
    # Output the result
    LDR r0, =result_msg  # Load the address of the result message
    BL printf              # Call printf to output the result
    
    LDR pc, [sp], #4       

.data
# Tells user to enter a temperature in Celsius
prompt_msg:
    .asciz "Enter a temperature in Celsius: "
# Take user input in Celsius
scanf_format:
    .asciz "%d"  # Format string for scanf to read a decimal integer
# Output the result in Fahrenheit
result_msg:
    .asciz "%d degrees Celsius is %d degrees Fahrenheit.\n"
