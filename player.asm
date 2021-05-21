;=======================================
;               GYRO-RUN
;       Written by Richard Bayliss
;        
;       (C) 2021 The New Dimension
;=======================================

;==========================================
;Main player properties and control
;==========================================

playercontrol        

        jsr updatedial
        ;First check if the player is dead 
        ;if it is, then call death animation 
        ;otherwise the player is alive.
        
        lda playerisdead
        cmp #1
        bne playerisalive
        
        ;The player is dead, so destroy 
        ;the spinner
        
        lda playerdeathdelay
        cmp #$04
        beq deathanimok
        inc playerdeathdelay
        rts
deathanimok
        lda #0
        sta playerdeathdelay
        ldx playerdeathpointer
        lda playerdeathframe,x
        sta $07f8 
        inx
        cpx #8
        beq checkrespawn
        inc playerdeathpointer
        rts
checkrespawn
        
        lda #0
        sta playerdeathpointer
        sta playerdeathdelay
        
        ;Deduct a life from the lives counter
        
        dec lives
        
        ;Call lives indicator to visually remove 
        ;a heart from the screen 
        
        jsr livesindicator
        
        lda lives     ;0 lives = game over
        beq callgameover
        
        ;Clear screen area
        
        jsr clearplayarea
        
        ;Spawn the player to its default positiion
respawn        
        lda #$54
        sta objpos
        lda #$c0
        sta objpos+1
        
        ;Disable player moving and init all 
        ;colour flash/shield pointers
        lda #1
        sta playerdirset
        lda #1
        sta playerismoving
        sta playerreleased
        sta playerdir
        sta dirpointer
        lda #0
        sta playerisdead
        lda #200
        sta shieldtimer
        lda #0
        sta shieldpointer
        sta shielddelay
        rts
        
        ;All lives are lost, run game over 
        
callgameover

        lda #%11111111
        sta $d015
        sta $d01c
        jmp gameover

;---------------------------------------------------------------------------        
;Player is alive, so call necessary in game routines for the player. Also
;give the player the correct animation and control its movement. The 
;Sprite to Char collision is also very important and should remain in the
;player alive code loop.
;---------------------------------------------------------------------------
        
playerisalive
        
        jsr spritetochar 
        jsr rotatespinner
        jsr animplayer
        jsr testshield
        ;lda playerreleased
        ;cmp #1
        ;beq controlmovement
        ;jmp firecontrol

;The player is allowed to move

controlmovement
        jsr testdirectiontomove

;The player is waiting for fire button
;if pressed, the player should get released


firecontrol        
        lda $dc00
        lsr
        lsr
        lsr
        lsr
        lsr
        bit firebutton
        ror firebutton
        bmi nofirepress1
        bvc nofirepress1
        jmp oklaunch
nofirepress1        
        lda $dc01
        lsr
        lsr
        lsr
        lsr
        lsr
        bit firebutton
        ror firebutton 
        bmi nofirepress
        bvc nofirepress 
        
oklaunch        
        lda #0
        sta firebutton
       
        lda #1
        sta playerreleased
        sta playerismoving
        lda directionstore
        sta playerdirset
        lda #<sfx_shift
        ldy #>sfx_shift
        ldx #14
        jsr sfxplay
nofirepress
        rts
stopmoving
       
        rts

;------------------------------------
;Test direction in which the player 
;is allowed to move
;------------------------------------

testdirectiontomove
               lda playerspeed
               cmp playerspeedskill
               beq playeroktomovenow
               inc playerspeed
               rts
playeroktomovenow
               lda #0
               sta playerspeed
                
               lda playerdirset
               cmp #1
               bne notup
               jmp moveup
notup          cmp #2
               bne notupright
               jmp moveupright
notupright     cmp #3
               bne notright 
               jmp moveright
notright       cmp #4
               bne notdownright
               jmp movedownright
notdownright   cmp #5
               bne notdown
               jmp movedown
notdown        cmp #6
               bne notdownleft
               jmp movedownleft
notdownleft    cmp #7
               bne notleft 
               jmp moveleft 
notleft        cmp #8
               bne notupleft
               jmp moveupleft
notupleft      rts

;Player moves up only
moveup         jsr uplogic
               rts

;Player moves up and right
moveupright    jsr uplogic
               jsr rightlogic
               rts

;Player moves right only
moveright      jsr rightlogic
               rts 

;Player moves down and right
movedownright  jsr downlogic
               jsr rightlogic
               rts

;Player moves down only
movedown       jsr downlogic
               rts

;Player moves down and left
movedownleft   jsr downlogic
               jsr leftlogic
               rts

;Player moves left only
moveleft       jsr leftlogic
               rts

;Player moves up and left
moveupleft     jsr uplogic
               jsr leftlogic
               rts

;------------------------------------
;Movement logic
;------------------------------------

;Player up logic:
uplogic         lda objpos+1
                sec
                sbc #2
                cmp #player_up_stop_position
                bcs storeup
                
                lda #player_up_stop_position
storeup         sta objpos+1
                rts

;Player down logic
downlogic       lda objpos+1
                clc
                adc #2
                cmp #player_down_stop_position
                bcc storedown
                lda #player_down_stop_position
storedown       sta objpos+1
                rts

;Player left logic
leftlogic       lda objpos
                sec
                sbc #1
                cmp #player_left_stop_position
                bcs storeleft
                lda #player_left_stop_position
