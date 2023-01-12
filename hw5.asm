############## FULL NAME ##############
############## SBUID #################
############## NETID ################

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:
.globl create_term
create_term:
    
    move $t0, $a0
    move $t1, $a1
    beqz $t0, cTermError
    bltz $t1, cTermError
    
    li $a0, 12
    li $v0, 9
    syscall
    move $t2, $v0
    sw $t0, 0($t2)
    addi $t2, $t2, 4
    sw $t1, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0
    sw $t3, 0($t2)
    j cTermDone
    
    cTermError:
    	li $v0, -1
    	j cTermDone
    	
    cTermDone:
    	jr $ra

.globl create_polynomial
create_polynomial:
    addi $sp $sp, -8
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    
    move $t0, $a0
    lw $s1, 0($t0)
    beqz $s1, retNull
    
    move $t1, $t0
    cpCheckInvalid:
    	lw $t2, 0($t1)
    	lw $t3, 4($t1)
    	
    	beqz $t2, cpLoop1
    	bltz $t3, retNull
    	addi $t1, $t1, 8
    	j cpCheckInvalid
    	
    cpLoop1:
    	li $t6, -2
    	lw $t1, 0($t0)
    	beqz $t1, cpNext
	addi $t0, $t0, 4
	lw $t2, 0($t0)
	
	addi $t0, $t0, 4
	move $t3, $t0
	
	cpLoop2:
	    lw $t4, 0($t3)
	    beqz $t4, cpLoop1
	    addi $t3, $t3, 4
	    lw $t5, 0($t3)
	    addi $t3, $t3, 4
	    beq $t2, $t5, addExp
	    j cpLoop2
	       	
	addExp:
	    add $t1, $t1, $t4
	    addi $t0, $t0, -8
	    sw $t1, 0($t0)
	    addi $t0, $t0, 8
	    
	    addi $t3, $t3, -4
	    sw $t6, 0($t3)
	    addi $t3, $t3, 4

	    j cpLoop2
    cpNext:    
    	move $t0, $a0
    	move $s0, $a0
    	li $t9, 0 #counter
    	li $t8, -1
    	
    	lw $t1, 0($t0)
    	addi $t0, $t0, 4
    	lw $t2, 0($t0)
    	addi $t0, $t0, 4
    	li $a0, 12
    	li $v0, 9
    	syscall
    	
    	move $s1, $v0
    	move $t3, $v0
    	sw $t1, 0($t3)
    	addi $t3, $t3, 4
    	sw $t2, 0($t3)
    	addi $t3, $t3, 4
    	
    	cpLoop3:
    	lw $t1, 0($t0)
    	addi $t0, $t0, 4
    	beqz $t1, retCp
    	lw $t2, 0($t0)
    	addi $t0, $t0, 4
    	beq $t6, $t2, cpLoop3
    	li $a0, 12
    	li $v0, 9
    	syscall
    	
    	sw $v0, 0($t3) #store new address to the term before
    	
    	move $t3, $v0 
    	sw $t1, 0($t3)
    	addi $t3, $t3, 4
    	sw $t2, 0($t3)
    	addi $t3, $t3, 4
    	addi $t9, $t9, 1
    	j cpLoop3
    	
    retCp:	
    	li $t8, 0
    	sw $t8, 0($t3)
    	addi $t9, $t9, 1
    	li $a0, 8
    	li $v0, 9
    	syscall
    	
    	move $t0, $v0
    	sw $s1, 0($t0)
    	addi $t0, $t0, 4
    	sw $t9, 0($t0)
    	
    	lw $s0, 0($sp)
    	lw $s1, 4($sp)
    	addi $sp, $sp, 8
    	jr $ra
    	
    retNull:
    	li $v0, 0
    	lw $s0, 0($sp)
    	lw $s1, 4($sp)
    	addi $sp, $sp, 8
    	jr $ra

.globl sort_polynomial
sort_polynomial:
    move $t0, $a0
    lw $t1, 0($t0)
    lw $t2, 4($t0)
    li $t9, 1 #counter
    spLoop1:
    li $t3, 1 #counter for inner
    beq $t9, $t2, spNext
    lw $t1, 0($t0)
    
    spLoop2:
        beq $t3, $t2, spInc
        lw $t4, 0($t1)
        lw $t5, 4($t1)
        lw $t6, 8($t1)
        lw $t7, 0($t6)
        lw $t8, 4($t6)
        bgt $t8, $t5, swap
        addi $t1, $t1, 12
        addi $t3, $t3, 1
        j spLoop2
        
        swap:
            sw $t4, 0($t6)
            sw $t5, 4($t6)
            sw $t7, 0($t1)
            sw $t8, 4($t1)
            addi $t1, $t1, 12
            addi $t3, $t3, 1
            j spLoop2
    	spInc:
    	    addi $t9, $t9, 1
    	    j spLoop1
    spNext:
    	jr $ra

