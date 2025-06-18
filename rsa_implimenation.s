@ Filename: rsa_demo.s
@ Author: Gemini
@ Date: June 2025
@ Description: A simplified demonstration of RSA encryption and decryption
@              using ARM Assembly. This program uses small, hardcoded
@              numbers to illustrate the modular exponentiation principle.
@              It is NOT a cryptographically secure implementation.
@
@ Key Components:
@ 1. Pre-defined RSA parameters (p, q, n, phi_n, e, d)
@ 2. Modular Exponentiation function (power_mod)
@ 3. Encryption and Decryption steps
@
@ NOTE: This code assumes a generic ARMv7-A architecture (e.g., Cortex-A series).
@       It does not handle user input or dynamic key generation.
@       The results (encrypted/decrypted message) are stored in memory
@       and can be inspected using a debugger.

.global _start

.data
    @ RSA Parameters (small, hardcoded for demonstration)
    @ p = 3, q = 11
    p:      .word   3
    q:      .word   11
    n:      .word   33      @ n = p * q
    phi_n:  .word   20      @ phi(n) = (p-1)*(q-1) = 2*10 = 20

    @ Public Key (e, n)
    e:      .word   7       @ e = 7 (coprime to phi_n)
    pub_key_n: .word 33     @ n

    @ Private Key (d, n)
    d:      .word   3       @ d = 3 (since (7 * 3) mod 20 = 21 mod 20 = 1)
    priv_key_n: .word 33    @ n

    @ Message to encrypt (hardcoded numerical value)
    @ For simplicity, we use a single number instead of a string.
    @ Let's encrypt the number 4.
    message:        .word   4

    @ Variables to store results
    encrypted_msg:  .word   0
    decrypted_msg:  .word   0

.text
_start:
    @ ==========================================
    @ 1. Prepare values for Encryption
    @    M = message (r0)
    @    E = e       (r1)
    @    N = n       (r2)
    @ ==========================================
    ldr r0, message      @ Load message into r0 (Base)
    ldr r1, e            @ Load encryption exponent (e) into r1 (Exponent)
    ldr r2, n            @ Load modulus (n) into r2 (Modulus)

    @ Call modular exponentiation function for encryption
    bl power_mod         @ Call power_mod(r0, r1, r2). Result in r0.

    @ Store the encrypted message
    str r0, encrypted_msg @ Save the encrypted message

    @ ==========================================
    @ 2. Prepare values for Decryption
    @    C = encrypted_msg (r0)
    @    D = d             (r1)
    @    N = n             (r2)
    @ ==========================================
    ldr r0, encrypted_msg @ Load encrypted message into r0 (Base)
    ldr r1, d             @ Load decryption exponent (d) into r1 (Exponent)
    ldr r2, n             @ Load modulus (n) into r2 (Modulus)

    @ Call modular exponentiation function for decryption
    bl power_mod          @ Call power_mod(r0, r1, r2). Result in r0.

    @ Store the decrypted message
    str r0, decrypted_msg @ Save the decrypted message

    @ ==========================================
    @ 3. Program End (Infinite Loop)
    @    In a real system, you might exit via a syscall or return.
    @    For a simple embedded or simulator environment, an infinite loop
    @    prevents the program from crashing and allows inspection of memory.
    @ ==========================================
end_loop:
    b end_loop

@ -----------------------------------------------------------------------------
@ Function: power_mod(base, exp, mod)
@ Description: Computes (base ^ exp) % mod using binary exponentiation.
@              This is an efficient method for modular exponentiation.
@
@ Parameters:
@   r0: base
@   r1: exponent (exp)
@   r2: modulus (mod)
@
@ Returns:
@   r0: result of (base ^ exp) % mod
@
@ Registers used:
@   r0: base (also used for result)
@   r1: exponent
@   r2: modulus
@   r3: temporary for base_squared
@   r4: result accumulator (res)
@
@ Preserves: none (r0-r3 are volatile in AAPCS, r4 is callee-saved but not used outside this function)
@ -----------------------------------------------------------------------------
power_mod:
    @ Save context if this were a more complex function or following strict ABI
    @ push {r4, lr} @ push r4 (callee-saved) and link register

    mov r4, #1          @ Initialize result (res) to 1 (r4 = 1)
    mov r3, r0          @ Copy base to r3 (temp for squaring, r3 = base)
    and r3, r2          @ r3 = base % mod (initial base value)
    mov r0, r3          @ Move initial (base % mod) back to r0

power_loop:
    cmp r1, #0          @ Compare exp with 0
    beq power_exit      @ If exp == 0, exit loop

    and r3, r1, #1      @ Check if exp is odd (r1 & 1)
    cmp r3, #1
    bne exp_is_even     @ If exp is even, skip multiplication with res

    @ If exp is odd: res = (res * base) % mod
    mul r4, r4, r0      @ r4 = res * base
    sdiv r3, r4, r2     @ r3 = (res * base) / mod (for remainder)
    mla r4, r3, r2, r4  @ r4 = r4 - (r3 * r2) (i.e., r4 = (res * base) % mod)
    @ The above two lines can be replaced with a single instruction if available (e.g., UMAAL on some architectures for larger numbers)
    @ or a more explicit modulo operation if division is complex.
    @ For simplicity, using sdiv/mla for integer modulo.

exp_is_even:
    @ base = (base * base) % mod
    mul r0, r0, r0      @ r0 = base * base
    sdiv r3, r0, r2     @ r3 = (base * base) / mod
    mla r0, r3, r2, r0  @ r0 = r0 - (r3 * r2) (i.e., r0 = (base * base) % mod)

    lsr r1, r1, #1      @ exp = exp / 2 (right shift by 1)
    b power_loop        @ Continue loop

power_exit:
    mov r0, r4          @ Move final result from r4 to r0 (return value)
    @ pop {r4, pc}      @ Restore r4 and return (pop pc loads lr into pc)
    bx lr               @ Return from function (using lr)

