################ CSC258H1F Winter 2024 Assembly Final Project ##################
# This file contains our implementation of Tetris.
#
# Student: Shih-Hsin Chuang, 1008727754
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   352
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

.data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL: .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD: .word 0xffff0000

##############################################################################
# Mutable Data
############################################################################
# The height of the vertical walls
wall_height: .word 64
# The length  of the horizontal wall
wall_length: .word 32
# The width of the walls
wall_width: .word 2
# The version of tetromino to draw 
version: .word 0
# The current starting x position of the current tetromino
curr_x: .word 16
# The current starting y position of the current tetromino
curr_y: .word 0
# The current type of the tetromino (T = 0, L = 1, J = 2, S = 3, Z = 4, I = 5, O = 6)
curr_type: .word 6
# The current shape of the tetromino
curr_shape: .word 0
# The x position of new piece to come
new_piece_x: .word 16
# The y position of the new piece to come 
new_piece_y: .word 0
# Whether to store the current tetromino (1 = no store, 0 = yes store)
store_tetromino: .word 0
# Whether we need to create a new piece (1 = no new piece, 0 = yes new piece)
new_piece: .word 1
# Whether the game now is paused (1 = not paused, 0 = paused)
paused: .word 1 
# The auto drop counter
auto_drop: .word 0
# The dropping rate of tetrominos
drop_rate: .word 34
# Paused display
paused_x: .word 2, 2, 2, 2, 2, 3, 4, 4, 4, 3, 7, 7, 7, 7, 8, 9, 9, 9, 9, 8, 12, 12, 12, 12, 12, 13, 14, 14, 14, 14, 14, 19, 18, 17, 17, 17, 18, 19, 19, 19, 18, 17, 22, 22, 22, 22, 22, 23, 24, 23, 24, 23, 24, 27, 27, 27, 27, 27, 28, 28, 29, 29, 29                              
paused_y: .word 19, 20, 21, 22, 23, 19, 19, 20, 21, 21, 23, 22, 21, 20, 19, 20, 21, 22, 23, 21, 19, 20, 21, 22, 23, 23, 23, 22, 21, 20, 19, 19, 19, 19, 20, 21, 21, 21, 22, 23, 23, 23, 19, 20, 21, 22, 23, 19, 19, 21, 21, 23, 23, 19, 20, 21, 22, 23, 19, 23, 20, 21, 22 
# Game over display
game_over_x: .word 2, 2, 2, 2, 2, 3, 4, 4, 4, 4, 4, 7, 8, 9, 12, 12, 12, 12, 12, 13, 14, 17, 17, 17, 17, 17, 18, 19, 18, 19, 19, 19, 19, 22, 23, 24, 22, 22, 23, 24, 24, 24, 22, 23, 27, 27, 27, 27, 27, 28, 29, 28, 29, 28, 29                            
game_over_y: .word 19, 20, 21, 22, 23, 23, 23, 22, 21, 20, 19, 21, 21, 21, 19, 20, 21, 22, 23, 23, 23, 19, 20, 21, 22, 23, 23, 23, 19, 19, 20, 21, 22, 19, 19, 19, 20, 21, 21, 21, 22, 23, 23, 23, 19, 20, 21, 22, 23, 19, 19, 21, 21, 23, 23                       
# Restart display
restart_x: .word 7, 7, 7, 7, 7, 8, 9, 8, 9, 10, 9, 10
restart_y: .word 30, 31, 32, 33, 34, 30, 30, 32, 32, 31, 33, 34
# Quit display
quit_x: .word 20, 20, 20, 23, 23, 23, 21, 22, 21, 22, 24
quit_y: .word 31, 32, 33, 31, 32, 33, 30, 30, 34, 34, 34
# Whether the PAUSED sign has been drawn (1 = not yet, 0 = yes)
paused_drawn: .word 1 
# Whether the U-LOSE sign has been drawn (1 = not yet, 0 = yes)
game_over_drawn: .word 1

# A Collision detection constants for t shapes
t_collision_A: .word -8, 256, -1, -1, -8, 256, -256, -1, -8, -256, -1, -1, 0, -256, 256, -1, -1 
# D Collision detection constants for t shapes
t_collision_D: .word 24, 272, -1, -1, -240, 16, 272, -1, 24, -240, -1, -1, 24, -240, 272, -1
# S Collision detection constants for t shapes
t_collision_S: .word 256, 520, 272, -1, 256, 520, -1, -1, 256, 264, 272, -1, 520, 272, -1, -1
# W Collision detection constants for t shapes
t_collision_W: .word -248, -1, -1, -1, 16, -1, -1, -1, 264, -1, -1, -1, -1, 0, -1, -1, -1

# A Collision detection constants for l shapes
l_collision_A: .word -8, 248, 504, -1, 248, 504, -1, -1, -8, 256, 512, -1, 248, 8, -1, -1
# D Collision detection constants for l shapes
l_collision_D: .word 8, 264, 528, -1, 520, 280, -1, -1, 16, 272, 528, -1, 24, 280, -1, -1
# S Collision detection constants for l shapes
l_collision_S: .word 768, 776, -1, -1, 768, 520, 528, -1, 256, 776, -1, -1, 512, 520, 528, -1
# W Collision detection constants for l shapes
l_collision_W: .word 264, 272, -1, -1, 0, 8, 520, -1, 256, 16, 272, -1, 8, 520, 528, -1

# A Collision detection constants for j shapes
j_collision_A: -8, 248, 496, -1, -16, 240, -1, -1, -8, 248, 504, -1, 240, 512, -1, -1
# D Collision detection constants for j shapes
j_collision_D: 8, 264, 520, -1, 0, 272, -1, -1, 16, 264, 520, -1, 272, 528, -1, -1
# S Collision detection constants for j shapes
j_collision_S: 760, 768, -1, -1, 504, 512, 520, -1, 768, 264, -1, -1, 504, 512, 776, -1 
# W Collision detection constants for j shapes
j_collision_W: -8, 248, 264, -1, 0, 8, 512, -1, 248, 264, 520, -1, 0, 504, 512, -1

# A Collision detection constants for s shapes
s_collision_A: -8, 240, -1, -1, -272, -16, 248, -1, -8, 240, -1, -1, -272, -16, 248, -1
# D Collision detection constants for s shapes
s_collision_D: 16, 264, -1, -1, -256, 8, 264, -1, 16, 264, -1, -1, -256, 8, 264, -1 
# S Collision detection constants for s shapes
s_collision_S: 264, 512, 504, -1, 248, 512, -1, -1, 264, 512, 504, -1, 248, 512, -1, -1
# W Collision detection constants for s shapes
s_collision_W: -264, -8, -1, -1, 240, 248, 8, -1, -264, -8, -1, -1, 240, 248, 8, -1

# A Collision detection constants for z shapes
z_collision_A: -16, 248, -1, -1, -264, -16, 240, -1, -16, 248, -1, -1, -264, -16, 240, -1
# D Collision detection constants for z shapes
z_collision_D: 8, 272, -1, -1, -248, 8, 256, -1, 8, 272, -1, -1, -248, 8, 256, -1 
# S Collision detection constants for z shapes
z_collision_S: 248, 512, 520, -1, 256, 504, -1, -1, 248, 512, 520, -1, 256, 504, -1, -1
# W Collision detection constants for z shapes
z_collision_W: -256, 248, -1, -1, 256, 264, -1, -1, -256, 248, -1, -1, 256, 264, -1, -1

# A Collision detection constants for i shapes
i_collision_A: -264, -8, 248, 504, -16, -1, -1, -1, -264, -8, 248, 504, -16, -1, -1, -1 
# D Collision detection constants for i shapes
i_collision_D: -248, 8, 264, 520, 24, -1, -1, -1, -248, 8, 264, 520, 24, -1, -1, -1
# S Collision detection constants for i shapes
i_collision_S: 768, -1, -1, -1, 248, 256, 264, 272, 768, -1, -1, -1, 248, 256, 264, 272
# W Collision detection constants for i shapes
i_collision_W: -8, 8, 16, -1, -256, 256, 512, -1, -8, 8, 16, -1, -256, 256, 512, -1

# A Collision detection constants for o shapes
o_collision_A: -272, -16, -1, -1, -272, -16, -1, -1, -272, -16, -1, -1, -272, -16, -1, -1
# D Collision detection constants for o shapes
o_collision_D: -248, 8, -1, -1, -248, 8, -1, -1, -248, 8, -1, -1, -248, 8, -1, -1
# S Collision detection constants for o shapes
o_collision_S: 248, 256, -1, -1, 248, 256, -1, -1, 248, 256, -1, -1, 248, 256, -1, -1
# W Collision detection constants for o shapes
o_collision_W: -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1

# The color value of each position of the grid
grid_data: .byte 0x00:352
##############################################################################

##############################################################################
# Code
##############################################################################
.text
.globl main

	# Run the Tetris game.
main:
    # Initialize the game
    lw $t0, ADDR_DSPL  # $t0 = base address for display
    
draw_grids:
    lw $t0, ADDR_DSPL         # reset $t0 to base address
    addi $a0, $zero, 0        # set staring x coordinate of the grid
    addi $a1, $zero, 0        # set starting y coordinate of the grid
    addi $a2, $zero, 2        # set width of each square 
    addi $a3, $zero, 2        # set length of each square
    
    # Drawing the gird
    j row_type_two
    draw_grid:
    addi $a1, $a1, 2          # increase starting y coordinate of the square by 2
    addi $a0, $zero, 0        # set staring x coordinate of the grid
    j row_type_one
    
    continue1:
    addi $a1, $a1, 2          # increase starting y coordinate of the square by 2
    addi $a0, $zero, 0        # set staring x coordinate of the grid
    j row_type_two
    
    continue2:
    beq $a1, 44, end_grid    # stop when y reaches its stopping index
    j draw_grid
    
    end_grid:
    j draw_walls
    
    row_type_one:
    addi $a0, $a0, 2          # increase starting x coordinate of the square by 2
    li $t4, 0x17161A          # set the color to be dark gray
    jal draw_line             # draw a dark gray square
    addi $a0, $a0, 2          # increase starting x coordinate of the square by 2
    li $t4, 0x1b1b1b          # set the color to be light gray
    jal draw_line             # draw a light gray square
    beq $a0, 28, loop1_end    # Stop when x reaches its stopping index
    j row_type_one
    
    loop1_end:
    j continue1
    
    row_type_two:
    addi $a0, $a0, 2          # increase starting x coordinate of the square by 2
    li $t4, 0x1b1b1b          # set the color to be light gray
    jal draw_line             # draw a dark gray square
    addi $a0, $a0, 2          # increase starting x coordinate of the square by 2
    li $t4, 0x17161A          # set the color to be dark gray
    jal draw_line             # draw a light gray square
    beq $a0, 28, loop2_end    # Stop when x reaches its stopping index
    j row_type_two
    
    loop2_end:
    j continue2
    
