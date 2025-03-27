.data
    msg_n:      .asciiz "Insira a ordem do polinômio: "
    msg_x:      .asciiz "Insira o valor de x: "
    msg_saida:  .asciiz "O resultado eh: "

    coef:       .word 2, -11, -7, -27, 88  # Coeficientes do polinômio

.text
    main:
        # Solicita ao usuário o grau do polinômio (n)
        li $v0, 4
        la $a0, msg_n
        syscall

        li $v0, 5
        syscall
        move $t0, $v0   # $t0 = n

        # Solicita ao usuário o valor de x
        li $v0, 4
        la $a0, msg_x
        syscall

        li $v0, 5
        syscall
        move $t1, $v0   # $t1 = x

        # Chamada da função horner
        la $a0, coef    # Endereço do vetor de coeficientes
        move $a1, $t0   # n (grau do polinômio)
        move $a2, $t1   # x
        jal horner      # Chama a função Horner (resultado em $t3)

        # Chama a função de impressão
        jal imprimir_t3

        # Finaliza o programa
        li $v0, 10
        syscall


horner:
    lw $t3, 0($a0)   # poly = coef[0] (primeiro coeficiente)
    addi $t4, $zero, 1  # i = 1 (contador do loop)

loop_horner:
    bgt $t4, $a1, fim_horner  # Se i > n, termina o loop
    mul $t3, $t3, $a2  # poly = poly * x

    # Correção: acessar coef[i] corretamente
    mul $t6, $t4, 4   # Calcula deslocamento i * 4
    add $t7, $a0, $t6 # Endereço de coef[i]
    lw $t5, 0($t7)    # Carrega coef[i]

    add $t3, $t3, $t5  # poly = poly + coef[i]

    addi $t4, $t4, 1   # i++
    j loop_horner      # Repetir o loop

fim_horner:
    jr $ra  # Retorna para a função chamadora


imprimir_t3:
    li $v0, 4
    la $a0, msg_saida
    syscall

    li $v0, 1
    move $a0, $t3  # Move o valor de $t3 para $a0 para ser impresso
    syscall

    jr $ra  # Retorna para a função chamadora
