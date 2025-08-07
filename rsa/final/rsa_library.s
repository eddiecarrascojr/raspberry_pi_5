@ =============================================================================
@ Description:
@ This file contains the core functions for the RSA algorithm. It is intended
@ to be assembled separately and linked with a main program.
@ =============================================================================

.text
.global is_prime, gcd, cpubexp, cprivexp, encrypt, decrypt


@ =============================================================================
@ is_prime: Checks if a number in r0 is prime.
@ =============================================================================
is_prime:
    push {r3, lr}
    mov r1, r0
    cmp r1, #1
    ble .L_not_prime
    cmp r1, #3
    ble .L_is_prime

    mov r2, r1
    mov r3, #2
    udiv r0, r2, r3
    mul r0, r3, r0
    cmp r0, r2
    beq .L_not_prime

    mov r3, #3
    udiv r0, r2, r3
    mul r0, r3, r0
    cmp r0, r2
    beq .L_not_prime

    mov r2, #5
.L_prime_loop:
    mul r3, r2, r2
    cmp r3, r1
    bgt .L_is_prime

    udiv r0, r1, r2
    mul r0, r2, r0
    cmp r0, r1
    beq .L_not_prime

    add r3, r2, #2
    udiv r0, r1, r3
    mul r0, r3, r0
    cmp r0, r1
    beq .L_not_prime

    add r2, r2, #6
    b .L_prime_loop

.L_is_prime:
    mov r0, #1
    pop {r3, pc}

.L_not_prime:
    mov r0, #0
    pop {r3, pc}

@ =============================================================================
@ gcd: Calculates the greatest common divisor of two numbers.
@ =============================================================================
gcd:
    push {r3, lr}
.L_gcd_loop:
    cmp r1, #0
    beq .L_gcd_end
    sdiv r2, r0, r1
    mls r3, r2, r1, r0
    mov r0, r1
    mov r1, r3
    b .L_gcd_loop
.L_gcd_end:
    pop {r3, pc}

@ =============================================================================
@ extended_gcd: Extended Euclidean Algorithm to find modular inverse.
@ =============================================================================
extended_gcd:
    push {r4-r10, lr}
    mov r4, r0
    mov r5, r1

    mov r6, #0
    mov r7, #1
    mov r8, #1
    mov r9, #0

.L_ext_gcd_loop:
    cmp r5, #0
    beq .L_ext_gcd_end

    sdiv r10, r4, r5
    mls r3, r10, r5, r4
    mov r4, r5
    mov r5, r3

    mul r2, r10, r7
    sub r2, r9, r2
    mov r9, r7
    mov r7, r2

    mul r2, r10, r6
    sub r2, r8, r2
    mov r8, r6
    mov r6, r2
    
    b .L_ext_gcd_loop

.L_ext_gcd_end:
    mov r0, r9
    cmp r0, #0
    bge .L_d_positive
    add r0, r0, r1

.L_d_positive:
    pop {r4-r10, pc}

@ =============================================================================
@ mod_pow: Performs modular exponentiation (base^exp % mod).
@ This function serves as the implementation for both 'pow' and 'modulo'.
@ =============================================================================
mod_pow:
    push {r3, r4-r7, lr}
    mov r4, r0
    mov r5, r1
    mov r6, r2
    mov r7, #1

    sdiv r0, r4, r6
    mls r4, r0, r6, r4

.L_mod_pow_loop:
    cmp r5, #0
    ble .L_mod_pow_end

    tst r5, #1
    beq .L_mod_pow_skip_mul

    mul r0, r7, r4
    sdiv r1, r0, r6
    mls r7, r1, r6, r0

.L_mod_pow_skip_mul:
    lsr r5, r5, #1

    mul r0, r4, r4
    sdiv r1, r0, r6
    mls r4, r1, r6, r0

    b .L_mod_pow_loop

.L_mod_pow_end:
    mov r0, r7
    pop {r3, r4-r7, pc}

@ =============================================================================
@ cpubexp: Validates the public key exponent e.
@   - r0: e (the candidate public exponent)
@   - r1: phi_n
@   Returns:
@   - r0: 0 on success, or a non-zero error code.
@         1: e <= 1
@         2: e >= phi_n
@         3: gcd(e, phi_n) != 1
@ =============================================================================
cpubexp:
    push {r4, r5, lr}
    mov r4, r0          @ r4 = e
    mov r5, r1          @ r5 = phi_n

    @ Check 1: e > 1
    cmp r4, #1
    movle r0, #1        @ Set error code 1 if e <= 1
    ble .L_cpubexp_end

    @ Check 2: e < phi_n
    cmp r4, r5
    movge r0, #2        @ Set error code 2 if e >= phi_n
    bge .L_cpubexp_end

    @ Check 3: gcd(e, phi_n) == 1
    mov r0, r4
    mov r1, r5
    bl gcd
    cmp r0, #1
    movne r0, #3        @ Set error code 3 if gcd is not 1
    bne .L_cpubexp_end

    @ Success
    mov r0, #0

.L_cpubexp_end:
    pop {r4, r5, pc}

@ =============================================================================
@ cprivexp: Sub-routine for private key exponent (d) calculation.
@ =============================================================================
cprivexp:
    push {r3, lr}
    bl extended_gcd
    pop {r3, pc}

@ =============================================================================
@ encrypt: Sub-routine for encryption. C = M^e mod n
@ =============================================================================
encrypt:
    push {r3, lr}
    bl mod_pow
    pop {r3, pc}

@ =============================================================================
@ decrypt: Sub-routine for decryption. m = c^d mod n
@ =============================================================================
decrypt:
    push {r3, lr}
    bl mod_pow
    pop {r3, pc}
