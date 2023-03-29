//
// Vic Panic - Original copyright (c) 1982 Bug Byte Software - Written by Eugene Evans - Disassembled from .tap file of original 2023

// It's hard to say where the ownership of this game currently sits. I was an employee of Bug Byte. The company no longer exists.
// I'm unaware of any of the assets being acquired. In addition this game was a copy of a popular arcade game "Space Panic".
// As a result I'm comfortable posting this source code which I created by disassembling the object code from a tap file which someone else
// had captured and made available online

// Versions

// 2023-03-11 Posted first build
//      Full disassembly is not complete. Some tables and data is still hard coded which means if you change the code you make break the game.
//      My goal is to complete the disassembly so that the game is ready to be changed. I hope to then make some improvements
//      while staying true to being a game for the unexpanded original 4K Vic 20

// 2023-03-28 Completed disassembly
//      Full disassembly complete. All subroutines and jumps labeled so that the code can be modified and it will assemble and run. Removed some data that was superfluous
//      from the original disassembly. All data is labeled and turned into a more readable form. Still work to do to make some labels make more sense and still don't have
//      100% of idea of how all code works. Found at least one bug and odd code (amazing it ever made sense). Plan to start making improvements.

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
//                   Bit 2=Joy 0        %00000100 / 0x04 / Up
//                   Bit 3=Joy 1        %00001000 / 0x08 / Down
//                   Bit 4=Joy 2        %00010000 / 0x10 / Left
//                   Bit 5=Fire button  %00100000 / 0x20 / Fire
        .var Joystick_Up_Bit = $04      // Read from port $911F
        .var Joystick_Down_Bit = $08    // Read from port $911F
        .var Joystick_Left_Bit = $10    // Read from port $911F
        .var Joystick_Right_Bit = $80   // Read from port $9120
        .var Joystick_Fire_Bit = $20    // Read from port $911F

        .var VIC_VIA_1_DDR_B = $9112
        .var VIC_VIA_1_DDR_A = $9113
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
        .var VIC_VIA_2_DDR_A = $9123
//                   Bit 7 = Joy 3      %00000010 / 0x20 / Fire?
        .var VIC_VIA_2_Int_Enable = $912E

// VIC20 Keyboard Matrix

// Write to Port B($9120)column - 0 bit selects column to read - write a $7F (%01111111) here and then read $9121 ad check the high order bit to read F7
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
//  // [        SPACE BAR       ]

//
//  Game Constants
//
        .var screen_width = $16  // 22 characters across ($16)
        .var screen_height = $17 // 23 characters high ($17)

        .var initial_player_x = $0B
        .var initial_player_y = $12

        .var Init_Alien_X_Pos = $2
        .var Init_Alien_Y_Pos = $0

        .var Alien_Kill_Hits = $6

        .var Player_Move_Up = 0
        .var Player_Move_Right = 1
        .var Player_Move_Down = 2
        .var Player_Move_Left = 3

        .var Alien_Up = $00
        .var Alien_Right = $04
        .var Alien_Left = $08
        .var Alien_Down = $0C

        .var Start_Level = 2
        .var Init_Player_Lives = 3      // Also the initial number of Aliens

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
        .var Delay_Amount = $21         // Save a delay size here and call Delay_By_Var but it's not clear that this is ever used. Might be able to delete???
        .var Init_Alien_X = $22         // Shared location, always dangerous
        .var Init_Alien_Y = $23         // Shared location, always dangerous
        .var Temp_Index_Lo = $22        // Used as a indirect address low byte for indexing into tables, strings or lists
        .var Temp_Index_Hi = $23        // 
        .var Ladder_Start_Lo_Addr = $24 // Used when drawing ladders. Lo/Hi pointer to the video memory start of the ladder on screen
        .var Ladder_Start_Hi_Addr = $25
        .var Ladder_Length = $26        // Used when drawing ladders
        .var Current_Level = $27        // The current level in the game
        .var Num_of_Aliens_Level = $28  // This seems to be the number of aliens for each level
        .var Char_X = $29               // Character X Co-ordinate
        .var Char_Y = $2A               // Character Y Co-ordinate
        .var Char_To_Draw = $2B         // Character to Draw
        .var Color_To_Draw = $2C        // Character Color to Draw
        .var Char_Screen_Adr_Lo = $2D   // Lo/Hi Indirect Address in video memory of Char at Char_X,Char_Y
        .var Char_Screen_Adr_Hi = $2E

        .var Aliens_Live_Count = $2F    // Number of active aliens on screen
        .var Alien_Anim_Frame = $30     // What frame of animation are we showing for alien? This gets incremented and then the lowest bit used to alternate between two frames
        .var Curr_Alien = $31           // Current Alien that we're processing
        .var Curr_Alien_Color = $32
        .var Curr_Alien_X = $33         // Current Alien X,Y location on screen
        .var Curr_Alien_Y = $34         // Might be Alien color and have $32, $33, $34 wrong
// Unknown_20 = $35
// Unknown_21 = $36
        .var Curr_Alien_Status = $37            // Status of current alien which includes embedded direction
        .var Current_Alien_Direction = $38      // Direction of Alien we're currently processing
        .var Ladder_Start_Col_Lo_Addr = $39
        .var Ladder_Start_Col_Hi_Addr = $3A

        .var Alien_X = $3A                     // Alien Screen X Co-ordinate
        .var Alien_Y = $3B                     // Alien Screen Y Co-ordinate

        .var Player_X = $3A                     // Initial Player X Co-ordinate
        .var Player_Y = $3B                     // Initial Player Y Co-ordinate
        .var Player_Top_Under_Char = $3C
        .var Player_Bot_Under_Char = $3D
        .var Player_Top_Under_Col = $3E
        .var Player_Bot_Under_Col = $3F
        .var Player_Lives_Left = $40
        .var Alien_Hits= $41
        .var Killed_Alien_Level = $42                    // X coord of the Alien we're currently processing
// Unknown_31 = $43
        .var Num_Live_Aliens = $44              // Number of aliens on screen
        .var Dead_Alien_Level = $45
        .var Num_Alien_Hit = $46                // Save the number of the alien that was hit
        .var Current_Alien_Flr_Fall = $47       // Level for alien you killed??
        .var Current_Alien_Level = $48          // Level for the Alien we're currently processing, if an alien survives going in a level it goes up a level and changes color

// Table of Data for Aliens

        .var Alien_Data = $033B         //$33B to $3FF is available RAM not used when a game is running (Vic 20 Cassette buffer) - How much are we using and
                                        //what is upper limit? There are $C4 bytes and somewhere in the code we test for $C1. There might be some free space for code???
        //      X
        //      Y
        //      Color = Upper Nibble / Direction = Lower Nibble
        //      Alien Status
                //      %10000000      - Bit 7 ??
                //      %01000000      - Bit 6 ??
        
// Screen Addresses used for drawing on screen - Screen is 22 ($16) characters across by 23 ($17) down

        .var Lowest_Flr = $14           // The Char_Y of the lowest floor on the screen - line 20

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

        * = $1000 "Main Program"                   // Assemble starting at $1000 

//       .byte $00           // 00 - no name?
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
        sta VIC_SCREEN_COLORS   // %00001000 = Black Border, Black Background and Normal Mode (note inverted)

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
        sta VIC_VIA_1_DDR_A     // Data Direction Register in VIA #1
        sta VIC_VIA_2_DDR_A     // Data Direction Register in VIA #1
        sta VIC_OSC_1_FREQ     // Frequency for oscillator 1
        sta VIC_OSC_2_FREQ     // Frequency for oscillator 2
        sta VIC_OSC_3_FREQ     // Frequency for oscillator 3
        sta VIC_NOISE       // Frequency of noise source

        sta Alien_Anim_Frame    // Start with frame 0 for alien animation

Start_New_Game:
        lda #Start_Level                        // Set the first level number
        sta Current_Level
        
Another_New_Game:
        lda #Init_Player_Lives                        // Player starts game with 3 players - Is there a bonus player, could add this to the game at a certain number of points??
        sta Player_Lives_Left
        sta Num_of_Aliens_Level

        tax                             // Refresh the player lives characters by painting them white - Might have felt smart at the time but may as well as put the character there
        lda #Color_White
!loop:  sta Color_Line_22,X             // Set color of line 22 on screen
        dex
        bne !loop-

        lda #Char_0                     // Character 0
        ldx #$06
!loop:  sta Screen_Score,X              // Put 6 "0"'s across screen for SCORE
        dex
        bne !loop-

