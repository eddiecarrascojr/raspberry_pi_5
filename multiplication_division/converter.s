#
# ARM Assembly Program: Fahrenheit to Celsius Converter
# Program Name: converter.s
# Author: Eduardo Carrasco Jr
# Date: 06/21/2025
# Purpose: Reads in user for a temperature in Celsius,
# then converts it to Fahrenheit, and prints the result.
#
# Inputs: 
#   - Integer of temperature in Fahrenheit
#   - r0 as integer of Fahrenheit temperature
# Outputs:
#   - Integer of temperature in Celsius
#   - r0 as integer of Celsius temperature
#

.text
.global main

main:
    # Manually save Link Register and IP to the stack to maintain 8-byte alignment
    SUB sp, sp, #4         
    STR lr, [sp, #0]        
    
    # 1. Prompt the user for input
    LDR r0, =prompt_msg     
    BL printf               

    # 2. Read an integer from the user using scanf
    SUB sp, sp, #4          
    MOV r1, sp             
    LDR r0, =scanf_format   
    BL scanf                

    LDR r4, [sp]            
    add sp, sp, #4          
    
    # 3. Call the conversion function
    MOV r0, r4             
    BL fahrenheit_to_celsius 
                           

    # 4. Print the final result
    MOV r2, r0              
    MOV r1, r4              
    LDR r0, =result_msg     
    BL printf               

    # 5. Exit the program cleanly
    MOV r0, #0              
    
    # Manually restore IP and PC (from saved LR) and return from main
    LDR ip, [sp, #0]       
    LDR pc, [sp, #4]        

.data
# The .data section is used to declare initialized data or constants.
prompt_msg:
    .asciz "Enter a temperature in Fahrenheit: "

scanf_format:
    .asciz "%d"  # Format STRing for scanf to read a decimal integer

result_msg:
    .asciz "%d degrees Fahrenheit is %d degrees Celsius.\n"
