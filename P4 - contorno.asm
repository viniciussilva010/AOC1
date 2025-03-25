.data
    matriz: .space 10000  # Matriz 100x100 (ajuste conforme necessario)
    msg_dimensao: .asciiz "Digite a dimensao da matriz: "
    msg_linha: .asciiz "Digite a linha: "
    msg_coluna: .asciiz "Digite a coluna: "
    msg_erro: .asciiz "Posicao invalida!\n"

.text
.globl main

main:
    # Ler a dimensao da matriz
    li $v0, 4	# Codigo para imprimir string
    la $a0, msg_dimensao
    syscall
    
    li $v0, 5	# Codigo para ler valor inteiro
    syscall
    move $s0, $v0  # s0 = dimensao da matriz

    # Ler a linha
    li $v0, 4	# Codigo para imprimir string
    la $a0, msg_linha
    syscall

    li $v0, 5	# Codigo para ler valor inteiro
    syscall
    move $s1, $v0  # s1 = linha

    # Ler a coluna
    li $v0, 4	# Codigo para imprimir string
    la $a0, msg_coluna
    syscall

    li $v0, 5	# Codigo para ler valor inteiro
    syscall
    move $s2, $v0  # s2 = coluna

    # Verificar se a posicao eh valida
    bltz $s1, posicao_invalida		#Verifica se < 0	BLTZ RS, OFF18	IF RS < 0, goto label
    bltz $s2, posicao_invalida		#Verifica se < 0	BLTZ RS, OFF18	IF RS < 0, goto label
    bge $s1, $s0, posicao_invalida	#bge $t1, $t2, label	 if ($t1 >= $t2) goto label
    bge $s2, $s0, posicao_invalida	#bge $t1, $t2, label	 if ($t1 >= $t2) goto label

    # Calcular o endereco da celula
    mul $t0, $s1, $s0   #to = linha * dimensao
    add $t0, $t0, $s2   #to = (linha * dimensao) + coluna
    sll $t0, $t0, 2     #desloca bits para esquerda por uma quantidade imediata constante, equiv. mult por 4
    la $t1, matriz      # load address into register - carrega em t1 o endereco inicial da matriz
    add $t0, $t0, $t1   #soma ao endereco inicial da matriz a posicao calculada

    # Definir o valor da celula como 9
    li $t2, 9       #carrega para t2 o valor 9
    sw $t2, 0($t0)  #guarda na posicao de memoria de t0 o valor 9

    # Incrementar os valores ao redor
    jal incrementar_ao_redor    #chamada de funcao

    # Exibir a matriz
    jal exibir_matriz   #chamada de funcao

    # Sair
    li $v0, 10  # Codigo para finalizar programa
    syscall

posicao_invalida:
    li $v0, 4	# Codigo para imprimir string
    la $a0, msg_erro
    syscall
    j main

    # s0 = dimensao da matriz
    # s1 = linha
    # s2 = coluna
    #$t1 endereco inicial da matriz
    #$t0 posicao do elemento informado

incrementar_ao_redor:
    # Verificar as celulas ao redor
    
    # Celula a frente
    # Calcular o endereco da celula
    subi $t5, $s0, 1
    beq $s2, $t5, pula_frente   #verifica se esta no final da linha, se estiver pula esse elemento
    mul $t0, $s1, $s0   #to = linha * dimensao
    add $t0, $t0, $s2   #to = (linha * dimensao) + coluna
    sll $t0, $t0, 2     #desloca bits para esquerda por uma quantidade imediata constante, equiv. mult por 4
    la $t1, matriz      # load address into register - carrega em t1 o endereco inicial da matriz
    add $t0, $t0, $t1   #soma ao endereco inicial da matriz a posicao calculada
    # Definir o valor da celula como 1
    li $t2, 1       #carrega para t2 o valor 1
    sw $t2, 4($t0)  #guarda na posicao de memoria com endereco guardado em t0 o valor armazenado em t2
