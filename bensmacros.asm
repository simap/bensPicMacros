;(C)2004 Ben Hencke

;This is a runtime if macro library. It compiles into
;real run-time evaluated nested if blocks. I use it for
;just about everything and I hope you will too.

;I tried to use nomenclature similar to mchips
;ie ifzf - check for z in f, not iffz - check f for z

;the skipping instructions have an 'if' eqivelent
;ie btfss gains an 'if' but loses a 'skip' to become 
;ifbtfs or simply ifbtf but remember that:
;* btfss skips if true
;* 'if' doesnt skip if true


;---          legend            ---
;if								if stuff
;z								zero
;c								carry bit
;dc								digit carry (carrry for low nibble)
;n								not
;f								file register
;bt								test that a bit is set
;eq								equal
;ne								not equal (short form)
;gt								greater than
;ge								greater than or equal
;lt								less than
;le								less than or equal

;q why dont i make a "if not less than - ifnlt"?
;a thats the same as "if greater than or equal - ifge".


	variable	_ifknt=0						;track number of ifs to make unique labels
	variable 	_iflevel=0						;track nested ifs

;------------------- IF -------------------
; handle the common variable setup stuff for an if block
_if macro
_ifknt set _ifknt+1							;track number of ifs to make unique labels
_iflevel set _iflevel+1						;track nested ifs
_ifstack#v(_iflevel) set _ifknt				;stack holds the unique label for this level
_ifhaselse#v(_ifstack#v(_iflevel)) set 0	;remember if this has an else or not
	endm

; all if blocks should use this goto if their expression is false
_if_goto_false macro
	goto _ifnot#v(_ifstack#v(_iflevel))
	endm

;------------------- ELSE -------------------
;------------------- ifelse -------------------
;extends an if to have else clause
ifelse macro
_ifhaselse#v(_ifstack#v(_iflevel)) set 1		;remember if this has an else, so we dont redefine the _ifnot label
	goto _endif#v(_ifstack#v(_iflevel))
_ifnot#v(_ifstack#v(_iflevel))
	endm

;------------------- ENDIF -------------------
;------------------- ifend -------------------
;ends and if or if-else
ifend macro
	if !_ifhaselse#v(_ifstack#v(_iflevel))
_ifnot#v(_ifstack#v(_iflevel))
	endif
_endif#v(_ifstack#v(_iflevel))
_iflevel set _iflevel-1
	endm


;------------------- ifz -------------------
;if zero
ifz macro
	_if
	btfss STATUS, Z
	_if_goto_false
	endm


;------------------- ifnz -------------------
;if not zero
ifnz macro
	_if
	btfsc STATUS, Z
	_if_goto_false
	endm

;------------------- ifzf -------------------
;if f is zero
ifzf macro freg
	movf freg, f
	ifz
	endm

;------------------- ifnzf -------------------
;if f is not zero
ifnzf macro freg
	movf freg, f
	ifnz
	endm


;------------------- ifeqfl -------------------
;if f is equal to literal
ifeqfl macro freg, lval
	movlw lval
	xorwf freg, w
	ifz
	endm

#define ifneqfl ifnefl
;------------------- ifnefl -------------------
;if f is not equal to literal
ifnefl macro freg, lval
	movlw lval
	xorwf freg, w
	ifnz
	endm

;------------------- ifeqff -------------------
;if f1 is equal to f2
ifeqff macro freg1, freg2
	movf freg2, w
	xorwf freg1, w
	ifz
	endm

#define ifneqff ifneff
;------------------- ifneff -------------------
;if f1 is not equal to f2
ifneff macro freg1, freg2
	movf freg2, w
	xorwf freg1, w
	ifnz
	endm


;------------------- ifc -------------------
;if carry
ifc macro
	_if
	btfss STATUS, C
	_if_goto_false
	endm

;------------------- ifnc -------------------
;if not carry
ifnc macro
	_if
	btfsc STATUS, C
	_if_goto_false
	endm

;------------------- ifdc -------------------
;if digit carry
ifdc macro
	_if
	btfss STATUS, DC
	_if_goto_false
	endm

;------------------- ifndc -------------------
;if not digit carry
ifndc macro
	_if
	btfsc STATUS, DC
	_if_goto_false
	endm

