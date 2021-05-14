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

                rts
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
               lda (zp+1),y
               cmp #sweet_top_left
               beq remove_sweet1
               cmp #sweet2_top_left
               beq remove_sweet2
               cmp #sweet3_top_left 
               beq remove_sweet3
               cmp #bomb_top_left
               beq destroybomb
               cmp #spikes1
               beq _playerhit
               cmp #spikes2
               beq _playerhit
               
               cmp #skull_top_left
               bcs _playerhit
               rts
_playerhit    
               jmp playerhit 
               
               ;The player picks up a bomb - clear the screen
               ;and award 100 points
destroybomb
               jsr remove_object
               jsr clearplayarea
               jsr recolour
               jsr doscore
               lda #<sfx_bomb 
               ldy #>sfx_bomb 
               ldx #14
               jsr sfxplay
               rts
               
               ;The player picks up a sweet worth 200 points 
               
remove_sweet1               
                jsr remove_object
                jsr recolour
                jsr doscore
                jsr doscore
                lda #<sfx_pickup1
               ldy #>sfx_pickup1
               ldx #14
               jsr sfxplay
                rts
                                  
                ;The player picks a sweet worth 500 points 
remove_sweet2                
                jsr remove_object
                jsr recolour
                jsr doscore
                jsr doscore
                jsr doscore
                lda #<sfx_pickup2
               ldy #>sfx_pickup2
               ldx #14
               jsr sfxplay
                rts
                
remove_sweet3 
               jsr remove_object
               jsr recolour
               jsr doscore
               jsr doscore
               jsr doscore 
               jsr doscore
               jsr doscore
               lda #<sfx_pickup3
               ldy #>sfx_pickup3
               ldx #14
               jsr sfxplay
               rts
               
                

               ;Remove sweets from top left
remove_object   lda #void
                sta (zp+1),y
                iny
                lda #void
                sta (zp+1),y
                tya
                clc
                adc #$28
                tay
                lda #void
                sta (zp+1),y
                dey
                lda #void
                sta (zp+1),y
                rts
               
                ;Player gets killed

playerhit       lda #0
                sta playerdeathdelay
                sta playerdeathpointer
                lda #1
                sta playerisdead
                lda #<sfx_dead
               ldy #>sfx_dead
               ldx #14
               jsr sfxplay
                rts
                
                ;Smart bomb was activated, 
                ;clear the entire play area
                
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
