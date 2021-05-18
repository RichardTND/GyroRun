;=======================================
;               GYRO-RUN
;       Written by Richard Bayliss
;        
;       (C) 2021 The New Dimension
;=======================================

;----------------------------------------
;Player sprite to charset collision
;----------------------------------------

spritetochar 
                ldx #$18
                ldy #$32
                stx csmod1+1
                sty csmod2+1
                jsr testcollision
                ldx #$10
                ldy #$32
                stx csmod1+1
                sty csmod2+1
                jsr testcollision
                ldx #$08
                ldy #$32
                stx csmod1+1
                sty csmod2+1
                jsr testcollision
                ldx #$18
                ldy #$2a
                stx csmod1+1
                sty csmod2+1
                jsr testcollision
                ldx #$10
                ldy #$2a
                stx csmod1+1
                sty csmod2+1
                jsr testcollision
                ldx #$08
                ldy #$2a
                stx csmod1+1
                sty csmod2+1
                jsr testcollision
                ldx #$18
                ldy #$22
                stx csmod1+1
                sty csmod2+1
                jsr testcollision
                ldx #$10
                ldy #$22
                stx csmod1+1
                sty csmod2+1
                jsr testcollision
                ldx #$08
                ldy #$22
                stx csmod1+1
                sty csmod2+1
                jsr testcollision
                rts

                ;rts
testcollision

               lda $d000
               sec
csmod1         sbc #$10
               sta zp
               lda $d010
               sbc #$00
               lsr
               lda zp
               ror
               lsr
               lsr
               sta zp+3
               lda $d001
               sec
csmod2         sbc #$2a
               lsr
               lsr
               lsr
               sta zp+4
               lda #<screen
               sta zp+1
               lda #>screen
               sta zp+2
               ldx zp+4
               beq checkchar
colloop        lda zp+1
               clc
               adc #40
               sta zp+1
               lda zp+2
               adc #0
               sta zp+2
               dex
               bne colloop

checkchar      ldy zp+3
               jsr sweets1
               jsr sweets2
               jsr sweets3
               jsr bombs
               jmp skulls
               
;The player has been caught, kill instantly
               
instantkill   lda #0
               sta playerdeathdelay
               sta playerdeathpointer
               lda #1
               sta playerisdead
               jmp playdeathsfx
               
;---------------------------------------------
;Test collision with sweets type 1
;---------------------------------------------
sweets1       ldy zp+3
              lda (zp+1),y
              cmp #sweet_top_left
              beq remove_sweet_top_left 
              cmp #sweet_top_right 
              beq remove_sweet_top_right 
              
              rts
remove_sweet_top_left
              jsr remove_top_left
sweet1main    jsr score200
              jsr shieldboostcheck
              jsr playpickup1sfx
              rts
              
remove_sweet_top_right
              jsr remove_top_right
              jmp sweet1main
              
;---------------------------------------------
sweets2       ldy zp+3
              lda (zp+1),y
              cmp #sweet2_top_left
              beq remove_sweet2_top_left 
              cmp #sweet2_top_right
              beq remove_sweet2_top_right
            
              rts 
              
remove_sweet2_top_left
              jsr remove_top_left
sweet2main    jsr score300
              jsr shieldboostcheck
              jsr playpickup2sfx
              rts
remove_sweet2_top_right
              jsr remove_top_right
              jmp sweet2main
              
;----------------------------------------------
sweets3       ldy zp+3
              lda (zp+1),y
              cmp #sweet3_top_left 
              beq remove_sweet_top_left 
              cmp #sweet3_top_right
              beq remove_sweet_top_right 
            
              rts
              
remove_sweet3_top_left
              jsr remove_top_left
sweet3main    jsr score500
              jsr shieldboostcheck
              jsr playpickupsfx
              rts
              
remove_sweet3_top_right
              jsr remove_top_right
              jmp sweet3main
              
;----------------------------------------------
bombs         ldy zp+3
              lda (zp+1),y
              cmp #bomb_top_left
              beq bombactivated
              cmp #bomb_top_right 
              beq bombactivated
              cmp #bomb_bottom_left
              beq bombactivated
              cmp #bomb_bottom_right
              beq bombactivated
              rts
bombactivated 
              jsr score100
              jsr clearplayarea
              ldx #0
              stx shieldtimer
              ldx #0
              stx explodepointer
              jsr playbombsfx
              
              rts
;----------------------------------------------
skulls        lda (zp+1),y
              cmp #skull_top_left
              beq testkillplayer
              cmp #skull_top_right
              beq testkillplayer
              cmp #skull_bottom_left
              beq testkillplayer
              cmp #skull_bottom_right 
              beq testkillplayer
              rts
              
testkillplayer
              lda shieldtimer
              beq playerdeath
              rts
playerdeath   jmp instantkill              

;----------------------------------------------
;Shield boost check 
;----------------------------------------------
shieldboostcheck
              lda shieldtimer
              beq activateshield
              rts
activateshield
              lda shielddifficulty
              sta shieldtimer
              rts
              
;----------------------------------------------
;Object removals (when a sweet has been 
;picked up) 
;----------------------------------------------      
        
remove_top_left
              
              lda #void
              sta (zp+1),y 
              iny
              sta (zp+1),y
              tya
              clc
              adc #40
              tay
              lda #void 
              sta (zp+1),y
              dey 
              sta (zp+1),y
              jmp repaint
              
remove_top_right
              lda #void
              sta (zp+1),y
              dey
              sta (zp+1),y
              tya
              clc
              adc #40
              tay
              lda #void
              sta (zp+1),y
              iny
              sta (zp+1),y
              jmp repaint
              
              
score500      jsr doscore
              jsr doscore
score300      jsr doscore
score200      jsr doscore
score100      jmp doscore
              
              
;---------------------------------------------              
               
;Sound effects pointers 

playdeathsfx   ldx #7
               lda #<sfx_dead
               ldy #>sfx_dead
               jsr sfxplay
               rts
               
;Collect 1 sfx 
playpickup1sfx ldx #14
               lda #<sfx_pickup1
               ldy #>sfx_pickup1
               jsr sfxplay
               rts
               
;Collect 2 sfx 
playpickup2sfx ldx #14
               lda #<sfx_pickup2
               ldy #>sfx_pickup2
               jsr sfxplay 
               rts 
               
;Collect 3 sfx
playpickupsfx  ldx #14
               lda #<sfx_pickup3
               ldy #>sfx_pickup3
               jsr sfxplay
               rts
               
;Bomb sfx 
playbombsfx    ldx #14
               lda #<sfx_bomb
               ldy #>sfx_bomb 
               jsr sfxplay
               rts
               
;---------------------------------------------------        
               
clearplayarea   
        ldx #$00
copymap lda map,x
        sta screen,x
        lda map+$100,x
        sta screen+$100,x
        lda map+$200,x
        sta screen+$200,x
        lda map+$2e8-40,x
        sta screen+$2e8-40,x
        ldy map,x
        lda attribs,y
        sta colour,x
        ldy map+$100,x
        lda attribs,y
        sta colour+$100,x
        ldy map+$200,x
        lda attribs,y
        sta colour+$200,x
        ldy map+$2e8-40,x
        lda attribs,y
        sta colour+$2e8-40,x
        inx
        bne copymap               
        rts  

testshieldenable        
        lda shieldtimer
        beq rebootshield
        rts
rebootshield
        lda #50
        sta shieldtimer
        rts