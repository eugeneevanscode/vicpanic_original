//
// Vic Panic - Original copyright (c) 1982 Bug Byte Software - Written by Eugene Evans

// It's hard to say where the ownership of this game currently sits. I was an employee of Bug Byte. The company no longer exists.
// I'm unaware of any of the assets being acquired. In addition this game was a copy of a popular arcade game "Space Panic".
// As a result I'm comfortable posting this source code which I created by disassembling the object code from a tap file which someone else
// had captured and made available online

// Versions

// 2023-03-11 Posted first build
//      Full disassembly is not complete. Some tables and data is still hard coded which means if you change the code you make break the game.
//      My goal is to complete the disassembly so that the game is ready to be changed. I hope to them go on to make some serious improvements
//      while staying turn to being a game for the unexpanded original 4K Vic 20

//
//  Define VIC 20 Hardware System Addresses
//
        .var VIC_HORZ_POS_INTERLACE = $9000
        .var VIC_VERT_POS = $9001
        .var VIC_COLUMN_COUNT = $9002
        .var VIC_ROW_COUNT = $9003
        .var VIC_COLUMN = $9002
//              Bits 0-6 set # of columns
//              Bit 7 is part of video matrix address
        .var VIC_RASTER_LINE = $9004
        .var VIC_Char_Mem = $9005
//              Bits 0-3 start of character memory
//                    (default = 0)
//              Bits 4-7 is rest of video address
//                    (default= F)
//                    BITS 3,2,1,0 CM startinq address
//                                        HEX   DEC
//                           0000   ROM   8000  32768
//                           0001         8400  33792
//                           0010         8800  34816
//                           0011         8C00  35840
//                           1000   RAM   0000  0000
//                           1001   xxxx
//                           1010   xxxx  unavail.
//                           1011   xxxx
//                           1100         1000  4096
//                           1101         1400  5120
//                           1110         1800  6144
//                           1111         1C00  7168
//      .var VIC_??? = $9006
//      .var VIC_??? = $9007
//      .var VIC_??? = $9008
//      .var VIC_??? = $9009
        .var VIC_OSC_1_FREQ = $900A
        .var VIC_OSC_2_FREQ = $900B
        .var VIC_OSC_3_FREQ = $900C
        .var VIC_NOISE = $900D
        .var VIC_VIA_1_AUX_COL_VOL = $900E
//              bit 0-3 sets volume of all sound
//              bits 4-7 are auxiliary color information
        .var VIC_SCREEN_COLORS = $900F
//              Screen and border color register
//              Bits 0-2 select border color
//              Bit 3 selects inverted or normal mode
//              Bits 4-7 select background color

// VIA 1
        .var VIC_VIA_1_Port_A = $9111   
//                   Port A Output Register
//                   Bit 2=Joy 0        0b00000100 / 0x04 / Up
//                   Bit 3=Joy 1        0b00001000 / 0x08 / Down
//                   Bit 4=Joy 2        0b00010000 / 0x10 / Left
//                   Bit 5=Fire button  0b00100000 / 0x20 / Fire
        .var Joystick_Up_Bit = $04      // Read from port $911F
        .var Joystick_Down_Bit = $08    // Read from port $911F
        .var Joystick_Left_Bit = $10    // Read from port $911F
        .var Joystick_Right_Bit = $80   // Read from port $9120
        .var Joystick_Fire_Bit = $20    // Read from port $911F

//      .var    ??? = $9112
//      .var    ??? = $9113
//      .var    ??? = $9114
//      .var    ??? = $9115
//      .var    ??? = $9116
//      .var    ??? = $9117
//      .var    ??? = $9118
//      .var    ??? = $9119
//      .var    ??? = $911A
//      .var    ??? = $911B
//      .var    ??? = $911D
        .var    VIC_VIA_1_Int_Enable = $911E
//      .var    ??? = $911F

// VIC #2

        .var VIC_VIA_2_Key_Col_Scan = $9120     // Write to this port to select what keyboard column to check (See Keyboard Matrix Below)
                                                // 0 selects a column
        .var VIC_VIA_2_Key_Row_Scan = $9121     // Read this 
        .var VIC_VIA_2_DDR_B = $9122
//      .var VIC_VIA_2_DDR_B = $9123
//                   Bit 7 = Joy 3      0b00000010 / 0x20 / Fire?
        .var VIC_VIA_2_Int_Enable = $912E

// VIC20 Keyboard Matrix

// Write to Port B($9120)column - 0 bit selects column to read - write a $7F (0b01111111) here and then read $9121 ad check the high order bit to read F7
// Read from Port A($9121)row

//     7   6   5   4   3   2   1   0
//    --------------------------------
//  7| F7  F5  F3  F1  CDN CRT RET DEL    CRT=Cursor-Right, CDN=Cursor-Down
//   |
//  6| HOM UA  =   RSH /   ;   *   BP     BP=British Pound, RSH=Should be Right-SHIFT,
//   |                                    UA=Up Arrow
//  5| -   @   :   .   ,   L   P   +
//   |
//  4| 0   O   K   M   N   J   I   9
//   |
//  3| 8   U   H   B   V   G   Y   7
//   |
//  2| 6   T   F   C   X   D   R   5
//   |
//  1| 4   E   S   Z   LSH A   W   3      LSH=Should be Left-SHIFT
//   |
//  0| 2   Q   CBM SPC STP CTL LA  1      LA=Left Arrow, CTL=Should be CTRL, STP=RUN/STOP
//   |                                    CBM=Commodore key

// VIC20 Keyboard Layout

//  LA  1  2  3  4  5  6  7  8  9  0  +  -  BP HOM DEL    F1
//  CTRL Q  W  E  R  T  Y  U  I  O  P  @  *  UA RESTORE   F3
// STOP SL A  S  D  F  G  H  J  K  L  :  ;  =  RETURN      F5
// C= SHIFT Z  X  C  V  B  N  M  ,  .  /  SHIFT  CDN CRT   F7
//         [        SPACE BAR       ]



//
//  Game Constants
//
        .var screen_width = 22  // 22 characters across ($16)
        .var screen_height = 23 // 23 characters high ($17)

        .var initial_player_x = $0B
        .var initial_player_y = $12

        .var Player_Move_Up = 0
        .var Player_Move_Right = 1
        .var Player_Move_Down = 2
        .var Player_Move_Left = 3

        .var Alien_Up = $00
        .var Alien_Right = $04
        .var Alien_Left = $08
        .var Alien_Down = $0C

// Colors
        .var Color_Black = 0
        .var Color_White = 1
        .var Color_Red = 2
        .var Color_Cyan = 3
        .var Color_Purple = 4
        .var Color_Green = 5
        .var Color_Blue = 6
        .var Color_Yellow = 7

// Char_Map = $1C00

// Character List
        .var Char_Blank = 0
        .var Char_Ladder_Main = 1
        .var Char_Ladder_Top = 2
        .var Char_Floor = 3
        .var Char_Floor_Dug_1 = 4
        .var Char_Floor_Dug_2 = 5
        .var Char_Floor_Dug_3 = 6
        .var Char_Floor_Dug_4 = 7
        .var Char_Alien_0 = 8
        .var Char_Alien_1 = 9
        .var Char_LifeCount = $A
        .var Player_Shovel_Right_Top_0 = $B
        .var Player_Shovel_Right_Bot_0 = $C
        .var Player_Shovel_Left_Top_0 = $D
        .var Player_Shovel_Left_Bot_0 = $E
        .var Player_Shovel_Right_Top_1 = $F
        .var Player_Shovel_Right_Bot_1 = $10
        .var Player_Shovel_Left_Top_1 = $11
        .var Player_Shovel_Left_Bot_1 = $12
        .var Player_Climb_Top_0 = $13
        .var Player_Climb_Bot_0 = $14
        .var Player_Climb_Top_1 = $15
        .var Player_Climb_Bot_1 = $16
        .var Player_Run_Left_Bottom_0 = $17
        .var Player_Run_Top_0 = $18 // ??
        .var Char_Player_Body_1 = $19 // ??
        .var Char_Player_Leg_0 = $1A
        .var Char_Player_Leg_1 = $1B
        .var Char_Alien_In_Hole = $1C
        .var Char_Alien_Dead = $1D

        .var Char_Player_Upper = $21

// Alphanumeric Characters - high bit set means they come from the standard character set so we don't have to define their bitmaps
        .var Char_0 = $B0
        .var Char_1 = $B1
        .var Char_2 = $B2
        .var Char_3 = $B3
        .var Char_4 = $B4
        .var Char_5 = $B5
        .var Char_6 = $B6
        .var Char_7 = $B7
        .var Char_8 = $B8
        .var Char_9 = $B9

// Scratch Memory Map

        .var Player_Direction = $20              // Player Direction - Most recent joystick direction
// Unknown_0 = $21
// Unknown_1 = $22
// Unknown_2 = $23
// Unknown_3 = $24
// Unknown_4 = $25
// Unknown_5 = $26
        .var Current_Level = $27        // The current level in the game
// Unknown_7 = $28
        .var Char_X = $29               // Character X Co-ordinate
        .var Char_Y = $2A               // Character Y Co-ordinate
        .var Char_To_Draw = $2B         // Character to Draw
        .var Color_To_Draw = $2C        // Character Color to Draw
        .var Char_Screen_Adr_Lo = $2D   // Lo/Hi Indirect Address in video memory of Char at Char_X,Char_Y
        .var Char_Screen_Adr_Hi = $2E

        .var Aliens_Live_Count = $2F    // Number of active aliens on screen
        .var Alien_Anim_Frame = $30     // What frame of animation are we showing for alien? This gets incremented and then the lowest bit used to alternate between two frames
        .var Curr_Alien = $31           // Current Alien that we're processing
// Unknown_17 = $32
        .var Curr_Alien_X = $33         // Current Alien X,Y location on screen
        .var Curr_Alien_Y = $34
// Unknown_20 = $35
// Unknown_21 = $36
// Unknown_22 = $37
// Unknown_23 = $38
// Unknown_24 = $39

        .var Player_X = $3A             // Initial Player X Co-ordinate
        .var Player_Y = $3B             // Initial Player Y Co-ordinate
        .var Player_Top_Under_Char = $3C
        .var Player_Bot_Under_Char = $3D
        .var Player_Top_Under_Col = $3E
        .var Player_Bot_Under_Col = $3F

// Unknown_31 = $40
// Unknown_31 = $41
// Unknown_31 = $42                    // X coord of the Alien we're currently processing
// Unknown_31 = $43
        .var Num_Live_Aliens = $44     // Number of aliens on screen
// Unknown_31 = $45
// Unknown_31 = $46     // Number of Aliens?
// Unknown_31 = $47     // Level for alien you killed??
// Unknown_31 = $48     // Score for alien you killed??


//
// Table of Data for Aliens

        .var Alien_Data = $033B         //$33B to $3FF is available RAM not used when a game is running (Cassette buffer?)
        //      X
        //      Y
        //      Color = Upper Nibble / Direction = Lower Nibble


