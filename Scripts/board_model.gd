# board_model.gd
class_name BoardModel

enum CellState { EMPTY, FILLED }

var cell_state: Dictionary = {}
var board_cells: Array[Vector2i] = []
var is_hex: bool = false

const HEX_DIRS : Array[Vector2i] = [
	Vector2i(2, 0),
	Vector2i(2, -2),
	Vector2i(0, -2),
	Vector2i(-2, 0),
	Vector2i(-2, 2),
	Vector2i(0, 2)]
	
const RECT_DIRS: Array[Vector2i] = [
	Vector2i(0,-2),
	Vector2i(0,2),
	Vector2i(-2,0),
	Vector2i(2,0)]

#region Getters
func get_board_cells():
	return board_cells
#endregion

# Initialization   
func setup(cells: Array[Vector2i], hex_mode: bool) -> void:
	board_cells = cells
	is_hex = hex_mode
	cell_state.clear()
	for cell in cells:
		cell_state[cell] = CellState.FILLED

func is_valid(cell: Vector2i) -> bool:
	return cell_state.has(cell)

func is_filled(cell: Vector2i) -> bool:
	return cell_state.get(cell) == CellState.FILLED

func is_empty(cell: Vector2i) -> bool:
	return cell_state.get(cell) == CellState.EMPTY

func set_empty(cell: Vector2i) -> void:
	if is_valid(cell): cell_state[cell] = CellState.EMPTY

func set_filled(cell: Vector2i) -> void:
	if is_valid(cell): cell_state[cell] = CellState.FILLED

func mid_cell(from: Vector2i, to: Vector2i) -> Vector2i:
	return ((from + to) / 2)

# set of move directions 
func jump_destinations(cell: Vector2i) -> Array[Vector2i]:
	var dir := HEX_DIRS if is_hex else RECT_DIRS
	var dest: Array[Vector2i] = []
	for d in dir:
		dest.append(cell + d)
	return dest

# determining possible moves
func can_move(from: Vector2i, to: Vector2i) -> bool:
	if not is_valid(from) or not is_valid(to): return false
	if not is_filled(from) or not is_empty(to): return false
	
	var mid = mid_cell(from, to)
	return is_valid(mid) and is_filled(mid)

func legal_moves() -> Array[Array]:
	var moves: Array[Array] = []
	for from_cell in board_cells:
		if not is_filled(from_cell):
			continue
		for to_cell in jump_destinations(from_cell):
			if can_move(from_cell, to_cell):
				moves.append([from_cell, to_cell])
	return moves

# making that move
func execute_move(from: Vector2i, to: Vector2i) -> void:
	if not can_move(from, to): return
	set_empty(from)
	set_empty(mid_cell(from, to))
	set_filled(to)

func randomize_cells(probability) -> void:
	
	# chance to be filled/empty
	for cell in get_board_cells():
		if randi_range(1, 100) >= probability:
			set_filled(cell)
		else:
			set_empty(cell)
			
	# at least 1 cell is empty when Prob = 100
	if not board_cells.is_empty():
		set_empty(board_cells.pick_random())

# game over detection
func is_game_over() -> bool:
	return legal_moves().is_empty()

func count_pegs() -> int:
	var count = 0
	for state in cell_state.values():
		if state == CellState.FILLED:
			count += 1
	return count
