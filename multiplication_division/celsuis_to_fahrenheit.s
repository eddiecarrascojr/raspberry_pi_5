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
    @ Save return to OS on Stack
    SUB sp, sp, #4
    STR lr, [sp, #0]

    @ Prompt user for input
    LDR r0, =prompt_msg
    BL printf

    @ Correctly read user input using scanf
    SUB sp, sp, #4          
    MOV r1, sp              
    LDR r0, =scanf_format   
    BL scanf                

    LDR r4, [sp]            
    ADD sp, sp, #4          

    @ C to F Conversion
    @ Formula: F = (C * 9 / 5) + 3
    MOV r0, r4              
    MOV r1, #9              
    MUL r0, r0, r1          

    @ Step 2: Divide the result by 5 using the __aeabi_idiv function
    @ The numerator (C * 9) is already in r0, which is correct.
    MOV r1, #5              
    BL __aeabi_idiv        

    @ Step 3: Add 32
    @ r0 = ((C * 9) / 5) + 32
    ADD r0, r0, #32         
 

    # Output the result
    MOV r2, r0             
    MOV r1, r4              
    LDR r0, =result_msg     
    BL printf               

    @ Set exit code for the OS
    MOV r0, #0

    @ Return to OS by loading the saved address from the stack into the PC
    LDR pc, [sp], #4

.data
    @ Tells user to enter a temperature in Celsius
    prompt_msg:
        .asciz "Enter a temperature in Celsius: "
    @ Format string for scanf
    scanf_format:
        .asciz "%d"
    @ Output the result in Fahrenheit
    result_msg:
        .asciz "%d degrees Celsius is %d degrees Fahrenheit.\n"