    .arch armv7-a
    .fpu    vfpv3-d16

    .data
p_prompt:      .asciz "Enter prime p (<50): "
q_prompt:      .asciz "Enter prime q (<50): "
e_prompt:      .asciz "Enter public exponent e: "
error_msg:     .asciz "Error: invalid input. Exiting.\n"
input_fmt:     .asciz "%d"
fmt_pq:        .asciz "p=%d, q=%d\n"
fmt_nphi:      .asciz "n=%d, phi=%d\n"
fmt_ed:        .asciz "e=%d, d=%d\n"

    .bss
    .align  4
p_var:   .skip 4
q_var:   .skip 4
n_var:   .skip 4
phi_var: .skip 4
e_var:   .skip 4
d_var:   .skip 4

    .text
    .global main
    .extern printf, scanf

/* ----------------------------------------
   MAIN
   ---------------------------------------- */
main:
    push    {lr}

    /* --- read p --- */
    ldr     r0, =p_prompt
    bl      printf
    ldr     r0, =input_fmt
    ldr     r1, =p_var
    bl      scanf

    /* --- read q --- */
    ldr     r0, =q_prompt
    bl      printf
    ldr     r0, =input_fmt
    ldr     r1, =q_var
    bl      scanf

    /* load p into r0, q into r1 */
    ldr     r0, =p_var
    ldr     r0, [r0]
    cmp     r0, #50
    bge     invalid
    ldr     r1, =q_var
    ldr     r1, [r1]
    cmp     r1, #50
    bge     invalid

    /* is_prime(p) */
    ldr     r0, =p_var
    ldr     r0, [r0]
    bl      is_prime
    cmp     r0, #1
    bne     invalid

    /* is_prime(q) */
    ldr     r0, =q_var
    ldr     r0, [r0]
    bl      is_prime
    cmp     r0, #1
    bne     invalid

    /* n = p * q */
    ldr     r0, =p_var
    ldr     r0, [r0]
    ldr     r1, =q_var
    ldr     r1, [r1]
    mul     r2, r0, r1
    ldr     r3, =n_var
    str     r2, [r3]

    /* phi = (p-1)*(q-1) */
    sub     r0, r0, #1
    sub     r1, r1, #1
    mul     r2, r0, r1
    ldr     r3, =phi_var
    str     r2, [r3]

    /* prompt & read e */
    ldr     r0, =e_prompt
    bl      printf
    ldr     r0, =input_fmt
    ldr     r1, =e_var
    bl      scanf

    /* r0 = e, r1 = phi; validate/pick via cpubexp */
    ldr     r0, =e_var
    ldr     r0, [r0]
    ldr     r1, =phi_var
    ldr     r1, [r1]
    bl      cpubexp
    /* store validated e */
    ldr     r1, =e_var
    str     r0, [r1]

    /* compute private exponent d = cprivexp(e, phi) */
    ldr     r0, =e_var
    ldr     r0, [r0]
    ldr     r1, =phi_var
    ldr     r1, [r1]
    bl      cprivexp
    /* store d */
    ldr     r1, =d_var
    str     r0, [r1]

    /* --- print results --- */
    /* p, q */
    ldr     r0, =fmt_pq
    ldr     r1, =p_var
    ldr     r1, [r1]
    ldr     r2, =q_var
    ldr     r2, [r2]
    bl      printf

    /* n, phi */
    ldr     r0, =fmt_nphi
    ldr     r1, =n_var
    ldr     r1, [r1]
    ldr     r2, =phi_var
    ldr     r2, [r2]
    bl      printf

    /* e, d */
    ldr     r0, =fmt_ed
    ldr     r1, =e_var
    ldr     r1, [r1]
    ldr     r2, =d_var
    ldr     r2, [r2]
    bl      printf

    /* exit cleanly */
    mov     r0, #0
    pop     {pc}

invalid:
    ldr     r0, =error_msg
    bl      printf
    mov     r0, #1
    pop     {pc}

/* ----------------------------------------
   FUNCTION: is_prime(n) → r0 = 1 if prime, 0 otherwise
   uses Euclidean division via UDIV
   ---------------------------------------- */
    .global is_prime
is_prime:
    push    {lr}
    cmp     r0, #2
    blt     not_prime
    mov     r1, #2       @ divisor
prime_loop:
    cmp     r1, r0
    beq     prime_yes    @ reached n → prime
    udiv    r2, r0, r1   @ q = n / div
    mul     r3, r2, r1   @ q*div
    sub     r3, r0, r3   @ rem = n - q*div
    cmp     r3, #0
    beq     not_prime    @ divisible
    add     r1, r1, #1
    b       prime_loop
prime_yes:
    mov     r0, #1
    pop     {pc}
not_prime:
    mov     r0, #0
    pop     {pc}

/* ----------------------------------------
   FUNCTION: gcd(a,b) → r0 = gcd(a,b)
   Euclid’s algorithm
   ---------------------------------------- */
    .global gcd
gcd:
    push    {lr}
    cmp     r1, #0
    beq     gcd_done
gcd_loop:
    udiv    r2, r0, r1   @ q = a / b
    mul     r3, r2, r1   @ q*b
    sub     r3, r0, r3   @ r = a % b
    mov     r0, r1       @ a = b
    mov     r1, r3       @ b = r
    cmp     r1, #0
    bne     gcd_loop
gcd_done:
    @ r0 holds gcd
    pop     {pc}

/* ----------------------------------------
   FUNCTION: cpubexp(e, phi)
   Validate e; if invalid, scan upward until
   1<e<phi and gcd(e,phi)==1
   → r0 = chosen e
   ---------------------------------------- */
    .global cpubexp
cpubexp:
    push    {lr}
    mov     r2, r0       @ candidate e in r2
    mov     r3, r1       @ phi in r3
validate_e:
    cmp     r2, #2
    ble     next_e
    cmp     r2, r3
    bge     next_e
    mov     r0, r2
    mov     r1, r3
    bl      gcd
    cmp     r0, #1
    beq     done_e
next_e:
    add     r2, r2, #1
    b       validate_e
done_e:
    mov     r0, r2
    pop     {pc}

/* ----------------------------------------
   FUNCTION: cprivexp(e, phi)
   Find d = (1 + x*phi)/e  such that integer.
   Brute x = 1,2,…
   → r0 = d
   ---------------------------------------- */
    .global cprivexp
cprivexp:
    push    {lr}
    mov     r2, #1       @ x = 1
    mov     r4, #0       @ temp
priv_loop:
    mul     r4, r1, r2   @ r4 = phi * x
    add     r4, r4, #1   @ r4 = 1 + phi*x
    udiv    r5, r4, r0   @ q = r4 / e
    mul     r6, r5, r0   @ q*e
    sub     r6, r4, r6   @ rem = r4 - q*e
    cmp     r6, #0
    beq     done_d
    add     r2, r2, #1   @ x++
    b       priv_loop
done_d:
    mov     r0, r5       @ d = quotient
    pop     {pc}
