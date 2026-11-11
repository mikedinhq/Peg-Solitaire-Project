extends Control

@export var button_size := Vector2(32, 32)
@export var spacing := Vector2(8, 8)
var group = ButtonGroup.new()
#var button_group: ButtonGroup
enum CellState {EMPTY, FILLED}
var cell_state: Dictionary = {}
var valid_targets: Array[Vector2i] = []
var highlighted: Array[Vector2i] = []
var selected := Vector2i(-1, -1)   # (-1,-1) = nothing selected
var is_hex: bool = false
const HEX_DIRS = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
]
var board_cells: Array[Vector2i] = []
var autoplay_timer: Timer

func delete_board() -> void:
	#button_group = null
	for child in get_children():
		if child is Button:
			child.free()

#region cell_type
func cell_to_pixel(cell: Vector2i, hex_mode: bool) -> Vector2:
		if hex_mode == true:
			return _hex_to_pixel(cell.x, cell.y)
		else:
			return _rect_to_pixel(cell.x, cell.y)

func _rect_to_pixel(row: int, col: int) -> Vector2:
	return Vector2(
		col * (button_size.x + spacing.x),
		row * (button_size.y + spacing.y)
	)

func _hex_to_pixel(q: int, r: int) -> Vector2:
	var size = button_size.x / sqrt(3.0)
	return Vector2(
		size * sqrt(5.0) * (q + r / 2.0),
		size * 2 * r
	)
	
#endregion

#region board_type
func diamond_board(diameter: int) -> Array[Vector2i]:
	delete_board()
	diameter /= 2
	var cells: Array[Vector2i] = []
	var n := 2 * diameter + 1
	var center := diameter
	for r in range(n):
		for c in range(n):
			if abs(r-center) + abs(c-center) <= diameter:
				cells.append(Vector2i(r, c))
	return cells
	
func english_board(diameter: int) -> Array[Vector2i]:
	delete_board()
	var lower_bound = diameter/3
	var upper_bound = diameter - (lower_bound)
	
	var cells: Array[Vector2i] = []
	var n := 2 * diameter + 1
	var center := diameter
	
	for row in range(diameter):
		for col in range(diameter):
			if (col < lower_bound or col >= upper_bound) and (row < lower_bound or row >= upper_bound):
				pass
			else:
				cells.append(Vector2i(row, col))
	return cells

# Return CELL COORDINATES, not pixels
func hex_board(radius: int) -> Array[Vector2i]:
	radius /= 2
	var cells: Array[Vector2i] = []
	for q in range(-radius, radius + 1):
		for r in range(-radius, radius + 1):
			if abs(q) + abs(r) + abs(q + r) <= 2 * radius:
				cells.append(Vector2i(q, r))
	return cells
	
func make_board(cells: Array[Vector2i], size: int, hex_mode: bool) -> void:
	board_cells = cells
	is_hex = hex_mode
	for cell in cells:
		var btn = Button.new()
		var off = cell + Vector2i(8, 8)   # offset for negative hex coords
		btn.name = "Cell_%d_%d" % [off.x, off.y]
		btn.toggle_mode = true
		btn.button_group = group
		btn.custom_minimum_size = button_size
		btn.position = cell_to_pixel(cell, is_hex) - button_size / 2.0
		add_child(btn)
		btn.toggled.connect(_on_cell_clicked.bind(cell.x, cell.y))
		set_filled(cell)
		print_cell(cell)
		set_cell_color(cell, Color.BLACK)
	if is_hex == true:
		set_empty(Vector2i(0,0))
		print_cell(Vector2i(0,0))
	else:
		set_empty(Vector2i(size/2, size/2))
		print_cell(Vector2i(size/2, size/2))
		
func _choose_board(board, type, size) -> void:
	match type:
		'English': board.make_board(english_board(size), size)
		'Hexagon': board.make_board(hex_board(size), size, true)
		'Diamond': board.make_board(diamond_board(size), size)
		_: print("Unknown board type or WIP board type")
