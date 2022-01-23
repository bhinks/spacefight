.include "constants.inc"

.segment "ZEROPAGE"
.importzp explosion_x, explosion_y, explosion_frames, dead, enemy_died

.segment "CODE"
.import main
.export explode

.proc explode
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
  
  LDA #$0a
  STA $0231
  STA $0235
  STA $0239
  STA $023d
  ; write explosion tile attributes
  ; use palette 1 and flip as needed
  LDA #%00000001
  STA $0232
  LDA #%01000001
  STA $0236
  LDA #%10000001
  STA $023a
  LDA #%11000001
  STA $023e
  ; store tile locations
  ; top left tile:
  LDA explosion_y
  STA $0230
  LDA explosion_x
  STA $0233
  ; top right tile (x + 8):
  LDA explosion_y
  STA $0234
  LDA explosion_x
  CLC
  ADC #$08
  STA $0237
  ; bottom left tile (y + 8):
  LDA explosion_y
  CLC
  ADC #$08
  STA $0238
  LDA explosion_x
  STA $023b
  ; bottom right tile (x + 8, y + 8)
  LDA explosion_y
  CLC
  ADC #$08
  STA $023c
  LDA explosion_x
  CLC
  ADC #$08
  STA $023f

  ; play explosion sound on noise channel
  LDA #%00111111 ; Volume F (maximum)
  STA $400c

  LDA #$AA   ; 0C9 is a C# in NTSC mode
  STA $400e
  LDA #$00
  STA $400f

  ; check explosion frame count and advance to the next set of tiles when appropriate
  LDA explosion_frames
  CMP #10
  BCS frame_2
  JMP continue
  frame_2:
  LDA #$0b
  STA $0231
  STA $0235
  STA $0239
  STA $023d
  LDA explosion_frames
  CMP #30
  BCS frame_3
  JMP continue
  frame_3:
  LDA #$0c
  STA $0231
  STA $0235
  STA $0239
  STA $023d
  LDA explosion_frames
  CMP #40
  BCS frame_4
  JMP continue
  frame_4:
  LDA #$0d
  STA $0231
  STA $0235
  STA $0239
  STA $023d
  LDA explosion_frames
  CMP #60
  BCS frame_5
  JMP continue
  frame_5:
  LDA #$00
  STA $0231
  STA $0235
  STA $0239
  STA $023d

  continue:
    LDA #60
    CMP explosion_frames
    BNE advance_frame
    LDA #$00
    STA dead
    STA enemy_died
    STA explosion_frames
    LDA #%00110000 ; Drop volume to 0
    STA $400c

    LDA #$00
    STA $400e
    LDA #$00
    STA $400f
    JMP end
  advance_frame:
    INC explosion_frames
  end:
  ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc
