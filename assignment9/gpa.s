.data
# -----------------------------------------------------------------------------
# Data Section
#
# This section contains all the data constants and strings used in the program.
# -----------------------------------------------------------------------------

name_prompt:      .asciz  "Enter student's name: "
avg_prompt:       .asciz  "Enter student's average: "
result_msg:       .asciz  "Student: "
grade_msg:        .asciz  ", Grade: "
error_msg:        .asciz  "Error: The average must be between 0 and 100.\n"
newline:          .asciz  "\n"

# Buffer to store the user's input for the name
name_buffer:      .space  32
# Buffer to store the user's input for the average as a string
avg_buffer:       .space  8

.text
# -----------------------------------------------------------------------------
# Text Section
#
# This section contains the executable code for the program.
# -----------------------------------------------------------------------------
.global main

main:
    # --- Prompt for and read the student's name ---
    ldr r0, =name_prompt   # Load the address of the name prompt string
    bl  print_string       # Call the print_string subroutine

    ldr r0, =name_buffer   # Load the address of the name buffer
    mov r1, #32            # Set the maximum number of bytes to read
    bl  read_string        # Call the read_string subroutine

    # --- Prompt for and read the student's average ---
    ldr r0, =avg_prompt    # Load the address of the average prompt string
    bl  print_string       # Call the print_string subroutine

    ldr r0, =avg_buffer    # Load the address of the average buffer
    mov r1, #8             # Set the maximum number of bytes to read
    bl  read_string        # Call the read_string subroutine

    # --- Convert the average string to an integer ---
    ldr r0, =avg_buffer    # Load the address of the average buffer
    bl  string_to_int      # Call the string_to_int subroutine
                           # The integer result will be in r0

    # --- Validate the average ---
    cmp r0, #0             # Compare the average with 0
    blt error_exit         # If less than 0, branch to error_exit
    cmp r0, #100           # Compare the average with 100
    bgt error_exit         # If greater than 100, branch to error_exit

    # --- Determine the grade ---
    mov r4, r0             # Move the average to r4 for safekeeping
    cmp r0, #90            # Compare with 90
    bge grade_a            # If greater than or equal, it's an 'A'
    cmp r0, #80            # Compare with 80
    bge grade_b            # If greater than or equal, it's a 'B'
    cmp r0, #70            # Compare with 70
    bge grade_c            # If greater than or equal, it's a 'C'
    b   grade_f            # Otherwise, it's an 'F'

grade_a:
    mov r5, #'A'           # Set the grade to 'A'
    b   print_result

grade_b:
    mov r5, #'B'           # Set the grade to 'B'
    b   print_result

grade_c:
    mov r5, #'C'           # Set the grade to 'C'
    b   print_result

grade_f:
    mov r5, #'F'           # Set the grade to 'F'
    b   print_result

print_result:
    # --- Print the student's name ---
    ldr r0, =result_msg    # Load the address of the result message
    bl  print_string       # Print "Student: "

    ldr r0, =name_buffer   # Load the address of the student's name
    bl  print_string       # Print the name

    # --- Print the grade message and the grade ---
    ldr r0, =grade_msg     # Load the address of the grade message
    bl  print_string       # Print ", Grade: "

    mov r0, r5             # Move the grade character to r0
    bl  print_char         # Print the grade

    ldr r0, =newline       # Load the address of the newline character
    bl  print_string       # Print a newline

    b   exit               # Branch to the exit

error_exit:
    # --- Print the error message ---
    ldr r0, =error_msg     # Load the address of the error message
    bl  print_string       # Print the error message

exit:
    # --- Exit the program ---
    mov r7, #1             # syscall number for exit
    mov r0, #0             # Exit status
    svc #0                 # Make the system call

# -----------------------------------------------------------------------------
# Subroutines
# -----------------------------------------------------------------------------

# --- print_string: Prints a null-terminated string ---
# r0: Address of the string
print_string:
    push {lr}              # Push the link register to the stack
    mov r2, r0             # Copy the string address to r2
2:
    ldrb r1, [r2], #1      # Load a byte and increment the pointer
    cmp  r1, #0            # Check for the null terminator
    beq  3f                # If it's the end of the string, branch forward
    mov  r7, #4            # syscall for write
    mov  r0, #1            # stdout
    push {r2}              # Save r2
    mov  r2, #1            # Number of bytes to write
    push {r1}
    mov  r1, sp
    svc  #0                # Make the system call
    pop  {r1}
    pop  {r2}              # Restore r2
    b    2b                # Branch back to the loop
3:
    pop  {pc}              # Pop the return address to the program counter

# --- read_string: Reads a string from standard input ---
# r0: Address of the buffer
# r1: Maximum number of bytes to read
read_string:
    push {lr}              # Push the link register
    mov  r7, #3            # syscall for read
    mov  r0, #0            # stdin
    mov  r2, r1            # Number of bytes
    mov  r1, r0            # Buffer address
    svc  #0                # Make the system call
    pop  {pc}              # Return

# --- string_to_int: Converts a string to an integer ---
# r0: Address of the string
# Returns the integer in r0
string_to_int:
    push {r4, r5, lr}      # Push registers to the stack
    mov  r4, r0            # Copy the string address to r4
    mov  r0, #0            # Initialize the result to 0
    mov  r5, #10           # The base for decimal conversion
1:
    ldrb r1, [r4], #1      # Load a byte and increment the pointer
    cmp  r1, #'\n'         # Check for newline
    beq  2f
    cmp  r1, #'0'          # Check if it's a digit
    blt  1b                # If less than '0', it's not a digit
    cmp  r1, #'9'
    bgt  1b                # If greater than '9', it's not a digit
    sub  r1, r1, #'0'      # Convert ASCII digit to integer
    mul  r0, r0, r5        # Multiply the current result by 10
    add  r0, r0, r1        # Add the new digit
    b    1b
2:
    pop  {r4, r5, pc}      # Pop registers and return

# --- print_char: Prints a single character ---
# r0: The character to print
print_char:
    push {lr}              # Push the link register
    mov  r7, #4            # syscall for write
    mov  r1, sp            # Point to the character on the stack
    push {r0}              # Push the character
    mov  r0, #1            # stdout
    mov  r2, #1            # Number of bytes
    svc  #0                # Make the system call
    pop  {r0}
    pop  {pc}              # Return