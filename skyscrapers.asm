


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
spacess:
	.asciiz "  "
spaces:
	.asciiz " "
logo:
	.asciiz "\n*******************\n**  SKYSCRAPERS  **\n*******************\n"
init_puzzle:
	.asciiz "\nInitial Puzzle\n\n"
final_puzzle:
	.asciiz "final Puzzle\n\n"
impossible:
	.asciiz "Impossible Puzzle\n\n"
	
board_input_error:
	.asciiz "\nInvalid board size, Skyscrapers terminating\n"
illegal_input_error:
	.asciiz "\nIllegal input value, Skyscrapers terminating\n"
fixed_number_input_error:
	.asciiz "\nInvalid number of fixed values, Skyscrapers terminating\n"
fixed_input_error:
	.asciiz "\nIllegal fixed input values, Skyscrapers terminating\n"
	
	.text
	.align	2

#####################################################
#                  Program area                     #
#####################################################


#
# Name: Main
#
main:
	addi	$sp, $sp, -8
	sw	$ra, 4($sp)
	sw	$s0, 0($sp)
	
	la	$a0, logo
	jal	print_string
	
	jal	read_input
	beq	$v0, $zero, main_done	#end if it returned false.
	
	
	la	$a0, init_puzzle
	jal	print_string
	
	jal	print_board
	
	la	$a0, new_line_char
	jal	print_string
	
	
	la	$a0, board
	li	$a1, 0
	la	$t0, board_size
	lb	$a2, 0($t0)
	mul	$a3, $a2, $a2
	
	jal	eval
	
	beq	$v0, $zero, solve_fail
	
	la	$a0, final_puzzle
	jal	print_string
	
	jal	print_board
	la	$a0, new_line_char
	jal	print_string
	
	j	main_done
	
solve_fail:
	
	la	$a0, impossible
	jal	print_string
	
main_done:
	lw	$ra, 4($sp)
	lw	$s0, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra




#####################################################
#                    Sim eval                       #
#####################################################

#
# Name: eval
#
# Arguments:
#    a0: board location pointer
#    a1: board locaiton counter
#    a2: board bound
#    a3: board length
#
eval:
	addi	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s6, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	move	$s0, $a0				#save board pointer
	move	$s1, $a1				#save locaiton counter
	move	$s2, $a2				#save board bound
	move	$s3, $a3				#save board length
	
	lb	$s5, 0($s0)				#save current value
	
	beq	$s5, $zero, eval_not_found_fixed	#if the current location is 0 branch
	
	#fixed found if here
	
	addi	$t3, $s3, -1
	bne	$s1, $t3, no_last_fixed_space		#if its the last fixed space, continue
	
	
	#here it is the last fixed space
	jal	validate_board
	
	#if v0 is 0, bad. if not good
	
	j	eval_end

no_last_fixed_space:
	
	addi	$a0, $s0, 1				#tick board pointer
	addi	$a1, $s1, 1				#tick counter
	move	$a2, $s2				
	move	$a3, $s3
	move	$v0, $zero
	
	jal	eval					#recurse
	
	j	eval_end

eval_not_found_fixed:
	
	li	$s4, 1					#s4 is our counter for the loop (cant use 0)
	
eval_loop:
	
	addi	$t9, $s2, 1
	beq	$s4, $t9, eval_loop_done
	
	sb	$s4, 0($s0)				#write to board
	jal	validate_board				#validate
	
	beq	$v0, $zero, eval_loop_bottom		#branch if bad place
	
	addi	$t3, $s3, -1
	bne	$s1, $t3, not_last_place
	
	#here it is the last place and v0 is 1 so return 1
	j	eval_end
	
	
not_last_place:
	addi	$a0, $s0, 1				#tick board pointer
	addi	$a1, $s1, 1				#tick counter
	move	$a2, $s2				
	move	$a3, $s3
	move	$v0, $zero
	
	jal	eval					#recurse
	
	beq	$v0, $zero, eval_loop_bottom
	
	j	eval_end
	
eval_loop_bottom:
	
	sb	$zero, 0($s0)				#rest board locaiton
	addi	$s4, $s4, 1				#tick
	j	eval_loop
	
	
eval_loop_done:
	j	eval_end
	
eval_end:
	
	lw	$ra, 28($sp)
	lw	$s6, 24($sp)
	lw	$s5, 20($sp)
	lw	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	addi	$sp, $sp, 32
	jr	$ra







#####################################################
#                    validate                       #
#####################################################

