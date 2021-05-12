;=======================================
;               GYRO-RUN
;       Written by Richard Bayliss
;        
;       (C) 2021 The New Dimension
;=======================================
        *=$4000

;Main game code

        lda $02a6
        sta system
        jsr plotjewels
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

        lda #0
        sta spawnjeweltimer
        sta playerdirset
        
        jsr randomizer
        
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
        sta $d021
        lda #$09 ;Brown outline - Char multicolour 1
        sta $d022
        lda #$01 ;White outline - Char multicolour 2
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
        lda #$56
        sta objpos
        
        ;Spin indicator X position
        sta objpos+2

        ;Player Y position
        lda #$84
        sta objpos+1
        
        ;Spin indicator Y position
        lda #$de
        sta objpos+3

        ;Init player speed
        lda #0
        sta playerspeed

        ;Spinner sprite
        lda #$c0
        sta $07f8
        
        ;Spinner indicator 
        lda #$d8
        sta $07f9
        
        lda #$ff
        sta $d015
        sta $d01c
        
        lda #$07
        sta $d025
        lda #$0a
        sta $d026
        lda #$02
        sta $d027
        lda #6
        sta $d028
        
        lda #0
        sta playerreleased
        
        ldx #0
scloop  lda #$30
        clc
        adc #$80
        sta score,x
        inx
        cpx #6
        bne scloop
       
        
        
        jsr updatescore
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
        ;Synchronize timer with the IRQ
        ;raster interrupt - so that the
        ;routines are running at level 
        ;speed as the interriupts

        lda #0  
        sta rt  
        cmp rt
        beq *-3
        
        ;Main game loop sub routines, 
        ;merged with the synctimer (rt)

        ;Expand sprite MSB position
        jsr expandspritearea
        
        ;Player sprite to background charset collision
        jsr spritetochar 

        ;Animate the player's spinner
        jsr animplayer

        ;Player controller (using fire button)
        ;and player movement
        jsr playercontrol

        ;Random reading of plotting jewels
        jsr plotjewels
        
        ;Background animation
        jsr animbackground

        jmp gameloop

;-----------------------------------------
;Expand the game sprite area so that all
;sprites can use more than 256 pixels 
;and be able to move across the whole X
;position
;-----------------------------------------

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
        ;Call rotation subroutine
        ;and also make a delayed animation
        ;before switching to the next frame

        jsr rotatespinner
        lda animdelay
        cmp #1
        beq animdelayok
        inc animdelay
        rts

        ;Reset delayed animation and switch
        ;to the next sprite frame

animdelayok
        lda #0
        sta animdelay
        ldx animpointer
        lda playerframe,x
        sta playertype
        inx
        cpx #4 ;The spinner has 4 frames
        beq resetanim
        inc animpointer
        rts

        ;4th frame reached, reset animation
        ;for spinner sprite

resetanim
        ldx #0
        stx animpointer
        rts

;-----------------------------------------
;Player direction rotational vectors
;-----------------------------------------

rotatespinner
     
        ;Delay rotation of spinner position
        ;before switching to the next sprite
        ;direction

        lda dirdelay
        cmp rotatespeedskill
        beq dirswitch
        inc dirdelay
cannotswap
        rts

        ;Reset delay timer and switch to next 
        ;indicated rotation position. Then 
        ;update the rotator's indicator position

dirswitch
        lda #0
        sta dirdelay
        ldx dirpointer
        lda playerdir,x
        sta directionstore
        clc
        adc #$d8
        sta $07f9
        
        inx
        cpx #8 ;Total number of directions = 8
        beq resetdirection
        inc dirpointer
        rts

        ;Reset direction of spinner
        ;indicator

resetdirection
        ldx #0
        stx dirpointer
        rts

;-----------------------------------------------
;Random jewel plotter routine
;-----------------------------------------------

plotjewels
        ;First wait for timer to spawn new jewels 
        ;before we can produce a jewel

        lda spawnjeweltimer
        cmp spawntimeexpiry
        beq spawnnextjewel
        inc spawnjeweltimer
        rts
spawnnextjewel
        lda #0
        sta spawnjeweltimer

        ;Now randomize the value and then
        ;plot one of eight different objects
        ;randomly selected. Then store to plot
        ;counter
        
        jsr randomizer
        sta jewelplotcounter
        
        ;Call table read to position random
        ;selected object to spawn onto the 
        ;screen.
        
        ldx jewelplotcounter
        lda char_read_lo,x
        sta plotstore1+1
        lda char_read_hi,x
        sta plotstore1+2
        lda char_read_lo_2,x
        sta plotstore3+1
        lda char_read_hi_2,x
        sta plotstore3+2
       
        jsr randomizer          ;Randomizer picks a random number between 0 and 255
        and #$07                ;We use AND #$07 in order to pick between 0 and 7
        sta randomobjecttospawn ;since the table has 8 bytes.
        ldx randomobjecttospawn
        lda obj_top_left_table,x
        sta objmod1+1
        lda obj_top_right_table,x
        sta objmod2+1
        lda obj_bottom_left_table,x
        sta objmod3+1
        lda obj_bottom_right_table,x
        sta objmod4+1
        
        
        ;Plot store the charset and then
        ;store to a free zeropage (for)
        ;plotting the jewel

