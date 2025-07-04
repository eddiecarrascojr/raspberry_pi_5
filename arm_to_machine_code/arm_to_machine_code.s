# Program Name: arm_to_machine_code.s
# Author: Eduardo Carrasco Jr
# Date: 07/05/2025
# Purpose: Converts ARM assembly instructions to their corresponding machine code
#
# Inputs: 
#   None: just simple ARM instructions into machine code
#
# Outputs:
#   - r0 as ARM Assembly instructions
#   - r0 machine code values
#

# To compile and run (on a Linux ARM system or cross-compile):
#   arm-linux-gnueabihf-as -g arm_machine_code_display.s -o arm_machine_code_display.o
#   arm-linux-gnueabihf-ld arm_machine_code_display.o -o arm_machine_code_display
#   ./arm_machine_code_display
#


# To observe the values in r0, you would typically use a debugger like GDB:
#   arm-linux-gnueabihf-gdb arm_machine_code_display
#   (gdb) start
#   (gdb) # Set breakpoints at each 'ldr r0, [r1]' instruction to see the values
#   (gdb) b *(_start + offset_to_ldr_r0)
#   (gdb) continue
#   (gdb) info registers r0
#   (gdb) continue
#   ... and so on.

.global _start          # Declare _start as a global symbol, making it the entry point

.data                   # Data section - Contains the 32-bit machine code values

machine_code_mov_r1_r2:
    .word 0xE1A01002    # mov r1, r2

machine_code_mov_r3_imm7:
    .word 0xE3A03007    # mov r3, #7

machine_code_add_r7_r3_imm5:
    .word 0xE2837005    # add r7, r3, #5

machine_code_sub_r8_r6_r3:
    .word 0xE0468003    # sub r8, r6, r3

machine_code_mul_r3_r4_r5:
    .word 0xE0030495    # mul r3, r4, r5

machine_code_lsl_r1_r2_r3:
    .word 0xE1A01312    # lsl r1, r2, r3

machine_code_asr_r2_r3_r4:
    .word 0xE1A02453    # asr r2, r3, r4

machine_code_ldr_r1_r2_no_offset:
    .word 0xE5921000    # ldr r1, [r2]

machine_code_ldr_r2_r0_imm4:
    .word 0xE5902004    # ldr r2, [r0, #4]

machine_code_str_r1_r2_r3:
    .word 0xE7821003    # str r1, [r2, r3]


.text                   # Code section
_start:
    # Load and display machine code for 'mov r1, r2' (0xE1A01002)
    ldr r1, =machine_code_mov_r1_r2
    ldr r0, [r1]        # r0 now holds 0xE1A01002

    # Load and display machine code for 'mov r3, #7' (0xE3A03007)
    ldr r1, =machine_code_mov_r3_imm7
    ldr r0, [r1]        # r0 now holds 0xE3A03007

    # Load and display machine code for 'add r7, r3, #5' (0xE2837005)
    ldr r1, =machine_code_add_r7_r3_imm5
    ldr r0, [r1]        # r0 now holds 0xE2837005

    # Load and display machine code for 'sub r8, r6, r3' (0xE0468003)
    ldr r1, =machine_code_sub_r8_r6_r3
    ldr r0, [r1]        # r0 now holds 0xE0468003

    # Load and display machine code for 'mul r3, r4, r5' (0xE0030495)
    ldr r1, =machine_code_mul_r3_r4_r5
    ldr r0, [r1]        # r0 now holds 0xE0030495

    # Load and display machine code for 'lsl r1, r2, r3' (0xE1A01312)
    ldr r1, =machine_code_lsl_r1_r2_r3
    ldr r0, [r1]        # r0 now holds 0xE1A01312

    # Load and display machine code for 'asr r2, r3, r4' (0xE1A02453)
    ldr r1, =machine_code_asr_r2_r3_r4
    ldr r0, [r1]        # r0 now holds 0xE1A02453

    # Load and display machine code for 'ldr r1, [r2]' (0xE5921000)
    ldr r1, =machine_code_ldr_r1_r2_no_offset
    ldr r0, [r1]        # r0 now holds 0xE5921000

    # Load and display machine code for 'ldr r2, [r0, #4]' (0xE5902004)
    ldr r1, =machine_code_ldr_r2_r0_imm4
    ldr r0, [r1]        # r0 now holds 0xE5902004

    # Load and display machine code for 'str r1, [r2, r3]' (0xE7821003)
    ldr r1, =machine_code_str_r1_r2_r3
    ldr r0, [r1]        # r0 now holds 0xE7821003

    # --- Program Exit (Linux ARM syscall) ---
    # This section performs a clean exit for a program running under a Linux-like OS.
    mov r7, #1          @ Set r7 (or r8 depending on EABI) to the syscall number for exit (1)
    mov r0, #0          @ Set r0 to the exit code (0 for success)
    svc #0              @ Invoke the supervisor call (syscall)
                        @ This transfers control to the operating system kernel to terminate the process.
