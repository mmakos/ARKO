# $s0 - deskryptor pliku input
# $s1 - deskryptor pliku output
# $s2 - szerokosc w px
# $s3 - licznik linijek pozostalych do wczytania
# $s4 - szerokosc w bajtach z paddingiem
# $s5 - padding


	.data
	.align 2
	
buffer:	.space 30000
line:	.space 10009
med:	.space 9
input:	.space 100
output:	.space 100

hello:	.asciiz	"Witaj w programie do filtrowania medianowego.\n"
namein:	.asciiz "Podaj nazwe pliku wejsciowego: "
nameou:	.asciiz "Podaj nazwe pliku wyjsciowego: "
errStr:	.asciiz "Blad przy obsludze pliku"
nthStr: .asciiz "Nie ma czego filtrowac!!!"

	.text
	.globl main
	
main:
	la $a0, hello		# Powitanie
	li $v0, 4
	syscall
	
	la $a0, namein
	li $v0, 4
	syscall
	
	li $v0, 8
	la $a0, input
	li $a1, 100
	syscall
	
	la $t0, input
convertFileName:
	addi $t0, $t0, 1
	lb $t1, ($t0)
	bne $t1, '\n', convertFileName
	la $t1, 0x2e
	sb $t1, ($t0)
	addi $t0, $t0, 1
	la $t1, 0x62
	sb $t1, ($t0)
	addi $t0, $t0, 1
	la $t1, 0x6d
	sb $t1, ($t0)
	addi $t0, $t0, 1
	la $t1, 0x70
	sb $t1, ($t0)
	addi $t0, $t0, 1
	la $t1, 0x0
	sb $t1, ($t0)
	
	la $a0, nameou
	li $v0, 4
	syscall
	
	li $v0, 8
	la $a0, output
	li $a1, 100
	syscall
	
	la $t0, output
convertFileName2:
	addi $t0, $t0, 1
	lb $t1, ($t0)
	bne $t1, '\n', convertFileName2
	la $t1, 0x2e
	sb $t1, ($t0)
	addi $t0, $t0, 1
	la $t1, 0x62
	sb $t1, ($t0)
	addi $t0, $t0, 1
	la $t1, 0x6d
	sb $t1, ($t0)
	addi $t0, $t0, 1
	la $t1, 0x70
	sb $t1, ($t0)
	addi $t0, $t0, 1
	la $t1, 0x0
	sb $t1, ($t0)
	
loadBmp:
	la $a0, input		# Opening input file
	li $a1, 0
	li $a2, 0
	li $v0, 13
	syscall
	
	move $s0, $v0		# $s0 - deskryptor pliku input
	bltz $s0, error
	
	la $a0, output		# making output file 
	li $a1, 1
	li $a2, 0
	li $v0, 13
	syscall
		
	move $s1, $v0		# $s1 - deskryptor pliku output
	bltz $s1, error
	
ReadAndWrite:
	move $a0, $s0		# odczyt BM, size i bajtów sta³ych
	la $a1, buffer
	li $a2, 18
	li $v0, 14
	syscall
	
	move $a0, $s1		# przepisanie powy¿szych do pliku output
	la $a1, buffer
	li $a2, 18
	li $v0, 15
	syscall
	
Width:
	move $a0, $s0		# odczyt szerokosci
	la $a1, buffer		
	li $a2, 4
	li $v0, 14
	syscall
	
	lw $s2, buffer		# $s2 - szerokosc bez paddingu w px
	
	move $a0, $s1		# przepisanie szerokosci do pliku output
	la $a1, buffer
	li $a2, 4
	li $v0, 15
	syscall
	
Height:
	move $a0, $s0		# odczyt wysokosci
	la $a1, buffer		
	li $a2, 4
	li $v0, 14
	syscall
	
	lw $s3, buffer		# $s3 - wysokosc w px
	
	move $a0, $s1		# przepisanie wysokosci do pliku output
	la $a1, buffer
	li $a2, 4
	li $v0, 15
	syscall
	
If2x2:
	ble $s2, 2, Nothing
	ble $s3, 2, Nothing
	
