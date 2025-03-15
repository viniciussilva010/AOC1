.data
primos: .space 720
gemeos: .space 400 
separacao: .asciiz "; "

.text
.globl main

main:
	# t0 = i : i = 3
	# t1 = total de iterações : 1000
	# t2 = temporário de uso geral
	# t3 = temporário de uso geral
	# t4 = temporário de uso geral
	# t5 = temporário de uso geral

	#t6 = lista de primos : endereço base da lista de primos
	#t7 = gemeos : endereço base da lista de gemeos

	##### Iniicializando
	la $t6, primos
	la $t7, gemeos
	addi $t1, $zero, 1000

	
	addi $t3, $zero, 2
	sw $t3, 0($t6)
	
	addi $t0, $zero, 3
	
	j gerar_primos
	
	j exit

gerar_primos: # Verificar se t0 é primo, se for, adicionar na lista de primos
	# t3 comporta o endereço base do vetor, t0 o contador e t1 o total de iterações
	bgt $t0, $t1,  end_gerar_primos # t0 > 1000 jump to end_gerar_primos
	add $t3, $t6, $zero # t3 = t6 (endereço base do vetor)

	jal e_primo
	
	addi $t0, $t0, 2 # Apenas os numeros impares são primos. Lembre-se que t3 começa no valor 3
	j gerar_primos
end_gerar_primos:
	add $t3, $zero, $t6
	j encontrar_gemeos
	
e_primo: # Se t0 for divisivel por algum primo da lista, então t0 não é primo, caso contrário, t0 é primo
	# t4 inicialmente comporta o valor no endereço de t3 e depois comparta o resto da divisão de t0 pelo valor em t3
	lw $t4, 0($t3) # t4 = t3[i]
	bgt $t0, $t1,  end_gerar_primos
	beqz $t4, end_e_primo # t3 = 0 (Significa que chegou ao fim da lista de primos
	
	div $t0, $t4 
	mfhi $t4
	beqz $t4, nao_e_primo # Se a divisão for diferente de 0, então o número não é divisível por esse primo. Continua até chegar no final da lista.
	
	addi $t3, $t3, 4 # t3 = $t3 + 4 -> pula para o próximo indice do vetor
	j e_primo
end_e_primo:# Note que em t3 está o final da lista de primos. Esse label só é chamado se chegar ao final da lista
	sw $t0, 0($t3) # Armazena o primo na lista
	jr $ra
nao_e_primo: # t3 recebe o valor base da lista de primo e t0 é incrementado. Isso é feito até que encontre um primo
	addi $t0, $t0, 2
	add $t3, $t6, $zero # t3 = t6 (endereço base do vetor)
	j e_primo

encontrar_gemeos:# A ideia dessa função é verificar se t3[i] e t3[i+1] tem diferença de 2, se sim, adicionar na lista de primos gemeos, se não, incrementar i em 1
	lw $t4, 0($t3) # t4 = t3[i]
	lw $t5, 4($t3) # t5 = t3[i+1]	
	beqz $t5, end_encontrar_gemeos
	
	sub $t2, $t5, $t4 # t2 = t5 - t4 (t3[i+1] sempre maior que t3[i])
	beq $t2, 2, e_gemeos # se for gemeos
	
	# Se não
	addi $t3, $t3, 4
	j encontrar_gemeos
e_gemeos:
	sub $t0, $t7, 4
	lw $t0, 0($t0)
	
	beq $t0, $t4, iguais
	sw $t4, 0($t7)
	sw $t5, 4($t7)
	addi $t7, $t7, 8
	addi $t3, $t3, 4
	j encontrar_gemeos
iguais:
	sw $t5, 0($t7)
	addi $t7, $t7, 4
	addi $t3, $t3, 4
	j encontrar_gemeos
	
end_encontrar_gemeos: 
	la $t7, gemeos
	j print_gemeos

print_gemeos:
	lw $a0, 0($t7)
	beqz $a0, end	
	
	addi $v0, $zero, 1
	syscall
	
	addi $v0, $zero, 4
	la $a0, separacao
	syscall
	
	addi $t7, $t7, 4
	j print_gemeos
end:
	j exit
	
exit:
	addi $v0, $zero, 10
	syscall          
