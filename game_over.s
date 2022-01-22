.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, explosion_frames

.segment "CODE"
.import main
.export end_game

.proc end_game
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
  
  LDA #$00
  STA $0211
  STA $0215
  STA $0219
  STA $021d
  STA $0212
  STA $0216
  STA $021a
  STA $021e
  STA $0210
  STA $0213
  STA $0214
  STA $0217
  STA $0218
  STA $021b
  STA $021c
  STA $021f

  STA $0201
  STA $0205
  STA $0209
  STA $020d
  STA $0202
  STA $0206
  STA $020a
  STA $020e
  STA $0200
  STA $0203
  STA $0204
  STA $0207
  STA $0208
  STA $020b
  STA $020c
  STA $020f
  
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
