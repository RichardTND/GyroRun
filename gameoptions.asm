gameoptions   
      
        lda #0
        sta firebutton
        sta joydelay
        
        jsr playoksfx
      
        ldx #$00
clearsarea
        lda #$a0
        sta screen+360,x
        sta screen+$200,x
        sta screen+$2e8,x
        lda #$0f
        sta colour+360,x 
        sta colour+$200,x
        sta colour+$2e8,x
        inx
        bne clearsarea 
       
;-----------------------------------------
;Joystick controlled game option menu
;use this in scroll text area
;-----------------------------------------

          lda #$08
          sta xpos
          sta swingstore
          ldx #$00
setoptionmenu
          lda difficultymenu,x 
          eor #$80
          sta screen+480,x 
          lda difficultymenu+40,x
          eor #$80
          sta screen+520,x
          lda difficultymenu+80,x
          eor #$80
          sta screen+560,x
          lda difficultymenu+120,x
          eor #$80
          sta screen+600,x
          lda difficultymenu+160,x
          eor #$80
          sta screen+640,x
          lda difficultymenu+200,x
          eor #$80
          sta screen+680,x
          lda difficultymenu+240,x
          eor #$80
          sta screen+720,x 
          lda difficultymenu+280,x
          eor #$80
          sta screen+760,x 
          inx
          cpx #$28
          bne setoptionmenu
          lda #0
          sta firebutton
;--------------------------------------------------
; Main option selector loop
;--------------------------------------------------
optionsloop
          lda #0
          sta rt
          cmp rt
          beq *-3
          jsr optionjoyread
          jsr checkoption
          jsr checkoptionposition
          lda $dc00
          lsr
          lsr
          lsr
          lsr
          lsr
          bit firebutton
          ror firebutton
          bmi optionsloop2
          bvc optionsloop2
         
          jmp exitoption
optionsloop2
          lda $dc01
          lsr
          lsr
          lsr
          lsr
          lsr
          bit firebutton
          ror firebutton
          bmi optionsloop
          bvc optionsloop
         
          jmp gamestart
          
          
          jmp exitoption
          
;--------------------------------------------
; Controlled joystick read options
;--------------------------------------------          
          
optionjoyread
          
          lda joydelay
          cmp #5
          beq joycontrolop
          inc joydelay
          rts
joycontrolop 
          lda #0
          sta joydelay
          lda #$00
          sta opjoy+1
          jsr joyopcontrol
          lda #$01
          sta opjoy+1
          jsr joyopcontrol
          rts
          
joyopcontrol
        
opjoy
          lda $dc00
          lsr
          bcs opjoydown
          jsr playselectsfx
          jmp prevoption
opjoydown lsr
          bcs opfire
          jsr playselectsfx
          jmp nextoption
opfire    rts

nextoption
          jsr playselectsfx
          lda option
          cmp #3
          beq resetoptiontop
          inc option
          rts
resetoptiontop
          lda #0
          sta option
          rts
          
prevoption
          jsr playselectsfx
          lda option 
          beq resetoptionbottom
          dec option
          rts
resetoptionbottom
          lda #3
          sta option
          rts
          
;-----------------------------------
;Check option. The first is reading
;the flash colour table. Then record
;and check values of which option 
;should flash - also store to game
;pointer values
;-----------------------------------

checkoption
          jsr flashoption
          
          rts
          
flashoption
          lda optionflashdelay 
          cmp #3
          beq opflashok
          inc optionflashdelay
          rts
opflashok lda #$00
          sta optionflashdelay
          ldx optionflashpointer
          lda optionflashcolour,x
          sta optionflashstore
          inx
          cpx #8
          beq resetflasher
          inc optionflashpointer
          rts
resetflasher 
          ldx #0
          stx optionflashpointer
          rts
;-------------------------------------------------
; Check option highlighter selectefd          
;-------------------------------------------------          
checkoptionposition
          lda option
          beq _case1
          cmp #1
          beq _case2
          cmp #2
          beq _case3 
          cmp #3
          beq _case4
          rts
_case1     jmp setupmodeeasy
_case2     jmp setupmodemoderate
_case3     jmp setupmodehard
_case4     jmp setupmodeareyounuts

;Setup game mode, easy

setupmodeeasy
          ldx #<optcolour1
          ldy #>optcolour1
          stx osm1+1
          sty osm1+2
          ldx #<optcolour2 
          ldy #>optcolour2
          stx osm2+1
          sty osm2+2
          ldx #<optcolour3
          ldy #>optcolour3 
          stx osm3+1
          sty osm3+2
          ldx #<optcolour4 
          ldy #>optcolour4 
          stx osm4+1
          sty osm4+2
          lda #3
          sta startlives+1
          lda #2
          sta playerspeedskill
          jmp paintline
         
setupmodemoderate
          ldx #<optcolour2
          ldy #>optcolour2
          stx osm1+1
          sty osm1+2
          ldx #<optcolour1 
          ldy #>optcolour1
          stx osm2+1
          sty osm2+2
          ldx #<optcolour3
          ldy #>optcolour3 
          stx osm3+1
          sty osm3+2
          ldx #<optcolour4
          ldy #>optcolour4 
          stx osm4+1
          sty osm4+2
          lda #3
          sta startlives+1
          lda #1
          sta playerspeedskill
          jmp paintline 