// Screen Addresses used for drawing on screen - Screen is 22 ($16) characters across by 23 ($17) down

        .var Screen_Start = $1E00

        .var Screen_Line_01 = Screen_Start                       // $1E00
        .var Screen_Line_02 = Screen_Start+(1*screen_width)      // $1E16
        .var Screen_Line_03 = Screen_Start+(2*screen_width)      // $1E2C Platform
        .var Screen_Line_04 = Screen_Start+(3*screen_width)      // $1E42
        .var Screen_Line_05 = Screen_Start+(4*screen_width)      // $1E58
        .var Screen_Line_06 = Screen_Start+(5*screen_width)      // $1E6E Platform
        .var Screen_Line_07 = Screen_Start+(6*screen_width)      // $1E84
        .var Screen_Line_08 = Screen_Start+(7*screen_width)      // $1E9A
        .var Screen_Line_09 = Screen_Start+(8*screen_width)      // $1EB0 Platform
        .var Screen_Line_10 = Screen_Start+(9*screen_width)      // $1EC6
        .var Screen_Line_11 = Screen_Start+(10*screen_width)     // $1EDC
        .var Screen_Line_12 = Screen_Start+(11*screen_width)     // $1EF2 Platform
        .var Screen_Line_13 = Screen_Start+(12*screen_width)     // $1F08
        .var Screen_Line_14 = Screen_Start+(13*screen_width)     // $1F1E
        .var Screen_Line_15 = Screen_Start+(14*screen_width)     // $1F34 Platform
        .var Screen_Line_16 = Screen_Start+(15*screen_width)     // $1F4A
        .var Screen_Line_17 = Screen_Start+(16*screen_width)     // $1F60
        .var Screen_Line_18 = Screen_Start+(17*screen_width)     // $1F76 Platform
        .var Screen_Line_19 = Screen_Start+(18*screen_width)     // $1F8C
        .var Screen_Line_20 = Screen_Start+(19*screen_width)     // $1FA2
        .var Screen_Line_21 = Screen_Start+(20*screen_width)     // $1FB8 Platform
        .var Screen_Line_22 = Screen_Start+(21*screen_width)     // $1FCE Player Count and Score
        .var Screen_Line_23 = Screen_Start+(22*screen_width)     // $1FE4 Oxygen and High Score

// Screen addresses for player count, score, Oxygen and high score
// _XXX_______SCORE000000
// OXYGEN2000__HIGH000000

        .var Screen_Player_Count = Screen_Line_22+1
        .var Screen_Score = Screen_Line_22+16-1                 // Do I have to -1??
        .var Screen_Oxygen_Count = Screen_Line_23+6
        .var Screen_High_Score = Screen_Line_23+16-1

        .var Color_Start = $9600
        
        .var Color_Line_01 = Color_Start                        // $9600
        .var Color_Line_02 = Color_Start+(1*screen_width)       // $9616
        .var Color_Line_03 = Color_Start+(2*screen_width)       // $962C Platform
        .var Color_Line_04 = Color_Start+(3*screen_width)       // $9642
        .var Color_Line_05 = Color_Start+(4*screen_width)       // $9658
        .var Color_Line_06 = Color_Start+(5*screen_width)       // $966E Platform
        .var Color_Line_07 = Color_Start+(6*screen_width)       // $9684
        .var Color_Line_08 = Color_Start+(7*screen_width)       // $969A
        .var Color_Line_09 = Color_Start+(8*screen_width)       // $96B0 Platform
        .var Color_Line_10 = Color_Start+(9*screen_width)       // $96C6
        .var Color_Line_11 = Color_Start+(10*screen_width)      // $96DC
        .var Color_Line_12 = Color_Start+(11*screen_width)      // $96F2 Platform
        .var Color_Line_13 = Color_Start+(12*screen_width)      // $9708
        .var Color_Line_14 = Color_Start+(13*screen_width)      // $971E
        .var Color_Line_15 = Color_Start+(14*screen_width)      // $9734 Platform
        .var Color_Line_16 = Color_Start+(15*screen_width)      // $974A
        .var Color_Line_17 = Color_Start+(16*screen_width)      // $9760
        .var Color_Line_18 = Color_Start+(17*screen_width)      // $9776 Platform
        .var Color_Line_19 = Color_Start+(18*screen_width)      // $978C
        .var Color_Line_20 = Color_Start+(19*screen_width)      // $97A2
        .var Color_Line_21 = Color_Start+(20*screen_width)      // $97B8 Platform
        .var Color_Line_22 = Color_Start+(21*screen_width)      // $97CE Player Count and Score
        .var Color_Line_23 = Color_Start+(22*screen_width)      // $97E4 Oxygen and High Score

        * = $1000                   // Assemble to $1000 

        .byte $00           // 00 - no name?
//        .byte $10, $00      // 0x1000 - start address to load the file in memory


Main:   lda #$7F
        sta VIC_VIA_1_Int_Enable        // Interupt enable register - 6522 VIA #1
        sta VIC_VIA_2_Int_Enable        // Interupt enable register - 6522 VIA #2

        ldx #$FF                // Reset stack to the top
        txs

        clc                     // Clear the screen and draw the floors and ladders and clear area with score, etc.
        jsr Clear_Screen
        jsr Draw_Floors
        jsr Clear_Dashboard

        lda #$08                // Set screen and border colors
        sta VIC_SCREEN_COLORS   // 0b00001000 = Black Border, Black Background and Normal Mode (note inverted)

        lda VIC_COLUMN          // Set the top bit of to set part of video matrix address to ???
        ora #$80                // ??
        sta VIC_COLUMN

        lda VIC_VIA_1_AUX_COL_VOL       // What does setting the top bit do???
        ora #$08
        sta VIC_VIA_1_AUX_COL_VOL

        lda #$FF
        sta VIC_VIA_2_DDR_B     // Set Data direction register B to read
        sta VIC_Char_Mem        // Set start of character memory $F in the lower half
                                // sets character map to start at $1C00

        lda #$00
        sta $9113     // Data Direction Register in VIA #1
        sta $9123     // Data Direction Register in VIA #1
        sta VIC_OSC_1_FREQ     // Frequency for oscillator 1
        sta VIC_OSC_2_FREQ     // Frequency for oscillator 2
        sta VIC_OSC_3_FREQ     // Frequency for oscillator 3
        sta VIC_NOISE       // Frequency of noise source

        sta Alien_Anim_Frame    // Start with frame 0 for alien animation

// $104D
        lda #$02                // Set the current level
        sta Current_Level

        lda #$03
        sta $40
        sta $28

        tax                             // Refresh the player lives characters by painting them white
        lda #Color_White
!loop:  sta Color_Line_22,X             // Set color of line 22 on screen
        dex
        bne !loop-

        lda #Char_0             // Character 0
        ldx #$06
!loop:  sta Screen_Score,X      // Put 6 0's across screen for SCORE
        dex
        bne !loop-

//
// New Game - Jump here after a game over
//
// $1066
New_Game:
        lda #Char_2             // Draw Oxygen to screen as 2000
        sta Screen_Oxygen_Count
        lda #Char_0
        sta Screen_Oxygen_Count+1
        sta Screen_Oxygen_Count+2
        sta Screen_Oxygen_Count+3

        inc $28
        inc Current_Level                 // Increment the level count

        lda #$00
        sta $48                 // Zero the level of alien you'll kill
        sta $47                 // Zero the score for the alien you'll kill
        sta $41                 // Zero the number of hits or how long the alien has been in hole??

        jsr Draw_Floors
        jsr Draw_Ladders
        jsr Draw_Aliens
        jsr Initial_Draw_Player

        lda $28
        sta Num_Live_Aliens
        cmp #$04
        bne Main_Loop           // ??

// $109C
        jsr Draw_Game_Start_Message     // Draw either Game Over or F7 message to start game??
        jmp Main_Loop

Lose_Life:
        ldy $40                 //
        dey
        sty $40
        beq Out_Of_Lives        // Branch if 0, the player is out of lives
        lda #Color_Black        // Leave the Player symbol on screen but make it black so it disappears
        sta Color_Line_22+1,Y
        jmp $13BE

Out_Of_Lives:
        jsr Comp_High_Score             // Check for new high score $1D0C
        jsr Draw_Game_Over_Message      // $1A84
        jsr Clear_Main_Screen           // $13C4
        jmp $104D
        
        jsr $162C

        ldx Curr_Alien
        lda $3A
        sta Alien_Data,X
        inx
        lda $3B
        sta Alien_Data,X
        ldy #$0F
!loop:  tya
        pha
        jsr $15FC
        inc Alien_Anim_Frame            // Increment to alternate to next frame of alien animation
        jsr $1D36
        pla
        tay
        dey
        bne !loop-
        jmp $109C

// $10DB
// L00DD:
Main_Loop:
        jsr Move_Aliens                // Move all the aliens
        jsr Move_Player                // Move the player??
        jsr Decrement_Oxygen           // Decrement the Oxygen Counter??
        jmp Main_Loop

// $10E7??
Move_Aliens:
        lda $28                 // Get the current level number and x4 to use as index
        clc
        asl
        asl
        sta $2F

        ldx #$01                // Start processing aliens from the first one
!loop:  stx Curr_Alien
        jsr $162C               // Draw_Alien??
        jsr $1650
        jsr $1862
        jsr $15FC
        inx                             // Inc to look at next Alien and compare with the number of Aliens on screen
        cpx Aliens_Live_Count
        bcc !loop-

        inc Alien_Anim_Frame            // Increment to alternate to next frame of alien animation

        ldx #$A0
        jsr Delay_By_X
        rts

// $110B??
Move_Player:
        lda Player_X            // Get the Player X and Y cordinate and set up to draw Character
        sta Char_X
        lda Player_Y
        sta Char_Y

        inc Char_Y              // Check what is under the player
        jsr Check_Below
        dec Char_Y
        cmp #Char_Blank         // Is there a gap in the floor below the player, if yes branch and start the player falling
        beq !B0+

        cmp #Char_Ladder_Top    // Is there a ladder below? If so we're still not back on the ground so keep falling
        bne Handle_Move_Player  // There is something else under the player so don't fall - L0141

// There was nothing under the character so make them fall??
!B0:    jsr $150E               // Draw the Player
        inc Char_Y              // Move the player down one character

        jsr Get_Chars_Under_Player

        lda VIC_OSC_3_FREQ      // Read frequency of Oscilllator 3
        bne L0136

        lda #$80
        sta VIC_OSC_3_FREQ      // Set frequency of Oscilllator 3

L0136:  lda #$02
        adc VIC_OSC_3_FREQ      // Add to frequency of Oscilllator 3
        sta VIC_OSC_3_FREQ      // Set frequency of Oscilllator 3
        jmp $13F3

//
// ??
//

L0141:  
Handle_Move_Player:
        lda #$00                // Silent frequency of Oscilllator 3
        sta VIC_OSC_3_FREQ

        jsr Get_Player_Input    // Read the Joystick/Keyboard and return with direction in A          This code is only called once, move here and save a few bytes??
        bcc !B0+                // If carry is clear we got a direction
        rts                     // Otherwise return

