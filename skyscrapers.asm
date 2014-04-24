




PRINT_INT = 1
PRINT_STRING = 4
EXIT = 10

	.data
	.align	0



board_size:
	.byte	0
board:
	.space	256	#64 bytes to handle max size board

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


	.text
	.align	2



main:
	addi	$sp, $sp, -8
	sw	$ra, 4($sp)
	sw	$s0, 0($sp)
	
	la	$t0, board_size
	li	$t1, 3

	sb	$t1, 0($t0)

	jal	print_board

	lw	$ra, 4($sp)
	lw	$s0, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra

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

print_board_loop_row:

	beq	$s2, $s0, print_board_done

	jal	print_break_row

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
	addi	$s1, $s1, 4
	addi	$s2, $s2, 1
	j	print_board_loop_row

print_board_done:

	jal	print_break_row

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

	


print_string:
	li	$v0, PRINT_STRING
	syscall

	jr	$ra

print_number:
	li	$v0, PRINT_INT
	syscall

	jr	$ra










