.global main

# External functions from libConversions.s
.text
.extern miles2kilometer
.extern kph
.extern CToF
.extern InchesToFt


main:
    PUSH {LR} # Save Link Register

    # --- KPH Calculation ---
    # Prompt for miles
    LDR R0, =prompt_miles # Load address of prompt string
    SWI 0x6B              # Call printf

    # Read miles
    LDR R0, =fmt_int      # Load address of format string "%d"
    LDR R1, =miles_val    # Load address of miles_val variable
    SWI 0x69              # Call scanf

    # Prompt for hours
    LDR R0, =prompt_hours # Load address of prompt string
    SWI 0x6B              # Call printf

    # Read hours
    LDR R0, =fmt_int      # Load address of format string "%d"
    LDR R1, =hours_val    # Load address of hours_val variable
    SWI 0x69              # Call scanf

    # Call kph function
    LDR R0, =hours_val    # Load address of hours_val
    LDR R0, [R0]          # Load hours value into R0
    LDR R1, =miles_val    # Load address of miles_val
    LDR R1, [R1]          # Load miles value into R1
    BL kph                # Call kph (result in R0)

    # Print kph result
    MOV R1, R0            # Move kph result (from R0) to R1 for printf
    LDR R0, =result_kph   # Load address of result string
    SWI 0x6B              # Call printf

    # --- Celsius to Fahrenheit Conversion ---
    # Prompt for Celsius
    LDR R0, =prompt_celsius # Load address of prompt string
    SWI 0x6B                # Call printf

    # Read Celsius
    LDR R0, =fmt_int        # Load address of format string "%d"
    LDR R1, =celsius_val    # Load address of celsius_val variable
    SWI 0x69                # Call scanf

    # Call CToF function
    LDR R0, =celsius_val    # Load address of celsius_val
    LDR R0, [R0]            # Load celsius value into R0
    BL CToF                 # Call CToF (result in R0)

    # Print Fahrenheit result
    MOV R1, R0              # Move Fahrenheit result (from R0) to R1 for printf
    LDR R0, =result_fahrenheit # Load address of result string
    SWI 0x6B                # Call printf

    # --- Inches to Feet Conversion ---
    # Prompt for Inches
    LDR R0, =prompt_inches # Load address of prompt string
    SWI 0x6B               # Call printf

    # Read Inches
    LDR R0, =fmt_int       # Load address of format string "%d"
    LDR R1, =inches_val    # Load address of inches_val variable
    SWI 0x69               # Call scanf

    # Call InchesToFt function
    LDR R0, =inches_val    # Load address of inches_val
    LDR R0, [R0]           # Load inches value into R0
    BL InchesToFt          # Call InchesToFt (result in R0)

    # Print Feet result
    MOV R1, R0             # Move feet result (from R0) to R1 for printf
    LDR R0, =result_feet   # Load address of result string
    SWI 0x6B               # Call printf

    # --- Exit the program ---
    POP {LR} # Restore Link Register
    MOV R7, #0x11 # System call number for exit (common in some simulators)
    SWI 0         # Execute system call

.data
    # Format strings for printf
    prompt_miles:     .asciz "Enter miles: "
    prompt_hours:     .asciz "Enter hours: "
    result_kph:       .asciz "Kilometers per hour: %d\n"
    prompt_celsius:   .asciz "Enter Celsius temperature: "
    result_fahrenheit: .asciz "Fahrenheit temperature: %d\n"
    prompt_inches:    .asciz "Enter inches: "
    result_feet:      .asciz "Feet: %d\n"

    # Format string for scanf (reading an integer)
    fmt_int:          .asciz "%d"

    # Variables to store input values
    miles_val:        .word 0
    hours_val:        .word 0
    celsius_val:      .word 0
    inches_val:       .word 0