#
# Name: validate_board
#
#
validate_board:
	addi	$sp, $sp, -8
	sw	$ra, 4($sp)
	sw	$s0, 0($sp)
	
	la	$t0, board_size
	lb	$s0, 0($t0)
	
	
	la	$a0, north_hints
	la	$a1, get_next_north
	move	$a2, $s0
	
	jal	generic_check_board
	
	beq	$v0, $zero, done_validate
	
	la	$a0, south_hints
	la	$a1, get_next_south
	move	$a2, $s0
	
	jal	generic_check_board
	
	beq	$v0, $zero, done_validate
	
	la	$a0, east_hints
	la	$a1, get_next_east
	move	$a2, $s0
	
	jal	generic_check_board
	
	beq	$v0, $zero, done_validate
	
	la	$a0, west_hints
	la	$a1, get_next_west
	move	$a2, $s0
	
	jal	generic_check_board
	
	beq	$v0, $zero, done_validate
	
	
done_validate:
	lw	$ra, 4($sp)
	lw	$s0, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra


#
# Name: generic_check_board
#
# Arguments:
#    a0: hint_pointer
#    a1: index_funct_pointer
#    a2: board_size
#
generic_check_board:
	addi	$sp, $sp, -36
	sw	$ra, 32($sp)
	sw	$s7, 28($sp)
	sw	$s6, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	
	move	$s0, $a0		#hint pointer
	move	$s1, $a1		#index funct pointer
	move	$s2, $a2		#board size
	
	li	$s3, 0			#col counter
	li	$s6, 1			#defualt to pass
		
	
generic_check_loop_col:

	beq	$s2, $s3, generic_check_loop_done_col
	
	
	li	$s4, 0			#row counter
	li	$s5, 0			#height counter
	li	$t5, 0			#last building
	
	#check result
	
	lb	$s7, 0($s0)		#current hint
	
generic_check_loop_row:

	
	beq	$s7, $zero, generic_check_loop_done_row		#no hint, pass

	beq	$s2, $s4, generic_check_loop_done_row		#normal loop end
	
	addi	$a0, $s4, -1		#backup one
	move	$a1, $s3
	move	$a2, $s2		#alwas load boar size even though north and west dont need
	
	
	
	addi	$sp, $sp, -4		#have to save restore $t5
	sw	$t5, 0($sp)
	
	jalr	$s1			#call indexer funct
	
	lw	$t5, 0($sp)
	addi	$sp, $sp, 4
	
	move	$t2, $v0		#set cur
	
	
	
	move	$a0, $s3		#load col number
	move	$a1, $s1		#funct pointer
	move	$a2, $t2		#val
	move	$a3, $s2		#board size
	
	addi	$sp, $sp, -8		#have to save restore stuff
	sw	$t2, 4($sp)
	sw	$t5, 0($sp)
	
	jal	repeat_check
	
	lw	$t5, 0($sp)
	lw	$t2, 4($sp)
	addi	$sp, $sp, 8
	
	bne	$v0, $zero, check_fail
	
	
	
	beq	$t2, $zero, generic_check_loop_found_zero	#found zero, not finished, valid
	
	addi	$t6, $t5, 1
	blt	$t2, $t6, pass_add
	
	addi	$s5, $s5, 1					#add to new if its last
	move	$t5, $t2					#set as new greatest
	move	$a0, $t5
	
pass_add:

	j	continue_check_loop
	
continue_check_loop:
	
	addi	$s4, $s4, 1
	j	generic_check_loop_row

generic_check_loop_done_row:
	
	beq	$s5, $s7, generic_check_loop_found_zero
	j	check_fail
	
generic_check_loop_found_zero:
	
	addi	$s0, $s0, 1
	
	addi	$s3, $s3, 1
	j	generic_check_loop_col
	
	############### fail #################
check_fail:
	li	$s6, 0				#reutrn 0
	j	generic_check_loop_done_col	#break all loops	

generic_check_loop_done_col:

	move	$v0, $s6	#reutrn result
	
	lw	$ra, 32($sp)
	lw	$s7, 28($sp)
	lw	$s6, 24($sp)
	lw	$s5, 20($sp)
	lw	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	addi	$sp, $sp, 36
	jr	$ra
	
	
#
# Name: repeat check
#
# Arguments:
#    a0: col number
#    a1: get_next_pointer
#    a2: val
#    a3: board_size
#	
repeat_check:
	addi	$sp, $sp, -36
	sw	$ra, 32($sp)
	sw	$s7, 28($sp)
	sw	$s6, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)

	move	$s0, $a0	#col
	move	$s1, $a1	#funct
	move	$s2, $a2	#val
	move	$s3, $a3	#board_size
	
	li	$s4, 0		#counter
	li	$s5, 0		#false by default
	li	$s6, 0		#rpt counter
	
