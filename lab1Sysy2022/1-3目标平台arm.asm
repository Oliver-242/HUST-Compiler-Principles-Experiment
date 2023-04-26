    .arch armv7-a
	.text
	.global	bubblesort
	.syntax unified
	.thumb
	.thumb_func
bubblesort:
	movs	r2, #0					
	subs	r1, r1, #1				
	push	{r4, r5, r6, r7, lr}
LOOPSTART:
	cmp	r1, r2
	ble	FUNCEND
	mov	r3, r0						
	movs	r4, #0					
	subs	r7, r1, r2				
	b	LOOPI
LOOPJ:
	ldrd	r5, r6, [r3]
	adds	r4, r4, #1
	cmp	r5, r6
	it	gt
	strdgt	r6, r5, [r3]
	adds	r3, r3, #4
LOOPI:
	cmp	r4, r7						
	blt	LOOPJ
	adds	r2, r2, #1				
	b	LOOPSTART
FUNCEND:
	movs	r0, #0
	pop	{r4, r5, r6, r7, pc}

	bx	lr