pula_frente:
    
    # Celula atras
    # Calcular o endereco da celula
    li $t5, 0
    beq $s2, $t5, pula_atras    #verifica se esta no inicio da linha, se estiver pula esse elemento
    mul $t0, $s1, $s0   #to = linha * dimensao
    add $t0, $t0, $s2   #to = (linha * dimensao) + coluna
    sll $t0, $t0, 2     #desloca bits para esquerda por uma quantidade imediata constante, equiv. mult por 4
    la $t1, matriz      # load address into register - carrega em t1 o endereco inicial da matriz
    add $t0, $t0, $t1   #soma ao endereco inicial da matriz a posicao calculada
    # Definir o valor da celula como 1
    li $t2, 1       #carrega para t2 o valor 1
    sw $t2, -4($t0)  #guarda na posicao de memoria com endereco guardado em t0 o valor armazenado em t2
pula_atras:
    
    # Celula abaixo
    # Calcular o endereco da celula
    subi $t5, $s0, 1
    beq $s1, $t5, pula_abaixo   #verifica se esta na ultima linha, se estiver pula esse elemento
    mul $t0, $s1, $s0   #to = linha * dimensao
    add $t0, $t0, $s2   #to = (linha * dimensao) + coluna
    add $t0, $t0, $s0   #soma a posicao informada a dimensao da matriz para achar o elemento abaixo
    sll $t0, $t0, 2     #desloca bits para esquerda por uma quantidade imediata constante, equiv. mult por 4
    la $t1, matriz      # load address into register - carrega em t1 o endereco inicial da matriz
    add $t0, $t0, $t1   #soma ao endereco inicial da matriz a posicao calculada
    # Definir o valor da celula como 1
    li $t2, 1       #carrega para t2 o valor 1
    sw $t2, 0($t0)  #guarda na posicao de memoria com endereco guardado em t0 o valor armazenado em t2
pula_abaixo:
    
    # Celula acima
    # Calcular o endereco da celula
    li $t5, 0
    beq $s1, $t5, pula_acima    #verifica se esta na primeira linha, se estiver pula esse elemento
    mul $t0, $s1, $s0   #to = linha * dimensao
    add $t0, $t0, $s2   #to = (linha * dimensao) + coluna
    sub $t0, $t0, $s0   #subtrai da posicao informada a dimensao da matriz para achar o elemento acima
    sll $t0, $t0, 2     #desloca bits para esquerda por uma quantidade imediata constante, equiv. mult por 4
    la $t1, matriz      # load address into register - carrega em t1 o endereco inicial da matriz
    add $t0, $t0, $t1   #soma ao endereco inicial da matriz a posicao calculada
    # Definir o valor da celula como 1
    li $t2, 1       #carrega para t2 o valor 1
    sw $t2, 0($t0)  #guarda na posicao de memoria com endereco guardado em t0 o valor armazenado em t2
pula_acima:
    
    # Celula diagonal esquerda acima
    # Calcular o endereco da celula
    li $t5, 0
    beq $s2, $t5, pula_diagonal_esquerda_acima      #verifica se esta no inicio da linha, se estiver pula esse elemento
    mul $t0, $s1, $s0   #to = linha * dimensao
    add $t0, $t0, $s2   #to = (linha * dimensao) + coluna
    sub $t0, $t0, $s0   #subtrai da posicao informada a dimensao da matriz para achar o elemento acima
    subi $t0, $t0, 1    #subtrai 1 da posicao acima
    sll $t0, $t0, 2     #desloca bits para esquerda por uma quantidade imediata constante, equiv. mult por 4
    la $t1, matriz      # load address into register - carrega em t1 o endereco inicial da matriz
    add $t0, $t0, $t1   #soma ao endereco inicial da matriz a posicao calculada
    # Definir o valor da celula como 1
    li $t2, 1       #carrega para t2 o valor 1
    sw $t2, 0($t0)  #guarda na posicao de memoria com endereco guardado em t0 o valor armazenado em t2
pula_diagonal_esquerda_acima:
    
    # Celula diagonal esquerda abaixo
    # Calcular o endereco da celula
    li $t5, 0
    beq $s2, $t5, pula_diagonal_esquerda_abaixo     #verifica se esta no inicio da linha, se estiver pula esse elemento
    mul $t0, $s1, $s0   #to = linha * dimensao
    add $t0, $t0, $s2   #to = (linha * dimensao) + coluna
    add $t0, $t0, $s0   #soma a posicao informada a dimensao da matriz para achar o elemento abaixo
    subi $t0, $t0, 1    #subtrai 1 da posicao abaixo
    sll $t0, $t0, 2     #desloca bits para esquerda por uma quantidade imediata constante, equiv. mult por 4
    la $t1, matriz      # load address into register - carrega em t1 o endereco inicial da matriz
    add $t0, $t0, $t1   #soma ao endereco inicial da matriz a posicao calculada
    # Definir o valor da celula como 1
    li $t2, 1       #carrega para t2 o valor 1
    sw $t2, 0($t0)  #guarda na posicao de memoria com endereco guardado em t0 o valor armazenado em t2
