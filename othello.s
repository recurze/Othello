.equ SWI_SETSEG8,     0x200        @display on 8 Segment
.equ SWI_SETLED,      0x201        @LEDs on/off
.equ SWI_CheckBlack,  0x202        @check Black button
.equ SWI_CheckBlue,   0x203        @check press Blue button
.equ SWI_DRAW_STRING, 0x204        @display a string on LCD
.equ SWI_DRAW_INT,    0x205        @display an int on LCD
.equ SWI_CLEAR_DISPLAY,0x206        @clear LCD
.equ SWI_DRAW_CHAR,   0x207        @display a char on LCD
.equ SWI_CLEAR_LINE,  0x208        @clear a line on LCD
.equ SWI_EXIT,        0x11         @terminate program
.equ SWI_GetTicks,    0x6d         @get current time 
.equ SEG_A,  0x80         @ patterns for 8 segment display
.equ SEG_B,  0x40         @byte values for each segment
.equ SEG_C,  0x20         @of the 8 segment display
.equ SEG_D,  0x08
.equ SEG_E,  0x04
.equ SEG_F,  0x02
.equ SEG_G,  0x01
.equ SEG_P,  0x10
.equ LEFT_LED,        0x02         @bit patterns for LED lights
.equ RIGHT_LED,       0x01
.equ LEFT_BLACK_BUTTON,0x02         @bit patterns for black buttons
.equ RIGHT_BLACK_BUTTON,0x01        @and for blue buttons
.equ BLUE_KEY_00, 0x01     @button(0)
.equ BLUE_KEY_01, 0x02     @button(1)
.equ BLUE_KEY_02, 0x04     @button(2)
.equ BLUE_KEY_03, 0x08     @button(3)
.equ BLUE_KEY_04, 0x10     @button(4)
.equ BLUE_KEY_05, 0x20     @button(5)
.equ BLUE_KEY_06, 0x40     @button(6)
.equ BLUE_KEY_07, 0x80     @button(7)
.equ BLUE_KEY_08, 1<<8     @button(8) - different way to set
.equ BLUE_KEY_09, 1<<9     @button(9)
.equ BLUE_KEY_10, 1<<10    @button(10)
.equ BLUE_KEY_11, 1<<11    @button(11)
.equ BLUE_KEY_12, 1<<12    @button(12)
.equ BLUE_KEY_13, 1<<13    @button(13)
.equ BLUE_KEY_14, 1<<14    @button(14)
.equ BLUE_KEY_15, 1<<15    @button(15)


.text

@Clear the board, clear the LCD screen
swi      SWI_CLEAR_DISPLAY

.global main

main:
    bl intialize
    bl print
    mov r3, #2
    stmfd sp!,{r0}
    mov r0,#0x02
    swi 0x201
    ldmfd sp!,{r0}
    mov r4, #0
while:
    bl print
    bl move_exists
    cmp r0, #0
    beq switch_turns
    bl getXY
    bl inboard
    cmp r0, #0
    beq while
    bl valid
    cmp r0, #0
    beq while
    mov r4, #0
    bl makemove
    cmp r3, #1 @ player change
    beq t
    stmfd sp!,{r0}
    mov r0,#0x01  @ right led 
    swi 0x201
    ldmfd sp!,{r0}
    mov r3, #1
    b skip
switch_turns:
    cmp r4, #1
    beq exit
    mov r4, #1
    cmp r3, #1
    beq t
    stmfd sp!,{r0}
    mov r0,#0x01  @ right led 
    swi 0x201
    ldmfd sp!,{r0}
    mov r3, #1
    b skip
t:
    mov r3, #2
    stmfd sp!,{r0}
    mov r0,#0x02 @ left led
    swi 0x201
    ldmfd sp!,{r0}
skip:
    b while



