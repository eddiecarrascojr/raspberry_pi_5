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
    # start the stack
    SUB sp, sp, #4          

    # --- Function Body ---

    # 1. Prompt the user for input.
    LDR r0, =prompt_msg
    BL printf

    # 2. Read an integer, 
    MOV r1, sp              
    LDR r0, =scanf_format
    BL scanf               

    # Immediately load the Fahrenheit value into a safe register, r4.
    LDR r4, [sp, #0]        

    # 3. Convert Fahrenheit to Celsius.
    # We MUST save the Link Register now because 'BL __aeabi_idiv' will overwrite it.
    STR lr, [sp, #0]        
    MOV r0, r4        
    # Add 32      
    SUB r0, r0, #32
    # Multiply by 5
    MOV r1, #5
    MUL r0, r0, r1
    # Divide by 9 using the __aeabi_idiv function.
    MOV r1, #9
    BL __aeabi_idiv         

    # Restore the Link Register immediately after the call.
    LDR lr, [sp, #0] 

    # 4. Print the final result.
    MOV r2, r0             
    MOV r1, r4           
    LDR r0, =result_msg
    BL printf

    # 5. Clean up and exit.
    MOV r0, #0              
    ADD sp, sp, #4         
    BX lr                   

.data
prompt_msg:
    .asciz "Enter a temperature in Fahrenheit: "

scanf_format:
    .asciz "%d"

result_msg:
    .asciz "%d degrees Fahrenheit is %d degrees Celsius.\n"