setupmodehard 
          ldx #<optcolour3
          ldy #>optcolour3
          stx osm1+1
          sty osm1+2
          ldx #<optcolour1 
          ldy #>optcolour1
          stx osm2+1
          sty osm2+2
          ldx #<optcolour2
          ldy #>optcolour2 
          stx osm3+1
          sty osm3+2
          ldx #<optcolour4 
          ldy #>optcolour4 
          stx osm4+1
          sty osm4+2
          lda #3
          sta startlives+1
          lda #0
          sta playerspeedskill
          jmp paintline
          
setupmodeareyounuts          

          ldx #<optcolour4
          ldy #>optcolour4
          stx osm1+1
          sty osm1+2
          ldx #<optcolour1 
          ldy #>optcolour1
          stx osm2+1
          sty osm2+2
          ldx #<optcolour2
          ldy #>optcolour2 
          stx osm3+1
          sty osm3+2
          ldx #<optcolour3 
          ldy #>optcolour3
          stx osm4+1
          sty osm4+2
          lda #1
          sta startlives+1
          lda #0
          sta playerspeedskill
          jmp paintline
          
paintline
          ldx #$00
paintselected
          lda optionflashstore
osm1      sta colour+560,x
          lda #$07
osm2      sta colour+600,x
osm3      sta colour+640,x
osm4      sta colour+680,x
          inx 
          cpx #$28
          bne paintselected
          rts
;Test game option selected 

playselectsfx
          ldx #14
          lda #<sfx_select
          ldy #>sfx_select 
          jsr sfxplay
          rts

playoksfx
          ldx #7
          lda #<sfx_ready
          ldy #>sfx_ready
          jsr sfxplay
          rts 
exitoption
          jsr playoksfx 
         
          jmp gamestart
 
option             !byte 0
optionflashdelay   !byte 0
optionflashpointer !byte 0
optionflashstore   !byte 0
optionflashcolour  !byte $06,$04,$0a,$07,$01,$07,$0a,$04,$06

;Game option select sfx 

!ct scr          
difficultymenu 
               
!text "         game difficulty options        "
!text "                                        "
!text "      very easy    (3 lives, slow)      "
!text "      normal       (3 lives, medium)    "
!text "      crazy        (3 lives, fast)      "    
!text "      are you nuts (1 life, fast)       "
!text "                                        "
!text "joystick up/down to select, fire to exit"          

!align $ff,0


;In game sound effects pointers

sfx_pickup1     !byte $0E,$EE,$88,$B0,$41,$B0,$B4,$B4,$B7,$B7,$BC,$BC,$C0,$C0,$BC,$BC
                !byte $B7,$B7,$B4,$B4,$B0,$B0,$A0,$10,$00
                
sfx_pickup2     !byte $0E,$EE,$88,$B0,$41,$B0,$B2,$B4,$B6,$B8,$BA,$BA,$BC,$BC,$BE,$BE
                !byte $90,$11,$00                
                
sfx_pickup3     !byte $0E,$EE,$88,$B0,$41,$C0,$C2,$C4,$C6,$C8,$CA,$CA,$CC,$CC,$CE,$CE
                !byte $D0,$D1,$00       
                    
                                
sfx_bomb        !byte $0E,$EE,$88,$BC,$81,$BB,$BC,$BB,$BA,$BB,$BA,$BB,$BA,$B9,$BA,$B9
                !byte $B8,$B9,$B8,$B7,$B8,$B6,$B7,$B6,$B5,$B6,$B5,$B4,$B5,$B4,$B3,$B4
                !byte $B3,$B2,$B3,$B2,$B1,$B0,$90,$10,$00                
                
sfx_dead        !byte $0E,$EE,$88,$BC,$41,$BB,$BC,$BB,$BA,$BB,$BA,$BB,$BA,$B9,$BA,$B9
                !byte $B8,$B9,$B8,$B7,$B8,$B6,$B7,$B6,$B5,$B6,$B5,$B4,$B5,$B4,$B3,$B4
                !byte $B3,$B2,$B3,$B2,$B1,$B0,$90,$10,$00                

sfx_shift        
                !byte $0e,$ee,$00,$C0,$81,$C3,$C4,$CC,$C7,$CC,$00
                
sfx_levelup    !byte $0E,$EE,$88,$BC,$41,$c0,$bf,$be,$bd,$bc,$bb,$ba,$b9,$b8,$b7,$b6,$b5            
                !byte $b4,$b3,$b2,$b1,$b9
                !byte $c0,$bf,$be,$bd,$bc,$bb,$ba,$b9,$b8,$b7,$b6,$b5            
                !byte $b4,$b3,$b2,$b1,$b9
                !byte $c0,$bf,$be,$bd,$bc,$bb,$ba,$b9,$b8,$b7,$b6,$b5            
                !byte $b4,$b3,$b2,$b1,$b9
                !byte $c0,$bf,$be,$bd,$bc,$bb,$ba,$b9,$b8,$b7,$b6,$b5            
                !byte $b4,$b3,$b2,$b1,$b9,$90,$10,0
                

sfx_select
                !byte $0e,$ee,$88,$C0,$41,$CC,$00
sfx_ready
                !byte $0e,$ee,$88,$C0,$41,$B0,$B2,$B4,$B6,$B8,$BA,$BC,$BE,$10,0