#define ifbtfs ifbtf
;------------------- ifbtf -------------------
;if bit is set file, bit
ifbtf macro freg, bitno
	_if
	btfss freg, bitno
	_if_goto_false
	endm

#define ifbtfc ifnbtf
;------------------- ifnbtf -------------------
;if bit is clear file, bit
ifnbtf macro freg, bitno
	_if
	btfsc freg, bitno
	_if_goto_false
	endm


;------------------- ifgtfl -------------------
;if f is greater than literal
ifgtfl macro freg, lval
	movlw lval+1
	subwf freg, w
	ifc
	endm

;------------------- ifgtff -------------------
;if f1 is greater than f2
ifgtff macro freg1, freg2
	movf freg2, w
	addlw 1
	subwf freg1, w
	ifc
	endm

;------------------- ifltfl -------------------
;if f is less than literal
ifltfl macro freg, lval
	movlw lval
	subwf freg, w
	ifnc
	endm
;------------------- ifltff -------------------
;if f1 is less than f2
ifltff macro freg1, freg2
	movf freg2, w
	subwf freg1, w
	ifnc
	endm

;------------------- ifgefl -------------------
;if f is greater than or equal to literal
ifgefl macro freg, lval
	movlw lval
	subwf freg, w
	ifc
	endm
;------------------- ifgeff -------------------
;if f1 is greater than or equal to f2
ifgeff macro freg1, freg2
	movf freg2, w
	subwf freg1, w
	ifc
	endm

;------------------- iflefl -------------------
;if f is less than or equal to literal
iflefl macro freg, lval
	movlw lval+1
	subwf freg, w
	ifnc
	endm

;------------------- ifleff -------------------
;if f1 is less than or equal to f2
ifleff macro freg1, freg2
	movf freg2, w
	addlw 1
	subwf freg1, w
	ifnc
	endm

;------------------- ifdecfz -------------------
;decrement f, if zero
ifdecfz macro freg
	_if
	decfsz freg, f
	_if_goto_false
	endm

;------------------- ifincfz -------------------
;increment f, if zero
ifincfz macro freg
	_if
	incfsz freg, f
	_if_goto_false
	endm


;------------------- MATH & LOGIC --------------------
;todo
;add, subtract, etc 16,24,32 bit vars

;------------------- add16ff -------------------
add16ff macro slo, shi, dlo, dhi
	movf    slo,w
	addwf   dlo,f
	
	movf    shi,w
	btfsc   STATUS,c
	incfsz 	shi,w
	addwf 	dhi,f
	endm

;------------------- add16lf -------------------
add16lf macro lval, dlo, dhi
	movf    low(lval),w
	addwf   dlo,f
	
	movf    high(lval),w
	btfsc   STATUS,c
	addlw 	1
	addwf 	dhi,f
	endm

;------------------- sub16ff -------------------
;	Rudy Wieser
; 16-bit Subtraction-with-Borrow
;       SourceH:SourceL - Number to be subtracted
;       Carry - NOT( Borrow to be subtracted )
;       DestH:DestL - Number to be subtracted FROM
;Out    DestH:DestL - Result
;       Carry - NOT( Borrow result)
sub16ff macro slo,shi,dlo,dhi
	movf    slo,W
	subwf   dlo
	movf    shi,W
	btfss   STATUS,C
	incfsz  shi,W
	subwf   dhi           \
	;dest = dest - source, WITH VALID CARRY
	;(although the Z flag is not valid).
	endm
;------------------- sub16lf -------------------

sub16lf macro lval, dlo,dhi
	movlw   low(lval)
	subwf   dlo
	movlw   high(lval)
	btfss	STATUS,C
	addlw 	1
	subwf   dhi           \
	;dest = dest - lval, WITH VALID CARRY
	;(although the Z flag is not valid).
	endm
;----------------------------



;	variable	_foobar = 0

 
mul4x4 macro arg2, arg1, dest

	movf arg2, w ; put multiplicand in w	 
	
	clrf dest
	bcf STATUS, C ; Clear the carry bit. 
	
	;check each bit of multiplier and add multiplicand 
	;and shift left for each
	btfsc arg1, 3
	addwf dest, f	
	rlf dest, f 
	btfsc arg1, 2 
	addwf dest, f	
	rlf dest, f 
	btfsc arg1, 1 
	addwf dest, f	
	rlf dest, f 
	btfsc arg1, 0 
	addwf dest, f

	endm


