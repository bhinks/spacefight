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
  check_zero:
    LDA shot_count
    CMP #$00
    BNE check_one
    LDA player_x
    ADC #$03
    STA shot1_x
    LDX player_y
    STX shot1_y
    LDA shot_count
    EOR #%00000001
    STA shot_count
    JSR play_sound
  check_one:
    LDA shot_count
    AND #%00000001
    CMP #%00000001
    BNE skip
    LDA player_x
    ADC #$03
    STA shot2_x
    LDX player_y
    STX shot2_y
    LDA shot_count
    EOR #%00000010
    STA shot_count
    JSR play_sound
    JMP end

  skip:
    LDA #$00
    STA $4002
    LDA #$00
    STA $4003
  end:
    RTS
.endproc

.proc play_sound
  ; try to play a sound
  LDA #%10111111 ; Duty 10, Volume F (maximum)
  STA $4000

  LDA #$C9    ; 0C9 is a C# in NTSC mode
  STA $4002
  LDA #$00
  STA $4003
  RTS
.endproc

.proc draw_shots

  ; write empty tile for bullet until one if fired
  LDA #$00
  STA $0221
  STA $0225
 
  ; write bullet tile attributes
  ; use palette 3
  LDA #%00000011
  STA $0222
  STA $0226

  ; check current shot count
  ; only one shot is allowed on the screen at a time currently
  LDY #$09
  check_one:
    LDA shot_count
    AND #%00000001
    CMP #%00000001
    BNE check_two
    STY $0221
    LDA shot1_y
    STA $0220
    LDA shot1_x
    STA $0223
  check_two:
    LDA shot_count
    AND #%00000010
    CMP #%00000010
    BNE skip
    STY $0225
    LDA shot2_y
    STA $0224
    LDA shot2_x
    STA $0227
  
  skip:

  RTS
.endproc

.proc update_shots

  LDA shot_count
  AND #%00000001
  CMP #%00000001
  BNE check_two
  
  DEC shot1_y
  DEC shot1_y
  DEC shot1_y
  DEC shot1_y

  check_two:
  LDA shot_count
  AND #%00000010
  CMP #%00000010
  BNE edge_one

  DEC shot2_y
  DEC shot2_y
  DEC shot2_y
  DEC shot2_y

  ; check if bullet has hit the top of the screen
  edge_one:
    LDA shot1_y
    CMP #$10
    BCC stop_one_up
    JMP edge_two

  stop_one_up:
    LDA shot_count
    AND #%00000001
    CMP #%00000001
    BNE edge_two
    LDA #$00
    STA $0220
    STA $0221
    STA $0222
    STA $0223
    LDA shot_count
    EOR #%00000001
    STA shot_count

  edge_two:
    LDA shot2_y
    CMP #$10
    BCC stop_two_up
    JMP exit_subroutine
  stop_two_up:
    LDA shot_count
    AND #%00000010
    CMP #%00000010
    BNE exit_subroutine
    LDA #$00
    STA $0224
    STA $0225
    STA $0226
    STA $0227
    LDA shot_count
    EOR #%00000010
    STA shot_count

  exit_subroutine:
    RTS
.endproc

.proc kill_test
  LDA shot_count
  CMP #$00
  BEQ end
  ; check for shot collision with enemy
  AND #%00000010
  CMP #%00000010
  BEQ test_two_x
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
  test_two_x:
    LDA shot2_x
    SBC enemy_x
    CMP #$0f
    BEQ test_two_y
    BCC test_two_y
    LDA shot2_x
    ADC #$10
    SBC enemy_x
    CMP #$0f
    BEQ test_two_y
    BCC test_two_y
    JMP end
  test_two_y:
    LDA shot2_y
    SBC enemy_y
    CMP #$0f
    BEQ kill_enemy
    BCC kill_enemy
    LDA shot2_y
    ADC #$10
    SBC enemy_y
    CMP #$0f
    BEQ kill_enemy
    BCC kill_enemy
    JMP end
  ; remove enemy and bullet sprites from the screen on a hit
  kill_enemy:
    JSR kill
  end:
    RTS
.endproc

.proc kill
  LDA enemy_x
    STA explosion_x
    LDA enemy_y
    STA explosion_y
    LDA #$00
    STA $0220
    STA $0221
    STA $0222
    STA $0223

    STA $0224
    STA $0225
    STA $0226
    STA $0227

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
  RTS
.endproc