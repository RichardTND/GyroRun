;=======================================
;               GYRO-RUN
;       Written by Richard Bayliss
;        
;       (C) 2021 The New Dimension
;=======================================

;Music variables
musicinit = $8000 ;Initalise music player address
musicplay = $8003 ;Main music player address
sfxplay = $8006

;Screen pointer variables

screen = $0400 ;Default screen ram memory we are storing screen chars to 
colour = $d800 ;Colour ram which we are storing colour data to
bmpcol = $5800 ;Colour data which the logo is locaated
piccolram = $c800 ;Colour data which the LOADING PICTURE colour RAM is based
swingscreenstore = $c000
swingbase = 78

;Charset coded variables

_eorcode = 128  ;Where the text charset has been assigned
indicator_sprite_no = $d8 ;Where the spinning icon has been assigned


;Char ID's for specific sprite/char collision objects

void = 18           ;No collision - 

sweet_top_left = 47 ;char ID that represents sweet chars (2x2)
sweet_top_right = 48 
sweet_bottom_left = 49
sweet_bottom_right = 50

sweet2_top_left = 51 ;sweet 2 char ID which should give more points once spawned
sweet2_top_right = 52
sweet2_bottom_left = 53
sweet2_bottom_right = 54

sweet3_top_left = 55 ;sweet 3 char ID 
sweet3_top_right = 56
sweet3_bottom_left = 57
sweet3_bottom_right = 58 

bomb_top_left = 59 ;Char ID for screen clear bombs
bomb_top_right = 60
bomb_bottom_left = 61
bomb_bottom_right = 62


skull_top_left = 63;Deadly object which the player should avoid 
skull_top_right = 64
skull_bottom_left = 65
skull_bottom_right = 66

heart = 165 ; Lives indicator

gamecharmemory = $2000

;Player stop position 

player_up_stop_position = $50
player_down_stop_position = $be
player_left_stop_position = $1c
player_right_stop_position = $90

;Collision pointers 
zp = $71


;Hi score variables

scorelen = 6
listlen = 10
namelen = 9
storbyt = $02

hitemp1 = $05
hitemp2 = $06
hitemp3 = $07
hitemp4 = $08
nmtemp1 = $09
nmtemp2 = $0a
nmtemp3 = $0b
nmtemp4 = $0c

;Titlescreen vars

charmem = $2400 ;Memory to reach the charset
space = 202     ;Custom space char for the scroll       
charprint = 201 ;Custom print char for the scroll    
scrollspeed = 4 ;Speed of 8x8 scroll
swingstore   = $ee  

;Sprite pointers
levelspriteleft = $e0
levelspriteright = $e1
level1sprite = $e2
level2sprite = $e3
level3sprite = $e4
level4sprite = $e5 
level5sprite = $e6
level6sprite = $e7
level7sprite = $e8
level8sprite = $e9