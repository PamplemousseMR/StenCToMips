.data
    var_0: .word 10
    var_1: .word 20
    string: .asciiz "\n"

#####

.globl main

#####

.text

main :
    #get int
    li $v0 8
    sll $a0 $v0 2 #number of bytes now in $a0
    li  $v0 9
    syscall 

    move $v1 $v0
 

    lw $t0 var_0
    sw $t0 0($v1)
    lw $t1 0($v1)

    move $a0 $t1
    li $v0 1
    syscall
    la $a0 string
    li  $v0 4
    syscall
    
    ###########
    
    lw $t0 var_1
    sw $t0 4($v1)
    lw $t1 4($v1)

    move $a0 $t1
    li $v0 1
    syscall
    la $a0 string
    li  $v0 4
    syscall
    
    ###########

    lw $t1 0($v1)

    move $a0 $t1
    li $v0 1
    syscall
    la $a0 string
    li  $v0 4
    syscall
    
    ###########
    
    la $t0 4($v1)
    sw $t0 0($v1)
    lw $t1 0($v1)
    lw $t1 0($t1)
    
    move $a0 $t1
    li $v0 1
    syscall
    la $a0 string
    li  $v0 4
    syscall
 
    j Exit

#####

Exit :

    li $v0 10
    syscall