.include "constants.inc"

.segment "ZEROPAGE"
.importzp buttons, shot_count, enemy_x, enemy_y, enemy_died, enemy_count
.importzp explosion_x, explosion_y, explosion_frames
.importzp player_x, player_y, shot1_x
.importzp shot1_y, shot2_x, shot2_y, shot3_x, shot3_y, shot4_x, shot4_y


.segment "CODE"
.import main
.export fire_shot
.export draw_shots
.export update_shots
.export kill_test

.proc fire_shot
  b_pressed:
    LDA buttons
    AND #%01000000
    CMP #%01000000
    BNE skip
  LDA shot_count
  check_zero:
    CMP #$00
    BNE skip
    LDA player_x
    ADC #$03
    STA shot1_x
    LDX player_y
    STX shot1_y
    INC shot_count
  skip:
    RTS
.endproc

.proc draw_shots
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
  ; write empty tile for bullet until one if fired
  LDA #$00
  STA $0221
 
  ; write bullet tile attributes
  ; use palette 3
  LDA #%00000011
  STA $0222

  ; check current shot count
  ; only one shot is allowed on the screen at a time currently
  LDY #$09
  LDA shot_count
  check_one:
    CMP #$01
    BNE skip
    STY $0221
    LDA shot1_y
    STA $0220
    LDA shot1_x
    STA $0223
  
  skip:

  ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc update_shots
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  DEC shot1_y
  DEC shot1_y
  DEC shot1_y
  DEC shot1_y

  ; check if bullet has hit the top of the screen
  edge_check:
    LDA shot1_y
    CMP #$10
    BCC stop_shot_up
    JMP exit_subroutine

  stop_shot_up:
    LDA #$00
    STA $0220
    STA $0221
    STA $0222
    STA $0223
    STA shot_count

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

.proc kill_test
  LDA shot_count
  CMP #$00
  BEQ end
  ; check for shot collision with enemy
  test_x:
    LDA shot1_x
    SBC enemy_x
    CMP #$0f
    BEQ test_y
    BCC test_y
    LDA shot1_x
    ADC #$10
    SBC enemy_x
    CMP #$0f
    BEQ test_y
    BCC test_y
    JMP end
  test_y:
    LDA shot1_y
    SBC enemy_y
    CMP #$0f
    BEQ kill_enemy
    BCC kill_enemy
    LDA shot1_y
    ADC #$10
    SBC enemy_y
    CMP #$0f
    BEQ kill_enemy
    BCC kill_enemy
    JMP end
  ; remove enemy and bullet sprites from the screen on a hit
  kill_enemy:
    LDA enemy_x
    STA explosion_x
    LDA enemy_y
    STA explosion_y
    LDA #$00
    STA $0220
    STA $0221
    STA $0222
    STA $0223
    STA $0211
    STA $0215
    STA $0219
    STA $021d
    STA $0212
    STA $0216
    STA $021a
    STA $021e
    STA $0210
    ;STA $0213
    STA $0214
    STA $0217
    STA $0218
    STA $021b
    STA $021c
    STA $021f
    STA shot_count
    STA enemy_count
    STA explosion_frames
    LDA #$01
    STA enemy_died
  end:
    RTS
.endproc