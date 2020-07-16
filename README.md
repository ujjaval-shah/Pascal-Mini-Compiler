# Pascal MINI compiler

A Basic Pascal language Compiler made as a course project of *Compilers Course CS327* (IITGN). Taking the input a ".pas" file creates executables MIPS assembly code - "asmb.asm". Can be run with *MARS MIPS Simulator*.

## Command to Compile the compiler 😂


```bash
clear
rm lex.yy.c calc.tab.c calc.tab.h a.out
bison --debug -d calc.y
flex --debug tok.l
gcc calc.tab.c lex.yy.c -lfl
```

## Using Pascal MINI compiler to compile a Pascal program

```bash
./a.out<TestCodes/filename.pas
```

## Some programs the compiler can compile

Pic1

![alt text](PicsForReadME/zz1.png)

Pic2

![alt text](PicsForReadME/zz2.png)

Pic3

![alt text](PicsForReadME/zz3.png)
