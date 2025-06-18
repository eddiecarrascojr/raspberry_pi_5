# --- ARM Assembly Program: Celsius to Fahrenheit Converter ---
#
# This program converts a temperature from degrees Celsius to Fahrenheit.
# Formula: F = (C * 9 / 5) + 32
#
# Input:
#   r0: Celsius temperature (integer)
#
# Output:
#   r1: Fahrenheit temperature (integer)
#
.text
.global celsius_to_fahrenheit

celsius_to_fahrenheit:
    # Save Link Register if calling other functions, not needed here
    # PUSH {LR}

    # r0 contains Celsius temperature (C)
    # F = (C * 9)
    MUL r1, r0, #9      # r1 = C * 9

    # F = (C * 9) / 5
    SDIV r1, r1, #5      # r1 = (C * 9) / 5 (Signed Division)

    # F = ((C * 9) / 5) + 32
    ADD r1, r1, #32     # r1 = F + 32

    # Return from function
    # POP {LR}
    BX LR               # Branch to the address in the Link Register


# --- ARM Assembly Program: Fahrenheit to Celsius Converter ---
#
# This program converts a temperature from degrees Fahrenheit to Celsius.
# Formula: C = (F - 32) * 5 / 9
#
# Input:
#   r0: Fahrenheit temperature (integer)
#
# Output:
#   r1: Celsius temperature (integer)
#
.text
.global fahrenheit_to_celsius

fahrenheit_to_celsius:
    # Save Link Register if calling other functions, not needed here
    # PUSH {LR}

    # r0 contains Fahrenheit temperature (F)
    # C = (F - 32)
    SUB r1, r0, #32     # r1 = F - 32

    # C = (F - 32) * 5
    MUL r1, r1, #5      # r1 = (F - 32) * 5

    # C = ((F - 32) * 5) / 9
    SDIV r1, r1, #9      # r1 = ((F - 32) * 5) / 9 (Signed Division)

    # Return from function
    # POP {LR}
    BX LR               # Branch to the address in the Link Register
