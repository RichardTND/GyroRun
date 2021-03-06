;=======================================
;               GYRO-RUN
;       Written by Richard Bayliss
;        
;       (C) 2021 The New Dimension
;=======================================

;General pointers
pictureshowed !byte 0
system  !byte 0
ntsctimer !byte 0
rt      !byte 0
firebutton !byte 0
animdelay !byte 0
animpointer !byte 0
dirdelay !byte 0
dirpointer !byte 0
directionstore !byte 0
;Player pointers 
playerwaittime !byte 0
playerreleased !byte 0
playerdirset !byte 0
playerismoving !byte 0
playerspeed !byte 0
playerspeedskill !byte 1
playeranimtype !byte $c0
;Player death pointers
playerisdead !byte 0
playerdeathdelay !byte 0
playerdeathpointer !byte 0
shielddelay !byte 0
shieldpointer !byte 0
shieldtimer !byte 200
shielddifficulty !byte 100
explodepointer !byte 0
explodedelay !byte 0
;Amount of lives for the player
lives !byte 0

;Scroller
voiddelay !byte 0
uptemp !byte 0
downtemp !byte 0
lefttemp !byte 0
righttemp !byte 0

leveltimer !byte 0,0
;Randomizer
sweetplotcounter !byte 0
spawnsweettimer !byte 0
randomobjecttospawn !byte 0
spawntimeexpiry !byte 120
rtemp !byte $5c
rand !byte %10010101,%01001011

;Sprite pointers 
objpos !byte 0,0,0,0,0,0,0,0
       !byte 0,0,0,0,0,0,0,0

;Collider pointers
collision !byte 0,0,0,0

;Sprite animation pointers

animtable   !byte $c0,$c1,$c2,$c3,$c0,$c1,$c2,$c3

;Player sprite death animation pointers
playerdeathframe !byte $d0,$d1,$d2,$d3,$d4,$d5,$d6,$d7
playerdeathframeend !byte $d7

;Get Ready and Game Over Sprite Table
getreadytable !byte $c4,$c5,$c6,$c7,$c5,$c8,$c9,$ca
gameovertable !byte $c4,$c8,$cb,$c5,$cc,$cd,$c5,$c7


;Directional pointers
playerdir   !byte $00,$01,$02,$03,$04,$05,$06,$07

;Sprite position for GET READY and game over
getreadypos
            !byte $46,$78,$56,$78,$66,$78,$36,$98
            !byte $46,$98,$56,$98,$66,$98,$76,$98
            
gameoverpos
            !byte $3e,$78,$4e,$78,$5e,$78,$6e,$78
            !byte $3e,$98,$4e,$98,$5e,$98,$6e,$98  
            
shieldcolourtable
            !byte $02,$08,$0a,$07,$01,$07,$0a,$08
            
;Smart bomb explosion colour table

explodecolourtable
              !byte $09,$02,$0a,$07,$01,$01,$07,$0a,$02,$09,$00

;Object table that has to spawn to screen

obj_top_left_table 
            !byte sweet_top_left, sweet2_top_left, sweet3_top_left, skull_top_left
            !byte sweet2_top_left, sweet_top_left,sweet3_top_left, skull_top_left 
obj_top_right_table 
            !byte sweet_top_right, sweet2_top_right, sweet3_top_right, skull_top_right
            !byte sweet2_top_right, sweet_top_right, sweet3_top_right, skull_top_right 
obj_bottom_left_table 
            !byte sweet_bottom_left, sweet2_bottom_left, sweet3_bottom_left, skull_bottom_left 
            !byte sweet2_bottom_left, sweet_bottom_left, sweet3_bottom_left, skull_bottom_left
obj_bottom_right_table 
            !byte sweet_bottom_right, sweet2_bottom_right, sweet3_bottom_right, skull_bottom_right 
            !byte sweet2_bottom_right, sweet_bottom_right, sweet3_bottom_right, skull_bottom_right
            

;Player score
score       !byte $30,$30,$30,$30,$30,$30

;Possible screen low/hi!byte table for randomizer to develop 
;new

!align $ff,0

