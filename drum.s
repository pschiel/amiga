init:
	bset	#1,$bfe001
	lea	start(pc),a0
	move.l	a0,$80.w
	trap	#0
	bclr	#1,$bfe001
	rts

start:
	lea	drumdat(pc),a0
	add.l	#planes-drumdat,a0
	move.l	a0,d0
	lea	cop-planes(a0),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#80*200,d0
	move.w	d0,14(a0)
	swap	d0
	move.w	d0,10(a0)
	lea	mouse(pc),a1
	move.l	a1,d0
	lea	spr-cop(a0),a2
	swap	d0
	move.w	d0,2(a2)
	swap	d0
	move.w	d0,6(a2)
	addq.l	#8,a2
	add.l	#drumdat-mouse,d0
	moveq	#6,d1
s1	swap	d0
	move.w	d0,2(a2)
	swap	d0
	move.w	d0,6(a2)
	addq.l	#8,a2
	dbf	d1,s1
	move.l	a0,$dff080
	clr.w	$dff088
	move.w	#$8200,$dff096
	move.b	#$87,$bfd100
	bsr.b	speed
	lea	datas1(pc),a2
	bra.b	l19

speed:
	move.w	bpm(pc),d0
	move.l	#50*60*304,d1
	divu	d0,d1
	ext.l	d1
	move.w	quant(pc),d0
	divu	d0,d1
	ext.l	d1
	move.w	rhythm(pc),d0
	lsl.w	#1,d1
	divu	d0,d1
	lea	count(pc),a0
	move.w	d1,(a0)
	rts

play:
	move.w	count(pc),d1
l1	move.b	$dff006,d0
l2	cmp.b	$dff006,d0
	beq.b	l2
	dbf	d1,l1
	
l19	moveq	#0,d1
l18	move.b	(a2)+,d0
	cmp.b	#-1,d0
	bne.b	l15
	lea	datas(pc),a2
	move.b	(a2)+,d0
l15	cmp.b	#-2,d0
	bne.b	l17
	move.b	(a2)+,d0
	lea	bpm+1(pc),a0		; -2:bpm
	move.b	d0,(a0)
	bsr.b	speed
	bra.b	l18
l17	btst	#1,d0
	beq.b	l6
	moveq	#1,d1
l6	btst	#3,d0
	beq.b	l7
	or.b	#2,d1
l7	btst	#5,d0
	beq.b	l8
	or.b	#4,d1
l8	btst	#7,d0
	beq.b	l9
	or.b	#8,d1
l9	move.w	d1,$dff096		; clear channels
	move.b	$dff006,d1
	addq.b	#3,d1
l3	cmp.b	$dff006,d1		; wait
	bne.b	l3
	
	btst	#1,d0			; channel 0:
	beq.b	l4
	lea	drumdat+4(pc),a0	; bass tom
	move.w	#1288,$dff0a4
	move.w	#250,$dff0a6
	move.w	#64,$dff0a8
	btst	#0,d0
	beq.b	l5
	lea	drumdat+8964(pc),a0	; block
	move.w	#872,$dff0a4
	move.w	#200,$dff0a6
	move.w	#50,$dff0a8
l5	move.l	a0,$dff0a0
	move.w	#$8001,$dff096

l4	btst	#3,d0			; channel 1:
	beq.b	l10
	lea	drumdat+2580(pc),a0	; snare
	move.w	#2224,$dff0b4
	move.w	#260,$dff0b6
	move.w	#64,$dff0b8
	btst	#2,d0
	beq.b	l16
	lea	drumdat+8964(pc),a0	; block2
	move.w	#872,$dff0b4
	move.w	#210,$dff0b6
	move.w	#28,$dff0b8
l16	move.l	a0,$dff0b0
	move.w	#$8002,$dff096
	
l10	btst	#5,d0			; channel 2:
	beq.b	l11
	lea	drumdat+7028(pc),a0	; highhat
	move.w	#968,$dff0c4
	move.w	#220,$dff0c6
	move.w	#50,$dff0c8
	btst	#4,d0
	beq.b	l12
	lea	drumdat+10708(pc),a0	; ride
	move.w	#11004,$dff0c4
	move.w	#160,$dff0c6
	move.w	#25,$dff0c8
l12	move.l	a0,$dff0c0
	move.w	#$8004,$dff096
	
