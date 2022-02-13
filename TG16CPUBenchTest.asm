;*********************************************************
;* TG16CPUBenchTest.asm
;*
;* Program description:
;*   This program tests the performance of the NEC
;*   TurboGrafx-16 (TG16) Central Processing Unit (CPU)
;*   using the following algorithm:
;*     1) Load and initalize the TG16 settings.
;*     2) Display a uniform blue background on screen.
;*     3) Calculate 1 + 1 for 8,323,200 times.
;*     4) Display a uniform green background on screen.
;*     5) Loop until TG16 is reset or turned off.
;*
;* Update History:
;*   Feb 09 2022 - First version. Hagop Mouradian
;*********************************************************

; Local constants.
VideoPort          .equ $0000
VideoRegister      .equ $0000
VideoData          .equ $0002
VideoDataP1        .equ $0003
ColourControl      .equ $0400
ColourRegister     .equ $0402
ColourData         .equ $0404
TimerControl       .equ $0C01        
IRQDisable         .equ $1402
IRQStatus          .equ $1403
SourceAddress      .equ $20EE
VDCStatusRegister  .equ $20F6
VDCRegisterPointer .equ $20F7
NUM_256            .equ $0100
NUM_255            .equ $FF
NUM_128            .equ $80
NUM_24             .equ $18
NUM_1              .equ $01
RAM_x2000          .equ $2000
RAM_x2001          .equ $2001
COLOUR_BLUE        .equ $0007
COLOUR_GREEN       .equ $01C0

;**************************************************************
;*
;* stz2b Macro
;*
;* Description:
;*   Stores two zero bytes in the specified address.
;*
;**************************************************************
stz2b	.macro
	 stz LOW_BYTE \1
	 stz HIGH_BYTE \1
	.endm

;**************************************************************
;*
;* sta2b Macro
;*
;* Description:
;*   Stores two bytes in the specified address.
;*
;**************************************************************
sta2b	.macro
	 lda LOW_BYTE \1
	 sta LOW_BYTE \2
	 lda HIGH_BYTE \1
	 sta HIGH_BYTE \2
	.endm

;**************************************************************
;*
;* vreg Macro
;*
;* Description:
;*   Updates the video register in the specified address.
;*
;**************************************************************
vreg	.macro
	lda \1
	sta <VDCRegisterPointer
	sta VideoRegister
	.endm

	; Set program memory location.
	.bank $00
	.org $FF00
	.code

; Reset system parameters.
SystemReset:
	sei
	csh
	cld
	lda #$FF
	tam #$00
	tax
	lda #$F8
	tam #$01
	txs
	lda VideoPort
	lda #$07
	sta $1402
	sta $1403
	stz $0C01
	stz <$00
	tii $2000,$2001,$1FFF
	bsr InitializeVDC
	st0 #$05
	st1 #$00
	st2 #$00
	lda #$05
	sta IRQDisable
	vreg #$05
	st1 #$CC
	cli
	jmp StartProgram

; Initialize Video Display Controller.
InitializeVDC:
        sta2b #TableVDC,<SourceAddress;
	cly
LoopInitializeVDC:
	lda [SourceAddress],Y
	bmi InitializeVDCEnd
	iny
	sta <VDCRegisterPointer
	sta VideoRegister
	lda [SourceAddress],Y
	iny
	sta VideoData
	lda [SourceAddress],Y
	iny
	sta VideoDataP1
	bra LoopInitializeVDC
InitializeVDCEnd:
	lda #$04
	sta ColourControl
	rts

; Video Display Controller table definition.
TableVDC:
	.db $05,$00,$00
	.db $06,$00,$00
	.db $07,$00,$00
	.db $08,$00,$00
	.db $09,$10,$00
	.db $0A,$02,$02
	.db $0B,$1F,$04
	.db $0C,$07,$0D
	.db $0D,$DF,$00
	.db $0E,$03,$00
	.db $0F,$10,$00
	.db $13,$00,$7F
	.db -1

; Interrupt definitions.
InterruptVDC:
	pha
	phx
	phy
	lda VideoRegister
	sta <VDCStatusRegister
	lda <VDCRegisterPointer
	sta VideoRegister
	ply
	plx
	pla
	rti

InterruptTimer:
	sta IRQStatus
	stz TimerControl
InterruptReturn:
	rti

	; Initialize interrupts and main program.
	.bank $00
	.org $FFF6
	.dw InterruptReturn
	.dw InterruptVDC
	.dw InterruptTimer
	.dw InterruptReturn
	.dw SystemReset

	.bank $00
	.org $E000
	.code

StartProgram:
	; Short delay before continuing.
	ldx #NUM_24
LoopRepeat1:
	stx RAM_x2000
	ldx #NUM_255
LoopRegisterX1:
	ldy #NUM_255
LoopRegisterY1:
	dey
	bne LoopRegisterY1
	dex
	bne LoopRegisterX1
	ldx RAM_x2000
	dex
	bne LoopRepeat1

	; Set screen background to blue.
	stz2b ColourRegister
	sta2b #COLOUR_BLUE,ColourData
	sta2b #NUM_256,ColourRegister
	sta2b #COLOUR_BLUE,ColourData

	; Run 128 * 255 * 255 of RAM_x2001 = 1 + 1.
	ldx #NUM_128
LoopRepeat2:
	stx RAM_x2000
	ldx #NUM_255
LoopRegisterX2:
	ldy #NUM_255
LoopRegisterY2:
	lda #NUM_1
	adc #NUM_1
	sta RAM_x2001
	dey
	bne LoopRegisterY2 ; Loop 255->1
	dex
	bne LoopRegisterX2 ; Loop 255->1
	ldx RAM_x2000
	dex
	bne LoopRepeat2    ; Loop 128->1

	; Set screen background to green.
	stz2b ColourRegister
	sta2b #COLOUR_GREEN,ColourData
	sta2b #NUM_256,ColourRegister
	sta2b #COLOUR_GREEN,ColourData

LoopProgram:
	bra LoopProgram

;***************
;* End of file *
;***************