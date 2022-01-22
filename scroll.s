.include "constants.inc"

.segment "ZEROPAGE"
.importzp ppuctrl_settings, scroll

.segment "CODE"
.import main
.export scroll_background

.proc scroll_background
  LDA scroll
  CMP #$00 ; did we scroll to the end of a nametable?
  BNE set_scroll_positions
  ; if yes, update base nametable
  LDA ppuctrl_settings
  EOR #%00000010 ; flip bit #1 to its opposite
  STA ppuctrl_settings
  STA PPUCTRL
  LDA #240
  STA scroll

  set_scroll_positions:
    LDA #$00 ; X scroll first
    STA PPUSCROLL
    DEC scroll
    LDA scroll ; then Y scroll
    STA PPUSCROLL
    RTS
.endproc