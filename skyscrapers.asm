


PRINT_INT = 1
PRINT_STRING = 4
READ_INT = 5
EXIT = 10

	.data
	.align	0



board_size:
	.byte	0
board:
	.space	256
north_hints:
	.space	32
south_hints:
	.space	32
east_hints:
	.space	32
west_hints:
	.space	32

board_row_break_part:
	.asciiz "+---"
plus_char_break:
	.asciiz "+\n"
board_space_front:
	.asciiz "| "
board_space_mid:
	.asciiz " | "
board_space_back:
	.asciiz " |\n"
new_line_char:
	.asciiz "\n"
spacesss:
	.asciiz "   "
spacess:
	.asciiz "  "
spaces:
	.asciiz " "
	
board_input_error:
	.asciiz "\nInvalid board size, Skyscrapers terminating\n"

	.text
	.align	2

##################################################
#              Program area                      #
##################################################


#
# Name: Main
#
main:
	addi	$sp, $sp, -8
	sw	$ra, 4($sp)
	sw	$s0, 0($sp)
	
	jal	read_input
	beq	$v0, $zero, main_done	#end if it returned false. 

	jal	print_board

main_done:
	lw	$ra, 4($sp)
	lw	$s0, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra




#
# Name: get_<direction>_hint
#
# Arguments: 
#     $a0: index
#
get_north_hint:
	la	$a1, north_hints
	j	get_hint
get_south_hint:
	la	$a1, south_hints
	j	get_hint
get_east_hint:
	la	$a1, east_hints
	j	get_hint
get_west_hint:
	la	$a1, west_hints
	j	get_hint
get_hint:
	add	$a1, $a0, $a1
	lb	$v0, 0($a1)
	jr	$ra

#####################################################
#               Data Input Functions                #
#####################################################

read_input:
	addi	$sp, $sp, -8
	sw	$ra, 4($sp)
	sw	$s0, 0($sp)

	#read user input board bounds
	li	$v0, READ_INT
	syscall
	
	#confirm starting board bounds
	li	$t0, 3
	li	$t1, 9
	la	$a0, board_input_error
	blt	$v0, $t0, read_input_error
	blt	$t1, $v0, read_input_error
	
	#write the borad bounds
	la	$t0, board_size
	sb	$v0, 0($t0)
	
	move	$s0, $v0	#s0 will contian the board size
	
	la	$a0, north_hints
	move	$a1, $s0
	jal	load_hints
	
	la	$a0, east_hints
	move	$a1, $s0
	jal	load_hints


	la	$a0, south_hints
	move	$a1, $s0
	jal	load_hints


	la	$a0, west_hints
	move	$a1, $s0
	jal	load_hints



	#all input is good
	li	$v0, 1		#return 1
	j	read_input_end

	
read_input_error:
	
	jal	print_string
	li	$v0, 0		#return 0

read_input_end:
	lw	$ra, 4($sp)
	lw	$s0, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra

	

load_hints:
	addi	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	move	$s0, $a0
	move	$s1, $a1
	
	li	$t0, 0		#counter
read_input_loop:
	
	beq	$t0, $s1, load_hints_done
	
	li	$v0, READ_INT
	syscall
	
	sb	$v0, 0($s0)
	addi	$s0, $s0, 1

	addi	$t0, $t0, 1
	j	read_input_loop

	
load_hints_done:
	lw	$ra, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	addi	$sp, $sp, 12
	jr	$ra

	
	
	

#####################################################
#               Print functions                     #
#####################################################

#
# Name: print board
#
print_board:
	
	addi	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	la	$s0, board_size
	lb	$s0, 0($s0)
	la	$s1, board
	li	$s2, 0

	la	$a0, north_hints
	jal	print_x_hints

print_board_loop_row:

	beq	$s2, $s0, print_board_done

	jal	print_break_row

	la	$a0, west_hints
	move	$a1, $s2
	jal	print_y_hint
	
	la	$a0, spaces
	jal	print_string

	la	$a0, board_space_front
	jal	print_string
	

	move	$s3, $zero


print_board_loop_col:

	beq	$s3, $s0, print_board_loop_col_done

	add	$s1, $s3, $s1

	lb	$a0, 0($s1)
	jal	print_number

	la	$a0, board_space_mid
	jal	print_string
	
	addi	$s3, $s3, 1
	j	print_board_loop_col
	
print_board_loop_col_done:
	
	la	$a0, east_hints
	move	$a1, $s2
	jal	print_y_hint
	
	addi	$s1, $s1, 4
	addi	$s2, $s2, 1
	
	j	print_board_loop_row

print_board_done:

	jal	print_break_row

	la	$a0, south_hints
	jal	print_x_hints
	
	la	$a0, new_line_char
	jal	print_string

	lw	$ra, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	addi	$sp, $sp, 20
	jr	$ra


#
# Name: Print break row
#
print_break_row:
	
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)

	la	$a0, new_line_char
	jal	print_string

	la	$a0, spacess
	jal	print_string
	
	la      $t1, board_size
	lb      $t1, 0($t1)

	li	$t0, 0


print_break_row_loop:
	
	beq	$t1, $t0, print_break_row_done

	la	$a0, board_row_break_part
	jal	print_string

	addi	$t0, $t0, 1

	j	print_break_row_loop

print_break_row_done:
	la	$a0, plus_char_break
	jal	print_string
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	
	jr	$ra


#
# Name: print y hint
#
# Arguments:
#    $a0: pointer to array
#    $a1: index
#
print_y_hint:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)

	add	$a0, $a0, $a1
	lb	$a0, 0($a0)
	jal	print_number

	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra



#
# Name: prints x axis hints
#
# Arguments: 
#     $a0: pointer to hint array
#
print_x_hints:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	move	$t2, $a0

	la      $t1, board_size
	lb      $t1, 0($t1)

	li	$t0, 0
	
	la	$a0, spaces
	jal	print_string

print_x_hints_loop:
	
	beq	$t1, $t0, print_x_hints_done
	
	la	$a0, spacesss
	jal	print_string

	lb	$a0, 0($t2)
	jal	print_number

	addi	$t2, $t2, 1
	addi	$t0, $t0, 1

	j	print_x_hints_loop

print_x_hints_done:
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	
	jr	$ra



print_string:
	li	$v0, PRINT_STRING
	syscall

	jr	$ra

print_number:
	li	$v0, PRINT_INT
	syscall

	jr	$ra