# Drawing grids with current tetrominos
draw_tetrominos_grid:
    lw $t0, ADDR_DSPL                # reset $t0 to base address
    addi $a0, $zero, 0               # set staring x coordinate of the grid
    addi $a1, $zero, 0               # set starting y coordinate of the grid
    addi $a2, $zero, 2               # set width of each square 
    addi $a3, $zero, 2               # set length of each square
    la $t2, grid_data                # load the first address of the grid data array
    
    draw_tetro_grid:
    beq $a1, 44, end_drawing
    # Get colour
    la $t2, grid_data                # load the first address of the grid data array
    sll $t3, $a0, 2                  # convert the x offset into pixels
    sll $t5, $a1, 7                  # convert the y offset into pixels
    add $t3, $t3, $t5                # $t3 is the total offset from $t0
    add $t2, $t2, $t3                # get the current position of the grid data
    lw $t4, 0($t2)                   # load the colour from the position
    # Draw colour at the position
    jal draw_line
    addi $a0, $a0, 2                 # increase starting x coordinate of the square by 2
    bne $a0, 32, draw_tetro_grid
    addi $a1, $a1, 2                 # increase starting y coordinate of the square by 2
    addi $a0, $zero, 0               # set staring x coordinate of the grid
    j draw_tetro_grid
    
    end_drawing:
    lw $t1, new_piece
    beq $t1, 0, generate_new_piece
    j draw_tetromino

# Drawing 3 walls
draw_walls:
    li $t4, 0xf0f0f0                # set the wall colour to be white
    
    # Vertical left line
    addi $a0, $zero, 0              # set staring x coordinate of the line
    addi $a1, $zero, 0              # set starting y coordinate of the line
    lw $t1, wall_width              # load the width of the wall
    lw $t2, wall_height             # load the height of the walls
    add $a2, $zero, $t1             # set width of line
    add $a3, $zero, $t2             # set length of line
    jal draw_line                   # call the line-drawing function
    
    # Vertical right line
    addi $a0, $zero, 30             # set staring x coordinate of the line
    addi $a1, $zero, 0              # set starting y coordinate of the line
    lw $t1, wall_width              # load the width of the wall
    lw $t2, wall_height             # load the height of the walls
    add $a2, $zero, $t1             # set width of line 
    add $a3, $zero, $t2             # set length of line
    jal draw_line                   # call the line-drawing function
    
    # Horizontal bottom line
    addi $a0, $zero, 0              # set staring x coordinate of the line
    addi $a1, $zero, 42             # set starting y coordinate of the line
    lw $t1, wall_width              # load the width of the wall
    lw $t2, wall_length             # load the height of the walls
    add $a2, $zero, $t2             # set width of line 
    add $a3, $zero, $t1             # set length of line
    jal draw_line 
    la $t3, store_tetromino
	li $t9, 1
	sw $t9, 0($t3)                  # we don't want to store the tetromino   
    j draw_tetromino

# Draw squares with specified width and length at (x, y)
draw_line:
    lw $t0, ADDR_DSPL               # reset $t0 to base address 
    sll $t2, $a1, 7                 # convert vertical offset to pixels (by multiplying $a1 by 128)
    sll $t6, $a3, 7                 # convert height of line from pixels to rows of bytes (by multiplying $a3 by 128)
    add $t6, $t2, $t6               # calculate value of $t2 for the last line in the rectangle.
    
    outer_top:
    sll $t1, $a0, 2                 # convert horizontal offset to pixels (by multiplying $a0 by 4)
    sll $t5, $a2, 2                 # convert length of line from pixels to bytes (by multiplying $a2 by 4)
    add $t5, $t1, $t5               # calculate value of $t1 for end of the horizontal line.

    inner_top:
    add $t3, $t1, $t2               # store the total offset of the starting pixel (relative to $t0)
    lw $t9, store_tetromino
    beq $t9, 1, inner_loop_continue # 0 = store the value into the array, 1 = don't store the value into the array
    la $t8, grid_data               # load the first address of the grid data into $t8
    add $t8, $t8, $t3               # add the offset relative to $t0
    sw $t4, 0($t8)                  # store the color in $t4 into the corresponding grid position
    
    inner_loop_continue:
    add $t3, $t0, $t3               # calculate the location of the starting pixel ($t0 + offset)
    sw $t4, 0($t3)                  # paint the current unit on the first row with color in $t4
    
    addi $t1, $t1, 4                # move horizontal offset to the right by one pixel
    beq $t1, $t5, inner_end         # break out of the line-drawing loop
    j inner_top                     # jump to the start of the inner loop
    
    inner_end:
    addi $t2, $t2, 128              # move vertical offset down by one line
    beq $t2, $t6, outer_end         # on last line, break out of the outer loop
    j outer_top                     # jump to the top of the outer loop
    
    outer_end:
    jr $ra                          # return to calling program

generate_random_value:
    li $v0 , 42
    li $a0 , 0
    li $a1 , 7                      # generate random values from 0 to 6 
    syscall 

# Draw a tetromino, any shape is possible
draw_tetromino:
    lw $t0, curr_type               # load the current type of tetromino to draw 
    beq $t0, 0, draw_T_tetromino    # 0 = T tetromino
    beq $t0, 1, draw_L_tetromino    # 1 = L tetromino
    beq $t0, 2, draw_J_tetromino    # 2 = J tetromino
    beq $t0, 3, draw_S_tetromino    # 3 = S tetromino
    beq $t0, 4, draw_Z_tetromino    # 4 = Z tetromino
    beq $t0, 5, draw_I_tetromino    # 5 = I tetromino
    beq $t0, 6, draw_O_tetromino    # 6 = O tetromino

# Draw a single T tetromino
draw_T_tetromino:
    lw $t9, version                 # get the version of tetromino to draw
    beq $t9, 0, rotate0_T
    beq $t9, 1, rotate1_T
    beq $t9, 2, rotate2_T
    beq $t9, 3, rotate3_T 
    
rotate0_T:
    lw $t0, ADDR_DSPL               # reset $t0 to base address
    li $t4, 0xff0000                # $t4 stores the colour of the tetromino as red
    lw $a0, curr_x                  # $a0 stores the x position of the tetromino 
    lw $a1, curr_y                  # $a1 stores the y position of the tetromino
    addi $a2, $zero, 2              # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2              # $a3 stores the length of the tetromino
    addi $t7, $a0, 6                # $t7 stores the stopping x position 
    
    draw_part0_T:
    jal draw_line                   # draw a squre of the tetromino
    addi $a0, $a0, 2                # increase starting x coordinate of the square by 2
    beq $a0, $t7, next_tetromino0_T
    j draw_part0_T
    
    next_tetromino0_T:
    addi $a1, $a1, 2                # increase starting y coordinate of the square by 2
    subi $a0, $a0, 4                # decrease starting x coordinate of the square by 4
    jal draw_line
    la $t1, curr_shape
    li $t2, 1
    sw $t2, 0($t1)                  # set the curr_shape as 1
    lw $t9, store_tetromino
    bne $t9, 0, game_loop           # check if we want to store the tetromino
    j remove_lines                  # check for if any row is full
    
rotate1_T:
    lw $t0, ADDR_DSPL               # reset $t0 to base address
    li $t4, 0xff0000                # $t4 stores the colour of the tetromino as red
    lw $a0, curr_x                  # $a0 stores the x position of the tetromino 
    addi $a0, $a0, 2                # increase $a0 by 2
    lw $a1, curr_y                  # $a1 stores the y position of the tetromino
    subi $a1, $a1, 2                # decrease $a1 by 2
    addi $a2, $zero, 2              # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2              # $a3 stores the length of the tetromino
    addi $t7, $a1, 6                # $t7 stores the stopping y position 
    
    draw_parts1_T:
    jal draw_line                   # draw a squre of the tetromino
    addi $a1, $a1, 2                # increase starting y coordinate of the square by 2
    beq $a1, $t7, next_tetromino1_T
    j draw_parts1_T
    
    next_tetromino1_T:
    subi $a1, $a1, 4                # decrease starting y coordinate of the square by 2
    subi $a0, $a0, 2                # decrease starting x coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 2
    sw $t2, 0($t1)                  # set the curr_shape as 2
    lw $t9, store_tetromino
    bne $t9, 0, game_loop           # check if we want to store the tetromino
    j remove_lines
    
rotate2_T:
    lw $t0, ADDR_DSPL               # reset $t0 to base address
    li $t4, 0xff0000                # $t4 stores the colour of the tetromino as red
    lw $a0, curr_x                  # $a0 stores the x position of the tetromino
    lw $a1, curr_y                  # $a1 stores the y position of the tetromino
    addi $a2, $zero, 2              # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2              # $a3 stores the length of the tetromino
    addi $t7, $a0, 6                # $t7 stores the stopping x position 
    
    draw_parts2_T:
    jal draw_line                   # draw a squre of the tetromino
    addi $a0, $a0, 2                # increase starting x coordinate of the square by 2
    beq $a0, $t7, next_tetromino2_T
    j draw_parts2_T
    
    next_tetromino2_T:
    subi $a1, $a1, 2                # decrease starting y coordinate of the square by 2
    subi $a0, $a0, 4                # decrease starting x coordinate of the square by 4
    jal draw_line
    la $t1, curr_shape
    li $t2, 3
    sw $t2, 0($t1)                  # set the curr_shape as 3
    lw $t9, store_tetromino
    bne $t9, 0, game_loop           # check if we want to store the tetromino
    j remove_lines
    
