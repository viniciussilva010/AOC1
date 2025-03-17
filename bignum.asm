.data
buffer1:   .space  300      # Buffer para armazenar até 100 dígitos + espaços
buffer2:   .space  300      # Buffer para armazenar até 100 dígitos + espaços
result:    .space  300      # Buffer para armazenar o resultado
msg1:      .asciiz "Digite a primeira sequência:\n"
msg2:      .asciiz "Digite a segunda sequência:\n"
msgRes:    .asciiz "Resultado: "
space:     .asciiz " "
newline:   .asciiz "\n"

.text
.globl main

main:
    # Pedir e ler a primeira sequência
    li $v0, 4
    la $a0, msg1
    syscall

    li $v0, 8
    la $a0, buffer1
    li $a1, 300
    syscall

    # Pedir e ler a segunda sequência
    li $v0, 4
    la $a0, msg2
    syscall

    li $v0, 8
    la $a0, buffer2
    li $a1, 300
    syscall

    # Chamar a função de soma
    la $a0, buffer1
    la $a1, buffer2
    la $a2, result
    jal add

# Inverter a string de resultado antes de imprimir
reverse_result:
    la $t0, result      # Ponteiro para início do resultado
    move $t1, $s2       # Ponteiro para o final (última posição preenchida)
    subi $t1, $t1, 1    # Ajustar para último caractere útil

reverse_loop:
    bge $t0, $t1, print_result  # Se os ponteiros se cruzarem, parar

    lb $t2, 0($t0)  # Carregar primeiro caractere
    lb $t3, 0($t1)  # Carregar último caractere
    sb $t3, 0($t0)  # Trocar
    sb $t2, 0($t1)  # Trocar

    addi $t0, $t0, 1  # Avançar início
    subi $t1, $t1, 1  # Retroceder fim
    j reverse_loop

# Exibir resultado 
print_result:
    li $v0, 4
    la $a0, result
    syscall

    # Finalizar programa
    li $v0, 10
    syscall

# Função add(a, b, result)
# Soma duas sequências de números representadas como strings e mantém os espaços corretos
add:
    move $s0, $a0  # Ponteiro para buffer1 (a)
    move $s1, $a1  # Ponteiro para buffer2 (b)
    move $s2, $a2  # Ponteiro para result (inicializado no início)

    li $s3, 0      # Carry inicializado em 0

    # Buffers temporários para armazenar os números sem espaços
    la $t5, buffer1
    la $t6, buffer2

    # Remover espaços e armazenar os números corretamente
clean_buffer1:
    lb $t3, 0($s0)
    beq $t3, 10, end_clean1  # Se encontrar '\n', termina
    beq $t3, 32, skip_space1 # Ignorar espaços (ASCII 32)
    sb $t3, 0($t5)
    addi $t5, $t5, 1
skip_space1:
    addi $s0, $s0, 1
    j clean_buffer1
end_clean1:

clean_buffer2:
    lb $t3, 0($s1)
    beq $t3, 10, end_clean2  # Se encontrar '\n', termina
    beq $t3, 32, skip_space2 # Ignorar espaços (ASCII 32)
    sb $t3, 0($t6)
    addi $t6, $t6, 1
skip_space2:
    addi $s1, $s1, 1
    j clean_buffer2
end_clean2:

    # Definir ponteiros para os finais das sequências limpas
    subi $t5, $t5, 1
    subi $t6, $t6, 1

    # Iniciar soma dos números
sum_loop:
    # Se ambos os números já foram processados, encerra a soma
la $t8, buffer1  # Carregar endereço base de buffer1
blt $t5, $t8, check_b  

la $t9, buffer2  # Carregar endereço base de buffer2
blt $t6, $t9, check_a  


    # Carregar último dígito de cada número
    lb $t3, 0($t5)  # Último dígito de buffer1
    lb $t4, 0($t6)  # Último dígito de buffer2
    subi $t3, $t3, 48  # Converter ASCII para número
    subi $t4, $t4, 48  # Converter ASCII para número
    add $t7, $t3, $t4  # Somar os dois números
    add $t7, $t7, $s3  # Adicionar carry

    # Resetar carry
    li $s3, 0  

    # Se soma for maior que 9, ajustar carry
    bgt $t7, 9, carry_set
    j store_result

check_b:
    # Se buffer2 acabou, processar apenas buffer1
    blt $t5, $t8, sum_done
    lb $t4, 0($t6)
    subi $t4, $t4, 48
    add $t7, $t4, $s3
    li $s3, 0
    bgt $t7, 9, carry_set
    j store_result

check_a:
    # Se buffer1 acabou, processar apenas buffer2
    
    lb $t3, 0($t5)
    subi $t3, $t3, 48
    add $t7, $t3, $s3
    li $s3, 0
    bgt $t7, 9, carry_set

store_result:
    addi $t7, $t7, 48  # Converter número para ASCII
    sb $t7, 0($s2)    # Armazenar no buffer de resultado
    addi $s2, $s2, 1  # Atualizar ponteiro do resultado
    addi $t5, $t5, -1  # Atualizar ponteiro buffer1
    addi $t6, $t6, -1  # Atualizar ponteiro buffer2
    j sum_loop         # Voltar para próximo dígito

carry_set:
    subi $t7, $t7, 10  # Ajustar carry
    li $s3, 1
    j store_result

sum_done:
    # Se ainda houver carry, adicionar 1 no início do resultado
    beqz $s3, end_add
    li $t7, 49  # ASCII '1'
    sb $t7, 0($s2)
    addi $s2, $s2, 1

end_add:
    # Adicionar '\0' no final para garantir impressão correta
    li $t7, 0
    sb $t7, 0($s2)

    # Ajustar ponteiro para exibir o resultado corretamente
    la $a0, result
    jr $ra
