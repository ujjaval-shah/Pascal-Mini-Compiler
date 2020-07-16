.data

string0:  .asciiz  "ENTER_A_NUMBER_TO_REVERSE"
string1:  .asciiz  "THIS_IS_THE_REVERSE"

.text
li $t8,268502192
li $t0, 0
sw $t0,8($t8)


li $v0,4 
la $a0, string0
syscall

li $a0,10
li $v0,11
syscall

li $v0, 5
syscall
move $t0, $v0
sw $t0,4($t8)

li $t0, 1
sw $t0,20($t8)


LabStartWhile0:lw $t0, 20($t8)
li $t1, 1

bne $t0, $t1, NextPart0
lw $t0, 4($t8)
li $t1, 10
div $t0, $t0, $t1
sw $t0,12($t8)

lw $t0, 12($t8)
li $t1, 10
mul $t0, $t0, $t1
sw $t0,24($t8)

lw $t0, 8($t8)
li $t1, 10
mul $t0, $t0, $t1
sw $t0,8($t8)

lw $t0, 4($t8)
lw $t1, 24($t8)
sub $t0, $t0, $t1
sw $t0,16($t8)

lw $t0, 8($t8)
lw $t1, 16($t8)
add $t0, $t0, $t1
sw $t0,8($t8)

lw $t0, 12($t8)
sw $t0,4($t8)


li $t0, 0
move $t1, $t0
lw $t0, 12($t8)

bne $t0, $t1, EndIf0
li $t0, 0
sw $t0,20($t8)


EndIf0:j LabStartWhile0
NextPart0:

li $v0,4 
la $a0, string1
syscall

li $a0,10
li $v0,11
syscall

lw $t0, 8($t8)
li $v0,1
move $a0,$t0
syscall
li $a0,10
li $v0,11
syscall
