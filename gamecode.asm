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
        jsr plotsweets
        jmp titlecode
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
        
        ldx $fb
        txs
        
        ;Reset firebutton properties and 
        ;speed skill

        lda #0 
        sta firebutton
        sta playerspeed
        sta dirdelay
        sta shielddelay
        sta shieldpointer
        sta shieldtimer

        lda #0
        sta spawnsweettimer
        sta playerdirset
        sta animpointer 
        sta animdelay
        sta playerisdead
        lda #$c0
        sta playeranimtype
        jsr randomizer
        jsr randomizer
       
        ;Init exploder
        ldx #10
        stx explodepointer
        
        ;Reset spawn time expiry
        lda #100
        sta spawntimeexpiry
        
        lda #0
        sta leveltimer
        sta leveltimer+1
        
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
        lda #$0a ;Light red outline - Char multicolour 1
        sta $d022
        lda #$07 ;Yellow outline - Char multicolour 2
        sta $d023
        
        ;Reset player idle wait time
        
        lda #200
        sta playerwaittime
        
        ;Set amount of lives the player has to 3
        lda #3
        sta lives
        
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
        lda #1 ;In game music
        jsr musicinit
        cli
        
        ;Initialise lives indicator
        jsr livesindicator
        
        
;---------------------------------------
;Setup the player sprite properties and
;other default game settings
;---------------------------------------

 
        lda #$ff
        sta $d015
        sta $d01c
        ldx #$00
zerospriteframes
        lda #$ff
        sta $07f8,x
        lda #$02
        sta $d027,x
        inx
        cpx #8
        bne zerospriteframes
        lda #$07
        sta $d025
        lda #$0a
        sta $d026
        
        jmp getready ;Jump directly to the GET READY screen
        
setupgame 
        
        ;Jump to main game loop
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
        
;Setup the main game code - init all sprites,
;then position the player and the dial        
        
setupgamecode
  
        ldx #$00
removeallsprites
        lda #$00
        sta objpos,x
        inx
        cpx #$10
        bne removeallsprites
        jsr expandspritearea
        
        lda #$c0
        sta $07f8
        lda #$d8
        sta $07f9
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
        
        lda #6
        sta $d028
        
        lda #1 ;Setup in game music
        
        jsr musicinit
        jsr expandspritearea
        
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
        
        ;Player controller (using fire button)
        ;and player movement
        jsr playercontrol

        ;Random reading of plotting sweets
        jsr plotsweets
        
        ;Background animation
        jsr animbackground

        ;Level control 
        
        jsr levelcontrol
        jsr screenexploder
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


;-----------------------------------------------
;Random sweet plotter routine
;-----------------------------------------------

plotsweets
        ;First wait for timer to spawn new sweets 
        ;before we can produce a sweet

        lda spawnsweettimer
        cmp spawntimeexpiry
        beq spawnnextsweet
        inc spawnsweettimer
        rts
spawnnextsweet
        lda #0
        sta spawnsweettimer

        ;Now randomize the value and then
        ;plot one of eight different objects
        ;randomly selected. Then store to plot
        ;counter
        
        jsr randomizer
        sta sweetplotcounter
        
        ;Call table read to position random
        ;selected object to spawn onto the 
        ;screen.
        
        ldx sweetplotcounter
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
        ;plotting the sweet

placesweet
objmod1  
        lda #sweet_top_left
plotstore1
        sta $0400
        lda plotstore1+1
        clc
        adc #1
        sta plotstore2+1
        lda plotstore1+2
        sta plotstore2+2
objmod2 lda #sweet_top_right
plotstore2
        sta $0401
objmod3
        lda #sweet_bottom_left
plotstore3
        sta $0428
        lda plotstore3+1
        clc
        adc #1
        sta plotstore4+1
        lda plotstore3+2
        sta plotstore4+2
objmod4
        lda #sweet_bottom_right
plotstore4
        sta $0429
        
        
        
        ;Once again, refresh the game attributes so all objects
        ;that have been spawned are the correct objects 
        ;that appear on screen.
repaint        
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

;Level control - Basically tiime each level 
;reset the object spawn delay counter and
;make the spawn become more rapidly.

;----------------------------------------------

levelcontrol
          lda leveltimer
          cmp #$32 ;32 = 1 second
          beq switchtimer
          inc leveltimer
          rts 
switchtimer
          lda #0
          sta leveltimer
          lda leveltimer+1
          cmp #30 ;30 secs = level up
          beq levelup
          inc leveltimer+1
          rts
levelup   lda #0
          sta leveltimer
          sta leveltimer+1
          lda spawntimeexpiry
          cmp #10
          beq spawnnomore
          sec
          sbc #10
          sta spawntimeexpiry
          
          lda #0 
          sta spawnsweettimer
          lda #<sfx_levelup
          ldy #>sfx_levelup
          ldx #14
          jsr sfxplay
spawnnomore
          rts 
          
          
;----------------------------------------------
;Get ready screen - Setup sprites on the main
;game board
;----------------------------------------------

getready  
          
          ldx #$00
setupgrsprites
          lda getreadytable,x
          sta $07f8,x
          lda #$02
          sta $d027,x
          inx
          cpx #8
          bne setupgrsprites
        
          ldx #$00
putgrposition
          lda getreadypos,x
          sta objpos,x
          inx
          cpx #$10
          bne putgrposition
          lda #0
          sta firebutton
          ;Synchonise loop 
          
          lda #3 ;Play Get Ready jingle 
          jsr musicinit
          
getreadyloop          
          lda #0
          cmp rt
          beq *-3
          jsr expandspritearea
          lda $dc00
          lsr
          lsr
          lsr
          lsr
          lsr
          bit firebutton
          ror firebutton
          bmi getreadyloop
          bvc getreadyloop
          lda #0
          sta firebutton
          lda #250
          sta shieldtimer
          jmp setupgamecode
          
;----------------------------------------------
;Screen explosion routine
screenexploder
         
          lda explodedelay
          cmp #1
          beq doexplosion
          inc explodedelay
          rts
doexplosion 
          lda #0
          sta explodedelay
          ldx explodepointer
          lda explodecolourtable,x
          
          sta $d021
          inx
          cpx #11
          beq endexplode
          inc explodepointer
          rts
endexplode
          ldx #10
          stx explodepointer
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