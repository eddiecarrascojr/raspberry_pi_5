.text
.global main

main:

#pop the stack
     SUB sp, sp , #8
     STR lr, [sp]
     STR r4, [sp, #4] 

     #prompt user to entertotient
     LDR r0, =prompt
     BL printf

     #take in user 'e' value
     LDR r0, =format //how to read input
     LDR r1, =totient //make space for input 
     BL scanf //take in input

     LDR r1, =totient
     LDR r1, [r1]
     MOV r4, r1 //hold totient in r4


      #prompt user for 'e' value
      LDR r0, =prompt2
      BL printf 
   
      #take in user value
      LDR r0, =format2
      LDR r1, =eValue
      BL scanf


      LDR r1, =eValue
      LDR r1, [r1] //putting e value into r1

      MOV r0, r4 //moving totient into r0

      #calling gcd function
      BL gcd

      #printing totient and e to ensure they are in the right register
      #MOV r2, r1 
      #MOV r1, r0
      #LDR r0, =check
      #BL printf
      

#push the stack
    LDR r4, [sp, #4]
    LDR lr, [sp]
    ADD sp, sp, #8
    MOV pc, lr


.data
    prompt: .asciz "Please enter your totient value: \n"
    prompt2: .asciz "Please enter your desired e  value: \n"
    #check: .asciz "Totient = %d and eValue = %d\n"
    format: .asciz "%d"
    format2: .asciz "%d"
    totient: .word 0
    eValue: .word 0


.text
   # r4 - storing e  initially | in loop will always hold a
   # r5 - storing totient  initially | in loop will be used to hold remainder
   # r6 - storing the new value b
   # r7 - storing the remainder to compare at the beginning of the loop
   # r8 - holding previous remainder before remainder 0 to print gcd
   # r10 - holding the original e value
   # r11 - holding the original totient

#put a loop here to prompt the user to put in 2 new p and q values

#greatest common divisor
gcd:

#pop the stack
   SUB sp, sp , #32
   STR lr, [sp]
   STR r4, [sp, #4] 
   STR r5, [sp, #8]
   STR r6, [sp, #12]
   STR r7, [sp, #16]
   STR r8, [sp, #20]
   STR r10, [sp, #24]
   STR r11, [sp, #28]   

#assuming that when the function is call totient r0 and e is in r1
   MOV r5, r0 //copying totient  in r5
   MOV r11, r0 //holder of totient
   MOV r4, r1 // copying e in r4
   MOV r10, r1 // holder of e value

   MOV r8, r4//save first value of b or e in r8
   #calculate quotient of totient /e
   MOV r0, r5 //totient
   MOV r1, r4 //e
   BL __aeabi_idiv //assuming that r0 holds totient and r1 holds e when gcd function is called.

   MUL r0, r4, r0 // e*quotient
   SUB r6, r5, r0 // totient  - e*quotient =remainder    
   MOV r7, r6 //copying remainder in r7 to compare at the beginning of loop
  
   gcdLoop:
         #setting up a loop to calculate gcd
         CMP r7, #0 //is remainder - r7 equal to zero if not continue loop
         BEQ endGCDLoop
         MOV r8, r6 //hold previous remainder into r8 to eventually print gcd

         MOV r0, r4 //move e (b) which is now a into r0 (a)
         MOV r1, r6 //move remainder which is now b into r1 (b)
         BL __aeabi_idiv //store quotient in r0
         
         MUL r0, r6, r0 // b*quotient
         SUB r5, r4, r0 // a -  b*quotient = remainder

         MOV r4, r6 //storing b into a
         MOV r6, r5 //storing remainder into b

         MOV r7, r5 //storing remainder into comparer
         
         B gcdLoop

  endGCDLoop:

    #compare gcd value to 1: if it is one then the values are co-prime
    CMP r8, #1
    BNE else

       #if the values are co-prime: then print this statement 
       MOV r1, r11 //move totient into r1
       MOV r2, r10 //move e into r2
       MOV r3, r8 // move gcd into r3

      #print gcd
       LDR r0, =coPrime
       BL printf
       B End

      #if value is not co prime: print this statement

     else:
      #printing gcd 
       MOV r1, r11 //move totient into r1
       MOV r2, r10 //move e into r2
       MOV r3, r8 // move gcd into r3

      #print gcd
       LDR r0, =gcdOutput
       BL printf
   End:

#push the stack
    LDR r4, [sp, #4]
    LDR r5, [sp, #8]
    LDR r6, [sp, #12]
    LDR r7, [sp, #16]
    LDR r8, [sp, #20]
    LDR r10, [sp, #24]
    LDR r11, [sp, #28]
    LDR lr, [sp]
    ADD sp, sp, #32
    MOV pc, lr


              
.data
    coPrime: .asciz "The totient is : %d.  The eValue is: %d. The gcd is: %d! They are co-prime.\n"
    gcdOutput: .asciz "The totient is: %d. The eValue is: %d. The gcd is: %d! They are not co-prime.\n"