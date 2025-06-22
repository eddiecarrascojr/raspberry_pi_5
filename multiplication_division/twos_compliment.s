
#
# ARM AssemBLy Program: Reads in integer then performs two's complement negation
# Program Name: twos_compliment.s
# Author: Eduardo Carrasco Jr
# Date: 06/21/2025
# Purpose: Reads in user for an integer,
# then performs two's complement negation, and prints the result.
#
# Inputs: 
#   - Integer of number to negate
#   - r0 as integer of inches

# Outputs:
#   - Integer of negated number
#   - r0 as integer of negated number
#

.text
.global main

main:
    # Manually save the link register and allocate stack space
    sub     sp, sp, #4     
    str     lr, [sp, #0]   
                           
    # Prompt the user and read the integer
    ldr     r0, =prompt_string 
    bl      printf          

    # Load the address of the format string ("%d") into r0
    ldr     r0, =format_string 
    mov     r1, sp          
    bl      scanf          
   

    ldr     r2, [sp, #0]
                           

    # Perform Two's Complement with bitwise NOT and addition
    mvn     r3, r2          # r3 = ~r2. MVN (Move Not) performs a bitwise NOT.
    add     r3, r3, #1  
                           

    # Print the result
    ldr     r0, =result_string
    mov     r1, r2        
    mov     r2, r3         
    bl      printf          

    # Clean up and return from main
    mov     r0, #0    
    ldr     lr, [sp, #4]    
    add     sp, sp, #8     
    mov     pc, lr         

.data
    # Prompt message for the user
    prompt_string:  .asciz "Enter an integer: "
    # Read in the integer from the user
    format_string:  .asciz "%d" 
    # Output message for the result
    result_string:  .asciz "You entered: %d. The negative value is: %d\n"