//
// New Game - Jump here after a game over
//
New_Game:
        lda #Char_2                     // Reset Oxygen on screen to 2000
        sta Screen_Oxygen_Count
        lda #Char_0                     // Could this be a short loop, would it be fewer bytes???
        sta Screen_Oxygen_Count+1
        sta Screen_Oxygen_Count+2
        sta Screen_Oxygen_Count+3

        inc Num_of_Aliens_Level         // Not sure why we increment here instead of with each level?? - This starts at 3 but because we increment and only look at the lower 2 bits it starts the game at 0
        inc Current_Level               // Increment the level count

        lda #$00
        sta Current_Alien_Level         // Zero the level of alien you'll kill
        sta Current_Alien_Flr_Fall      // Zero the score for the alien you'll kill
        sta Alien_Hits                  // Zero the number of hits or how long the alien has been in hole??

        jsr Draw_Floors
        jsr Draw_Ladders
        jsr Draw_Aliens
        jsr Initial_Draw_Player

        lda Num_of_Aliens_Level
        sta Num_Live_Aliens
        cmp #$04
        bne Main_Loop                   // We haven't run out of lives yet so keep playing

        jsr Draw_Game_Start_Message     // Draw either Press 'F7' to Start Game message to start game?? Loops until pressed

        jmp Main_Loop                   // Start the game

Lose_Life:
        ldy Player_Lives_Left           // Decrement number of lives
        dey
        sty Player_Lives_Left
        beq Out_Of_Lives                // Branch if 0, the player is out of lives

        lda #Color_Black                // Leave the Player symbol on screen but make it black so it disappears - just too dumb to be clever!
        sta Color_Line_22+1,Y

        jmp Game_Over

Out_Of_Lives:
        jsr Comp_High_Score             // Check for new high score $1D0C
        jsr Draw_Game_Over_Message
        jsr Clear_Main_Screen

        jmp Another_New_Game

End_Alien_Loop:
        jsr Draw_an_Alien

        ldx Curr_Alien
        lda Alien_X
        sta Alien_Data,X
        inx
        lda Alien_Y
        sta Alien_Data,X
        
        ldy #$0F

!loop:  tya                             // Save index into alien data
        pha

        jsr Draw_Alien

        inc Alien_Anim_Frame            // Increment to alternate to next frame of alien animation

        jsr Safe_Delay                  // Delay

        pla                             // Retrieve index into alien data
        tay
        dey
        bne !loop-
        
        jmp Lose_Life

Main_Loop:
        jsr Move_Aliens                 // Move all the aliens
        jsr Move_Player                 // Move the player??
        jsr Decrement_Oxygen            // Decrement the Oxygen Counter??

        jmp Main_Loop

Move_Aliens:
        lda Num_of_Aliens_Level         // Get the current level number and x4 to use as index
        clc
        asl
        asl
        sta Aliens_Live_Count

        ldx #$01                        // Start processing aliens from the first one
!loop:  stx Curr_Alien

        jsr Draw_an_Alien               // Draw_Alien??
        jsr Process_Alien               // We only call this here so we could put the code inline??
        jsr Get_Alien_Data
        jsr Draw_Alien

        inx                             // Inc to look at next Alien and compare with the number of Aliens on screen
        cpx Aliens_Live_Count
        bcc !loop-

        inc Alien_Anim_Frame            // Increment to alternate to next frame of alien animation

        ldx #$A0
        jsr Delay_By_X
        rts

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
        bne Handle_Move_Player  // There is something else under the player so don't fall

// There was nothing under the character so make them fall??
!B0:    jsr Draw_Player         // Draw the Player
        inc Char_Y              // Move the player down one character

        jsr Get_Chars_Under_Player

        lda VIC_OSC_3_FREQ      // Read frequency of Oscilllator 3
        bne !B1+

        lda #$80
        sta VIC_OSC_3_FREQ      // Set frequency of Oscilllator 3

!B1:    lda #$02
        adc VIC_OSC_3_FREQ      // Add to frequency of Oscilllator 3
        sta VIC_OSC_3_FREQ      // Set frequency of Oscilllator 3

        jmp Draw_Player_Falling                //$13F3

//
// ??
//

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
        jmp Handle_Move_Right

!B2:    cmp #Player_Move_Down   // If not Down check next direction
        bne !B3+
        jmp Handle_Move_Down

!B3:    cmp #Player_Move_Left   // If not Left check return
        bne !B4+                // Could branch to another RTS and save a byte??
        jmp Handle_Move_Left

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

        jsr Check_Alien_Collision

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
        bne !B2+

        lda #Char_Blank
        sta Char_To_Draw
!B2:    jsr Draw_Char_On_Screen


Player_No_Move:                         // Branch to here and return if the player actually isn't going to move. Edge of screen, top of ladder, etc.
        rts

Climb_Ladder_Up:
        jsr Get_Char_From_Screen        // Get what is on screen under the player

        lda Char_To_Draw                   // If the player is on the ladder
        cmp #Player_Climb_Top_0
        bne !B1+
        jsr Check_Below
        cmp #Player_Climb_Bot_0
        bne !B1+

!B0:    lda #Player_Climb_Top_1
        sta Char_To_Draw
        jsr Draw_Char_On_Screen

Draw_Lower_Player:
        inc Char_To_Draw
        inc Char_Y

Draw_Lower_Player_2:
        jsr Draw_Char_On_Screen
        dec Char_Y
        rts

!B1:    jsr Get_Char_From_Screen

        lda Char_To_Draw
        cmp #Player_Climb_Top_1
        bne !B0-

        jsr Check_Below
        cmp #Player_Climb_Bot_1
        bne !B0-
        
        dec Char_Y
        jsr Check_Player_Position
        
        inc Char_Y
        jsr Draw_Player
        
        dec Char_Y
        jsr Get_Chars_Under_Player
        
        lda #Color_White
        sta Color_To_Draw
        lda #Player_Climb_Top_0
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        jmp Draw_Lower_Player

Handle_Move_Right:
        jsr Get_Char_From_Screen

        lda Char_To_Draw
        cmp #Player_Climb_Top_1
        bne !B0+
        jsr Check_Below
        cmp #Char_Player_Leg_0
        bne !B0+

!loop:  lda #Player_Run_Top_0           // Draw player body upper character
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        inc Char_Y                      // Move down a character and draw player body lower character
        lda #Char_Player_Leg_1
        sta Char_To_Draw
        jmp Draw_Lower_Player_2

!B0:
        jsr Get_Char_From_Screen
        
        lda Char_To_Draw
        cmp #Player_Run_Top_0
        bne !loop-
        
        jsr Check_Below
        cmp #Char_Player_Leg_1
        bne !loop-
        
        inc Char_X
        jsr Check_Player_Position

        dec Char_X
        jsr Draw_Player
        
        inc Char_X
        jsr Get_Chars_Under_Player

        lda #Color_White
        sta Color_To_Draw
        lda #Player_Climb_Top_1         // 
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        inc Char_Y
        lda #Char_Player_Leg_0          //
        sta Char_To_Draw
        jmp Draw_Lower_Player_2

Player_on_Ladder:
        jmp Player_Climb                // Jump because otherwise the branch is too far away

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

Player_Not_Moving:
        rts

Climb_Ladder_Down:
        jsr Check_Alien_Collision

// Potential Bug
        lda Get_Chars_Under_Player      // Crazy but in the original this was a LDA Get_Chars_Under_Player, how that ever worked I don't know
        cmp #Char_Ladder_Top            // Is the player on the top of a ladder
        beq Player_Not_Moving           // If yes, make the player walk down the ladder.
        
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
        bne Fill_Hole

!B0:    inc Char_X                      // The player is digging to the right but check if he's digging off the right of the screen
        lda Char_X                      // Are we at the right of the screen?
        cmp #screen_width
        beq Player_Not_Moving           // If player is at right of screen return without moving/digging

Fill_Hole:
        jsr Get_Char_From_Screen        // Get the character on the screen that the player was digging
        dec Char_To_Draw                // Subtract one to fill in the hole

        lda Char_To_Draw                // If it's $00 then Player was digging a ladder so return without the player moving
        beq Player_Not_Moving

        cmp #Char_Alien_1-1             // We decremented the character so check for the character minus 1
        beq Hit_Alien                   // Branch to handle hitting an alien
        cmp #Char_Alien_0-1
        beq Hit_Alien

        cmp #$FF                        // If it went negative we hit an empty hole
        beq !B0+

        cmp #Char_Floor-1
        beq Player_Not_Moving

        jsr Draw_Char_On_Screen
        rts

!B0:    lda #Char_Floor_Dug_4
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        rts

Hit_Alien:
        inc Alien_Hits                  // +1 the number of times the Alien has been hit. If it's more than 6 kill the alien
        lda Alien_Hits
        cmp #Alien_Kill_Hits            // Have we hit it enough to kill the Alien
        bcs !B0+
        rts

!B0:    jsr Chk_Alien_Impact
        bcs Alien_Collided              // Carry set if collission
        rts

Alien_Collided:
        dex                             // X is the index to the Alien that collided, save to scratch
        stx Num_Alien_Hit
        inx                             // Increment to point at the status byte of the aliens data
        inx
        inx
        lda Alien_Data,X                // Get the status and zero out everything other than the bottom two bit %00000011
        and #$03
        sta Killed_Alien_Level            // Save the Aliens new status - might be color but also level to determine points??
        tay
        lda Alien_Level,Y               // Use the level to look up the color for the Alien
        sta Dead_Alien_Level
        sta Current_Alien_Level

        lda #$00                        // Reset the count of the number of times the alien has been hit
        sta Alien_Hits