rotate3_T:
    lw $t0, ADDR_DSPL               # reset $t0 to base address
    li $t4, 0xff0000                # $t4 stores the colour of the tetromino as red
    lw $a0, curr_x                  # $a0 stores the x position of the tetromino 
    addi $a0, $a0, 2                # Increase $a0 by 2
    lw $a1, curr_y                  # $a1 stores the y position of the tetromino
    subi $a1, $a1, 2                # Decrease $a1 by 2
    addi $a2, $zero, 2              # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2              # $a3 stores the length of the tetromino
    addi $t7, $a1, 6                # $t7 stores the stopping y position 
    
    draw_parts3_T:
    jal draw_line                   # draw a squre of the tetromino
    addi $a1, $a1, 2                # increase starting y coordinate of the square by 2
    beq $a1, $t7, next_tetromino3_T
    j draw_parts3_T
    
    next_tetromino3_T:
    subi $a1, $a1, 4                # decrease starting y coordinate of the square by 2
    addi $a0, $a0, 2                # decrease starting x coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 4
    sw $t2, 0($t1)                  # set the curr_shape as 4
    lw $t9, store_tetromino
    bne $t9, 0, game_loop           # check if we want to store the tetromino
    j remove_lines
    
# Draw a single L tetromino
draw_L_tetromino:
    lw $t9, version                 # get the version of tetromino to draw
    beq $t9, 0, rotate0_L
    beq $t9, 1, rotate1_L
    beq $t9, 2, rotate2_L
    beq $t9, 3, rotate3_L 
    
rotate0_L:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0xff6600            # $t4 stores the colour of the tetromino as orange
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a1, 6            # $t7 stores the stopping y position 
    
    draw_part0_L:
    jal draw_line               # draw a squre of the tetromino
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    beq $a1, $t7, next_tetromino0_L
    j draw_part0_L
    
    next_tetromino0_L:
    subi $a1, $a1, 2            # decrease starting y coordinate of the square by 2
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 5
    sw $t2, 0($t1)              # set the curr_shape as 5
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines              # check for if any row is full
    
rotate1_L:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0xff6600            # $t4 stores the colour of the tetromino as orange
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    addi $a1, $a1, 2            # increase $a1 by 2
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a1, 4            # $t7 stores the stopping y position 
    
    draw_parts1_L:
    jal draw_line               # draw a squre of the tetromino
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    beq $a1, $t7, next_tetromino1_L
    j draw_parts1_L
    
    next_tetromino1_L:
    subi $a1, $a1, 4            # decrease starting y coordinate of the square by 4
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    jal draw_line
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 6
    sw $t2, 0($t1)              # set the curr_shape as 6
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
rotate2_L:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0xff6600            # $t4 stores the colour of the tetromino as orange
    lw $a0, curr_x              # $a0 stores the x position of the tetromino
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a0, 4            # $t7 stores the stopping x position 
    
    draw_parts2_L:
    jal draw_line               # draw a squre of the tetromino
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    beq $a0, $t7, next_tetromino2_L
    j draw_parts2_L
    
    next_tetromino2_L:
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    subi $a0, $a0, 2            # decrease starting x coordinate of the square by 2
    jal draw_line
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 7
    sw $t2, 0($t1)              # set the curr_shape as 7
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
rotate3_L:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0xff6600            # $t4 stores the colour of the tetromino as orange
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    addi $a1, $a1, 2            # Increase $a1 by 2
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a0, 6            # $t7 stores the stopping x position 
    
    draw_parts3_L:
    jal draw_line               # draw a squre of the tetromino
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    beq $a0, $t7, next_tetromino3_L
    j draw_parts3_L
    
    next_tetromino3_L:
    subi $a1, $a1, 2            # decrease starting y coordinate of the square by 2
    subi $a0, $a0, 2            # decrease starting x coordinate of the square by 4
    jal draw_line
    la $t1, curr_shape
    li $t2, 8
    sw $t2, 0($t1)              # set the curr_shape as 8
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
# Draw a single J tetromino
draw_J_tetromino:
    lw $t9, version             # get the version of tetromino to draw
    beq $t9, 0, rotate0_J
    beq $t9, 1, rotate1_J
    beq $t9, 2, rotate2_J
    beq $t9, 3, rotate3_J 
    
rotate0_J:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0xfff200            # $t4 stores the colour of the tetromino as yellow
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a1, 6            # $t7 stores the stopping y position 
    
    draw_part0_J:
    jal draw_line               # draw a squre of the tetromino
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    beq $a1, $t7, next_tetromino0_J
    j draw_part0_J
    
    next_tetromino0_J:
    subi $a1, $a1, 2            # decrease starting y coordinate of the square by 2
    subi $a0, $a0, 2            # decrease starting x coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 9
    sw $t2, 0($t1)              # set the curr_shape as 9
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines              # check for if any row is full
    
rotate1_J:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0xfff200            # $t4 stores the colour of the tetromino as yellow
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    subi $a0, $a0, 2            # decrease $a0 by 2
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a1, 4            # $t7 stores the stopping y position 
    
    draw_parts1_J:
    jal draw_line               # draw a squre of the tetromino
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    beq $a1, $t7, next_tetromino1_J
    j draw_parts1_J
    
    next_tetromino1_J:
    subi $a1, $a1, 2            # decrease starting y coordinate of the square by 2
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    jal draw_line
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 10
    sw $t2, 0($t1)              # set the curr_shape as 10
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
rotate2_J:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0xfff200            # $t4 stores the colour of the tetromino as yellow
    lw $a0, curr_x              # $a0 stores the x position of the tetromino
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a0, 4            # $t7 stores the stopping x position 
    
    draw_parts2_J:
    jal draw_line               # draw a squre of the tetromino
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    beq $a0, $t7, next_tetromino2_J
    j draw_parts2_J
    
    next_tetromino2_J:
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    subi $a0, $a0, 4            # decrease starting x coordinate of the square by 4
    jal draw_line
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 11
    sw $t2, 0($t1)              # set the curr_shape as 11
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
rotate3_J:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0xfff200            # $t4 stores the colour of the tetromino as yellow
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    subi $a0, $a0, 2            # Decrease $a0 by 2
    addi $a1, $a1, 2            # Increase $a1 by 2
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a0, 6            # $t7 stores the stopping x position 
    
    draw_parts3_J:
    jal draw_line               # draw a squre of the tetromino
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    beq $a0, $t7, next_tetromino3_J
    j draw_parts3_J
    
    next_tetromino3_J:
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    subi $a0, $a0, 2            # decrease starting x coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 12
    sw $t2, 0($t1)              # set the curr_shape as 12
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
# Draw a single S tetromino
draw_S_tetromino:
    lw $t9, version             # get the version of tetromino to draw
    beq $t9, 0, rotate0_S
    beq $t9, 1, rotate1_S
    beq $t9, 2, rotate2_S
    beq $t9, 3, rotate3_S 
    
rotate0_S:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0x3cb043            # $t4 stores the colour of the tetromino as green
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a0, 4            # $t7 stores the stopping x position 
    
    draw_part0_S:
    jal draw_line               # draw a squre of the tetromino
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    beq $a0, $t7, next_tetromino0_S
    j draw_part0_S
    
    next_tetromino0_S:
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    subi $a0, $a0, 6            # decrease starting x coordinate of the square by 6
    jal draw_line
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 13
    sw $t2, 0($t1)              # set the curr_shape as 13
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines              # check for if any row is full
    
rotate1_S:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0x3cb043            # $t4 stores the colour of the tetromino as green
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    subi $a0, $a0, 2            # decrease $a0 by 2
    subi $a1, $a1, 2            # decrease $a1 by 2
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a1, 4            # $t7 stores the stopping y position 
    
    draw_parts1_S:
    jal draw_line               # draw a squre of the tetromino
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    beq $a1, $t7, next_tetromino1_S
    j draw_parts1_S
    
    next_tetromino1_S:
    subi $a1, $a1, 2            # decrease starting y coordinate of the square by 2
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    jal draw_line
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 14
    sw $t2, 0($t1)              # set the curr_shape as 14
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
rotate2_S:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0x3cb043            # $t4 stores the colour of the tetromino as green
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a0, 4            # $t7 stores the stopping x position 
    
    draw_parts2_S:
    jal draw_line               # draw a squre of the tetromino
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    beq $a0, $t7, next_tetromino2_S
    j draw_parts2_S
    
    next_tetromino2_S:
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    subi $a0, $a0, 6            # decrease starting x coordinate of the square by 6
    jal draw_line
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 15
    sw $t2, 0($t1)              # set the curr_shape as 15
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
rotate3_S:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0x3cb043            # $t4 stores the colour of the tetromino as green
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    subi $a0, $a0, 2            # decrease $a0 by 2
    subi $a1, $a1, 2            # decrease $a1 by 2
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a1, 4            # $t7 stores the stopping y position 
    
    draw_parts3_S:
    jal draw_line               # draw a squre of the tetromino
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    beq $a1, $t7, next_tetromino3_S
    j draw_parts3_S
    
    next_tetromino3_S:
    subi $a1, $a1, 2            # decrease starting y coordinate of the square by 2
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    jal draw_line
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 16
    sw $t2, 0($t1)              # set the curr_shape as 16
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
# Draw a single Z tetromino
draw_Z_tetromino:
    lw $t9, version             # get the version of tetromino to draw
    beq $t9, 0, rotate0_Z
    beq $t9, 1, rotate1_Z
    beq $t9, 2, rotate2_Z
    beq $t9, 3, rotate3_Z
    
rotate0_Z:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0x0000ff            # $t4 stores the colour of the tetromino as blue
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    subi $a0, $a0, 2            # Decrease $a0 by 2
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a0, 4            # $t7 stores the stopping x position  
    
    draw_part0_Z:
    jal draw_line               # draw a squre of the tetromino
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    beq $a0, $t7, next_tetromino0_Z
    j draw_part0_Z
    
    next_tetromino0_Z:
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    subi $a0, $a0, 2            # decrease starting 2 coordinate of the square by 2
    jal draw_line
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 17
    sw $t2, 0($t1)              # set the curr_shape as 17
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines              # check for if any row is full
    
