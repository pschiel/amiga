
*********************************************************
*                                                       *
*        F I L E C O N V E R T E R   V 1 . 0            *
*       -------------------------------------           *
*                                                       *
*         Programmed 1992 by Patrick Schiel             *
*               Final release 26-Apr                    *
*                                                       *
*********************************************************
*                                                       *
*      Written on HiSoft DevPac-Assembler 2.14          *
*                                                       *
*********************************************************

;----------------------------------------------------------

main:
	lea	filenam,a0
	move	#441,d0
m2	clr.b	(a0)+
	dbf	d0,m2
	lea	diskio,a0
	move	#1079,d0
m3	clr.b	(a0)+
	dbf	d0,m3
	move.l	sp,stack
	move.l	4.w,a6
	sub.l	a1,a1
	jsr	FindTask(a6)
	move.l	d0,repport+16
	move.l	d0,a2
	tst.l	$ac(a2)
	bne.b	m1
	lea	$5c(a2),a0
	jsr	WaitPort(a6)
	jsr	GetMsg(a6)
m1	lea	repport,a1
	jsr	AddPort(a6)
	bsr	OpenTd
	bsr	OpenLibs
	bsr	InitDisplay
	bra	About

;----------------------------------------------------------

Done:
	lea	donetx(pc),a0
	bsr	Print
	bra.b	Loop

;----------------------------------------------------------

Abort:
	lea	terr(pc),a0
	bsr	Print
	bra.b	Loop

;----------------------------------------------------------

PrtLp:
	bsr	Print
	bra.b	Done
	
;----------------------------------------------------------

Loop:
	move.b	#'0',t41+22
	moveq	#0,d7
	lea	hbuf,a4
	move.l	4.w,a6
	move.l	stack(pc),sp
	move.l	win(pc),a0
	move.l	86(a0),a2
	move.l	a2,a0
	jsr	GetMsg(a6)
	tst.l	d0
	bne.b	l1
	moveq	#1,d0
	move.b	15(a2),d1
	lsl.l	d1,d0
	jsr	Wait(a6)
	bra.b	Loop
l1	move.l	d0,a1
	move.l	28(a1),a0
	move	38(a0),d2
	jsr	ReplyMsg(a6)
	lsl	#2,d2
	lea	functab-4(pc),a0
	move.l	(a0,d2),a0
	jmp	(a0)

;----------------------------------------------------------

ReadBB:
	lea	t33(pc),a0
	move.b	gad14t+8(pc),26(a0)
	bsr	Print
	move.l	#1012,d0
	moveq	#2,d1
	bsr	GetBuffer
	moveq	#0,d0
	bsr.b	ReadBlock
	lea	diskbuf,a0
	move.l	buffer(pc),a1
	move	#252,d0
rb1	move.l	(a0)+,(a1)+
	dbf	d0,rb1
	lea	t28(pc),a0
	move.l	#1012,(a4)
	bra	PrtLp

ReadBlock:
	move.l	4.w,a6
	lea	diskio,a1
	move.l	#repport,14(a1)
	move	#2,28(a1)
	move.l	#1024,36(a1)
	move.l	#diskbuf,40(a1)
	move.l	d0,44(a1)
	jsr	DoIO(a6)
	lea	diskio,a1
	move.b	31(a1),d2
	move	#9,28(a1)
	clr.l	36(a1)
	jsr	DoIO(a6)
	tst.b	d2
	bne	TdError
	rts
	
;----------------------------------------------------------

WriteBB:
	move.l	buflen(pc),d0
	beq	NoBuffer
	cmp.l	#1012,d0
	bls.b	wb1
	lea	t24(pc),a0
	sub.l	a1,a1
	lea	t22(pc),a2
	bsr	Request
	bra	Loop
wb1	lea	t35(pc),a0
	move.b	gad14t+8(pc),21(a0)
	lea	t36(pc),a1
	lea	t37(pc),a2
	bsr	Request
	beq	Loop
	lea	t38(pc),a0
	move.b	gad14t+8(pc),24(a0)
	bsr	Print
	bsr	FastToChip
	lea	diskbuf+12,a0
	move.l	buffer(pc),a1
	move	#252,d0
wb2	move.l	(a1)+,(a0)+
	dbf	d0,wb2
	
WriteBoot:
	bsr	CheckSum
	moveq	#0,d0
	bsr.b	WriteBlock
	lea	t29(pc),a0
	move.l	#1024,(a4)
	bra	PrtLp

WriteBlock:
	move.l	4.w,a6
	lea	diskio,a1
	move.l	#repport,14(a1)
	move	#3,28(a1)
	move.l	#1024,36(a1)
	move.l	#diskbuf,40(a1)
	move.l	d0,44(a1)
	jsr	DoIO(a6)
	lea	diskio,a1
	move.b	31(a1),d2
	bne.b	wbl1
	move	#4,28(a1)
	jsr	DoIO(a6)
	lea	diskio,a1
	move.b	31(a1),d2
wbl1	move	#9,28(a1)
	clr.l	36(a1)
	jsr	DoIO(a6)
	tst.b	d2
	bne	TdError
	rts

;----------------------------------------------------------

LoadExe:
	lea	gad2t(pc),a0
	bsr	FileReq
	move.l	a0,(a4)
	lea	t20(pc),a0
	bsr	Print
	move.l	dosbase(pc),a6
	move.l	(a4),d1
	move.l	#1005,d2
	jsr	Open(a6)
	move.l	d0,hdl
	beq	DosError
	move.l	a4,d2
	moveq	#4,d3
	bsr	le1
	cmp.l	#$3f3,(a4)
	beq.b	le2
	lea	t21(pc),a0
le5	sub.l	a1,a1
	lea	t22(pc),a2
	bsr	Request
	bra	Abort
le2	moveq	#4,d3
	bsr.b	le1
	move.l	(a4),d3
	beq.b	le3
	lsl	#2,d3
	bsr.b	le1
	bra.b	le2
le3	moveq	#24,d3
	bsr.b	le1
	cmp.l	#1,(a4)
	beq.b	le4
	lea	t23(pc),a0
	bra.b	le5
le4	cmp.l	#$3e9,16(a4)
	beq.b	le7
	lea	t25(pc),a0
	bra.b	le5
le7	move.l	12(a4),d0
	lsl.l	#2,d0
	move.l	d0,(a4)
	lea	t26(pc),a0
	bsr	Print
	move.l	(a4),d0
	moveq	#0,d1
	bsr	GetBuffer
	move.l	dosbase(pc),a6
	move.l	buffer(pc),d2
	move.l	buflen(pc),d3
	bsr.b	le1
	move.l	hdl(pc),d1
	jsr	Close(a6)
	clr.l	hdl
	bra	Done
le1	move.l	hdl(pc),d1
	jsr	Read(a6)
	cmp.l	d0,d3
	bne	DosError
	rts

;----------------------------------------------------------

SaveExe:
	tst.l	buflen
	beq	NoBuffer
	lea	gad6t(pc),a0
	bsr	FileReq
	move.l	a0,(a4)
	bsr	Exists
	move.l	a0,d3
	lea	t27(pc),a0
	bsr	Print
	move.l	dosbase(pc),a6
	move.l	(a4),d1
	move.l	#1006,d2
	jsr	Open(a6)
	move.l	d0,hdl
	beq	DosError
	lea	t30(pc),a0
	bsr	Print
	lea	exehdr(pc),a0
	move.l	buflen(pc),d4
	addq.l	#3,d4
	lsr.l	#2,d4
	move.l	d4,20(a0)
	move.l	d4,28(a0)
	move.l	a0,d2
	moveq	#32,d3
	bsr.b	se1
	bsr.b	se2
	lea	t31(pc),a0
	bsr	Print
	move.l	buffer(pc),d2
	lsl.l	#2,d4
	move.l	d4,d3
	bsr.b	se1
	bsr.b	se2
	lea	t73(pc),a0
	bsr	Print
	move.l	#exeend,d2
	moveq	#4,d3
	bsr.b	se1
	bsr.b	se2
	move.l	dosbase(pc),a6
	move.l	hdl(pc),d1
	jsr	Close(a6)
	clr.l	hdl
	bra	Done
se1	move.l	dosbase(pc),a6
	move.l	hdl(pc),d1
	jsr	Write(a6)
	cmp.l	d0,d3
	bne	DosError
	rts
se2	move.l	d3,(a4)
	lea	bytes(pc),a0
	bsr	Print
	rts

;----------------------------------------------------------

