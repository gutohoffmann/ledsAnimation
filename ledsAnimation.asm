; ------------------------------------------------------------------------------
; Project:	Leds animation in Assembly
; File:		ledsAnimation.asm
; Author:	Augusto Hoffmann
; Created:	2016-04-16
; Modified:	2016-04-21
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
.def		pushedLed	= R17
.def		pusherLeds	= R18
.equ		buttonDdr	= DDRB
.equ		buttonPort	= PORTB
.equ		buttonPin	= PINB
.equ		buttonBit	= PB0
.equ		ledsDdr		= DDRD
.equ		ledsPort	= PORTD



; ------------------------------------------------------------------------------
; Interruption vectors
; ------------------------------------------------------------------------------
.ORG		0X0000



; ------------------------------------------------------------------------------
; Constants stored en Flash Memory
; Note: Variables must be multiples of 2, since memory us organized in 16 bits
; ------------------------------------------------------------------------------



; ------------------------------------------------------------------------------
; Main code
; ------------------------------------------------------------------------------
main:
	SBI		buttonPort, buttonBit		; Button as input tristate
	LDI		auxReg, 0x00				; LEDS port configured as output low
	OUT		ledsPort, auxReg			; ---
	LDI		auxReg, 0xFF				; ---
	OUT		ledsDdr, auxReg				; ---
	LDI		auxReg, (1 << buttonBit)	; BUTTON port config. as input pull-up
	OUT		buttonPort, auxReg			; ---
	LDI		pushedLed, 0b00000010		; turn on led1 for pushed
	LDI		pusherLeds, 0b00000001		; turn on led0 for pushers
	
mainLoop:	
	CALL	compareLeds					; Call animation subroutine
	JMP		mainLoop



; ------------------------------------------------------------------------------
; Button read subroutine
; Registers:	buttonPin
; Constants:	-
; Dependencies:	-
; ------------------------------------------------------------------------------
buttonRead:
	IN		auxReg, buttonPin			; Get button state
	SBRS	auxReg, buttonBit			; ---
	CALL	buttonPress					; ---
	RET

; ------------------------------------------------------------------------------
; Button press subroutine
; Registers:	buttonPin
; Constants:	-
; Dependencies:	-
; ------------------------------------------------------------------------------
buttonPress:							; Button handling
	CALL	debounce					; Debounce subroutine

buttonPress1:
	IN		auxReg, buttonPin			; Wait until button is released
	SBRS	auxReg, buttonBit			; ---
	JMP		buttonPress1				; Skip if button press
	CALL	debounce					; Debounce subroutine

buttonPress2:							; Button handling
	IN		auxReg, buttonPin			; Wait until button is pressed
	SBRC	auxReg, buttonBit			; ---
	JMP		buttonPress2				; Skip if button press
	CALL	debounce					; Debounce subroutine

buttonPress3:
	IN		auxReg, buttonPin			; Wait until button is released
	SBRS	auxReg, buttonBit			; ---
	JMP		buttonPress3				; Skip if button press
	CALL	debounce					; Debounce subroutine
	RET

	

; ------------------------------------------------------------------------------
; Leds bits comparision subroutine
; Registers:	pushedLed, 
; Constants:	-
; Dependencies:	-
; ------------------------------------------------------------------------------
compareLeds:
	SUBI	pushedLed, 0				; Just for activate Z flag on SREG
	BREQ	endCompare					; Branch endCompare if pushedLed = 0
	CALL	pusherMove					; Call animation for pusherLeds
	JMP		compareLeds					; Repeat it until pushedLed != 0
endCompare:
	LDI		pushedLed, 0b00000010		; Reset pushedLed value
	RET									; Return to main loop



; ------------------------------------------------------------------------------
; Leds movement subroutine
; Registers:	pusherLeds, pushedLed
; Constants:	-
; Dependencies:	-
; ------------------------------------------------------------------------------
pusherMove:
	MOV		auxReg, pusherLeds			; Uses auxReg to compare pushedLed
	AND		auxReg, pushedLed			;	with pusherLeds
	BRNE	endPusherMove				; If != 0 MSB of pusherLeds = pushedLed
	CALL	showLeds					; If 0, show leds,
	LSL		pusherLeds					; Shift left pusherLeds
	INC		pusherLeds					; pusherLeds + 1
	JMP		pusherMove					; Repeat
endPusherMove:
	LSL		pushedLed					; When equals, shift left pushedLed
	CALL	showLeds					; Show leds with pushedLed shifted
	LDI		pusherLeds, 0x00000001		; Reset pusherLeds value
	RET									; Return to compareLeds subroutine



; ------------------------------------------------------------------------------
; Show leds subroutine
; Registers:	pusherLeds, pushedLed, ledsOut
; Constants:	-
; Dependencies:	-
; ------------------------------------------------------------------------------
showLeds: 
	MOV		auxReg, pusherLeds			; Set auxReg with pusherLeds
	OR		auxReg, pushedLed			; OR op with pushedLed
	OUT		ledsPort, auxReg			; Turn leds on
	CALL	delay300ms					; Call delay subroutine
	RET



; ------------------------------------------------------------------------------
; Delay of 300 ms subroutine including call buttonRead subroutine
; ------------------------------------------------------------------------------
delay300ms:
	PUSH	R18
	PUSH	R19
	PUSH	R20

	LDI		R18, 5
	LDI		R19, 226
	LDI		R20, 128

delay300msLoop:
	CALL	buttonRead					; Call buttonRead subroutine
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
; Debounce subroutine
; Registers:	-
; Constants:	-
; Dependencies:	-
; ------------------------------------------------------------------------------
debounce:
	PUSH	R18
	PUSH	R19
	PUSH	R20
    LDI		R18, 2
    LDI		R19, 160
    LDI		R20, 142
debounceLoop: 
	DEC		R20
    BRNE	debounceLoop
    DEC		R19
    BRNE	debounceLoop
    DEC		R18
    BRNE	debounceLoop
	POP		R20
	POP		R19
	POP		R18
    NOP
	NOP
	RET


; ------------------------------------------------------------------------------
; Interrupt handlers
; ------------------------------------------------------------------------------



; ------------------------------------------------------------------------------
; Include other Assembly files
; ------------------------------------------------------------------------------