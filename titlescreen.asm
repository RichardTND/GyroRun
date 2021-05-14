;=======================================
;               GYRO-RUN
;       Written by Richard Bayliss
;         (CBMPRG Studio Source)
;       (C) 2021 The New Dimension
;=======================================

titlecode

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
        
        sta colour+800,x
        sta colour+840,x
        sta colour+880,x
        inx
        cpx #40
        bne redscheme

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
        sta screen+360,x
        lda textline2,x
        adc #_eorcode
        sta screen+440,x
        lda textline3,x
        adc #_eorcode
        sta screen+480,x
        lda textline4,x
        adc #_eorcode
        sta screen+520,x
        lda textline5,x
        adc #_eorcode
        sta screen+560,x
        lda textline6,x
        adc #_eorcode
        sta screen+600,x
       
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
       
        ldx #<titleirq2
        ldy #>titleirq2
        stx $0314
        sty $0315
        jmp $ea7e

titleirq2
        ;Bitmap logo

        inc $d019
        lda #$7a
        sta $d012
        lda #$02
        sta $dd00
        lda #$3b
        sta $d011
        lda #$18
        sta $d016
        lda #$78
        sta $d018
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
        lda #$08
        sta $d016
       
        ldx #<titleirq 
        ldy #>titleirq 
        stx $0314
        sty $0315
        jmp $ea7e

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
        jsr bigscroll

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
;Scroll hi score table
;-----------------------------------------

charmem = $2400 ;Memory to reach the charset
space = 202     ;Custom space char for the scroll       
charprint = 201 ;Custom print char for the scroll    
scrollspeed = 7 ;Speed of 8x8 scroll

xpos  !byte $07
data1 !byte 0,0,0,0,0,0,0,0 ;Plotting char data
data2 !byte 0,0,0,0,0,0,0,0 ;to form character
count !byte 8 ;Amount of bytes to read

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
        
;High score list
        !ct scr
textline1
        !text "       >>> todays best spinners <<<     "
textline2
        !text "       1. richard   ........ 010000     "
textline3
        !text "       2. hugues    ........ 007500     "
textline4
        !text "       3. arthur    ........ 005000     "
textline5
        !text "       4. tnd       ........ 002500     "
textline6          
        !text "       5. games     ........ 000000     "


;Title screen scroll text

scrolltext
        !text "    ... hello there and welcome to gyro-run ...   "
        !text "programming and font by richard bayliss ...   loading "
        !text "screen, front end logo and game graphics by hugues (ax!s)"
        !text " poisseroux ...   music and sound effects by richard bayliss ...   "
        !text "copyright (c) 2021 the new dimension ...   written for the csdb "
        !text "fun compo 2021 ...   how to play: control: joystick port 2 ...   "
        !text "use left/right in game to turn the dial at the bottom "
        !text "of the screen ...   then press fire to launch your "
        !text "spinner to that direction ...   warning: the spinner will move automatically if idle for some time ...   "
        !text "the object of the game is to pick up the sweets for points ...   "
        !text "each type of sweet will have a score value added once picked up by your spinner ...   "
        !text "pick up bombs to clear the game area you will get only 100 points awarded...   "
        !text "it is possible for the objects to transform into some other "
        !text "object ...   watch out for the deadly skulls or the spikes on the "
        !text "walls ...   if your spinner bumps into those, you will lose a life ...   "
        !text "there are 3 lives in total ...   the game is over as soon as "
        !text "all 3 lives have been lost ...   keep on scoring as many points "
        !text "as you possibly can, and try to make it onto the hi score table ...   "
        !text "good luck ...   presss fire or space to play ...                      "
        
        !byte 0 ;Reset scroll text marker