LoadData:
	lea	gad3t(pc),a0
	bsr	FileReq
	move.l	a0,(a4)
	move.l	a0,d3
	lea	t2(pc),a0
	bsr	Print
	move.l	dosbase(pc),a6
	move.l	d3,d1
	moveq	#-2,d2
	jsr	Lock(a6)
	move.l	d0,lck
	beq	DosError
	move.l	d0,d1
	move.l	a4,d2
	jsr	Examine(a6)
	tst.l	d0
	beq	DosError
	move.l	lck(pc),d1
	jsr	UnLock(a6)
	clr.l	lck
	move.l	124(a4),d0
	moveq	#0,d1
	bsr	GetBuffer
	move.l	dosbase(pc),a6
	move.l	d3,d1
	move.l	#1005,d2
	jsr	Open(a6)
	move.l	d0,hdl
	beq	DosError
	move.l	d0,d1
	move.l	buffer(pc),d2
	move.l	buflen(pc),d3
	jsr	Read(a6)
	cmp.l	d0,d3
	bne	DosError
	move.l	hdl(pc),d1
	jsr	Close(a6)
	clr.l	hdl
	move.l	buflen(pc),(a4)
	lea	t28(pc),a0
	bra	PrtLp

;----------------------------------------------------------

SaveData:
	tst.l	buflen
	beq	NoBuffer
	lea	gad7t(pc),a0
	bsr	FileReq
	move.l	a0,(a4)
	bsr	Exists
	move.l	a0,d3
	lea	t14(pc),a0
	bsr	Print
	move.l	dosbase(pc),a6
	move.l	(a4),d1
	move.l	#1006,d2
	jsr	Open(a6)
	move.l	d0,hdl
	beq	DosError
	move.l	d0,d1
	move.l	buffer(pc),d2
	move.l	buflen(pc),d3
	jsr	Write(a6)
	cmp.l	d0,d3
	bne	DosError
	move.l	hdl(pc),d1
	jsr	Close(a6)
	clr.l	hdl
	move.l	buflen(pc),(a4)
	lea	t29(pc),a0
	bra	PrtLp

;----------------------------------------------------------

LoadIFF:
	lea	gad4t(pc),a0
	bsr	FileReq
	move.l	a0,(a4)
	lea	t51(pc),a0
	bsr	Print
	move.l	dosbase(pc),a6
	move.l	(a4),d1
	move.l	#1005,d2
	jsr	Open(a6)
	move.l	d0,hdl
	beq	DosError
	move.l	a4,d2
	moveq	#12,d3
	bsr	li1
	cmp.l	#'FORM',(a4)
	beq.b	li2
	lea	t52(pc),a0
	sub.l	a1,a1
	lea	t19(pc),a2
	bsr	Request
	bra	Abort
li2	clr.b	12(a4)
	lea	8(a4),a0
	move.l	a0,(a4)
	lea	t53(pc),a0
	bsr	Print
	cmp.l	#'ILBM',8(a4)
	beq.b	li3
	cmp.l	#'8SVX',8(a4)
	beq	li4
	lea	t54(pc),a0
li7	sub.l	a1,a1
	lea	t22(pc),a2
	bsr	Request
	bra	Abort
li3	moveq	#28,d3
	add.l	#16,d2
	bsr	li1
	cmp.l	#'BMHD',16(a4)
	beq.b	li6
	lea	t55(pc),a0
	bra.b	li7
li6	lea	t56(pc),a0
	clr	4(a4)
	move	26(a4),6(a4)
	clr.l	8(a4)
	move.b	32(a4),11(a4)
	move	6(a4),height
	move	10(a4),planes
	move	24(a4),d0
	add	#15,d0
	lsr	#4,d0
	clr	(a4)
	move	d0,2(a4)
	lsl	#1,d0
	move	d0,width
	move	d0,d1
	mulu	6(a4),d1
	move.l	d1,plsize
	mulu	10(a4),d0
	mulu	6(a4),d0
	move.l	d0,size
	move.l	d0,12(a4)
	clr.b	compr
	tst.b	34(a4)
	beq.b	li13
	st	compr
	cmp.b	#1,34(a4)
	beq.b	li13
	lea	t60(pc),a0
	bra	li7
li13	bsr	Print
	move.l	size(pc),size2
	lea	t69(pc),a0
	lea	t70(pc),a1
	lea	t71(pc),a2
	bsr	Request
	move	d0,shadow
	beq.b	li32
	move.l	plsize(pc),d0
	add.l	d0,size
li32	clr.b	cmapfnd
li8	move.l	a4,d2
	moveq	#8,d3
	bsr	li1
	cmp.l	#'CMAP',(a4)
	bne	li9
	tst.b	cmapfnd
	beq.b	li10
	lea	t58(pc),a0
	bra	li7
li10	lea	t80(pc),a0
	lea	t70(pc),a1
	lea	t71(pc),a2
	bsr	Request
	move.l	dosbase(pc),a6
	beq.b	li9
	lea	t57(pc),a0
	move.l	4(a4),d0
	move.l	d0,d3
	divu	#3,d0
	ext.l	d0
	move.l	d0,(a4)
	lsl.l	#1,d0
	move.l	d0,4(a4)
	bsr	Print
	addq.l	#8,d2
	bsr	li1
	st	cmapfnd
	move.l	size(pc),d0
	add.l	4(a4),d0
	moveq	#0,d1
	bsr	GetBuffer
	add.l	size(pc),d0
	move.l	d0,a0
	lea	8(a4),a1
	move.l	(a4),d0
	subq	#1,d0
li12	move.b	(a1)+,d1
	lsl	#4,d1
	move	d1,(a0)
	move.b	(a1)+,d1
	and	#$f0,d1
	or	d1,(a0)
	move.b	(a1)+,d1
	lsr	#4,d1
	or	d1,(a0)+
	dbf	d0,li12
	bra	li8
li9	cmp.l	#'BODY',(a4)
	beq.b	li11
	move.l	hdl(pc),d1
	move.l	4(a4),d2
	moveq	#0,d3
	jsr	Seek(a6)
	bra	li8
li11	tst.b	cmapfnd
	bne.b	li31
	move.l	size(pc),d0
	moveq	#0,d1
	bsr	GetBuffer
li31	lea	t59(pc),a0
	bsr	Print
	lea	t61(pc),a0
	lea	t62(pc),a1
	lea	t63(pc),a2
	bsr	Request
	move	d0,-(sp)
	lea	t67(pc),a0
	bsr	Print
	move.l	buffer(pc),a2
	move.l	dosbase(pc),a6
	moveq	#0,d3
	tst.b	compr
	bne.b	li14
	move	height(pc),d4
	subq	#1,d4
	move.l	a2,a3
	move	width(pc),d3
li16	move	planes(pc),d5
	subq	#1,d5
	tst	(sp)
	beq.b	li17
	move.l	a3,a2
li17	move.l	hdl(pc),d1
	move.l	a2,d2
	jsr	Read(a6)
	cmp.l	d0,d3
	bne	DosError
	tst	(sp)
	beq.b	li18
	add.l	plsize(pc),a2
	bra.b	li19
li18	add	d3,a2
li19	dbf	d5,li17
	add	d3,a3
	dbf	d4,li16
	bra	li15
li14	move	height(pc),d4
	subq	#1,d4
	move.l	a2,a3
li20	move	planes(pc),d5
	subq	#1,d5
	tst	(sp)
	beq.b	li21
	move.l	a3,a2
li21	move	width(pc),d6
	move.l	a2,a5
li22	move.l	hdl(pc),d1
	move.l	a4,d2
	moveq	#1,d3
	jsr	Read(a6)
	cmp.l	d0,d3
	bne	DosError
	move.b	(a4),d3
	cmp.b	#128,d3
	beq.b	li22
	bhi.b	li28
	move.l	hdl(pc),d1
	move.l	a5,d2
	addq	#1,d3
	sub	d3,d6
	add	d3,a5
	jsr	Read(a6)
	cmp.l	d0,d3
	bne	DosError
	tst	d6
	bgt.b	li22
	bra.b	li29
li28	move.b	d3,1(a4)
	move.l	hdl(pc),d1
	moveq	#1,d3
	jsr	Read(a6)
	cmp.l	d0,d3
	bne	DosError
	move.b	(a4),d0
	move.b	1(a4),d1
	ext	d1
	neg	d1
	sub	d1,d6
	subq	#1,d6
li30	move.b	d0,(a5)+
	dbf	d1,li30
	tst	d6
	bgt.b	li22
li29	tst	(sp)
	beq.b	li23
	add.l	plsize(pc),a2
	bra.b	li24
li23	add	width(pc),a2
li24	dbf	d5,li21
	add	width(pc),a3
	dbf	d4,li20
	bra	li15
li4	moveq	#28,d3
	bsr	li1
	cmp.l	#'VHDR',(a4)
	beq.b	li25
	lea	t64(pc),a0
	bra	li7
li25	move.l	20(a4),(a4)
	lea	t65(pc),a0
	bsr	Print
