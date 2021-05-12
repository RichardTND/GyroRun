;=======================================
;               GYRO-RUN
;       Written by Richard Bayliss
;         (CBMPRG Studio Source)
;       (C) 2021 The New Dimension
;=======================================
        *=$4000

;Main game code

        lda $02a6
        sta system
        jmp $8000
;---------------------------------------
;The player starts a fresh new game. 
;Kill all existing interrupts from the
;title screen. Setup the very first 
;level and draw it to the game screen
;---------------------------------------
gamestart
      
startnewgame
        sei
        ldx #$31
        ldy #$ea
        stx $0314
        sty $0315
        lda #$00
        sta $d019
        sta $d01a
       
        lda #$81
        sta $dc0d
        sta $dd0d

        ;Reset firebutton properties and 
        ;speed skill

        lda #0 
        sta firebutton
        sta playerspeed
        sta dirdelay

        ;Init SID chip

        ldx #$00
silence lda #0
        sta $d400,x
        inx
        cpx #$18
        bne silence

        ;Setup hardware VIC2 registers
        ;in order to display game graphics

        lda #$03 ;VIC2 Bank #$03
        sta $dd00
        lda #$18 ;Charset at $2800
        sta $d018
        lda #$1b ;Screen mode normal 
        sta $d011
        lda #$18 ;Screen position multicolour
        sta $d016
                
        lda #$00 ;Black border + background
        sta $d020
        lda #$0c
        sta $d021
        lda #$0f ;Dark grey char multicolour 1
        sta $d022
        lda #$0b ;Light grey char multicolour 2
        sta $d023
        
        ;Draw game screen

        ldx #$00
drawmap lda map,x
        sta screen,x
        lda map+$100,x
        sta screen+$100,x
        lda map+$200,x
        sta screen+$200,x
        lda map+$2e8,x
        sta screen+$2e8,x
        ldy map,x
        lda attribs,y
        sta colour,x
        ldy map+$100,x
        lda attribs,y
        sta colour+$100,x
        ldy map+$200,x
        lda attribs,y
        sta colour+$200,x
        ldy map+$2e8,x
        lda attribs,y
        sta colour+$2e8,x
        inx
        bne drawmap 

;---------------------------------------
;Setup the player sprite properties and
;other default game settings
;---------------------------------------

        ;Player X position 
        lda #$54
        sta objpos

        ;Player Y position
        lda #$84
        sta objpos+1

        ;Init player speed
        lda #0
        sta playerspeed

        ;Test single sprite 
        lda #$c0
        sta $07f8
        lda #1
        sta $d027

        lda #$ff
        sta $d015
        sta $d01c
        
        lda #$07
        sta $d025
        lda #$0a
        sta $d026
        lda #$02
        sta $d027
        
        lda #0
        sta playerreleased
;---------------------------------------
;Setup the IRQ Raster interrupt player
;---------------------------------------

        ldx #<gameirq
        ldy #>gameirq
        stx $0314
        sty $0315
        lda #$7f
        sta $dc0d
        lda #$36
        sta $d012
        lda #$1b
        sta $d011
        lda #$01
        sta $d019
        sta $d01a
        lda #0
        jsr musicinit
        cli
        jmp gameloop

;---------------------------------------
;Main IRQ raster interrupts
;---------------------------------------

gameirq

        inc $d019
        lda $dc0d
        sta $dd0d
        lda #$f8
        sta $d012
        lda #1
        sta rt
        jsr musicplayer
        jmp $ea7e
;---------------------------------------
;Music player (PAL/NTSC check)
;---------------------------------------

musicplayer
        lda system
        cmp #1
        beq pal
        inc ntsctimer
        lda ntsctimer
        cmp #6
        beq resetntsc
pal     jsr musicplay
        rts

resetntsc
        lda #0
        sta ntsctimer
        rts

;-----------------------------------------
;Main game loop
;-----------------------------------------

gameloop
        lda #0  ;Synchronize timer 
        sta rt  ;routine
        cmp rt
        beq *-3
        
        jsr expandspritearea
        jsr animplayer
        jsr playercontrol
        jmp gameloop

;-----------------------------------------
;Expand the game sprite area so that all
;sprites can use more than 256 pixels 
;and be able to move across the whole X
;position
;=========================================

expandspritearea
        ldx #$00
xloop   lda objpos+1,x
        sta $d001,x
        lda objpos,x
        asl
        ror $d010
        sta $d000,x
        inx
        inx
        cpx #$10
        bne xloop
        rts
;-----------------------------------------
;Animate the player sprites and also 
;movement
;-----------------------------------------
animplayer
        jsr rotatespinner
        lda animdelay
        cmp #1
        beq animdelayok
        inc animdelay
        rts
animdelayok
        lda #0
        sta animdelay
        ldx animpointer
        lda playerframe,x
        sta playertype
       
        inx
        cpx #8
        beq resetanim
        inc animpointer
        rts
resetanim
        ldx #0
        stx animpointer
        rts

;-----------------------------------------
;Player direction rotational vectors
;-----------------------------------------

rotatespinner
     
        lda dirdelay
        cmp rotatespeedskill
        beq dirswitch
        inc dirdelay
cannotswap
        rts
dirswitch
        lda #0
        sta dirdelay
        ldx dirpointer
        lda playerdir,x
        sta directionstore
        clc
        adc #192
        sta $07d4
       
        inx
        cpx #8
        beq resetdirection
        inc dirpointer
        rts
resetdirection
        ldx #0
        stx dirpointer
        rts
;=========================================

        ;Include source code for player control
        incasm "player.asm"        

;=========================================
        
        ;Include source code for pointers
        incasm "pointers.asm"