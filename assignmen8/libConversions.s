.global miles2kilometer
.global kph
.global CToF
.global InchesToFt

.text

miles2kilometer:
    # Convert miles to kilometers
    MOV R1, #161      # R1 = 161 1 mile = 1.61 kilometers or 1 mile = 161/100 kilometers
    MUL R0, R0, R1    # R0 = miles * 161
    MOV R1, #100      # R1 = 100
    UDIV R0, R0, R1
    BX LR

kph:
    PUSH {R1, LR}     # Save R1 (miles) and Link Register
    MOV R0, R1        # Move miles (from R1) to R0 for miles2kilometer call
    BL miles2kilometer # Call miles2kilometer function
    MOV R1, R0        # Move kilometers (from R0) to R1
    POP {R0, LR}      # Restore original R0 (hours) and Link Register
    UDIV R0, R1, R0   # R0 = kilometers / hours
    BX LR             # Return


CToF:
    # Fahrenheit = (Celsius * 9 / 5) + 32
    MOV R1, #9        # R1 = 9
    MUL R0, R0, R1    # R0 = celsius * 9
    MOV R1, #5        # R1 = 5
    SDIV R0, R0, R1   # R0 = (celsius * 9) / 5
    ADD R0, R0, #32   # R0 = R0 + 32
    BX LR             # Return

# InchesToFt(int inches)
# Converts inches to feet.
# R0: inches (input)
# Returns: feet in R0
InchesToFt:
    # Feet = Inches / 12
    MOV R1, #12       # R1 = 12
    SDIV R0, R0, R1   # R0 = inches / 12
    BX LR             # Return