placejewel
objmod1  
        lda #jewel_top_left
plotstore1
        sta $0400
        lda plotstore1+1
        clc
        adc #1
        sta plotstore2+1
        lda plotstore1+2
        sta plotstore2+2
objmod2 lda #jewel_top_right
plotstore2
        sta $0401
objmod3
        lda #jewel_bottom_left
plotstore3
        sta $0428
        lda plotstore3+1
        clc
        adc #1
        sta plotstore4+1
        lda plotstore3+2
        sta plotstore4+2
objmod4
        lda #jewel_bottom_right
plotstore4
        sta $0429
        
        ;Once again, refresh the game attributes so all objects
        ;that have been spawned are the correct objects 
        ;that appear on screen.
        
        ldx #$00
recolour
        ldy screen,x
        lda attribs,y
        sta colour,x
        ldy screen+$100,x
        lda attribs,y
        sta colour+$100,x
        ldy screen+$200,x
        lda attribs,y
        sta colour+$200,x
        ldy screen+$2e8,x
        lda attribs,y
        sta colour+$2e8,x
        inx
        bne recolour
        rts
      
        ;Randomizer subroutine
randomizer
        lda rand+1
        sta rtemp
        lda rand
        asl
        rol rtemp
        asl
        rol rtemp
        clc
        adc rand 
        pha
        lda rtemp
        adc rand+1
        sta rand+1
        pla
        adc #$11
        sta rand 
        lda rand+1 
        adc #$36
        sta rand+1 
        rts
        
;----------------------------------------------
;Update player score

doscore
        inc score+3
        ldx #3
scuploop
        lda score,x
        cmp #186
        bne scok
        lda #176
        sta score,x
        inc score-1,x
scok    dex
        bne scuploop
        

updatescore
        ldy #$00
topanel lda score,y
        sta screen+966,y
        iny
        cpy #6
        bne topanel
        rts
        
;----------------------------------------------

;Background animation sub routine    

animbackground
     
        lda voiddelay
        cmp #2
        beq slowok
        inc voiddelay
        rts
slowok  lda #0
        sta voiddelay
       
        lda playerdirset
        cmp #0
        bne notvoidup
        jmp scrollup
notvoidup
        cmp #1
        bne notvoidupright
        jmp scrollupright
notvoidupright
        cmp #2
        bne notvoidright
        jmp scrollright
notvoidright
        cmp #3
        bne notvoiddownright
        jmp scrolldownright
notvoiddownright
        cmp #4
        bne notvoiddown
        jmp scrolldown
notvoiddown cmp #5
        bne notvoiddownleft
        jmp scrolldownleft
notvoiddownleft
        cmp #6
        bne notvoidleft
        jmp scrollleft
notvoidleft
        cmp #7
        bne notvoidupleft
        jmp scrollupleft
notvoidupleft
        rts
        
;Void scrolling direction

scrollup
          jsr voidup
          rts
scrolldown
          jsr voiddown
          rts
scrollleft
         jsr voidleft
         rts
scrollright
         jsr voidright
         rts
scrollupright
          jsr voidup
          jsr voidright
          rts
scrolldownright
          jsr voiddown
          jsr voidright
          rts
scrolldownleft
          jsr voiddown
          jsr voidleft
          rts
scrollupleft
          jsr voidup
          jsr voidleft
          rts
          
;Scroll void up 

voidup   
          lda gamecharmemory+(void*8)
          sta uptemp
          ldx #$00
shiftup   lda gamecharmemory+(void*8)+1,x
          sta gamecharmemory+(void*8),x
          inx
          cpx #8
          bne shiftup
          lda uptemp
          sta gamecharmemory+(void*8)+7
          rts
          
voiddown  lda gamecharmemory+(void*8)+7
          sta downtemp
          ldx #$07
shiftdown lda gamecharmemory+(void*8)-1,x
          sta gamecharmemory+(void*8),x
          dex
          bpl shiftdown
          lda downtemp
          sta gamecharmemory+(void*8)
          rts
          
voidleft  ldx #$00
shiftleft lda gamecharmemory+(void*8),x
          asl
          rol gamecharmemory+(void*8),x
          asl 
          rol gamecharmemory+(void*8),x
          inx
          cpx #8
          bne shiftleft
          rts
          
voidright ldx #$00          
shiftright
          lda gamecharmemory+(void*8),x
          lsr
          ror gamecharmemory+(void*8),x
          lsr
          ror gamecharmemory+(void*8),x
          inx
          cpx #8
          bne shiftright
          rts
          
            
        
;----------------------------------------------

        ;Include source code for player control
        !source "player.asm"        

;----------------------------------------------
        
        ;Include source code for pointers
        !source "pointers.asm"

;----------------------------------------------

        ;Include source code for collision
        !source "collision.asm"
        
;----------------------------------------------