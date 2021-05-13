;=======================================
;               GYRO-RUN
;       Written by Richard Bayliss
;        
;       (C) 2021 The New Dimension
;=======================================

;Music variables
musicinit = $1000 ;Initalise music player address
musicplay = $1003 ;Main music player address

;Screen pointer variables

screen = $0400 ;Default screen ram memory we are storing screen chars to 
colour = $d800 ;Colour ram which we are storing colour data to
bmpcol = $5800 ;Colour data which the VIDCOM PAINT logo is  locaated

;Charset coded variables

_eorcode = 128  ;Where the text charset has been assigned
indicator_sprite_no = $d8 ;Where the spinning icon has been assigned


;Char ID's for specific sprite/char collision objects

void = 18           ;No collision - 

jewel_top_left = 50 ;char ID that represents jewel chars (2x2)
jewel_top_right = 51 
jewel_bottom_left = 52
jewel_bottom_right = 53

jewel2_top_left = 46 ;Jewel 2 char ID which should give more points once spawned
jewel2_top_right = 47
jewel2_bottom_left = 48
jewel2_bottom_right = 49

skull_top_left = 66 ;Deadly object which the player should avoid 
skull_top_right = 67
skull_bottom_left = 68
skull_bottom_right = 69

heart = 165 ; Lives indicator

gamecharmemory = $2000



;Spikes chars
spikes1 = 38
spikes2 = 39
spikes3 = 54
spikes4 = 55
spikes5 = 56
spikes6 = 57
spikes7 = 58
spikes8 = 59
spikes9 = 60
spikes10 = 61
spikes11 = 62
spikes12 = 63 
spikes14 = 64
spikes15 = 65


;Collision pointers 
zp = $02