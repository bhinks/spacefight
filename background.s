.include "constants.inc"

.segment "CODE"
.import main
.export draw_background

.proc draw_background
  ; write a nametable
  LDA PPUSTATUS
  TXA
  STA PPUADDR
  LDA #$43
  STA PPUADDR
  LDA #$2f
  STA PPUDATA

  LDA PPUSTATUS
  TXA
  ADC #$01
  STA PPUADDR
  LDA #$59
  STA PPUADDR
  LDA #$2f
  STA PPUDATA

  LDA PPUSTATUS
  TXA
  ADC #$01
  STA PPUADDR
  LDA #$a5
  STA PPUADDR
  LDA #$2f
  STA PPUDATA

  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$15
  STA PPUADDR
  LDA #$2e
  STA PPUDATA

  LDA PPUSTATUS
  LDA #$29
  STA PPUADDR
  LDA #$7d
  STA PPUADDR
  LDA #$2e
  STA PPUDATA

  ; write attribute table
  LDA PPUSTATUS
  TXA
  ADC #$03
  STA PPUADDR
  LDA #$c0
  STA PPUADDR
  LDA #%01000000
  STA PPUDATA
  LDA PPUSTATUS
  RTS
.endproc