# -----------------------------------------------------------------------------
# recursion_multi.s
#
# This program calculates the product of two numbers using recursive
# successive addition. It prompts the user for two integers: a multiplier (m)
# and the number of iterations (n).
#
# The recursive logic is as follows:
#   Mult(m, n) = m                            (if n = 1)
#   Mult(m, n) = m + Mult(m, n - 1)         (if n > 1)
#
# To assemble and link on a Raspberry Pi (or any ARM 32-bit system):
#   as -o arm_recursive_multiply.o arm_recursive_multiply.s
#   gcc -o arm_recursive_multiply arm_recursive_multiply.o
#
# To run:
#   ./arm_recursive_multiply
# -----------------------------------------------------------------------------


.global main

# -----------------------------------------------------------------------------
# recursive_multiply: Performs multiplication using successive addition.
#
# Arguments:
#   r0: The multiplier (m)
#   r1: The number of iterations (n)
#
# Returns:
#   r0: The result of the multiplication (m * n)
# -----------------------------------------------------------------------------
recursive_multiply:
    # --- Function Prologue ---
    # Manually save the link register to the stack. This is an alternative
    # to 'push {lr}'. We decrement the stack pointer and then store lr.
    sub sp, sp, #4
    str lr, [sp]

    # --- Base Case ---
    # Check if n (in r1) is equal to 1.
    cmp r1, #1
    # If n == 1, the recursion stops. The result is simply m.
    # The value of m is already in r0, so we just need to return.
    beq return_base_case

    # --- Recursive Step ---
    # If n > 1, we need to calculate m + Mult(m, n - 1).

    # First, save the current multiplier 'm' (in r0) on the stack.
    # We need this value for the addition after the recursive call returns.
    push {r0}

    # Decrement n for the next recursive call: n = n - 1
    sub r1, r1, #1

    # Recursively call the function with Mult(m, n - 1).
    # r0 still contains m, and r1 now contains n - 1.
    bl recursive_multiply

    # After the recursive call returns, the result of Mult(m, n-1) is in r0.
    # Now, we need to add the original 'm' that we saved.
    # Pop the saved 'm' from the stack into r2.
    pop {r2}

    # Perform the addition: result = m + Mult(m, n - 1)
    # r0 = r0 (result from recursive call) + r2 (original m)
    add r0, r0, r2

return_base_case:
    # --- Function Epilogue ---
    # Manually restore the return address from the stack into the program
    # counter (pc). This instruction loads from the stack pointer and then
    # increments it, effectively replacing 'pop {pc}'.
    ldr pc, [sp], #4


# -----------------------------------------------------------------------------
# main: The main entry point of the program.
# -----------------------------------------------------------------------------
main:
    # --- Function Prologue ---
    # Push frame pointer and link register to the stack to conform to
    # standard calling conventions.
    push {fp, lr}
    add fp, sp, #4

    # --- Prompt for Multiplier (m) ---
    # Load the address of the prompt string into r0.
    ldr r0, =prompt_m
    # Call printf to display the prompt.
    bl printf

    # --- Read Multiplier (m) ---
    # Load the address of the format string ("%d") into r0.
    ldr r0, =format_int
    # Load the address where the input integer will be stored into r1.
    ldr r1, =input_m
    # Call scanf to read the integer from the user.
    bl scanf

    # --- Prompt for Iterations (n) ---
    # Load the address of the second prompt string into r0.
    ldr r0, =prompt_n
    # Call printf.
    bl printf

    # --- Read Iterations (n) ---
    # Load the address of the format string ("%d") into r0.
    ldr r0, =format_int
    # Load the address where the second integer will be stored into r1.
    ldr r1, =input_n
    # Call scanf.
    bl scanf

    # --- Prepare for Recursive Call ---
    # Load the user's first input (m) into r0.
    ldr r1, =input_m
    ldr r0, [r1]
    # Load the user's second input (n) into r1.
    ldr r1, =input_n
    ldr r1, [r1]

    # Call the recursive multiplication function.
    bl recursive_multiply
    # The result is now in r0.

    # --- Display the Result ---
    # Move the result from r0 to r1, as r1 is the second argument for printf.
    mov r1, r0
    # Load the address of the result message format string into r0.
    ldr r0, =result_msg
    # Call printf to display the final result.
    bl printf

    # --- Function Epilogue ---
    # Set the return value to 0 (successful execution).
    mov r0, #0
    # Restore the stack and frame pointers.
    sub sp, fp, #4
    pop {fp, pc}

# We need to link with the C library for printf and scanf
.extern printf
.extern scanf

.data
# String constants for user prompts and output formatting
prompt_m:       .asciz "Enter the multiplier (m): "
prompt_n:       .asciz "Enter the number of iterations (n): "
result_msg:     .asciz "Result: %d\n"
format_int:     .asciz "%d"

# Memory allocation for user input. .word allocates 4 bytes.
input_m:        .word 0
input_n:        .word 0

.text
# End of the assembly file