.globl add_polynomial
add_polynomial:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    beqz $a0, checkOther
    beqz $a1, retA0
    
    jal sort_polynomial
    move $s0, $a0
    move $a0, $a1
    
    jal sort_polynomial
    move $a1, $a0
    move $a0, $s0
    
    lw $s0, 0($a0) #p address
    lw $s1, 4($a0) #p length
    lw $s2, 0($a1) #q address
    lw $s3, 4($a1) #q length
    
    move $t0, $s0
    move $t1, $s2
    
    li $t2, 0 #counter1
    li $t3, 0 #counter2
    
    li $a0, 8
    li $v0, 9
    syscall
    move $s5, $v0 #poly
    
    li $a0, 12
    li $v0, 9
    syscall
    move $s6, $v0 # head term
    sw $s6, 0($s5)
    li $t9, 0 #length counter
    apLoop1:
    	bne $t2, $s1,checkQ
    	bne $t3, $s3,getQ
    	j finishAdd
    	
    	checkQ:
    	beq $t3, $s3, getP
    	lw $t4, 4($t0)
    	lw $t5, 4($t1)
    	beq $t4, $t5, mergeTerm
    	bgt $t5, $t4, getQ
    	
    	getP:
    	lw $t4, 4($t0)
    	
    	lw $t6, 0($t0)
    	sw $t6, 0($s6)
    	sw $t4, 4($s6)
    	lw $t7, 8($t0)
    	move $t0, $t7
    	addi $t2, $t2, 1
    	
    	j apNext
    	
    	getQ:
    	lw $t5, 4($t1)
    	
    	lw $t6, 0($t1)
    	sw $t6, 0($s6)
    	sw $t5, 4($s6)
    	lw $t7, 8($t1)
    	move $t1, $t7
    	addi $t3, $t3, 1
    	j apNext
    	
    	mergeTerm:
    	lw $t6, 0($t0)
    	lw $t7, 0($t1)
    	add $t6, $t6, $t7
    	beqz $t6, skipZero
    	sw $t6, 0($s6)
    	sw $t4, 4($s6)
    	lw $t6, 8($t0)
    	lw $t7, 8($t1)
    	move $t0, $t6
    	move $t1, $t7
    	addi $t2, $t2, 1
    	addi $t3, $t3, 1
    	j apNext
    	
    	skipZero:
    	    addi $t2, $t2, 1
    	    addi $t3, $t3, 1
    	    lw $t6, 8($t0)
    	    lw $t7, 8($t1)
    	    move $t0, $t6
    	    move $t1, $t7
    	    j apLoop1
    	    
    	apNext:
    	    li $a0, 12
    	    li $v0, 9
    	    syscall
    	    sw $v0, 8($s6)
    	    move $s6, $v0
    	    addi $t9, $t9, 1
    	    j apLoop1
    	    
    finishAdd:
    	li $t8, 0
    	sw $t8, 8($s6)
    	sw $t9, 4($s5)
    	move $v0, $s5
    	j doneAdd
    
    checkOther:
    	beqz $a1, retEmpty
  	j retA1
    
    retEmpty:
    	li $a0, 8
    	li $v0, 9
    	syscall
    	li $t9, 0
    	sw $t9, 0($v0)
    	sw $t9, 4($v0)
    	j doneAdd
    	
    retA0:
    	jal sort_polynomial
    	j doneAdd
    	
    retA1:
    	move $a0, $a1
    	jal sort_polynomial
    	j doneAdd
    	
    doneAdd:
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	jr $ra

.globl mult_polynomial
mult_polynomial:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    beqz $a0, retEmptyM
    beqz $a1, retEmptyM
    
    jal sort_polynomial
    move $s0, $a0
    move $a0, $a1
    
    jal sort_polynomial
    move $a1, $a0
    move $a0, $s0
    
    lw $s0, 0($a0) #p address
    lw $s1, 4($a0) #p length
    lw $s2, 0($a1) #q address
    lw $s3, 4($a1) #q length
    
    move $t0, $s0
    move $t1, $s2
    
    li $a0, 8
    li $v0, 9
    syscall
    move $s5, $v0 #poly
    
    li $a0, 12
    li $v0, 9
    syscall
    move $s6, $v0 # head term
    sw $s6, 0($s5)
    
    li $t5, 0
    mpLoop1:
    	lw $t2, 0($t0)
    	lw $t3, 4($t0)
    	
    	mpLoop2:
    	    lw $t4, 0($t1)
    	    lw $t6, 4($t1)
    	    lw $t7, 8($t1)
    	    mul $t8, $t2, $t4
    	    add $t9, $t3, $t6
    	    sw $t8, 0($s6)
    	    sw $t9, 4($s6)
    	    
    	    li $a0, 12
    	    li $v0, 9
    	    syscall
    	    move $t4, $v0
    	    sw $t4, 8($s6)
    	    move $s6, $t4
    	    addi $t5, $t5, 1
    	    beqz $t7, mpCont
    	    
    	    lw $t4, 8($t1)
    	    move $t1, $t4
    	    j mpLoop2 
    	    
    	mpCont:
    	    lw $t4, 8($t0)
    	    beqz $t4, mpSort
    	    move $t0, $t4
    	    move $t1, $s2
    	    j mpLoop1
    	    
    mpSort:
    	sw $t4, 8($s6)
    	sw $t5, 4($s5)
    	move $t9, $t5
    	move $a0, $s5
    	jal sort_polynomial
    	move $t0, $a0
    	
    	lw $t1, 0($t0)
	li $t8, -1
	
    mpAddLoop:
    	lw $t2, 0($t1)
    	lw $t3, 4($t1)
    	lw $t4, 8($t1)
    	beqz $t4, endMpAdd
    	
    	mpAddLoop2:
    	    lw $t5, 0($t4)
    	    lw $t6, 4($t4)
    	    lw $t7, 8($t4)
    	    bne $t3, $t6, skipAdd
    	    add $t2, $t2, $t5
    	    sw $t2, 0($t1)
    	    sw $t7, 8($t1)
    	    move $t4, $t7
    	    addi $t9, $t9, -1
    	    j mpAddLoop2
    	skipAdd:
    	move $t1, $t4
    	j mpAddLoop
    	
    endMpAdd:
    	beqz $t9, retEmptyM
    	sw $t9, 4($s5)
    	move $v0, $s5
    	j doneMult
    		    	    
    retEmptyM:
    	li $a0, 8
    	li $v0, 9
    	syscall
    	li $t9, 0
    	sw $t9, 0($v0)
    	sw $t9, 4($v0)
    	j doneMult
    doneMult:
        lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	jr $ra
