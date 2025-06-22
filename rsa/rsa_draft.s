#
# ARM AssemBLy Program: Encryption and Decryption using RSA
# Program Name: rsa_implementation.s
# Authors: Eduardo Carrasco Jr, Bryon Proctor, Kyla Ugwu, and Peyton Marrone.
# Date: 06/21/2025
# Purpose: Reads in user message to encrypt using RSA algorithm.
#
# Inputs: 
#   - String message to encrypt as well as two integers.
#   - r0 the message to encrypt
#   - r1 the first integer
#   - r2 the second integer

# Outputs:
#   - Encrypted message
#   - r0 as encrypted message
#   

# Buffers to store the user's input
.lcomm user_message, 100 # Buffer for the STRing
.lcomm integer_val1, 4    # 4 bytes for the first integer
.lcomm integer_val2, 4    # 4 bytes for the second integer

.text
.global main

main:
    # Manually create a stack frame to save the return address
    SUB sp, sp, #8            
    STR lr, [sp, #4]          

    # Prompt and Read Input using scanf
    # int scanf(const char *format, ...);
    # r0 = address of format STRing
    # r1 = address of user_message buffer
    # r2 = address of integer_val1
    # r3 = address of integer_val2

    LDR r0, =scan_format
    LDR r1, =user_message
    LDR r2, =integer_val1
    LDR r3, =integer_val2
    BL scanf


    # Read the user input into the buffers and print the results read in.
    LDR r0, =printf_format
    LDR r1, =user_message
    LDR r1, [r1]                 
    LDR r2, =integer_val1     
    LDR r2, [r2]              
    LDR r3, =integer_val2     
    LDR r3, [r3]             
    BL printf    

    # Exit the program cleanly
    MOV r0, #0                
    LDR lr, [sp, #4]         
    add sp, sp, #8            
    BX lr


.data
    # Format STRings for scanf for upto 100 character STRing and two integers
    scan_format:   .asciz "%99s %d %d" # Reads a String (up to 99 chars), and two integers
    # Format STRing for printf
    printf_format: .asciz "\nYou entered:\nMessage: %s\nFirst Integer: %d\nSecond Integer: %d\n"