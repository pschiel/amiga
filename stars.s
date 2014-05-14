;---------------------------------------------------------------------

waitvb	macro
	move.l	$dff004,d0
	and.l	#$1ff00,d0
	cmp.l	#$01000,d0
	bne.b	*-18
	endm
waitblt	macro
	btst	#14,$dff002
	bne.b	*-8
	endm

;---------------------------------------------------------------------

init:
	move.l	4.w,a6
	lea	vars(pc),a5
	move.l	#copend-coplist,d0
	moveq	#2,d1
	jsr	-198(a6)
	move.l	d0,cop(a5)
	beq.w	q2
	move.l	d0,a2
	move.l	d0,a0
	lea	coplist(pc),a1
	move.w	#(copend-coplist)/2-1,d0
i1	move.w	(a1)+,(a0)+
	dbf	d0,i1
	
	move.l	#40*200*2,d0
	move.l	#$10002,d1
	jsr	-198(a6)
	move.l	d0,bpl(a5)
	beq.w	q1
	
	move.w	d0,copbpl-coplist+6(a2)
	swap	d0
	move.w	d0,copbpl-coplist+2(a2)
	
	move.w	#$4000,$dff09a
	move.b	#$87,$bfd100
	
	waitvb
	move.w	#$0020,$dff096
	move.w	#$83c0,$dff096
	
	move.l	cop(a5),$dff080
	clr.w	$dff088
	
	move.l	bpl(a5),d6
	move.l	d6,d7
	add.l	#40*200,d7
	
	move.l	#$7f618e2,rndseed(a5)	; random star position
	lea	starxyd(pc),a2
	moveq	#79,d2
i2	move.w	#250,d0
	bsr.w	rnd
	sub.w	#125,d0
	move.w	d0,(a2)+
	move.w	#160,d0
	bsr.w	rnd
	sub.w	#80,d0
	move.w	d0,(a2)+
	move.w	#256,(a2)+
	dbf	d2,i2
	
;---------------------------------------------------------------------
	
loop:
	waitvb				; double buffering
	exg	d6,d7
	move.l	cop(a5),a0
	swap	d6			; set at next vb
	move.w	d6,copbpl-coplist+2(a0)
	swap	d6
	move.w	d6,copbpl-coplist+6(a0)
	
	waitblt				; clear bitplane
	move.l	#$01000000,$dff040
	clr.w	$dff066
	move.l	d6,$dff054
	move.w	#200*64+20,$dff058
	waitblt
	
	lea	starxyd(pc),a2
	moveq	#79,d3
l1	move.w	(a2),d0
	move.w	2(a2),d1
	move.w	4(a2),d2
	ble.b	l3
	ext.l	d0
	ext.l	d1
	asl.w	#8,d0
	asl.w	#8,d1
	divs	d2,d0
	divs	d2,d1
	
	cmp.w	#-160,d0
	ble.b	l3
	cmp.w	#160,d0
	bge.b	l3
	cmp.w	#-100,d1
	ble.b	l3
	cmp.w	#100,d1
	bge.b	l3
	bra.b	l2
	
l3	move.w	#200,d0
	bsr.w	rnd
	sub.w	#100,d0
	move.w	d0,(a2)
	move.w	#100,d0
	bsr.w	rnd
	sub.w	#50,d0
	move.w	d0,2(a2)
	move.w	#260,4(a2)
	move.w	(a2),d0
	move.w	2(a2),d1
	
l2	subq.w	#4,4(a2)
	add.w	#160,d0
	add.w	#100,d1
	bsr.w	point
	addq.l	#6,a2
	dbf	d3,l1
	;move.w	#$fff,$dff180
	btst	#6,$bfe001
	bne.w	loop
	
;---------------------------------------------------------------------

quit:
	move.l	378(a6),a0
	lea	gfxname(pc),a1
	jsr	-276(a6)
	move.l	d0,a0
	move.l	38(a0),$dff080
	clr.w	$dff088
	move.w	#$8020,$dff096
	
	move.l	bpl(a5),a1
	move.l	#40*200*2,d0
	jsr	-210(a6)
	
q1	move.l	cop(a5),a1
	move.l	#copend-coplist,d0
	jsr	-210(a6)
	
q2	moveq	#0,d0
	rts

;---------------------------------------------------------------------

point:
	move.l	d6,a0
	move.w	d1,d2
	lsl.w	#5,d1			; y*32
	lsl.w	#3,d2			; y*8
	add.w	d2,d1			; y*40
	move.w	d0,d2
	not.w	d2
	and.w	#7,d2			; 7-(x mod 8)
	lsr.w	#3,d0			; x div 8
	add.w	d0,d1
	bset	d2,(a0,d1.w)
	rts

;---------------------------------------------------------------------
	
rnd:
	move.w	d0,d1
	move.l	rndseed(a5),d0
	add.l	d0,d0
	bhi.b	rnd1
	eor.l	#$1d872b41,d0
rnd1	move.l	d0,rndseed(a5)
	and.l	#$ffff,d0
	divu	d1,d0
	swap	d0
	rts
	
;---------------------------------------------------------------------

coplist	dc.w	$8e,$3081,$90,$f8c1,$92,$38,$94,$d0
	dc.w	$100,$1200,$108,0,$102,0
copbpl	dc.w	$e0,0,$e2,0
	dc.w	$182,$888
	dc.w	$300f,-2,$180,$004
	dc.w	$f80f,-2,$180,$000
	dc.w	-1,-2
copend

gfxname	dc.b	"graphics.library",0
	even

	rsreset
cop	rs.l	1
bpl	rs.l	1
rndseed	rs.l	1
vsize	rs.b	0

starxyd	blk.w	80*3

vars	blk.b	vsize

