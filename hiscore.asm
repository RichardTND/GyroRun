;=======================================
;               GYRO-RUN
;       Written by Richard Bayliss
;        
;       (C) 2021 The New Dimension
;=======================================

;Hi score variables

scorelen = 6
listlen = 10
namelen = 9
storbyt = $02

hitemp1 = $c1
hitemp2 = $c2
hitemp3 = $c3
hitemp4 = $c4
nmtemp1 = $d1
nmtemp2 = $d2
nmtemp3 = $d3
nmtemp4 = $d4
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
         
         ;Grab player's score and put
;into zeropages 

     ldx #$00
nextone  lda hslo,x
     sta hitemp1 
     lda hshi,x
     sta hitemp2 
     
;Check hiscores

     ldy #$00
scoreget lda finalscore,y 
scorecmp cmp (hitemp1),y 
     bcc posdown 
     beq nextdigit 
     bcs posfound
nextdigit    
     iny
     cpy #scorelen 
     bne scoreget 
     beq posfound 
posdown  inx 
     cpx #listlen
     bne nextone 
     beq nohiscor
posfound stx storbyt
     cpx #listlen-1
     beq lastscor 
     
;Move hiscores and ranks down 

    ldx #listlen-1 
copynext 
    lda hslo,x
    sta hitemp1 
    lda hshi,x 
    sta hitemp2 
    lda nmlo,x
    sta nmtemp1 
    lda nmhi,x 
    sta nmtemp2 
    dex
    lda hslo,x
    sta hitemp3 
    lda hshi,x 
    sta hitemp4 
    lda nmlo,x
    sta nmtemp3 
    lda nmhi,x
    sta nmtemp4 
    
    ldy #scorelen-1
copyscor
    lda (hitemp3),y 
    sta (hitemp1),y 
    dey 
    bpl copyscor 
    
    ldy #namelen+1
copyname 
    lda (nmtemp3),y 
    sta (nmtemp1),y 
    dey 
    bpl copyname 
    cpx storbyt 
    bne copynext 
    
lastscor 
    ldx storbyt 
    lda hslo,x
    sta hitemp1 
    lda hshi,x
    sta hitemp2 
    lda nmlo,x
    sta nmtemp1 
    lda nmhi,x
    sta nmtemp2 
    
    jmp nameentry 
    
placenewscore
    ldy #scorelen-1 
putscore
    lda finalscore,y 
    sta (hitemp1),y 
    dey 
    bpl putscore 
    ldy #namelen-1 
putname lda name,y 
    sta (nmtemp1),y 
    dey 
    bpl putname 
    jsr mainsave
nohiscor    
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
            jmp placenewscore
            
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
            

;Hi score table pointers

hslo !byte <hiscore1, <hiscore2, <hiscore3, <hiscore4, <hiscore5
hshi !byte >hiscore1, >hiscore2, >hiscore3, >hiscore4, >hiscore5
nmlo !byte <name1, <name2, <name3, <name4, <name5 
nmhi !byte >name1, >name2, >name3, >name4, >name5