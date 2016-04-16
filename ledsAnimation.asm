; ------------------------------------------------------------------------------
; Project:	Leds animation in Assembly
; File:		ledsAnimation.asm
; Author:	Augusto Hoffmann
; Created:	2016-04-16
; Modified:	2016-04-16
; Version:	1.0
; Notes:	
; ------------------------------------------------------------------------------



; ------------------------------------------------------------------------------
; Include definition files
; ------------------------------------------------------------------------------
.include	"m328pdef.inc"



; ------------------------------------------------------------------------------
; Register and constants definitions
; ------------------------------------------------------------------------------
.def		auxReg		= R16
<<<<<<< HEAD
;.def		counter		= R17
.def		pushedLed	= R18
.def		pusherLeds	= R19
.def		ledsOut		= R20
=======
;.def		counter		= R18
.def		pushedLed	= R19
.def		pusherLeds	= R20
.def		ledsOut		= R21
>>>>>>> origin/master
.equ		buttonDdr	= DDRB
.equ		buttonPort	= PORTB
.equ		buttonPin	= PINB
.equ		buttonBit	= PB0
.equ		ledsDdr		= DDRD
.equ		ledsPort	= PORTD


; ------------------------------------------------------------------------------
; Interruption vectors
; ------------------------------------------------------------------------------



; ------------------------------------------------------------------------------
; Constants stored en Flash Memory
; Note: Variables must be multiples of 2, since memory us organized in 16 bits
; ------------------------------------------------------------------------------



; ------------------------------------------------------------------------------
; Main code
; ------------------------------------------------------------------------------
.ORG		0X0000

main:
	LDI		auxReg, 0x00				; LEDS port configured as output low
	OUT		ledsPort, auxReg			; ---
	LDI		auxReg, 0xFF				; ---
	OUT		ledsDdr, auxReg				; ---
	LDI		auxReg, (1 << buttonBit)	; BUTTON port config. as input pull-up
	OUT		buttonPort, auxReg			; ---
	LDI		pushedLed, 0b00000010		; turn on led1 for pushed
	LDI		pusherLeds, 0b00000001		; turn on led0 for pushers
;	LDI		counter, 0x00				; Reset counter
	
mainLoop:
	CALL	compareLeds					; Call animation subroutine
	JMP		mainLoop

; ------------------------------------------------------------------------------
; Leds bits comparision subroutine
; Registers:	-
; Constants:	-
; Dependencies:	-
; ------------------------------------------------------------------------------
compareLeds:
	SUBI	pushedLed, 0				; Only for activate Z flag on SREG
	BREQ	endCompare					; Branch endCompare if pushedLed = 0
	CALL	pusherMove					; Call animation for pusherLeds
	JMP		compareLeds					; Repeat it until pushedLed != 0
endCompare:
	LDI		pushedLed, 0b00000010		; Reset pushedLed value
	RET									; Return to main loop

; ------------------------------------------------------------------------------
; Leds movement subroutine
; Registers:	-
; Constants:	-
; Dependencies:	-
; ------------------------------------------------------------------------------
pusherMove:
	MOV		auxReg, pusherLeds			; Uses auxReg2 to compare pushedLed
	AND		auxReg, pushedLed			;	with pusherLeds
	BRNE	endPusherMove				; If != 0 MSB of pusherLeds = pushedLed
	CALL	showLeds					; If 0, show leds,
	LSL		pusherLeds					; Shift left pusherLeds
	SUBI	pusherLeds, -1				; Set LSB of pusherLeds
	JMP		pusherMove					; Repeat
endPusherMove:
	LSL		pushedLed					; When equals, shift left pushedLed
	CALL	showLeds					; Show leds with pushedLed shifted
	LDI		pusherLeds, 0x00000001		; Reset pusherLeds value
	RET									; Return to compareLeds subroutine



; ------------------------------------------------------------------------------
; Show leds subroutine
; Registers:	-
; Constants:	-
; Dependencies:	-
; ------------------------------------------------------------------------------
showLeds: 
	MOV		ledsOut, pusherLeds			; Set register ledsOut with pusherLeds
	OR		ledsOut, pushedLed			; OR op with pushedLed
	OUT		ledsPort, ledsOut			; Turn leds on 
	CALL	delay300ms					; Call delay subroutine
	RET

; ------------------------------------------------------------------------------
; Delay of 300 ms subroutine
; ------------------------------------------------------------------------------
delay300ms:
	PUSH	R18
	PUSH	R19
	PUSH	R20

	LDI		R18, 25
	LDI		R19, 90
	LDI		R20, 176
delay300msLoop: 
	DEC		R20
	BRNE	delay300msLoop
	DEC		R19
	BRNE	delay300msLoop
	DEC		R18
	BRNE	delay300msLoop
	NOP
	NOP
	POP		R20
	POP		R19
	POP		R18
	RET


; ------------------------------------------------------------------------------
; Interrupt handlers
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; Include other Assembly files
; ------------------------------------------------------------------------------