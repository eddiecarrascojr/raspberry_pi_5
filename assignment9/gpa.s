#
# gpa.s
# Purpose: A program to reads in a student's name and average score,
# checks if the average score is within a valid range (0-100),
# and assigns a letter grade based on the score.
# If the score is out of range, it prints an error message.
# 
# Author: Eduardo Carrasco Jr
# Date: 07/18/2025
#
# Compile and run instructions:
#   AssemBLe with: as -o gpa.o gpa.s
#   Link with: gcc -o gpa gpa.o
#   Run with: ./gpa
#
# Parameters:
#   R0: The student's name (string).
#   R1: The student's average score (integer).
# Returns:
#   R0: The letter grade (A, B, C, or F).
#   Prints out the student's name and grade to the console.

.text
    .global main
    .extern printf
    .extern scanf

main:
    # Standard function prologue for a C-style function
    push {fp, lr}
    ADD fp, sp, #4

    LDR r0, =prompt_combined
    BL printf

    # Scanf format string ("%s %d")
    LDR r0, =fmt_s_d
    LDR r1, =student_name_buffer
    LDR r2, =average_score
    BL scanf

    # Load the student's score
    LDR r1, =average_score
    LDR r1, [r1]

    CMP r1, #0
    BLT print_error

    CMP r1, #100
    BGT print_error

    CMP r1, #90
    BGE print_grade_A

    CMP r1, #80
    BGE print_grade_B

    CMP r1, #70
    BGE print_grade_C

    B print_grade_F

print_grade_A:
    MOV r2, #'A'
    B print_result

print_grade_B:
    MOV r2, #'B'
    B print_result

print_grade_C:
    MOV r2, #'C'
    B print_result

print_grade_F:
    MOV r2, #'F'
    B print_result

print_result:
    LDR r0, =output_grade
    LDR r1, =student_name_buffer
    BL printf

    B exit_program

print_error:
    LDR r0, =error_range
    BL printf
    # If there's an error, typically you'd return a non-zero exit code
    MOV r0, #1
    B exit_program_common_return

exit_program:
    MOV r0, #0 # Set return value to 0 for success
    # Fall through to common return

exit_program_common_return:
    # Standard function epilogue for a C-style function
    SUB sp, fp, #4
    POP {fp, lr}
    BX lr

.data
    .align 4
    # Format string for reading a string and an integer
    fmt_s_d: .asciz "%s %d" 

.data
    .align 4
    prompt_combined:    .asciz "Enter student name (single word) and average (e.g., Alice 85): "
    error_range:        .asciz "Error: Average must be between 0 and 100.\n"
    output_grade:       .asciz "Student: %s, Grade: %c\n"
    grade_A:            .ascii "A"
    grade_B:            .ascii "B"
    grade_C:            .ascii "C"
    grade_F:            .ascii "F"
    newline:            .asciz "\n"

    student_name_buffer: .skip 256
    average_score:      .word 0
# End of Program gps.s