char_read_lo 
 !byte $a4,$a6,$a8,$aa,$ac,$ae,$b0,$b2,$b4,$b6,$b8,$ba,$bc,$be,$c0,$c2
 !byte $f4,$f6,$f8,$fa,$fc,$fe,$00,$02,$04,$06,$08,$0a,$0c,$0e,$10,$12
 !byte $44,$46,$48,$4a,$4c,$4e,$50,$52,$54,$56,$58,$5a,$5c,$5e,$60,$62
 !byte $94,$96,$98,$9a,$9c,$9e,$a0,$a2,$a4,$a6,$a8,$aa,$ac,$ae,$b0,$b2
 !byte $e4,$e6,$e8,$ea,$ec,$ee,$f0,$f2,$f4,$f6,$f8,$fa,$fc,$fe,$00,$02
 !byte $34,$36,$38,$3a,$3c,$3e,$40,$42,$44,$46,$48,$4a,$4c,$4e,$50,$52
 !byte $84,$86,$88,$8a,$8c,$8e,$90,$92,$94,$96,$98,$9a,$9c,$9e,$a0,$a2
 !byte $d4,$d6,$d8,$da,$dc,$de,$e0,$e2,$e4,$e6,$e8,$ea,$ec,$ee,$f0,$f2
 !byte $a4,$a6,$a8,$aa,$ac,$ae,$b0,$b2,$b4,$b6,$b8,$ba,$bc,$be,$c0,$c2
 !byte $f4,$f6,$f8,$fa,$fc,$fe,$00,$02,$04,$06,$08,$0a,$0c,$0e,$10,$12
 !byte $44,$46,$48,$4a,$4c,$4e,$50,$52,$54,$56,$58,$5a,$5c,$5e,$60,$62
 !byte $94,$96,$98,$9a,$9c,$9e,$a0,$a2,$a4,$a6,$a8,$aa,$ac,$ae,$b0,$b2
 !byte $e4,$e6,$e8,$ea,$ec,$ee,$f0,$f2,$f4,$f6,$f8,$fa,$fc,$fe,$00,$02
 !byte $34,$36,$38,$3a,$3c,$3e,$40,$42,$44,$46,$48,$4a,$4c,$4e,$50,$52
 !byte $84,$86,$88,$8a,$8c,$8e,$90,$92,$94,$96,$98,$9a,$9c,$9e,$a0,$a2
 !byte $d4,$d6,$d8,$da,$dc,$de,$e0,$e2,$e4,$e6,$e8,$ea,$ec,$ee,$f0,$f2
 !byte 0
char_read_lo_end



char_read_hi 
 !byte $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04
 !byte $04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 !byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 !byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 !byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$06,$06
 !byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 !byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 !byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 !byte $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04
 !byte $04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 !byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 !byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 !byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$06,$06
 !byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 !byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 !byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06

 !byte 0
char_read_hi_end


char_read_lo_2
 !byte $cc,$ce,$d0,$d2,$d4,$d6,$d8,$da,$dc,$de,$e0,$e2,$e4,$e6,$e8,$ea
 !byte $1c,$1e,$20,$22,$24,$26,$28,$2a,$2c,$2e,$30,$32,$34,$36,$38,$3a
 !byte $6c,$6e,$70,$72,$74,$76,$78,$7a,$7c,$7e,$80,$82,$84,$86,$88,$8a
 !byte $bc,$be,$c0,$c2,$c4,$c6,$c8,$ca,$cc,$ce,$d0,$d2,$d4,$d6,$d8,$da
 !byte $0c,$0e,$10,$12,$14,$16,$18,$1a,$1c,$1e,$20,$22,$24,$26,$28,$2a
 !byte $5c,$5e,$60,$62,$64,$66,$68,$6a,$6c,$6e,$70,$72,$74,$76,$78,$7a
 !byte $ac,$ae,$b0,$b2,$b4,$b6,$b8,$ba,$bc,$be,$c0,$c2,$c4,$c6,$c8,$ca
 !byte $fc,$fe,$00,$02,$04,$06,$08,$0a,$0c,$0e,$10,$12,$14,$16,$18,$1a 
 !byte $cc,$ce,$d0,$d2,$d4,$d6,$d8,$da,$dc,$de,$e0,$e2,$e4,$e6,$e8,$ea
 !byte $1c,$1e,$20,$22,$24,$26,$28,$2a,$2c,$2e,$30,$32,$34,$36,$38,$3a
 !byte $6c,$6e,$70,$72,$74,$76,$78,$7a,$7c,$7e,$80,$82,$84,$86,$88,$8a
 !byte $bc,$be,$c0,$c2,$c4,$c6,$c8,$ca,$cc,$ce,$d0,$d2,$d4,$d6,$d8,$da
 !byte $0c,$0e,$10,$12,$14,$16,$18,$1a,$1c,$1e,$20,$22,$24,$26,$28,$2a
 !byte $5c,$5e,$60,$62,$64,$66,$68,$6a,$6c,$6e,$70,$72,$74,$76,$78,$7a
 !byte $ac,$ae,$b0,$b2,$b4,$b6,$b8,$ba,$bc,$be,$c0,$c2,$c4,$c6,$c8,$ca
 !byte $fc,$fe,$00,$02,$04,$06,$08,$0a,$0c,$0e,$10,$12,$14,$16,$18,$1a 

 !byte 0
char_read_lo_2_end


char_read_hi_2
 !byte $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04
 !byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 !byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 !byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 !byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 !byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 !byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 !byte $06,$06,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
 !byte $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04
 !byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 !byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 !byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 !byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 !byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 !byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 !byte $06,$06,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07

 !byte 0 
 
char_read_hi_2_end 

;Collision char read tables for low and hi-!byte 
;(Reads entire set of character rows)

screenhi        !byte $04,$04,$04,$04,$04
                !byte $04,$04,$05,$05,$05
                !byte $05,$05,$05,$06,$06
                !byte $06,$06,$06,$06,$06
                !byte $07,$07,$07,$07,$07,$07


                
screenlo        !byte $00,$28,$50,$78,$a0
                !byte $c8,$f0,$18,$40,$68
                !byte $90,$b8,$e0,$08,$30
                !byte $58,$80,$a8,$d0,$f8 
                !byte $20,$48,$70,$98,$c0,$e0
                
