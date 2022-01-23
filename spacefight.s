; TODO
; game over screen
; title screen
; score
; music
; power-ups (speed, extra life, ?)
; boss?

.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA

  ; get input from controller
  read_input:
    LDA #$01
    STA CTRL1
    STA buttons
    LSR A
    STA CTRL1
  loop:
    LDA CTRL1
    LSR A
    ROL buttons
    BCC loop
  ; check for collisions between player and enemy
  JSR collision_test
  LDA #$01
  CMP dead
  BEQ game_over

  ; update and redraw sprite tiles
  JSR update_player
  JSR draw_player

  JSR update_enemy
  JSR draw_enemy

  JSR fire_shot
  JSR update_shots
  JSR kill_test
  JSR draw_shots

  LDA #$01
  CMP enemy_died
  BEQ explode_enemy

  JMP continue

  ; check explosion animation frame count and stop incrementing if animation is finished
  game_over:
    JSR explode
    JSR end_game
    JMP continue
  explode_enemy:
    JSR explode
    
  ; end sprite and game state updates. scroll background.
  continue:
    LDA #$00
    STA $2005
    STA $2005

    LDX #$20
    JSR draw_background
    LDX #$28
    JSR draw_background
    JSR scroll_background

  RTI
.endproc

.import reset_handler
.import draw_player
.import update_player
.import draw_background
.import scroll_background
.import draw_enemy
.import update_enemy
.import end_game
.import collision_test
.import fire_shot
.import draw_shots
.import update_shots
.import kill_test
.import explode

.export main
.proc main
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR

  ; init zero-page values
  LDA #$80
  STA player_x
  LDA #$a0
  STA player_y

  LDA #$80
  STA enemy_x
  LDA #$00
  STA enemy_y
  
  LDA #$00
  STA enemy_dir
  STA dead
  STA shot_count
  STA enemy_count
  STA explosion_frames

  LDA #239   ; y is only 240 lines tall
  STA scroll

  load_palettes:
    LDA palettes,X
    STA PPUDATA
    INX
    CPX #$20
    BNE load_palettes

  vblankwait:
    BIT PPUSTATUS
    BPL vblankwait

    LDA #%10010000 ; turn on NMIs, sprites use first pattern table
    STA ppuctrl_settings
    STA PPUCTRL
    LDA #%00011000 ; turn on screen
    STA PPUMASK
  forever:
    JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "starfield.chr"

.segment "RODATA"
palettes:
  .byte $0d, $00, $10, $20
  .byte $0d, $01, $11, $21
  .byte $0d, $06, $16, $26
  .byte $0d, $09, $19, $29
  .byte $0d, $00, $10, $20
  .byte $0d, $27, $16, $38
  .byte $0d, $06, $16, $26
  .byte $0d, $09, $19, $29

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
scroll: .res 1
ppuctrl_settings: .res 1
buttons: .res 1
enemy_x: .res 1
enemy_y: .res 1
enemy_dir: .res 1
enemy_count: .res 1
enemy_died: .res 1
dead: .res 1
shot1_x: .res 1
shot1_y: .res 1
shot2_x: .res 1
shot2_y: .res 1
shot3_x: .res 1
shot3_y: .res 1
shot4_x: .res 1
shot4_y: .res 1
shot_count: .res 1
explosion_frames: .res 1
explosion_x: .res 1
explosion_y: .res 1
.exportzp player_x, player_y, dead
.exportzp enemy_dir, enemy_x, enemy_y, enemy_count, enemy_died
.exportzp ppuctrl_settings, scroll, buttons
.exportzp shot_count, shot1_x, shot1_y, shot2_x, shot2_y, shot3_x, shot3_y, shot4_x, shot4_y
.exportzp explosion_frames, explosion_x, explosion_y