!B0:    cmp #Player_Move_Up
        bne !B1+                // If not Up check next direction
        beq Handle_Move_Up

!B1:    cmp #Player_Move_Right  // If not Right check next direction
        bne !B2+
        jmp Handle_Move_Right   // $121A

!B2:    cmp #Player_Move_Down   // If not Down check next direction
        bne !B3+
        jmp Handle_Move_Down    // $1270

!B3:    cmp #Player_Move_Left   // If not Left check return
        bne !B4+                // Could branch to another RTS and save a byte??
        jmp Handle_Move_Left    // $142A

!B4:    rts

Handle_Move_Up:
        lda Player_Top_Under_Char        // Is the player on a ladder??
        cmp #Char_Ladder_Main
        beq Climb_Ladder_Up

        lda Player_Bot_Under_Char
        cmp #Char_Ladder_Main
        beq Climb_Ladder_Up

        lda Char_Y                      // Is the player at the bottom of the play area on screen
        cmp #screen_height-5            // Subtract two lines for dashboard, one line of bricks and lower body ($12)
        beq Player_No_Move              // If at bottom of screen player shouldn't move down - Why??

        jsr Check_Alien_Collision       // $1529

        lda Player_Bot_Under_Char       // If the player is at the top of the ladder they can't climb up further so the player shouldn't move
        cmp #Char_Ladder_Top
        beq Player_No_Move

        inc Char_Y
        jsr Get_Char_From_Screen

        inc Char_Y
        lda Char_To_Draw
        cmp #Player_Shovel_Right_Bot_1
        beq !B0+

        cmp #Player_Shovel_Left_Bot_1
        bne Player_No_Move

        dec Char_X                      // Decrement X and see if it went it wrapped to $FF which means we're at the left side of screen, character 0
        lda Char_X
        cmp #$FF
        beq Player_No_Move
        bne !B1+

!B0:    inc Char_X                      // Increment X and if we're off the right side of screen
        lda Char_X
        cmp #screen_width
        beq Player_No_Move

// L01A6:
!B1:    dec Char_Y
        jsr Get_Char_From_Screen
        lda Char_To_Draw
        cmp #Char_Ladder_Main
        beq Player_No_Move

        inc Char_Y
        jsr Get_Char_From_Screen
        inc Char_To_Draw
        lda Char_To_Draw
        cmp #Char_Ladder_Top
        beq Player_No_Move

        cmp #Char_Ladder_Main
        beq Player_No_Move
        
        cmp #Char_Alien_0               // Did the player hit an Alien? This only check the 0 frame shouldn't we be checking for Char_Alien_1 also??
        bne L01CA

        lda #Char_Blank
        sta Char_To_Draw
L01CA:  jsr Draw_Char_On_Screen

//L01CD:
Player_No_Move:                         // Branch to here and return if the player actually isn't going to move. Edge of screen, top of ladder, etc.
        rts

// L01CE:
Climb_Ladder_Up:
        jsr Get_Char_From_Screen        // Get what is on screen under the player

        lda Char_To_Draw                   // If the player is on the ladder
        cmp #Player_Climb_Top_0
        bne !B1+
        jsr Check_Below
        cmp #Player_Climb_Bot_0
        bne !B1+

//L01DE:
!B0:    lda #Player_Climb_Top_1
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
// $11E3
Draw_Lower_Player:
        inc Char_To_Draw
        inc Char_Y
Draw_Lower_Player_2:
        jsr Draw_Char_On_Screen
        dec Char_Y
        rts

//L01EF:
!B1:    jsr Get_Char_From_Screen
        lda Char_To_Draw
        cmp #Player_Climb_Top_1
        bne !B0-

        jsr Check_Below
        cmp #Player_Climb_Bot_1
        bne !B0-
        
        dec Char_Y
        jsr $147D
        
        inc Char_Y
        jsr $150E
        
        dec Char_Y
        jsr Get_Chars_Under_Player
        
        lda #Color_White
        sta Color_To_Draw
        lda #Player_Climb_Top_0
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        jmp Draw_Lower_Player

// $121A
Handle_Move_Right:
        jsr Get_Char_From_Screen

        lda Char_To_Draw
        cmp #Player_Climb_Top_1         // Should this be cmp #$21
        bne !B0+                        // L023C
        jsr Check_Below
        cmp #Char_Player_Leg_0
        bne !B0+                        // L023C

!loop:  lda #Player_Run_Top_0           // Draw player body upper character
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        inc Char_Y                      // Move down a character and draw player body lower character
        lda #Char_Player_Leg_1
        sta Char_To_Draw
        jmp Draw_Lower_Player_2

// L023C:
!B0:
        jsr Get_Char_From_Screen
        
        lda Char_To_Draw
        cmp #Player_Run_Top_0
        bne !loop-
        
        jsr Check_Below
        cmp #Char_Player_Leg_1
        bne !loop-
        
        inc Char_X
        jsr $147D

        dec Char_X
        jsr $150E
        
        inc Char_X
        jsr Get_Chars_Under_Player

        lda #Color_White
        sta Color_To_Draw
        lda #Player_Climb_Top_1          // Not sure if this is right label, it was $21
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        inc Char_Y
        lda #Char_Player_Leg_0          // $1A is this correct??
        sta Char_To_Draw
        jmp Draw_Lower_Player_2

// L026F:
Player_on_Ladder:
        jmp $13E3                       // Jump because otherwise the branch is too far away

// $1270
Handle_Move_Down:
        lda Player_Top_Under_Char       // Is the player on the ladder
        cmp #Char_Ladder_Main
        beq Player_on_Ladder            // Check the top and bottom of the player
        cmp #Char_Ladder_Top            // Both the mid and top ladder and if yes branch to handle climbing
        beq Player_on_Ladder

        lda Player_Bot_Under_Char
        cmp #Char_Ladder_Main
        beq Player_on_Ladder
        cmp #Char_Ladder_Top
        beq Player_on_Ladder
        
        lda Char_Y                      // Is the player at the bottom of the play area on screen
        cmp #screen_height-5            // Subtract two lines for dashboard, one line of bricks and lower body ($12)
        bne Climb_Ladder_Down           // If at the bottom return without moving, otherwise handle climbing down

// L028C:
Player_Not_Moving:
        rts

//L028D:
Climb_Ladder_Down:
        jsr Check_Alien_Collision       // $1529

        lda Get_Chars_Under_Player                       // Why does this seem to load the first byte of a subroutine???
        cmp #Char_Ladder_Top            // Is the player on the top of a ladder
        beq Player_Not_Moving                       // If yes, make the player walk down the ladder.
        
        inc Char_Y
        jsr Get_Char_From_Screen
        inc Char_Y
        
        lda Char_To_Draw                // Is the player digging?
        cmp #Player_Shovel_Right_Bot_1
        beq !B0+
        cmp #Player_Shovel_Left_Bot_1
        bne Player_Not_Moving

        dec Char_X                      // The player is digging to the left but check if he's digging off the left of the screen
        lda Char_X
        cmp #$FF
        beq Player_Not_Moving           // If player is at left of screen return without moving/digging
        bne L02BA

// L02B2:
!B0:    inc Char_X                      // The player is digging to the right but check if he's digging off the right of the screen
        lda Char_X                      // Are we at the right of the screen?
        cmp #screen_width
        beq Player_Not_Moving           // If player is at right of screen return without moving/digging

// $12B8??
L02BA:  jsr Get_Char_From_Screen        // Get the character on the screen that the player is digging
        dec Char_To_Draw                // Subtract one because we're digging the hole or this could be filling in the hole??

        lda Char_To_Draw                // If it's $00 then Player was digging a ladder so return without the player moving
        beq Player_Not_Moving

        cmp #Char_Alien_1-1             // We decremented the character so check for the character minus 1
        beq L02DF                       // Branch to handle hitting an alien
        cmp #Char_Alien_0-1
        beq L02DF

        cmp #$FF                        // If it went negative we hit an empty hole
        beq L02D7

        cmp #Char_Floor-1
        beq Player_Not_Moving
        jsr Draw_Char_On_Screen
        rts

L02D7:  lda #Char_Floor_Dug_4
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        rts

L02DF:
Hit_Alien:
        inc $41                 // +1 the number of times the Alien has been hit. If it's more than 6 kill the alien
        lda $41
        cmp #$06
        bcs !B0+
        rts

!B0:    jsr Chk_Alien_Impact
        bcs Alien_Collided     // Carry set if collission
        rts

Alien_Collided:
        dex             // X is the number of the Alien that collided, save to scratch
        stx $46
        inx
        inx
        inx
        lda Alien_Data,X
        and #$03
        sta $42
        tay
        lda $1B64,Y
        sta $45
        sta $48

        lda #$00                        // Reset the count of the number of times the alien has been hit
        sta $41
        jsr Draw_Fill_Hole              // Fill the hole the Alien was in. This is only called once could be in line code ??? $1DB6

        inc $47
        jsr Alien_Fall                  // $1DC2
        dec $45

        lda #Char_Blank                 // Draw blank character
        sta Char_To_Draw
        lda #Color_White
        sta Color_To_Draw
        jsr Draw_Char_On_Screen

        jsr Check_Below

        lda Char_To_Draw
        sta $33
        lda Color_To_Draw
        sta $34
        jsr Alien_Fall

        jsr Check_Below                 // Check if there is floor under the Alien
        cmp #Char_Floor
        bcc !B0+
        cmp #Char_Floor_Dug_4+1
        bcc !B1+                // L034A
//L0335
!B0:    cmp #Char_Ladder_Main
        beq !B1+

        lda $33
        sta Char_To_Draw
        lda $34
        sta Color_To_Draw
        jsr Draw_Char_On_Screen
        jsr Alien_Fall
        jmp $1305

// L034A:
!B1:    lda $45
        beq L0386
        cmp #$0F
        bcs L0386
        
        ldx $46
        lda Char_X
        sta Alien_Data,X

        inx
        lda Char_Y
        sta Alien_Data,X

        inx
        lda $34
        clc
        asl             // Multiply by 16 to use as index
        asl
        asl
        asl
        sta Alien_Data,X

        lda $33
        and #$0F
        ora Alien_Data,X
        sta Alien_Data,X
        
        inx
        lda Alien_Data,X
        and #$9F
        ora #$40
        sta Alien_Data,X

        lda #$00
        sta $48         // Zero the current alien level and score ready for the next alien killed
        sta $47         // Do we have to zero both of these, won't they just get over ridden?
        rts

//L0386
L0386:  lda #Char_Alien_In_Hole         // Draw Alien in Hole??
        sta Char_To_Draw
        lda $42
        sta Color_To_Draw
        jsr Draw_Char_On_Screen

        jsr $1D36

        lda $33
        sta Char_To_Draw
        lda $34
        sta Color_To_Draw
        jsr Draw_Char_On_Screen

        ldx $46
        lda #$00
        sta Alien_Data,X
        inx
        lda #screen_width-1
        sta Alien_Data,X
        inx
        lda #$00
        sta Alien_Data,X
        inx
        sta Alien_Data,X

        jsr Add_Score_For_Alien

        dec Num_Live_Aliens       // Decrement number of aliens
        lda Num_Live_Aliens
        beq !B0+                  // If 0 we've killed all the aliens
        rts

