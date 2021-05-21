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
           ;IRQ raster interrupts in game
           ;should stop immediately
           jsr stopinterrupts
           
           lda #$00
           sta $d015
           
           sta fdelay
           sta fpointer
          
           
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
            sta firebutton
         
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
            stx $fffe
            sty $ffff
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
       

         lda #0
         sta namecount
         sta buffer
         lda #$8e
         sta nameplot+1
         lda #$06
         sta nameplot+2

;--------------------------------------------------------
;Main name input routine. Joystick controlled.

;--------------------------------------------------------          
            lda #1
            sta char
            lda #0
            sta namefinished
            sta joydelay
entryloop   lda #0
            sta rt
            cmp rt 
            beq *-3
            lda char 
nameplot    sta $068e
            jsr flashwelldonetext
            jsr joyname
            lda namefinished 
            cmp #1
            beq grabname
            jmp entryloop
            
;Register screen to buffer name
grabname
            ldx #$00
grabloop    lda $068e,x 
            sta name,x
            inx
            cpx #9
            bne grabloop
            rts
            
flashwelldonetext
            lda fdelay
            cmp #2
            beq flashset 
            inc fdelay
            rts
flashset    lda #0
            sta fdelay 
            ldx fpointer
            lda colourtable,x 
            sta fstore
            lda colourtable2,x
            sta fstore2
            inx
            cpx #10
            beq loopflashtext
            inc fpointer
            jmp storemainflash
            
loopflashtext ldx #$00
            stx fpointer
storemainflash
            ldx #0
storemainflash2            
            lda fstore
            sta colour+(6*40),x
            lda fstore2
            sta $da8e,x 
            inx
            cpx #40
            bne storemainflash2
            rts
            
;----------------------------------------------------------
;Main joystick control for name entry 
;----------------------------------------------------------

joyname     lda joydelay 
            cmp #5
            beq nameentryok
            inc joydelay
            rts
nameentryok lda #0
            sta joydelay
            
            lda #$00
            sta joybit+1
            jsr joyinputmain
            lda #$01
            sta joybit+1
            jsr joyinputmain
            rts
            
joyinputmain  
joybit      lda $dc00
            lsr ;UP 
            bcs readdown
            jmp movecharup
readdown    lsr ;DOWN
            bcs readfire
            jmp movechardown
readfire    lsr
            lsr
            lsr
            bit firebutton
            ror firebutton
            bmi nonameentry
            bvc nonameentry
            lda #0
            sta firebutton
            jmp nextchar
nonameentry rts

;----------------------------------------
;User input - Up has been pushed, so move
;character upwards. 
;----------------------------------------

movecharup  lda char
            cmp #$1a ;Last char is Z so change to UP ARROW
            beq mark_up_arrow 
            cmp #$20 ;Spacebar is last allow char so change to A
            beq mark_a
            inc char
            rts
            ;Mark character as up arrow 
mark_up_arrow 
            lda #$1e ;Up arrow marker set 
            sta char 
            rts
mark_a      lda #$01
            sta char
            rts
            
;--------------------------------------
;User input down - go down names 
;--------------------------------------            

movechardown
            lda char 
            cmp #$01 ;Below A = SPACEBAR
            beq mark_space
            cmp #$1e ;Below UP arrow = Z 
            beq mark_z
            dec char
            rts 
            
            ;Mark char on screen as space bar
mark_space  lda #$20
            sta char 
            rts
            
            ;Mark letter Z on screen 
mark_z      lda #$1a 
            sta char
            rts
            
;----------------------------------------
; Fire has been pressed, check the 
; character type and also store the char 
; onto the name if UP ARROW has been 
; detected.
;----------------------------------------            
            
nextchar      lda char 
              cmp #$1e ;Key UP ARROW = End
              beq endinput 
              cmp #$1f ;Key LEFT ARROW = delete 
              beq delinput
              
              ;Otherwise check for the character
              ;position has not exceeded
              
              lda nameplot+1
              cmp #$8e+8
              beq plotexpired
              
              ;Else move onto the next character
              inc nameplot+1
              rts
plotexpired   jmp endinput           
              
              
              ;Up arrow (END) has been detected
endinput      jsr cleararrowchars

              ;Mark name as finished
              lda #$20
              sta char
              lda #1
              sta namefinished
              rts
              
delinput      ;BACK ARROW (DEL) has been detected
              ;clear arrow keys, then check char
              ;position. If at very first char 
              ;refrain the char going back one
              ;position 
              
              jsr cleararrowchars
              lda nameplot+1
              cmp #$8e 
              beq skipdelete
             
              dec nameplot+1
              
              
skipdelete    rts

;-------------------------------------------------
;Name entry garbage clear routine. Everytime there
;is a DEL or END marker set onscreen, it should be 
;removed before confirming input.
;-------------------------------------------------              

cleararrowchars
              ldx #$08
clearnametxt  lda $068e,x 
              cmp #$1e
              beq clearnamechar
              cmp #$1f
              beq clearnamechar
              jmp skipnameclr
clearnamechar lda #$20 
              sta $068e,x
skipnameclr   dex
              bpl clearnametxt
skipnamechar              
              rts
              
hiirq         sta hstacka+1
              stx hstackx+1
              sty hstacky+1
              asl $d019
              lda $dc0d
              sta $dd0d
              lda #1
              sta rt
              jsr musicplayer
hstacka       lda #$00
hstackx       ldx #$00
hstacky       ldy #$00
              rti
              
 
;----------------------------------------------------------
namecount   !byte 0
buffer      !byte 0
fdelay      !byte 0 ;Flash delay
fpointer    !byte 0 ;Flash pointer           
fstore      !byte 0
fstore2     !byte 0
char        !byte 0
namefinished !byte 0
joydelay    !byte 0
            !ct scr
message1    !text "             congratulations            "
message2    !text "     your score is a real spinner       "
message3    !text "you have made it onto the hall of fame. "
message4    !text "         please enter your name.        "
name        !text "         "
finalscore  !byte $30,$30,$30,$30,$30,$30

colourtable !byte $00,$06,$04,$0a,$07,$01,$07,$0a,$04,$06
colourtable2 !byte $01,$07,$0a,$04,$02,$00,$02,$04,$0a,$07
            
