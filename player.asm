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
        bmi nofirepress
        bvc nofirepress
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
                


        