// $13BE
!B0:    jsr Clear_Main_Screen
        jmp New_Game              // Game over start a new game $1066

// $13C4
//
// Clear Main Screen - Clear the screen but not the two lines of dashboard
//
Clear_Main_Screen:
        ldx #$00          // Clear the screen and set the color
!loop:  lda #$01          // Set color to XXX
        sta Color_Start,X
        lda #$00          // Set character to XXX                               This could be reduced by overlapping the start address and doing 256 characters
        sta Screen_Start,X
        dex
        bne !loop-

        ldx #$CE          // Clear the rest of the screen and set color
!loop:  lda #$01
        sta Color_Start+$100,X
        lda #$00
        sta Screen_Start+$100,X
        dex
        bne !loop-

        rts

//$13E6
        jsr Get_Char_From_Screen

        lda Char_To_Draw                 // Get the character that was retreived from the screen
        cmp #Player_Climb_Top_0          // 
        bne !B1+

        jsr Check_Below
        cmp #Player_Climb_Bot_0
        bne !B1+

// $13F3??
!B0:    lda #Player_Climb_Top_1
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        jmp Draw_Lower_Player

//L03FF
!B1:    jsr Get_Char_From_Screen
        lda Char_To_Draw
        cmp #Player_Climb_Top_1
        bne !B0-

        jsr Check_Below
        cmp #Player_Climb_Bot_1
        bne !B0-
        inc Char_Y
        jsr $147D
        dec Char_Y
        jsr $150E
        inc Char_Y
        jsr Get_Chars_Under_Player
        lda #Color_White
        sta Color_To_Draw
        lda #Player_Climb_Top_0
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        jmp Draw_Lower_Player

// $142A
Handle_Move_Left:
        jsr Get_Char_From_Screen
        
        lda Char_To_Draw
        cmp #Player_Climb_Top_0
        bne L044C
        
        jsr Check_Below
        cmp #Player_Run_Left_Bottom_0
        bne L044C

L043C:  lda #Player_Run_Top_0         // Draw player body upper character
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        inc Char_Y                      // Move down a character and draw player body lower character  ??
        lda #Char_Player_Body_1         // ?? What character is this? Leg and body don't make sense
        sta Char_To_Draw
        jmp Draw_Lower_Player_2

L044C:
        jsr Get_Char_From_Screen
        lda Char_To_Draw
        cmp #Player_Run_Top_0
        bne L043C

        jsr Check_Below
        cmp #Char_Player_Body_1
        bne L043C

        dec Char_X
        jsr $147D
        
        inc Char_X
        jsr $150E

        dec Char_X
        jsr Get_Chars_Under_Player

        lda #Color_White
        sta Color_To_Draw
        lda #Player_Climb_Top_0
        sta Char_To_Draw
        jsr Draw_Char_On_Screen

        inc Char_Y
        lda #Player_Run_Left_Bottom_0
        sta Char_To_Draw
        jmp Draw_Lower_Player_2

// $147D
        lda #$00                // Silence the Noise generator
        sta VIC_NOISE
        sta $41
        lda Char_X              // Is the character off the right of the screen
        cmp #screen_width
        bcs !B3+                // L04C6
        lda Char_Y              // Is the character at the bottom of the play area of the screen
        cmp #screen_height-3
        bcs !B3+                // L04C6

        jsr Get_Char_From_Screen
        lda Char_To_Draw
        cmp #Char_Floor
        bcc !B0+

        cmp #Player_Shovel_Right_Top_0-1   // ??
        bcs !B0+
        jmp $14C4

// L04A2:
!B0:    jsr Check_Below         // Check below the character
        cmp #Char_Floor         // If there is floor underneath
        bcc !B1+
        cmp #Player_Shovel_Right_Top_0-1                // ??
        bcs !B1+
        jmp !B3+

// L04B0:
!B1:    inc Char_Y
        jsr Check_Below
        dec Char_Y
        beq !B2+
        cmp #Char_Ladder_Main
        beq !B2+
        cmp #Char_LifeCount
        bcs !B2+
        cmp #Char_Floor_Dug_1
        bcs !B3+

!B2:    rts

// $14C4
// L04C6:
!B3:    pla
        pla
        rts

// $14C7
// Set the players initial postion on screen
Initial_Draw_Player:
        lda #initial_player_x
        sta Player_X
        sta Char_X
        lda #initial_player_y
        sta Player_Y
        sta Char_Y

        jsr Get_Chars_Under_Player

        lda #Color_White
        sta Color_To_Draw
        lda #Player_Climb_Top_1
        sta Char_To_Draw
        jsr Draw_Char_On_Screen

        inc Char_Y                    // Inc down one line to draw lower half of body
        lda #Char_Player_Leg_0
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        rts

//
// Get what us under player characters on screen??
//

// $14EB
Get_Chars_Under_Player:
        lda Char_X
        sta Player_X
        lda Char_Y
        sta Player_Y
        jsr Get_Char_From_Screen

        lda Char_To_Draw
        sta Player_Top_Under_Char
        lda Color_To_Draw
        sta Player_Top_Under_Col
        inc Char_Y
        jsr Get_Char_From_Screen

        lda Char_To_Draw
        sta Player_Bot_Under_Char
        lda Color_To_Draw
        sta Player_Bot_Under_Col
        dec Char_Y
        rts

//
// Draw Player??
//
// $150E
Draw_Player:
        lda Player_Top_Under_Char
        sta Char_To_Draw
        lda Player_Top_Under_Col
        sta Color_To_Draw
        jsr Draw_Char_On_Screen
        
        inc Char_Y

        lda Player_Bot_Under_Char
        sta Char_To_Draw
        lda Player_Bot_Under_Col
        sta Color_To_Draw
        jsr Draw_Char_On_Screen

        dec Char_Y

        rts

//
// Check to see what the alien might have collided with??
//
// $1529
Check_Alien_Collision:
        jsr Check_Below         // Check_Right??
        cmp #Char_Player_Leg_0  // Has the alien collided with the players leg animation 0
        beq L054F
        cmp #Char_Player_Leg_1  // Has the alien collided with the players leg animation 1
        beq L054F

        cmp #$19
        beq L056A
        cmp #Player_Run_Left_Bottom_0
        beq L056A
        cmp #Player_Shovel_Right_Bot_0
        beq L054F
        cmp #Player_Shovel_Right_Bot_1
        beq L0565
        cmp #Player_Shovel_Left_Bot_0
        beq L056A
        cmp #Player_Shovel_Left_Bot_1
        beq L056F
        rts

// Alien has hit Player?
L054F:
// $154D
        lda #Player_Shovel_Right_Top_1
// $154F
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        inc Char_To_Draw
        inc Char_Y
        jsr Draw_Char_On_Screen
        dec Char_Y

        lda #$00
        sta VIC_NOISE
        rts

//L0565
L0565:  lda #Player_Shovel_Right_Top_0
        jmp $154F       // Could this be a BNE branch instead?

L056A:  lda #Player_Shovel_Left_Top_1
        jmp $154F       // Could this be a BNE branch instead?

L056F:  lda #Player_Shovel_Left_Top_0
        jmp $154F       // Could this be a BNE branch instead?

// $1572
Draw_Aliens:
        ldx #$01

        lda #$02                // Initial X coordinate - line 2 - of alien??
        sta $22
        lda #$00
        sta $23

        lda #$80
        sta VIC_OSC_1_FREQ

        lda #$0F
        sta VIC_VIA_1_AUX_COL_VOL

        lda $28         // Get number of aliens
        clc             // x4 because there are 4 bytes per alien in the alien data
        asl
        asl
        sta $2F
// L058F:
Next_Alien:
        lda $22
        sta Alien_Data,X
        sta Char_X
        tay
        iny
        iny
        cpy #Player_Climb_Bot_1
        bcc !B0+

        ldy #$02
        inc $23
// L05A1:
!B0:    sty $22
        inx
        ldy $23                         // Get the alien Y coord??
        lda Floor_Level_Y,Y             // Look up the initial position of the alien on the floor
        sta Alien_Data,X
        sta Char_Y
        inx
        jsr Get_Char_From_Screen
        lda Color_To_Draw
        clc
        asl
        asl
        asl
        asl
        sta Alien_Data,X                // Save the alien color in the alien database
        lda Char_To_Draw
        and #$0F
        ora Alien_Data,X
        sta Alien_Data,X

        inx
        lda #$D7
        sta Alien_Data,X
        
        cpx $2F
        bcs !B1+                        // L05EC
        
        txa
        pha

        lda #Char_Alien_1               // Draw alien
        sta Char_To_Draw
        lda #Color_Cyan
        sta Color_To_Draw
        jsr Draw_Char_On_Screen
        
        lda #$04
        adc VIC_OSC_1_FREQ
        sta VIC_OSC_1_FREQ

        ldx #$50
        jsr Delay_By_X

        pla
        tax
// L05EC:
!B1:    inx
        cpx #$C1
        bne Next_Alien

        lda #$00                // Silence sound
        sta VIC_OSC_1_FREQ
        
        rts

// Y co-ordinate of the line above each floor for the Aliens
// $15F5
Floor_Level_Y:
        .byte $01,$04,$07,$0A,$0D,$10,$13

Draw_Alien:
        lda Alien_Anim_Frame            // Test if this number odd or even? Animation frame?
        and #$01
        beq !B0+

        lda #Char_Alien_1                // Frame 1 of player or alien animation
        sta Player_Anim+1               // Self-modified code alert - $1625             - Not sure if self modifying code actually saved us anything here
        bne !B1+

!B0:    lda #Char_Alien_0                // Frame 0 of player or alien animation
        sta Player_Anim+1               // Self-modified code alert - $1625

!B1:    ldx Curr_Alien
        lda Alien_Data,X
        sta Char_X
        inx
        lda Alien_Data,X
        sta Char_Y
        inx
        inx
        lda Alien_Data,X                // Get Alien Color
        and #$03
        sta Color_To_Draw

 Player_Anim:
        lda #Char_Alien_0               // The value loaded in A is set by self-modifying code above.
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        rts

// $162C
// Draw_Alien:
        ldx Curr_Alien                         // Get the alien's X, Y and Color
        lda Alien_Data,X
        sta Char_X
        inx
        lda Alien_Data,X
        sta Char_Y
        inx
        lda Alien_Data,X
        pha
        and #$F0                        // Get the alien color which is in the upper nibble of the byte
        clc                             // Move into lower nibble and set up color to draw
        lsr
        lsr
        lsr
        lsr
        sta Color_To_Draw
        pla
        and #$0F                        // Lower nibble is the character to draw
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        rts

// $1650
        ldx Curr_Alien                  // Get current index into Alien Date table
        lda Alien_Data,X
        sta Char_X
        sta $33
        inx
        lda Alien_Data,X
        sta Char_Y
        sta $34
        inx
        lda Alien_Data,X
        sta $32
        inx
        lda Alien_Data,X
        bmi !B0+
        jmp $1861