li26	moveq	#8,d3
	bsr	li1
	cmp.l	#'BODY',(a4)
	beq.b	li27
	move.l	hdl(pc),d1
	move.l	4(a4),d2
	moveq	#0,d3
	jsr	Seek(a6)
	bra.b	li26
li27	lea	t66(pc),a0
	move.l	4(a4),(a4)
	bsr	Print
	move.l	(a4),d0
	moveq	#0,d1
	bsr	GetBuffer
	move.l	dosbase(pc),a6
	move.l	hdl(pc),d1
	move.l	d0,d2
	move.l	(a4),d3
	jsr	Read(a6)
	cmp.l	d0,d3
	bne	DosError
li5	move.l	dosbase(pc),a6
	move.l	hdl(pc),d1
	jsr	Close(a6)
	clr.l	hdl
	bra	Done
li15	tst	shadow
	beq.b	li33
	move.l	buffer,a0
	move.l	a0,a1
	move.l	a0,a2
	add.l	size2(pc),a1
	move	height(pc),d0
	subq	#1,d0
li34	move	planes(pc),d1
	subq	#1,d1
li35	move	width(pc),d2
	lsr	#1,d2
	subq	#1,d2
	movem.l	a0-a1,-(sp)
li36	move	(a0)+,d3
	or	d3,(a1)+
	dbf	d2,li36
	movem.l	(sp)+,a0-a1
	tst	(sp)
	beq.b	li37
	add.l	plsize(pc),a0
	bra.b	li38
li37	add	width(pc),a0
li38	dbf	d1,li35
	tst	(sp)
	beq.b	li39
	add	width(pc),a2
	move.l	a2,a0
li39	add	width(pc),a1
	dbf	d0,li34
li33	addq.l	#2,sp
	tst	shadow
	beq.b	li5
	lea	t72(pc),a0
	move.l	plsize(pc),(a4)
	bsr	Print
	bra	li5
li1	move.l	dosbase(pc),a6
	move.l	hdl(pc),d1
	jsr	Read(a6)
	cmp.l	d0,d3
	bne	DosError
	rts

;----------------------------------------------------------

SaveDCx:
	tst.l	buflen
	beq	NoBuffer
	lea	t47(pc),a0
	lea	t48(pc),a1
	lea	t49(pc),a2
	move	#'l',d4
	bsr	Request
	beq.b	sx1
	move	#'w',d4
sx1	lea	gad8t(pc),a0
	bsr	FileReq
	move.l	a0,(a4)
	bsr	Exists
	lea	t50(pc),a0
	move.b	d4,14(a0)
	bsr	Print
	lsl	#8,d4
	or	#9,d4
	move.l	dosbase(pc),a6
	move.l	(a4),d1
	move.l	#1006,d2
	jsr	Open(a6)
	move.l	d0,hdl
	beq	DosError
	clr.l	(a4)
	move.l	buflen(pc),d5
	move.l	buffer(pc),a3
sx2	lea	4(a4),a2
	move.l	#$0964632e,(a2)+
	move	d4,(a2)+
	moveq	#3,d2
sx3	move.l	(a3)+,d0
	bsr.b	LtoH
sx4	move.b	(a0)+,(a2)+
	bne.b	sx4
	move.b	#',',-1(a2)
	subq.l	#4,d5
	bcs.b	sx5
	dbf	d2,sx3
sx5	subq.l	#1,a2
	move.b	#10,(a2)
	clr.b	1(a2)
	moveq	#0,d3
	lea	4(a4),a2
sx6	tst.b	(a2)+
	beq.b	sx7
	addq	#1,d3
	bra.b	sx6
sx7	add.l	d3,(a4)
	move.l	hdl(pc),d1
	move.l	a4,d2
	addq.l	#4,d2
	jsr	Write(a6)
	cmp.l	d0,d3
	bne	DosError
	tst.l	d5
	bmi.b	sx8
	bra.b	sx2
sx8	move.l	hdl(pc),d1
	jsr	Close(a6)
	clr.l	hdl
	lea	t29(pc),a0
	bra	PrtLp
LtoH:
	movem.l	d2-d3,-(sp)
	lea	number,a0
	lea	hextab(pc),a1
	move.b	#'$',(a0)+
	moveq	#1,d1
lh1	moveq	#3,d2
lh2	rol.l	#4,d0
	move	d0,d3
	and	#$f,d3
	move.b	(a1,d3),(a0)+
	dbf	d2,lh2
	cmp	#$6c09,d4
	beq.b	lh3
	move.b	#',',(a0)+
	move.b	#'$',(a0)+
lh3	dbf	d1,lh1
	cmp	#$6c09,d4
	beq.b	lh4
	clr.b	-(a0)
	clr.b	-(a0)
lh4	movem.l	(sp)+,d2-d3
	lea	number,a0
	rts

;----------------------------------------------------------

ReadSecs:
	move	#64,secwin+6
	move.l	#gad9t,secwin+26
	move.l	#sec2gad,sec1gad
	move	#20,sec3gad+4
	move	#49,sec3gad+6
	move	#118,sec4gad+4
	move	#49,sec4gad+6
	moveq	#0,d5
	bsr	SecRequest
	tst.l	d0
	bmi	FalseSec
	cmp.l	#1759,d0
	bhi	FalseSec
	tst.l	d1
	bmi	FalseSec
	cmp.l	#1759,d1
	bhi	FalseSec
	move.l	d0,(a4)
	move.l	d1,4(a4)
	lea	t43(pc),a0
	move.b	gad14t+8(pc),30(a0)
	bsr	Print
	move.l	4(a4),d0
	sub.l	(a4),d0
	addq	#1,d0
	lsl.l	#8,d0
	lsl.l	#1,d0
	moveq	#2,d1
	bsr	GetBuffer
	lea	diskio,a1
	move.l	#repport,14(a1)
	move	#2,28(a1)
	move.l	buflen(pc),36(a1)
	move.l	buffer(pc),40(a1)
	clr.l	44(a1)
	jsr	DoIO(a6)
	lea	diskio,a1
	move.b	31(a1),d2
	move	#9,28(a1)
	clr.l	36(a1)
	jsr	DoIO(a6)
	tst.b	d2
	bne	TdError
	move.l	buflen(pc),(a4)
	lea	t28(pc),a0
	bra	PrtLp

;----------------------------------------------------------

WriteSecs:
	tst.l	buflen
	beq	NoBuffer
	move	#50,secwin+6
	move.l	#gad13t,secwin+26
	move.l	#sec3gad,sec1gad
	move	#20,sec3gad+4
	move	#35,sec3gad+6
	move	#118,sec4gad+4
	move	#35,sec4gad+6
	moveq	#1,d5
	bsr	SecRequest
	tst.l	d0
	bmi	FalseSec
	cmp.l	#1759,d0
	bhi	FalseSec
	move.l	d0,(a4)
	move.l	buflen,d1
	add.l	#511,d1
	lsr.l	#8,d1
	lsr.l	#1,d1
	subq	#1,d1
	add.l	d0,d1
	move.l	d1,4(a4)
	cmp.l	#1759,d1
	bls.b	ws1
	lea	t44(pc),a0
	sub.l	a1,a1
	lea	t6(pc),a2
	bsr	Request
	bra	Loop
ws1	lea	t45(pc),a0
	move.b	gad14t+8(pc),28(a0)
	bsr	Print
	lea	t46(pc),a0
	move.b	gad14t+8(pc),19(a0)
	lea	t36(pc),a1
	lea	t37(pc),a2
	bsr	Request
	beq	Abort
	bsr	FastToChip
	lea	diskio,a1
	move.l	#repport,14(a1)
	move	#3,28(a1)
	move.l	buflen,d0
	add.l	#511,d0
	lsr.l	#8,d0
	lsr.l	#1,d0
	lsl.l	#8,d0
	lsl.l	#1,d0
	move.l	d0,36(a1)
	move.l	(a4),d1
	move.l	d0,(a4)
	move.l	buffer(pc),40(a1)
	lsl.l	#8,d1
	lsl.l	#1,d1
	move.l	d1,44(a1)
	jsr	DoIO(a6)
	lea	diskio,a1
	move.b	31(a1),d2
	bne.b	ws2
	move	#4,28(a1)
	jsr	DoIO(a6)
	lea	diskio,a1
	move.b	31(a1),d2
ws2	move	#9,28(a1)
	clr.l	36(a1)
	jsr	DoIO(a6)
	tst.b	d2
	bne	TdError
	lea	t29(pc),a0
	bra	PrtLp
	
;----------------------------------------------------------