AddPadding:
	mul $t0, $s2, 3		# zamiana szerokosci na bajty
	andi $t1, $t0, 3 	# reszta z dzielenia przez 4
	move $s5, $zero		# brak paddingu
	beqz $t1, Rest		
	li $t2, 4
	sub $s5, $t2, $t1	# $s5 - padding
	
Rest:
	add $s4, $t0, $s5	# $s4 - szerokoœæ w bajtach z paddingiem
	
	move $a0, $s0		# odczyt reszty (az do mapy)
	la $a1, buffer
	li $a2, 28
	li $v0, 14
	syscall
	
	move $a0, $s1		# zapis reszty
	la $a1, buffer
	li $a2, 28
	li $v0, 15
	syscall
	
	move $s6, $zero		# $s6 - licznik bitow wpisanych do bufora zapisu
	
#-----PIERWSZE CZYTANIE--------------------------#
FirstRead:
	la $t1, line		# $t1 - skoczek po buforze zapisu
				# $s3 - licznik linijek pozostalych do wczytania
	li $t0, 30000
	div $t0, $t0, $s4	# ile linijek mo¿emy wczytaæ
	bge $t0, $s3, ReadToEnd
	
	sub $s3, $s3, $t0	# dekrementujemy licznik 
	move $s7, $t0		# s7 - ile linijek wczytalismy
	mul $t0, $t0, $s4	# ile bajtow wczytujemy
	j read

ReadToEnd:
	move $s7, $s3
	mul $t0, $s3, $s4	# do wczytania tylko to co zostalo
	move $s3, $zero
	
read:
	move $a0, $s0
	la $a1, buffer
	la $a2, ($t0)
	li $v0, 14
	syscall
	
writeFirstLine:
	move $a0, $s1
	la $a1, buffer
	la $a2, ($s4)
	li $v0, 15
	syscall
	
	
	subi $s7, $s7, 2
	
	j ProcessPortion
	
#-----------------------WCZYTYWANIE ALE NIE 1---------------#

readNextPortion:		# $s3 - licznik linijek pozostalych do wczytania
	li $t0, 30000
	sub $t0, $t0, $s4
	sub $t0, $t0, $s4
	div $t0, $t0, $s4	# ile linijek mo¿emy wczytaæ
	bge $t0, $s3, ReadToEnd2
	
	sub $s3, $s3, $t0	# dekrementujemy licznik 
	move $s7, $t0		# s7 - ile linijek wczytalismy
	mul $t0, $t0, $s4	# ile bajtow wczytujemy
	j read2

ReadToEnd2:
	move $s7, $s3
	mul $t0, $s3, $s4	# do wczytania tylko to co zostalo
	move $s3, $zero
	
read2:
	move $a0, $s0
	la $a1, buffer
	add $t2, $s4, $s4
	add $a1, $a1, $t2
	la $a2, ($t0)
	li $v0, 14
	syscall

ProcessPortion:
	la $t0, buffer		# t0 - skoczek po buforze
	add $t0, $t0, $s4	# Ustawiamy na 2 linijke
	
LINE:	# przerobienie lini z $t0
	la $t2, med		# t2 - skoczek po wartosciach mediany
	
	move $t9, $s4		# t8 - licznik bitow przerobionych ( malejacy )
	subi $t9, $t9, 6
	sub $t9, $t9, $s5	# pomniejszamy o bajty pocz, konc i o padding
	
writeFirtPx:
	lbu $t6, ($t0)
	sb $t6, ($t1)
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	lbu $t6, ($t0)
	sb $t6, ($t1)
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	lbu $t6, ($t0)
	sb $t6, ($t1)
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	addi $s6, $s6, 3
	
