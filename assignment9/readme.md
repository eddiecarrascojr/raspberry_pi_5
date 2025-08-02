# Homework assignment 9
This is a simple readme.md for Assignment 9 for Computer Organization.
 - By Eduardo Carrasco Jr
 - 7/18/25
## Screenshots 

Each screenshot should be named as q1a.jpg, a1b.jpg q2.jpg, q3.jpg

### Question 1.
A) the program **isAlpha.s** checks if a character is alphabetic. The returns yes or no if the character is alpha or not. Uses logical operations.

B) the program **isAlphav2.s** checks if a character is alphabetic. This version does not use logical operations.

### Question 2.

The program **gpa.s** checks if:
- Prompt for a name and an average.
- If the average is <0 or >100,  print an error
- Else calculate a grade as 90-100 as A, 80-90 as B, 70-80 as C, else F.
- Print out the student's name and grade.


### Question 3.
The program **findMax.s** finds the max of three arguments. Then prints out the max value.


## Running and Compiling

compile each program with:
- as -o **program.o** **program.s** 
- ld -o **program** **program.o** 
- **./program**