.include "constants.inc"

.segment "CODE"
.import main
.export reset_handler

.proc reset_handler
  SEI
  CLD
  LDX #$00
  STX PPUCTRL
  STX PPUMASK

  ; enable APU channels and configure square channel
  LDA #$0F
  STA APUFLAGS   ; enable Square 1, Square 2, Triangle and Noise channels.  Disable DMC.

  LDA #$ff
  clear_oam:
    STA $0200,X ; set sprite y-positions off-screen
    INX
    INX
    INX
    INX
    BNE clear_oam

  vblankwait:
    BIT PPUSTATUS
    BPL vblankwait
    JMP main
.endproc