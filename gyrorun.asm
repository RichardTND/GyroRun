;=======================================
;               GYRO-RUN
;       Written by Richard Bayliss
;       (C) 2021 The New Dimension
;=======================================


;Insert variables

        !source "vars.asm"
*=$0801
        !basic 16384

*=$1000
;Title screen code
        !source "titlescreen.asm"

        !source "diskaccess.asm"
;Insert game character set
*=$2000
        !binary "c64\gamechars.bin"
;Insert game colour data
*=$2800
attribs
        !binary "c64\gameattribs.bin"
;Insert game level map (This is where the game
;levels will decompress to via Exomizer decrunch src)
*=$2c00
map
        !binary "c64\gamescreen.bin"

;Insert game sprites
*=$3000
        !binary "c64\gamesprites.bin"

;Insert main game code
*=$4000
        
        !source "gamecode.asm"
 
;Insert the title screen logo bitmap (Vidcom paint Format)
*=$5800
        !binary "c64\logo.prg",,2
        

*=$8000
;Music
        !binary "c64\music.prg",,2
        
*=$c400
        !binary "c64\gyrovidram.prg",,2
*=$c800
        !binary "c64\gyrocolram.prg",,2
*=$e000
        !binary "c64\gyrobitmap.prg",,2
        
        