rotate1_Z:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0x0000ff            # $t4 stores the colour of the tetromino as blue
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    subi $a1, $a1, 2            # decrease $a1 by 2
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a1, 4            # $t7 stores the stopping y position 
    
    draw_parts1_Z:
    jal draw_line               # draw a squre of the tetromino
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    beq $a1, $t7, next_tetromino1_Z
    j draw_parts1_Z
    
    next_tetromino1_Z:
    subi $a1, $a1, 2            # decrease starting y coordinate of the square by 2
    subi $a0, $a0, 2            # decrease starting x coordinate of the square by 2
    jal draw_line
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 18
    sw $t2, 0($t1)              # set the curr_shape as 18
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
rotate2_Z:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0x0000ff            # $t4 stores the colour of the tetromino as blue
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    subi $a0, $a0, 2            # Decrease $a0 by 2
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a0, 4            # $t7 stores the stopping x position 
    
    draw_parts2_Z:
    jal draw_line               # draw a squre of the tetromino
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    beq $a0, $t7, next_tetromino2_Z
    j draw_parts2_Z
    
    next_tetromino2_Z:
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    subi $a0, $a0, 2            # decrease starting 2 coordinate of the square by 2
    jal draw_line
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 19
    sw $t2, 0($t1)              # set the curr_shape as 19
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
rotate3_Z:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0x0000ff            # $t4 stores the colour of the tetromino as blue
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    subi $a1, $a1, 2            # decrease $a1 by 2
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a1, 4 
    
    draw_parts3_Z:
    jal draw_line               # draw a squre of the tetromino
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    beq $a1, $t7, next_tetromino3_Z
    j draw_parts3_Z
    
    next_tetromino3_Z:
    subi $a1, $a1, 2            # decrease starting y coordinate of the square by 2
    subi $a0, $a0, 2            # decrease starting x coordinate of the square by 2
    jal draw_line
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    jal draw_line
    la $t1, curr_shape
    li $t2, 20
    sw $t2, 0($t1)              # set the curr_shape as 20
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
# Draw a single I tetromino
draw_I_tetromino:
    lw $t9, version             # get the version of tetromino to draw
    beq $t9, 0, rotate0_I
    beq $t9, 1, rotate1_I
    beq $t9, 2, rotate2_I
    beq $t9, 3, rotate3_I 
    
rotate0_I:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0xa020f0            # $t4 stores the colour of the tetromino as purple
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    subi $a1, $a1, 2            # Decrease $a1 by 2
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a1, 8            # $t7 stores the stopping y position 
    
    draw_part0_I:
    jal draw_line               # draw a squre of the tetromino
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    beq $a1, $t7, next_tetromino0_I
    j draw_part0_I
    
    next_tetromino0_I:
    la $t1, curr_shape
    li $t2, 21
    sw $t2, 0($t1)              # set the curr_shape as 21
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines              # check for if any row is full
    
rotate1_I:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0xa020f0            # $t4 stores the colour of the tetromino as purple
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    subi $a0, $a0, 2            # decrease $a0 by 2
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a0, 8            # $t7 stores the stopping x position 
    
    draw_parts1_I:
    jal draw_line               # draw a squre of the tetromino
    addi $a0, $a0, 2            # increase starting y coordinate of the square by 2
    beq $a0, $t7, next_tetromino1_I
    j draw_parts1_I
    
    next_tetromino1_I:
    la $t1, curr_shape
    li $t2, 22
    sw $t2, 0($t1)              # set the curr_shape as 22
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
rotate2_I:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0xa020f0            # $t4 stores the colour of the tetromino as purple
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    subi $a1, $a1, 2            # Decrease $a1 by 2
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a1, 8            # $t7 stores the stopping y position 
    
    draw_parts2_I:
    jal draw_line               # draw a squre of the tetromino
    addi $a1, $a1, 2            # increase starting y coordinate of the square by 2
    beq $a1, $t7, next_tetromino2_I
    j draw_parts2_I
    
    next_tetromino2_I:
    la $t1, curr_shape
    li $t2, 23
    sw $t2, 0($t1)              # set the curr_shape as 23
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
rotate3_I:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0xa020f0            # $t4 stores the colour of the tetromino as purple
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    subi $a0, $a0, 2            # decrease $a0 by 2
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a0, 8            # $t7 stores the stopping x position 
    
    draw_parts3_I:
    jal draw_line               # draw a squre of the tetromino
    addi $a0, $a0, 2            # increase starting y coordinate of the square by 2
    beq $a0, $t7, next_tetromino3_I
    j draw_parts3_I
    
    next_tetromino3_I:
    la $t1, curr_shape
    li $t2, 24
    sw $t2, 0($t1)              # set the curr_shape as 24
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
# Draw a single O tetromino
draw_O_tetromino:
    lw $t9, version             # get the version of tetromino to draw
    beq $t9, 0, rotate0_O
    beq $t9, 1, rotate1_O
    beq $t9, 2, rotate2_O
    beq $t9, 3, rotate3_O 
    
rotate0_O:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0xffc0cb            # $t4 stores the colour of the tetromino as pink
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    subi $a0, $a0, 2            # Decrease $a0 by 2
    subi $a1, $a1, 2            # Decrease $a1 by 2
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a0, 4            # $t7 stores the stopping x position 
    
    draw_part0_O:
    jal draw_line               # draw a squre of the tetromino
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    beq $a0, $t7, next_tetromino0_O
    j draw_part0_O
    
    next_tetromino0_O:
    addi $a1, $a1, 2            # Increase starting y coordinate by 2
    subi $a0, $a0, 4            # Decrease starting x coordinate by 4
    jal draw_line   
    addi $a0, $a0, 2            # Increase starting x coordinate by 2
    jal draw_line  
    la $t1, curr_shape
    li $t2, 25
    sw $t2, 0($t1)              # set the curr_shape as 25
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines              # check for if any row is full
    
rotate1_O:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0xffc0cb            # $t4 stores the colour of the tetromino as pink
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    subi $a0, $a0, 2            # Decrease $a0 by 2
    subi $a1, $a1, 2            # Decrease $a1 by 2
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a0, 4            # $t7 stores the stopping y position  
    
    draw_parts1_O:
    jal draw_line               # draw a squre of the tetromino
    addi $a0, $a0, 2            # increase starting y coordinate of the square by 2
    beq $a0, $t7, next_tetromino1_O
    j draw_parts1_O
    
    next_tetromino1_O:
    addi $a1, $a1, 2            # Increase starting y coordinate by 2
    subi $a0, $a0, 4            # Decrease starting x coordinate by 4
    jal draw_line   
    addi $a0, $a0, 2            # Increase starting x coordinate by 2
    jal draw_line  
    la $t1, curr_shape
    li $t2, 26
    sw $t2, 0($t1)              # set the curr_shape as 26
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
rotate2_O:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0xffc0cb            # $t4 stores the colour of the tetromino as pink
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    subi $a0, $a0, 2            # Decrease $a0 by 2
    subi $a1, $a1, 2            # Decrease $a1 by 2
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a0, 4            # $t7 stores the stopping y position  
    
    draw_parts2_O:
    jal draw_line               # draw a squre of the tetromino
    addi $a0, $a0, 2            # increase starting y coordinate of the square by 2
    beq $a0, $t7, next_tetromino2_O
    j draw_parts2_O
    
    next_tetromino2_O:
    addi $a1, $a1, 2            # Increase starting y coordinate by 2
    subi $a0, $a0, 4            # Decrease starting x coordinate by 4
    jal draw_line   
    addi $a0, $a0, 2            # Increase starting x coordinate by 2
    jal draw_line  
    la $t1, curr_shape
    li $t2, 27
    sw $t2, 0($t1)              # set the curr_shape as 27
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
rotate3_O:
    lw $t0, ADDR_DSPL           # reset $t0 to base address
    li $t4, 0xffc0cb            # $t4 stores the colour of the tetromino as pink
    lw $a0, curr_x              # $a0 stores the x position of the tetromino 
    lw $a1, curr_y              # $a1 stores the y position of the tetromino
    subi $a0, $a0, 2            # Decrease $a0 by 2
    subi $a1, $a1, 2            # Decrease $a1 by 2
    addi $a2, $zero, 2          # $a2 stores the width of the tetromino   
    addi $a3, $zero, 2          # $a3 stores the length of the tetromino
    addi $t7, $a0, 4            # $t7 stores the stopping y position  
    
    draw_parts3_O:
    jal draw_line               # draw a squre of the tetromino
    addi $a0, $a0, 2            # increase starting x coordinate of the square by 2
    beq $a0, $t7, next_tetromino3_O
    j draw_parts3_O
    
    next_tetromino3_O:
    addi $a1, $a1, 2            # Increase starting y coordinate by 2
    subi $a0, $a0, 4            # Decrease starting x coordinate by 4
    jal draw_line   
    addi $a0, $a0, 2            # Increase starting x coordinate by 2
    jal draw_line  
    la $t1, curr_shape
    li $t2, 28
    sw $t2, 0($t1)              # set the curr_shape as 28
    lw $t9, store_tetromino
    bne $t9, 0, game_loop       # check if we want to store the tetromino
    j remove_lines
    
