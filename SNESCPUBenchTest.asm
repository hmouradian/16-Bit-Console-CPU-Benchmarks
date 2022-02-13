;*********************************************************
;* SNESCPUBenchTest.asm
;*
;* Program description:
;*   This program tests the performance of the Super
;*   Nintendo's (SNES) Central Processing Unit (CPU)
;*   as follows:
;*     1) Load and initalize the SNES settings.
;*     2) Display a uniform blue background on screen.
;*     3) Calculate 1 + 1 for 8,323,200 times.
;*     4) Display a uniform green background on screen.
;*     5) Loop until SNES is reset or turned off.
;*
;* Update History:
;*   Feb 09 2022 - First version. Hagop Mouradian
;*********************************************************

; Local constants.
.equ ScreenDisplayRegister  $2100
.equ CGRAMAddressRegister   $2121
.equ CGRAMDataWriteRegister $2122
.equ NUM_255                $FF
.equ NUM_128                $80
.equ NUM_32                 $20
.equ NUM_24                 $18
.equ NUM_15                 $0F
.equ NUM_1                  $01
.equ NUM_0                  $00
.equ RAM_x0000              $0000
.equ RAM_x0001              $0001
.equ COLOUR_BLUE            $00F0
.equ COLOUR_GREEN           $0003

; SNES memory initializations.
.memorymap
	slotsize $8000
	defaultslot 0
	slot 0 $8000
.endme

.rombanksize $8000
.rombanks 8

; SNES cartridge initializations.
.snesheader
	id "SNES"
	name "SNESCPUBenchTest     "
	slowrom
	lorom
	cartridgetype $00
	romsize $08
	sramsize $00
	country $01
	licenseecode $00
	version $00
.endsnes

.snesnativevector
	cop EmptyHandler
	brk EmptyHandler
	abort EmptyHandler
	nmi VBlank
	irq EmptyHandler
.endnativevector

.snesemuvector
	cop EmptyHandler
	abort EmptyHandler
	nmi EmptyHandler
	reset StartProgram
	irqbrk EmptyHandler
.endemuvector

.bank $00
.org $00
.section "MainCode"

; Start of game program.
StartProgram:
	; Short delay before continuing.
	ldx #NUM_24
LoopRepeat1:
	stx RAM_x0000
	ldx #NUM_255
LoopRegisterX1:
	ldy #NUM_255
LoopRegisterY1:
	dey
	bne LoopRegisterY1
	dex
	bne LoopRegisterX1
	ldx RAM_x0000
	dex
	bne LoopRepeat1

	; Set screen background to blue.
	sep #NUM_32
	lda #NUM_128
	sta ScreenDisplayRegister
	stz CGRAMAddressRegister
	lda #NUM_0
	sta CGRAMDataWriteRegister
	lda #COLOUR_BLUE
	sta CGRAMDataWriteRegister
	lda #NUM_15
	sta ScreenDisplayRegister

	; Run 128 * 255 * 255 of RAM_x0000 = 1 + 1.
	ldx #NUM_128
LoopRepeat2:
	stx RAM_x0000
	ldx #NUM_255
LoopRegisterX2:
	ldy #NUM_255
LoopRegisterY2:
	lda #NUM_1
	adc #NUM_1
	sta RAM_x0001
	dey
	bne LoopRegisterY2 ; Loop 255->1
	dex
	bne LoopRegisterX2 ; Loop 255->1
	ldx RAM_x0000
	dex
	bne LoopRepeat2    ; Loop 128->1

	; Set screen background to green.
	sep #NUM_32
	lda #NUM_128
	sta ScreenDisplayRegister
	stz CGRAMAddressRegister
	lda #NUM_0
	sta CGRAMDataWriteRegister
	lda #COLOUR_GREEN
	sta CGRAMDataWriteRegister
	lda #NUM_15
	sta ScreenDisplayRegister

; Keep looping.
LoopProgram:
	jmp LoopProgram

; Video and interrupt handlers.
VBlank:
	rti

EmptyHandler:
	rti

.ends

;***************
;* End of file *
;***************