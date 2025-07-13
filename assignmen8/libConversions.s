# Global functions for conversions
.global miles2kilometer
.global kph
.global CToF
.global InchesToFt

.text
# miles2kilometer(int miles)
# Converts miles to kilometers.
# Returns the result in R0.
miles2kilometer:
    # Converstion factor: 1 mile = 1.61 kilometers
    # R0 = miles
    # R1 = 161 (1 mile = 161/100 kilometers)
    # Convert miles to kilometers

    # Push the stack
    SUB SP, SP, #4
    # Save Link Register on stack
    STR lr, [SP]        

    MOV R1, #161      # R1 = 161 1 mile = 1.61 kilometers or 1 mile = 161/100 kilometers
    MUL R0, R0, R1    # R0 = miles * 161
    MOV R1, #100      # R1 = 100
    UDIV R0, R0, R1
    

    # push the stack
    LDR lr, [SP]
    ADD SP, SP, #4
    MOV pc, lr
    # End of miles2kilometer function

# kph(int hours, int miles)
# Calculates kilometers per hour from miles and hours.
# Returns the result in R0.
kph:
    # Converts miles to kilometers and divides by hours
    # R0 = hours
    # R1 = miles
    # R0 will hold the result (kph)
    # R1 will hold the kilometers after conversion

        # Push the stack
        SUB SP, SP, #4
        # Save Link Register on stack
        STR lr, [SP]  

    MOV R0, R1        # Move miles (from R1) to R0 for miles2kilometer call
    BL miles2kilometer # Call miles2kilometer function
    MOV R1, R0        # Move kilometers (from R0) to R1
    POP {R0, LR}      # Restore original R0 (hours) and Link Register
    # Change from UDIV to __aeabi_idiv to avoid issues with ARMv8
    UDIV R0, R1, R0   # R0 = kilometers / hours
    
    # push the stack
    LDR lr, [SP]
    ADD SP, SP, #4
    MOV pc, lr

# Celsius to Fahrenheit conversion
# CToF(int celsius)
# Converts Celsius to Fahrenheit.
CToF:
    # Fahrenheit = (Celsius * 9 / 5) + 32
    # R0 = celsius
    # R1 = 9
    # R2 = 5
    # R0 will hold the result (Fahrenheit)
    
    # Push the stack
    SUB SP, SP, #4
    STR lr, [SP]

    MOV R1, #9        # R1 = 9
    MUL R0, R0, R1    # R0 = celsius * 9
    MOV R1, #5        # R1 = 5
    SDIV R0, R0, R1   # R0 = (celsius * 9) / 5
    ADD R0, R0, #32   # R0 = R0 + 32
    
    # push the stack
    LDR lr, [SP]
    ADD SP, SP, #4
    MOV pc, lr

# InchesToFt(int inches)
# Converts inches to feet.
InchesToFt:
    # R0 = inches
    # R1 = 12
    # R0 will hold the result (feet)

    # Push the stack
    SUB SP, SP, #4
    STR lr, [SP]

    MOV R1, #12       # R1 = 12
    SDIV R0, R0, R1   # R0 = inches / 12
    
    # push the stack
    LDR lr, [SP]
    ADD SP, SP, #4
    MOV pc, lr

.data
# End of libConversions.s