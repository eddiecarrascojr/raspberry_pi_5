.global 

encrypt: 
    SUB sp, sp, #24 
    STR lr, [sp] 
    STR r4, [sp, #4] 
    STR r5, [sp, #8] 
    STR r6, [sp, #12] 
    STR r7, [sp, #16] 
    STR r8, [sp, #20] 

    # prompt the user for message  
    LDR r0, =encryptPrompt 
    BL printf 

    # read the message 
    LDR r0, =formatStr    
    LDR r1, =buffer 
    BL scanf 

    LDR r6, =buffer       # r6 points to input string 
    LDR r7, =encryptedBuffer # r7 points to encrypted output buffer 

encrypt_loop: 
    LDRB r4, [r6], #1      
    CMP r4, #0             
    BEQ encrypt_complete 
 
    #ASCII value of char is in r4 
    MOV r0, r4            # m = ASCII(char) - individual plaintext character of message 
    LDR r1, =eValue 
    LDR r1, [r1]          # e – public key exponent 
    LDR r2, =modulus 
    LDR r2, [r2]          # n – calculated modulus 
    # r0 = m, r1 = e, r2 = n 

    BL pow_mod            # result in r0 
 
    # store encrypted value 
    MOV r1, r0            # encrypted value 
    LDR r0, =formatEnc    # format as string 
    MOV r2, r7            # write to buffer 
    BL sprintf 
    ADD r7, r7, r0        

    B encrypt_loop 

encrypt_complete: 
    # Write to file 
    LDR r0, =encryptedFile 
    MOV r1, #1            
    MOV r2, #0644         # permissions 
    BL fopen 
    MOV r4, r0             

    LDR r1, =encryptedBuffer 
    BL fputs 

    MOV r0, r4 
    BL fclose 

    # restore registers 
    LDR lr, [sp] 
    LDR r4, [sp, #4] 
    LDR r5, [sp, #8] 
    LDR r6, [sp, #12] 
    LDR r7, [sp, #16] 
    LDR r8, [sp, #20] 
    ADD sp, sp, #24 
    MOV pc, lr 

.data 
    encryptPrompt: .asciz "Enter a message you would like to encrypt (<100 chars): \n" 
    encryptedFile: .asciz "encrypted.txt" 
    decryptedFile: .asciz "plaintext.txt" 
    buffer: .space 100      # store the user’s message 
    encryptedBuffer: .space 400 # stores the ASCII values 
    dValue: .word 0         # private key exponent d 
    modulus: .word 0        # n value for modulus 


.global 

decrypt: 
    SUB sp, sp, #24 
    STR lr, [sp] 
    STR r4, [sp, #4] 
    STR r5, [sp, #8] 
    STR r6, [sp, #12] 
    STR r7, [sp, #16] 
    STR r8, [sp, #20] 
 
    # open the encrypted file 
    LDR r0, =encryptedFile 
    LDR r1, =formatRead   # "r" 
    BL fopen 
    MOV r4, r0         
 
    LDR r1, =encryptedBuffer 
    BL fgets 

    MOV r6, r1            # pointer to buffer 
    LDR r7, =decryptedBuffer # location to store result 
 
decrypt_loop: 
    # parse int from string 
    MOV r0, r6 
    BL atoi 
    MOV r5, r0            # c = encrypted int 
 
    # advance string past the current int 
    BL advance_int_str     

    # decrypt: m = c^d mod n 
    MOV r0, r5            # c – cipher text 
    LDR r1, =dValue 
    LDR r1, [r1]          # d – private key exponent 
    LDR r2, =modulus 
    LDR r2, [r2]          # n – calculated modulus 
    BL pow_mod            # result in r0 (ASCII value) 

    # Convert r0 to char and store 
    STRB r0, [r7], #1     # write to decryptedBuffer 

    CMP r6, #0             
    BEQ decrypt_complete 
    B decrypt_loop 

decrypt_complete: 
    MOV r0, r4 
    BL fclose 
 
    # null-terminate string to mark end of string 
    MOV r0, #0 
    STRB r0, [r7] 

    # write to plaintext.txt 
    LDR r0, =decryptedFile 
    MOV r1, #1 
    MOV r2, #0644 
    BL fopen 
    MOV r4, r0 

    LDR r1, =decryptedBuffer 
    BL fputs 
    MOV r0, r4 
    BL fclose 
 
    # restore registers 
    LDR lr, [sp] 
    LDR r4, [sp, #4] 
    LDR r5, [sp, #8] 
    LDR r6, [sp, #12] 
    LDR r7, [sp, #16] 
    LDR r8, [sp, #20] 
    ADD sp, sp, #24 
    MOV pc, lr 
 

.data 

    formatStr: .asciz "%s" 
    formatEnc: .asciz "%d " 
    formatRead: .asciz "r" 
    decryptedBuffer: .space 100 