game_loop:
	# 1a. Check if key has been pressed
	li 		$v0, 32
	li 		$a0, 1
	syscall
	
	check_keyboard:
	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    lw $t1, paused                  # get the value of paused
    beq $t1, 0, pause_game          # when the game is paused, stay paused
    li $v0, 32                      # sleep the game for 0.03 second
    li $a0, 30
    syscall
    la $t2, auto_drop               # load the address of the auto_drop variable
    lw $t3, 0($t2)                  # load the current auto drop record 
    addi $t3, $t3, 1                # increase the auto drop record by 1
    sw $t3, 0($t2)                  
    lw $t3, auto_drop
    lw $t4, drop_rate               # larger drop rate -> slower
    beq $t3, $t4, drop              # once the auto drop record reaches n times, it drops automatically once
    beq $t8, 1, keyboard_input      # otherwise, if first word is 1, key is pressed
    j check_keyboard                # or if it's not 10 yet and the key is not pressed, keep keyboard checking
    
    drop:
    la $t2, auto_drop               # load the address of the auto_drop variable
    li $t3, 0 
    sw $t3, 0($t2)                  # set auto_drop as 0 = restart counting
    j respond_to_S
    
    pause_game:                     # pause the game when pause "p" is clicked
    li 		$v0, 32
	li 		$a0, 1
	syscall
	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, pause_only_input    # otherwise, if first word is 1, key is pressed
    lw $t1, paused
    beq $t1, 1, game_loop           # when the game is not paused anymore, go back to the game loop
    lw $t2, paused_drawn            # load the value of paused_drawn
    beq $t2, 0, pause_game          # if the paused sign has been drawn, don't need to draw again
    # display PAUSED
    la $t4, store_tetromino         # load the address of store_tetromino
    li $t5, 1
    sw $t5, 0($t4)                  # set it not to store whatever that's drawn
    addi $a0, $zero, 0              # set staring x coordinate of the box
    addi $a1, $zero, 17             # set starting y coordinate of the box
    addi $a2, $zero, 32             # set width of box
    addi $a3, $zero, 9              # set length of box
    li $t4, 0xa62c2b                # set the colour of the displayed box to red
    jal draw_line                   # call the line-drawing function
    li $t4, 0xffffff                # set the colour of the word PAUSED to white
    li $t7, 0                       # $t7 is the counter of the x and y arrays
    addi $a2, $zero, 1              # set width of box
    addi $a3, $zero, 1              # set length of box
    
    write_paused:
    beq $t7, 252, continue_pause_game        # continue pausing the game
    la $t9, paused_x                # the first address of the pasued_x
    la $t8, paused_y                # the first address of the pasued_y
    add $t9, $t9, $t7               # Move to the next x element 
    add $t8, $t8, $t7               # Move to the next y element 
    lw $a0, 0($t9)                  # load the current x coordinate into $a0
    lw $a1, 0($t8)                  # load the current y coordinate into $a1
    jal draw_line                   # draw the single square
    addi $t7, $t7, 4                # increment the loop counter by 1
    j write_paused
    
    continue_pause_game:
    la $t2, paused_drawn            # load the address of paused_drawn
    li $t3, 0            
    sw $t3, 0($t2)                  # indicate that the paused sign has been drawn
    j pause_game
    
    # 1b. Check which key has been pressed
    keyboard_input:                 # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    beq $a0, 0x77, respond_to_W     # Check if the key w was pressed
    beq $a0, 0x61, respond_to_A     # Check if the key a was pressed
    beq $a0, 0x73, respond_to_S     # Check if the key s was pressed
    beq $a0, 0x64, respond_to_D     # Check if the key d was pressed
    beq $a0, 0x70, respond_to_P     # Check if the key p was pressed
    b game_loop
    
    pause_only_input:
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x70, respond_to_P     # Check if the key p was pressed
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    b game_loop
    
    restart_only_input:
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x72, respond_to_R     # Check if the key r was pressed
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    b game_loop
    
respond_to_Q:
	li $v0, 10                       # Quit gracefully
	syscall
	
respond_to_P:
    li $v0, 33    # async play note syscall
    li $a0, 60    # midi pitch
    li $a1, 300   # duration
    li $a2, 93    # instrument
    li $a3, 100   # volume
    syscall
    
    la $t1, paused                   # load the address of the paused variable
    lw $t2, 0($t1)                   # get the value of paused
    beq $t2, 0, set_restart          # before key P, the game is paused -> restart          
    beq $t2, 1, set_pause            # before key P, the game is not paused -> pause
    
    set_restart:
    la $t1, paused                   # load the address of the paused variable
    li $t2, 1
    sw $t2, 0($t1)                   # set paused = 1 (not paused -> restart)
    la $t2, paused_drawn            # load the address of paused_drawn
    li $t3, 1            
    sw $t3, 0($t2)                  # indicate that the paused sign has not been drawn
    j game_loop
    
    set_pause:
    la $t1, paused                   # load the address of the paused variable
    li $t2, 0
    sw $t2, 0($t1)                   # set paused = 0 (paused)
    j game_loop

respond_to_R:
    # Reset variables 
    lw $t0, ADDR_DSPL               # Reset base address
    la $t1, version                 # Reset version to 0
    li $t2, 0
    sw $t2, 0($t1) 
    la $t1, curr_type               # Reset curr_type to 3
    li $t2, 3
    sw $t2, 0($t1)
    la $t1, curr_shape              # Reset version to 13
    li $t2, 13
    sw $t2, 0($t1) 
    la $t1, curr_x                  # Reset curr_x to 16
    li $t2, 16
    sw $t2, 0($t1) 
    la $t1, curr_y                  # Reset curr_y to 0
    li $t2, 0
    sw $t2, 0($t1) 
    la $t1, store_tetromino         # Reset store_tetromino to 0
    li $t2, 0
    sw $t2, 0($t1)
    la $t1, new_piece               # Reset new_piece to 1
    li $t2, 1
    sw $t2, 0($t1)
    la $t1, paused                  # Reset paused to 1
    li $t2, 1
    sw $t2, 0($t1)
    la $t1, auto_drop               # Reset auto_drop to 0
    li $t2, 0
    sw $t2, 0($t1)
    la $t1, drop_rate               # Reset drop_rate to 31
    li $t2, 34
    sw $t2, 0($t1)
    la $t1, paused_drawn            # Reset paused_drawn to 1
    li $t2, 1
    sw $t2, 0($t1)
    la $t1, game_over_drawn         # Reset game_over_drawn to 1
    li $t2, 1
    sw $t2, 0($t1)
    
    # Redrawn the grid and the walls -> update the grid data
    j draw_grids
	
respond_to_W:                        # rotate the tetromino by 90 degree, clockwise
	j check_collision_W              # check for collisions
	pass_check_W:
	li $v0, 31    # async play note syscall
    li $a0, 60    # midi pitch
    li $a1, 100   # duration
    li $a2, 0     # instrument
    li $a3, 200   # volume
    syscall
	la $t1, version          
	lw $t2, 0($t1)
	addi $t2, $t2, 1
	beq $t2, 4, restart_count
	sw $t2, 0($t1)
	j draw_tetrominos_grid
	restart_count:
	la $t1, version                  
	lw $t2, 0($t1)
	li $t2, 0
	sw $t2, 0($t1)
	la $t3, store_tetromino
	li $t9, 1
	sw $t9, 0($t3)                 # we don't want to store the tetromino           
	j draw_tetrominos_grid
	
respond_to_A:                      # move the tetromino to the left
	j check_collision_A            # check for collisions 
	pass_check_A:
	li $v0, 31    # async play note syscall
    li $a0, 60    # midi pitch
    li $a1, 100   # duration
    li $a2, 0     # instrument
    li $a3, 200   # volume
    syscall
	la $t1, curr_x                 # load the x position address of the current tetromino
	lw $t2, 0($t1)                 # fetch the x position  
	subi $t2, $t2, 2               # subtract the x position by 2
	sw $t2, 0($t1)                 # rewrite the x position 
	la $t3, store_tetromino
	li $t9, 1
	sw $t9, 0($t3)                 # we don't want to store the tetromino   
	j draw_tetrominos_grid
	    
respond_to_S:                      # move the tetromino down
	j check_collision_S
	pass_check_S:
	la $t1, curr_y                 # load the y position address of the current tetromino
	lw $t2, 0($t1)                 # fetch the y position  
	addi $t2, $t2, 2               # increase the y position by 2
	sw $t2, 0($t1)                 # rewrite the y position 
	la $t3, store_tetromino
	li $t9, 1
	sw $t9, 0($t3)                 # we don't want to store the tetromino   
	j draw_tetrominos_grid
	   
respond_to_D:                      # move the tetromino to the right
	j check_collision_D            # check for collisions
	pass_check_D:
	li $v0, 31    # async play note syscall
    li $a0, 60    # midi pitch
    li $a1, 100   # duration
    li $a2, 0     # instrument
    li $a3, 200   # volume
    syscall
	la $t1, curr_x                 # load the x position address of the current tetromino
	lw $t2, 0($t1)                 # fetch the x position 
	addi $t2, $t2, 2               # increase the x position by 2
	sw $t2, 0($t1)                 # rewrite the x position 
	la $t3, store_tetromino
	li $t9, 1
	sw $t9, 0($t3)                 # we don't want to store the tetromino   
	j draw_tetrominos_grid
	
# 2a. Check for collisions
check_collision_W:
    lw $t1, curr_shape              # get the shape of the current tetromino
    lw $t2, curr_x                  
    sll $t3, $t2, 2                 # convert horizontal offset to pixels
    lw $t2, curr_y  
    sll $t4, $t2, 7                 # convert vertical offset to pixels
    add $t5, $t3, $t4               # store the total offset of the starting pixel (relative to $t0)
    la $t6, grid_data               # load the first address of the grid data into $t6
    add $t6, $t6, $t5               # add the offset relative to $t0 = the current location
    li $t3, 0x17161a                # $t3 stores dark gray color code
    li $t4, 0x1b1b1b                # $t4 stores light gray color code 
    lw $t7, curr_type               # load the current type of tetromino (T, J, L, etc)
    beq $t7, 0, use_t_w 
    beq $t7, 1, use_l_w 
    beq $t7, 2, use_j_w
    beq $t7, 3, use_s_w
    beq $t7, 4, use_z_w
    beq $t7, 5, use_i_w
    beq $t7, 6, use_o_w
    # T 
    use_t_w:
    la $t2, t_collision_W           # load the first address of the constant array
    j check_W_shape
    # L            
    use_l_w:
    la $t2, l_collision_W           # load the first address of the constant array
    j check_W_shape
    # J
    use_j_w:
    la $t2, j_collision_W           # load the first address of the constant array
    j check_W_shape
    # S
    use_s_w:
    la $t2, s_collision_W           # load the first address of the constant array
    j check_W_shape
    # Z
    use_z_w:
    la $t2, z_collision_W           # load the first address of the constant array
    j check_W_shape
    # I
    use_i_w:
    la $t2, i_collision_W           # load the first address of the constant array
    j check_W_shape
    # O
    use_o_w:
    la $t2, o_collision_W           # load the first address of the constant array
    j check_W_shape
    
    check_W_shape:
    beq $t1, 1, set_W_shape1        # check for shape 1 (T)
    beq $t1, 2, set_W_shape2        # check for shape 2 (T)
    beq $t1, 3, set_W_shape3        # check for shape 3 (T)
    beq $t1, 4, set_W_shape4        # check for shape 4 (T)
    beq $t1, 5, set_W_shape1        # check for shape 5 (L)
    beq $t1, 6, set_W_shape2        # check for shape 6 (L)
    beq $t1, 7, set_W_shape3        # check for shape 7 (L)
    beq $t1, 8, set_W_shape4        # check for shape 8 (L)
    beq $t1, 9, set_W_shape1        # check for shape 9 (J)
    beq $t1, 10, set_W_shape2       # check for shape 10 (J)
    beq $t1, 11, set_W_shape3       # check for shape 11 (J)
    beq $t1, 12, set_W_shape4       # check for shape 12 (J)
    beq $t1, 13, set_W_shape1       # check for shape 13 (S)
    beq $t1, 14, set_W_shape2       # check for shape 14 (S)
    beq $t1, 15, set_W_shape3       # check for shape 15 (S)
    beq $t1, 16, set_W_shape4       # check for shape 16 (S)
    beq $t1, 17, set_W_shape1       # check for shape 17 (Z)
    beq $t1, 18, set_W_shape2       # check for shape 18 (Z)
    beq $t1, 19, set_W_shape3       # check for shape 19 (Z)
    beq $t1, 20, set_W_shape4       # check for shape 20 (Z)
    beq $t1, 21, set_W_shape1       # check for shape 21 (I)
    beq $t1, 22, set_W_shape2       # check for shape 22 (I)
    beq $t1, 23, set_W_shape3       # check for shape 23 (I)
    beq $t1, 24, set_W_shape4       # check for shape 24 (I)
    beq $t1, 25, set_W_shape1       # check for shape 25 (O)
    beq $t1, 26, set_W_shape2       # check for shape 26 (O)
    beq $t1, 27, set_W_shape3       # check for shape 27 (O)
    beq $t1, 28, set_W_shape4       # check for shape 28 (O)
    
    set_W_shape1:
    li $t1, 0                       # set $t1 as the starting index 
    li $t0, 16                      # set $t0 as the stopping index
    j check_W_shapes
    set_W_shape2:
    li $t1, 16                      # set $t1 as the starting index 
    li $t0, 32                      # set $t0 as the stopping index
    j check_W_shapes
    set_W_shape3:
    li $t1, 32                      # set $t1 as the starting index 
    li $t0, 48                      # set $t0 as the stopping index
    j check_W_shapes
    set_W_shape4:
    li $t1, 48                      # set $t1 as the starting index 
    li $t0, 64                      # set $t0 as the stopping index
    j check_W_shapes
    
    check_W_shapes:
    beq $t1, $t0, finish_check_W    # If index == stopping index, done checking
    add $t5, $t2, $t1               # calculate the current address
    lw $t7, 0($t5)                  # get the value 
    beq $t7, -1, skip_W             # if the stored value is -1, it means it doesn't need to be checked
    add $t9, $t6, $t7               # store the moving address of the block
    lw $t8, 0($t9)                  # load the color at that location 
    addi $t1, $t1, 4                # increment the counter by 4
    beq $t8, $t3, check_W_shapes    # if the color is dark gray, check next block
    beq $t8, $t4, check_W_shapes    # or if the color is light gray, check next block
    j game_loop                 

    finish_check_W:
    j pass_check_W
    
    skip_W:
    add $t1, $t1, 4
    j check_W_shapes
    
check_collision_A:
    lw $t1, curr_shape              # get the shape of the current tetromino
    lw $t2, curr_x                  
    sll $t3, $t2, 2                 # convert horizontal offset to pixels
    lw $t2, curr_y  
    sll $t4, $t2, 7                 # convert vertical offset to pixels
    add $t5, $t3, $t4               # store the total offset of the starting pixel (relative to $t0)
    la $t6, grid_data               # load the first address of the grid data into $t6
    add $t6, $t6, $t5               # add the offset relative to $t0 = the current location in the grid data
    li $t3, 0x17161a                # $t3 stores dark gray color code
    li $t4, 0x1b1b1b                # $t4 stores light gray color code 
    lw $t7, curr_type               # load the current type of tetromino (T, J, L, etc)
    beq $t7, 0, use_t_a 
    beq $t7, 1, use_l_a 
    beq $t7, 2, use_j_a
    beq $t7, 3, use_s_a
    beq $t7, 4, use_z_a
    beq $t7, 5, use_i_a
    beq $t7, 6, use_o_a
    # T    
    use_t_a:
    la $t2, t_collision_A           # load the first address of the constant array
    j check_A_shape
    # L           
    use_l_a:
    la $t2, l_collision_A           # load the first address of the constant array
    j check_A_shape
    # J 
    use_j_a:
    la $t2, j_collision_A           # load the first address of the constant array
    j check_A_shape
    # S 
    use_s_a:
    la $t2, s_collision_A           # load the first address of the constant array
    j check_A_shape
    # Z
    use_z_a:
    la $t2, z_collision_A           # load the first address of the constant array
    j check_A_shape
    # I
    use_i_a:
    la $t2, i_collision_A           # load the first address of the constant array
    j check_A_shape
    # O
    use_o_a:
    la $t2, o_collision_A           # load the first address of the constant array
    j check_A_shape
    
    check_A_shape:
    beq $t1, 1, set_A_shape1        # check for shape 1 (T)
    beq $t1, 2, set_A_shape2        # check for shape 2 (T)
    beq $t1, 3, set_A_shape3        # check for shape 3 (T)
    beq $t1, 4, set_A_shape4        # check for shape 4 (T)
    beq $t1, 5, set_A_shape1        # check for shape 5 (L)
    beq $t1, 6, set_A_shape2        # check for shape 6 (L)
    beq $t1, 7, set_A_shape3        # check for shape 7 (L)
    beq $t1, 8, set_A_shape4        # check for shape 8 (L)
    beq $t1, 9, set_A_shape1        # check for shape 9 (J)
    beq $t1, 10, set_A_shape2       # check for shape 10 (J)
    beq $t1, 11, set_A_shape3       # check for shape 11 (J)
    beq $t1, 12, set_A_shape4       # check for shape 12 (J)
    beq $t1, 13, set_A_shape1       # check for shape 13 (S)
    beq $t1, 14, set_A_shape2       # check for shape 14 (S)
    beq $t1, 15, set_A_shape3       # check for shape 15 (S)
    beq $t1, 16, set_A_shape4       # check for shape 16 (S)
    beq $t1, 17, set_A_shape1       # check for shape 17 (Z)
    beq $t1, 18, set_A_shape2       # check for shape 18 (Z)
    beq $t1, 19, set_A_shape3       # check for shape 19 (Z)
    beq $t1, 20, set_A_shape4       # check for shape 20 (Z)
    beq $t1, 21, set_A_shape1       # check for shape 21 (I)
    beq $t1, 22, set_A_shape2       # check for shape 22 (I)
    beq $t1, 23, set_A_shape3       # check for shape 23 (I)
    beq $t1, 24, set_A_shape4       # check for shape 24 (I)
    beq $t1, 25, set_A_shape1       # check for shape 25 (O)
    beq $t1, 26, set_A_shape2       # check for shape 26 (O)
    beq $t1, 27, set_A_shape3       # check for shape 27 (O)
    beq $t1, 28, set_A_shape4       # check for shape 28 (O)
    
    set_A_shape1:
    li $t1, 0                       # set $t1 as the starting index 
    li $t0, 16                      # set $t0 as the stopping index
    j check_A_shapes
    set_A_shape2:
    li $t1, 16                       # set $t1 as the starting index 
    li $t0, 32                       # set $t0 as the stopping index
    j check_A_shapes
    set_A_shape3:
    li $t1, 32                       # set $t1 as the starting index 
    li $t0, 48                       # set $t0 as the stopping index
    j check_A_shapes
    set_A_shape4:
    li $t1, 48                       # set $t1 as the starting index 
    li $t0, 64                       # set $t0 as the stopping index
    j check_A_shapes
    
    check_A_shapes:
    beq $t1, $t0, finish_check_A    # If index == stopping index, done checking
    add $t5, $t2, $t1               # calculate the current address
    lw $t7, 0($t5)                  # get the value 
    beq $t7, -1, skip_A             # if the stored value is -1, it means it doesn't need to be checked
    add $t9, $t6, $t7               # store the moving address of the block
    lw $t8, 0($t9)                  # load the color at that location 
    addi $t1, $t1, 4                # increment the counter by 4
    beq $t8, $t3, check_A_shapes    # if the color is dark gray, check next block
    beq $t8, $t4, check_A_shapes    # or if the color is light gray, check next block
    j game_loop                 

    finish_check_A:
    j pass_check_A
    
    skip_A:
    add $t1, $t1, 4
    j check_A_shapes
    
