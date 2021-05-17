;=======================================
;               GYRO-RUN
;       Written by Richard Bayliss
;        
;       (C) 2021 The New Dimension
;=======================================

;----------------------------------------
;Disable all IRQ registers and init the
;SID chip. Refresh keypress, so that no
;other keys have been typed in after 
;game over has taken place 
;----------------------------------------

hiscorecheck
           sei
           ldx #$31
           ldy #$ea
           stx $0314
           sty $0315
           lda #$81
           sta $dc0d
           sta $dd0d
           lda #$00
           sta $d015
           sta $d01a
           sta $d019
           
            ;Convert score to final score
            
            ldx #$00
convsc      lda score,x
            sec 
            sbc #$80
            sta finalscore,x
            inx
            cpx #6
            bne convsc
            
            
            ;Set screen settings 
            
            lda #$03
            sta $dd00
            lda #$12 ;Read backup charset
            sta $d018
            lda #$08
            sta $d016
            lda #$1b
            sta $d011
            
            lda #0
            sta $d020
            sta $d021
            sta $d015
         
;WARNING !!!
  
;Unoptimized version of hi score check routine. There 
;was a more compact version of the hi-score check 
;routine, but it messes up the pointers inside the 
;main music. So I decided to use the unoptimized
;approach. It generates awfully long code for checking
;and moving score / name rank to correct position but 
;the routine does work.

;Generate macro for checking score with hi score data 

!macro checkhiscorepos _hiscore {
  
            lda finalscore
            sec
            lda _hiscore+5
            sbc finalscore+5
            lda _hiscore+4
            sbc finalscore+4
            lda _hiscore+3
            sbc finalscore+3
            lda _hiscore+2
            sbc finalscore+2
            lda _hiscore+1
            sbc finalscore+1
            lda _hiscore
            sbc finalscore
}
          
;Also macro for moving scores and names 

!macro moverank rank_source, rank_target {
  
            lda rank_source,x
            sta rank_target,x
            
}
;----------------------------------------------------------------
;Check for first place position 
;----------------------------------------------------------------
            +checkhiscorepos hiscore1 ;<- call macro rountine for
            bpl not_first_place       ;   scrore checking
            jsr nameentry
            
            ;Move ranks (hiscores)
            ldx #$00
movescores1 +moverank hiscore4, hiscore5 
            +moverank hiscore3, hiscore4
            +moverank hiscore2, hiscore3 
            +moverank hiscore1, hiscore2 
            +moverank finalscore, hiscore1
            inx
            cpx #6
            bne movescores1
            
            ;Move ranks (names)
            ldx #$00
movenames1  +moverank name4, name5
            +moverank name3, name4
            +moverank name2, name3
            +moverank name1, name2
            +moverank name, name1
            inx
            cpx #9
            bne movenames1
            
            jmp exitandsavehiscores

not_first_place

;----------------------------------------------------------------
;Check for second place position 
;----------------------------------------------------------------
            
            +checkhiscorepos hiscore2
            bpl not_second_place
            jsr nameentry
            
            ;Move score and name to second rank 
            
            ldx #$00
movescores2 +moverank hiscore4, hiscore5
            +moverank hiscore3, hiscore4
            +moverank hiscore2, hiscore3
            +moverank finalscore, hiscore2
            inx
            cpx #6
            bne movescores2
            
            ;Now move names to second place
            
            ldx #$00
movenames2  +moverank name4, name5
            +moverank name3, name4
            +moverank name2, name3
            +moverank name, name2
            inx
            cpx #9
            bne movenames2
            jmp exitandsavehiscores
            
not_second_place


;----------------------------------------------------------------
;Check for third place position 
;----------------------------------------------------------------

            +checkhiscorepos hiscore3
            bpl not_third_place
            jsr nameentry 
            ldx #$00
movescores3 +moverank hiscore4, hiscore5
            +moverank hiscore3, hiscore4 
            +moverank finalscore, hiscore3
            inx
            cpx #6
            bne movescores3
            
            ldx #$00
movenames3  +moverank name4, name5
            +moverank name3, name4
            +moverank name, name3
            inx
            cpx #9
            bne movenames3
            jmp exitandsavehiscores
            
