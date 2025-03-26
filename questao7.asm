.data
string1: .asciiz "Escreva o grau do polinômio: "
string2: .asciiz "Comece a escrita dos coeficientes pelo termo de maior grau até o termo constante.\n"
string3: .asciiz "Escreva o coeficiente: "
string4: .ascii "Digite os limites do intervalo [a,b]\n" 
string5: .asciiz "Digite o inicio do intervalo: "
string6: .asciiz "Digite o final do intervalo: "
string7: .asciiz "A raiz do polinomio com precisão  "
string8 :.asciiz " é: "
new_line: .asciiz "\n"

grau: .word 0
delta: .double 50.0
epsilon: .double 0.00000001 #10^(-8)
zero: .double 0.0
um: .double 1.0


.text
.globl main


# FALTA FAZER A FUNÇÃO DE BISSECCAO. O FLUXO DE COMANDOS NA MAIN JÁ ESTÁ CORRETA

main:
	jal capturar_dados_de_f
	jal capturar_coeficientes
	# Nao pode haver alteracoes no registrador t0. t0 guarda a lista de coeficientes da funcao

	
	j get_raizes
	
	j exit
	

bisseccao: # $f2 = 2.0
				 # $f4 = b - a
				 # $f6 = epsilon (Precisão da raiz)
				 # $f8 = (b-a) / 2
				 # $f20 = 0.0 -> O registrador f20 já contém o 0.0, pela função anterior get_raizes
				 # $f22 = f(x).f(b)
				 # $f24 = f(b) -> O registrado f24 já contém f(b), pela função anterior get_raizes
				 # $f28 = a, $f30 = b ( [a,b] )
	sub.d $f4, $f30, $f28
	div.d $f8, $f4, $f2 # f8 =  (b-a) / 2
	add.d $f8, $f28, $f8 # f8 = a + (b - a)/2 = m
	
	la $t7, grau
	lw $a2, 0($t7) 
	addi $a2, $a2, 1 # a2= grau + 1
	mov.d $f18, $f8 	# f18 = m
	move $a3, $t0 	# a3 = endereço base da lista de coeficientes
	jal fx #Avalia f(m)
	
	mov.d $f16, $f10
	abs.d $f16,$f16
	
	c.lt.d $f16, $f6 # if abs(f(m)) < epsilon then exit else continue
	bc1t exit_bisseccao
	
	mul.d $f22, $f10, $f24 # f22 = f(m).f(b)
	c.lt.d $f22, $f20 #Se f(m).f(b) < 0 then a = (b-a) / 2 else b = (b-a) / 2
	bc1t trocar_a
	
	mov.d $f30, $f8 # b = m
	j bisseccao
trocar_a:
	mov.d $f28, $f8 # a = m
	j bisseccao
	
exit_bisseccao:
	j print_raiz

# MÉTODO PARA AVALIAR O POLINOMIO
fx: # $f18 = x (valor onde o polinômio será avaliado)
    # $a2 = grau do polinômio + 1 (número de coeficientes)
    # $a3 = endereço base da lista de coeficientes
    # $f10 = acumulador do método de Horner -> Retorno de fx
	li $t7, 0        

    l.d $f10, 0($a3)
    addi $a3, $a3, 8       # Avançar para o proximo coeficiente
    subi $a2, $a2, 1       # Reduzir o contador de coeficientes

loop_fx:
    beqz $a2, exit_fx          # Fim dos coeficientes

    l.d $f4, 0($a3)                
    addi $a3, $a3, 8

    mul.d $f10, $f10, $f18   # Multiplicar acumulador por x
    add.d $f10, $f10, $f4    # Somar o coeficiente atual

    subi $a2, $a2, 1       	   # Reduzir o contador de coeficientes
    j loop_fx              	
 exit_fx:
 	jr $ra 

# CAPTURAR DADOS
capturar_dados_de_f:
	# A entrada começa pelo termo de maior grau
    #t0 = lista de coeficientes
    #t1 = grau do polinomio
    li $v0, 4
    la $a0, string1
    syscall

	la $a0, new_line
	syscall	

    li $v0, 5
    syscall
	
	la $t7, grau
	sw $v0, 0($t7) #Armazena o grau + 1 do polinomio na memória
	
    addi $v0, $v0, 1 #n+1 coeficientes
    mul $t0, $v0, 8 #Quantidade de bytes para alocar
	add $t1, $v0, $zero #t1 = n+1
	
	
	#Alocando memória para a lista de coeficientes
	add $a0, $zero, $t0
	addi $v0, $zero, 9
	syscall
	
	add $t0, $zero, $v0 #Local de memória da lista de coeficientes
	
	jr $ra

#CAPTURAR COEFICIENTES
capturar_coeficientes: 
    #t0 = lista de coeficientes
    #t1 = grau do polinomio + 1
	add $t3, $zero, $zero #t3 = contador do loop
	add $t4, $zero, $t0 #t4 = iterador sobre a lista de coeficientes
	
	li $v0 , 4
	la $a0, string2
	syscall
	
	la $a0, new_line
	syscall	