SecLoader:
	move.b	#'1',t41+22
	move	#64,secwin+6
	move.l	#gad10t,secwin+26
	move.l	#sec2gad,sec1gad
	move	#20,sec3gad+4
	move	#49,sec3gad+6
	move	#118,sec4gad+4
	move	#49,sec4gad+6
	moveq	#0,d5
	bsr	SecRequest
	tst.l	d0
	bls	FalseSec
	cmp.l	#1759,d0
	bhi	FalseSec
	cmp.l	d0,d1
	blo	FalseSec
	cmp.l	#1759,d1
	bhi	FalseSec
	move.l	d0,sl4
	move.l	d1,sl5
	move.l	sl4,(a4)
	move.l	sl5,4(a4)
	lea	t35(pc),a0
	move.b	gad14t+8(pc),21(a0)
	lea	t36(pc),a1
	lea	t37(pc),a2
	bsr	Request
	beq	Loop
	lea	t68(pc),a0
	move.b	gad14t+8(pc),35(a0)
	bsr	Print
	lea	diskbuf,a0
	move	#255,d0
sl10	clr.l	(a0)+
	dbf	d0,sl10
	lea	sl1(pc),a0
	lea	diskbuf+12,a1
	move	#sl2-sl1-1,d0
sl3	move.b	(a0)+,(a1)+
	dbf	d0,sl3
	move.l	4.w,a6
	bra	WriteBoot
sl1	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a1,-(sp)
	move.l	sl5(pc),d2
	sub.l	sl4(pc),d2
	addq.l	#1,d2
	lsl.l	#8,d2
	lsl.l	#1,d2
	move.l	d2,d0
	moveq	#2,d1
	jsr	AllocMem(a6)
	lea	sl12(pc),a0
	move.l	d0,d3
	beq.b	sl6
	move.l	(sp),a1
	move	#2,28(a1)
	move.l	d2,36(a1)
	move.l	d3,40(a1)
	move.l	sl4(pc),d0
	lsl.l	#8,d0
	lsl.l	#1,d0
	move.l	d0,44(a1)
	jsr	DoIO(a6)
	move.l	(sp),a1
	move.b	31(a1),d4
	move	#9,28(a1)
	clr.l	36(a1)
	jsr	DoIO(a6)
	lea	sl13(pc),a0
	tst.b	d4
	bne.b	sl6
	move.l	d3,a0
	move.l	(sp)+,a1
	jsr	(a0)
	bra.b	sl7
sl14	addq.l	#4,sp
sl7	movem.l	(sp)+,d0-d7/a0-a6
	lea	sl8(pc),a1
	jsr	FindResident(a6)
	tst.l	d0
	beq.b	sl9
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	rts
sl9	moveq	#-1,d0
	rts
sl6	move.l	a0,a2
	lea	sl11(pc),a1
	moveq	#0,d0
	jsr	OpenLibrary(a6)
	move.l	d0,a6
	move.l	a2,a0
	moveq	#0,d0
	moveq	#40,d1
	jsr	DisplayAlert(a6)
	tst.l	d0
	beq.b	sl15
	move.l	a6,a1
	move.l	4.w,a6
	jsr	CloseLibrary(a6)
	bra.b	sl14
sl15	move	#$4000,$dff09a
	lea	sl16(pc),a0
	move.l	a0,$b4.w
	trap	#13
sl16	move	#$2700,sr
	jmp	$fc0000
sl8	dc.b	"dos.library",0
sl11	dc.b	"intuition.library",0
sl12	dc.b	0,60,12,"SECTORLOADER - NOT ENOUGH CHIP MEMORY !",0,1
	dc.b	0,68,22,"Left button : Return to AmigaDOS",0,1
	dc.b	0,68,32,"Right button: Reset/reboot",0,0
sl13	dc.b	0,60,12,"SECTORLOADER - DISK READ ERROR !",0,1
	dc.b	0,68,22,"Left button : Return to AmigaDOS",0,1
	dc.b	0,68,32,"Right button: Reset/reboot",0,0
	even
sl4	dc.l	0
sl5	dc.l	0
	dc.b	"*** Sectorloader V1.0 by Patrick Schiel ***"
sl2	even

;----------------------------------------------------------

SelectUnit:
	addq	#1,unit+2
	and	#3,unit+2
	move.b	#'0',d0
	add.b	unit+3(pc),d0
	move.b	d0,gad14t+8
	bsr	CloseTd
	bsr	OpenTd
	bne.b	SelectUnit
	move.l	intbase(pc),a6
	lea	gad14(pc),a0
	move.l	win(pc),a1
	sub.l	a2,a2
	jsr	RefreshGadgets(a6)
	bra	Loop

;----------------------------------------------------------

About:
	lea	tabout(pc),a0
	bsr	WinText
	bra	Loop

;----------------------------------------------------------

ModBitMap:
	lea	t81(pc),a0
	lea	t82(pc),a1
	lea	t83(pc),a2
	bsr	Request
	move	d0,8(a4)
	move.b	#'2',t41+22
	move	#64,secwin+6
	move.l	#gad11t,secwin+26
	move.l	#sec2gad,sec1gad
	move	#20,sec3gad+4
	move	#49,sec3gad+6
	move	#118,sec4gad+4
	move	#49,sec4gad+6
	moveq	#0,d5
	bsr	SecRequest
	cmp.l	#1,d0
	bls	FalseSec
	cmp.l	#1759,d0
	bhi	FalseSec
	cmp.l	d0,d1
	blo	FalseSec
	cmp.l	#1759,d1
	bhi	FalseSec
	move.l	d0,(a4)
	move.l	d1,4(a4)
	lea	t84(pc),a0
	move.b	gad14t+8(pc),23(a0)
	bsr	Print
	move.l	#880*512,d0
	bsr	ReadBlock
	move.l	diskbuf+79*4,d0
	lsl.l	#8,d0
	lsl.l	#1,d0
	move.l	d0,12(a4)
	bsr	ReadBlock
	lea	diskbuf,a0
	clr.l	(a0)+
	move.l	(a4),d0
	move.l	4(a4),d1
	move	8(a4),d2
mb1	move	d0,d3
	subq	#2,d3
	move	d3,d4
	and	#31,d3
	lsr	#5,d4
	lsl	#2,d4
	move.l	(a0,d4),d5
	tst	d2
	bne.b	mb2
	bclr	d3,d5
	bra.b	mb3
mb2	bset	d3,d5
mb3	move.l	d5,(a0,d4)
	addq	#1,d0
	cmp	d0,d1
	bhs.b	mb1
	moveq	#126,d0
	moveq	#0,d1
mb5	sub.l	(a0)+,d1
	dbf	d0,mb5
	move.l	d1,diskbuf
	lea	t85(pc),a0
	move.l	#t86,8(a4)
	tst	d2
	beq.b	mb4
	move.l	#t87,8(a4)
mb4	bsr	Print
	lea	t89(pc),a0
	lea	t36(pc),a1
	lea	t37(pc),a2
	bsr.b	Request
	beq	Abort
	lea	t88(pc),a0
	bsr	Print
	move.l	12(a4),d0
	bsr	WriteBlock
	bra	Done
	
;----------------------------------------------------------

DelFile:
	lea	gad15t(pc),a0
	bsr	FileReq
	move.l	a0,(a4)
	lea	t10(pc),a0
	lea	t11(pc),a1
	lea	t12(pc),a2
	bsr.b	Request
	beq	Loop
	lea	t13(pc),a0
	bsr	Print
	move.l	dosbase,a6
	move.l	(a4),d1
	jsr	DeleteFile(a6)
	tst.l	d0
	beq	DosError
	bra	Done

;----------------------------------------------------------

Quit:
	lea	t7(pc),a0
	lea	t8(pc),a1
	lea	t9(pc),a2
	bsr.b	Request
	bne	CleanUp
	bra	Loop

;----------------------------------------------------------

Request:
	clr.l	nogad
	move.l	a1,d0
	beq.b	r6
	move.l	#yesgad,nogad
r6	move.l	a0,rgadt+12
	move.l	a0,rgadt+32
	move.l	a1,yesgadt+12
	move.l	a1,yesgadt+32
	move.l	a2,nogadt+12
	move.l	a2,nogadt+32
	bsr	strlen
	lsl	#3,d0
	add	#16,d0
	cmp	#160,d0
	bhi.b	r2
	move	#150,d0
r2	move	d0,reqwin+4
	move.l	a1,a0
	bsr	strlen
	addq	#1,d0
	lsl	#3,d0
	move	d0,yesgad+8
	move.l	a2,a0
	bsr	strlen
	addq	#1,d0
	lsl	#3,d0
	move	d0,nogad+8
	move	reqwin+4(pc),d1
	sub	d0,d1
	sub	#25,d1
	move	d1,nogad+4
	move.l	win(pc),a0
	move	12(a0),d0
	sub	#23,d0
	bcc.b	r5
	moveq	#0,d0