Now_Fill_Hole:
        jsr Draw_Fill_Hole              // Fill the hole the Alien was in. This is only called once could be in line code ??? $1DB6

        inc Current_Alien_Flr_Fall
        jsr Alien_Fall
        dec Dead_Alien_Level

        lda #Char_Blank                 // Draw blank character
        sta Char_To_Draw
        lda #Color_White
        sta Color_To_Draw
        jsr Draw_Char_On_Screen

        jsr Check_Below

        lda Char_To_Draw
        sta Curr_Alien_X
        lda Color_To_Draw
        sta Curr_Alien_Y
        jsr Alien_Fall

        jsr Check_Below                 // Check if there is floor under the Alien
        cmp #Char_Floor
        bcc !B0+
        cmp #Char_Floor_Dug_4+1
        bcc !B1+

!B0:    cmp #Char_Ladder_Main
        beq !B1+

        lda Curr_Alien_X
        sta Char_To_Draw
        lda Curr_Alien_Y                // This might not be right label for $34, why are we putting Y co-ord in Color_To_Draw???
        sta Color_To_Draw
        jsr Draw_Char_On_Screen

        jsr Alien_Fall
        
        jmp Now_Fill_Hole

!B1:    lda Dead_Alien_Level
        beq !B2+
        cmp #$0F
        bcs !B2+

        ldx Num_Alien_Hit
        lda Char_X
        sta Alien_Data,X

        inx
        lda Char_Y
        sta Alien_Data,X

        inx
        lda Curr_Alien_Y                 // Get Alien X or color???
        clc
        asl                             // Move into upper half of Alien status??
        asl
        asl
        asl
        sta Alien_Data,X

        lda Curr_Alien_X                // Get the current alien status
        and #$0F                        // Clear the upper nibble of the byte
        ora Alien_Data,X                // Or with the curent alien status in table and save to table
        sta Alien_Data,X
        
        inx                             // Get the Alien status
        lda Alien_Data,X        
        and #$9F                        // Clear bit 6 and 5 and the set bit 6, but what are they??
        ora #$40
        sta Alien_Data,X

        lda #$00
        sta Current_Alien_Level         // Zero the current alien level and score ready for the next alien killed
        sta Current_Alien_Flr_Fall      // Do we have to zero both of these, won't they just get over ridden?
        rts

!B2:    lda #Char_Alien_In_Hole         // Draw Alien in Hole??
        sta Char_To_Draw
        lda Killed_Alien_Level
        sta Color_To_Draw
        jsr Draw_Char_On_Screen

        jsr Safe_Delay                  // Delay

        lda Curr_Alien_X
        sta Char_To_Draw
        lda Curr_Alien_Y                // Alien color or Y co-ord??? $34 might be mis-labeled
        sta Color_To_Draw
        jsr Draw_Char_On_Screen

        ldx Num_Alien_Hit
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

Game_Over:
!B0:    jsr Clear_Main_Screen
        jmp New_Game              // Game over start a new game $1066

// Clear Main Screen - Clear the screen but not the two lines of dashboard
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

Player_Climb:
        jsr Get_Char_From_Screen

        lda Char_To_Draw                // Get the character that was retreived from the screen
        cmp #Player_Climb_Top_0         // Are we showing the first frame of climbing for the players upper body?
        bne !B1+                        // If not then check for the other frame and move the player

        jsr Check_Below                 // Check the lower half of the player animation
        cmp #Player_Climb_Bot_0         // Are we showing the first frame of climbing for the players upper body?
        bne !B1+                        // If not then check for the other frame and move the player

Draw_Player_Falling:                    // ??
!B0:    lda #Player_Climb_Top_1
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        jmp Draw_Lower_Player

!B1:    jsr Get_Char_From_Screen
        lda Char_To_Draw
        cmp #Player_Climb_Top_1
        bne !B0-

        jsr Check_Below
        cmp #Player_Climb_Bot_1
        bne !B0-

        inc Char_Y
        jsr Check_Player_Position
        dec Char_Y
        jsr Draw_Player
        inc Char_Y
        jsr Get_Chars_Under_Player
        
        lda #Color_White
        sta Color_To_Draw
        lda #Player_Climb_Top_0
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        
        jmp Draw_Lower_Player

Handle_Move_Left:
        jsr Get_Char_From_Screen
        
        lda Char_To_Draw
        cmp #Player_Climb_Top_0
        bne !B1+
        
        jsr Check_Below
        cmp #Player_Run_Left_Bottom_0
        bne !B1+

!B0:    lda #Player_Run_Top_0           // Draw player body upper character
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        inc Char_Y                      // Move down a character and draw player body lower character  ??
        lda #Char_Player_Body_1         // ?? What character is this? Leg and body don't make sense
        sta Char_To_Draw
        jmp Draw_Lower_Player_2

!B1:
        jsr Get_Char_From_Screen
        lda Char_To_Draw
        cmp #Player_Run_Top_0
        bne !B0-

        jsr Check_Below
        cmp #Char_Player_Body_1
        bne !B0-

        dec Char_X
        jsr Check_Player_Position
        
        inc Char_X
        jsr Draw_Player

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

Check_Player_Position:
        lda #$00
        sta VIC_NOISE           // Silence the Noise generator
        sta Alien_Hits          // 

        lda Char_X              // Is the character off the right of the screen
        cmp #screen_width
        bcs !B3+

        lda Char_Y              // Is the character at the bottom of the play area of the screen
        cmp #screen_height-3
        bcs !B3+

        jsr Get_Char_From_Screen
        lda Char_To_Draw
        cmp #Char_Floor
        bcc !B0+

        cmp #Player_Shovel_Right_Top_0-1   // ??
        bcs !B0+
        jmp !B3+                // Could this be a bcc???

!B0:    jsr Check_Below         // Check below the character
        cmp #Char_Floor         // If there is floor underneath
        bcc !B1+
        cmp #Player_Shovel_Right_Top_0-1                // ??
        bcs !B1+
        jmp !B3+

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

!B3:    pla
        pla
        rts

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
Check_Alien_Collision:
        jsr Check_Below         // Check_Right??
        cmp #Char_Player_Leg_0  // Has the alien collided with the players leg animation 0
        beq !B0+
        cmp #Char_Player_Leg_1  // Has the alien collided with the players leg animation 1
        beq !B0+

        cmp #Char_Player_Body_1
        beq !B3+
        cmp #Player_Run_Left_Bottom_0
        beq !B3+
        cmp #Player_Shovel_Right_Bot_0
        beq !B0+
        cmp #Player_Shovel_Right_Bot_1
        beq !B2+
        cmp #Player_Shovel_Left_Bot_0
        beq !B3+
        cmp #Player_Shovel_Left_Bot_1
        beq !B4+
        rts

// Alien has hit Player?
!B0:
        lda #Player_Shovel_Right_Top_1
!B1:
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        inc Char_To_Draw
        inc Char_Y
        jsr Draw_Char_On_Screen
        dec Char_Y

        lda #$00
        sta VIC_NOISE
        rts

!B2:  lda #Player_Shovel_Right_Top_0
        jmp !B1-        // Could this be a BNE branch instead?

!B3:
        lda #Player_Shovel_Left_Top_1
        jmp !B1-        // Could this be a BNE branch instead?

!B4:
        lda #Player_Shovel_Left_Top_0
        jmp !B1-        // Could this be a BNE branch instead?

Draw_Aliens:
        ldx #$01

        lda #Init_Alien_X_Pos           // Initial X,Y coordiate for Alien - 2 (counting from 0) and 0 across but that changes
        sta Init_Alien_X
        lda #Init_Alien_Y_Pos
        sta Init_Alien_Y

        lda #$80                        // Start making a noise as the Aliens appear
        sta VIC_OSC_1_FREQ
        lda #$0F                        // ???
        sta VIC_VIA_1_AUX_COL_VOL

        lda Num_of_Aliens_Level         // Get number of aliens that should be on this level
        clc                             // x4 because there are 4 bytes per alien in the alien data table
        asl
        asl
        sta Aliens_Live_Count           // Use that to check when we're done processing all Aliens

Next_Alien:
        lda Init_Alien_X                // Set the Aliens initial X co-ordinate in the Alien data table
        sta Alien_Data,X
        sta Char_X
        tay                             // Add two to the Alien X co-ordinate to start placing then further to the right as they appear
        iny
        iny
        cpy #screen_width               // Have we gone past the width of the screen?
        bcc !B0+                        // If not keep going and draw

        ldy #Init_Alien_X_Pos           // If we have gone of the right edge, reset back to the Left of screen
        inc Init_Alien_Y                // Move the Alien down one, this is actually a floor number, we then look up the actual Y coord of the floor

!B0:    sty Init_Alien_X                // Save the new Alien X coordinate

        inx                             // move to the next entry in the Alien Table

        ldy Init_Alien_Y                // Get the alien Y coord
        lda Floor_Level_Y,Y             // Look up the position of the alien on the floor based on the Y - this seems cumbersome???
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
        lda #$D7                        // Set the initial Alien status - %11010111 - Not sure excatly what the bits represent yet???
        sta Alien_Data,X
        
        cpx Aliens_Live_Count
        bcs !B1+
        
        txa                             // Save the index into the Alien data table on to the stack
        pha

        lda #Char_Alien_1               // Draw alien
        sta Char_To_Draw
        lda #Color_Cyan
        sta Color_To_Draw
        jsr Draw_Char_On_Screen
        
        lda #$04                        // Play a rising tone for the time the Aliens are appearing - Increase the tone and pause
        adc VIC_OSC_1_FREQ
        sta VIC_OSC_1_FREQ

        ldx #$50
        jsr Delay_By_X

        pla                             // Retrieve the index into the Alien data table on to the stack
        tax

!B1:    inx
        cpx #$C1                        // Are we above the maximum index for the number of Aliens??? 4 x the maximum number? $C1 is a big number
        bne Next_Alien

        lda #$00                        // Silence sound
        sta VIC_OSC_1_FREQ
        
        rts

// Y co-ordinate of the line above each floor for the Aliens - instead of a table might just be able to increment with each addition.
// Can higher level should start with more difficult aliens set at higher levels???
Floor_Level_Y:
        .byte $01,$04,$07,$0A,$0D,$10,$13

Draw_Alien:
        lda Alien_Anim_Frame            // Test if this number odd or even, use to determine which animation frame to draw
        and #$01
        beq !B0+

        lda #Char_Alien_1               // Frame 1 of player or alien animation
        sta Player_Anim+1               // Self-modified code alert - $1625             - Not sure if self modifying code actually saved us anything here??
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
        lda #Char_Alien_0               // The value loaded in A is set by self-modifying code above
        sta Char_To_Draw
        jsr Draw_Char_On_Screen
        rts

Draw_an_Alien:
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

Process_Alien:
        ldx Curr_Alien                  // Get current index into Alien Date table
        lda Alien_Data,X                // Get Alien X Screen Coordinate
        sta Char_X
        sta Curr_Alien_X
        inx
        lda Alien_Data,X                // Get Alien Y Screen Coordinate
        sta Char_Y
        sta Curr_Alien_Y
        inx
        lda Alien_Data,X                // Get Alien Color
        sta Curr_Alien_Color
        inx
        lda Alien_Data,X                // Get Alien Status data
        bmi !B0+                        // Bit 7 set? If yes?
        jmp Just_Return                 // This appears to just jump to an RTS, why not just do an RTS here???

!B0:    rol                             // Rotate and check what was bit 6, is it set? If yes?
        bmi !B1+
        jmp Set_Alien_Status            // Not set so...

!B1:    jsr Check_Below                 // Check to see if the Alien is over a hole that has been dug

        cmp #Char_Floor_Dug_1           // If the character under the Alien is less than or greater than any of the Dug hole characters they can keep going
        bcc Alien_Keep_Moving
        cmp #Char_Floor_Dug_4+1
        bcs Alien_Keep_Moving

        inc Char_Y                      // The Alien is over a partly dug hole so point at that character and jump to code to fill hole
        jmp Fill_Hole

Alien_Keep_Moving:                      // May be it's alien NOT in hole??
        ldx Curr_Alien                  // Get the Alien direction from table??
        inx
        inx
        inx
        lda Alien_Data,X
        and #$0C                        // Mask the direction bits of data for Alien %00001100
        beq Alien_Going_Up              // If 0 the Alien is going Up

        cmp #Alien_Down                 // If $0C the Alien is going Down
        beq Alien_Going_Down

        cmp #Alien_Right                // If $04 the Alien is going Right
        beq Alien_Going_Right

Alien_Going_Left:
        dec Char_X                      // It has to have been $08 so the Alien is going Left
        jmp Check_Alien                 //$16BB

Alien_Going_Right:
        inc Char_X                      // Move Alien Right
        jmp Check_Alien

Alien_Going_Up:
        dec Char_Y                      // Move Alien Up

        jsr Get_Char_From_Screen        // Check the character under the aliens new position
        lda Char_To_Draw                // If it's 0 then it's a empty character and they have gone off the top of a ladder
        bne Check_Alien                 // If not, check but keep the alien moving

        jsr Check_Below                 // Check if the Alien has reached the top of a ladder?
        cmp #Char_Ladder_Top
        bne !B0+                        // If not at top of ladder keep going  -- Check_Alien might be in reach to branch directly

        inc Char_Y                      // If at top of ladder put him back down and keep going

!B0:    jmp Check_Alien

Alien_Going_Down:
        inc Char_Y                      // Move Alien down ladder

Check_Alien:                            // Check if the Alien should keep moving
        lda Char_X                      // Is the Alien off the right edge of screen?
        cmp #screen_width               // If yes jump to reverse aliens direction
        bcc !B1+
        jmp Reverse_Alien_Direction

!B0:    jmp End_Alien_Loop              // The Alien came in contact with the player

!B1:    lda Char_Y                      // Check if the Alien has reached the top of the screen
        bne !B3+                        // If Y isn't zero keep checking
!B2:    jmp Reverse_Alien_Direction     // If Y is 0 Alien is at top and needs to reverse direction

!B3:    cmp #Lowest_Flr                 // Has the Alien gone into the lowest floor
        beq !B2-                        // If yes then reverse direction

        jsr Get_Char_From_Screen        // Check the character in the position that Alien is about to enter

        lda Char_To_Draw                
        cmp #Player_Shovel_Right_Top_0  // If the character is anything higher than this we came in contact with the player
        bcs !B0-                        // No contact so End_Alien_Loop and draw the alien in new position

        cmp #Char_Alien_0               // Did the Alien hit another alien, if so reverse direction
        beq Reverse_Alien_Direction
        cmp #Char_Alien_1
        beq Reverse_Alien_Direction

        cmp #Char_Floor                 // Did the Alien hit the floor at the bottom of a ladder, if so change direction
        beq Reverse_Alien_Direction
        
        jsr Check_Below                 // Look at he character below the Alien
        beq !B4+                        // If it's an empty character branch to decide what to do

        cmp #Player_Shovel_Right_Top_0  // If the character is anything higher than this we came in contact with the player
        bcs !B0-                        // No contact so End_Alien_Loop and draw the alien in new position

        cmp #Char_Alien_0               // Did the Alien hit another alien, if so it's OK so save Alien position and return
        beq Save_Alien_Position
        cmp #Char_Alien_1
        beq Save_Alien_Position

!B4:    ldx Curr_Alien                  // Save the Aliens new position in the Alien data
        lda Char_X
        sta Alien_Data,X
        inx
        lda Char_Y
        sta Alien_Data,X
        jsr Get_Char_From_Screen        // Get the character in the Aliens new location

        lda Char_To_Draw
        cmp #Char_Ladder_Top            // Are we at the top of a ladder?
        beq Alien_Top_Ladder            // If so go and handle the Alien at top of ladder, needs to pick a direction
        
        cmp #Char_Ladder_Main           // Is the Alien still on the ladder?
        bne !B0+                        // If not need to handle
        
        jmp Check_Still_on_Ladder       // If still on ladder go check if time to start moving left or right

!B0:    inc Char_Y                      // Look at the character under the Alien
        jsr Get_Char_From_Screen
        dec Char_Y

        lda Char_To_Draw                // Does the Alien have a blank character under it?
        cmp #Char_Blank                 // Do we need to compare? If it's 0 can we just beq??
        beq !B1+
        rts                             // It's not a blank character so return

// The Alien had nothing under it
!B1:    ldx Curr_Alien                  // Get the index for the current Alien into Alien data
        inc Char_Y                      // Make Alien fall down one character height
        inx                             // Save the new Alien Y position
        lda Char_Y
        sta Alien_Data,X
        inx
        lda #$FF                        // ??
        sta Alien_Data,X
        inx
        lda Alien_Data,X                // Get Alien status and set it to falling??
        and #$9F                        // Clear the two bits %10011111
        ora #$20                        // Set the 5th bit in status %00100000
        sta Alien_Data,X
        rts

        inc Char_Y
        jsr Get_Char_From_Screen
        dec Char_Y
        lda Char_To_Draw                // Should Get_Char_From_Screen always return with the character in A??
        cmp #Char_Floor
        bne !B0+                        // Branch if the character below isn't the floor. It has
        jmp Alien_Random_Left_or_Right  // The Alien has reached floor need to pick a new direction

Reverse_Alien_Direction:
!B0:    ldx Curr_Alien                 // Change the direction of the Alien??
        inx
        inx
        inx
        lda Alien_Data,X
        eor #$0C                       // Flip the direction the alien is moving?? $00 to $0C, $0C to $00, $08 to $04, $04 to $08
        sta Alien_Data,X