// L0672:
!B0:    rol
        bmi !B1+
        jmp $181C

// L0678:
!B1:    jsr Check_Below                 // Check to see if the Alien is over a hole that has been dug
        cmp #Char_Floor_Dug_1
        bcc Alien_In_Hole
        cmp #Char_Floor_Dug_4+1
        bcs Alien_In_Hole               // Put the Alien in the hole??

        inc Char_Y
        jmp $12B8

// L0688:
Alien_In_Hole:                  // May be it's alien NOT in hole??
        ldx Curr_Alien                 // Get the Alien direction from table??
        inx
        inx
        inx
        lda Alien_Data,X
        and #$0C                // Mask the direction bits of data for Alien 0b00001100
        beq Alien_Going_Up      // L06A6     If 0 then the Alien is going Up

        cmp #Alien_Down         // If $0C then the Alien is going Down
        beq Alien_Going_Down    // L06BB

        cmp #Alien_Right        // If $04 then the Alien is going Right
        beq Alien_Going_Right           // L06A1

Alien_Going_Left:
        dec Char_X                      // If $08 then the Alien is going Left
        jmp Check_Alien                 //$16BB

// L06A1:
Alien_Going_Right:
        inc Char_X                      // Move Alien Right
        jmp Check_Alien                 // $16BB

// L06A6:
Alien_Going_Up:
        dec Char_Y                      // Move Alien Left

        jsr Get_Char_From_Screen
        lda Char_To_Draw
        bne Check_Alien                 // L06BD

        jsr Check_Below                 // Has the Alien reached the top of a ladder?
        cmp #Char_Ladder_Top
        bne !B0+                        //L06B8                       // If not at top of ladder keep going
        inc Char_Y                      // If at top of ladder put him back down and keep going
// L06B8
!B0:    jmp Check_Alien                 // $16BB

//L06BB:
Alien_Going_Down:
        inc Char_Y

// $16BB
L06BD:
Check_Alien:
        lda Char_X                      // Is the Alien at the right edge of screen?
        cmp #screen_width
        bcc !B1+
        jmp $174F

// L06C6:
!B0:    jmp $10B7

L06C9:
!B1:    lda Char_Y
        bne !B2+                        //L06D0
L06CD:  jmp $174F

//L06D0:
!B2:    cmp #$14
        beq L06CD

        jsr Get_Char_From_Screen

        lda Char_To_Draw
        cmp #Player_Shovel_Right_Top_0
        bcs !B0-                        // L06C6

        cmp #Char_Alien_0
        beq L0751
        cmp #Char_Alien_1
        beq L0751
        cmp #Char_Floor
        beq L0751
        
        jsr Check_Below
        beq L06FA
        cmp #Player_Shovel_Right_Top_0
        bcs !B0-                        // L06C6

        cmp #Char_Alien_0
        beq L075E
        cmp #Char_Alien_1
        beq L075E

L06FA:  ldx Curr_Alien
        lda Char_X
        sta Alien_Data,X
        inx
        lda Char_Y
        sta Alien_Data,X
        jsr Get_Char_From_Screen

        lda Char_To_Draw
        cmp #Char_Ladder_Top
        beq L076C
        
        cmp #Char_Ladder_Main
        bne !B0+                        // L0717
        
        jmp $1797

// L0717:
!B0:    inc Char_Y
        jsr Get_Char_From_Screen
        dec Char_Y
        lda Char_To_Draw
        cmp #Char_Blank
        beq L0725
        rts

L0725:  ldx Curr_Alien
        inc Char_Y
        inx
        lda Char_Y
        sta Alien_Data,X
        inx
        lda #$FF
        sta Alien_Data,X
        inx
        lda Alien_Data,X
        and #$9F
        ora #$20
        sta Alien_Data,X
        rts

        inc Char_Y
        jsr Get_Char_From_Screen
        dec Char_Y
        lda Char_To_Draw
        cmp #Char_Floor
        bne L0751
        jmp $17E9

L0751:  ldx Curr_Alien                 // Change the direction of the Alien??
        inx
        inx
        inx
        lda Alien_Data,X
        eor #$0C                // Flip the direction the alien is moving?? $00 to $0C, $0C to $00, $08 to $04, $04 to $08
        sta Alien_Data,X

L075E:  ldx Curr_Alien                 // Save the location of the current Alien now that we've moved it??
        lda $33
        sta Alien_Data,X
        inx
        lda $34
        sta Alien_Data,X
        rts

L076C:  inc Char_Y                      // Look under the Alien
        jsr Get_Char_From_Screen
        dec Char_Y

        lda Char_To_Draw
        cmp #Char_Ladder_Main
        bne L07EB

        inc Char_Y
        inc Char_Y
        jsr Get_Char_From_Screen
        dec Char_Y
        dec Char_Y
        
        lda Char_To_Draw
        cmp #Char_Ladder_Main
        bne L07EB

        lda VIC_RASTER_LINE             // get a random number AND with $3 (0b00000011) to limit to 0-3
        and #$03
        tax
        lda Alien_Direction,X           // use the random number from 0-3 to pick a directiom??
        beq L076C

        pha
        jmp Set_Alien_Direction         // $1805

// Look under the alien and to either side to see if there is floor, if it's still mid-ladder not time to move left or right

        inc Char_Y                      // Look under the Alien
        jsr Get_Char_From_Screen
        dec Char_Y
        lda Char_To_Draw
        cmp #Char_Floor
        beq Alien_On_Floor              // L07CF  // If there is floor keep going??

        dec Char_X                      // Look behind or to the left of the Alien to see if there is floor?
        inc Char_Y
        jsr Get_Char_From_Screen
        inc Char_X
        dec Char_Y
        lda Char_To_Draw
        cmp #Char_Floor
        bne L07EA
        
        inc Char_X                      // Look in front or to the right of the Alien to see if there is floor?
        inc Char_Y
        jsr Get_Char_From_Screen
        dec Char_X
        dec Char_Y
        lda Char_To_Draw
        cmp #Char_Floor
        bne L07EA

// The Alien had floor to the left and right so now pick a random direction??

        jsr Random_Binary       // Random number?
        bcs L07EB
        bcc L07FA

// L07CF:
Alien_On_Floor:
        jsr Random_Binary       // Random binary - get a 1 or 0 in carry
        bcs L07EB

        dec Char_Y
        jsr Get_Char_From_Screen
        inc Char_Y
        lda Char_To_Draw
        cmp #Char_Alien_0
        beq L07EB
        cmp #Char_Alien_1
        beq L07EB

        lda #Char_Blank
        pha
        beq Set_Alien_Direction         // L0807

L07EA:  rts

// Does this section choose a random direction for the Alien?

L07EB:
        jsr Random_Binary       // Pick a random 0 or 1 in carry flag
        bcs !B1+                // L07F5

        lda #Alien_Right                // Alien new direction??
        pha
        bne Set_Alien_Direction         //L0807               // This always jumps because we loaded it with a non-zero value

//L07F5:
!B1:    lda #Alien_Left
        pha
        bne Set_Alien_Direction         //L0807               // This always jumps because we loaded it with a non-zero value

L07FA:  jsr Random_Binary       // Pick a random 0 or 1 in carry flag
        bcs L0804

        lda #Alien_Down
        pha
        bne Set_Alien_Direction         //L0807

L0804:  lda #Alien_Up
        pha

// L0807:
// $1805
Set_Alien_Direction:                    // The new direction is on the stack
        ldx Curr_Alien                         // Get alien number we're currently processing
        inx
        inx
        inx
        lda Alien_Data,X
        and #$F3
        sta $37
        pla
        ora $37
        sta Alien_Data,X
        rts

// Look up table for Alien direction
// $1818

Alien_Direction:
        .byte Alien_Up, Alien_Right, Alien_Left, Alien_Down

// $181C
        dex
        lda Alien_Data,X
        tay
        dey
        tya
        sta Alien_Data,X
        cmp #$E0
        bcc !B0+
        rts

// L082D:
!B0:    dex
        lda Alien_Data,X
        tay
        dey
        tya
        sta Alien_Data,X
        inx
        inx
        lda Alien_Data,X
        and #$9F
        ora #$40
        sta Alien_Data,X
        and #$03
        cmp #$01
        beq L0858
        tay
        dey
        tya
        sta $38
        lda Alien_Data,X
        and #$FC
        ora $38
        sta Alien_Data,X
L0858:  lda #Color_Green
        sta Color_To_Draw
        lda #$03
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        rts

// $1861
        ldx Curr_Alien
        inx
        inx
        inx
        rol
        rol
        rol
        bcc L086F
        rts

L086F:  ldx Curr_Alien
        lda Alien_Data,X
        sta Char_X
        inx
        lda Alien_Data,X
        sta Char_Y
        inx
        jsr Get_Char_From_Screen
        lda Color_To_Draw
        clc
        asl
        asl
        asl
        asl
        sta Alien_Data,X
        lda Char_To_Draw
        and #$0F
        ora Alien_Data,X
        sta Alien_Data,X
        rts

//
// Return a random binary value by reading the raster line and rotating the 3rd bit into the carry flag
//
// $1893
Random_Binary:
        clc
        lda VIC_RASTER_LINE      // Read the TV raster line?
        lsr                      // Divide by 8?
        lsr
        lsr
        rts

// $189B
Get_Player_Input:
        jsr Read_Joystick       // Read the Joystick -- Move this subroutine here to save a few bytes - it only appears here
 
// Read_Keyboard usage here is tricky. If a match is found the subroutine doesn't return inline, it pops
// the return address and does at RTS from Get_Player_Input. Not clear if this is actually efficient or
// just very confusing.

        lda #Player_Move_Up     // Set Player direction to Up
        sta Player_Direction
        lda #$FD                // Pass to scan keyboard column 1 (0b11111101)
        jsr Read_Keyboard
 
        lda #Player_Move_Right  // Set Player direction to Right
        sta Player_Direction
        lda #$DF                // Pass to scan keyboard column 5 (0b11011111)
        jsr Read_Keyboard
 
        lda #Player_Move_Down   // Set Player direction to Down
        sta Player_Direction
        lda #$EF
        jsr Read_Keyboard      // Pass to scan keyboard column 4 (0b11101111)
 
        lda #Player_Move_Left  // Set Player direction to Left
        sta Player_Direction   // Pass to keyboard column to scan 0b11101111
        jsr Read_Keyboard
 
        lda #$FB               // Pass to scan keyboard column 2 (0b11111011)
        jsr Read_Keyboard
        sec
        rts

//
// Read the joystick and return direction in A and Player_Direction = $20
//
//      0 = Up
//      1 = Right
//      2 = Down
//      3 = Left
//

// Lok at this for a smart way to check all bits of joystick more efficiently https://www.chibiakumas.com/6502/simplesamples.php#LessonS12

// $18C7
Read_Joystick:
                lda VIC_VIA_1_Port_A            // read the VIC port tied to joystick
                and #Joystick_Up_Bit            // Check for up on Joy 0 - Bit 2 - 0x00000100
                bne Joy_Not_Up                  // Branch if it is up
                lda #Player_Move_Up             // Return 0 for player pushing joystick up
                beq Return_Dir