r5	move	scrh(pc),d1
	sub	#42,d1
	cmp	d1,d0
	bls.b	r4
	move	d1,d0
r4	move	d0,reqwin+2
	move	14(a0),d0
	add	#24,d0
	move	nogad+8(pc),d1
	lsr	#1,d1
	add	d1,d0
	move	reqwin+4(pc),d1
	sub	d1,d0
	bcc.b	r7
	moveq	#0,d0
r7	move	d0,reqwin
	add	d1,d0
	cmp	#640,d0
	bls.b	r8
	sub	#640,d0
	sub	d0,reqwin
r8	move.l	intbase(pc),a6
	lea	reqwin(pc),a0
	jsr	OpenWindow(a6)
	move.l	d0,rwin
	beq.b	r1
	move.l	d0,a0
	move.l	86(a0),a2
	move.l	50(a0),a0
	lea	rgadt(pc),a1
	moveq	#8,d0
	moveq	#15,d1
	jsr	PrintIText(a6)
	move.l	4.w,a6
r3	move.l	a2,a0
	jsr	GetMsg(a6)
	tst.l	d0
	beq.b	r3
	move.l	d0,a1
	move.l	28(a1),a0
	move	38(a0),-(sp)
	jsr	ReplyMsg(a6)
	move.l	intbase(pc),a6
	move.l	rwin(pc),a0
	jsr	CloseWindow(a6)
	move	(sp)+,d0
r1	rts
	
;----------------------------------------------------------

SecRequest:
	moveq	#0,d6
	move.l	intbase(pc),a6
	lea	secwin(pc),a0
	jsr	OpenWindow(a6)
	move.l	d0,swin
	beq	Loop
	move.l	d0,a0
	move.l	86(a0),a3
	lea	sec1gad(pc),a0
	move.l	swin(pc),a1
	sub.l	a2,a2
	jsr	ActivateGadget(a6)
sr1	move.l	4.w,a6
	move.l	a3,a0
	jsr	GetMsg(a6)
	tst.l	d0
	beq.b	sr1
	move.l	d0,a1
	move.l	28(a1),a0
	move	38(a0),d2
	jsr	ReplyMsg(a6)
	tst	d2
	beq.b	sr2
	cmp	#3,d2
	beq.b	sr2
	move.l	intbase,a6
	cmp	#2,d2
	beq.b	sr2
	tst	d5
	bne.b	sr2
	lea	sec2gad(pc),a0
	move.l	swin(pc),a1
	sub.l	a2,a2
	jsr	ActivateGadget(a6)
	bra.b	sr1
sr2	move.l	intbase(pc),a6
	move.l	swin(pc),a0
	jsr	CloseWindow(a6)
	tst	d2
	beq	Loop
	move.l	sec1gad+72(pc),d0
	move.l	sec2gad+72(pc),d1
	tst	d5
	bne.b	sr3
	cmp.l	d0,d1
	bhi.b	sr3
	exg	d0,d1
sr3	rts
	
;----------------------------------------------------------

FalseSec:
	lea	t41(pc),a0
	sub.l	a1,a1
	lea	t42(pc),a2
	bsr	Request
	bra	Loop

;----------------------------------------------------------

FileReq:
	tst.l	arpbase
	beq.b	fr2
	move.l	a0,freq
	move.l	arpbase(pc),a6
	lea	freq(pc),a0
	jsr	FileRequest(a6)
	tst.l	d0
	beq	Loop
	lea	filenam,a0
	lea	dirbuf,a1
fr1	move.b	(a1)+,(a0)+
	bne.b	fr1
	lea	filenam,a0
	lea	filebuf,a1
	jsr	TackOn(a6)
fr3	lea	filenam,a0
	move.l	a0,d1
	tst.b	(a0)
	beq	Loop
	rts
fr2	move.l	a0,frwin+26
	move	#120,sec3gad+4
	move	#44,sec3gad+6
	move	#324,sec4gad+4
	move	#44,sec4gad+6
	lea	frwin(pc),a0
	move.l	intbase(pc),a6
	jsr	OpenWindow(a6)
	move.l	d0,fwin
	bne.b	fr4
	move.l	dosbase(pc),a6
	jsr	Output(a6)
	move.l	d0,d1
	move.l	#t74,d2
	moveq	#34,d3
	jsr	Write(a6)
	bra	CleanUp
fr4	lea	fstrgad(pc),a0
	move.l	d0,a1
	sub.l	a2,a2
	jsr	ActivateGadget(a6)
	move.l	4.w,a6
fr5	move.l	fwin(pc),a0
	move.l	86(a0),a0
	jsr	GetMsg(a6)
	tst.l	d0
	beq.b	fr5
	move.l	d0,a1
	move.l	28(a1),a0
	move	38(a0),d2
	jsr	ReplyMsg(a6)
	move.l	intbase(pc),a6
	move.l	fwin(pc),a0
	jsr	CloseWindow(a6)
	tst	d2
	beq	Loop
	bra	fr3

;----------------------------------------------------------

GetBuffer:
	moveq	#1,d7
	move.l	4.w,a6
	movem.l	d0-d1,-(sp)
	move.l	buflen(pc),d0
	beq.b	gb1
	move.l	buffer(pc),a1
	jsr	FreeMem(a6)
gb1	move.l	(sp),d0
	move.l	d0,buflen
	beq.b	gb2
	move.l	(sp),d0
	move.l	4(sp),d1
	or.l	#$10000,d1
	jsr	AllocMem(a6)
	move.l	d0,buffer
	bne.b	gb2
	clr.l	buflen
	move.l	4(sp),d0
	bra.b	NoMem
gb2	addq.l	#8,sp
	rts
	
;----------------------------------------------------------

NoBuffer:
	lea	t18(pc),a0
	sub.l	a1,a1
	lea	t19(pc),a2
	bsr	Request
	bra	Loop

;----------------------------------------------------------

NoMem:
	lea	t5(pc),a0
	beq.b	nm1
	lea	t32(pc),a0
nm1	sub.l	a1,a1
	lea	t6(pc),a2
	bsr	Request
	lea	t76(pc),a0
	bsr	Print
	bra	Loop

;----------------------------------------------------------

FastToChip:
	move.l	4.w,a6
	move.l	buffer(pc),a1
	jsr	TypeOfMem(a6)
	btst	#1,d0
	bne.b	fc1
	move.l	buflen(pc),d0
	moveq	#2,d1
	jsr	AllocMem(a6)
	move.l	d0,d2
	beq.b	fc2
	move.l	buffer(pc),a0
	move.l	d0,a1
	move.l	buflen(pc),d0
	jsr	CopyMem(a6)
	move.l	buffer(pc),a1
	move.l	buflen(pc),d0
	jsr	FreeMem(a6)
	move.l	d2,buffer
fc1	rts
fc2	moveq	#2,d0
	bra.b	NoMem

;----------------------------------------------------------

OpenTd:
	move.l	4.w,a6
	move.l	unit(pc),d0
	moveq	#0,d1
	lea	tdname(pc),a0
	lea	diskio,a1
	jsr	OpenDevice(a6)
	move.l	d0,tdopen
	bne.b	ot1
	move.l	#repport,diskio+14
	moveq	#0,d0
ot1	rts

;----------------------------------------------------------

CloseTd:
	tst.l	tdopen
	bne.b	ct1
	move.l	4.w,a6
	lea	diskio,a1
	jsr	CloseDevice(a6)
	clr.l	tdopen
ct1	rts

;----------------------------------------------------------

CheckSum:
	lea	diskbuf,a0
	move.l	#$444f5300,(a0)
	clr.l	4(a0)
	move.l	#880,8(a0)
	move	#255,d0
	moveq	#0,d1
cs1	add.l	(a0)+,d1
	bcc.b	cs2
	addq.l	#1,d1
cs2	dbf	d0,cs1
	not.l	d1
	move.l	d1,diskbuf+4
	rts

;----------------------------------------------------------

DosError:
	jsr	IoErr(a6)
	bsr	LtoA
	lea	t3+20(pc),a1
	moveq	#2,d0
de1	move.b	(a0)+,(a1)+
	dbf	d0,de1
	move.l	lck(pc),d1
	beq.b	de2
	jsr	UnLock(a6)
	clr.l	lck
de2	move.l	hdl(pc),d1
	beq.b	de3
	jsr	Close(a6)
	clr.l	hdl
de3	lea	t3(pc),a0
	sub.l	a1,a1
	lea	t4(pc),a2
	bsr	Request
	tst	d7
	beq.b	de5
	moveq	#0,d0
	bsr	GetBuffer
de5	lea	t75(pc),a0
	bsr	Print
	bra	Loop