loop1:
	beq $t3, $t1, exit_loop1
	add $v0, $zero, 4
	la $a0, string3
	syscall	

	
	add $v0, $zero, 7 # ler double
	syscall

	s.d $f0, 0($t4)
	addi $t4, $t4, 8
	
	addi $t3, $t3, 1

	add $v0, $zero, 4
	la $a0, new_line
	syscall	
	
	j loop1
exit_loop1:
	jr $ra
	
	
# CAPTURAR UM INTERVALO [a,b} EM QUE CONTÉM UMA RAIZ
get_raizes: #f8 = 1.0
				 #f26 = contador
				 #f16 = delta
				 #f20 = 0.0
				 #f22 = f(a).f(b)
				 #f24 = f(b)		 
	jal get_intervalo # f28 = inicio do intervalo (a) -> f30 = final do intervalo(b)
	
	# f(a)f(b) > 0, então não pode afirmar que existe uma raiz no intervalo [a,b]
	#A rotina aproximará a de b até que f(a)f(b) < 0. Dessa maneira, no intervalo `[a,b] tem ao menos uma raiz.
	#O intervalo [a,b] vai ser quebrado em 50 pedaços de tamanho b-a / 50. E a aproximação será feita de tal maneira que f será avaliado em a + (b-a)*i/50 até que f(a).f(b) < 0. 
	la $t7, delta
	l.d $f18, 0($t7)
	
	la $t7, zero
	l.d $f20, 0($t7)
	
	sub.d $f16, $f30, $f28
	div.d $f16, $f16, $f18
	abs.d $f16, $f16
	
	# $f18 = x (valor onde o polinômio será avaliado)
    # $a2 = grau do polinômio + 1 (número de coeficientes)
    # $a3 = endereço base da lista de coeficientes
    # $f26 = acumulador do método de Horner -> Retorno de fx
	la $t7, grau
	lw $a2, 0($t7) 
	addi $a2, $a2, 1 # a2= grau + 1
	mov.d $f18, $f28 # f18 = a 
	move $a3, $t0 # a3 = endereço base da lista de coeficientes
	jal fx #Avalia f(a)
	mov.d $f2, $f10 # f2 = f(a)
	
	la $t7, grau
	lw $a2, 0($t7) 
	addi $a2, $a2, 1 # a2= grau + 1
	mov.d $f18, $f30 # f18 = b
	move $a3, $t0 # a3 = endereço base da lista de coeficientes
	jal fx #Avalia f(b)
	mov.d $f24, $f10 # f4 = f(b)
	
	mul.d $f22, $f2, $f24 # f22 = f(a).f(b)
	
	 
	 la $t7, um
	 l.d $f26, 0($t7) #Contador = 1 (i = 1)
	 l.d $f8, 0($t7)  #f8 = 1.0
loop_get_raizes: 
	c.lt.d $f22, $f20 #Se 0, f(a).f(b) > 0, caso contrário, f(a).f(b) < 0
	bc1t exit_get_raizes #f28 = a' e f30 = b', com [a',b'] o intervalo que contém a raiz
	c.eq.d $f28, $f30
	bc1t exit #Se f(a) == f(b), então não existe raiz no intervalo especificado.
	
	# f28 = f28 + f16*f26 (a = a + delta*i)
	mul.d $f2, $f16, $f26 #delta*i
	add.d $f28, $f28, $f2 #a + delta*i
	add.d $f26, $f26, $f8
	
	la $t7, grau
	lw $a2, 0($t7) 
	addi $a2, $a2, 1 # a2= grau + 1
	mov.d $f18, $f28 # f18 = a 
	move $a3, $t0 # a3 = endereço base da lista de coeficientes
	jal fx #Avalia f(a)
	mov.d $f2, $f10 # f2 = f(a)
	
	mul.d $f22, $f2, $f24 # f2 = f(a).f(b)
	
	
	j loop_get_raizes
exit_get_raizes:
	#Definindo os registradores para a função bisseccao
	la $t7, epsilon
	l.d $f6, 0($t7)
	
	la $t7, um
	l.d $f2, 0($t7)
	add.d $f2, $f2, $f2

	j bisseccao
		
# CAPTURAR INTERVALO INICIAL
get_intervalo:
					# f28 = inicio do intervalo
					#f30 = final do intervalo
    	li $v0, 4
    	la $a0, string4
    	syscall
    	
    	la $a0, string5
    	syscall
    	
    	li $v0, 7
		syscall
		
		mov.d $f28, $f0
	
		li $v0, 4
    	la $a0, string6
    	syscall
    	
    	li $v0, 7
		syscall
		
		mov.d $f30, $f0
		
		jr $ra
	
exit_get_intervalo:
	jr $ra

print_raiz:
	li $v0, 4
	la $a0, string7
	syscall
	
	li $v0, 3
	la $t7, epsilon
	l.d $f12, 0($t7)
	syscall
	
	li $v0, 4
	la $a0, string8
	syscall
	
	li $v0, 3
	mov.d $f12, $f8
	syscall
	
	j exit


exit:
	addi $v0, $zero, 10
	syscall
	