#endregion

func set_cell_color(cell: Vector2i, color: Color) -> void:
	var btn = get_button(cell)
	if btn == null:
		return   # invalid cell or missing button
	var style = btn.get_theme_stylebox("normal") as StyleBoxFlat
	if style == null:
		return
	var new_style = style.duplicate()
	new_style.bg_color = color
	btn.add_theme_stylebox_override("normal", new_style)

func get_cell_color(cell: Vector2i) -> Color:
	var btn = get_button(cell)
	if btn == null:
		return Color.TRANSPARENT
	var style = btn.get_theme_stylebox("normal") as StyleBoxFlat
	return style.bg_color if style else Color.TRANSPARENT

func restore_cell_color(cell: Vector2i) -> void:
	if not cell_state.has(cell):
		return
	var base := Color.BLACK if cell_state[cell] == CellState.FILLED else Color.WHITE
	set_cell_color(cell, base)

func print_cell(cell: Vector2i) -> void:
	if not cell_state.has(cell):
		print("Cell ", cell, " : INVALID (not on board)")
		return
	match cell_state[cell]:
		CellState.EMPTY:
			print("Cell ", cell, " : EMPTY")
		CellState.FILLED:
			print("Cell ", cell, " : FILLED")

func name_to_cell(node_name: String) -> Vector2i:
	var parts = node_name.trim_prefix("Cell_").split("_")
	return Vector2i(int(parts[0]), int(parts[1]))

func cell_to_name(cell: Vector2i) -> String:
	var off = cell + Vector2i(8, 8)   # only if you offset names for negatives
	return "Cell_%d_%d" % [off.x, off.y]

func get_button(cell: Vector2i) -> Button:
	return get_node_or_null(cell_to_name(cell)) as Button

func is_filled(cell: Vector2i) -> bool:
	return cell_state.get(cell) == CellState.FILLED

func is_valid(cell: Vector2i) -> bool:
	return cell_state.has(cell)

func set_empty(cell: Vector2i) -> void:
	if not cell_state.has(cell):
		return
	cell_state[cell] = CellState.EMPTY
	set_cell_color(cell, Color.WHITE)
	
func set_filled(cell: Vector2i) -> void:
	set_cell_color(cell, Color.BLACK)
	cell_state[cell] = CellState.FILLED

func is_empty(cell: Vector2i) -> bool:
	return cell_state.get(cell) == CellState.EMPTY

func can_move(from: Vector2i, to: Vector2i) -> bool:
	if not is_valid(from) or not is_valid(to):
		return false
	# Must move from a filled cell to an empty cell
	if not is_filled(from) or not is_empty(to):
		return false
	
	# Must be exactly 2 steps away (horizontal or vertical)
	var diff = to - from
	if abs(diff.x) + abs(diff.y) != 2 or (diff.x != 0 and diff.y != 0):
		return false
		
	var mid := (from + to) / 2
	return is_valid(mid) and is_filled(mid)

func clear_selection() -> void:
	clear_highlights()
	valid_targets.clear()
	selected = Vector2i(-1, -1)

func _on_cell_clicked(toggled_on: bool, row: int, col: int) -> void:
	var cell := Vector2i(row, col)

	# 1. Execute the move if clicking a valid target
	if selected != Vector2i(-1, -1) and cell in valid_targets:
		actualize_move(selected, cell)
		clear_selection()
		
		# FORCE the clicked button to look unpressed
		var btn = get_button(cell)
		if btn:
			btn.set_pressed_no_signal(false) 
		return

	# 2. Select a peg
	if is_filled(cell):
		selected = cell
		show_moves(cell)
		# Optional: If you want the selected peg to look pressed, 
		# leave it true. If you don't, uncomment the next line:
		# get_button(cell).set_pressed_no_signal(false)
	else:
		clear_selection()
		# Reset the visual state of the clicked empty cell
		var btn = get_button(cell)
		if btn:
			btn.set_pressed_no_signal(false)