TdError:
	moveq	#0,d0
	move.b	d2,d0
	bsr	LtoA
	lea	t34+20(pc),a1
	move.b	(a0)+,(a1)+
	move.b	(a0),(a1)
	lea	t34(pc),a0
	sub.l	a1,a1
	lea	t4(pc),a2
	bsr	Request
	tst	d7
	beq.b	te2
	moveq	#0,d0
	bsr	GetBuffer
te2	lea	t75(pc),a0
	bsr	Print
	bra	Loop

;----------------------------------------------------------

Exists:
	move.l	dosbase(pc),a6
	move.l	(a4),d1
	moveq	#-2,d2
	jsr	Lock(a6)
	move.l	d0,d1
	beq.b	e1
	jsr	UnLock(a6)
	lea	t15(pc),a0
	lea	t16(pc),a1
	lea	t17(pc),a2
	bsr	Request
	beq	Loop
e1	rts

;----------------------------------------------------------

WinText:
	move.l	a0,a3
	move.l	intbase(pc),a6
	lea	txtwin(pc),a0
	move.l	(a3)+,(a0)
	move.l	(a3)+,4(a0)
	jsr	OpenWindow(a6)
	move.l	d0,d2
	beq.b	wt1
	move.l	d0,a2
	move.l	50(a2),a2
wt2	moveq	#0,d0
	moveq	#0,d1
	move.b	(a3)+,d0
	move.b	(a3)+,d1
	lsl	#2,d0
	lsl	#2,d1
	move.l	a2,a0
	lea	rgadt(pc),a1
	move.b	(a3)+,20(a1)
	move.l	a3,12(a1)
	move.l	a3,32(a1)
	jsr	PrintIText(a6)
wt4	tst.b	(a3)+
	bne.b	wt4
	tst.b	(a3)
	bne.b	wt2
wt1	btst	#6,$bfe001
	bne.b	wt1
wt3	btst	#6,$bfe001
	beq.b	wt3
	move.l	d2,a0
	jsr	CloseWindow(a6)
	move.b	#1,rgadt+20
	rts

;----------------------------------------------------------

Print:
	move.l	gfxbase(pc),a6
	movem.l	d2-d5/a2/a4,-(sp)
	move.l	a0,a2
p1	moveq	#0,d0
	move.b	(a2)+,d0
	beq	p2
	cmp.b	#3,d0
	bhi.b	p3
	move.l	rport(pc),a1
	jsr	SetAPen(a6)
	bra.b	p1
p3	cmp.b	#10,d0
	bne.b	p8
p10	move.l	rport(pc),a1
	moveq	#0,d0
	moveq	#8,d1
	moveq	#12,d2
	moveq	#102,d3
	move.l	#628,d4
	move	scrh(pc),d5
	subq	#2,d5
	ext.l	d5
	jsr	ScrollRaster(a6)
	clr	cx
	moveq	#90,d0
	move.l	d5,d1
	subq	#2,d1
	move.l	rport(pc),a1
	jsr	Move(a6)
	bra.b	p1
p8	cmp.b	#'%',d0
	bne.b	p7
	move.b	(a2)+,d0
	cmp.b	#'s',d0
	bne.b	p9
	move.l	(a4)+,a0
	bsr.b	Print
	bra.b	p1
p9	cmp.b	#'l',d0
	bne.b	p7
	move.l	(a4)+,d0
	bsr.b	LtoA
	bsr.b	Print
	bra.b	p1
p7	move.l	rport,a1
	lea	-1(a2),a0
	moveq	#1,d0
	jsr	Text(a6)
	addq	#1,cx
	cmp	#64,cx
	bne	p1
	bra.b	p10
p2	movem.l	(sp)+,d2-d5/a2/a4
	rts

;----------------------------------------------------------

LtoA:
	lea	number,a1
	lea	longtab(pc),a0
la1	cmp.l	(a0)+,d0
	blo.b	la1
	subq.l	#4,a0
la2	move.b	#'0',(a1)
	move.l	(a0)+,d1
	beq.b	la3
la4	cmp.l	d1,d0
	blo.b	la5
	sub.l	d1,d0
	addq.b	#1,(a1)
	bra.b	la4
la5	addq.l	#1,a1
	bra.b	la2
la3	clr.b	(a1)
	lea	number,a0
	sub.l	a0,a1
	move.l	a1,d0
	bne.b	la6
	move	#$3000,(a0)
	moveq	#1,d0
la6	rts
	
;----------------------------------------------------------

strlen:
	move.l	a0,-(sp)
	moveq	#0,d0
sn1	tst.b	(a0)+
	beq.b	sn2
	addq	#1,d0
	bra.b	sn1
sn2	move.l	(sp)+,a0
	rts
	
;----------------------------------------------------------

OpenLibs:
	lea	dosname(pc),a1
	moveq	#0,d0
	jsr	OpenLibrary(a6)
	move.l	d0,dosbase
	lea	intname(pc),a1
	moveq	#0,d0
	jsr	OpenLibrary(a6)
	move.l	d0,intbase
	move.l	d0,a0
	move.l	60(a0),a0
	move	14(a0),scrh
	lea	gfxname(pc),a1
	moveq	#0,d0
	jsr	OpenLibrary(a6)
	move.l	d0,gfxbase
	lea	arpname(pc),a1
	moveq	#39,d0
	jsr	OpenLibrary(a6)
	move.l	d0,arpbase
	rts

;----------------------------------------------------------

InitDisplay:
	move.l	intbase(pc),a6
	lea	newscr(pc),a0
	move	scrh(pc),6(a0)
	jsr	OpenScreen(a6)
	move.l	d0,scr
	bne.b	id1
	lea	t77(pc),a2
	bra	OpenErr
id1	move.l	d0,reqwin+30
	move.l	d0,secwin+30
	move.l	d0,txtwin+30
	move.l	d0,frwin+30
	add.l	#44,d0
	move.l	d0,vport
	add.l	#40,d0
	move.l	d0,rport
	lea	newwin(pc),a0
	move	scrh(pc),d0
	sub	#10,d0
	move	d0,6(a0)
	jsr	OpenWindow(a6)
	move.l	d0,win
	bne.b	id2
	lea	t78(pc),a2
	bra.b	OpenErr
id2	move.l	d0,freq+12
	move.l	gfxbase(pc),a6
	move.l	vport(pc),a0
	lea	colors(pc),a1
	moveq	#4,d0
	jsr	LoadRGB4(a6)
	move.l	rport(pc),a1
	moveq	#1,d0
	jsr	SetAPen(a6)
	moveq	#2,d0
	jsr	SetBPen(a6)
	moveq	#10,d0
	moveq	#99,d1
	move.l	#630,d2
	move	scrh(pc),d3
	subq	#1,d3
	ext.l	d3
	jsr	RectFill(a6)
	move.l	rport(pc),a1
	moveq	#2,d0
	jsr	SetAPen(a6)
	moveq	#12,d0
	moveq	#100,d1
	subq	#2,d2
	subq	#1,d3
	jsr	RectFill(a6)
	lea	t0(pc),a0
	bsr	Print
	move.l	intbase(pc),a6
	move.l	scr(pc),a0
	jsr	ScreenToFront(a6)
	rts
	
;----------------------------------------------------------

OpenErr:
	move.l	dosbase(pc),a6
	jsr	Output(a6)
	move.l	d0,d1
	move.l	a2,d2
	moveq	#-1,d3
oe1	tst.b	(a2)+
	dbeq	d3,oe1
	not.l	d3
	jsr	Write(a6)

;----------------------------------------------------------

CleanUp:
	bsr	CloseTd
	lea	repport,a1
	jsr	RemPort(a6)
	moveq	#0,d0
	bsr	GetBuffer
	move.l	intbase(pc),a6
	move.l	win(pc),d0
	beq.b	c1
	move.l	d0,a0
	jsr	CloseWindow(a6)
c1	move.l	scr(pc),d0
	beq.b	c2
	move.l	d0,a0
	jsr	CloseScreen(a6)
c2	move.l	4.w,a6
	move.l	dosbase(pc),d0
	beq.b	c3
	move.l	d0,a1
	jsr	CloseLibrary(a6)
c3	move.l	intbase(pc),d0
	beq.b	c4
	move.l	d0,a1
	jsr	CloseLibrary(a6)
c4	move.l	gfxbase(pc),d0
	beq.b	c5
	move.l	d0,a1
	jsr	CloseLibrary(a6)
c5	move.l	arpbase(pc),d0
	beq.b	c6
	move.l	d0,a1
	jsr	CloseLibrary(a6)
c6	move.l	stack(pc),sp
	moveq	#0,d0
	rts
	
;----------------------------------------------------------

