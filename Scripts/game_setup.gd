# res://src/board_game.gd
class_name BoardGame
extends RefCounted

const VALID_BOARD_TYPES := ["square", "hex"]
const VALID_SIZES := [1, 3, 5, 8]

var board_size: int = 3
var board_type: String = "square"
var board: Array = []          # flat array of cell values (null or player id)
var current_turn: int = 1
var is_game_active: bool = false
var winner: String = ""
var _move_count: int = 0

# --- 1. Board configuration ---

func set_board_size(size: int) -> bool:
	if size <= 0 or not VALID_SIZES.has(size):
		return false
	board_size = size
	return true

func set_board_type(type: String) -> bool:
	if not VALID_BOARD_TYPES.has(type):
		return false
	board_type = type
	return true

# --- 2. Start a new game ---

func start_new_game() -> void:
	board.clear()
	for i in range(board_size * board_size):
		board.append(null)
	current_turn = 1
	is_game_active = true
	winner = ""
	_move_count = 0

# --- 3. Making a move ---

func make_move(pos: Vector2i, player: String) -> bool:
	if not is_game_active:
		return false
	if not _is_in_bounds(pos):
		return false
	var idx := _to_index(pos)
	if board[idx] != null:
		return false

	board[idx] = player
	_move_count += 1
	current_turn += 1
	_check_end_of_game()
	return true

func get_piece_at(pos: Vector2i) -> Variant:
	if not _is_in_bounds(pos):
		return null
	return board[_to_index(pos)]

# --- 4. End of game ---

func is_game_over() -> bool:
	return not is_game_active

func _check_end_of_game() -> void:
	# Win check: any full row, column, or diagonal
	var lines := _get_lines()
	for line in lines:
		var first = line[0]
		if first == null:
			continue
		var all_same := true
		for v in line:
			if v != first:
				all_same = false
				break
		if all_same:
			winner = first
			is_game_active = false
			return

	# Draw check: board full, no winner
	if _move_count >= board.size():
		winner = ""
		is_game_active = false

# --- Helpers ---

func _is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.y >= 0 and pos.x < board_size and pos.y < board_size

func _to_index(pos: Vector2i) -> int:
	return pos.y * board_size + pos.x

func _get_lines() -> Array:
	var lines: Array = []
	# Rows
	for y in range(board_size):
		var row: Array = []
		for x in range(board_size):
			row.append(board[_to_index(Vector2i(x, y))])
		lines.append(row)
	# Columns
	for x in range(board_size):
		var col: Array = []
		for y in range(board_size):
			col.append(board[_to_index(Vector2i(x, y))])
		lines.append(col)
	# Diagonals (only square boards)
	if board_type == "square":
		var diag1: Array = []
		var diag2: Array = []
		for i in range(board_size):
			diag1.append(board[_to_index(Vector2i(i, i))])
			diag2.append(board[_to_index(Vector2i(board_size - 1 - i, i))])
		lines.append(diag1)
		lines.append(diag2)
	return lines