Save_Alien_Position:
        ldx Curr_Alien                 // Save the location of the current Alien now that we've moved it
        lda Curr_Alien_X
        sta Alien_Data,X
        inx
        lda Curr_Alien_Y
        sta Alien_Data,X
        rts

Alien_Top_Ladder:
        inc Char_Y                      // Look one character under the Alien
        jsr Get_Char_From_Screen
        dec Char_Y

        lda Char_To_Draw                // Is the Alien still on a ladder?
        cmp #Char_Ladder_Main
        bne Alien_Random_Left_or_Right  // If not on ladder we need to handle if it's the floor, the player or another Alien

        inc Char_Y                      // Look two characters under the Alien
        inc Char_Y
        jsr Get_Char_From_Screen
        dec Char_Y
        dec Char_Y
        
        lda Char_To_Draw                // Is the Alien still on a ladder or about to reach a floor?
        cmp #Char_Ladder_Main
        bne Alien_Random_Left_or_Right  // If not on ladder we need to handle if it's the floor, the player or another Alien

// Pick a new random direction for the Alien - This is code which could be improved A LOT! e.g. check where the player is and go after him
        lda VIC_RASTER_LINE             // get a random number by peeking at the current raster line AND with $3 (%00000011) to limit to 0-3
        and #$03
        tax
        lda Alien_Direction,X           // use the random number from 0-3 to pick a directiom??
        beq Alien_Top_Ladder            // if the Alien is to go up, check if at the top of the ladder

        pha                             // Save the new direction on stack and go and chamnge the Aliens direction
        jmp Set_Alien_Direction

// Look under the alien and to either side to see if there is floor, if it's still mid-ladder not time to move left or right
Check_Still_on_Ladder:
        inc Char_Y                      // Look under the Alien
        jsr Get_Char_From_Screen
        dec Char_Y
        lda Char_To_Draw
        cmp #Char_Floor
        beq Alien_On_Floor              // If there is floor keep going??

        dec Char_X                      // Look behind or to the left of the Alien to see if there is floor?
        inc Char_Y
        jsr Get_Char_From_Screen
        inc Char_X
        dec Char_Y
        lda Char_To_Draw
        cmp #Char_Floor
        bne !B0+                        // No floor to the left so handle otherwise
        
        inc Char_X                      // Look in front or to the right of the Alien to see if there is floor?
        inc Char_Y
        jsr Get_Char_From_Screen
        dec Char_X
        dec Char_Y
        lda Char_To_Draw
        cmp #Char_Floor
        bne !B0+                        // No floor to the right so handle otherwise

// The Alien had floor under it to the left and right so now pick a random direction?? -- This could be improved a lot so much less random??

        jsr Random_Binary               // Get random 0 or 1 in carry flag
        bcs Alien_Random_Left_or_Right  // If 1 set Alien to randomly go left or right
        bcc Alien_Random_Up_or_Down     // If 0 set Alien to randomly go up or down

Alien_On_Floor:
        jsr Random_Binary               // Random binary - get a 1 or 0 in carry
        bcs Alien_Random_Left_or_Right

        dec Char_Y
        jsr Get_Char_From_Screen
        inc Char_Y
        lda Char_To_Draw
        cmp #Char_Alien_0
        beq Alien_Random_Left_or_Right
        cmp #Char_Alien_1
        beq Alien_Random_Left_or_Right

        lda #Char_Blank
        pha
        beq Set_Alien_Direction

!B0:    rts

// Choose a random direction left or right for Alien
Alien_Random_Left_or_Right:
        jsr Random_Binary               // Pick a random 0 or 1 in carry flag
        bcs !B1+

        lda #Alien_Right                // Alien new direction??
        pha                             // ??? change this branch to save a PHA
        bne Set_Alien_Direction         // This always jumps because we loaded it with a non-zero value

!B1:    lda #Alien_Left
        pha                             // ??? change this branch to save a PHA
        bne Set_Alien_Direction         // This always jumps because we loaded it with a non-zero value

// Choose a random direction up or down for Alien
Alien_Random_Up_or_Down:
        jsr Random_Binary               // Pick a random 0 or 1 in carry flag
        bcs !B0+

        lda #Alien_Down
        pha
        bne Set_Alien_Direction         // This always jumps because we loaded it with a non-zero value

!B0:    lda #Alien_Up
        pha                             // ??? For Alien_Down above we could branch to this pha to save a byte

Set_Alien_Direction:                    // The new direction is on the stack
        ldx Curr_Alien                  // Get alien number we're currently processing
        inx
        inx
        inx
        lda Alien_Data,X                // Get the Alien status with embedded direction
        and #$F3                        // Mask off the bottom to bits %11111100
        sta Curr_Alien_Status
        pla                             // Get the direction of the stack
        ora Curr_Alien_Status           // Save the new status with the new directi0n in bottom two bits
        sta Alien_Data,X
        rts

// Look up table for Alien direction 0-3
Alien_Direction:
        .byte Alien_Up, Alien_Right, Alien_Left, Alien_Down

Set_Alien_Status:               // Still not clear what this routine actually does to Alien or why we came here??? Work out later.
        dex
        lda Alien_Data,X
        tay                     // Why do this in three instructions when we should be be able to do a subtract #1???
        dey
        tya
        sta Alien_Data,X
        cmp #$E0                // Is ??
        bcc !B0+
        rts

!B0:    dex
        lda Alien_Data,X
        tay                     // Could this have been done better, seems sloppy???
        dey
        tya
        sta Alien_Data,X
        inx
        inx
        lda Alien_Data,X        //
        and #$9F                // Mask off status bits %10011111
        ora #$40                // Set %01000000 - ??
        sta Alien_Data,X
        and #$03                // Mask off the direction bits %00000011
        cmp #$01                // Is the Alien going in a hole? ???
        beq !B1+

        tay
        dey
        tya
        sta Current_Alien_Direction
        lda Alien_Data,X
        and #$FC                        // Mask off the direction bits %11111100
        ora Current_Alien_Direction     // or in the new direction
        sta Alien_Data,X

// The Alien just died so fill in the floor
!B1:    lda #Color_Green
        sta Color_To_Draw
        lda #Char_Floor
        sta Char_To_Draw
        jsr Draw_Char_On_Screen

Just_Return:
        rts

Get_Alien_Data:
        ldx Curr_Alien
        inx
        inx
        inx
        rol                             // Rotate the status byte for the Alien and check bit 5
        rol
        rol
        bcc !B0+                        // If bit 5 is clear ??? Bit 5 might mean the Alien is dead so ignore in list
        rts                             // Bit 5 was set so return

!B0:    ldx Curr_Alien
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
Random_Binary:
        clc
        lda VIC_RASTER_LINE      // Read the TV raster line?
        lsr                      // Divide by 8?
        lsr
        lsr
        rts

Get_Player_Input:
        jsr Read_Joystick       // Read the Joystick -- Move this subroutine here to save a few bytes - it only appears here
 
// Read_Keyboard usage here is tricky. If a match is found the subroutine doesn't return inline, it pops
// the return address and does at RTS from Get_Player_Input. Not clear if this is actually efficient or
// just very confusing.

        lda #Player_Move_Up     // Set Player direction to Up
        sta Player_Direction
        lda #$FD                // Pass to scan keyboard column 1 (%11111101)
        jsr Read_Keyboard
 
        lda #Player_Move_Right  // Set Player direction to Right
        sta Player_Direction
        lda #$DF                // Pass to scan keyboard column 5 (%11011111)
        jsr Read_Keyboard
 
        lda #Player_Move_Down   // Set Player direction to Down
        sta Player_Direction
        lda #$EF
        jsr Read_Keyboard      // Pass to scan keyboard column 4 (%11101111)
 
        lda #Player_Move_Left  // Set Player direction to Left
        sta Player_Direction   // Pass to keyboard column to scan %11101111
        jsr Read_Keyboard
 
        lda #$FB               // Pass to scan keyboard column 2 (%11111011)
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

Read_Joystick:
        lda VIC_VIA_1_Port_A            // read the VIC port tied to joystick
        and #Joystick_Up_Bit            // Check for up on Joy 0 - Bit 2 - 0x00000100
        bne Joy_Not_Up                  // Branch if it is up
        lda #Player_Move_Up             // Return 0 for player pushing joystick up
        beq Return_Dir

Joy_Not_Up:
        lda VIC_VIA_1_Port_A            // read the joystick
        and #Joystick_Down_Bit          // Check for Up on Joy 1 - Bit 3 - 0x00001000
        bne Joy_Not_Down
        lda #Player_Move_Down           // Return 2 for player pushing joystick down
        bne Return_Dir

Joy_Not_Down:
        lda VIC_VIA_1_Port_A            // read the joystick
        and #Joystick_Left_Bit          // Check for Left on Joy 1 - Bit 4 - 0x00010000
        bne Joy_Not_Left
        lda #Player_Move_Left           // Return 3 for player pushing joystick left
        bne Return_Dir

