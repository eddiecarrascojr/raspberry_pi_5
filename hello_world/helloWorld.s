// Assembly for 64-bit ARM Linux

.data
greeting: .ascii "Hello World\n"

.text
.global _start
_start:

    //Print the greeting message to the terminal

    ldr x1, =greeting // Load the location in memory of the greeting message into register x1
    mov x2, #12       // Store the length of the greeting message into register x2 (it's 12 bytes long)
    mov x0, #1        // Load 1 into register x0. This tells the write syscall to send the greeting to stdout (the terminal)
    mov w8, #64       // The write syscall is number 64. This is placed into the w8 register 
    svc #0            // Tell Linux to run the syscall

    // Exit cleanly from the program by setting the exit status

    mov x0, #0        // Set the program exit status to 0 (set in the x0 register). Zero means the program ran correctly.
    mov w8, #93       // Exit is syscall number 93 which is placed into the w8 register
    svc #0            // Tell Linux to run the syscall