rand_LFSR macro rnd
	rlf rnd, w
	rlf rnd, w
	btfsc rnd, 4
	xorlw 1
	btfsc rnd, 5
	xorlw 1
	btfsc rnd, 3
	xorlw 1
	movwf rnd
	endm

rand_MARV macro rnd
	movlw 0x1d
	clrc
	rlf rnd, f
	skpnc
	xorwf rnd, f
	endm

rand_other macro rnd
	clrc
	rlf rnd, f
	swapf rnd, w
	andlw 0xe0
	rrf rnd, f
	addwf rnd, w
	addwf rnd, w
	addwf rnd, w
	sublw 0x35
	movwf rnd
	endm

rand16 macro rndlo, rndhi
	movf rndhi, w
	iorwf rndlo, w
	btfsc STATUS, Z
	comf rndhi, f
	movlw 0x80
	btfsc rndhi, 6
	xorwf rndhi, f
	btfsc rndhi, 4
	xorwf rndhi, f
	btfsc rndlo, 3
	xorwf rndhi, f
	rlf rndhi, w
	rlf rndlo, f
	rlf rndhi, f
	endm

;----------------- DATA HANDLING ----------------------



copybitff macro freg1, bit1, freg2, bit2
	btfsc freg1, bit1
	bsf freg2, bit2
	btfss freg1, bit1
	bcf freg2, bit2
	endm

copybitwf macro wbit, freg, bit
	bsf freg, bit
	andlw 1<<wbit
	btfss STATUS, Z
	bcf freg, bit
	endm

copybitfw macro wbit, freg, bit
	movlw 1<<wbit
	btfss freg, bit
	clrw 
	endm

;moves a high or low nibble from freg to low nib in w
movnibfw macro freg, ishighnib
	if ishighnib
	swapf freg, w
	else
	movfw freg
	endif
	andlw 0x0f
	endm

;moves low nib in w to low or high nib in freg
movnibwf macro freg, ishighnib
	andlw ox0f
	if ishighnib
	swapf freg, f
	bcf freg, 0
	bcf freg, 1
	bcf freg, 2
	bcf freg, 3
	iorwf freg, f
	swapf freg, f	
	else
	bcf freg, 0
	bcf freg, 1
	bcf freg, 2
	bcf freg, 3
	iorwf freg, f	
	endif

movnibff macro src, srcnib, dst, dstnib
if (srcnib && dstnib)
	movlw 0x0f		;erase hi dst
	andwf dst, f	
	movwf src		;load src
	andlw 0xf0		;erase low src
	iorwf dst, f	;combine
else if (!srcnib && !dstnib)
	movlw 0xf0
	andwf dst, f
	movwf src
	andlw 0x0f
	iorwf dst, f	
else if (!srcnib && dstnib)
	movlw 0x0f
	andwf dst, f
	swapf src, w
	andlw 0xf0
	iorwf dst, f	
else if (srcnib && !dstnib)
	movlw 0xf0
	andwf dst, f
	swapf src, w
	andlw 0x0f
	iorwf dst, f	
endif
	endm

movniblf macro lval, freg, ishighnib
if ishighnib
	movlw 0x0f
else
	movlw 0xf0	
endif
	andwf freg	;erase high or low nib of freg
	;erase high of lval just in case
	;and maybe shift it to high nib
	movlw (lval & 0x0f)<<((ishighnib!=0)*4)	
	iorwf freg, f	;combine
	endm

incnibf macro freg, ishighnib
if ishighnib
	movlw 0x10
	addwf freg, f
else
	swapf freg, w
	addlw 0x10
	movwf freg
	swapf freg,f
endif
	endm



;----------------- INTERFACE ----------------------

;check buttons

	variable _btnknt=0

definebutton macro port,pin,invert,action,fdata
_btnknt set _btnknt+1
_btnport#v(_btnknt) set port
_btnpin#v(_btnknt) set pin
_btninvert#v(_btnknt) set invert
_btnaction#v(_btnknt) set action
_btndata#v(_btnknt) set data
	endm

checkbuttons macro
	local curbtn=0
	while curbtn != _btnknt
curbtn set cutbtn+1
	
	;check debounce

	;check if btn is changed
	;if changed do action
	;set debounce
	endw
	endm	
