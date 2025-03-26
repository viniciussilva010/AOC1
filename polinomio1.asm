.data
    coeficientes: .word 2, -11, -7, -27, 88  # Coeficientes do polinômio
    grau: .word 4  # Grau do polinômio (n)
    x_valor: .word 3  # Valor de x a ser avaliado
    resultado: .word 0  # Armazena o resultado final
    msg_resultado: .asciiz "Resultado do polinômio: "  # Mensagem para exibição

.text
    .globl main

main:
    # Carregar valores
    la $t0, coeficientes  # Endereço do vetor de coeficientes
    lw $t1, grau  # n (grau do polinômio)
    lw $t2, x_valor  # x (valor a ser avaliado)
    
    li $t3, 0  # poly = 0 (inicializa resultado)
    li $t4, 0  # i = 0 (contador do loop)
    
loop:
    bgt $t4, $t1, fim_loop  # Se i > n, sai do loop
    
    # Carregar coeficiente a[i]
    lw $t5, 0($t0)  # t5 = coeficientes[i]
    
    # Calcular potência de x: x^(n-i)
    sub $t6, $t1, $t4  # t6 = n - i
    move $a0, $t2  # x como base
    move $a1, $t6  # expoente (n-i)
    jal potencia  # Chama função potencia(x, exp)
    move $t7, $v0  # t7 = x^(n-i)
    
    # Multiplicar coeficiente pelo resultado da potência
    mul $t8, $t5, $t7  # t8 = a[i] * x^(n-i)
    
    # Somar ao resultado final
    add $t3, $t3, $t8  # poly += a[i] * x^(n-i)
    
    # Atualizar ponteiro do vetor
    addi $t0, $t0, 4  # Avança para o próximo coeficiente
    addi $t4, $t4, 1  # i++
    j loop  # Volta para o loop

fim_loop:
    sw $t3, resultado  # Armazena o resultado final na memória
    
# Chamar função para imprimir o resultado correto
    move $a0, $t3  # Passa o valor correto para impressão
    jal imprimir_resultado  # Chama a função de impressão


    # Encerrar o programa
    li $v0, 10
    syscall

# Função para calcular potência: potencia(base, exp)
potencia:
    li $v0, 1  # Resultado inicial = 1
    li $t9, 0  # Contador de loop

potencia_loop:
    beq $t9, $a1, potencia_fim  # Se contador == expoente, retorna resultado
    mul $v0, $v0, $a0  # Multiplica resultado pela base
    addi $t9, $t9, 1  # Incrementa contador
    j potencia_loop  # Continua loop

potencia_fim:
    jr $ra  # Retorna

imprimir_resultado:
    # Imprimir mensagem
    li $v0, 4
    la $a0, msg_resultado
    syscall
    
   
    lw $a0, resultado  # Carrega o valor na memória para $a0
    
    # Imprimir número armazenado em $a0
    li $v0, 1
    syscall
    
    # Imprimir nova linha
    li $v0, 11
    li $a0, 10  # Código ASCII de '\n'
    syscall
    
    jr $ra  # Retorna
