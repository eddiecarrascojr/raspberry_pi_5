// AArch64 Assembly program to print the reference (memory address) of a variable
//
// To compile and run:
// gcc -o printf_reference_example printf_reference_example.s
// ./printf_reference_example

.data

prompt_msg:
    .asciz "Please enter your age: "
scan_format:
    .asciz "%d"

// New format strings to print the memory address (reference)
ref_after_scan_msg:
    .asciz "Reference before at input: %p\n"
ref_after_read_msg:
    .asciz "Reference before at output: %p\n"

// Final output message
output_msg:
    .asciz "\nYou are %d years old.\n"

.bss
    // A place to store the integer read from scanf
    .align 8 // Align to 8 bytes for addresses
input_age:
    .space 8 // Use 8 bytes for consistency with 64-bit addresses

.text
.global main

main:
    // Standard function prologue
    stp x29, x30, [sp, -16]!  // Store frame pointer and link register
    mov x29, sp

    // --- 1. Print the prompt ---
    // printf("Please enter your age: ");
    ldr x0, =prompt_msg
    bl printf

    // --- 2. Get user input ---
    // scanf("%d", &input_age);
    ldr x0, =scan_format
    ldr x1, =input_age        // x1 = address of input_age
    bl scanf

    // --- 3. Print the reference AFTER scanning ---
    // printf(" -> The address... is: %p\n", &input_age);
    ldr x0, =ref_after_scan_msg
    ldr x1, =input_age        // x1 = address of input_age (the reference to print)
    bl printf

    // --- 4. Print the final output message using the value ---
    // printf("\nYou are %d years old.\n", value_at_input_age);
    ldr x0, =output_msg
    ldr x1, =input_age        // First, get the address of input_age
    ldr w1, [x1]              // Then, load the 32-bit integer VALUE from that address into w1
    bl printf

    // --- 5. Print the reference AFTER it has been read and used ---
    // printf(" -> The same reference... is: %p\n", &input_age);
    ldr x0, =ref_after_read_msg
    ldr x1, =input_age        // x1 = address of input_age (the reference to print)
    bl printf

    // Standard function epilogue
    mov w0, #0                // Return 0 from main
    ldp x29, x30, [sp], 16   // Restore frame pointer and link register
    ret                       // Return from main

// We need to declare printf and scanf as external functions
.extern printf
.extern scanf
