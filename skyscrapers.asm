


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
illegal_input_error:
	.asciiz "Illegal input value, Skyscrapers terminating\n"
fixed_number_input_error:
	.asciiz "Invalid number of fixed values, Skyscrapers terminating\n"
fixed_input_error:
	.asciiz "Illegal fixed input values, Skyscrapers terminating\n"
	
	
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
# Name: write_board
#
# Arguments:
#    a0: x index
#    a1: y index
#    a2: value
#
write_board:
	la	$t0, board_size
	lb	$t0, 0($t0)
	#t0 has board width
	
	mul	$t0, $t0, $a1
	add	$t0, $t0, $a0
	
	la	$t1, board
	add	$t0, $t1, $t0
	sb	$a2, 0($t0)
	
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

#
# Name: read_input
#
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
	beq	$v0, $zero, read_input_error
	
	
	la	$a0, east_hints
	move	$a1, $s0
	jal	load_hints
	beq	$v0, $zero, read_input_error


	la	$a0, south_hints
	move	$a1, $s0
	jal	load_hints
	beq	$v0, $zero, read_input_error


	la	$a0, west_hints
	move	$a1, $s0
	jal	load_hints
	beq	$v0, $zero, read_input_error
	
	
	
	li	$v0, READ_INT
	syscall
	
	la	$a0, fixed_input_error
	blt	$v0, $zero, read_input_error
	
	move	$a0, $v0
	move	$a1, $s0
	jal	load_fixed
	beq	$v0, $zero, read_input_error
	


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







#
# Name: load_fixed
#
# Arguments: 
#    $a0: num of fixed towers
#    $a1: board Size
#
load_fixed:
	addi	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	move	$s0, $a0	#s0 contains number of fixed towers
	li	$s1, 0		#conter
	move	$s2, $a1
	
	li	$v0, 1
	
read_fixed_loop:

	beq	$s1, $s0, load_fixed_done
	
	#load x
	li	$v0, READ_INT
	syscall
	move	$t0, $v0
	
	blt	$t0, $zero, size_fixed_error
	blt	$s2, $t0, size_fixed_error
	
	#load y
	li	$v0, READ_INT
	syscall
	move	$t1, $v0
	
	blt	$t1, $zero, size_fixed_error
	blt	$s2, $t1, size_fixed_error
	
	#load value
	li	$v0, READ_INT
	syscall
	move	$t2, $v0
	
	li	$t9, 1
	blt	$t2, $t9, size_fixed_error
	blt	$s2, $t2, size_fixed_error
	
	move	$a0, $t0
	move	$a1, $t1
	move	$a2, $t2
	jal	write_board
	
	
	addi	$s1, $s1, 1
	j	read_fixed_loop	

size_fixed_error:
	
	la	$a0, fixed_input_error
	li	$v0, 0
	j	load_fixed_done
	
load_fixed_done:
	lw	$ra, 12($sp)
	lw	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	addi	$sp, $sp, 16
	jr	$ra






	

#
# Name: load_hints
#
# Arguments: 
#    $a0: hint array pointer
#    $a1: board size
#
load_hints:
	addi	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	move	$s0, $a0
	move	$s1, $a1
	
	li	$t0, 0		#counter
	li	$v0, 1
read_input_loop:
	
	beq	$t0, $s1, load_hints_done
	
	li	$v0, READ_INT
	syscall
	
	blt	$v0, $zero, size_input_error
	blt	$s1, $v0, size_input_error
	
	
	sb	$v0, 0($s0)
	addi	$s0, $s0, 1

	addi	$t0, $t0, 1
	j	read_input_loop

	
size_input_error:
	
	la	$a0, illegal_input_error
	li	$v0, 0
	j	load_hints_done
	
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
	la	$s1, board		#s1 contains board pointer
	li	$s2, 0

	la	$a0, north_hints
	jal	print_x_hints

print_board_loop_row:

	beq	$s2, $s0, print_board_done

	jal	print_break_row		#print break

	la	$a0, west_hints
	move	$a1, $s2
	jal	print_y_hint		#print y hint
	
	la	$a0, spaces
	jal	print_string

	la	$a0, board_space_front
	jal	print_string
	

	move	$s3, $zero


print_board_loop_col:

	beq	$s3, $s0, print_board_loop_col_done

	lb	$a0, 0($s1)
	jal	print_number

	la	$a0, board_space_mid
	jal	print_string
	
	addi	$s3, $s3, 1
	addi	$s1, $s1, 1
	j	print_board_loop_col
	
print_board_loop_col_done:
	
	la	$a0, east_hints
	move	$a1, $s2
	jal	print_y_hint
	
	#addi	$s1, $s1, 1
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










