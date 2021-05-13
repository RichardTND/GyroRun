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

        ;First check if the player is dead 
        ;if it is, then call death animation 
        ;otherwise the player is alive.
        
        lda playerisdead
        cmp #1
        bne playerisalive
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
        
        ;Check how many lives the player has
        
        dec lives
        
        ;Call lives indicator to visually remove 
        ;a heart from the screen 
        
        jsr livesindicator
        
        lda lives     ;0 lives = game over
        beq callgameover
        
        ;Else all lives are not lost, so respawn
        ;the player and default the direction it
        ;can move.
        
        lda #$54
        sta objpos
        lda #$84
        sta objpos+1
        
        ;Disable player moving
        
        lda #0
        sta playerismoving
        sta playerreleased
        sta playerdirset
        sta playerisdead
        
        ;Reset player waiting time
        lda #200
        sta playerwaittime
        rts
        
callgameover
        inc $d020
        jmp *-3

;---------------------------------------------------------------------------        
;Player is alive, so call necessary in game routines for the player. Also
;give the player the correct animation and control its movement. The 
;Sprite to Char collision is also very important and should remain in the
;player alive code loop.
;---------------------------------------------------------------------------
        
playerisalive
        
        jsr spritetochar 
        jsr autotimer ;If the player is idle, wait a few seconds then launch
        lda playertype
        sta $07f8

        lda playerreleased
        cmp #1
        beq controlmovement
        jmp firecontrol

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
               cmp #0
               bne notup
               jmp moveup
notup          cmp #1
               bne notupright
               jmp moveupright
notupright     cmp #2
               bne notright 
               jmp moveright
notright       cmp #3
               bne notdownright
               jmp movedownright
notdownright   cmp #4
               bne notdown
               jmp movedown
notdown        cmp #5
               bne notdownleft
               jmp movedownleft
notdownleft    cmp #6
               bne notleft 
               jmp moveleft 
notleft        cmp #7
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
                cmp #$3a
                bcs storeup
                lda #$3a
storeup         sta objpos+1
                rts

;Player down logic
downlogic       lda objpos+1
                clc
                adc #2
                cmp #$e2
                bcc storedown
                lda #$e2
storedown       sta objpos+1
                rts

;Player left logic
leftlogic       lda objpos
                sec
                sbc #1
                cmp #$10
                bcs storeleft
                lda #$10
storeleft       sta objpos
                rts

;Player right logic
rightlogic      lda objpos
                clc
                adc #1
                cmp #$9e
                bcc storeright
                lda #$9e
storeright      sta objpos
                rts
                
;----------------------------------------------
;Player control - Automatic launch when set to 
;idle at the start of a game.
;----------------------------------------------
autotimer       lda playerreleased
                beq beingidle
                rts
beingidle                
                lda playerwaittime
                beq idlenomore
                dec playerwaittime
                rts
idlenomore      lda #0
                sta playerwaittime
                
                ;Force player to move
                
                lda #1
                sta playerreleased
                sta playerismoving
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
                rts
                
;Show 2 lives on the screen indicator (black out the last
;heart)   
             
show2lives      lda #space
                sta screen+960+39
                lda #heart
                sta screen+960+38
                sta screen+960+37
                rts

;Show 1 life on screen indicator (black out the second heart

show1lives      lda #heart
                sta screen+960+39
                lda #space
                sta screen+960+38
                sta screen+960+37
                rts
                
;Show 0 lives on screen indicator 

show0lives      lda #space
                sta screen+960+39
                sta screen+960+38
                sta screen+960+37
                rts
                