pula_diagonal_esquerda_abaixo:
    
    # Celula diagonal direita acima
    # Calcular o endereco da celula
    subi $t5, $s0, 1
    beq $s2, $t5, pula_diagonal_direita_acima       #verifica se esta no final da linha, se estiver pula esse elemento
    mul $t0, $s1, $s0   #to = linha * dimensao
    add $t0, $t0, $s2   #to = (linha * dimensao) + coluna
    sub $t0, $t0, $s0   #subtrai da posicao informada a dimensao da matriz para achar o elemento acima
    addi $t0, $t0, 1    #adiciona 1 da posicao acima
    sll $t0, $t0, 2     #desloca bits para esquerda por uma quantidade imediata constante, equiv. mult por 4
    la $t1, matriz      # load address into register - carrega em t1 o endereco inicial da matriz
    add $t0, $t0, $t1   #soma ao endereco inicial da matriz a posicao calculada
    # Definir o valor da celula como 1
    li $t2, 1       #carrega para t2 o valor 1
    sw $t2, 0($t0)  #guarda na posicao de memoria com endereco guardado em t0 o valor armazenado em t2
pula_diagonal_direita_acima:
    
    # Celula diagonal direita abaixo
    # Calcular o endereco da celula
    subi $t5, $s0, 1
    beq $s2, $t5, pula_diagonal_direita_abaixo      #verifica se esta no final da linha, se estiver pula esse elemento
    mul $t0, $s1, $s0   #to = linha * dimensao
    add $t0, $t0, $s2   #to = (linha * dimensao) + coluna
    add $t0, $t0, $s0   #soma a posicao informada a dimensao da matriz para achar o elemento abaixo
    addi $t0, $t0, 1    #adiciona 1 da posicao abaixo
    sll $t0, $t0, 2     #desloca bits para esquerda por uma quantidade imediata constante, equiv. mult por 4
    la $t1, matriz      # load address into register - carrega em t1 o endereco inicial da matriz
    add $t0, $t0, $t1   #soma ao endereco inicial da matriz a posicao calculada
    # Definir o valor da celula como 1
    li $t2, 1       #carrega para t2 o valor 1
    sw $t2, 0($t0)  #guarda na posicao de memoria com endereco guardado em t0 o valor armazenado em t2
pula_diagonal_direita_abaixo:
    
    jr $ra
 
 
    # s0 = dimensao da matriz
    # s1 = linha
    # s2 = coluna

exibir_matriz:
    li $t0, 0  # Linha - load immediate: load constant into register (16-bit)
    li $t1, 0  # Coluna - load immediate: load constant into register (16-bit)

exibir_loop:
    bge $t0, $s0, exibir_fim    #desvia para o label, se: t0 >= s0 - se linhas >= dimensao

    mul $t2, $t0, $s0   #t2 = linha * dimensao
    add $t2, $t2, $t1   #t2 = (linha * dimensao) + coluna
    sll $t2, $t2, 2     #desloca bits para esquerda por uma quantidade imediata constante, equiv. mult por 4
    la $t3, matriz      # load address into register - carrega em t3 o endereco inicial da matriz
    add $t2, $t2, $t3   #soma ao endereco inicial da matriz a posicao calculada
    lw $a0, 0($t2)      #le conteudo da posicao de memoria com endereco guardado em t2 e armazena em a0
    li $v0, 1           # Codigo para escrever um inteiro
    syscall

    li $v0, 11  # Codigo para escrever um byte
    li $a0, 32  # Espaco
    syscall

    addi $t1, $t1, 1    #avanca uma coluna
    bne $t1, $s0, exibir_loop   #desvia para o label, se: t1 != s0

    li $v0, 11  # Codigo para escrever um byte
    li $a0, 10  # Nova linha
    syscall

    li $t1, 0           #zera contador de coluna
    addi $t0, $t0, 1    #incrementa linha
    j exibir_loop       #retorna inicio do loop

exibir_fim:
    jr $ra
