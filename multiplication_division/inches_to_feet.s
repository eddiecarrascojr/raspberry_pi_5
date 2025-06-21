@ Inches to Feet and Inches Converter
@
@ This program prompts the user to enter a total number of inches,
@ reads the integer value, converts it to feet and inches,
@ and then prints the result to the console.
@ It is designed for ARMv8-A architecture running a 32-bit OS (AArch32).
@
@ To compile and run on a Raspberry Pi:
@ as -o inches_converter.o inches_converter.s
@ gcc -o inches_converter inches_converter.o
@ ./inches_converter

.global main

.data
@ String format for scanf to read a decimal integer
scanf_format: .asciz "%d"

@ String for the input prompt
prompt_message: .asciz "Enter total inches: "

@ String format for the final output using printf
@ %d inches is %d feet and %d inches.
output_format: .asciz "%d inches is %d feet and %d inches.\n"

@ Alignment for memory safety
.balign 4
@ Variable to store the integer read from scanf
input_inches: .word 0

.text
main:
    @ --- Manual Function Prologue ---
    @ Allocate 8 bytes on the stack for the frame pointer and link register.
    sub     sp, sp, #8
    @ Store the old frame pointer (fp) on the stack.
    str     fp, [sp, #0]
    @ Store the link register (lr) on the stack.
    str     lr, [sp, #4]
    @ Set the new frame pointer to the base of our new stack frame.
    mov     fp, sp

    @ --- Prompt for input ---
    @ Load the address of the prompt message into r0
    ldr r0, =prompt_message
    @ Call printf to display the prompt
    bl printf

    @ --- Read integer from user ---
    @ Load the address of the scanf format string into r0
    ldr r0, =scanf_format
    @ Load the address where the input integer will be stored into r1
    ldr r1, =input_inches
    @ Call scanf to read the integer
    bl scanf

    @ --- Load the input value for calculation ---
    @ Load the address of our input variable
    ldr r1, =input_inches
    @ Load the actual integer value from that address into r4
    ldr r4, [r1] @ r4 now holds the total inches

    @ --- Calculate Feet ---
    @ We need to calculate feet = total_inches / 12
    mov r0, r4       @ Move total inches into r0 for division
    mov r1, #12      @ Move 12 into r1
    @ The __aeabi_idiv function performs integer division
    @ It returns the result in r0 (r0 = r0 / r1)
    bl __aeabi_idiv
    mov r5, r0       @ r5 now holds the calculated feet

    @ --- Calculate Remaining Inches ---
    @ We need to calculate inches = total_inches - (feet * 12)
    @ First, calculate (feet * 12)
    mov r0, r5       @ Move feet (r5) into r0 for multiplication
    mov r1, #12      @ Move 12 into r1
    mul r2, r0, r1   @ r2 = r5 * 12 (feet * 12)

    @ Now, subtract that from the original total
    @ r6 will hold the remaining inches
    sub r6, r4, r2   @ r6 = r4 - r2 (total_inches - (feet * 12))

    @ --- Print the final result ---
    @ Prepare arguments for printf(output_format, total_inches, feet, inches)
    @ r0 = address of the output format string
    ldr r0, =output_format
    @ r1 = the first value for the format string (total inches)
    mov r1, r4
    @ r2 = the second value (feet)
    mov r2, r5
    @ r3 = the third value (remaining inches)
    mov r3, r6
    @ Call printf to display the result
    bl printf

    @ --- Manual Function Epilogue and Exit ---
    @ Set exit code to 0 (successful execution)
    mov     r0, #0
    @ Restore the old frame pointer from the stack.
    ldr     fp, [sp, #0]
    @ Restore the link register from the stack.
    ldr     lr, [sp, #4]
    @ Deallocate the 8 bytes from the stack.
    add     sp, sp, #8
    @ Return to the calling function by moving lr to the program counter.
    mov     pc, lr