l11	btst	#7,d0			; channel 3:
	beq.b	l13
	lea	drumdat(pc),a0		; cymbal
	lea	32716(a0),a0
	move.l	a0,$dff0d0
	move.w	#12020,$dff0d4
	move.b	$dff006,d0
	divu	#20,d0
	swap	d0
	add.w	#205,d0
	move.w	d0,$dff0d6
	move.w	#32,$dff0d8
	move.w	#$8008,$dff096
	
l13	move.b	$dff006,d0
	addq.b	#3,d0
l14	cmp.b	$dff006,d0
	bne.b	l14

	lea	drumdat(pc),a0		; stop repeat
	move.l	a0,$dff0a0
	move.l	a0,$dff0b0
	move.l	a0,$dff0c0
	move.l	a0,$dff0d0
	moveq	#1,d0
	move.w	d0,$dff0a4
	move.w	d0,$dff0b4
	move.w	d0,$dff0c4
	move.w	d0,$dff0d4

	btst	#7,$bfe001
	beq.b	quit
	btst	#10,$dff016
	beq.b	quit
	cmp.b	#$7f,$bfec01
	bne.w	play
	
quit:
	move.w	#$000f,$dff096
	
	move.l	4.w,a6
	move.l	378(a6),a0
	lea	gfxname(pc),a1
	jsr	-276(a6)
	move.l	d0,a0
	move.l	38(a0),$dff080
	clr.w	$dff088
	rte

bpm	dc.w	180
rhythm	dc.w	3
quant	dc.w	4
count	dc.w	0

datas1
	dc.b	3,0,0,0,0,0,0,0
	dc.b	3,0,0,0,0,0,0,0
	dc.b	3,0,0,0,0,0,0,0
	dc.b	3,0,0,0,0,0,0,0

datas	
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$02,$02,$02,$88,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$02,$02,$02,$88,$00,$02,$00,$02,$00
	
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$02,$02,$02,$88,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$02,$02,$02,$88,$00,$02,$00,$02,$00
	
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$02,$02,$02,$88,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$02,$02,$02,$88,$00,$02,$00,$02,$00
	
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$00,$02,$00,$28,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$02,$02,$02,$88,$00,$02,$00,$02,$00
	dc.b	$22,$00,$02,$02,$02,$02,$88,$00,$02,$00,$02,$00
;datas1		

	dc.b	$32,$00,$02,$00,$02,$00,$32,$00,$02,$00,$02,$00
	dc.b	$88,$00,$00,$00,$00,$00,$32,$00,$02,$00,$02,$00
	dc.b	$38,$00,$00,$00,$00,$00,$32,$00,$02,$00,$02,$00
	dc.b	$88,$02,$02,$02,$02,$02,$88,$02,$02,$02,$02,$02

	dc.b	$32,$00,$02,$00,$02,$00,$32,$00,$02,$00,$02,$00
	dc.b	$88,$00,$00,$00,$00,$00,$32,$00,$02,$00,$02,$00
	dc.b	$38,$00,$00,$00,$00,$00,$32,$00,$02,$00,$02,$00
	dc.b	$88,$02,$02,$02,$02,$02,$88,$02,$02,$02,$02,$02

 
	dc.b	-1
gfxname	dc.b	'graphics.library',0
	even

mouse	dc.w	$a05a,$a700
	dc.w	%1111110,%1111110
	dc.w	%1111100,%0111100
	dc.w	%1111000,%0011000
	dc.w	%1111100,%0001100
	dc.w	%1101110,%0000110
	dc.w	%1000111,%0000011
	dc.w	%0000010,%0000000
	dc.w	0,0
drumdat	incbin	'df0:drum.dat'

planes	blk.b	80*200*2

cop	dc.w	$e0,0,$e2,0,$e4,0,$e6,0
	dc.w	$8e,$3081,$90,$f8c1,$92,$3c,$94,$d4
	dc.w	$100,$a200,$102,0,$108,0
	dc.w	$180,0,$182,$ccc,$184,$555,$186,$ff0,$1a2,$999,$1a6,$ddd
spr	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0,$12a,0,$12c,0,$12e,0
	dc.w	$130,0,$132,0,$134,0,$136,0,$138,0,$13a,0,$13c,0,$13e,0
	dc.l	-2

