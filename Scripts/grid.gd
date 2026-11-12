extends Control

@export var button_size := Vector2(32, 32)
@export var spacing := Vector2(8, 8)

var shapes := BoardShapes.new()
var model := BoardModel.new()
var valid_targets: Array[Vector2i] = []
var highlighted: Array[Vector2i] = []
var selected := Vector2i(-1, -1)   # (-1,-1) = nothing selected

var autoplay_timer: Timer

# configure setup
func make_board(cells: Array[Vector2i], size: int, layout: String = 'rect') -> void:
	delete_board()
	model.setup(cells, layout == "hex")
	
	for cell in cells:
		# 0. Initialize new button
		var btn = Button.new()
		
		# 1. Calculate Position
		var pos = shapes._hex_to_pixel(cell.x, cell.y, button_size) if layout == "hex" else shapes._rect_to_pixel(cell.x, cell.y, button_size, spacing)
		btn.position = pos - button_size / 2.0
		
		# 2. Setup Visuals
		btn.name = "Cell_%d_%d" % [cell.x + 100, cell.y + 100] # +100 offset for negative hex coords
		btn.toggle_mode = true
		btn.custom_minimum_size = button_size
		add_child(btn)
		btn.toggled.connect(_on_cell_clicked.bind(cell.x, cell.y))
		
		# 3. Apply Initial Color
		update_cell_visual(cell)
		
	# sets the center cell/button as empty
	# hexagonal positioning 
	if model.get_hex() == true:
		model.set_empty(Vector2i(0,0))
		set_cell_color(Vector2i(0,0), Color.WHITE)
		print_cell(Vector2i(0,0))
	else:
	# rectangular positioning
		set_cell_color(Vector2i(size/2, size/2), Color.WHITE)
		model.set_empty(Vector2i(size/2, size/2))
		print_cell(Vector2i(size/2, size/2))

# interfaces with the drop down menu on control.gd/the GUI script
func _choose_board(type, size) -> void:
	match type:
		'English': make_board(model.english_board(size), size)
		'Hexagon': make_board(model.hexagon_board(size), size, 'hex')
		'Diamond': make_board(model.diamond_board(size), size)
		_: print("Unknown board type or WIP board type")

# erase board
func delete_board() -> void:
	#button_group = null
	for child in get_children():
		if child is Button:
			child.free()

# updates color of board whenever called mostly on executing moves
func update_cell_visual(cell: Vector2i) -> void:
	if not model.is_valid(cell): return
	var color = Color.BLACK if model.is_filled(cell) else Color.WHITE
	set_cell_color(cell, color)


# cell color setter
func set_cell_color(cell: Vector2i, color: Color) -> void:
	var btn = get_button(cell)
	if btn == null:
		return   # invalid cell or missing button
		
	var style = btn.get_theme_stylebox("normal") as StyleBoxFlat
	if style:
		var new_style = style.duplicate()
		new_style.bg_color = color
		btn.add_theme_stylebox_override("normal", new_style)
		
	var pressed_style = btn.get_theme_stylebox("pressed") as StyleBoxFlat
	if pressed_style:
		var new_pressed = pressed_style.duplicate()
		new_pressed.bg_color = color
		btn.add_theme_stylebox_override("pressed", new_pressed)

# cell color getter
func get_cell_color(cell: Vector2i) -> Color:
	var btn = get_button(cell)
	if btn == null:
		return Color.TRANSPARENT
	var style = btn.get_theme_stylebox("normal") as StyleBoxFlat
	return style.bg_color if style else Color.TRANSPARENT

func print_cell(cell: Vector2i) -> void:
	if not model.has_cell_key(cell):
		print("Cell ", cell, " : INVALID (not on board)")
		return
	if model.is_empty(cell):
		print("Cell ", cell, " : EMPTY")
	else:
		print("Cell ", cell, " : FILLED")

func clear_highlights() -> void:
	for cell in highlighted:
		update_cell_visual(cell)
	highlighted.clear()

func refresh_highlights() -> void:
	for to in valid_targets:
		set_cell_color(to, Color.GREEN)
		highlighted.append(to)

func show_moves(from: Vector2i) -> void:
	clear_highlights()
	valid_targets.clear()
	for to in model.jump_destinations(from):
		if model.can_move(from, to):
			valid_targets.append(to)
	refresh_highlights()

func is_valid_target(cell: Vector2i) -> bool:
	return cell in valid_targets

func clear_selection() -> void:
	clear_highlights()
	valid_targets.clear()
	selected = Vector2i(-1, -1)

func _on_cell_clicked(toggled_on: bool, row: int, col: int) -> void:
	var cell := Vector2i(row, col)

	# 1. Execute the move if clicking a valid target
	if selected != Vector2i(-1, -1) and cell in valid_targets:
		var from_cell = selected
		var mid_cell = (from_cell + cell) / 2
		model.execute_move(selected, cell)
		clear_selection()
		
		update_cell_visual(from_cell)
		update_cell_visual(mid_cell)
		update_cell_visual(cell)
		
		# force clicked button to look unpressed
		var btn = get_button(cell)
		if btn:
			btn.set_pressed_no_signal(false) 
		return

	# 2. Select a peg
	if model.is_filled(cell):
		selected = cell
		show_moves(cell)
		

	else:
		clear_selection()
		# Reset the visual state of the clicked empty cell
		var btn = get_button(cell)
		if btn:
			btn.set_pressed_no_signal(false)

func randomize_board():
	clear_selection()
	
	for cell in model.get_board_cells():
		model.set_filled(cell)
		
	if model.board_cells.size() > 0:
		var random_index = randi() % model.board_cells.size()
		var empty_cell = model.board_cells[random_index]
		model.set_empty(empty_cell)

func start_autoplay() -> void:
	autoplay_timer.start()

func _on_autoplay_tick() -> void:
	if model.is_game_over():
		autoplay_timer.stop()
		$"../GameOverPanel".show()
		$"../Autoplay".button_pressed = false
		print("Autoplay finished!")
		return
		
	# Find a valid move
	for from_cell in model.get_board_cells():
		if model.is_filled(from_cell):
			for to_cell in model.jump_destinations(from_cell):
				if model.can_move(from_cell, to_cell):
					var mid_cell = (from_cell + to_cell) / 2
					# Execute the move!
					model.execute_move(from_cell, to_cell)
					
					update_cell_visual(from_cell)
					update_cell_visual(mid_cell)
					update_cell_visual(to_cell)
					
					# Reset toggle visuals for both cells
					get_button(from_cell).set_pressed_no_signal(false)
					get_button(to_cell).set_pressed_no_signal(false)
					return # Exit and wait for the next timer tick

func get_button(cell: Vector2i) -> Button:
	return get_node_or_null("Cell_%d_%d" % [cell.x + 100, cell.y + 100]) as Button

func _ready() -> void:
	# Setup a timer for autoplay
	autoplay_timer = Timer.new()
	autoplay_timer.wait_time = 0.5 # Half a second between moves
	autoplay_timer.timeout.connect(_on_autoplay_tick)
	add_child(autoplay_timer)
