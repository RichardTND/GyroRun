;=======================================
;               GYRO-RUN
;       Written by Richard Bayliss
;         (CBMPRG Studio Source)
;       (C) 2021 The New Dimension
;=======================================

titlecode
TitleScreen
;Destroy all IRQ raster interrupts

        sei
       
        ldx #$31
        ldy #$ea
        lda #$81
        stx $0314
        sty $0315
        sta $dc0d
        sta $dd0d
        lda #$00
        sta $d01a
        sta $d019
        sta $d015
        sta $d011
        ldx #$00
silent  lda #$00
        sta $d400,x
        inx
        cpx #$18
        bne silent
        lda #252
        sta 808
        ldx #$00
wait001  ldy #$00
wait002  iny
        bne wait002
        inx
        bne wait001
;Display loading picture on screen
        
        ldx #$00
showloop 
        lda $c800,x
        sta $d800,x
        lda $c900,x
        sta $d900,x
        lda $ca00,x
        sta $da00,x
        lda $cae8,x
        sta $dae8,x
        inx
        bne showloop
     
        lda #0
        sta $d021
        sta $d020
        lda #$3b
        sta $d011
        lda #$00
        sta $dd00
        lda #$18
        sta $d016 
        sta $d018
        
        ldx #<gameirq
        ldy #>gameirq
        lda #$7f
        stx $0314
        sty $0315
        sta $dc0d
        
        lda #$36
        sta $d012
        lda #$01
        sta $d01a
        lda #4
        jsr musicinit
        cli
        
        lda #0
        sta firebutton
firewaitpic         
        lda $dc00
        lsr
        lsr
        lsr
        lsr
        lsr
        bit firebutton
        ror firebutton
        bmi firewaitpic2
        bvc firewaitpic2
        jmp skippic 
firewaitpic2
        lda $dc01 
        lsr
        lsr
        lsr
        lsr
        lsr
        bit firebutton
        ror firebutton
        bmi firewaitpic
        bvc firewaitpic

skippic
        lda #0
        sta firebutton

        sei
        ldx #$31
        ldy #$ea 
        lda #$81
        sta $0314
        stx $0315
        sta $dc0d
        sta $dd0d
        lda #$00
        sta $d019
        sta $d01a
        ldx #$00
nosidstart
        lda #$00
        sta $d400,x
        inx
        cpx #$18
        bne nosidstart
        lda #0
        sta swingpointer
        sta slowpaintdelay
        sta slowpaintpointer
        lda #1
        sta slowpaintstore
        
        
        
;Quick delay routine

        ldx #$00
wait01  ldy #$00
wait02  iny
        bne wait02
        inx
        bne wait01
        
        
        ;Silence sid chip

        ldx #$00
blanksid
        lda #$00
        sta $d400,x
        inx
        cpx #$18
        bne blanksid


;Clear screen

        ldx #$00
clearscreentitle
        lda #$20
        clc
        adc #_eorcode
        sta screen,x
        sta screen+$100,x
        sta screen+$200,x
        sta screen+$2e8,x
        sta swingscreenstore,x
        sta swingscreenstore+$100,x
        sta swingscreenstore+$200,x
       
        inx
        bne clearscreentitle

;Setup the title screen logo
;colour matrix

        ldx #$00
paintlogo
        lda bmpcol,x
        sta colour,x
        lda bmpcol+40,x
        sta colour+40,x
        lda bmpcol+80,x
        sta colour+80,x
        lda bmpcol+120,x
        sta colour+120,x
        lda bmpcol+160,x
        sta colour+160,x
        lda bmpcol+200,x
        sta colour+200,x
        lda bmpcol+240,x
        sta colour+240,x
        lda bmpcol+280,x
        sta colour+280,x
        lda bmpcol+320,x
        sta colour+320,x
        inx
        bne paintlogo

        ;Now fill text area screen grey 

        ldx #$00
fillgreytext
        lda #$01
        sta colour+360,x
        sta colour+$200,x
        sta colour+$2e8,x
        inx
        bne fillgreytext

        ;Fill big scroll colour area 
        ;with a red colour scheme 

        ldx #$00
redscheme
        lda #$00 ;Top+bottom shade brown
        sta colour+680,x
        lda #$04
        sta colour+720,x
        sta colour+960,x
        lda #$0a
        sta colour+760,x
        sta colour+920,x
        lda #$07 ;Rest - pink
        sta colour+880,x
        sta colour+800,x
        lda #$01
        sta colour+840,x
        
        inx
        cpx #40
        bne redscheme
        ldx #0