Joy_Not_Left:
        lda #$7F                        // Set DDR to read, zero is read %01111111
        sta VIC_VIA_2_DDR_B
        lda VIC_VIA_2_Key_Col_Scan      // read the joystick

        pha                             // Push to stack to save the result of reading the joystick
        lda #$FF                        // Set DDR back to write, not clear if this is actually needed??
        sta VIC_VIA_2_DDR_B
        pla                             // Retrieve the result of reading the joystick from the stack

        and #Joystick_Right_Bit         // Check for Right on Joy 3 - Bit 7 - 0x10000000
        bne Joy_Not_Right

        lda #Player_Move_Right          // Return 1 for Right?
Return_Dir:
        sta Player_Direction            // Store direction of player based on Joystick 0

!B1:            pla                             // Pull the return address
                pla
                lda Player_Direction            // Load the direction and return
                clc

Joy_Not_Right:  rts

Read_Keyboard:
        sta VIC_VIA_2_Key_Col_Scan      // Write to VIC 2 Port B to select column to scan - 0 bit in A selects column
        lda VIC_VIA_2_Key_Row_Scan      // Read VIC 2 Row Scan to see what key is held down
        and #$20                        // Check row 5 (%00100000) - Checking for 'P' or 'E' key??
        beq !B1-
        
        lda VIC_VIA_2_Key_Row_Scan      // Read VIC 2 Row Scan to see what key is held down
        and #$02                        // Check %00000010 - Checking for 'W' key??
        beq !B1-                        // If it matched pop the return address and return with A = Direction
        
        rts                             // If it didn't match return and check again

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
        jsr Draw_Player
        
        inc Char_Y

        lda #Char_Alien_Dead            // Draw cross above dead alien??
        sta Char_To_Draw
        lda #Color_White
        sta Color_To_Draw
        jsr Draw_Char_On_Screen

Draw_Oxygen_Message:
        lda #<Text_Oxygen_Out           // $22 is used as to store the indirect address of something on the screen
        sta Temp_Index_Lo
        lda #>Text_Oxygen_Out
        sta Temp_Index_Hi
        jsr Draw_Game_End_Messages

        jmp Lose_Life

Still_Oxygen:
        rts                     // Return because Oxygen hasn't reached '0000' yet

Add_Score_For_Alien:                    // how many floors or level of alien you killed?
        ldy Current_Alien_Flr_Fall
!Loop:  jsr Add_Score
        dey
        bne !Loop-

        lda #$00                        // This code is repeated elsewhere, we could just jump to it??
        sta Current_Alien_Level         // Zero the current alien level and score ready for the next alien killed
        sta Current_Alien_Flr_Fall      // Do we have to zero both of these, won't they just get over ridden?
        rts

Add_Score:
        ldx Current_Alien_Level         // Use the level number of the Alien you killed to increment your score. This is kind of lame if it's just 1,2,3 perhaps multiply it by 10???

!Loop:  jsr Increment_Score             // Increment the score by 1
        dex
        bne !Loop-
        rts

// increment the score in 100's - This might be fewer bytes as a loop??
Increment_Score:
        inc Screen_Score+4              // Add 1 to score the hundreds digit of score
        lda Screen_Score+4              // Check if it has reached 10 so we need to increment next thousands
        cmp #Char_9+1
        beq !B0+
        rts

!B0:    lda #Char_0             // '0' the hundreds on screen              If we put Char_0 in X we might be able to use that to reset to "0" in each case below
        sta Screen_Score+4

        inc Screen_Score+3      // increment the thousands on screen
        lda Screen_Score+3      // Check if it has reached 10000 so we need to increment next digit
        cmp #Char_9+1
        beq !B1+
        rts

!B1:    lda #Char_0             // '0' the thousands on screen
        sta Screen_Score+3

        inc Screen_Score+2      // increment the ten thousands on screen
        lda Screen_Score+2      // Check if it has reached 10 so we need to increment next digit
        cmp #Char_9+1
        beq !B2+
        rts

!B2:    lda #Char_0             // '0' the ten thousands on screen
        sta Screen_Score+2

        inc Screen_Score+1      // increment the hundred thousand's on screen
        rts

//
// Draw Floors on screen
// 
// Draw the floor characters on the screen and puts the right color behind the character
//
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

Draw_Ladders:
        lda Current_Level       // Get the current level
        and #$03                // Isolate the lower two bits to make it an index from 0-3
        clc                     // Clear so we don't rotate in a set carry flag
        asl                     // double to give us an index into the table
        tax                     // Move A to X to use as index
        lda Ladder_Layout_Lookup,X
        sta Temp_Index_Lo
        inx
        lda Ladder_Layout_Lookup,X
        sta Temp_Index_Hi

        ldy #$17                // all screens have 8 ladders                           Opportunity to make the number of ladders change by level???
!B0:    lda (Temp_Index_Lo),Y             // Get the length of the ladder to draw
        sta Ladder_Length
        dey
        lda (Temp_Index_Lo),Y             // Get the screen high address of the start of the ladder
        sta Ladder_Start_Hi_Addr
        dey
        lda (Temp_Index_Lo),Y             // Get the screen low address of the start of the ladder
        sta Ladder_Start_Lo_Addr
        tya                     // Save Y
        pha                     
        jsr Draw_Ladder
        pla                     // retrieve Y
        tay
        dey
        bpl !B0-                // Draw the next ladder
        rts

Draw_Ladder:
        lda Ladder_Start_Lo_Addr                // Determine address in color map based on address in video
        sta Ladder_Start_Col_Lo_Addr
        lda Ladder_Start_Hi_Addr
        clc
        adc #$78                                // Adding $78 is offset from $1E00 start address of video memory to $9600 color memory
        sta Ladder_Start_Col_Hi_Addr

        lda #Char_Ladder_Top    // Draw top of ladder??
        ldy #$00
        sta (Ladder_Start_Lo_Addr),Y
        lda #Color_White
        sta (Ladder_Start_Col_Lo_Addr),Y

!loop:  jsr Next_Line_Down      // Move pointers down one line in video and color memory and draw bottom half of player
        
        lda #Char_Ladder_Main   // Draw Ladder character in white, takes advantage that character and color are both $1
        sta (Ladder_Start_Lo_Addr),Y
        sta (Ladder_Start_Col_Lo_Addr),Y
        dec Ladder_Length                 // Decrement length of ladder count and if unfinished loop and draw another ladder char
        lda Ladder_Length                 // Do we have to load or does DEC set the zero flag??
        bne !loop-

        rts

Next_Line_Down:
        clc                           // Add Screen Width to low address in video memory to point to next line down
        lda #screen_width
        adc Ladder_Start_Lo_Addr
        sta Ladder_Start_Lo_Addr
        lda #$00                      // Add carry flag if we went over $FF in low address
        adc Ladder_Start_Hi_Addr
        sta Ladder_Start_Hi_Addr

        clc                           // Add Screen Width to low address in color memory to point to next line down
        lda #screen_width
        adc Ladder_Start_Col_Lo_Addr
        sta Ladder_Start_Col_Lo_Addr
        lda #$00                      // Add carry flag if we went over $FF in low address
        adc Ladder_Start_Col_Hi_Addr
        sta Ladder_Start_Col_Hi_Addr
        rts

Draw_Game_Start_Message:
        lda #<Text_Start_Msg                // Set ($22) to point at text to start game at originally $1B21
        sta Temp_Index_Lo
        lda #>Text_Start_Msg
        sta Temp_Index_Hi

!loop:  jsr Draw_Message
        jsr Check_F7            // Check for 'F7' key to start game -- Could put the code in line and save a few bytes because it's only used once
        bcc !loop-              // No F7 so keep waiting and flashing message

        rts

Draw_Game_Over_Message:
        lda #<Text_Game_Over_Msg                // Set ($22) to point at text GAME OVER
        sta Temp_Index_Lo
        lda #>Text_Game_Over_Msg
        sta Temp_Index_Hi

Draw_Game_End_Messages:
        ldx #$08               // Show text 8 times
!loop:  txa
        pha
        jsr Draw_Message        // Draw message that is pointed to by Temp_Index_Lo ($22)
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
        lda (Temp_Index_Lo),Y             // Draw the text in White on the screen
        sta Screen_Line_11,Y
        lda #Color_White
        sta Color_Line_11,Y
        dey
        bpl !loop-

        jsr Safe_Delay                  //Two delays
        jsr Safe_Delay
          
        ldy #$00              // Pull the characters and color back off the stack and draw on screen
!loop:  pla
        sta Color_Line_11,Y
        pla
        sta Screen_Line_11,Y
        iny
        cpy #screen_width

        bne !loop-
        jsr Safe_Delay
        rts

//
// Draw Character on Screen
//
// $2B  - Character to draw
// $2C  - Color of character to draw
// ($2D)- Indirect address on screen for character to appear
// 