Joy_Not_Up:     lda VIC_VIA_1_Port_A            // read the joystick
                and #Joystick_Down_Bit          // Check for Up on Joy 1 - Bit 3 - 0x00001000
                bne Joy_Not_Down
                lda #Player_Move_Down           // Return 2 for player pushing joystick down
                bne Return_Dir

Joy_Not_Down:   lda VIC_VIA_1_Port_A            // read the joystick
                and #Joystick_Left_Bit          // Check for Left on Joy 1 - Bit 4 - 0x00010000
                bne Joy_Not_Left
                lda #Player_Move_Left           // Return 3 for player pushing joystick left
                bne Return_Dir

// L08EA:
Joy_Not_Left:   lda #$7F                        // Set DDR to read, zero is read 0b01111111
                sta VIC_VIA_2_DDR_B
                lda VIC_VIA_2_Key_Col_Scan      // read the joystick

                pha                             // Push to stack to save the result of reading the joystick
                lda #$FF                        // Set DDR back to write, not clear if this is actually needed??
                sta VIC_VIA_2_DDR_B
                pla                             // Retrieve the result of reading the joystick from the stack

                and #Joystick_Right_Bit         // Check for Right on Joy 3 - Bit 7 - 0x10000000
                bne Joy_Not_Right

                lda #Player_Move_Right          // Return 1 for Right?
Return_Dir:     sta Player_Direction            // Store direction of player based on Joystick 0

L0901:          pla                             // Pull the return address
                pla
                lda Player_Direction            // Load the direction and return
                clc
// L0906:
Joy_Not_Right:  rts

// $1905
Read_Keyboard:
        sta VIC_VIA_2_Key_Col_Scan      // Write to VIC 2 Port B to select column to scan - 0 bit in A selects column
        lda VIC_VIA_2_Key_Row_Scan      // Read VIC 2 Row Scan to see what key is held down
        and #$20                        // Check row 5 (0b00100000) - Checking for 'P' or 'E' key??
        beq L0901
        
        lda VIC_VIA_2_Key_Row_Scan      // Read VIC 2 Row Scan to see what key is held down
        and #$02                        // Check 0b00000010 - Checking for 'W' key??
        beq L0901                       // If it matched pop the return address and return with A = Direction
        
        rts                             // If it didn't match return and check again

// $1917??
Decrement_Oxygen:                     // decrement the 4 digit Oxygen number on screen
        dec Screen_Oxygen_Count+3     // decrement the unit digit
        lda Screen_Oxygen_Count+3
        cmp #Char_0                   // Is the unit digit '0'?
        bcc !B0+                      // Yes so roll over to 9 and increment next digit
        bcs !B4+                      // No so exit

!B0:    lda #Char_9                   // Put a '9' in the unit digit of Oxygen on screen
        sta Screen_Oxygen_Count+3

        dec Screen_Oxygen_Count+2     // decrement the Ten's digit
        lda Screen_Oxygen_Count+2
        cmp #Char_0                   // Is the Ten's digit '0'?
        bcc !B1+
        bcs !B4+

!B1:    lda #Char_9                      // Put a '9' in the Ten's digit of Oxygen on screen
        sta Screen_Oxygen_Count+2

        dec Screen_Oxygen_Count+1     // decrement the Hundred's digit
        lda Screen_Oxygen_Count+1
        cmp #Char_0                   // Is the Hundred's digit '0'?
        bcc !B2+
        bcs !B4+

!B2:    lda #Char_9                   // Put a '9' in the Hundred's digit of Oxygen on screen
        sta Screen_Oxygen_Count+1

        dec Screen_Oxygen_Count       // decrement the Thousand's digit
        lda Screen_Oxygen_Count
        cmp #Char_0                   // Is the Thousand's digit '0'?
        bcc !B3+
        bcs !B4+

!B3:    lda #Char_9                  // Put a '9' in the Thousand's digit of Oxygen on screen
        sta Screen_Oxygen_Count

!B4:    ldx #$04                     // Has Oxygen reached '0000'? Check all 4 digits on the screen
!loop:  lda Screen_Oxygen_Count-1,X
        cmp #Char_0
        bne Still_Oxygen                    // Branch and return if any of the digits are not zero
        dex
        bne !loop-
                                     // If we're here Oxygen has run out and the player has lost a life
        jsr $150E
        
        inc Char_Y
          
        lda #Char_Alien_Dead            // Draw cross above dead alien??
        sta Char_To_Draw
        lda #$01
        sta Color_To_Draw
        jsr Draw_Char_On_Screen

        lda #$4D                      // $22 is used as to store the indirect address of something on the screen
        sta $22
        lda #$1B
        sta $23
        jsr $1A8C

        jmp $109C

Still_Oxygen:
        rts                      // Return because Oxygen hasn't reached '0000' yet


// $1986
Add_Score_For_Alien:    // how many floors or level of alien you killed?
        ldy $47
!Loop:  jsr $1995
        dey
        bne !Loop-

        lda #$00        // This code is repeated elsewhere, we could just jump to it??
        sta $48         // Zero the current alien level and score ready for the next alien killed
        sta $47         // Do we have to zero both of these, won't they just get over ridden?
        rts

// $1995
Add_Score:
        ldx $48         // Add the number in $48 to the score one digit at a time

!Loop:  jsr Increment_Score     // Increment the score by 1
        dex
        bne !Loop-
        rts

// increment the score
// $199E
Increment_Score:
        inc $1FE1         // Add 1 to score ??? digit
        lda $1FE1         // Check if it has reached 10 so we need to increment next digit
        cmp #Char_9+1
        beq !B0+
        rts

!B0:    lda #Char_0          // '0' the units? on screen
        sta $1FE1

        inc $1FE0         // increment the ten's?? on screen
        lda $1FE0         // Check if it has reached 10 so we need to increment next digit
        cmp #Char_9+1
        beq !B1+
        rts
//L09BB:
!B1:    lda #Char_0       // '0' the ten's?? on screen
        sta $1FE0

        inc $1FDF         // increment the hundred's?? on screen
        lda $1FDF         // Check if it has reached 10 so we need to increment next digit
        cmp #Char_9+1
        beq !B2+
        rts
//L09CB:
!B2:    lda #Char_0       // '0' the hundred's?? on screen
        sta $1FDF

        inc $1FDE         // increment the thousand's?? on screen
        rts

//
// Draw Floors on screen
// 
// Draw the floor characters on the screen and puts the right color behind the character
//
// $19D2
Draw_Floors:
        ldx #screen_width-1          // Draw 22 characters across screen - DEFINE CONstaNT ScreenWidth
!loop:  lda #Char_Floor              // Load floor character
        sta Screen_Line_03,X         // start drawing from left edge plus X and decrement until we hit the left edge
        sta Screen_Line_06,X
        sta Screen_Line_09,X
        sta Screen_Line_12,X
        sta Screen_Line_15,X
        sta Screen_Line_18,X
        sta Screen_Line_21,X
        lda #Color_Green             // Load floor color
        sta Color_Line_03,X          // start filling in color from left edge plus X and decrement until we hit the left edge
        sta Color_Line_06,X
        sta Color_Line_09,X
        sta Color_Line_12,X
        sta Color_Line_15,X
        sta Color_Line_18,X
        sta Color_Line_21,X
        dex
        bpl !loop-              // Branch back until we go negative meaning we've drawn all 16 characters of the floor across screen
        rts

// $1A06
Draw_Ladders:
        lda Current_Level       // Get the current level
        and #$03                // Isolate the lower two bits to make it an indec from 0-3
        clc                     // Clear so we don't rotate in a set carry flag
        asl                     // double to give us an index into the table
        tax                     // Move A to X to use as index
        lda Ladder_Layout_Lookup,X
        sta $22
        inx
        lda Ladder_Layout_Lookup,X
        sta $23

        ldy #$17                // all screens have 8 ladders                           Opportunity to make the number of ladders change by level
!B0:    lda ($22),Y             // Get the length of the ladder to draw
        sta $26
        dey
        lda ($22),Y             // Get the screen high address of the start of the ladder
        sta $25
        dey
        lda ($22),Y             // Get the screen low address of the start of the ladder
        sta $24
        tya                     // Save Y
        pha                     
        jsr Draw_Ladder
        pla                     // retrieve Y
        tay
        dey
        bpl !B0-                // Draw the next ladder
        rts

// $1A33
Draw_Ladder:
        lda $24               // Determine address in color map based on address in video
        sta $39
        lda $25
        clc
        adc #$78              // Adding $78 is offset from $1E00 start address of video memory to $9600 color memory
        sta $3A

        lda #Char_Ladder_Top    // Draw top of ladder??
        ldy #$00
        sta ($24),Y
        lda #Color_White
        sta ($39),Y

!loop:  jsr Next_Line_Down      // Move pointers down one line in video and color memory and draw bottom half of player
        
        lda #Char_Ladder_Main   // Draw Ladder character in white, takes advantage that character and color are both $1
        sta ($24),Y
        sta ($39),Y
        dec $26                 // Decrement length of ladder count and if unfinished loop and draw another ladder char
        lda $26                 // Do we have to load or does DEC set the zero flag??
        bne !loop-

        rts

// $1A58
Next_Line_Down:
          clc                   // Add Screen Width to low address in video memory to point to next line down
          lda #screen_width
          adc $24
          sta $24
          lda #$00              // Add carry flag if we went over $FF in low address
          adc $25
          sta $25

          clc                   // Add Screen Width to low address in color memory to point to next line down
          lda #screen_width
          adc $39
          sta $39
          lda #$00              // Add carry flag if we went over $FF in low address
          adc $3A
          sta $3A
          rts

// $1A73??
Draw_Game_Start_Message:
        lda #$21                // Set ($22) to point at text to start game
        sta $22
        lda #$1B
        sta $23
!loop:  jsr Draw_Message
        jsr Check_F7            // Check for 'F7' key to start game -- Could put the code in line and save a few bytes because it's only used once
        bcc !loop-              // No F7 so keep waiting and flashing message

        rts

// $1A84
Draw_Game_Over_Message:
        lda #$37                // Set ($22) to point at text GAME OVER
        sta $22
        lda #$1B
        sta $23

        ldx #$08               // Show text 8 times
!loop:  txa
        pha
        jsr Draw_Message        // Draw message that is pointed to by ($22)
        pla
        tax
        dex
        bne !loop-
        rts

//
// Draw Message across middle of screen while saving what is underneath
// e.g. GAME OVER, etc.
//

Draw_Message:
        ldy #screen_width-1     // Save the line of current characters on the screen
!loop:  lda Screen_Line_11,Y    // to the stack
        pha
        lda Color_Line_11,Y
        pha
        lda ($22),Y             // Draw the text in White on the screen
        sta Screen_Line_11,Y
        lda #Color_White
        sta Color_Line_11,Y
        dey
        bpl !loop-

        jsr $1D36               // Two delays
        jsr $1D36
          
        ldy #$00              // Pull the characters and color back off the stack and draw on screen
