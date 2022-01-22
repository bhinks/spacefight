.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, buttons

.segment "CODE"
.import main
.export draw_player
.export update_player

.proc draw_player
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
  ; write player ship tile numbers
  LDA #$05
  STA $0201
  LDA #$06
  STA $0205
  LDA #$07
  STA $0209
  LDA #$08
  STA $020d
  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e
  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203
  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207
  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b
  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc update_player
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
  ; read all d-pad inputs to allow for diagonal movement
  up_pressed:
    LDA buttons
    AND #%00001000
    CMP #%00001000
    BNE down_pressed
    JSR move_up
  down_pressed:
    LDA buttons
    AND #%00000100
    CMP #%00000100
    BNE left_pressed
    JSR move_down
  left_pressed:
    LDA buttons
    AND #%00000010
    CMP #%00000010
    BNE right_pressed
    JSR move_left
  right_pressed:
    LDA buttons
    AND #%00000001
    CMP #%00000001
    BNE edge_check
    JSR move_right
  ; check if player is running into any edges and push back in the opposing direction
  edge_check:
    LDA player_x
    CMP #$e0
    BCS stop_player_right
    CMP #$10
    BCC stop_player_left
    BEQ stop_player_left
    LDA player_y
    CMP #$d0
    BCS stop_player_down
    CMP #$10
    BCC stop_player_up
    JMP exit_subroutine

    stop_player_down:
      JSR move_up
      JMP exit_subroutine
    stop_player_left:
      JSR move_right
      JMP exit_subroutine
    stop_player_right:
      JSR move_left
      JMP exit_subroutine
    stop_player_up:
      JSR move_down
      JMP exit_subroutine

  exit_subroutine:
    ; all done, clean up and return
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc

.proc move_up
  DEC player_y
  DEC player_y
  RTS
.endproc

.proc move_down
  INC player_y
  INC player_y
  RTS
.endproc

.proc move_right
  INC player_x
  INC player_x
  RTS
.endproc

.proc move_left
  DEC player_x
  DEC player_x
  RTS
.endproc