        .text
        .align  1
        .globl  bubblesort
        .type   bubblesort, @function
bubblesort:


	li		a2, 0			
	addiw	a1, a1, -1		
	addi	sp, sp, -20
	sw		a4, 0(sp)
	sw		a5, 4(sp)
	sw		a6, 8(sp)
	sw		a7, 12(sp)
	sw		ra, 16(sp)
LOOPSTART:
	ble		a1, a2, FUNCEND
	mv		a3, a0				
	li		a4, 0			
	sub		a7, a1, a2			
LOOPI:
	blt		a4, a7, LOOPJ
	addi	a2, a2, 1			
	j		LOOPSTART
LOOPJ:
	lw		a5, 0(a3)			
	lw		a6, 4(a3)
	addi	a4, a4, 1
	ble     a5, a6, SKIP			
	sw		a6, 0(a3)		
	sw		a5, 4(a3)
	addi	a3, a3, 4
	j		LOOPI
SKIP:
	addi	a3, a3, 4
	j		LOOPI
FUNCEND:
	li		a0, 0
	lw		a4, 0(sp)
	lw		a5, 4(sp)
	lw		a6, 8(sp)
	lw		a7, 12(sp)
	lw		ra, 16(sp)
	addi	sp, sp, 20
	ret

    .size   bubblesort, .-bubblesort