not_third_place


;----------------------------------------------------------------
;Check for fourth place position 
;----------------------------------------------------------------

            +checkhiscorepos hiscore4
            bpl not_fourth_place
            jsr nameentry
            
            ldx #$00
movescores4 +moverank hiscore4, hiscore5
            +moverank finalscore, hiscore4
            inx
            cpx #6
            bne movescores4
            
            ldx #$00
movenames4  +moverank name4, name5
            +moverank name, name4
            inx
            cpx #9
            bne movenames4
            jmp exitandsavehiscores
            
not_fourth_place

;----------------------------------------------------------------
;Check for last place position 
;----------------------------------------------------------------
      
            +checkhiscorepos hiscore5
            bpl no_hi_scores
            jsr nameentry
            ldx #$00
movescores5 +moverank finalscore, hiscore5
            inx
            cpx #6
            bne movescores5
            
            ldx #$00
movenames5  +moverank name, name5
            inx
            cpx #9
            bne movenames5
              
exitandsavehiscores
            jmp mainsave
            
;----------------------------------------------------------------
;No hiscore achieved, skip saving and jump to title screen
;----------------------------------------------------------------

no_hi_scores
            jmp titlecode
            
;----------------------------------------------
;Keyboard input based name entry routine
;----------------------------------------------
nameentry  
                 lda #5
         jsr $ffd2

         ldx #16
         ldy #14
         clc
         jsr $fff0   
            lda #$03
            sta $dd00
            lda #$12
            sta $d018
            lda #$00
            sta $d015
            lda #$08
            sta $d016
            ldx #$00
clearscreen lda #$20
            sta screen,x
            sta screen+$100,x
            sta screen+$200,x
            sta screen+$2e8,x
            lda #14
            sta colour,x
            sta colour+$100,x
            sta colour+$200,x
            sta colour+$2e8,x
            inx
            bne clearscreen
    
            ldx #$00
display     lda message1,x
            
            sta screen+(6*40),x
            lda message2,x
           
            sta screen+(9*40),x
            lda message3,x
          
            sta screen+(10*40),x
            lda message4,x 
            
            sta screen+(13*40),x 
            inx
            cpx #40
            bne display
            
            ;Init key pointers
          ;Hi score IRQ interrupts
            
            ldx #<hiirq
            ldy #>hiirq
            stx $0314
            sty $0315
            lda #$7f
            sta $dc0d
            lda #$1b
            sta $d011
            lda #$01
            sta $d01a
            
            
           lda #$04
           jsr musicinit
           cli
           ;Separators
         ldx #$00
makeseps lda #$2d
         sta $06b6,x
         lda #$04
         sta $dab6,x
         inx
         cpx #9
         bne makeseps

         lda #0
         sta namecount
         sta buffer
         

;--------------------------------------------------------
;Main keyboard input routine. Only allowed to use letter
;keys, spacebar, delete and return
;--------------------------------------------------------          

keypress
            jsr $ffe4
            cmp #$0d
            beq return
            cmp #$14
            beq delete
            cmp #$20
            beq typein
            cmp #$41
            bcc keypress
           
typein      
            jsr $ffd2
            inc namecount
            lda namecount
            cmp #9
            beq return
            jmp keypress
return      jmp grabname

delete      sta buffer
            lda namecount
            beq nodelete
            lda buffer
            jsr $ffd2
            dec namecount
nodelete    jmp keypress

;Register screen to buffer name
grabname
            ldx #$00
grabloop    lda $068e,x 
            sta name,x
            inx
            cpx #9
            bne grabloop
            rts
            
;----------------------------------------------------------

;Hi score IRQ 

hiirq       inc $d019
            lda $dc0d
            sta $dd0d
            lda #$f8
            sta $d012
            jsr musicplayer
            
            jmp $ea31

;----------------------------------------------------------
namecount   !byte 0
buffer      !byte 0
            
            !ct scr
message1    !text "             congratulations            "
message2    !text "     your score is a real spinner       "
message3    !text "you have made it onto the hall of fame. "
message4    !text "        please type in your name.       "
name        !text "         "
finalscore  !byte $30,$30,$30,$30,$30,$30
            