Draw_Char_On_Screen:
        jsr Get_Char_Screen_Adr
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
Get_Char_From_Screen:
          jsr Get_Char_Screen_Adr       // Get the address in video memory of the character at X,Y

          ldy #$00                      // Get the character that will be in the background
          lda (Char_Screen_Adr_Lo),Y
          sta Char_To_Draw
          clc
          lda #$78                      // Add $78 to the high address address to get the address in color space
          adc Char_Screen_Adr_Hi
          sta Char_Screen_Adr_Hi
          lda (Char_Screen_Adr_Lo),Y    // Get the character color and save it
          sta Color_To_Draw
          rts

// Index to start of each screen line in memory - 23 lines

Screen_Line_Address_Lo:
        .byte $00,$16,$2C,$42,$58,$6E,$84,$9A,$B0,$C6,$DC,$F2,$08,$1E,$34,$4A,$60,$76,$8C,$A2,$B8,$CE,$E4
Screen_Line_Address_Hi:
        .byte $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F

//
// Could overlap the $00 at the ends of each screen to save memory??
//

Text_Start_Msg:
// __TYPE_'F7'_TO_START__
        .byte $00,$00,$94,$99,$90,$85,$00,$A7,$86,$B7,$A7,$00,$94,$8F,$00,$93,$94,$81,$92,$94,$00,$00

Text_Game_Over_Msg:
// ______GAME__OVER______
        .byte $00,$00,$00,$00,$00,$00,$87,$81,$8D,$85,$00,$00,$8F,$96,$85,$92,$00,$00,$00,$00,$00,$00

// _____OXYGEN_OUT_______
Text_Oxygen_Out:
        .byte $00,$00,$00,$00,$00,$8F,$98,$99,$87,$85,$8E,$00,$8F,$95,$94,$00,$00,$00,$00,$00,$00,$00

        .byte $00

// Alien level and score for each as they level up? Also represents Alien Color         Do we actually need the first 0??
Alien_Level:
        .byte Color_Black,Color_Cyan,Color_Red,Color_White

// Index to each entry in the level ladder layout
Ladder_Layout_Lookup:
        .byte <Ladder_Layout_0, >Ladder_Layout_0        // $70,$1B
        .byte <Ladder_Layout_1, >Ladder_Layout_1        // $88,$1B
        .byte <Ladder_Layout_2, >Ladder_Layout_2        // $A0,$1B
        .byte <Ladder_Layout_3, >Ladder_Layout_3        // $B8,$1B

// Screen address and line length for ladder

// Create a look up table so that the levels can have a different number of ladders??? What about random at higher levels???

Ladder_Layout_0:
        .byte   $18,$1E,$03
        .byte   $9C,$1E,$03
        .byte   $20,$1F,$03
        .byte   $E4,$1E,$06
        .byte   $22,$1E,$06
        .byte   $2A,$1F,$06
        .byte   $AB,$1E,$03
        .byte   $2A,$1E,$12

Ladder_Layout_1:
        .byte   $17,$1E,$12
        .byte   $1C,$1E,$06
        .byte   $24,$1F,$03
        .byte   $6A,$1F,$03
        .byte   $23,$1E,$03
        .byte   $EE,$1E,$09
        .byte   $2A,$1E,$06
        .byte   $A4,$1E,$03

Ladder_Layout_2:
        .byte   $18,$1E,$09
        .byte   $62,$1F,$03
        .byte   $A0,$1E,$03
        .byte   $20,$1E,$03
        .byte   $E7,$1E,$06
        .byte   $24,$1E,$12
        .byte   $69,$1E,$09
        .byte   $32,$1F,$06

// First screen in game?
Ladder_Layout_3:
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
Dash_Text:
        .byte $00,$0A,$0A,$0A,$00,$00,$00,$00,$00,$00,$00,$93,$83,$8F,$92,$85,$B0,$B0,$B0,$B0,$B0,$B0
        .byte $8F,$98,$99,$87,$85,$8E,$B2,$B0,$B0,$B0,$00,$00,$88,$89,$87,$88,$B0,$B0,$B0,$B0,$B0,$B0

//
// Character Bitmap data
//
// Must fall at $1C00. VIC_Char_Mem register is set to find character map at $1C00 ???

        * = $1C00 "Charmap"

