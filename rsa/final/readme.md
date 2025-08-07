# Running and compiling the RSA library
as -o rsa_library.o rsa_library.s
as -o rsa_main.o rsa_main.s
gcc -o rsa rsa_main.o rsa_library.o