intialize:
    @ sets up the board, 
    @ 0 for empty spaces
    @ 1 for player 1, 2 for player 2
    stmfd sp!,{r0-r3,lr}
    ldr r0,=Grid
    mov r1,#0 @ i=0
    mov r2,#0 @ const=0
    mov r3,#4 @ const 4
    loop:
    str r2,[r0,r1,lsl #2]
    add r1,r1,#1
    cmp r1,#64
    blt loop
    mov r2,#1
    mov r1,#27
    str r2,[r0,r1,lsl #2]
    mov r2,#2
    mov r1,#28
    str r2,[r0,r1,lsl #2]
    mov r2,#1
    mov r1,#36
    str r2,[r0,r1,lsl #2]
    mov r2,#2
    mov r1,#35
    str r2,[r0,r1,lsl #2]
    ldmfd sp!,{r0-r3,pc} @ return


winner:
    stmfd sp!,{r1-r5,lr}
    mov r0,#0 @ i=0 
    ldr r2,=Grid
    mov r1,#0 @ player 1 score count (white)
    mov r3,#0 @ player 2 score count (black)
    while_winner: @ 2D array is nothing but 1D array
    ldr r5,[r2,r0,lsl #2]
    cmp r5,#1
    beq player1_count
    cmp r5,#2
    beq player2_count
    count_increased:
    add r0,r0,#1
    cmp r0,#64
    blt while_winner
    b decide
    player1_count:
    add r1,r1,#1
    b count_increased
    player2_count:
    add r3,r3,#1
    b count_increased
    decide:
    cmp r1,r3
    blt player2_win
    cmp r1,r3
    bgt player1_win
    mov r0,#0 @ Tie
    ldmfd sp!,{r1-r5,pc}
    player1_win:
    mov r0,#1
    ldmfd sp!,{r1-r5,pc}
    player2_win:
    mov r0,#2 
    ldmfd sp!,{r1-r5,pc}




move_exists:
    stmfd sp!,{r1,r2,r4,r5,r7,r8,lr}
    ldr r4,=Grid
    mov r1,#0   @i
    mov r2,#0   @j
    while_move_exists:
    mov r5,r1
    mov r5,r5,lsl #3
    add r5,r5,r2
    mov r5,r5,lsl #2
    ldr r7,[r4,r5]
    cmp r7,#0
    beq check_valid_move
    not_valid:
    add r2,r2,#1
    cmp r2,#8 @ j<8
    bge set_while_move_exists
    end_set_move_exists:
    cmp r1,#8 @i<8
    blt while_move_exists
    mov r0,#0
    ldmfd sp!,{r1,r2,r4,r5,r7,r8,pc} @ return false
    check_valid_move:
    bl valid
    cmp r0,#1
    bne not_valid
    ldmfd sp!,{r1,r2,r4,r5,r7,r8,pc}  @return true

set_while_move_exists:
    mov r2,#0 @ j=0
    add r1,r1,#1 @ i++
    b end_set_move_exists


getXY:   @(input ->keyboard,output r1,r2->(y,x))
    stmfd sp!,{r0,lr}
    bl getinput @ get Y
    mov r1,r2
    bl getinput @ get X in r2 ;(x,y)->(r1,r2)
    ldmfd sp!,{r0,pc}




getinput:
        stmfd sp!,{r0,lr}
        @wait for user to press blue button
        mov      r0,#0
        BB1:
        swi      SWI_CheckBlue         @get button press into R0
        cmp      r0,#0
        beq      BB1                   @ if zero, no button pressed
        cmp      r0,#BLUE_KEY_07
        beq      SEVEN
        cmp      r0,#BLUE_KEY_06
        beq      SIX
        cmp      r0,#BLUE_KEY_05
        beq      FIVE
        cmp      r0,#BLUE_KEY_04
        beq      FOUR
        cmp      r0,#BLUE_KEY_03
        beq      THREE
        cmp      r0,#BLUE_KEY_02
        beq      TWO
        cmp      r0,#BLUE_KEY_01
        beq      ONE
        cmp      r0,#BLUE_KEY_00
        beq      ZERO
        ZERO:
        mov r2,#0
        ldmfd sp!,{r0,pc}
        ONE:
        mov r2,#1            @clear previous line 
        ldmfd sp!,{r0,pc}
        TWO:
        mov r2,#2            @clear previous line 
        ldmfd sp!,{r0,pc}
        THREE:
        mov r2,#3           @clear previous line 
        ldmfd sp!,{r0,pc}
        FOUR:
        mov r2,#4            @clear previous line 
        ldmfd sp!,{r0,pc}
        FIVE:
        mov r2,#5            @clear previous line 
        ldmfd sp!,{r0,pc}
        SIX:
        mov r2,#6            @clear previous line 
        ldmfd sp!,{r0,pc}
        SEVEN:
        mov r2,#7            @clear previous line 
        ldmfd sp!,{r0,pc}


inboard:  @ bool ->r0
    cmp r1,#-1
    ble redo
    cmp r2,#-1
    ble redo
    cmp r1,#8
    bge redo
    cmp r2,#8
    bge redo
    mov r0,#1
    bx lr  @return
    redo:
    mov r0,#0
    bx lr @return

valid:  
    stmfd sp!,{r1-r6,lr}
    ldr r4,=Grid
    mov r5,r2
    mov r5,r5,lsl #3
    add r5,r5,r1
    mov r5,r5,lsl #2
    ldr r6,[r4,r5]
    cmp r6,#0
    bne return_false_valid
    bl lvalid
    cmp r0,#1
    beq return_true_valid
    bl rvalid
    cmp r0,#1
    beq return_true_valid
    bl uvalid
    cmp r0,#1
    beq return_true_valid
    bl dvalid
    cmp r0,#1
    beq return_true_valid
    bl ulvalid
    cmp r0,#1
    beq return_true_valid
    bl urvalid
    cmp r0,#1
    beq return_true_valid
    bl dlvalid
    cmp r0,#1
    beq return_true_valid
    bl drvalid
    cmp r0,#1
    beq return_true_valid
    return_false_valid:
    mov r0,#0
    ldmfd sp!,{r1-r6,pc} @ return   false
    return_true_valid:
    ldmfd sp!,{r1-r6,pc} @ return true




lvalid:     @(int i,int j,p) (r1,r2,r3)
    stmfd sp!, {r1-r8,lr}
    ldr r8,=Grid
    mov r4,#0 @local flag =0
    sub r2,r2,#1 @--j
    and r6,r3,#1            @temp=1+(p&1)
    add r6,r6,#1
    while_lvalid:
        cmp r2,#-1   @j>-1
        bgt l_v2 
        b return_false_lvalid
        l_v2:
        mov r5,r2
        mov r5,r5,lsl #3
        add r5,r5,r1
        mov r5,r5,lsl #2
        ldr r7,[r8,r5]
        
        cmp r7,r6
        bne return_true_lvalid
        mov r4,#1 @ flag=1
        sub r2,r2,#1 @ --j

        b while_lvalid
        

        return_false_lvalid:
        mov r0,#0
        ldmfd sp! ,{r1-r8,pc}
        return_true_lvalid:
        cmp r4,#1 @ checking Flag=1
        beq last_true_lvalid
        mov r0,#0 @ else return false
        ldmfd sp! ,{r1-r8,pc}
        last_true_lvalid:
        mov r5,r2
        mov r5,r5,lsl #3
        add r5,r5,r1
        mov r5,r5,lsl #2
        ldr r7,[r8,r5]
        cmp r7,r3
        beq final_true_l
        mov r0,#0 @ else return false
        ldmfd sp! ,{r1-r8,pc}
        final_true_l:
        mov r0,#1 @ return true
        ldmfd sp!,{r1-r8,pc}


rvalid:
    stmfd sp!, {r1-r8,lr}
    ldr r8,=Grid
    mov r4,#0 @local flag =0
    add r2,r2,#1 @++j
    and r6,r3,#1            @temp=1+(p&1)
    add r6,r6,#1
    while_rvalid:
        
        cmp r2,#8    @j<8
        blt r_v2 
        b return_false_rvalid
        r_v2:
        mov r5,r2
        mov r5,r5,lsl #3
        add r5,r5,r1
        mov r5,r5,lsl #2
        ldr r7,[r8,r5]
        
        cmp r7,r6
        bne return_true_rvalid
        add r2,r2,#1 @ ++j
        mov r4,#1 @ flag=1
        b while_rvalid
        

        return_false_rvalid:
        mov r0,#0
        ldmfd sp! ,{r1-r8,pc}
        return_true_rvalid:
        cmp r4,#1 @ checking Flag=1
        beq last_true_rvalid
        mov r0,#0 @ else return false
        ldmfd sp! ,{r1-r8,pc}
        last_true_rvalid:
        mov r5,r2
        mov r5,r5,lsl #3
        add r5,r5,r1
        mov r5,r5,lsl #2
        ldr r7,[r8,r5]
        cmp r7,r3
        beq final_true_r
        mov r0,#0 @ else return false
        ldmfd sp! ,{r1-r8,pc}
        final_true_r:
        mov r0,#1 @ return true
        ldmfd sp!,{r1-r8,pc}


uvalid:
    stmfd sp!, {r1-r8,lr}
    ldr r8,=Grid
    mov r4,#0 @local flag =0
    sub r1,r1,#1 @--i
    and r6,r3,#1 @temp=1+(p&1)
    add r6,r6,#1
    while_uvalid:
        
        cmp r1,#-1   @i>-1
        bgt u_v2 
        b return_false_uvalid
        u_v2:
        mov r5,r2
        mov r5,r5,lsl #3
        add r5,r5,r1
        mov r5,r5,lsl #2
        ldr r7,[r8,r5]
        
        cmp r7,r6
        bne return_true_uvalid
        sub r1,r1,#1 @ --i
        mov r4,#1 @ flag=1
        b while_uvalid
        

        return_false_uvalid:
        mov r0,#0
        ldmfd sp!,{r1-r8,pc}
        return_true_uvalid:
        cmp r4,#1  @checking Flag=1
        beq last_true_uvalid
        mov r0,#0  @else return false
        ldmfd sp!,{r1-r8,pc}
        last_true_uvalid:
        mov r5,r2
        mov r5,r5,lsl #3
        add r5,r5,r1
        mov r5,r5,lsl #2
        ldr r7,[r8,r5]
        cmp r7,r3
        beq final_true_u
        mov r0,#0 @ else return false
        ldmfd sp! ,{r1-r8,pc}
        final_true_u:
        mov r0,#1  @return true
        ldmfd sp!,{r1-r8,pc}


dvalid:
    stmfd sp!, {r1-r8,lr}
    ldr r8,=Grid
    mov r4,#0 @local flag =0
    add r1,r1,#1 @++i
    and r6,r3,#1            @temp=1+(p&1)
    add r6,r6,#1
    while_dvalid:
        
        cmp r1,#8    @i<8
        blt d_v2 
        b return_false_dvalid
        d_v2:
        mov r5,r2
        mov r5,r5,lsl #3
        add r5,r5,r1
        mov r5,r5,lsl #2
        ldr r7,[r8,r5]
        
        cmp r7,r6
        bne return_true_dvalid
        add r1,r1,#1 @ ++i
        mov r4,#1 @ flag=1
        b while_dvalid
        

        return_false_dvalid:
        mov r0,#0
        ldmfd sp! ,{r1-r8,pc}
        return_true_dvalid:
        cmp r4,#1 @ checking Flag=1
        beq last_true_dvalid
        mov r0,#0 @ else return false
        ldmfd sp! ,{r1-r8,pc}
        last_true_dvalid:
        mov r5,r2
        mov r5,r5,lsl #3
        add r5,r5,r1
        mov r5,r5,lsl #2
        ldr r7,[r8,r5]
        cmp r7,r3
        beq final_true_d
        mov r0,#0 @ else return false
        ldmfd sp! ,{r1-r8,pc}
        final_true_d:
        mov r0,#1 @ return true
        ldmfd sp!,{r1-r8,pc}


ulvalid:
    stmfd sp!, {r1-r8,lr}
    ldr r8,=Grid
    mov r4,#0 @local flag =0
    sub r1,r1,#1 @--i
    sub r2,r2,#1 @--j
    and r6,r3,#1            @temp=1+(p&1)
    add r6,r6,#1
    while_ulvalid:
        
        cmp r2,#-1   @j>-1
        bgt ul_vj
        b return_false_ulvalid
        ul_vj:
        cmp r1,#-1 @i>-1
        bgt ul_v2
        b return_false_ulvalid
        ul_v2:
        mov r5,r2
        mov r5,r5,lsl #3
        add r5,r5,r1
        mov r5,r5,lsl #2
        ldr r7,[r8,r5]
        
        cmp r7,r6
        bne return_true_ulvalid
        sub r2,r2,#1 @ --j
        sub r1,r1,#1 @ --i
        mov r4,#1 @ flag=1
        b while_ulvalid
        

        return_false_ulvalid:
        mov r0,#0
        ldmfd sp! ,{r1-r8,pc}
        return_true_ulvalid:
        cmp r4,#1 @ checking Flag=1
        beq last_true_ulvalid
        mov r0,#0 @ else return false
        ldmfd sp! ,{r1-r8,pc}
        last_true_ulvalid:
        mov r5,r2
        mov r5,r5,lsl #3
        add r5,r5,r1
        mov r5,r5,lsl #2
        ldr r7,[r8,r5]
        cmp r7,r3
        beq final_true_ul
        mov r0,#0 @ else return false
        ldmfd sp! ,{r1-r8,pc}
        final_true_ul:
        mov r0,#1 @ return true
        ldmfd sp!,{r1-r8,pc}

urvalid:
    stmfd sp!, {r1-r8,lr}
    ldr r8,=Grid
    mov r4,#0 @local flag =0
    sub r1,r1,#1 @--i
    add r2,r2,#1 @++j
    and r6,r3,#1            @temp=1+(p&1)
    add r6,r6,#1
    while_urvalid:
        
        cmp r2,#8    @j<8
        blt ur_vj
        b return_false_urvalid
        ur_vj:
        cmp r1,#-1 @i>-1
        bgt ur_v2
        b return_false_urvalid
        ur_v2:
        mov r5,r2
        mov r5,r5,lsl #3
        add r5,r5,r1
        mov r5,r5,lsl #2
        ldr r7,[r8,r5]
        
        cmp r7,r6
        bne return_true_urvalid
        add r2,r2,#1 @ ++j
        sub r1,r1,#1 @ --i
        mov r4,#1 @ flag=1
        b while_urvalid
        

        return_false_urvalid:
        mov r0,#0
        ldmfd sp! ,{r1-r8,pc}
        return_true_urvalid:
        cmp r4,#1 @ checking Flag=1
        beq last_true_urvalid
        mov r0,#0 @ else return false
        ldmfd sp! ,{r1-r8,pc}
        last_true_urvalid:
        mov r5,r2
        mov r5,r5,lsl #3
        add r5,r5,r1
        mov r5,r5,lsl #2
        ldr r7,[r8,r5]
        cmp r7,r3
        beq final_true_ur
        mov r0,#0 @ else return false
        ldmfd sp! ,{r1-r8,pc}
        final_true_ur:
        mov r0,#1 @ return true
        ldmfd sp!,{r1-r8,pc}


dlvalid:
    stmfd sp!, {r1-r8,lr}
    ldr r8,=Grid
    mov r4,#0 @local flag =0
    add r1,r1,#1 @++i
    sub r2,r2,#1 @--j
    and r6,r3,#1            @temp=1+(p&1)
    add r6,r6,#1
    while_dlvalid:
        
        cmp r2,#-1   @j>-1
        bgt dl_vj
        b return_false_dlvalid
        dl_vj:
        cmp r1,#8 @i<8
        blt dl_v2
        b return_false_dlvalid
        dl_v2:
        mov r5,r2
        mov r5,r5,lsl #3
        add r5,r5,r1
        mov r5,r5,lsl #2
        ldr r7,[r8,r5]
        
        cmp r7,r6
        bne return_true_dlvalid
        sub r2,r2,#1 @ --j
        add r1,r1,#1 @ ++i
        mov r4,#1 @ flag=1
        b while_dlvalid
        

        return_false_dlvalid:
        mov r0,#0
        ldmfd sp! ,{r1-r8,pc}
        return_true_dlvalid:
        cmp r4,#1 @ checking Flag=1
        beq last_true_dlvalid
        mov r0,#0 @ else return false
        ldmfd sp! ,{r1-r8,pc}
        last_true_dlvalid:
        mov r5,r2
        mov r5,r5,lsl #3
        add r5,r5,r1
        mov r5,r5,lsl #2
        ldr r7,[r8,r5]
        cmp r7,r3
        beq final_true_dl
        mov r0,#0 @ else return false
        ldmfd sp! ,{r1-r8,pc}
        final_true_dl:
        mov r0,#1 @ return true
        ldmfd sp!,{r1-r8,pc}    



drvalid:
    stmfd sp!, {r1-r8,lr}
    ldr r8,=Grid
    mov r4,#0 @local flag =0
    add r1,r1,#1 @++i
    add r2,r2,#1 @++j
    and r6,r3,#1            @temp=1+(p&1)
    add r6,r6,#1
    while_drvalid:
        
        cmp r2,#8    @j<8
        blt dr_vj
        b return_false_drvalid
        dr_vj:
        cmp r1,#8 @i<8
        blt dr_v2
        b return_false_drvalid
        dr_v2:
        mov r5,r2
        mov r5,r5,lsl #3
        add r5,r5,r1
        mov r5,r5,lsl #2
        ldr r7,[r8,r5]
        
        cmp r7,r6
        bne return_true_drvalid
        mov r4,#1 @ flag=1
        add r2,r2,#1 @ ++j
        add r1,r1,#1 @ ++i
        b while_drvalid
        

        return_false_drvalid:
        mov r0,#0
        ldmfd sp! ,{r1-r8,pc}
        return_true_drvalid:
        cmp r4,#1 @ checking Flag=1
        beq last_true_drvalid
        mov r0,#0 @ else return false
        ldmfd sp! ,{r1-r8,pc}
        last_true_drvalid:
        mov r5,r2
        mov r5,r5,lsl #3
        add r5,r5,r1
        mov r5,r5,lsl #2
        ldr r7,[r8,r5]
        cmp r7,r3
        beq final_true_dr
        mov r0,#0 @ else return false
        ldmfd sp! ,{r1-r8,pc}
        final_true_dr:
        mov r0,#1 @ return true
        ldmfd sp!,{r1-r8,pc}    



@ r1, r2 = i, j
@ r8 = Grid
@ r3 = p
@ r6 = temp
@ r9 = grid[i,lsl #2][j,lsl #2]
makemove:
    stmfd sp!, {r1-r8,lr}
    ldr r8,=Grid
    mov r4, r2, lsl #3
    add r5, r1, r4
    str r3, [r8, r5,lsl #2]
    bl lmove
    bl rmove
    bl umove
    bl dmove
    bl ulmove
    bl urmove
    bl dlmove
    bl drmove
    ldmfd sp!, {r1-r8,pc}

lmove:
    stmfd sp!, {r1-r8,lr}
    sub r2, r2, #1
    cmp r3, #1
    beq ltemp
    mov r6, #1
    b lskip
ltemp:
    mov r6, #2
lskip:
    cmp r2, #-1
    beq lstop
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9 , r6
    bne lstop
    sub r2, r2, #1
    b lskip
lstop:
    cmp r2, #-1
    beq lreturn
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9 , r3
    bne lreturn 
lwhile:
    add r2, r2, #1
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9, r6
    bne lreturn
    add r1, r1, r2, lsl #3
    str r3, [r8, r1,lsl #2]
    sub r1, r1, r2, lsl #3
    b lwhile
lreturn:
    ldmfd sp!, {r1-r8,pc}

rmove:
    stmfd sp!, {r1-r8,lr}
    add r2, r2, #1
    cmp r3, #1
    beq rtemp
    mov r6, #1
    b rskip
rtemp:
    mov r6, #2
rskip:
    cmp r2, #8 
    beq rstop
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9 , r6
    bne rstop
    add r2, r2, #1
    b rskip
rstop:
    cmp r2, #8
    beq rreturn
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9 , r3
    bne rreturn 
rwhile:
    sub r2, r2, #1
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9, r6
    bne rreturn
    add r1, r1, r2, lsl #3
    str r3, [r8, r1,lsl #2]
    sub r1, r1, r2, lsl #3
    b rwhile
rreturn:
    ldmfd sp!, {r1-r8,pc}

dmove:
    stmfd sp!, {r1-r8,lr}
    add r1, r1, #1
    cmp r3, #1
    beq dtemp
    mov r6, #1
    b dskip
dtemp:
    mov r6, #2
dskip:
    cmp r1, #8 
    beq dstop
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9 , r6
    bne dstop
    add r1, r1, #1
    b dskip
dstop:
    cmp r1, #8
    beq dreturn
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9 , r3
    bne dreturn 
dwhile:
    sub r1, r1, #1
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9, r6
    bne dreturn
    add r1, r1, r2, lsl #3
    str r3, [r8, r1,lsl #2]
    sub r1, r1, r2, lsl #3
    b dwhile
dreturn:
    ldmfd sp!, {r1-r8,pc}

umove:
    stmfd sp!, {r1-r8,lr}
    sub r1, r1, #1
    cmp r3, #1
    beq utemp
    mov r6, #1
    b uskip
utemp:
    mov r6, #2
uskip:
    cmp r1, #-1
    beq ustop
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9 , r6
    bne ustop
    sub r1, r1, #1
    b uskip
ustop:
    cmp r2, #-1
    beq ureturn
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9 , r3
    bne ureturn 
uwhile:
    add r1, r1, #1
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9, r6
    bne ureturn
    add r1, r1, r2, lsl #3
    str r3, [r8, r1,lsl #2]
    sub r1, r1, r2, lsl #3
    b uwhile
ureturn:
    ldmfd sp!, {r1-r8,pc}

ulmove:
    stmfd sp!, {r1-r8, lr}
    sub r1, r1, #1
    sub r2, r2, #1
    cmp r3, #1
    beq ultemp
    mov r6, #1
    b ulskip
ultemp:
    mov r6, #2
ulskip:
    cmp r1, #-1
    beq ulstop
    cmp r2, #-1
    beq ulstop
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9, r6
    bne ulstop
    sub r1, r1, #1
    sub r2, r2, #1
    b ulskip
ulstop:
    cmp r2, #-1
    beq ulreturn
    cmp r1, #-1
    beq ulreturn 
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9, r3
    bne ulreturn 
ulwhile:
    add r1, r1, #1
    add r2, r2, #1
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9, r6
    bne ulreturn
    add r1, r1, r2, lsl #3
    str r3, [r8, r1,lsl #2]
    sub r1, r1, r2, lsl #3
    b ulwhile
ulreturn:   
    ldmfd sp!, {r1-r8, pc}

urmove:
    stmfd sp!, {r1-r8,lr}
    add r2, r2, #1
    sub r1, r1, #1
    cmp r3, #1
    beq urtemp
    mov r6, #1
    b urskip
urtemp:
    mov r6, #2
urskip:
    cmp r2, #8 
    beq urstop
    cmp r1, #-1
    beq urstop
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1, lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9 , r6
    bne urstop
    add r2, r2, #1
    sub r1, r1, #1
    b urskip
urstop:
    cmp r2, #8
    beq urreturn
    cmp r1, #-1
    beq urreturn
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1, lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9 , r3
    bne urreturn 
urwhile:
    sub r2, r2, #1
    add r1, r1, #1
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9, r6
    bne urreturn
    add r1, r1, r2, lsl #3
    str r3, [r8, r1,lsl #2]
    sub r1, r1, r2, lsl #3
    b urwhile
urreturn:
    ldmfd sp!, {r1-r8,pc}

dlmove:
    stmfd sp!, {r1-r8,lr}
    add r1, r1, #1
    sub r2, r2, #1
    cmp r3, #1
    beq dltemp
    mov r6, #1
    b dlskip
dltemp:
    mov r6, #2
dlskip:
    cmp r1, #8 
    beq dlstop
    cmp r2, #-1
    beq dlstop
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9 , r6
    bne dlstop
    add r1, r1, #1
    sub r2, r2, #1
    b dlskip
dlstop:
    cmp r1, #8
    beq dlreturn
    cmp r2, #-1
    beq dlreturn 
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9 , r3
    bne dlreturn 
dlwhile:
    sub r1, r1, #1
    add r2, r2, #1
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9, r6
    bne dlreturn
    add r1, r1, r2, lsl #3
    str r3, [r8, r1,lsl #2]
    sub r1, r1, r2, lsl #3
    b dlwhile
dlreturn:
    ldmfd sp!, {r1-r8,pc}

drmove:
    stmfd sp!, {r1-r8,lr}
    add r1, r1, #1
    add r2, r2, #1
    cmp r3, #1
    beq drtemp
    mov r6, #1
    b drskip
drtemp:
    mov r6, #2
drskip:
    cmp r1, #8 
    beq drstop
    cmp r2, #8
    beq drstop
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9 , r6
    bne drstop
    add r1, r1, #1
    add r2, r2, #1
    b drskip
drstop:
    cmp r1, #8
    beq drreturn
    cmp r2, #8
    beq drreturn 
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9 , r3
    bne drreturn 
drwhile:
    sub r1, r1, #1
    sub r2, r2, #1
    add r1, r1, r2, lsl #3
    ldr r9, [r8, r1,lsl #2] 
    sub r1, r1, r2, lsl #3
    cmp r9, r6
    bne drreturn
    add r1, r1, r2, lsl #3
    str r3, [r8, r1,lsl #2]
    sub r1, r1, r2, lsl #3
    b drwhile
drreturn:
    ldmfd sp!, {r1-r8,pc}





    
print:
    stmfd sp!,{r0-r7,lr}
    mov r0,#0 @i=0
    mov r1,#0 @j=0
    ldr r3,=Grid
    mov r5,#8 @ const 8
    mov r6,#4
    print_loop:
    mul r7,r0,r5 @ check this
    add r7,r7,r1 @check this 
    mul r7,r6,r7
    ldr r4,[r3,r7]
    cmp r4,#0
    beq print_Emp
    cmp r4,#1
    beq print_White
    cmp r4,#2
    beq print_Black
    print_done:
    add r0,r0,#1
    cmp r0,r5
    beq set
    set_over:
    cmp r1,r5
    blt print_loop
    ldmfd sp!,{r0-r7,pc}


print_White:
    ldr r2,=White
    swi 0x204 @ display message
    b print_done

print_Black:
    ldr r2,=Black
    swi 0x204 @ display message
    b print_done

print_Emp:
    ldr r2,=Emp
    swi 0x204 @ display message
    b print_done

set:
    add r1,r1,#1
    mov r0,#0
    b set_over

exit:

    swi SWI_EXIT

.data
Grid: .space 256
Emp: .asciz "-" @0
White: .asciz "O" @1
Black: .asciz "X" @2
        .end