storeleft       sta objpos
                rts

;Player right logic
rightlogic      lda objpos
                clc
                adc #1
                cmp #player_right_stop_position
                bcc storeright
                lda #player_right_stop_position
storeright      sta objpos
                rts
                
;---------------------------------------------                
;Lives update - This will count the number of
;lives the player has, and then indicate the
;correct value on screen
;---------------------------------------------

livesindicator  lda lives
                cmp #3
                beq show3lives
                cmp #2
                beq show2lives
                cmp #1
                beq show1lives
                jmp show0lives
                rts

;Show 3 lives on the screen indicator 

show3lives      lda #heart
                sta screen+960+39
                sta screen+960+38
                sta screen+960+37
                lda #2
                sta colour+960+39
                sta colour+960+38
                sta colour+960+37
                rts
                
;Show 2 lives on the screen indicator (black out the last
;heart)   
             
show2lives      lda #$a0
                sta screen+960+39
                lda #heart
                sta screen+960+38
                sta screen+960+37
                
                lda #2
                sta colour+960+39
                sta colour+960+38
                sta colour+960+37
                rts

;Show 1 life on screen indicator (black out the second heart

show1lives      lda #heart
                sta screen+960+39
                lda #$a0
                sta screen+960+38
                sta screen+960+37
                
                lda #2
                sta colour+960+39
                sta colour+960+38
                sta colour+960+37
                rts
                
;Show 0 lives on screen indicator 

show0lives      lda #$a0
                sta screen+960+39
                sta screen+960+38
                sta screen+960+37
                
                lda #2
                sta colour+960+39
                sta colour+960+38
                sta colour+960+37
                rts
                
;-----------------------------------------
;Player direction rotational vectors
;-----------------------------------------

rotatespinner
     
        ;joystick controlled rotation of spinner position
        ;before switching to the next sprite
        ;direction

        lda dirdelay
        cmp #6
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
        
        ;Grab joystick control 
        
jleft   lda #4
        bit $dc00 ;LEFT 
        bne jright
        jmp dialanticlockwise
        
jright  lda #8
        bit $dc00
        bne nojoy2
        jmp dialclockwise
nojoy2
        lda #4
        bit $dc01
        bne jright2
        jmp dialclockwise
        
jright2 lda #8
        bit $dc01
        bne nojoycontrol
        jmp dialanticlockwise
nojoycontrol        
        rts 
        
dialclockwise
        inc dirpointer 
        lda dirpointer 
        cmp #9
        beq resetdial
        sta dirpointer
        jmp updatedial
resetdial
        lda #1
        sta dirpointer
        jmp updatedial
        
dialanticlockwise        
        
       
        lda dirpointer
        cmp #1
        beq resetdial2 
        dec dirpointer
        
        
        
updatedial
        lda dirpointer
        sta directionstore
        clc
        adc #$d7
        sta $07f9
        rts                
        
resetdial2
        lda #$08
        sta dirpointer
        jmp updatedial
;-----------------------------------------
;Animate the player sprites and also 
;movement
;-----------------------------------------
animplayer
        ;Call rotation subroutine
        ;and also make a delayed animation
        ;before switching to the next frame

      
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
        lda animtable,x
        sta $07f8
        inx
        cpx #4 ;The spinner has 4 frames
        beq resetanim
        inc animpointer
        rts
resetanim
        ldx #0
        stx animpointer
        rts


        
;---------------------------------------------
;Game over routine 

gameover lda #0
         sta $d015
        lda #2
        jsr musicinit
           ldx #$00
setupgosprites
          lda gameovertable,x
          sta $07f8,x
          lda #$02
          sta $d027,x
          inx
          cpx #8
          bne setupgosprites
        
          ldx #$00
putgoposition
          lda gameoverpos,x
          sta objpos,x
          inx
          cpx #$10
          bne putgoposition
          jsr expandspritearea
          lda #$ff
          sta $d015
          lda #0
          sta firebutton

;Wait for fire to be pressed before running 
;new front end 

goloop    lda #0
          sta rt
          cmp rt
          beq *-3
          jsr expandspritearea
          jsr screenexploder
          
          ;Background animation
          jsr animbackground
          lda $dc00
          lsr
          lsr
          lsr
          lsr
          lsr
          bit firebutton
          ror firebutton
          bmi goloop2
          bvc goloop2
          jmp hiscorecheck
goloop2   lda $dc01
          lsr
          lsr
          lsr
          lsr
          lsr
          bit firebutton
          ror firebutton
          bmi goloop
          bvc goloop
          jmp hiscorecheck

;---------------------------------------------------------

;Test shield ... The shield is only active if the 
;value of the shield is above 0 

testshield
          lda shieldtimer ;Shieldtimer as 0 = shieldout
          beq shieldout
          jsr flashshield
          dec shieldtimer
          rts
shieldout
          lda #2          ;Default spinner to red
          sta $d027       
          lda #0
          sta shieldtimer
          rts 
          
;Flash shield red scheme

flashshield
          lda shielddelay
          cmp #$02
          beq doflashnow
          inc shielddelay
          rts
doflashnow
          lda #0
          sta shielddelay
          ldx shieldpointer
          lda shieldcolourtable,x
          sta $d027
          inx
          cpx #8
          beq loopflash
          inc shieldpointer
          rts
loopflash ldx #0
          stx shieldpointer
          rts
          
          
                