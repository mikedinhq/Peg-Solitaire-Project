# board_model.gd
class_name BoardModel
extends BoardShapes

enum CellState { EMPTY, FILLED }

var cell_state: Dictionary = {}
var board_cells: Array[Vector2i] = []
var is_hex: bool = false
var Peg_label: Label

const HEX_DIRS = [
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1)
]

static func get_hex_directions():
	return HEX_DIRS

#region Getters
# hexagonal board configuration check
func get_hex():
	return is_hex

# whether the cell has a dictionary key or not
func has_cell_key(cell: Vector2i) -> bool:
	return cell_state.has(cell)

func get_cell_state(cell: Vector2i) -> bool:
	return cell_state.has(cell)

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

# set of move directions 
func jump_destinations(cell: Vector2i) -> Array[Vector2i]:
	var dests: Array[Vector2i] = []
	if is_hex:
		for dir in BoardModel.HEX_DIRS:
			dests.append(cell + dir * 2)
	else:
		dests = [
			cell + Vector2i(0,-2),
		 	cell + Vector2i(0,2),
			 cell + Vector2i(-2,0),
			 cell + Vector2i(2,0)]
	return dests

# determining possible moves
func can_move(from: Vector2i, to: Vector2i) -> bool:
	if not is_valid(from) or not is_valid(to): return false
	if not is_filled(from) or not is_empty(to): return false
	
	var mid = (from + to) / 2
	return is_valid(mid) and is_filled(mid)

# making that move
func execute_move(from: Vector2i, to: Vector2i) -> void:
	if not can_move(from, to): return
	set_empty(from)
	set_empty((from + to) / 2)
	set_filled(to)

# game over detection
func is_game_over() -> bool:
	var pegs_left = count_pegs()
	for cell in board_cells:
		if is_filled(cell):
			for to in jump_destinations(cell):
				if can_move(cell, to): return false
	
	if pegs_left == 1:
		print("Victory at 1 peg")
	else:
		print("There are ", pegs_left, " pegs left")
	
	return true

func count_pegs() -> int:
	var count = 0
	for state in cell_state.values():
		if state == CellState.FILLED:
			count += 1
	return count
