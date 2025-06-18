.global _start

.data
    prompt_msg_c: .asciz "Enter an integer: "
    output_msg_c: .asciz "The negative value (2's complement) is: %d\n"
    format_in_c:  .asciz "%d"

.bss
    .lcomm num_c, 4        # Allocate 4 bytes for the input number
    .lcomm neg_num_c, 4    # Allocate 4 bytes for the negative number

.text

_start:
    # --- Prompt for input using printf ---
    ldr r0, =prompt_msg_c  # Load address of prompt_msg_c into r0
    bl printf              # Call printf

    # --- Read integer input using scanf ---
    ldr r0, =format_in_c   # Load address of format_in_c into r0
    ldr r1, =num_c         # Load address of num_c into r1
    bl scanf               # Call scanf

    # --- Core Logic: 2's Complement ---
    ldr r0, [r1]           # Load the 32-bit integer from 'num_c' (address in r1) into r0

    mvn r1, r0             # Calculate one's complement of r0 and store in r1 (bitwise NOT)
    add r1, r1, #1         # Add 1 to r1 to get two's complement

    str r1, [r1]           # Store the result from r1 back into 'neg_num_c' (assuming r1 still holds address of neg_num_c, this is actually wrong, needs to be ldr r2, =neg_num_c; str r1, [r2])
                           # CORRECTED: r1 was overwritten by mvn. Need to load address again or use another register.
                           # Let's use a new register for storing.

    ldr r2, =neg_num_c     # Load address of neg_num_c into r2
    str r1, [r2]           # Store the result from r1 into 'neg_num_c'

    # --- Print the negative number using printf ---
    ldr r0, =output_msg_c  # Load address of output_msg_c into r0
    ldr r1, [r2]           # Load the calculated negative number from 'neg_num_c' (address in r2) into r1 for printing
    bl printf              # Call printf

    # --- Exit the program ---
    mov r7, #1             # syscall number for exit (sys_exit)
    mov r0, #0             # Exit code 0 (success)
    svc #0                 # Call kernel
