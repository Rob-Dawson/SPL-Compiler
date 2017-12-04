#SPL Compiler
------------

Included Files
--------------
This zip file contains the BNF text file for the SPL language and 
the respective flex, bison and C files to build the compiler.

Test results for the compiler are also included.

File Names
----------
bnf.file
spl.l
spl.y
spl.c
results.txt
b.spl (Sample Program in SPL)

Optimisations
-------------
Within for-loops, the TO section has been optimised to include, 
for example "a += 1;" instead of "a = a + 1;".

Assumptions
-----------
The IF NOT statement in SPL is ambiguous, does it mean the identifier 
is false or the statement is false?

E.g. IF NOT a = 7 THEN

I came to the assumption that if a NOT token precedes an identifier, 
the compiler would generate the C code as if the entire statement was false.

i.e.
input: IF NOT A = 7 THEN
output: if(!(A == 7)){}
