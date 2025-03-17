.data
buffer1: .space 300 # Armazena primeira sequencia
buffer2: .space 300 # Armazena segunda sequencia
result: .space 300 # Armazena o resultado
msg1: .asciiz "Digite a primeira sequencia:\n"
msg2: .asciiz "Digite a segunda sequencia:\n"
msgRes: .asciiz "Resultado: "
space: .asciiz " "
newline: .asciiz "\n"

.text
.globl main

main:
    # Solicita primeira sequencia
    li $v0, 4
    la $a0, msg1
    syscall

    # Le a primeira sequencia
    li $v0, 8
    la $a0, buffer1
    li $a1, 300
    syscall

    # Solicita segunda sequencia
    li $v0, 4
    la $a0, msg2
    syscall

    # Le a segunda sequencia
    li $v0, 8
    la $a0, buffer2
    li $a1, 300
    syscall

    # Chama a funcao de soma
    la $a0, buffer1
    la $a1, buffer2
    la $a2, result
    jal add

reverse_result:
    # Inverte a string resultante
    la $t0, result
    move $t1, $s2
    subi $t1, $t1, 1

reverse_loop:
    bge $t0, $t1, print_result # Termina se os ponteiros se cruzarem

    lb $t2, 0($t0) # Carrega caracteres
    lb $t3, 0($t1)
    sb $t3, 0($t0) # Troca os caracteres
    sb $t2, 0($t1)

    addi $t0, $t0, 1 # Ajusta os ponteiros
    subi $t1, $t1, 1
    j reverse_loop

print_result:
    # Imprime o resultado
    li $v0, 4
    la $a0, result
    syscall

    # Termina o programa
    li $v0, 10
    syscall

add:
    # Soma as sequencias
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2

    li $s3, 0 # Inicializa o carry

    # Remove espacos e armazena numeros
    la $t5, buffer1
    la $t6, buffer2

clean_buffer1:
    lb $t3, 0($s0)
    beq $t3, 10, end_clean1 # Termina ao encontrar '\n'
    beq $t3, 32, skip_space1 # Ignora espacos
    sb $t3, 0($t5)
    addi $t5, $t5, 1
skip_space1:
    addi $s0, $s0, 1
    j clean_buffer1
end_clean1:

clean_buffer2:
    lb $t3, 0($s1)
    beq $t3, 10, end_clean2 # Termina ao encontrar '\n'
    beq $t3, 32, skip_space2 # Ignora espaços
    sb $t3, 0($t6)
    addi $t6, $t6, 1
skip_space2:
    addi $s1, $s1, 1
    j clean_buffer2
end_clean2:

    # Ajusta os ponteiros
    subi $t5, $t5, 1
    subi $t6, $t6, 1

sum_loop:
    # Loop de soma
la $t8, buffer1
blt $t5, $t8, check_b

la $t9, buffer2
blt $t6, $t9, check_a

    lb $t3, 0($t5)
    lb $t4, 0($t6)
    subi $t3, $t3, 48
    subi $t4, $t4, 48
    add $t7, $t3, $t4
    add $t7, $t7, $s3

    li $s3, 0

    bgt $t7, 9, carry_set
    j store_result

check_b:
    # Processa buffer1 se buffer2 acabou
    blt $t5, $t8, sum_done
    lb $t4, 0($t6)
    subi $t4, $t4, 48
    add $t7, $t4, $s3
    li $s3, 0
    bgt $t7, 9, carry_set
    j store_result

check_a:
    # Processa buffer2 se buffer1 acabou
    lb $t3, 0($t5)
    subi $t3, $t3, 48
    add $t7, $t3, $s3
    li $s3, 0
    bgt $t7, 9, carry_set

store_result:
    # Armazena o resultado
    addi $t7, $t7, 48
    sb $t7, 0($s2)
    addi $s2, $s2, 1
    addi $t5, $t5, -1
    addi $t6, $t6, -1
    j sum_loop

carry_set:
    # Ajusta o carry
    subi $t7, $t7, 10
    li $s3, 1
    j store_result

sum_done:
    # Adiciona carry final
    beqz $s3, end_add
    li $t7, 49
    sb $t7, 0($s2)
    addi $s2, $s2, 1

end_add:
    # Adiciona '\0' e retorna
    li $t7, 0
    sb $t7, 0($s2)

    la $a0, result
    jr $ra