!loop:  pla
        sta Color_Line_11,Y
        pla
        sta Screen_Line_11,Y
        iny
        cpy #screen_width
L0AC5:  bne !loop-
        jsr $1D36
        rts

//
// Draw Character on Screen
//
// $2B  - Character to draw
// $2C  - Color of character to draw
// ($2D)- Indirect address on screen for character to appear
// 

// $1AC9
Draw_Char_On_Screen:
        jsr Get_Char_Screen_Adr
// $1ACC
        lda Char_To_Draw         // Get the character to draw in screen
        ldy #$00        // Suspect self-modifying code??
        sta (Char_Screen_Adr_Lo),Y
        clc
        lda #$78        // Add $78 to the high address address to get the address in color space
        adc Char_Screen_Adr_Hi
        sta Char_Screen_Adr_Hi
        lda Color_To_Draw         // Load the character color and draw in screen
        sta (Char_Screen_Adr_Lo),Y
        rts

//
// Get Character from Screen so that it can be drawn back when a character moves past, e.g. ladders
//
// $2B  - Character to draw
// $2C  - Color of character to draw
// ($2D)- Indirect address on screen for character to appear
// 
// $1ADE
Get_Char_From_Screen:
          jsr Get_Char_Screen_Adr       // Get the address in video memory of the character at X,Y

          ldy #$00                      // Get the character that will be in the background
          lda (Char_Screen_Adr_Lo),Y                   // Save it in $2B
          sta $2B
          clc
          lda #$78                      // Add $78 to the high address address to get the address in color space
          adc Char_Screen_Adr_Hi
          sta Char_Screen_Adr_Hi
          lda (Char_Screen_Adr_Lo),Y                   // Get the character color and save it
          sta Color_To_Draw
          rts

// Index to start of each screen line in memory - 23 lines

// $1AF3
Screen_Line_Address_Lo:
        .byte $00,$16,$2C,$42,$58,$6E,$84,$9A,$B0,$C6,$DC,$F2,$08,$1E,$34,$4A,$60,$76,$8C,$A2,$B8,$CE,$E4
// $1B0A
Screen_Line_Address_Hi:
        .byte $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F

//
// Could overlap the $00 at the ends of each screen to save memory
//

// $1B21
Text_Start_Msg:
// __TYPE_'F7'_TO_START__
        .byte $00,$00,$94,$99,$90,$85,$00,$A7,$86,$B7,$A7,$00,$94,$8F,$00,$93,$94,$81,$92,$94,$00,$00

// $1B37
Text_Game_Over_Msg:
// ______GAME__OVER______
        .byte $00,$00,$00,$00,$00,$00,$87,$81,$8D,$85,$00,$00,$8F,$96,$85,$92,$00,$00,$00,$00,$00,$00

// $1B4D
// _____OXYGEN_OUT_______
Text_Oxygen_Out:
        .byte $00,$00,$00,$00,$00,$8F,$98,$99,$87,$85,$8E,$00,$8F,$95,$94,$00,$00,$00,$00,$00,$00,$00

// $1B63
        .byte $00

// $1B64        // Alien level and score for each as they level up? Might also be color?
        .byte $00,$03,$02,$01

// Index to each entry in the level ladder layout

// $1B68
Ladder_Layout_Lookup:
        .byte $70,$1B
        .byte $88,$1B
        .byte $A0,$1B
        .byte $B8,$1B

// Screen address and line length for ladder

// $1B70
        .byte   $18,$1E,$03
        .byte   $9C,$1E,$03
        .byte   $20,$1F,$03
        .byte   $E4,$1E,$06
        .byte   $22,$1E,$06
        .byte   $2A,$1F,$06
        .byte   $AB,$1E,$03
        .byte   $2A,$1E,$12

// $1B88

        .byte   $17,$1E,$12
        .byte   $1C,$1E,$06
        .byte   $24,$1F,$03
        .byte   $6A,$1F,$03
        .byte   $23,$1E,$03
        .byte   $EE,$1E,$09
        .byte   $2A,$1E,$06
        .byte   $A4,$1E,$03

// $1BA0

        .byte   $18,$1E,$09
        .byte   $62,$1F,$03
        .byte   $A0,$1E,$03
        .byte   $20,$1E,$03
        .byte   $E7,$1E,$06
        .byte   $24,$1E,$12
        .byte   $69,$1E,$09
        .byte   $32,$1F,$06

// First screen in game?

// $1BB8

        .byte   $59,$1E,$03
        .byte   $1F,$1F,$06
        .byte   $1C,$1E,$12
        .byte   $A4,$1E,$06
        .byte   $25,$1E,$06
        .byte   $2D,$1F,$03
        .byte   $2A,$1E,$03
        .byte   $AD,$1E,$09

// Text for bottom of Screen including characters to show # of players left - Length must match
// _XXX_______SCORE000000
// OXYGEN2000__HIGH000000
// 
// $1BD0
        .byte $00,$0A,$0A,$0A,$00,$00,$00,$00,$00,$00,$00,$93,$83,$8F,$92,$85,$B0,$B0,$B0,$B0,$B0,$B0
        .byte $8F,$98,$99,$87,$85,$8E,$B2,$B0,$B0,$B0,$00,$00,$88,$89,$87,$88,$B0,$B0,$B0,$B0,$B0,$B0

// $1BFC

        .byte $11,$20
        .byte $DE,$1A

//
// Character Bitmap data
//
// Must fall at $1C00. VIC_Char_Mem register is set to find character map at $1C00

// A = 1010
// B = 1011
// C = 1100
// D = 1101
// E = 1110
// F = 1111

Char_Mem:
        .byte $00,$00,$00,$00,$00,$00,$00,$00   // 00 - Blank
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
        .byte $FF,$81,$FF,$81,$FF,$81,$FF,$81   // 01 - Ladder Main
//      11111111        [████████]
//      10000001        [█      █]
//      11111111        [████████]
//      10000001        [█      █]
//      11111111        [████████]
//      10000001        [█      █]
//      11111111        [████████]
//      10000001        [█      █]
        .byte $00,$00,$00,$81,$FF,$81,$FF,$81   // 02 - Ladder Top
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      10000001        [█      █]
//      11111111        [████████]
//      10000001        [█      █]
//      11111111        [████████]
//      10000001        [█      █]
        .byte $FB,$FB,$00,$DF,$DF,$00,$00,$00   // 03 - Floor
//      11111011        [█████ ██]
//      11111011        [█████ ██]
//      00000000        [        ]
//      11011111        [██ █████]
//      11011111        [██ █████]
//      00000000        [        ]
//      00000000        [        ]
        .byte $81,$E5,$00,$DF,$DF,$00,$00,$00   // 04 - Floor Dug 1
//      10000001        [█      █]
//      11100101        [███  █ █]
//      00000000        [        ]
//      11011111        [██ █████]
//      11011111        [██ █████]
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
        .byte $00,$C1,$00,$DF,$DF,$00,$00,$00   // 05 - Floor Dug 2
//      00000000        [        ]
//      11000001        [██     █]
//      00000000        [        ]
//      11011111        [██ █████]
//      11011111        [██ █████]
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
        .byte $00,$00,$00,$81,$DF,$00,$00,$00   // 06 - Floor Dug 3
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      10000001        [█      █]
//      11011111        [██ █████]
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
        .byte $00,$00,$00,$00,$83,$00,$00,$00   // 07 - Floor Dug 4
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      10000011        [█     ██]
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
        .byte $E6,$19,$3C,$5A,$81,$FF,$DD,$99   // 08 Alien Frame 0
//      11100110        [███  ██ ]
//      00011001        [   ██  █]
//      00111100        [  ████  ]
//      01011010        [ █ ██ █ ]
//      10000001        [█      █]
//      11111111        [████████]
//      11011101        [██ ███ █]
//      10011001        [█  ██  █]
        .byte $67,$98,$3C,$5A,$A5,$FF,$BB,$99   // 09 Alien Frame 1
//      01100111        [ ██  ███]
//      10011000        [█  ██   ]
//      00111100        [  ████  ]
//      01011010        [ █ ██ █ ]
//      10100101        [█ █  █ █]
//      11111111        [████████]
//      10111011        [█ ███ ██]
//      10011001        [█  ██  █]
        .byte $99,$5A,$3C,$18,$18,$24,$24,$24   // 0A Player Life Counter
//      10011001        [█  ██  █]
//      01011010        [ █ ██ █ ]
//      00111100        [  ████  ]
//      00011000        [   ██   ]
//      00100100        [  █  █  ]
//      00100100        [  █  █  ]
//      00100100        [  █  █  ]
//      00100100        [  █  █  ]
        .byte $00,$00,$00,$00,$60,$F0,$F0,$60   // 0B Player Shovel Right Top 0
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      01100000        [ ██     ]
//      11110000        [████    ]
//      11110000        [████    ]
//      01100000        [ ██     ]
        .byte $F0,$F8,$68,$64,$94,$96,$93,$D3   // 0C Player Shovel Right Bottom 0
//      11110000        [████    ]
//      11111000        [█████   ]
//      01101000        [ ██ █   ]
//      01100100        [ ██  █  ]
//      10010100        [█  █ █  ]
//      10010110        [█  █ ██ ]
//      10010011        [█  █  ██]
//      11010011        [██ █  ██]
        .byte $00,$00,$00,$00,$06,$0F,$0F,$06   // 0D Player Shovel Left Top 0
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      00000110        [     ██ ]
//      00001111        [    ████]
//      00001111        [    ████]
//      00000110        [     ██ ]
        .byte $0F,$1F,$16,$26,$29,$69,$C9,$DB   // 0E Player Shovel Left Bottom 0
//      00001111        [    ████]
//      00011111        [   █████]
//      00010110        [   █ ██ ]
//      00100110        [  █  ██ ]
//      00101001        [  █ █  █]
//      01101001        [ ██ █  █]
//      11001001        [██  █  █]
//      11011011        [██ ██ ██]
        .byte $00,$00,$03,$03,$66,$F4,$F4,$68   // 0F Player Shovel Right Top 0
//      00000000        [        ]
//      00000000        [        ]
//      00000011        [      ██]
//      00000011        [      ██]
//      01100110        [ ██  ██ ]
//      11110100        [████ █  ]
//      11110100        [████ █  ]
//      01101000        [ ██ █   ]
        .byte $F8,$F0,$60,$60,$90,$90,$90,$D8   // 10 Player Shovel Right Bottom 0
//      11111000        [█████   ]
//      11110000        [████    ]
//      01100000        [ ██     ]
//      01100000        [ ██     ]
//      10010000        [█  █    ]
//      10010000        [█  █    ]
//      10010000        [█  █    ]
//      11011000        [██ ██   ]
        .byte $00,$00,$C0,$C0,$66,$2F,$2F,$16   // 11 Player Shovel Left Top 1
//      00000000        [        ]
//      00000000        [        ]
//      01100000        [ ██     ]
//      01100000        [ ██     ]
//      01100110        [ ██  ██ ]
//      00101111        [ █  ████]
//      00101111        [ █  ████]
//      00010110        [ █   ██ ]
        .byte $1F,$0F,$06,$06,$09,$09,$09,$1B   // 12 Player Shovel Left Bottom 1