static func get_hex_directions() -> Array[Vector2i]:
	return [
		Vector2i(1, 0),   # Down-Right
		Vector2i(1, -1),  # Up-Right
		Vector2i(0, -1),  # Up
		Vector2i(-1, 0),  # Up-Left
		Vector2i(-1, 1),  # Down-Left
		Vector2i(0, 1)    # Down
	]

func jump_destinations(cell: Vector2i) -> Array[Vector2i]:
	var dests: Array[Vector2i] = []
	
	if is_hex:
		# Hex logic: 6 directions, 2 steps each
		for dir in get_hex_directions():
			dests.append(cell + dir * 2)
	else:
		# Square logic: 4 directions, 2 steps each
		dests = [
			cell + Vector2i(0, -2), # up
			cell + Vector2i(0, 2),  # down
			cell + Vector2i(-2, 0), # left
			cell + Vector2i(2, 0)   # right
		]
		
	return dests

#func jump_destinations(cell: Vector2i) -> Array[Vector2i]:
	## Return a LOCAL array, do not overwrite valid_targets
	#return [
		#cell + Vector2i(0, -2), # up
		#cell + Vector2i(0, 2),  # down
		#cell + Vector2i(-2, 0), # left
		#cell + Vector2i(2, 0),  # right
	#]

func clear_highlights() -> void:
	for cell in highlighted:
		restore_cell_color(cell)
	highlighted.clear()

func refresh_highlights() -> void:
	for to in valid_targets:
		set_cell_color(to, Color.GREEN)
		highlighted.append(to)

func show_moves(from: Vector2i) -> void:
	clear_highlights()
	valid_targets.clear()
	for to in jump_destinations(from):
		if can_move(from, to):
			valid_targets.append(to)
	refresh_highlights()

func is_valid_target(cell: Vector2i) -> bool:
	return cell in valid_targets
	
func actualize_move(from: Vector2i, to: Vector2i) -> void:
	if not can_move(from, to):
		return
	var mid := (from + to) / 2

	set_empty(from)
	set_empty(mid)
	set_filled(to)

	# update visuals from state
	restore_cell_color(from)
	restore_cell_color(mid)
	restore_cell_color(to)
	
	if is_game_over():
		print("Game Over!")

func is_game_over() -> bool:
	# Loop through all valid cells on the board
	for cell in cell_state.keys():
		# Only filled pegs can jump
		if cell_state[cell] == CellState.FILLED:
			# Check all 4 (or 6 for hex) jump directions
			for to in jump_destinations(cell):
				if can_move(cell, to):
					# Found at least one valid move, game is not over
					return false
					
	# If we check every peg and find no moves, the game is over
	$"../Panel".show()
	return true

func randomize_board():
	clear_selection()
	
	for cell in board_cells:
		set_filled(cell)
		
	if board_cells.size() > 0:
		var random_index = randi() % board_cells.size()
		var empty_cell = board_cells[random_index]
		set_empty(empty_cell)

func start_autoplay() -> void:
	autoplay_timer.start()

func _on_autoplay_tick() -> void:
	if is_game_over():
		autoplay_timer.stop()
		print("Autoplay finished!")
		return
		
	# Find a valid move
	for from_cell in board_cells:
		if is_filled(from_cell):
			for to_cell in jump_destinations(from_cell):
				if can_move(from_cell, to_cell):
					# Execute the move!
					actualize_move(from_cell, to_cell)
					# Reset toggle visuals for both cells
					get_button(from_cell).set_pressed_no_signal(false)
					get_button(to_cell).set_pressed_no_signal(false)
					return # Exit and wait for the next timer tick

func _ready() -> void:
	# Setup a timer for autoplay
	autoplay_timer = Timer.new()
	autoplay_timer.wait_time = 0.5 # Half a second between moves
	autoplay_timer.timeout.connect(_on_autoplay_tick)
	add_child(autoplay_timer)