Open=-30
Close=-36
Read=-42
Write=-48
Output=-60
Seek=-66
DeleteFile=-72
Lock=-84
UnLock=-90
Examine=-102
IoErr=-132
FindResident=-96
Forbid=-132
Permit=-138
AllocMem=-198
FreeMem=-210
AvailMem=-216
FindTask=-294
Wait=-318
AddPort=-354
RemPort=-360
GetMsg=-372
ReplyMsg=-378
WaitPort=-384
CloseLibrary=-414
OpenDevice=-444
CloseDevice=-450
DoIO=-456
TypeOfMem=-534
OpenLibrary=-552
CopyMem=-624
Text=-60
LoadRGB4=-192
Move=-240
RectFill=-306
SetAPen=-342
SetBPen=-348
ScrollRaster=-396
CloseScreen=-66
CloseWindow=-72
DisplayAlert=-90
OpenScreen=-198
OpenWindow=-204
PrintIText=-216
RefreshGadgets=-222
ScreenToFront=-252
ActivateGadget=-462
FileRequest=-294
TackOn=-624

CUSTOMSCREEN=$f
SCREENBEHIND=$80
HIRES=$8000
WINDOWDRAG=2
BORDERLESS=$800
ACTIVATE=$1000
RMBTRAP=$10000
GADGETUP=$40
GADGHBOX=1
RELVERIFY=1
BOOLGADGET=1
STRGADGET=4
LONGINT=$800
TOGGLESELECT=$100

;----------------------------------------------------------

stack	dc.l	0
win	dc.l	0
rwin	dc.l	0
swin	dc.l	0
fwin	dc.l	0
rport	dc.l	0
vport	dc.l	0
dosbase	dc.l	0
intbase	dc.l	0
gfxbase	dc.l	0
arpbase	dc.l	0
buffer	dc.l	0
buflen	dc.l	0
width	dc.w	0
height	dc.w	0
planes	dc.w	0
size	dc.l	0
size2	dc.l	0
plsize	dc.l	0
hdl	dc.l	0
lck	dc.l	0
cx	dc.w	0
unit	dc.l	0
tdopen	dc.l	0
shadow	dc.w	0
scrh	dc.w	0
cmapfnd	dc.b	0
compr	dc.b	0

newscr	dc.w	0,0,640,0,2
	dc.b	2,1
	dc.w	HIRES,CUSTOMSCREEN+SCREENBEHIND
	dc.l	topaz8,title,0,0
newwin	dc.w	0,10,640,0
	dc.b	0,1
	dc.l	GADGETUP,ACTIVATE+BORDERLESS+RMBTRAP
	dc.l	gad1,0,0
scr	dc.l	0,0
	dc.w	0,0,0,0,CUSTOMSCREEN
	
txtwin	dc.w	0,0,0,0
	dc.b	0,1
	dc.l	0,RMBTRAP,0,0,0,0,0
	dc.w	0,0,0,0,CUSTOMSCREEN
	
secwin	dc.w	222,30,194,0
	dc.b	2,1
	dc.l	GADGETUP,ACTIVATE+WINDOWDRAG+RMBTRAP
	dc.l	sec1gad,0,0,0,0
	dc.w	0,0,0,0,CUSTOMSCREEN
	
frwin	dc.w	80,62,500,59
	dc.b	2,1
	dc.l	GADGETUP,ACTIVATE+WINDOWDRAG+RMBTRAP
	dc.l	fstrgad,0,0,0,0
	dc.w	0,0,0,0,CUSTOMSCREEN
	
fstrgad	dc.l	sec3gad
	dc.w	10,30,480,9,0,RELVERIFY,STRGADGET
	dc.l	frbord,0,frgadt,0,fsg1
	dc.w	1
	dc.l	0
fsg1	dc.l	filenam,filenam
	dc.w	0,67,0,0,0,0,0,0
	dc.l	0,0,0
frgadt	dc.b	2,0,0,0
	dc.w	3,-13
	dc.l	0,t79,ft1
ft1	dc.b	3,0,0,0
	dc.w	2,-14
	dc.l	0,t79,0
frbord	dc.w	-1,-1
	dc.b	1,0,0,5
	dc.l	fb1,0
fb1	dc.w	-1,-1,482,-1,482,10,-1,10,-1,-1

sec1gad	dc.l	0
	dc.w	130,18,40,9,0,RELVERIFY+LONGINT,STRGADGET
	dc.l	secbord,0,s13,0,s11
	dc.w	1
	dc.l	0
s11	dc.l	s12,s15
	dc.w	0,5,0,0,0,0,0,0
	dc.l	0,0,0
s12	blk.b	6
s15	blk.b	6
s13	dc.b	2,0,0,0
	dc.w	-107,1
	dc.l	0,t39,s14
s14	dc.b	1,0,0,0
	dc.w	-108,0
	dc.l	0,t39,0
sec2gad	dc.l	sec3gad
	dc.w	130,32,40,9,0,RELVERIFY+LONGINT,STRGADGET
	dc.l	secbord,0,s23,0,s21
	dc.w	2
	dc.l	0
s21	dc.l	s22,s25
	dc.w	0,5,0,0,0,0,0,0
	dc.l	0,0,0
s22	blk.b	6
s25	blk.b	6
s23	dc.b	2,0,0,0
	dc.w	-107,1
	dc.l	0,t40,s24
s24	dc.b	1,0,0,0
	dc.w	-108,0
	dc.l	0,t40,0
secbord	dc.w	0,-1
	dc.b	1,0,0,5
	dc.l	sbd1,0
sbd1	dc.w	-1,-1,40,-1,40,9,-1,9,-1,-1
sec3gad	dc.l	sec4gad
	dc.w	0,0,40,10,GADGHBOX,RELVERIFY,BOOLGADGET
	dc.l	0,0,s31,0,0
	dc.w	3
	dc.l	0
s31	dc.b	2,0,0,0
	dc.w	5,2
	dc.l	0,t6,s32
s32	dc.b	3,0,0,0
	dc.w	4,1
	dc.l	0,t6,0
sec4gad	dc.l	0
	dc.w	0,0,56,10,GADGHBOX,RELVERIFY,BOOLGADGET
	dc.l	0,0,s41,0,0
	dc.w	0
	dc.l	0
s41	dc.b	2,0,0,0
	dc.w	5,2
	dc.l	0,t12,s42
s42	dc.b	3,0,0,0
	dc.w	4,1
	dc.l	0,t12,0
	
freq	dc.l	0,filebuf,dirbuf,0
	dc.b	0,0
	dc.l	0
	dc.w	170,30
reqwin	dc.w	100,0,200,42
	dc.b	2,1
	dc.l	GADGETUP,ACTIVATE+WINDOWDRAG+RMBTRAP
	dc.l	nogad,0,t1,0,0
	dc.w	0,0,0,0,CUSTOMSCREEN
	
yesgad	dc.l	0
	dc.w	25,28,0,10,GADGHBOX,RELVERIFY,BOOLGADGET
	dc.l	0,0,yesgadt,0,0
	dc.w	1
	dc.l	0
yesgadt	dc.b	2,0,0,0
	dc.w	5,2
	dc.l	0,0,yg1
yg1	dc.b	3,0,0,0
	dc.w	4,1
	dc.l	0,0,0
nogad	dc.l	0
	dc.w	0,28,0,10,GADGHBOX,RELVERIFY,BOOLGADGET
	dc.l	0,0,nogadt,0,0
	dc.w	0
	dc.l	0
nogadt	dc.b	2,0,0,0
	dc.w	5,2
	dc.l	0,0,ng1
ng1	dc.b	3,0,0,0
	dc.w	4,1
	dc.l	0,0,0
rgadt	dc.b	2,0,0,0
	dc.w	1,1
	dc.l	0,0,rg1
rg1	dc.b	1,0,0,0
	dc.w	0,0
	dc.l	0,0,0

topaz8	dc.l	tpzname
	dc.w	8,0
	
border	dc.w	-2,-1
	dc.b	1,0,0,9
	dc.l	br1,br2
br1	dc.w	0,0,153,0,153,14,0,14,0,0,152,0,152,14,1,14,1,0
br2	dc.w	1,13
	dc.b	2,0,0,16
	dc.l	br3,0
br3	dc.w	1,1,151,1,151,-11,152,-11,152,1,153,1,153,-11
	dc.w	154,-11,154,1,155,1,155,-11,156,-11,156,2
	dc.w	1,2,1,3,156,3

bgad	macro	;num,next,x,y,textx
gad\1	dc.l	\2
	dc.w	\3,\4,150,13,0,1,1
	dc.l	border,0,.bgd1,0,0
	dc.w	\1
	dc.l	0
.bgd1	dc.b	2,0,1,0
	dc.w	\5+1,4
	dc.l	0,gad\1t,.bgd2