check_collision_S:
    lw $t1, curr_shape              # get the shape of the current tetromino
    lw $t2, curr_x                  
    sll $t3, $t2, 2                 # convert horizontal offset to pixels
    lw $t2, curr_y  
    sll $t4, $t2, 7                 # convert vertical offset to pixels
    add $t5, $t3, $t4               # store the total offset of the starting pixel (relative to $t0)
    la $t6, grid_data               # load the first address of the grid data into $t6
    add $t6, $t6, $t5               # add the offset relative to $t0 = the current location
    li $t3, 0x17161a                # $t3 stores dark gray color code
    li $t4, 0x1b1b1b                # $t4 stores light gray color code 
    lw $t7, curr_type               # load the current type of tetromino (T, J, L, etc)
    beq $t7, 0, use_t_s 
    beq $t7, 1, use_l_s  
    beq $t7, 2, use_j_s
    beq $t7, 3, use_s_s
    beq $t7, 4, use_z_s
    beq $t7, 5, use_i_s
    beq $t7, 6, use_o_s
    # T  
    use_t_s:
    la $t2, t_collision_S           # load the first address of the constant array
    j check_S_shape
    # L           
    use_l_s:
    la $t2, l_collision_S           # load the first address of the constant array
    j check_S_shape
    # J           
    use_j_s:
    la $t2, j_collision_S           # load the first address of the constant array
    j check_S_shape
    # S           
    use_s_s:
    la $t2, s_collision_S           # load the first address of the constant array
    j check_S_shape
    # Z          
    use_z_s:
    la $t2, z_collision_S           # load the first address of the constant array
    j check_S_shape
    # I          
    use_i_s:
    la $t2, i_collision_S           # load the first address of the constant array
    j check_S_shape
    # O         
    use_o_s:
    la $t2, o_collision_S           # load the first address of the constant array
    j check_S_shape
    
    check_S_shape:
    beq $t1, 1, set_S_shape1        # check for shape 1 (T)
    beq $t1, 2, set_S_shape2        # check for shape 2 (T)
    beq $t1, 3, set_S_shape3        # check for shape 3 (T)
    beq $t1, 4, set_S_shape4        # check for shape 4 (T)
    beq $t1, 5, set_S_shape1        # check for shape 5 (L)
    beq $t1, 6, set_S_shape2        # check for shape 6 (L)
    beq $t1, 7, set_S_shape3        # check for shape 7 (L)
    beq $t1, 8, set_S_shape4        # check for shape 8 (L)
    beq $t1, 9, set_S_shape1        # check for shape 9 (J)
    beq $t1, 10, set_S_shape2       # check for shape 10 (J)
    beq $t1, 11, set_S_shape3       # check for shape 11 (J)
    beq $t1, 12, set_S_shape4       # check for shape 12 (J)
    beq $t1, 13, set_S_shape1       # check for shape 13 (S)
    beq $t1, 14, set_S_shape2       # check for shape 14 (S)
    beq $t1, 15, set_S_shape3       # check for shape 15 (S)
    beq $t1, 16, set_S_shape4       # check for shape 16 (S)
    beq $t1, 17, set_S_shape1       # check for shape 17 (Z)
    beq $t1, 18, set_S_shape2       # check for shape 18 (Z)
    beq $t1, 19, set_S_shape3       # check for shape 19 (Z)
    beq $t1, 20, set_S_shape4       # check for shape 20 (Z)
    beq $t1, 21, set_S_shape1       # check for shape 21 (I)
    beq $t1, 22, set_S_shape2       # check for shape 22 (I)
    beq $t1, 23, set_S_shape3       # check for shape 23 (I)
    beq $t1, 24, set_S_shape4       # check for shape 24 (I)
    beq $t1, 25, set_S_shape1       # check for shape 21 (O)
    beq $t1, 26, set_S_shape2       # check for shape 22 (O)
    beq $t1, 27, set_S_shape3       # check for shape 23 (O)
    beq $t1, 28, set_S_shape4       # check for shape 24 (O)
    
    set_S_shape1:
    li $t1, 0                       # set $t1 as the starting index 
    li $t0, 16                      # set $t0 as the stopping index
    j check_S_shapes
    set_S_shape2:
    li $t1, 16                      # set $t1 as the starting index 
    li $t0, 32                      # set $t0 as the stopping index
    j check_S_shapes
    set_S_shape3:
    li $t1, 32                      # set $t1 as the starting index 
    li $t0, 48                      # set $t0 as the stopping index
    j check_S_shapes
    set_S_shape4:
    li $t1, 48                      # set $t1 as the starting index 
    li $t0, 64                      # set $t0 as the stopping index
    j check_S_shapes
    
    check_S_shapes:
    beq $t1, $t0, finish_check_S    # If index == stopping index, done checking
    add $t5, $t2, $t1               # calculate the current address
    lw $t7, 0($t5)                  # get the value 
    beq $t7, -1, skip_S             # if the stored value is -1, it means it doesn't need to be checked
    add $t9, $t6, $t7               # store the moving address of the block
    lw $t8, 0($t9)                  # load the color at that location 
    addi $t1, $t1, 4                # increment the counter by 4
    beq $t8, $t3, check_S_shapes    # if the color is dark gray, check next block
    beq $t8, $t4, check_S_shapes    # or if the color is light gray, check next block
    # The tetromino has collision with the bottom
    li $v0, 31    # async play note syscall
    li $a0, 80    # midi pitch
    li $a1, 400   # duration
    li $a2, 2     # instrument
    li $a3, 200   # volume
    syscall
    la $t3, store_tetromino         
	li $t9, 0
	sw $t9, 0($t3)                  # we want to store the current tetromino by drawing it again
    j draw_tetromino                
    
    generate_new_piece:
    li $v0 , 42
    li $a0 , 0
    li $a1 , 7                  # generate random values from 0 to 6 
    syscall                     # $a0 is the random value
    la $t0, curr_type           # load the address for the current type
    lw $t9, 0($t0)              # load the value to $t1
    add $t9, $zero, $a0         # set $t1 = $a0
    sw $t9, 0($t0)              # store the new type into the curr type

    la $t1, curr_x              # reset all the current variables to the new piece information
    la $t2, curr_y
    la $t3, version
    la $t4, curr_shape
    lw $t5, new_piece_x
    lw $t6, new_piece_y
    li $t7, 0                   # set the shape as the default 0 orientation
    mult $t8, $t9, 4            # stores curr_type times 4 into $t8
    addi $t8, $t8, 1            # calculate the curr_shape (1 ~ 28)
    sw $t5, 0($t1)
    sw $t6, 0($t2)
    sw $t7, 0($t3)
    sw $t8, 0($t4)
    la $t3, store_tetromino
	li $t9, 1
	sw $t9, 0($t3)              # we don't want to store the tetromino  
	la $t1, new_piece           # load the address of variable new_piece
    li $t2, 1           
    sw $t2, 0($t1)              # set new_piece as 1, indicating not loading a new piece
    j draw_tetromino                

    finish_check_S:
    j pass_check_S
    
    skip_S:
    add $t1, $t1, 4
    j check_S_shapes
    
check_collision_D:
    lw $t1, curr_shape              # get the shape of the current tetromino
    lw $t2, curr_x                  
    sll $t3, $t2, 2                 # convert horizontal offset to pixels
    lw $t2, curr_y  
    sll $t4, $t2, 7                 # convert vertical offset to pixels
    add $t5, $t3, $t4               # store the total offset of the starting pixel (relative to $t0)
    la $t6, grid_data               # load the first address of the grid data into $t6
    add $t6, $t6, $t5               # add the offset relative to $t0 = the current location
    li $t3, 0x17161a                # $t3 stores dark gray color code
    li $t4, 0x1b1b1b                # $t4 stores light gray color code 
    lw $t7, curr_type               # load the current type of tetromino (T, J, L, etc)
    beq $t7, 0, use_t_d 
    beq $t7, 1, use_l_d 
    beq $t7, 2, use_j_d
    beq $t7, 3, use_s_d
    beq $t7, 4, use_z_d
    beq $t7, 5, use_i_d
    beq $t7, 6, use_o_d
    # T 
    use_t_d:
    la $t2, t_collision_D           # load the first address of the constant array
    j check_D_shape
    # L
    use_l_d:
    la $t2, l_collision_D           # load the first address of the constant array
    j check_D_shape
    # L
    use_j_d:
    la $t2, j_collision_D           # load the first address of the constant array
    j check_D_shape
    # S
    use_s_d:
    la $t2, s_collision_D           # load the first address of the constant array
    j check_D_shape
    # Z
    use_z_d:
    la $t2, z_collision_D           # load the first address of the constant array
    j check_D_shape
    # I
    use_i_d:
    la $t2, i_collision_D           # load the first address of the constant array
    j check_D_shape
    # O
    use_o_d:
    la $t2, o_collision_D           # load the first address of the constant array
    j check_D_shape
    
    check_D_shape:
    beq $t1, 1, set_D_shape1        # check for shape 1 (T)
    beq $t1, 2, set_D_shape2        # check for shape 2 (T)
    beq $t1, 3, set_D_shape3        # check for shape 3 (T)
    beq $t1, 4, set_D_shape4        # check for shape 4 (T)
    beq $t1, 5, set_D_shape1        # check for shape 5 (L)
    beq $t1, 6, set_D_shape2        # check for shape 6 (L)
    beq $t1, 7, set_D_shape3        # check for shape 7 (L)
    beq $t1, 8, set_D_shape4        # check for shape 8 (L)
    beq $t1, 9, set_D_shape1        # check for shape 9 (J)
    beq $t1, 10, set_D_shape2       # check for shape 10 (J)
    beq $t1, 11, set_D_shape3       # check for shape 11 (J)
    beq $t1, 12, set_D_shape4       # check for shape 12 (J)
    beq $t1, 13, set_D_shape1       # check for shape 13 (S)
    beq $t1, 14, set_D_shape2       # check for shape 14 (S)
    beq $t1, 15, set_D_shape3       # check for shape 15 (S)
    beq $t1, 16, set_D_shape4       # check for shape 16 (S)
    beq $t1, 17, set_D_shape1       # check for shape 17 (Z)
    beq $t1, 18, set_D_shape2       # check for shape 18 (Z)
    beq $t1, 19, set_D_shape3       # check for shape 19 (Z)
    beq $t1, 20, set_D_shape4       # check for shape 20 (Z)
    beq $t1, 21, set_D_shape1       # check for shape 21 (I)
    beq $t1, 22, set_D_shape2       # check for shape 22 (I)
    beq $t1, 23, set_D_shape3       # check for shape 23 (I)
    beq $t1, 24, set_D_shape4       # check for shape 24 (I)
    beq $t1, 25, set_D_shape1       # check for shape 25 (O)
    beq $t1, 26, set_D_shape2       # check for shape 26 (O)
    beq $t1, 27, set_D_shape3       # check for shape 27 (O)
    beq $t1, 28, set_D_shape4       # check for shape 28 (O)
    
    set_D_shape1:
    li $t1, 0                       # set $t1 as the starting index 
    li $t0, 16                      # set $t0 as the stopping index
    j check_D_shapes
    set_D_shape2:
    li $t1, 16                      # set $t1 as the starting index 
    li $t0, 32                      # set $t0 as the stopping index
    j check_D_shapes
    set_D_shape3:
    li $t1, 32                      # set $t1 as the starting index 
    li $t0, 48                      # set $t0 as the stopping index
    j check_D_shapes
    set_D_shape4:
    li $t1, 48                      # set $t1 as the starting index 
    li $t0, 64                      # set $t0 as the stopping index
    j check_D_shapes
    
    check_D_shapes:
    beq $t1, $t0, finish_check_D    # If index == stopping index, done checking
    add $t5, $t2, $t1               # calculate the current address
    lw $t7, 0($t5)                  # get the value 
    beq $t7, -1, skip_D             # if the stored value is -1, it means it doesn't need to be checked
    add $t9, $t6, $t7               # store the moving address of the block
    lw $t8, 0($t9)                  # load the color at that location 
    addi $t1, $t1, 4                # increment the counter by 4
    beq $t8, $t3, check_D_shapes    # if the color is dark gray, check next block
    beq $t8, $t4, check_D_shapes    # or if the color is light gray, check next block
    j game_loop                 

    finish_check_D:
    j pass_check_D
    
    skip_D:
    add $t1, $t1, 4
    j check_D_shapes
    
