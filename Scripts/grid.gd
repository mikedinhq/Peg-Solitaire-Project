extends Control

@onready var game_over_panel: Control = $"../GameOverPanel"
@onready var autoplay_button: Button = $"../Autoplay"
@onready var replay_button = $"../GameOverPanel/Replay"
@onready var peg_label = $"../GameOverPanel/Pegs"
@export var button_size := Vector2(32, 32)
@export var spacing := Vector2(8, 8)
var buttons: Dictionary = {}

var model := BoardModel.new()
var valid_targets: Array[Vector2i] = []
var highlighted: Array[Vector2i] = []
# (-100,-100) = nothing on the board selected will need to be bigger if board size has it
var selected := Vector2i(-100, -100)   

var autoplay_timer: Timer

# configure setup
func make_board(cells: Array[Vector2i], size: int, layout: String = 'rect') -> void:
	delete_board()
	model.setup(cells, layout == "hex")
	
	for cell in cells:
		# 0. Initialize new button
		var btn = Button.new()
		
		# 1. Calculate Position
		var pos = BoardShapes.hex_to_pixel(cell.x, cell.y, button_size) if layout == "hex" else BoardShapes.rect_to_pixel(cell.x, cell.y, button_size, spacing)
		btn.position = pos - button_size / 2.0
		
		# 2. Setup Visuals
		btn.name = "Cell_%d_%d" % [cell.x + 100, cell.y + 100] # +100 offset for negative hex coords
		btn.toggle_mode = true
		btn.custom_minimum_size = button_size
		add_child(btn)
		buttons[cell] = btn
		btn.toggled.connect(_on_cell_clicked.bind(cell.x, cell.y))
		
		# 3. Apply Initial Color
		update_cell_visual(cell)
		
	# sets the center cell/button as empty
	# hexagonal positioning 
	if model.is_hex:
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
		'English': make_board(BoardShapes.english_board(size), size)
		'Hexagon': make_board(BoardShapes.hexagon_board(size), size, 'hex')
		'Diamond': make_board(BoardShapes.diamond_board(size), size)
		_: print("Unknown board type or WIP board type")

# erase board
func delete_board() -> void:
	for btn in buttons.values():
		btn.free()
	buttons.clear()

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
	if not model.is_valid(cell):
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
	for move in model.legal_moves():
		if move[0] == from:
			valid_targets.append(move[1])
	refresh_highlights()

func is_valid_target(cell: Vector2i) -> bool:
	return cell in valid_targets

func clear_selection() -> void:
	clear_highlights()
	valid_targets.clear()
	selected = Vector2i(-100, -100)

func _on_cell_clicked(toggled_on: bool, row: int, col: int) -> void:
	var cell := Vector2i(row, col)

	# 1. Execute the move if clicking a valid target
	if selected != Vector2i(-100, -100) and cell in valid_targets:
				
		_apply_move([selected, cell])
		clear_selection()
		_reset_toggle(cell)
		_handle_game_over()
		return

	# 2. Select a peg
	if model.is_filled(cell):
		selected = cell
		show_moves(cell)
	else:
		clear_selection()
		_reset_toggle(cell)

func _apply_move(move: Array) -> void:
	var from_cell: Vector2i = move[0]
	var to_cell: Vector2i = move[1]
	var mid_cell: Vector2i = model.mid_cell(from_cell, to_cell)
	model.execute_move(from_cell, to_cell)
	update_cell_visual(from_cell)
	update_cell_visual(mid_cell)
	update_cell_visual(to_cell)

func randomize_board(probability):
	clear_selection()
	model.randomize_cells(probability)
	for cell in model.get_board_cells():
		update_cell_visual(cell)

func new_game(type: String, size: int) -> void:
	delete_board()
	_choose_board(type, size)

func replay_function(type: String, size: int):
	replay_button.set_pressed_no_signal(false)
	game_over_panel.hide()
	new_game(type, size)

func start_autoplay() -> void:
	autoplay_timer.start()

func stop_autoplay() -> void:
	autoplay_timer.stop()

func _on_autoplay_tick() -> void:
	var moves := model.legal_moves()
	if moves.is_empty():
		_handle_game_over()
		return
	var move = moves.pick_random()
	_apply_move(move)
	
	# 3. Reset the toggles that _apply_move doesn't already reset.
	_reset_toggle(move[0])
	_reset_toggle(move[1])

func get_button(cell: Vector2i) -> Button:
	return buttons.get(cell)

func _handle_game_over() -> void:
	if model.is_game_over():
		autoplay_timer.stop()
		game_over_panel.show()
		autoplay_button.button_pressed = false
		peg_label.text = "%d pegs left" % [model.count_pegs()]

func _reset_toggle(cell: Vector2i) -> void:
	var btn = get_button(cell)
	if btn:
		btn.set_pressed_no_signal(false)

func _ready() -> void:
	# Setup a timer for autoplay
	autoplay_timer = Timer.new()
	autoplay_timer.wait_time = 0.5 # Half a second between moves
	autoplay_timer.timeout.connect(_on_autoplay_tick)
	add_child(autoplay_timer)
