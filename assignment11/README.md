# Homework assignment 11
## Screenshots 

Each screenshot should be named as multiplication_recursion.jpg and fibnonaci.jpg.

### Question 1. Multiplication using recursion

Implement a program that accepts two user inputted numbers.  The first being the multiplier (m).  The second being the number of successive addition iterations (n).  Next calculate multiplication using successive addition with recursion. For example, 5x4 is 5+5+5+5.  This can be defined recursively as:
            Mult(m, n) = if n is 1,  return m
            else return m + Mult(m, n-1)

The program that handles this question is named **recursion_multi.s** and should be compiled with the command:

```bash
gcc -o recursion_multi recursion_multi.s
./recursion_multi

```

### Question 2.

Implement a program to calculate a Fibonacci number recursively.  The program should accept user input (n) to find the Fibonacci number.
A Fibonacci number is defined mathematically as:
        F(n) = F(n-1) + F(n-2)  
        where n>=0, F(0)=0, F(1)=1

The program that handles this question is named **fibonacci_recusively.s** and should be compiled with the command:

```bash
gcc -o fibonacci_recusively fibonacci_recusively.s
./fibonacci_recusively

```