countPx:
	lbu $t6, ($t0)
	sb $t6, ($t2)		# (0,0)
	addi $t2, $t2, 1
	sub $t0, $t0, $s4
	
	lbu $t6, ($t0)
	sb $t6, ($t2)		# (0,1)
	addi $t2, $t2, 1
	subi $t0, $t0, 3
	
	lbu $t6, ($t0)
	sb $t6, ($t2)		# (-1,1)
	addi $t2, $t2, 1
	addi $t0, $t0, 6
	
	lbu $t6, ($t0)
	sb $t6, ($t2)		# (1,1)
	addi $t2, $t2, 1
	add $t0, $t0, $s4
	
	lbu $t6, ($t0)
	sb $t6, ($t2)		# (1,0)
	addi $t2, $t2, 1
	subi $t0, $t0, 6
	
	lbu $t6, ($t0)
	sb $t6, ($t2)		# (-1,0)
	addi $t2, $t2, 1
	add $t0, $t0, $s4
	
	lbu $t6, ($t0)
	sb $t6, ($t2)		# (-1,-1)
	addi $t2, $t2, 1
	addi $t0, $t0, 3
	
	lbu $t6, ($t0)
	sb $t6, ($t2)		# (0,-1)
	addi $t2, $t2, 1
	addi $t0, $t0, 3
	
	lbu $t6, ($t0)
	sb $t6, ($t2)		# (1,-1)
	subi $t2, $t2, 8
	subi $t0, $t0, 3
	sub $t0, $t0, $s4
	
#--------------------DZIALA---------------#	uzywa rej. t3 - t8
	addi $t3, $zero, 0
	move $t6, $zero		# min obecna

findMed:
	li $t5, 256		# min z 9
	move $t4, $zero
	
inLoop:
	lbu $t7, ($t2)
	addi $t4, $t4, 1
	bge $t7, $t5, nextByte
	blt $t7, $t6, nextByte
	move $t5, $t7
	move $t8, $t2
	
nextByte:
	addi $t2, $t2, 1
	blt $t4, 9, inLoop
	li $t7, 255
	sb $t7, ($t8)
	move $t6, $t5
	subi $t2, $t2, 9
	addi $t3, $t3, 1
	blt $t3, 5, findMed
#--------------Med w $t6 ------------------------#

	sb $t6, ($t1)
	addi $t1, $t1, 1
	addi $t0, $t0, 1
	subi $t9, $t9, 1
	addi $s6, $s6, 1		# licznik bajtow w buforze
	blt $s6, 10000, jumpCount
	
storeBufferEnd:
	move $a0, $s1		# zapis wszystkiego z bufora
	la $a1, line
	la $a2, ($s6)
	li $v0, 15
	syscall
	
	move $s6, $zero
	la $t1, line
	
jumpCount:
	bnez $t9, countPx
	
writeLastPxAndPadd:
	lbu $t6, ($t0)
	sb $t6, ($t1)
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	lbu $t6, ($t0)
	sb $t6, ($t1)
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	lbu $t6, ($t0)
	sb $t6, ($t1)
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	addi $s6, $s6, 3
	
	move $t2, $s5		#licznik - ile paddingu zostalo do dodania
addPadding:
	beqz $t2, afterPadd
	sb $zero, ($t1)
	addi $t1, $t1, 1
	subi $t2, $t2, 1
	addi $s6, $s6, 1
	j addPadding
	
afterPadd:
	add $t0, $t0, $s5	# teraz t0 jest na kolejnej linijce
	
	subi $s7, $s7, 1
	bnez $s7, LINE			# nastepna linia
	beqz $s3, writeLastLine		# zapis ostatniej lini i konczymy

shiftBuffer:
	la $t4, buffer			# docelowe miejsce
	sub $t0, $t0, $s4		# pierwotne miejsce
	div $t2, $s4, 2			# $t2 - licznik slow pozostalych do przesuniecia
	
shiftWord:
	lw $t3, ($t0)
	sw $t3, ($t4)
	addi $t0, $t0, 4
	addi $t4, $t4, 4
	subi $t2, $t2, 1
	bnez $t2, shiftWord
	
	j readNextPortion
	
writeLastLine:
	move $a0, $s1		# zapis wszystkiego z bufora
	la $a1, line
	la $a2, ($s6)
	li $v0, 15
	syscall
	
	move $a0, $s1
	la $a1, ($t0)
	la $a2, ($s4)
	li $v0, 15
	syscall
	
	j end
	
	
#------------------END-----------------------------------#
error:
	la $a0, errStr
	li $v0, 4
	syscall
	j end

Nothing:
	la $a0, nthStr
	li $v0, 4
	syscall

end:
	move $a0, $s0
	li $v0, 16	# zamkniecie pliku input
	syscall
	
	move $a0, $s1
	li $v0, 16	# zamkniecie pliku output
	syscall