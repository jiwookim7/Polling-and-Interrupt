.data
asciiZero: .byte '0'

.text
main:
	lui $t0, 0Xffff
	lw $t1, 0($t0)
	ori $t1, $t1, 0x0002
	sw $t1, 0($t0)
	
	li $s1, 0
	li $s2, 4
	
Loop:
	addi $t1, $t1, 0
	beq $s0, $0, Loop
	
	bge $s1, $s2, sum
	j Loop
	

.ktext 0x80000180

	sw $at, _k_save_at
	sw $t0, _k_save_t0
	sw $t1, _k_save_t1
	sw $t2, _k_save_t2
	sw $t3, _k_save_t3
	

#read one char from receiver

	lui $t0, 0Xffff
	lw $t1, 0($t0)
	andi $t1, $t1, 0X0001
	beq $t1, $zero, EXIT #go to last block for recover
	lw $t2, 4($t0)	#t2 store the char that user touch the keyboard
	
	lw $t7, explen
	la $t8, expbuff
	
	# lw $v0, 4($t2)
	sb $t2, 0($t8) #store the $t8 bite to $t2
	addi $t7, $t7, 1
	sw $t7, explen
	add $t8, $t8, $t7
	
	bne $t7, 4, print
	
	li $v0, 1
	
	
	li $v0, 1
	move $a0,$t7
	syscall
	
	Loop2:
		
	beqz $t6, exit
	sb $t6,12($t0)
	
	EXIT:
	
	lw $at, _k_save_at
	lw $t0, _k_save_t0
	lw $t1, _k_save_t1
	lw $t2, _k_save_t2
	lw $t3, _k_save_t3
	
	eret 


sum:
	
	la $t7, explen #load the address of the exp to $t3
	lb $a0,($t7)
	jal char2num #jump and connect to the loop char2num
	
	move $t8, $v0
	addi $t7, $t7, 2
	
	lb $a0,($t7)
	
	jal char2num
	
	move $t5, $v0
	
	#add two digits
	add $t8, $t8, $t5
	li $t5,9
	#two digits, then goto doubleDigits
	bgt $t8,$t5,doubleDigits
	#one digit then goto singleDigit
	j singleDigit
	

doubleDigits:
	# jump and link to the loop char2num
	li $a0,1
	jal num2char
	move $t5, $v0
	addi $t7, $t7, 2
	sb $t5,($t7)
	subi $t8,$t8,10
	subi $t7, $t7, 1
	
singleDigit:
	move $a0, $t8
	jal num2char
	addi $t7, $t7, 2
	sb $v0,($t7)
	lui $t0, 0xffff
	la $t7, explen
	lb $t6,($t7)
	
print:
	lw $t1, 8($t0)
	andi $t1, $t1, 0x0001
	
	beq $t1, $zero, print
	addi $t7, $t7, 1
	lb $t6,($t7)
	
	j Loop2
	
exit:
	li $v0,10
	syscall
	
	
#converts ascii char to num
char2num:
lb $t0, asciiZero
subu $v0, $a0, $t0
jr $ra

#converts the num to ascii char
num2char:
lb $t0, asciiZero
addu $v0, $a0, $t0
jr $ra

.kdata 

	_k_save_at: .word 0
	_k_save_t0: .word 0
	_k_save_t1: .word 0
	_k_save_t2: .word 0
	_k_save_t3: .word 0
	
expbuff: .space 80 # 20chars
explen: .word 0 #(exp length stored).




	

	