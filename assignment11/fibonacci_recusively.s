# =============================================================================
# Program:      Recursive Fibonacci Calculator
# Author:       Gemini
# Date:         2024-07-31
# Description:  This program calculates the nth Fibonacci number using a
#               recursive function. It prompts the user for an integer 'n',
#               computes F(n), and prints the result.
# Target:       ARMv7-A (32-bit), suitable for Raspberry Pi 5
#
# To assemble and link on a Raspberry Pi:
#   as -o fib.o fib.s
#   gcc -o fib fib.o
#   ./fib
#
# fib: Recursive function to calculate the nth Fibonacci number
#   Calculates F(n) where F(n) = F(n-1) + F(n-2)
#   Base cases: F(0) = 0, F(1) = 1
#   Input:
#       r0: The integer n
#   Output:
#       r0: The nth Fibonacci number
# -----------------------------------------------------------------------------
.global main

.text
fib:
    # --- Function Prologue ---
    # Save the link register and r4 on the stack. We need to save lr because
    # we are making function calls (to ourself). We save r4 to hold the
    # value of n across recursive calls.
    push    {r4, lr}

    # --- Base Case Check ---
    cmp     r0, #1          # Compare n with 1
    ble     fib_base_cases  # If n <= 1, jump to handle base cases

    # --- Recursive Step: F(n) = F(n-1) + F(n-2) ---
    # Calculate F(n-1)
    mov     r4, r0          # Save original n in r4 before modifying r0
    sub     r0, r0, #1      # r0 = n - 1
    bl      fib             # Recursively call fib(n-1). Result is in r0.

    # At this point, r0 contains fib(n-1). We need to save it.
    mov     r1, r0          # Store fib(n-1) in r1

    # Calculate F(n-2)
    sub     r0, r4, #2      # r0 = n - 2 (using the saved n from r4)
    bl      fib             # Recursively call fib(n-2). Result is in r0.

    # At this point, r0 contains fib(n-2) and r1 contains fib(n-1).
    # Add them together for the final result.
    add     r0, r1, r0      # r0 = fib(n-1) + fib(n-2)

    b       fib_done        # Branch to the end of the function

fib_base_cases:
    # If n <= 1, then F(n) = n.
    # The value of n is already in r0, so we don't need to do anything.
    # The function will simply return r0.

fib_done:
    # --- Function Epilogue ---
    # Restore the registers we saved at the beginning
    pop     {r4, lr}
    bx      lr              # Return to the caller

# Main function to handle user input and output
main:
    # --- Function Prologue ---
    # Manually save the link register (return address) on the stack
    sub     sp, sp, #4      # Decrement stack pointer to make space
    str     lr, [sp]        # Store the link register on the stack

    # --- Prompt User for Input ---
    ldr     r0, =prompt_msg # Load address of the prompt message
    bl      printf          # Call printf to display the prompt

    # --- Read User Input ---
    ldr     r0, =input_format # Load address of the format string "%d"
    ldr     r1, =input_num    # Load address of where to store the input number
    bl      scanf             # Call scanf to read an integer from the user

    # --- Call Fibonacci Function ---
    ldr     r0, =input_num    # Load address of the input number
    ldr     r0, [r0]          # Dereference to get the actual value of n into r0
    bl      fib               # Call the fib function. The result will be in r0.

    # --- Print the Result ---
    mov     r1, r0            # Move the result (fib(n)) into r1 for printing
    ldr     r0, =result_msg   # Load address of the result message format string
    bl      printf            # Call printf to display the final result

    # --- Exit Program ---
    mov     r0, #0            # Return 0 to indicate success
    # Manually restore the link register and return to the OS
    ldr     lr, [sp]        # Load the saved return address back into lr
    add     sp, sp, #4      # Increment stack pointer to deallocate space
    bx      lr              # Branch to the address in lr to return

.data

# Standard input and output strings
prompt_msg:
    .asciz "Enter a non-negative integer (n) to find the Fibonacci number: "

input_format:
    .asciz "%d"

result_msg:
    .asciz "The Fibonacci number is: %d\n"

.bss
# This section is for uninitialized data.
input_num:
    .word 0  # A 4-byte space to store the integer read from the user
