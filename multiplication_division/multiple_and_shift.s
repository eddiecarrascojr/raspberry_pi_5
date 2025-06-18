# This ARM Assembly program runs on a Raspberry Pi 5 (in AArch32 mode).
# It reads an integer, multiplies it by 10 using LSL and ADD,
# prints the result, and demonstrates a register swap using EOR.

# Data section: Stores strings for prompts and formats.
.data
    # String for prompting the user to enter a number.
    prompt: .asciz "Enter a number: "
    # Format string for scanf to read an integer.
    input_format: .asciz "%d"
    # Format string for printf to display the multiplication result.
    output_format: .asciz "Result after multiplying by 10: %d\n"
    # Format string to show register values before the EOR swap.
    swap_before_format: .asciz "Before EOR swap: r4 = %d, r5 = %d\n"
    # Format string to show register values after the EOR swap.
    swap_after_format: .asciz "After EOR swap: r4 = %d, r5 = %d\n"

# BSS section: Uninitialized data, typically for variables.
.bss
    # A word (4 bytes) to store the integer input by the user.
    .align 2 # Ensure 4-byte alignment for word access.
    number: .word 0

# Text section: Contains the executable code.
.text
# Declare 'main' as a global symbol, making it the entry point for the linker.
.global main
# Declare 'printf' and 'scanf' as external symbols, indicating they are defined
# elsewhere (in the C standard library, libc).
.extern printf
.extern scanf

# The main entry point of the program.
main:
    # Save the Link Register (lr) onto the stack.
    # The lr holds the return address, allowing us to return cleanly
    # after the 'main' function completes (to libc's startup code).
    push {lr}

    # --- Prompt for Input ---
    # Load the address of the 'prompt' string into register r0.
    # r0 is used for the first argument to functions like printf.
    ldr r0, =prompt
    # Branch with Link (bl) to the printf function.
    # 'bl' saves the current instruction address into lr before jumping.
    bl printf

    # --- Read Input Number ---
    # Load the address of the 'input_format' string ("%d") into r0.
    ldr r0, =input_format
    # Load the address of the 'number' variable (where scanf should store the input)
    # into register r1. r1 is used for the second argument.
    ldr r1, =number
    # Call the scanf function to read an integer from standard input.
    bl scanf

    # --- Load Input Number into a Register ---
    # Load the integer value that scanf stored at the memory address 'number'
    # into register r4. r4 will be used for our calculations.
    ldr r4, [r1] # r1 still holds the address of 'number' from the scanf call.

    # --- Multiply by 10 using LSL and ADD ---
    # The multiplication N * 10 can be achieved as (N * 8) + (N * 2).
    # N * 8 is equivalent to N shifted left by 3 bits (N LSL #3).
    # N * 2 is equivalent to N shifted left by 1 bit (N LSL #1).

    # Perform N * 8: Shift r4 left by 3 bits, store result in r5.
    mov r5, r4, lsl #3
    # Perform N * 2: Shift r4 left by 1 bit, store result in r6.
    mov r6, r4, lsl #1
    # Add the two intermediate results (r5 + r6) and store the final
    # multiplication result (N * 10) in r7.
    add r7, r5, r6

    # --- Print the Result ---
    # Load the address of the 'output_format' string into r0.
    ldr r0, =output_format
    # Move the calculated result (N * 10) from r7 into r1.
    # r1 is the second argument for printf (the integer to print).
    mov r1, r7
    # Call printf to display the result.
    bl printf

    # --- Register Swap using EOR (Exclusive OR) ---
    # This technique swaps the values of two registers without needing a temporary register.
    # It works because A XOR B XOR B = A and A XOR B XOR A = B.

    # Initialize r4 and r5 with distinct values for demonstration.
    mov r4, #123 # Assign 123 to r4
    mov r5, #456 # Assign 456 to r5

    # Print values of r4 and r5 before the swap.
    ldr r0, =swap_before_format # Load format string
    mov r1, r4                  # First integer argument (r4's value)
    mov r2, r5                  # Second integer argument (r5's value)
    bl printf                   # Call printf

    # Perform the EOR swap:
    eor r4, r4, r5  # Step 1: r4 = (original r4) XOR (original r5)
                    # Now r4 holds a combined value.
    eor r5, r4, r5  # Step 2: r5 = (current r4) XOR (original r5)
                    #         r5 = ((original r4) XOR (original r5)) XOR (original r5)
                    #         r5 = original r4
                    # So, r5 now holds the original value of r4.
    eor r4, r4, r5  # Step 3: r4 = (current r4) XOR (current r5)
                    #         r4 = ((original r4) XOR (original r5)) XOR (original r4)
                    #         r4 = original r5
                    # So, r4 now holds the original value of r5.
    # At this point, the values in r4 and r5 have been successfully swapped.

    # Print values of r4 and r5 after the swap.
    ldr r0, =swap_after_format # Load format string
    mov r1, r4                  # First integer argument (r4's value)
    mov r2, r5                  # Second integer argument (r5's value)
    bl printf                   # Call printf

    # --- Exit the Program ---
    # Restore the Link Register from the stack.
    pop {lr}
    # Set r7 to the system call number for 'exit' (SYS_exit is 1 on ARM Linux).
    mov r7, #1
    # Issue a Supervisor Call (SVC) to the kernel to perform the exit system call.
    svc #0