;=======================================
;               GYRO-RUN
;       Written by Richard Bayliss
;         (CBMPRG Studio Source)
;       (C) 2021 The New Dimension
;=======================================

;General pointers

system  byte 0
ntsctimer byte 0
rt      byte 0
firebutton byte 0
animdelay byte 0
animpointer byte 0
dirdelay byte 0
dirpointer byte 0
directionstore byte 0
playertype byte $c0
;Player pointers 
playerreleased byte 0
playerdirset byte 0
playerismoving byte 0
playerspeed byte 0
playerspeedskill byte 1
rotatespeedskill byte 10

;Sprite pointers 
objpos byte 0,0,0,0,0,0,0,0
       byte 0,0,0,0,0,0,0,0

;Collider pointers
collision byte 0,0,0,0

;Sprite animation pointers
playerframe byte $c0,$c1,$c2,$c3,$c4,$c5,$c6,$c7
playerdir   byte $00,$01,$02,$03,$04,$05,$06,$07


