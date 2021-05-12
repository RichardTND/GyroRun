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
               cmp #jewel_top_left
               beq remove_jewel1
               cmp #jewel2_top_left
               beq remove_jewel2
               
               cmp #spikes1
               beq playerhit
               cmp #spikes2
               beq playerhit
               cmp #spikes3
               bcs playerhit
               rts

               ;The player picks up a jewel worth 200 points 
               
remove_jewel1               
                jsr remove_jewel
                jsr doscore
                jsr doscore
                rts
                                  
                ;The player picks a jewel worth 500 points 
remove_jewel2                
                jsr remove_jewel 
                jsr doscore
                jsr doscore
                jsr doscore
                jsr doscore
                jsr doscore
                rts
                

               ;Remove jewels from top left

remove_jewel   lda #void
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

                
               
                ;Player gets hit

playerhit       lda #$54
                sta objpos
                lda #$84
                sta objpos+1
                rts