# Remove any lines of blocks that result from dropping a piece into the playing area
remove_lines:
    lw $t0, ADDR_DSPL      # reset $t0 to base address
    addi $t1, $zero, 2     # set staring x coordinate of the grid
    addi $t2, $zero, 0     # set starting y coordinate of the grid
    
    check_grid:
    beq $t2, 42, end_checking       # when y reaches the bottom of the grid
    # Get colour
    la $t3, grid_data               # load the first address of the grid data array
    sll $t4, $t1, 2                 # convert the x offset into pixels
    sll $t5, $t2, 7                 # convert the y offset into pixels
    add $t6, $t4, $t5               # $t6 is the total offset from $t0
    add $t3, $t3, $t6               # get the current position of the grid data
    lw $t7, 0($t3)                  # load the colour from the position
    # check the colour at the position
    beq $t7, 0x1b1b1b, next_line    # if it's light gray, no need to check this line anymore
    beq $t7, 0x17161A, next_line    # if it's dark gray, no need to check this line anymore
    addi $t1, $t1, 2                # else, increase starting x coordinate of the square by 2
    bne $t1, 30, check_grid         # before x coordinate reaches the end, keep checking
    addi $t1, $zero, 2              # set staring x coordinate of the grid
    add $t0, $zero, $t2             # $t0 is a temporary y coordinate for shifting
    la $t8, drop_rate               # load the address of the drop rate
    lw $t9, 0($t8)                  # fetch the value of drop rate
    beq $t9, 4, continue            # if the drop rate is 1 already, don't decrease anymore
    subi $t9, $t9, 5                # decrease the drop rate by 5 everytime a line gets removed (increase speed)
    sw $t9, 0($t8)                  # store the new drop rate back
    la $a0, auto_drop               # load the address of the auto_drop variable
    li $a1, 0 
    sw $a1, 0($a0)                  # set auto_drop as 0 = restart counting
    li $v0, 31    # async play note syscall
    li $a0, 70    # midi pitch
    li $a1, 400   # duration
    li $a2, 9     # instrument
    li $a3, 200   # volume
    syscall
    continue:
    j shift_down                    # when the whole row is coloured, remove the line and shift everything down
    
    next_line:
    addi $t2, $t2, 2                # increase starting y coordinate of the square by 2
    addi $t1, $zero, 2              # set staring x coordinate of the grid
    j check_grid
    
    shift_down:                     # shift everything above the full line down one row
    beq $t0, 2, check_grid          # when y coordinate reaches 2
    j remove_line
    
    shift_down_continue:
    subi $t0, $t0, 2                # decrease y coordinate by 2 
    addi $t1, $zero, 2              # set staring x coordinate of the grid
    j shift_down
    
    remove_line:
    beq $t1, 30, shift_down_continue
    sll $t4, $t1, 2                        # convert the x offset into pixels
    sll $t5, $t0, 7                        # convert the y offset into pixels
    add $t8, $t4, $t5                      # $t8 is the total offset from $t0 of the current row
    subi $t6, $t0, 2                       # the y coordinate of the above row
    sll $t7, $t6, 7                        # the y pixels of the above row
    add $t9, $t4, $t7                      # $t9 is the total offset from $t0 of the above row
    la $t3, grid_data                      # load the first address of the grid data array
    add $t4, $t3, $t9                      # get the above position of the grid data
    lw $t5, 0($t4)                         # load the colour from the above position
    add $t6, $t3, $t8                      # get the current position of the grid data
    beq $t5, 0x1b1b1b, draw_dark_gray      # if the above colour is light gray, draw dark gray at current position
    beq $t5, 0x17161A, draw_light_gray     # if the above colour is dark gray, draw light gray at current position
    sw $t5, 0($t6)                         # write the above position colour into current position
    addi $t1, $t1, 2                       # increase the starting x coordinate by 2 
    j remove_line
    
    draw_dark_gray:
    li $t7, 0x17161A
    sw $t7, 0($t6)                 # write dark gray into current position
    addi $t1, $t1, 2               # increase the starting x coordinate by 2  
    j remove_line
    
    draw_light_gray:
    li $t7, 0x1b1b1b
    sw $t7, 0($t6)                  # write light gray into current position
    addi $t1, $t1, 2                # increase the starting x coordinate by 2 
    j remove_line
    
    end_checking:
    j check_game_over               # after removing all possible lines, check if it's game over
    
    continue_new_piece:             # if it doesn't game over, it should come to this line
    la $t1, new_piece               # load the address of variable new_piece
    li $t2, 0           
    sw $t2, 0($t1)                  # set new_piece as 0, indicating loading a new piece
    j draw_tetrominos_grid
    
check_game_over:                    # check whether there's any colour stored in the first row of the grid
    lw $t0, ADDR_DSPL               # reset $t0 to base address
    li $t1, 2                       # $t1 stores the starting x coordinate of the check
    la $t2, grid_data               # load the first address of the grid data array
    li $t5, 0x17161a                # $t5 stores dark gray
    li $t6, 0x1b1b1b                # $t6 stores light gray
    
    check_tetro_grid:
    # Get colour
    la $t2, grid_data               # load the first address of the grid data array
    sll $t3, $t1, 2                 # convert the x offset into pixels
    add $t2, $t2, $t3               # get the current position of the grid data
    lw $t4, 0($t2)                  # load the colour from the position
    beq $t4, $t5, next_square       # if the colour = dark gray, check next one
    beq $t4, $t6, next_square       # if the colour = light gray, check next one
    j game_over                     # if none, do game over 
    
    # Check the colour at the position
    next_square:
    addi $t1, $t1, 2                # increase starting x coordinate of the square by 2
    bne $t1, 30, check_tetro_grid
    j continue_new_piece            # pass the check, go generate new piece

    game_over:
    # Display the game over message: U-LOSE 
    # Restart option
    li 		$v0, 32
	li 		$a0, 1
	syscall
	lw $t0, ADDR_KBRD                 # $t0 = base address for keyboard
    lw $t8, 0($t0)                    # Load first word from keyboard
    beq $t8, 1, restart_only_input    # otherwise, if first word is 1, key is pressed
    
    lw $t2, game_over_drawn         # load the value of game_over_drawn
    beq $t2, 0, game_over           # if the game over sign has been drawn, don't need to draw again
    li $v0, 33    # async play note syscall
    li $a0, 70    # midi pitch
    li $a1, 500   # duration
    li $a2, 127   # instrument
    li $a3, 200   # volume
    syscall
    # Restart icon
    addi $a0, $zero, 5              # set staring x coordinate of the box
    addi $a1, $zero, 28             # set starting y coordinate of the box
    addi $a2, $zero, 9              # set width of box
    addi $a3, $zero, 9              # set length of box
    li $t4, 0xffffff                # set the colour of the larger displayed box to white
    jal draw_line                   # call the line-drawing function
    addi $a0, $zero, 18             # set staring x coordinate of the box
    addi $a1, $zero, 28             # set starting y coordinate of the box
    addi $a2, $zero, 9              # set width of box
    addi $a3, $zero, 9              # set length of box
    li $t4, 0xffffff                # set the colour of the larger displayed box to white
    jal draw_line                   # call the line-drawing function
    addi $a0, $zero, 6              # set staring x coordinate of the box
    addi $a1, $zero, 29             # set starting y coordinate of the box
    addi $a2, $zero, 7              # set width of box
    addi $a3, $zero, 7              # set length of box
    li $t4, 0x03ac13                # set the colour of the smaller displayed box to green
    jal draw_line                   # call the line-drawing function
    addi $a0, $zero, 19             # set staring x coordinate of the box
    addi $a1, $zero, 29             # set starting y coordinate of the box
    addi $a2, $zero, 7              # set width of box
    addi $a3, $zero, 7              # set length of box
    li $t4, 0xa62c2b                # set the colour of the smaller displayed box to red
    jal draw_line                   # call the line-drawing function
    # U-LOSE icon
    addi $a0, $zero, 0              # set staring x coordinate of the box
    addi $a1, $zero, 17             # set starting y coordinate of the box
    addi $a2, $zero, 32             # set width of box
    addi $a3, $zero, 9              # set length of box
    li $t4, 0x333333                # set the colour of the displayed box to gray
    jal draw_line                   # call the line-drawing function
    li $t4, 0xa62c2b                # set the colour of the word U-LOSE to red
    li $t7, 0                       # $t7 is the counter of the x and y arrays
    addi $a2, $zero, 1              # set width of box
    addi $a3, $zero, 1              # set length of box
    
    write_game_over:
    beq $t7, 220, reset_counter        # write restart after write game over
    la $t9, game_over_x                # the first address of the game_over_x
    la $t8, game_over_y                # the first address of the game_over_y
    add $t9, $t9, $t7                  # Move to the next x element 
    add $t8, $t8, $t7                  # Move to the next y element 
    lw $a0, 0($t9)                     # load the current x coordinate into $a0
    lw $a1, 0($t8)                     # load the current y coordinate into $a1
    jal draw_line                      # draw the single square
    addi $t7, $t7, 4                   # increment the loop counter by 4
    j write_game_over
    
    reset_counter:
    li $t7, 0                         # $t7 is the counter of the x and y arrays
    li $t4, 0xffffff                  # set the colour of the word R to white
    
    write_restart:
    beq $t7, 48, reset_counter_again   # write quit after write restart
    la $t9, restart_x                  # the first address of the restart_x
    la $t8, restart_y                  # the first address of the restart_y
    add $t9, $t9, $t7                  # Move to the next x element 
    add $t8, $t8, $t7                  # Move to the next y element 
    lw $a0, 0($t9)                     # load the current x coordinate into $a0
    lw $a1, 0($t8)                     # load the current y coordinate into $a1
    jal draw_line                      # draw the single square
    addi $t7, $t7, 4                   # increment the loop counter by 4
    j write_restart
    
    reset_counter_again:
    li $t7, 0                       # $t7 is the counter of the x and y arrays
    li $t4, 0xffffff                # set the colour of the word Q to white
    
    write_quit:
    beq $t7, 44, continue_game_over    # continue game over
    la $t9, quit_x                     # the first address of the restart_x
    la $t8, quit_y                     # the first address of the restart_y
    add $t9, $t9, $t7                  # Move to the next x element 
    add $t8, $t8, $t7                  # Move to the next y element 
    lw $a0, 0($t9)                     # load the current x coordinate into $a0
    lw $a1, 0($t8)                     # load the current y coordinate into $a1
    jal draw_line                      # draw the single square
    addi $t7, $t7, 4                   # increment the loop counter by 4
    j write_quit
    
    continue_game_over:
    la $t2, game_over_drawn         # load the address of game_over_drawn
    li $t3, 0            
    sw $t3, 0($t2)                  # indicate that the game over sign has been drawn
    j game_over

    b game_loop