//      00011111        [   █████]
//      00001111        [    ████]
//      00000110        [     ██ ]
//      00000110        [     ██ ]
//      00001001        [    █  █]
//      00001001        [    █  █]
//      00001001        [    █  █]
//      00010111        [   █ ███]
        .byte $00,$00,$00,$00,$18,$3C,$3C,$98   // 13 Player Climb Top 0
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      10001000        [█   █   ]
//      00111100        [  ████  ]
//      00111100        [  ████  ]
//      10011000        [█  ██   ]
        .byte $FF,$19,$18,$18,$64,$44,$C4,$06   // 14 Player Climb Bottom 0
//      11111111        [████████]
//      00011001        [   ██  █]
//      00011000        [   ██   ]
//      00011000        [   ██   ]
//      01100100        [ ██  █  ]
//      01000100        [ █   █  ]
//      11000100        [██   █  ]
//      00000110        [     ██ ]
        .byte $00,$00,$00,$00,$18,$3C,$3C,$19   // 15 Player Climb Top 1
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      00011000        [   ██   ]
//      00111100        [  ████  ]
//      00111100        [  ████  ]
//      00011001        [   ██  █]
        .byte $FF,$98,$18,$18,$26,$22,$23,$60   // 16 Player Climb Bottom 1
//      11111111        [████████]
//      10011000        [█  ██   ]
//      00011000        [   ██   ]
//      00011000        [   ██   ]
//      00100110        [  █  ██ ]
//      00100010        [  █   █ ]
//      00100011        [  █   ██]
//      01100000        [ █     ]
        .byte $FF,$19,$18,$18,$24,$27,$21,$60   // 17 Player Run Left Bottom 0
//      11111111        [████████]
//      00011001        [   ██  █]
//      00011000        [   ██   ]
//      00011000        [   ██   ]
//      00100100        [  █  █  ]
//      00100111        [  █  ███]
//      00100001        [  █    █]
//      01100000        [ ██     ]
        .byte $00,$00,$00,$00,$18,$3C,$3C,$18   // 18 Player Run Top 0
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      00011000        [   ██   ]
//      00111100        [  ████  ]
//      00111100        [  ████  ]
//      00011000        [   ██   ]
        .byte $AC,$5A,$1C,$18,$64,$44,$C4,$0C   // 19 Player Run Left Bottom 1
//      10101100        [█ █ ██  ]
//      01011010        [ █ ██ █ ]
//      00011100        [   ███  ]
//      00011000        [   ██   ]
//      01100100        [ ██  █  ]
//      01000100        [ █   █  ]
//      11000100        [██   █  ]
//      00001100        [    ██  ]
        .byte $FF,$98,$18,$18,$24,$E4,$84,$06   // 1A Player Run Right Bottom 0
//      11111111        [████████]
//      10011000        [█  ██   ]
//      00011000        [   ██   ]
//      00011000        [   ██   ]
//      00100100        [  █  █  ]
//      11100100        [███  █  ]
//      10000100        [█    █  ]
//      00000110        [     ██ ]
        .byte $3D,$5A,$38,$18,$26,$22,$23,$30   // 1B Player Run Right Bottom 1
//      00111101        [  ████ █]
//      01011010        [ █ ██ █ ]
//      00111000        [  ███   ]
//      00011000        [   ██   ]
//      00100110        [  █  ██ ]
//      00100010        [  █   █ ]
//      00100011        [  █   ██]
//      00110000        [  ██    ]
        .byte $00,$00,$00,$66,$99,$3C,$5A,$A5   // 1C Alien in Hole
//      00000000        [        ]
//      00000000        [        ]
//      00000000        [        ]
//      01100110        [ ██  ██ ]
//      10011001        [█  ██  █]
//      00111100        [  ████  ]
//      01011010        [ █ ██ █ ]
//      10100101        [█ █  █ █]
        .byte $18,$18,$FF,$18,$18,$18,$18,$18   // 1D Alien Dead
//      00011000        [   ██   ]
//      00011000        [   ██   ]
//      11111111        [████████]
//      00011000        [   ██   ]
//      00011000        [   ██   ]
//      00011000        [   ██   ]
//      00011000        [   ██   ]
//      00011000        [   ██   ]

// Memory $1CF4
                        // Call Membot - Set the bottom of memory to $1000
          ldx #$00      // X = Lower half of address $00
          ldy #$10      // Y = Lower half of address $10
          clc           // Clear carry to tell Membot to set bottom of memory
          jsr $FF9C     // Call Membot

                        // Call SETLFS
          ldx #$01      // Set for device #1 - Tape
          jsr $FFBA

                        // Set file name
          lda #$00      // Set file name length to zero
          jsr $FFBD     // Call SETNAM

                        // Save memory to tape?
          ldx #$00      // X = Lower half of address $00
          ldy #$1E      // Y = Lower half of address $1E
          lda #$2B
          jsr $FFD8     // Call SAVE

          brk
//
// Compare Score to High Score
//
// Compare each digit
//
// $1D0C
Comp_High_Score:
                ldx #$01
!loop:          lda Screen_Score,X
                cmp Screen_High_Score,X
                beq !B0+
                bcc Not_Hi_Score                // Lower so exit
                bcs Got_Hi_Score                // Higher so branch to copy score to high score
!B0:            inx
                cpx #$07                        // Have we compared all 6 digits of the score?
                bne !loop-                      // Not done, check the next digit
        
Got_Hi_Score:   ldx #$06                // It was a new high score so copy score to high score text
!loop:          lda Screen_Score,X
                sta Screen_High_Score,X
                dex
                bne !loop-
Not_Hi_Score:   rts

//
// Delay for X loops with X in $21
//
// $1D2B                        // It's not clear if this is ever called??
Delay_By_Var:
        ldx $21
// L0D2F:
// $1D2D
Delay_By_X:                     // Delay by looping based on the value in X
!loop0:
        ldy #$FF
!loop1: dey
        bne !loop1-
        dex
        bne !loop0-
        rts

//
// Safe Delay - Call the delay subroutine but only after saving X & Y to the stack and the retrieving
//
Safe_Delay:
          txa
          pha
          tya
          pha
          ldx #$FF
          jsr Delay_By_X
          pla
          tay
          pla
          tax
          rts

//
// Clear the screen and color memory
//
Clear_Screen:   ldx #$00
!loop:          lda #Color_White
                sta Color_Start,X
                sta Color_Start+$100,X
                lda #Char_Blank
                sta Screen_Start,X
                sta Screen_Start+$100,X
                dex
                bne !loop-
                rts

//
// Check_Below - Get the Character that is below the character at Char_X, Char_Y and return in A
//

// $1D5A
Check_Below:
        inc Char_Y                      // Increment Y
        jsr Get_Char_From_Screen        // Get the character
        dec Char_Y                      // Decrement Y to return to prior value
        lda Char_To_Draw                //Get the character below the Y
        rts

//
// Check for F7 key??
//
// $1D64
Check_F7:
        lda VIC_VIA_1_Port_A            // Check fire button on joystick??
        and #$20                        // If pressed branch and return with carry set to start game
        beq !B0+

        lda #$7F                        // 0b01111111 Select the column
        sta VIC_VIA_2_Key_Col_Scan
        lda VIC_VIA_2_Key_Row_Scan                      // Read the keyboard row
        and #$80                        // to check for 'F7'
        bne !B1+
// $1D79??
!B0:    sec                        // Return with carry set to start game
        rts
// $1D7B??
!B1:    clc                        // Return with carry clear 'F7' or joystick fire button where not pressed
        rts

//
// Get_Char_Screen_Adr
//
// $29  - X co-ord of character
// $2A  - Y co-ord of character
// ($2D)- Screen address created based on character X and Y
//
// $1D7B
Get_Char_Screen_Adr:
        ldy Char_Y                         // Get Y co-ordinate as line number of character on screen
        lda Screen_Line_Address_Lo,Y    // Look up the lower and upper address of end of line from table and create index at $2D
        sta Char_Screen_Adr_Lo
        lda Screen_Line_Address_Hi,Y
        sta Char_Screen_Adr_Hi
        clc                             // Add X co-ordinate from Char_X ($29) to address at ($2D)
        lda Char_X
        adc Char_Screen_Adr_Lo
        sta Char_Screen_Adr_Lo
        lda #$00                        // Add carry flag if High Byte of address went over $FF
        adc Char_Screen_Adr_Hi
        sta Char_Screen_Adr_Hi
        rts

//$1D95
        ldx #$80
        jsr Delay_By_X
        rts

// $1D9B
Clear_Dashboard:
        ldx #(screen_width*2)-1  // 43 ($22) Two x Screen Width - 1 because we're counting 0
!loop:  lda #Color_White
        sta Color_Line_22,X
        lda #$00
        sta Screen_Line_22,X
        dex
        bpl !loop-

// Copy text into bottom two lines of screen
        ldx #$2B                // Two x Screen Width?
!loop:  lda $1BD0,X
        sta Screen_Line_22,X
        dex
        bpl !loop-

        rts

// Draw Floor Character - fill in a hole after an alien was killed ??
// $1DB6
Draw_Fill_Hole:
        lda #Char_Floor
        sta $2B
        lda #Color_Green
        sta Color_To_Draw
        jsr Draw_Char_On_Screen         // Draw Floor
        rts

// $1DC2
Alien_Fall:
        inc Char_Y                      // +1 Y ??
        lda #Char_Alien_0               // Alien animation frame 0
        sta Char_To_Draw                // Store in Char to draw
        lda $42                         // Get Alien Color
        sta Color_To_Draw               // Store in Char color to draw
        jsr Draw_Char_On_Screen         // Draw alien
        jmp $1D95                       // Return after delay

//
// Have the aliens found the player - Carry is clear if no collision and set if collision
//
// $1DD2
Chk_Alien_Impact:
                ldx #$01                // X indexes though alien database
!loop:          lda Alien_Data,X        // Get the Alien X and compare it with the Current character X??
                cmp Char_X
                beq Match_X             // Branch if X is equal
                inx                     // +4 to index to get to next Alien data
Chck_Nxt_Alien:inx
                inx
                inx
                cpx #$E0                // Have we checked all the aliens $E0/4 = $38 - not clear why that is the upper limit??
                bcc !loop-
                clc                     // No collision so return clear
                rts

// $1DE7:  
Match_X:        inx                     // Move to Y co-ordinate entry and compare with Alien Y with Player Y
                lda Alien_Data,X
                cmp Char_Y
                bne Chck_Nxt_Alien      // If not at Player Y check next Alien
                sec                     // Collision so return carry set
                rts

// $1DF1
Volume_Silence:
        lda #$00                        // Set volume to 0
        sta VIC_OSC_1_FREQ
        rts

// $1DF7
        .byte $01,$04,$07,$0A,$0D,$10,$13,$A5,$30,$29,$01

//
// MUST END BEFORE $1E00 which is the start of the screen RAM
//

//          .END