Char_Mem:
        .byte %00000000 // [        ]           00 - Blank
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]

        .byte %11111111 // [████████]           01 - Ladder Main
        .byte %10000001 // [█      █]
        .byte %11111111 // [████████]
        .byte %10000001 // [█      █]
        .byte %11111111 // [████████]
        .byte %10000001 // [█      █]
        .byte %11111111 // [████████]
        .byte %10000001 // [█      █]

        .byte %00000000 // [        ]           02 - Ladder Top
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %10000001 // [█      █]
        .byte %11111111 // [████████]
        .byte %10000001 // [█      █]
        .byte %11111111 // [████████]
        .byte %10000001 // [█      █]

        .byte %11111011 // [█████ ██]           03 - Floor
        .byte %11111011 // [█████ ██]
        .byte %00000000 // [        ]
        .byte %11011111 // [██ █████]
        .byte %11011111 // [██ █████]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]

        .byte %10000001 // [█      █]           04 - Floor Dug 1
        .byte %11100101 // [███  █ █]
        .byte %00000000 // [        ]
        .byte %11011111 // [██ █████]
        .byte %11011111 // [██ █████]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]

        .byte %00000000 // [        ]           05 - Floor Dug 2
        .byte %11000001 // [██     █]
        .byte %00000000 // [        ]
        .byte %11011111 // [██ █████]
        .byte %11011111 // [██ █████]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]

        .byte %00000000 // [        ]           06 - Floor Dug 3
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %10000001 // [█      █]
        .byte %11011111 // [██ █████]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]

        .byte %00000000 // [        ]           07 - Floor Dug 4
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %10000011 // [█     ██]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]

        .byte %11100110 // [███  ██ ]           08 Alien Frame 0
        .byte %00011001 // [   ██  █]
        .byte %00111100 // [  ████  ]
        .byte %01011010 // [ █ ██ █ ]
        .byte %10000001 // [█      █]
        .byte %11111111 // [████████]
        .byte %11011101 // [██ ███ █]
        .byte %10011001 // [█  ██  █]

        .byte %01100111 // [ ██  ███]           09 Alien Frame 1
        .byte %10011000 // [█  ██   ]
        .byte %00111100 // [  ████  ]
        .byte %01011010 // [ █ ██ █ ]
        .byte %10100101 // [█ █  █ █]
        .byte %11111111 // [████████]
        .byte %10111011 // [█ ███ ██]
        .byte %10011001 // [█  ██  █]

        .byte %10011001 // [█  ██  █]           0A Player Life Counter
        .byte %01011010 // [ █ ██ █ ]
        .byte %00111100 // [  ████  ]
        .byte %00011000 // [   ██   ]
        .byte %00100100 // [  █  █  ]
        .byte %00100100 // [  █  █  ]
        .byte %00100100 // [  █  █  ]
        .byte %00100100 // [  █  █  ]

        .byte %00000000 // [        ]           0B Player Shovel Right Top 0
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %01100000 // [ ██     ]
        .byte %11110000 // [████    ]
        .byte %11110000 // [████    ]
        .byte %01100000 // [ ██     ]

        .byte %11110000 // [████    ]           0C Player Shovel Right Bottom 0
        .byte %11111000 // [█████   ]
        .byte %01101000 // [ ██ █   ]
        .byte %01100100 // [ ██  █  ]
        .byte %10010100 // [█  █ █  ]
        .byte %10010110 // [█  █ ██ ]
        .byte %10010011 // [█  █  ██]
        .byte %11010011 // [██ █  ██]

        .byte %00000000 // [        ]           0D Player Shovel Left Top 0
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000110 // [     ██ ]
        .byte %00001111 // [    ████]
        .byte %00001111 // [    ████]
        .byte %00000110 // [     ██ ]

        .byte %00001111 // [    ████]           0E Player Shovel Left Bottom 0
        .byte %00011111 // [   █████]
        .byte %00010110 // [   █ ██ ]
        .byte %00100110 // [  █  ██ ]
        .byte %00101001 // [  █ █  █]
        .byte %01101001 // [ ██ █  █]
        .byte %11001001 // [██  █  █]
        .byte %11011011 // [██ ██ ██]

        .byte %00000000 // [        ]           0F Player Shovel Right Top 0
        .byte %00000000 // [        ]
        .byte %00000011 // [      ██]
        .byte %00000011 // [      ██]
        .byte %01100110 // [ ██  ██ ]
        .byte %11110100 // [████ █  ]
        .byte %11110100 // [████ █  ]
        .byte %01101000 // [ ██ █   ]

        .byte %11111000 // [█████   ]           10 Player Shovel Right Bottom 0
        .byte %11110000 // [████    ]
        .byte %01100000 // [ ██     ]
        .byte %01100000 // [ ██     ]
        .byte %10010000 // [█  █    ]
        .byte %10010000 // [█  █    ]
        .byte %10010000 // [█  █    ]
        .byte %11011000 // [██ ██   ]

        .byte %00000000 // [        ]           11 Player Shovel Left Top 1
        .byte %00000000 // [        ]
        .byte %01100000 // [ ██     ]
        .byte %01100000 // [ ██     ]
        .byte %01100110 // [ ██  ██ ]
        .byte %00101111 // [ █  ████]
        .byte %00101111 // [ █  ████]
        .byte %00010110 // [ █   ██ ]

        .byte %00011111 // [   █████]           12 Player Shovel Left Bottom 1
        .byte %00001111 // [    ████]
        .byte %00000110 // [     ██ ]
        .byte %00000110 // [     ██ ]
        .byte %00001001 // [    █  █]
        .byte %00001001 // [    █  █]
        .byte %00001001 // [    █  █]
        .byte %00010111 // [   █ ███]

        .byte %00000000 // [        ]           13 Player Climb Top 0
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00011000 // [   ██   ]
        .byte %00111100 // [  ████  ]
        .byte %00111100 // [  ████  ]
        .byte %10011000 // [█  ██   ]

        .byte %11111111 // [████████]           14 Player Climb Bottom 0
        .byte %00011001 // [   ██  █]
        .byte %00011000 // [   ██   ]
        .byte %00011000 // [   ██   ]
        .byte %01100100 // [ ██  █  ]
        .byte %01000100 // [ █   █  ]
        .byte %11000100 // [██   █  ]
        .byte %00000110 // [     ██ ]

        .byte %00000000 // [        ]           15 Player Climb Top 1
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00011000 // [   ██   ]
        .byte %00111100 // [  ████  ]
        .byte %00111100 // [  ████  ]
        .byte %00011001 // [   ██  █]

        .byte %11111111 // [████████]           16 Player Climb Bottom 1
        .byte %10011000 // [█  ██   ]
        .byte %00011000 // [   ██   ]
        .byte %00011000 // [   ██   ]
        .byte %00100110 // [  █  ██ ]
        .byte %00100010 // [  █   █ ]
        .byte %00100011 // [  █   ██]
        .byte %01100000 // [ █     ]

        .byte %11111111 // [████████]           17 Player Run Left Bottom 0
        .byte %00011001 // [   ██  █]
        .byte %00011000 // [   ██   ]
        .byte %00011000 // [   ██   ]
        .byte %00100100 // [  █  █  ]
        .byte %00100111 // [  █  ███]
        .byte %00100001 // [  █    █]
        .byte %01100000 // [ ██     ]

        .byte %00000000 // [        ]           18 Player Run Top 0
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %00011000 // [   ██   ]
        .byte %00111100 // [  ████  ]
        .byte %00111100 // [  ████  ]
        .byte %00011000 // [   ██   ]

        .byte %10101100 // [█ █ ██  ]           19 Player Run Left Bottom 1
        .byte %01011010 // [ █ ██ █ ]
        .byte %00011100 // [   ███  ]
        .byte %00011000 // [   ██   ]
        .byte %01100100 // [ ██  █  ]
        .byte %01000100 // [ █   █  ]
        .byte %11000100 // [██   █  ]
        .byte %00001100 // [    ██  ]

        .byte %11111111 // [████████]           1A Player Run Right Bottom 0
        .byte %10011000 // [█  ██   ]
        .byte %00011000 // [   ██   ]
        .byte %00011000 // [   ██   ]
        .byte %00100100 // [  █  █  ]
        .byte %11100100 // [███  █  ]
        .byte %10000100 // [█    █  ]
        .byte %00000110 // [     ██ ]

        .byte %00111101 // [  ████ █]           1B Player Run Right Bottom 1
        .byte %01011010 // [ █ ██ █ ]
        .byte %00111000 // [  ███   ]
        .byte %00011000 // [   ██   ]
        .byte %00100110 // [  █  ██ ]
        .byte %00100010 // [  █   █ ]
        .byte %00100011 // [  █   ██]
        .byte %00110000 // [  ██    ]

        .byte %00000000 // [        ]           1C Alien in Hole
        .byte %00000000 // [        ]
        .byte %00000000 // [        ]
        .byte %01100110 // [ ██  ██ ]
        .byte %10011001 // [█  ██  █]
        .byte %00111100 // [  ████  ]
        .byte %01011010 // [ █ ██ █ ]
        .byte %10100101 // [█ █  █ █]

        .byte %00011000 // [   ██   ]           1D Alien Dead        - It's not clear if this is ever used???
        .byte %00011000 // [   ██   ]
        .byte %11111111 // [████████]
        .byte %00011000 // [   ██   ]
        .byte %00011000 // [   ██   ]
        .byte %00011000 // [   ██   ]
        .byte %00011000 // [   ██   ]
        .byte %00011000 // [   ██   ]

  // Eventually remove this code because we may not need it to write a tape image???

// Memory $1CF4
//                        // Call Membot - Set the bottom of memory to $1000
//          ldx #$00      // X = Lower half of address $00
//          ldy #$10      // Y = Lower half of address $10
//          clc           // Clear carry to tell Membot to set bottom of memory
//          jsr $FF9C     // Call Membot

//                        // Call SETLFS
//          ldx #$01      // Set for device #1 - Tape
//          jsr $FFBA

//                        // Set file name
//          lda #$00      // Set file name length to zero
//          jsr $FFBD     // Call SETNAM

//                        // Save memory to tape?
//          ldx #$00      // X = Lower half of address $00
//          ldy #$1E      // Y = Lower half of address $1E
//          lda #$2B
//          jsr $FFD8     // Call SAVE

//          brk
//
// Compare Score to High Score
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
//                         // It's not clear if this is ever called???
// Delay_By_Var:
//        ldx Delay_Amount

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

Check_Below:
        inc Char_Y                      // Increment Y
        jsr Get_Char_From_Screen        // Get the character
        dec Char_Y                      // Decrement Y to return to prior value
        lda Char_To_Draw                //Get the character below the Y
        rts

//
// Check for F7 key??
//
Check_F7:
        lda VIC_VIA_1_Port_A            // Check fire button on joystick??
        and #$20                        // If pressed branch and return with carry set to start game
        beq !B0+

        lda #$7F                        // %01111111 Select the column
        sta VIC_VIA_2_Key_Col_Scan
        lda VIC_VIA_2_Key_Row_Scan                      // Read the keyboard row
        and #$80                        // to check for 'F7'
        bne !B1+

!B0:    sec                        // Return with carry set to start game
        rts

!B1:    clc                        // Return with carry clear 'F7' or joystick fire button where not pressed
        rts

//
// Get_Char_Screen_Adr
//
// $29  - X co-ord of character
// $2A  - Y co-ord of character
// ($2D)- Screen address created based on character X and Y
//
Get_Char_Screen_Adr:
        ldy Char_Y                      // Get Y co-ordinate as line number of character on screen
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

Delay_Then_Return:
        ldx #$80
        jsr Delay_By_X
        rts

Clear_Dashboard:
        ldx #(screen_width*2)-1         // 43 ($22) Two x Screen Width - 1 because we're counting 0
!loop:  lda #Color_White
        sta Color_Line_22,X
        lda #$00
        sta Screen_Line_22,X
        dex
        bpl !loop-

// Copy text into bottom two lines of screen
        ldx #(screen_width*2)-1             // Two x Screen Width?
!loop:  lda Dash_Text,X
        sta Screen_Line_22,X
        dex
        bpl !loop-

        rts

// Draw Floor Character - fill in a hole after an alien was killed ??
Draw_Fill_Hole:
        lda #Char_Floor
        sta Char_To_Draw
        lda #Color_Green
        sta Color_To_Draw
        jsr Draw_Char_On_Screen         // Draw Floor
        rts

Alien_Fall:
        inc Char_Y                      // +1 Y ??
        lda #Char_Alien_0               // Alien animation frame 0
        sta Char_To_Draw                // Store in Char to draw
        lda Killed_Alien_Level          // Get Alien Color
        sta Color_To_Draw               // Store in Char color to draw
        jsr Draw_Char_On_Screen         // Draw alien
        jmp Delay_Then_Return           // Return after delay

//
// Have the aliens found the player - Carry is clear if no collision and set if collision
//
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

Match_X:        inx                     // Move to Y co-ordinate entry and compare with Alien Y with Player Y
                lda Alien_Data,X
                cmp Char_Y
                bne Chck_Nxt_Alien      // If not at Player Y check next Alien
                sec                     // Collision so return carry set
                rts

Volume_Silence:                         // This doesn't ever seem to be called, should be able to remove it to save memory???
        lda #$00                        // Set volume to 0
        sta VIC_OSC_1_FREQ
        rts

// Not sure what this hex is for???
//        .byte $01,$04,$07,$0A,$0D,$10,$13,$A5,$30,$29,$01

//
// MUST END BEFORE $1DFF which is the start of the screen RAM
//

//          .END
