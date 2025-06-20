.text
.global main
_main:
    SUB sp, sp, #4      // Allocate 4 bytes of stack space
    STR lr, [sp, #0]    // Save the link register to the stack

    // Prompt for and read the number of feet
    LDR r0, =prompt_feet // Load the address of the feet prompt string into r0
    BL printf            // Call printf to display the prompt

    LDR r0, =format_string // Load the address of the format string ("%d") into r0
    LDR r1, =input_feet    // Load the address of the input_feet variable into r1
    BL scanf             // Call scanf to read the integer input for feet

    // Prompt for and read the number of inches
    LDR r0, =prompt_inches // Load the address of the inches prompt string into r0
    BL printf              // Call printf to display the prompt

    LDR r0, =format_string  // Load the address of the format string ("%d") into r0
    LDR r1, =input_inches   // Load the address of the input_inches variable into r1
    BL scanf                // Call scanf to read the integer input for inches

    // Perform the calculation: total_inches = (feet * 12) + inches
    LDR r1, =input_feet     // Load the address of input_feet into r1
    LDR r1, [r1]            // Dereference r1 to get the value of input_feet
    LDR r2, =input_inches   // Load the address of input_inches into r2
    LDR r2, [r2]            // Dereference r2 to get the value of input_inches

    MOV r3, #12             // Move the integer 12 into r3 for multiplication
    MUL r1, r1, r3          // Multiply feet (r1) by 12, store result in r1

    ADD r0, r1, r2          // Add the inches (r2) to the result of the multiplication (r1)

    // Display the final calculated total inches
    MOV r1, r0              // Move the final result (total inches) into r1 for printing
    LDR r0, =output_string  // Load the address of the output format string into r0
    BL printf               // Call printf to display the result

    LDR lr, [sp, #0]    // Restore the link register from the stack
    ADD sp, sp, #4      // Deallocate stack space
    MOV pc, lr          // Return from main

.data
    prompt_feet:    .asciz "Enter the number of feet: "
    prompt_inches:  .asciz "Enter the number of inches: "
    format_string:  .asciz "%d"
    output_string:  .asciz "\nTotal inches: %d\n"
    input_feet:     .word 0
    input_inches:   .word 0