blackout
        lda #0
        sta colour+320,x
        inx
        cpx #40
        bne blackout
        ;Test (remove if ok)
        lda #$02
        sta $dd00

        lda #$78
        sta $d018
        sta $d016
        lda #0
        sta $d020
        sta $d021
        lda #$3b
        sta $d011
        
        ;Put text (credits) onto the screen (BANK #3)
        ldx #$00
puttext
        lda textline1,x
        clc
        adc #_eorcode
        sta swingscreenstore+(1*swingbase)+12,x
        lda #$a0
        sta swingscreenstore+(2*swingbase)+12,x
        lda textline2,x
        adc #_eorcode
        sta swingscreenstore+(3*swingbase)+12,x
        lda textline3,x
        adc #_eorcode
        sta swingscreenstore+(4*swingbase)+12,x
        lda textline4,x
        adc #_eorcode
        sta swingscreenstore+(5*swingbase)+12,x
        lda textline5,x
        adc #_eorcode
        sta swingscreenstore+(6*swingbase)+12,x
        lda textline6,x
        adc #_eorcode
        sta swingscreenstore+(7*swingbase)+12,x
       
        inx
        cpx #40
        bne puttext


        ;Initialise title screen scroll text

        lda #<scrolltext
        sta messread+1
        lda #>scrolltext
        sta messread+2
        lda #8
        sta count
        ldx #0
clrdata lda #0
        sta data1,x
        sta data2,x
        inx
        cpx #8
        bne clrdata

;-----------------------------------------
;Setup the IRQ raster interrupt for
;the title screen
;-----------------------------------------

        ldx #<titleirq
        ldy #>titleirq
        lda #$7f
        stx $0314
        sty $0315
        sta $dc0d
        lda #$2e
        sta $d012
        lda #$1b
        sta $d011
        lda #$01
        sta $d01a
        lda #0
        jsr musicinit
        cli
        jmp titleloop


;-----------------------------------------
;Main title screen loop
;-----------------------------------------
titleloop

        ;Synchronize timer with the IRQ
        ;raster interrupt - so that the
        ;routines are running at level 
        ;speed as the interriupts

        lda #0
        sta rt
        cmp rt
        beq *-3
        jsr swingtable
        jsr bigscroll
        jsr longcolourwash
        ;Wait for fire button to be 
        ;pressed and released before
        ;starting a new game 

        lda $dc00
        lsr
        lsr
        lsr
        lsr
        lsr
        bit firebutton
        ror firebutton
        bmi titleloop2
        bvc titleloop2
        jmp okstart
titleloop2        
        ;Check spacebar 
        lda $dc01
        lsr
        lsr
        lsr
        lsr
        lsr
        bit firebutton 
        ror firebutton 
        bmi titleloop
        bvc titleloop
        
okstart        
        lda #0
        sta firebutton
      
        jmp gamestart
        
;-----------------------------------------
;Swing hi score table - also add a fun 
;colour effect to the table
;-----------------------------------------

swingtable
        
        
        lda #$ff
        sec
        ldx swingpointer
        sbc sinus,x 
        lsr
        lsr
        lsr
        tax
        ldy #$00
screenloop  lda swingscreenstore,x
        sta screen+320,y
        lda swingscreenstore+(1*swingbase),x 
        sta screen+360,y
        lda swingscreenstore+(2*swingbase),x
        sta screen+400,y
        lda swingscreenstore+(3*swingbase),x
        sta screen+440,y 
        lda swingscreenstore+(4*swingbase),x
        sta screen+480,y
        lda swingscreenstore+(5*swingbase),x
        sta screen+520,y
        lda swingscreenstore+(6*swingbase),x
        sta screen+560,y
        lda swingscreenstore+(7*swingbase),x
        sta screen+600,y 
        inx
        iny
        cpy #$28
        bne screenloop
        ldx swingpointer
        lda sinus,x
        and #$07
        
        sta swingstore
        lda swingpointer
        clc
        adc #1
        sta swingpointer
        rts
   
        
        
;Scroll routine exit 

exitscroll
        rts

;-----------------------------------------
;Big 8x8 scrolling text 
;-----------------------------------------

bigscroll
        lda xpos
        sec
        sbc #scrollspeed
        and #7
        sta xpos
        bcs exitscroll

        ;Transdform char types into data

        ldx #$00
scrloop1 
        asl data1,x
        bcc scrloop2
        lda #charprint
        jmp scrloop3
scrloop2
        lda #space
scrloop3
        sta data2,x
        inx
        cpx #8
        bne scrloop1

        ;Scroll the 8 rows across the screen
        
        ldx #$00
scrloop4        
        lda screen+681,x
        sta screen+680,x
        lda screen+721,x
        sta screen+720,x
        lda screen+761,x
        sta screen+760,x
        lda screen+721,x
        sta screen+720,x
        lda screen+801,x
        sta screen+800,x
        lda screen+841,x
        sta screen+840,x
        lda screen+881,x
        sta screen+880,x
        lda screen+921,x
        sta screen+920,x
        lda screen+961,x
        sta screen+960,x
        inx
        cpx #39
        bne scrloop4
        
        ;Store each of the 8 bytes matrix
        ;to the very last column in each
        ;row

        lda data2
        sta screen+719
        lda data2+1
        sta screen+759
        lda data2+2
        sta screen+799
        lda data2+3
        sta screen+839
        lda data2+4
        sta screen+879
        lda data2+5
        sta screen+919
        lda data2+6
        sta screen+959
        lda data2+7
        sta screen+999
        dec count
        bne scrloop9
        lda #8
        sta count
        lda #>charmem 
        sta scrloop8+2
scrloop5

        ;Scroll text message wrap check. If
        ;@ detected, reset the scrolling 
        ;message position.

messread
        lda scrolltext
        cmp #$00
        bne scrloop6
        lda #<scrolltext
        sta messread+1
        lda #>scrolltext
        sta messread+2
        jmp messread

        ;Buid the new char data

scrloop6
        asl
        asl
        asl
        bcc scrloop7
        inc scrloop8+2
scrloop7
        sta scrloop8+1
        ldx #0
scrloop8
        lda charmem,x
        sta data1,x
        inx
        cpx #8
        bne scrloop8

        ;Self-mod moving to next character 
        ;in the scroller 
        inc messread+1
        bne scrloop9
        inc messread+2
scrloop9
        jmp exitscroll
;-----------------------------------------
;Main IRQ raster interrupts for the
;front end
;-----------------------------------------

titleirq
        ;Scroll text message 

        inc $d019
        lda $dc0d
        sta $dd0d
        lda #$22
        sta $d012
        lda #$03
        sta $dd00
        lda #$1b
        sta $d011
        lda xpos
        sta $d016 
        lda #$18
        sta $d018
      ;  lda #1
      ;  sta $d020
     
        ldx #<titleirq2
        ldy #>titleirq2
        stx $0314
        sty $0315
        jmp $ea7e

titleirq2
        ;Bitmap logo

        inc $d019
        lda #$78
        sta $d012
        lda #$02
        sta $dd00
        lda #$3b
        sta $d011
        lda #$18
        sta $d016
        lda #$78
        sta $d018
        
     ;   lda #2
     ;   sta $d020
       
        lda #1
        sta rt
        jsr musicplayer
        ldx #<titleirq3
        ldy #>titleirq3
        stx $0314
        sty $0315
        jmp $ea7e

titleirq3
        ;Static screen text display 

        inc $d019
        lda #$ba
        sta $d012
        lda #$03
        sta $dd00
        lda #$1b
        sta $d011
        lda #$18
        sta $d018
        lda swingstore
        sta $d016
    ;    lda #3
    ;    sta $d020
        ldx #<titleirq 
        ldy #>titleirq 
        stx $0314
        sty $0315
        jmp $ea7e
        

;----------------------------------------
; Long colour wash routine - paint the 
; text up screen in slow motion
;----------------------------------------        
longcolourwash
        lda slowpaintdelay 
        cmp #3
        beq slowpaintok 
        inc slowpaintdelay
        rts
slowpaintok
        lda #0
        sta slowpaintdelay
        ldx slowpaintpointer
        lda slowpainttable,x
        sta slowpaintstore
        inx
        cpx #80
        beq slowpaintreset
        inc slowpaintpointer
        jmp painttotable
        rts
slowpaintreset
        ldx #0
        stx slowpaintpointer
painttotable
        ldx #$27
shiftupcolour
        
        lda colour+400,x
        sta colour+360,x
        lda colour+440,x
        sta colour+400,x
        lda colour+480,x
        sta colour+440,x
        lda colour+520,x
        sta colour+480,x
        lda colour+560,x
        sta colour+520,x
        lda colour+600,x
        sta colour+560,x
        lda slowpaintstore
        sta colour+600,x
        dex
        bpl shiftupcolour
        rts
        
                
        
swingpointer !byte 0

slowpaintdelay   !byte 0
slowpaintpointer !byte 0
slowpaintstore   !byte 0

slowpainttable   
                 !byte $01,$01,$01,$01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$07,$0a,$04,$06
                 !byte $06,$04,$0a,$07,$01,$01,$01,$01

xpos  !byte $07
data1 !byte 0,0,0,0,0,0,0,0 ;Plotting char data
data2 !byte 0,0,0,0,0,0,0,0 ;to form character
count !byte 8 ;Amount of bytes to read
   
;High score list

!align $ff,0

        !ct scr
textline1
        !text "       >>> todays best spinners <<<     "
textline2
        !text "       1. "
hiscorestart        
name1 !text "richard   ........ "
hiscore1 !text "010000     "
textline3
        !text "       2. "
name2 !text "hugues    ........ "
hiscore2 !text "007500     "
textline4
        !text "       3. "
name3 !text "alf       ........ "
hiscore3     !text "005000     "
textline5
        !text "       4. "
name4 !text "tnd       ........ "
hiscore4     !text "002500     "

textline6          
        !text "       5. "
name5 !text "games     ........ "
hiscore5     !text "001000     "
hiscoreend

difficultymenu 
               !text "     please select game difficulty      "
!text "        1. normal                       "
!text "        2. a bit more difficult         "
!text "        3. are you totally nuts?        "
!align $ff,0

;Title screen scroll text

scrolltext
        !text "   >>> gyro run <<< ...   code, font, sound effects and music by richard "
        !text "bayliss ...   game graphics, sprites, logo, and loading bitmap "
        !text "by hugues (ax!s) poisseroux ... (c) 2021 the new dimension ...   special thanks goes to hugues poisseroux and alf yngve for testing and feedback ... " 
        !text "this is a high score attack party game ...   controls: joystick "
        !text "in either port or use keys ctrl, 2 or spacebar ...   "
        !text "use left/right to turn the arrow at the bottom of the screen and "
        !text "press fire to activate movement ...   random objects will appear "
        !text "on screen ...   guide your spinner around the arena picking up tasty treats ...   "
        !text "these objects will not only give you points, but also a temporary shield that "
        !text "will protect you from the skulls ...   avoid the skulls, otherwise a life "
        !text "will be lost ...   it is possible that different objects will spawn "
        !text "onto the same position as another object, or where your spinner is "
        !text "positioned ...   from time to time, an alarm will sound, which "
        !text "will release a bomb ...   pick that up to clear the screen ...   "
        !text "also beware, the alarm also indicates 'level up' and will spawn "
        !text "random objects more rapidly ...   keep on collecting those "
        !text "treats for protection and points and try to make it onto the hi score table ...   "
        !text "press spacebar or fire to play, and also have fun ...                "
        !text "                        "
        !byte 0
        
;Swing sinus 
        
!align $100,0        
sinus !byte 60,57,55,52,50,47
      !byte 45,42,40,38,36,34
      !byte 31,29,27,26,24,22
      !byte 20,19,17,15,14,13
      !byte 11,10,9,8,7,6
      !byte 5,4,3,3,2,1
      !byte 1,1,0,0,0,0
      !byte 0,0,0,1,1,1
      !byte 2,2,3,4,4,5
      !byte 6,7,8,9,11,12
      !byte 13,15,16,18,19,21
      !byte 23,25,27,28,30,33
      !byte 35,37,39,41,44,46
      !byte 48,51,53,56,59,61
      !byte 64,67,69,72,75,78
      !byte 81,84,87,90,93,96
      !byte 99,102,105,108,111,114
      !byte 117,120,124,127,130,133
      !byte 136,139,142,145,149,152
      !byte 155,158,161,164,167,170
      !byte 173,176,178,181,184,187
      !byte 190,192,195,198,200,203
      !byte 205,208,210,213,215,217
      !byte 219,221,224,226,228,229
      !byte 231,233,235,236,238,240
      !byte 241,242,244,245,246,247
      !byte 248,249,250,251,252,252
      !byte 253,254,254,254,255,255
      !byte 255,255,255,255,255,254
      !byte 254,254,253,253,252,251
      !byte 251,250,249,248,247,246
      !byte 244,243,242,240,239,237
      !byte 236,234,232,230,228,227
      !byte 225,222,220,218,216,214
      !byte 211,209,207,204,202,199
      !byte 196,194,191,188,186,183
      !byte 180,177,174,171,168,165
      !byte 162,159,156,153,150,147
      !byte 144,141,138,135,131,128
      !byte 125,122,119,116,113,110
      !byte 106,103,100,97,94,91
      !byte 88,85,82,79,77,74
      !byte 71,68,65,63