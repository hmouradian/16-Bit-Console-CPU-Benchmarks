;*********************************************************
;* GenesisCPUBenchTest.asm
;*
;* Program description:
;*   This program tests the performance of the Sega
;*   Genesis (Gen) Central Processing Unit (CPU)
;*   as follows:
;*     1) Load and initalize the Gen settings.
;*     2) Display a uniform blue background on screen.
;*     3) Calculate 1 + 1 for 8,323,200 times.
;*     4) Display a uniform green background on screen.
;*     5) Loop until Gen is reset or turned off.
;*
;* Update History:
;*   Feb 09 2022 - First version. Hagop Mouradian
;*********************************************************

; Local constants.
VDPController = $00C00004
VDPBuffer     = $00C00000
NUM_xC0000003 = $C0000003
NUM_x8F00     = $8F00
NUM_254       = $00FE
NUM_127       = $007F
NUM_23        = $0017
NUM_1         = $01
NUM_0         = $00000000
COLOUR_BLUE   = $0800
COLOUR_GREEN  = $00E0

; Initialize game ROM header.
InitializeROMHeader:
	dc.l $00FFFFFE
	dc.l StartProgram
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.b "Sega Genesis    "
	dc.b "Hagop Mouradian "
	dc.b "GenesisCPUBenchTest                               "
	dc.b "GenesisCPUBenchTest                               "
	dc.b "2022/02/06    "
	dc.w $0000
	dc.b "J               "
	dc.l $00000000
	dc.l HandlerTerminate
	dc.l $00FF0000
	dc.l $00FFFFFF
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.b "                                        "
	dc.b "JUE             "

; Start of game program.
StartProgram:
	; Initializations
	move.w #$2700,sr
	move.w $00A10001,d0
	andi.w #$000F,d0
	beq Skip
	move.l #'Sega',$00A14000
Skip:
	; Setup Z80
	move.w #$0100,$00A11100
	move.w #$0100,$00A11200
WaitSetupZ80:
	btst #$0000,$00A11101
	bne WaitSetupZ80
	move.l #$00A00000,a1
	move.l #$00C30000,(a1)
	move.w #$0000,$00A11200
	move.w #$0000,$00A11100

	; Initialize the Video Display Processor.
	move.l #InitializeVDPRegisters,a0
	move.l #$00000018,d0
	move.l #$00008000,d1
CopyVDP:
	move.b (a0)+,d1
	move.w d1,$00C00004
	add.w #$0100,d1
	dbra d0,CopyVDP
	move #$2700,sr
Main:
	; Initializations.
	move.l #NUM_0,d0

	; Short delay before continuing.
	move.w #NUM_23,d3
LoopD3Register:
	move.w #NUM_254,d2
LoopD2Register:
	move.w #NUM_254,d1
LoopD1Register:
	dbra d1,LoopD1Register
	dbra d2,LoopD2Register
	dbra d3,LoopD3Register

	; Set screen background to blue.
	move.w #NUM_x8F00,VDPController
	move.l #NUM_xC0000003,VDPController
	move.w #COLOUR_BLUE,VDPBuffer

	; Run 128 * 255 * 255 of d0 = 1 + 1.
	move.w #NUM_127,d3
LoopD3Register2:
	move.w #NUM_254,d2
LoopD2Register2:
	move.w #NUM_254,d1
LoopD1Register2:
	move.b #NUM_1,d0
	addi.b #NUM_1,d0
	dbra d1,LoopD1Register2 ; Loop 254->0
	dbra d2,LoopD2Register2 ; Loop 254->0
	dbra d3,LoopD3Register2 ; Loop 127->0

	; Set screen background to green.
	move.w #NUM_x8F00,VDPController
	move.l #NUM_xC0000003,VDPController
	move.w #COLOUR_GREEN,VDPBuffer

LoopProgram:
	jmp LoopProgram

; Interrupts and handlers.
HandlerEmpty:
	rte

HandlerTerminate:
	rte

InitializeVDPRegisters:
	rte

;***************
;* End of file *
;***************