repeat_check_loop:
	
	beq	$s4, $s3, repeat_check_loop_done
	
	addi	$a0, $s4, -1		#backup one to get next
	move	$a1, $s0		#col
	move	$a2, $s3		#alwas load boar size even though north and west dont need
	
	jalr	$s1			#call indexer funct
	
	beq	$v0, $zero, repeat_check_loop_done
	bne	$v0, $s2, repeat_check_loop_bottom
	
	#match_found

	addi	$s6, $s6, 1
	
	li	$t2, 2
	beq	$s6, $t2, repeat_found
	
	
repeat_check_loop_bottom:
	addi	$s4, $s4, 1
	j	repeat_check_loop
	
repeat_found:
	
	li	$s5, 1

repeat_check_loop_done:
	
	
	move	$v0, $s5
	
	lw	$ra, 32($sp)
	lw	$s7, 28($sp)
	lw	$s6, 24($sp)
	lw	$s5, 20($sp)
	lw	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	addi	$sp, $sp, 36
	jr	$ra

	

#
# Name: get_next_north
#
# Arguments:
#    a0: col index
#    a1: current_row_index
#
get_next_north:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	addi	$a0, $a0, 1
	
	jal	read_board
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra

#
# Name: get_next_west
#
# Arguments:
#    a0: row index
#    a1: current_col_index
#
get_next_west:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	move	$t0, $a1
	addi	$a1, $a0, 1
	move	$a0, $t0
	
	jal	read_board
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra

#
# Name: get_next_east
#
# Arguments:
#    a0: row index
#    a1: current_col_index
#    a2: board size
#
get_next_east:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	move	$t0, $a1
	addi	$a1, $a0, 1
	sub	$a1, $a2, $a1
	addi	$a1, $a1, -1
	move	$a0, $t0
	
	jal	read_board
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
#
# Name: get_next_south
#
# Arguments:
#    a0: col index
#    a1: current_row_index
#    a2: board size
#
get_next_south:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	
	addi	$a0, $a0, 1
	
	sub	$a0, $a2, $a0		#reverse index
	addi	$a0, $a0, -1
	
	jal	read_board
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra




#####################################################
#               Data Acces Functions                #
#####################################################

#
# Name: read_board
#
# Arguments:
#    a0: x index
#    a1: y index
#
read_board:
	la	$t0, board_size
	lb	$t0, 0($t0)
	#t0 has board width
	
	mul	$t0, $t0, $a0
	add	$t0, $t0, $a1
	
	la	$t1, board
	add	$t0, $t1, $t0
	lb	$v0, 0($t0)
	
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
	
	mul	$t0, $t0, $a0
	add	$t0, $t0, $a1
	
	la	$t1, board
	add	$t0, $t1, $t0
	sb	$a2, 0($t0)
	
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
	
	la	$a0, fixed_number_input_error
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
	addi	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	move	$s0, $a0	#s0 contains number of fixed towers
	li	$s1, 0		#conter
	move	$s2, $a1
	
	li	$s3, 1
	
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
	li	$s3, 0
	j	load_fixed_done
	
load_fixed_done:
	move	$v0, $s3
	lw	$ra, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	addi	$sp, $sp, 20
	jr	$ra






	

#
# Name: load_hints
#
# Arguments: 
#    $a0: hint array pointer
#    $a1: board size
#
load_hints:
	addi	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	move	$s0, $a0
	move	$s1, $a1
	
	li	$t0, 0		#counter
	li	$s3, 1
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
	li	$s3, 0
	j	load_hints_done
	
load_hints_done:
	move	$v0, $s3
	lw	$ra, 12($sp)
	lw	$s1, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	addi	$sp, $sp, 16
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
	jal	print_number_exclude

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
	jal	print_number_exclude

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
	
	la	$a0, spacess
	jal	print_string

	la	$a0, spaces
	jal	print_string
	
	lb	$a0, 0($t2)
	jal	print_number_exclude

	
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



#
# Name: print_number_exclude
#    prints numbers excluding zero
#
#
print_number_exclude:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	beq	$a0, $zero, print_space
	
	li	$v0, PRINT_INT
	syscall
	
	j	done_print_number_exclude
	
print_space:
	la	$a0, spaces
	jal	print_string
	
done_print_number_exclude:

	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra

#
# Name: print_number
#    prints numbers
#
#
print_number:
	li	$v0, PRINT_INT
	syscall

	jr	$ra




