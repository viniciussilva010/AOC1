.data
    coef_a:       .asciiz "Digite o coeficiente a: "
    coef_b:       .asciiz "Digite o coeficiente b: "
    coef_c:       .asciiz "Digite o coeficiente c: "
    msg_sem_raizes:   .asciiz "Nao ha raizes reais (discriminante negativo).\n"
    msg_uma_raiz:   .asciiz "Ha apenas uma raiz real (discriminante zero):\n"
    msg_duas_raizes:  .asciiz "\n\nAs raizes reais sao:\n"
    msg_raiz1: .asciiz "Raiz 1: "
    msg_raiz2: .asciiz "\nRaiz 2: "
    msg_a_invalido:  .asciiz "Erro: Coeficiente 'a' nao pode ser zero.\n"
    msg_discriminante: .asciiz "Valor Discriminante: "
    nova_linha:        .asciiz "\n"
    zero_float:     .float 0.0
    dois_float:      .float 2.0
    quatro_float:     .float 4.0

.text
.globl main

main:
    # Ler coeficiente a
    li $v0, 4               # Codigo para imprimir string
    la $a0, coef_a          # Carrega o endereco da mensagem
    syscall
    li $v0, 6               # Codigo para ler um float
    syscall
    mov.s $f1, $f0       # $f1 = a - armazena em f1 o valor do coef a

    # Verificar se a == 0
    l.s $f4, zero_float
    c.eq.s $f1, $f4
    bc1t a_invalido

    # Ler coeficiente b
    li $v0, 4               # Codigo para imprimir string
    la $a0, coef_b          # Carrega o endereco da mensagem
    syscall
    li $v0, 6               # Codigo para ler um float
    syscall
    mov.s $f2, $f0       # $f2 = b - armazena em f2 o valor do coef b

    # Ler coeficiente c
    li $v0, 4               # Codigo para imprimir string
    la $a0, coef_c          # Carrega o endereco da mensagem
    syscall
    li $v0, 6               # Codigo para ler um float
    syscall
    mov.s $f3, $f0       # $f3 = c - armazena em f3 o valor do coef c

    # Calcular discriminante (b^2 - 4ac)
    mul.s $f5, $f2, $f2   # $f5 = b^2
    l.s $f6, quatro_float
    mul.s $f6, $f6, $f1   # $f6 = 4a
    mul.s $f6, $f6, $f3   # $f6 = 4ac
    sub.s $f7, $f5, $f6   # $f7 = discriminante (b^2 - 4ac)
    
    #imprimir discriminante
    li $v0, 4                   # Codigo para imprimir string
    la $a0, msg_discriminante   # Carrega o endereco da mensagem
    syscall
    
    li $v0, 2               # Codigo para escrever float
    mov.s $f12, $f7         # Carrega o valor a ser impresso
    syscall   

    # Verificar discriminante
    l.s $f4, zero_float
    c.lt.s $f7, $f4
    bc1t sem_raizes_reais    # if disc < 0, sem raizes reais

    # Calcular sqrt(discriminante)
    sqrt.s $f8, $f7       # $f8 = sqrt(disc)

    # Verificar se discriminante é zero
    c.eq.s $f7, $f4
    bc1t uma_raiz_real    # if disc == 0, uma raiz real

    # Caso com duas raizes reais
    # Verificar sinal de b
    l.s $f4, zero_float
    c.lt.s $f4, $f2
    bc1t b_positivo

    # b negativo: tradicional para r1, segura para r2
    # r1 tradicional: (-b + sqrt(disc)) / (2a)
    l.s $f12, dois_float
    mul.s $f12, $f12, $f1   # $f12 = 2a
    neg.s $f13, $f2         # $f13 = -b
    add.s $f13, $f13, $f8   # $f13 = -b + sqrt(disc)
    div.s $f14, $f13, $f12  # $f14 = r1

    # r2 segura: (2c) / (-b + sqrt(disc))
    l.s $f12, dois_float
    mul.s $f12, $f12, $f3   # $f12 = 2c
    neg.s $f13, $f2         # $f13 = -b
    add.s $f13, $f13, $f8   # $f13 = -b + sqrt(disc)
    div.s $f15, $f12, $f13  # $f15 = r2

    j print_duas_raizes

b_positivo:
    # b positivo: segura para r1, tradicional para r2
    # r1 segura: (2c) / (-b - sqrt(disc))
    l.s $f12, dois_float
    mul.s $f12, $f12, $f3   # $f12 = 2c
    neg.s $f13, $f2         # $f13 = -b
    sub.s $f13, $f13, $f8   # $f13 = -b - sqrt(disc)
    div.s $f14, $f12, $f13  # $f14 = r1

    # r2 tradicional: (-b - sqrt(disc)) / (2a)
    l.s $f12, dois_float
    mul.s $f12, $f12, $f1   # $f12 = 2a
    neg.s $f13, $f2         # $f13 = -b
    sub.s $f13, $f13, $f8   # $f13 = -b - sqrt(disc)
    div.s $f15, $f13, $f12  # $f15 = r2

    j print_duas_raizes

uma_raiz_real:
    # Calcular raiz única (-b)/(2a)
    l.s $f12, dois_float
    mul.s $f12, $f12, $f1   # $f12 = 2a
    neg.s $f13, $f2         # $f13 = -b
    div.s $f14, $f13, $f12  # $f14 = raiz única

    # Imprimir mensagem de raiz única
    li $v0, 4               # Codigo para imprimir string
    la $a0, msg_uma_raiz    # Carrega o endereco da mensagem
    syscall
    li $v0, 2               # Codigo para escrever float
    mov.s $f12, $f14        # Carrega o valor a ser impresso
    syscall
    li $v0, 4               # Codigo para imprimir string
    la $a0, nova_linha      # Carrega o endereco da mensagem
    syscall
    j exit

sem_raizes_reais:
    # Imprimir mensagem de nenhuma raiz real
    li $v0, 4                   # Codigo para imprimir string
    la $a0, msg_sem_raizes      # Carrega o endereco da mensagem
    syscall
    j exit

a_invalido:
    # Imprimir mensagem de erro para a = 0
    li $v0, 4                   # Codigo para imprimir string
    la $a0, msg_a_invalido      # Carrega o endereco da mensagem
    syscall
    j exit

print_duas_raizes:
    # Imprimir mensagem de duas raízes
    li $v0, 4                   # Codigo para imprimir string
    la $a0, msg_duas_raizes     # Carrega o endereco da mensagem
    syscall

    li $v0, 4                # Codigo para imprimir string
    la $a0, msg_raiz1        # Carrega o endereco da mensagem
    syscall

    # Imprimir r1
    li $v0, 2               # Codigo para escrever float
    mov.s $f12, $f14        # Carrega o valor a ser impresso
    syscall
  
    li $v0, 4                # Codigo para imprimir string
    la $a0, msg_raiz2        # Carrega o endereco da mensagem
    syscall

    # Imprimir r2
    li $v0, 2               # Codigo para escrever float 
    mov.s $f12, $f15        # Carrega o valor a ser impresso
    syscall

    # Nova linha
    li $v0, 4               # Codigo para imprimir string
    la $a0, nova_linha      # Carrega o endereco da mensagem
    syscall

exit:
    # Terminar programa
    li $v0, 10              # Codigo para finalizar programa
    syscall