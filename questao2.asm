.data
string1: .space 100 # 100 caracteres
string2: .space 99 # 99 caracteres

.text
.globl main

main:
    # t0 <- string1
    # t1 <- string2
    # t3 <- 0, contador de aparecimento

    # t4 <- temp
    # t5 <- temp
    

    la $a0, string1
    addi $a1, $zero, 100
    addi $v0, $zero, 8
    syscall 

    la $a0, string2
    addi $a1, $zero, 99
    syscall

    la $t0, string1
    la $t1, string2
    xor $t3, $t3, $t3

    j sub_string

    j exit

sub_string:
    lb $t4, 0($t0) # t4 <- t0[i] String1
    beq $t4, 0x0000000a, fim_string # 0x0000000a = "\n"
    beqz $t4, fim_string # 0x0000000a = "\n"
    
    lb $t5, 0($t1) # t5 <- t1[i] String2
    beq $t5, $t4, letra_igual
    
    addi $t0, $t0, 1
    j sub_string
fim_string:
    add $a0, $t3, $zero
    addi $v0, $zero, 1
    syscall
    j exit

letra_igual:
    beq $t5, 0x0000000a, incrementar_sub_string # Se terminar a string2, então a string2 é substring da string1
    bne $t5, $t4, diferente # Se t5 != t4, então não é uma substring de t5
   
  
    addi $t0, $t0, 1
    addi $t1, $t1, 1    
    
    lb $t4, 0($t0) # t4 <- t0[i] String1
    lb $t5, 0($t1) # t5 <- t1[i] String2
    
    j letra_igual

incrementar_sub_string:
    addi $t3, $t3, 1
    la $t1, string2 # Reseta o ponteiro para o inicio da string2

    j sub_string
diferente:
    la $t1, string2 # Reseta o ponteiro para o inicio da string2

    j sub_string


exit:
	addi $v0, $zero, 10
	syscall         