.bgd2	dc.b	1,0,0,0
	dc.w	\5,3
	dc.l	0,gad\1t,0
	endm
	
	bgad	1,gad2,2,10,20
	bgad	2,gad3,162,10,16
	bgad	3,gad4,322,10,20
	bgad	4,gad5,482,10,24
	bgad	5,gad6,2,29,16
	bgad	6,gad7,162,29,16
	bgad	7,gad8,322,29,20
	bgad	8,gad9,482,29,20
	bgad	9,gad10,2,48,28
	bgad	10,gad11,162,48,28
	bgad	11,gad12,322,48,24
	bgad	12,gad13,482,48,24
	bgad	13,gad15,2,67,24
	bgad	14,0,162,67,36
	bgad	15,gad16,322,67,32
	bgad	16,gad14,482,67,28
	
colors	dc.w	$04b,$fff,$004,$ff0
longtab	dc.l	10000000,1000000,100000,10000,1000,100,10,1,0
hextab	dc.b	"0123456789abcdef"
exehdr	dc.l	$3f3,0,1,0,1,0,$3e9,0
exeend	dc.l	$3f2

functab	dc.l	ReadBB,LoadExe,LoadData,LoadIFF
	dc.l	WriteBB,SaveExe,SaveData,SaveDCx
	dc.l	ReadSecs,SecLoader,ModBitMap,About
	dc.l	WriteSecs,SelectUnit,DelFile,Quit

dosname	dc.b	"dos.library",0
intname	dc.b	"intuition.library",0
gfxname	dc.b	"graphics.library",0
arpname	dc.b	"arp.library",0
tpzname	dc.b	"topaz.font",0
tdname	dc.b	"trackdisk.device",0
title	dc.b	"FileConverter 1.0 by Patrick Schiel",0
gad1t	dc.b	"Read bootblock",0
gad2t	dc.b	"Load executable",0
gad3t	dc.b	"Load data file",0
gad4t	dc.b	"Load IFF file",0
gad5t	dc.b	"Write bootblock",0
gad6t	dc.b	"Save executable",0
gad7t	dc.b	"Save data file",0
gad8t	dc.b	"Save dc.x file",0
gad9t	dc.b	"Read sectors",0
gad10t	dc.b	"Sectorloader",0
gad11t	dc.b	"Modify bitmap",0
gad12t	dc.b	"About FileCon",0
gad13t	dc.b	"Write sectors",0
gad14t	dc.b	"Drive DF0:",0
gad15t	dc.b	"Delete file",0
gad16t	dc.b	"Quit FileCon",0
donetx	dc.b	10,"Ok.",10,0
terr	dc.b	10,3,"Aborted !",1,10,0
bytes	dc.b	3,"  (%l bytes)",1,0
t0	dc.b	1,10,0
t1	dc.b	"Request",0
t2	dc.b	10,"Loading data file '%s'...",0
t3	dc.b	"Warning: DOS-Error #   ",0
t4	dc.b	"Cancel",0
t5	dc.b	"Not enough memory !",0
t6	dc.b	"Okay",0
t7	dc.b	"Are you sure to quit ??",0
t8	dc.b	"Yes",0
t9	dc.b	"Cancel",0
t10	dc.b	"Really delete this file ?",0
t11	dc.b	"Yes",0
t12	dc.b	"Cancel",0
t13	dc.b	10,"Deleting '%s'...",0
t14	dc.b	10,"Saving as data file '%s'...",0
t15	dc.b	"File exists, overwrite ?",0
t16	dc.b	"Yes",0
t17	dc.b	"Cancel",0
t18	dc.b	"Sorry, buffer is empty !",0
t19	dc.b	"Cancel",0
t20	dc.b	10,"Loading executable '%s'...",0
t21	dc.b	"No hunk_header, not an executable file !",0
t22	dc.b	"Cancel",0
t23	dc.b	"Too many hunks, only one hunk supported !",0
t24	dc.b	"Buffer too large, maximum is 1012 bytes !",0
t25	dc.b	"Can't find hunk_code !",0
t26	dc.b	10,3,"%l bytes",1," code size.",1,0
t27	dc.b	10,"Saving as executable '%s'...",0
t28	dc.b	10,3,"%l bytes",1," read.",0
t29	dc.b	10,3,"%l bytes",1," written.",0
t30	dc.b	10,"Writing header...",0
t31	dc.b	10,"Writing code...",0
t32	dc.b	"Not enough chip memory !",0
t33	dc.b	10,"Reading bootblock from DFx:...",0
t34	dc.b	"Warning: I/O-Error #  ",0
t35	dc.b	"Write bootblock to DFx: ?",0
t36	dc.b	"Yes",0
t37	dc.b	"Cancel",0
t38	dc.b	10,"Writing bootblock to DFx:...",0
t39	dc.b	"Start sector:",0
t40	dc.b	"End sector  :",0
t41	dc.b	"Illegal sectors (only 0-1759) !",0
t42	dc.b	"Sorry",0
t43	dc.b	10,"Reading sectors %l-%l from DFx:...",0
t44	dc.b	"Not enough disk space, lower start sector !",0
t45	dc.b	10,"Writing sectors %l-%l to DFx:...",0
t46	dc.b	"Write sectors to DFx: ?",0
t47	dc.b	"Please select size:",0
t48	dc.b	"Word",0
t49	dc.b	"Long",0
t50	dc.b	10,"Saving as dc.x file '%s'...",0
t51	dc.b	10,"Loading IFF file '%s'...",0
t52	dc.b	"That's not an IFF file !",0
t53	dc.b	10," FORM found. ",3,"%s",1,0
t54	dc.b	"Only ILBM and 8SVX files supported !",0
t55	dc.b	"Can't find bitmap header !",0
t56	dc.b	10," BMHD found. %l words x %l rows x %l planes"
	dc.b	3,"  (%l bytes)",1,0
t57	dc.b	10," CMAP found. %l colors  ",3,"(%l bytes)",1,0
t58	dc.b	"Found two color maps !?",0
t59	dc.b	10," BODY found.",0
t60	dc.b	"Unknown compression used !",0
t61	dc.b	"Put planes or rows together ?",0
t62	dc.b	"Planes",0
t63	dc.b	"Rows",0
t64	dc.b	"No Voice-8-Header found !",0
t65	dc.b	10," VHDR found. %l samples/sec",0
t66	dc.b	10," BODY found.  ",3,"%l bytes",1,0
t67	dc.b	10,"Converting to RAW...",0
t68	dc.b	10,"Writing sectorloader (%l-%l) to DFx:...",0
t69	dc.b	"Add shadow bitplane ?",0
t70	dc.b	"Yes",0
t71	dc.b	"No",0
t72	dc.b	10,"Shadow bitplane added.  ",3,"(%l bytes)",1,0
t73	dc.b	10,"Writing hunk_end...",0
t74	dc.b	"Couldn't open requester window !",10,0
t75	dc.b	10,3,"Disk error !",10,1,0
t76	dc.b	10,3,"Not enough memory !",10,1,0
t77	dc.b	"Couldn't open screen !",10,0
t78	dc.b	"Couldn't open window !",10,0
t79	dc.b	"Enter filename:",0
t80	dc.b	"Add color registers ?",0
t81	dc.b	"Allocate or free sectors ?",0
t82	dc.b	"Free",0
t83	dc.b	"Allocate",0
t84	dc.b	10,"Reading bitmap from DFx:...",0
t85	dc.b	10,"Sectors %l-%l %s.",0
t86	dc.b	"allocated",0
t87	dc.b	"freed",0
t88	dc.b	10,"Writing new bitmap back...",0
t89	dc.b	"Write back new bitmap ?",0
	even

tabout	dc.w	80,30,480,140
	dc.b	47,1,3,"FILE CONVERTER",0
	dc.b	45,3,3,"----------------",0
	dc.b	4,7,1,"The Loadfile-Data-IFF-Sector-Bootblock-Source-Converter",0
	dc.b	27,12,3,"Programmed 1992 by Patrick Schiel",0
	dc.b	31,14,3,"Copyright (c) Schiel Software",0
	dc.b	49,18,1,"Version 1.0",0
	dc.b	35,20,1,"Final release 26-Apr-1992",0
	dc.b	15,24,3,"Any questions, suggestions or bugs?  Write to:",0
	dc.b	46,28,1,"p.schiel      ",0
	dc.b	47,30,1,"   @gmail.com",0
	dc.b	44,32,1,"                ",0
	dc.b	0

	section	2,bss
	
filenam	ds.b	68
hbuf	ds.b	260
repport	ds.b	34
number	ds.b	12
dirbuf	ds.b	34
filebuf	ds.b	34

	section	3,bss_c

diskio	ds.b	56
diskbuf	ds.b	1024


