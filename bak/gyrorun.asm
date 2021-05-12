TGT_C64
;=======================================
;               GYRO-RUN
;       Written by Richard Bayliss
;         (CBMPRG Studio Source)
;       (C) 2021 The New Dimension
;=======================================


;Insert variables

        incasm "vars.asm"

; 10 SYS16384:REM (c) 2021 tnd games
*=$0801
        BYTE    $21, $08, $0A, $00, $9E, $31, $36, $33, $38, $34, $3a, $8f, $20, $28, $43, $29, $20, $32, $30, $32, $31, $20, $54, $4E, $44, $20, $47, $41, $4D, $45, $53, $00, $00, $00

;Insert game music file
*=$1000
        incbin "c64\music.prg",2,0

;Insert game character set
*=$2000
        incbin "c64\charset.bin"
;Insert game colour data
*=$2800
attribs
        incbin "c64\gameattribs.bin"
;Insert game level map (This is where the game
;levels will decompress to via Exomizer decrunch src)
*=$2c00
map
        incbin "c64\level0.bin"

;Insert game sprites
*=$3000
        incbin "c64\gamesprites.bin"

;Insert main game code
*=$4000
        
        incasm "gamecode.asm"

;Insert the title screen logo bitmap (Vidcom paint Format)
*=$5800
        incbin "c64\logo.prg",2,0

*=$8000
;Title screen code
        incasm "titlescreen.asm"
        
