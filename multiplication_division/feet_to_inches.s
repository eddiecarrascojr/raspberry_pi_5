.text
.global main

main:
    // Function Prologue: Manually save the Link Register to the stack.
    SUB sp, sp, #4      // Allocate 4 bytes of stack space
    STR lr, [sp, #0]    // Save the link register to the stack

    // Prompt for and read the number of feet
    LDR r0, =prompt_feet // Load address of the prompt string for printf
    BL printf            // Call printf

    LDR r0, =format_string // Load address of format string for scanf
    LDR r1, =input_feet    // Load address where scanf will store the integer
    BL scanf             // Call scanf

    // Prompt for and read the number of inches
    LDR r0, =prompt_inches // Load address of the prompt string for printf
    BL printf              // Call printf

    LDR r0, =format_string  // Load address of format string for scanf
    LDR r1, =input_inches   // Load address where scanf will store the integer
    BL scanf                // Call scanf

    // --- Calculation ---
    // total_inches = (feet * 12) + inches

    // Load the values from memory into registers
    LDR r1, =input_feet
    LDR r1, [r1]            // r1 = value of input_feet
    LDR r2, =input_inches
    LDR r2, [r2]            // r2 = value of input_inches

    // Perform the multiplication
    MOV r3, #12             // r3 = 12
    // The MUL instruction on this architecture requires the destination register (Rd)
    // and the first source register (Rm) to be different.
    // We will store the result in r0. So, r0 = r1 * r3.
    MUL r0, r1, r3          // r0 = feet * 12

    // Perform the addition
    // The result of the multiplication is already in r0.
    ADD r0, r0, r2          // r0 = (feet * 12) + inches

    // --- Display Result ---
    // The result is already in r0, but printf expects the format string in r0
    // and the first value in r1.
    MOV r1, r0              // Move the final result into r1 for printf
    LDR r0, =output_string  // Load address of the output format string into r0
    BL printf               // Call printf

    // Function Epilogue: Manually restore the Link Register and return.
    LDR lr, [sp, #0]    // Restore the link register from the stack
    ADD sp, sp, #4      // Deallocate stack space
    MOV pc, lr          // Return from main by moving lr to the Program Counter

// The .data section remains unchanged as it is perfectly fine.
.data
    prompt_feet:    .asciz "Enter the number of feet: "
    prompt_inches:  .asciz "Enter the number of inches: "
    format_string:  .asciz "%d"
    output_string:  .asciz "\nTotal inches: %d\n"
    input_feet:     .word 0
    input_inches:   .word 0
