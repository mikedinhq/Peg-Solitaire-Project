extends Control

@export var button_size := Vector2(32, 32)
@export var spacing := Vector2(8, 8)
#var group = ButtonGroup.new()

func make_english_board(n) -> void:
	# for the first n*1/3 print nothing out
	var absent_n1 = n/3
	var absent_n2 = n - (absent_n1)
	var middle = (1+(n/2))

	for row in range(n):
		for col in range(n):
			var btn = Button.new()
			if (col < absent_n1 or col >= absent_n2) and (row < absent_n1 or row >= absent_n2):
				pass
				
			else:
				
				var pressed_style = StyleBoxFlat.new()
				pressed_style.bg_color = Color.RED  # Replace with the color you want

				# Apply it to this button
				btn.add_theme_stylebox_override("pressed", pressed_style)
				btn.toggle_mode = true
				btn.custom_minimum_size = button_size
				btn.name = "Cell_%d_%d" % [row, col]
				var pos_x = col * (button_size.x + spacing.x)
				var pos_y = row * (button_size.y + spacing.y)
				btn.position = Vector2(pos_x, pos_y)
				# Set BOTH states explicitly so the color is predictable
				#btn.add_theme_color_override("font_color", Color.WHITE)
				#btn.add_theme_color_override("font_pressed_color", Color.RED)

				# Optional: also override hover-pressed so it doesn't revert while hovering
				#btn.add_theme_color_override("font_hover_pressed_color", Color.RED)
				
				add_child(btn)
				#btn.add_theme_color_override("pressed", Color.WHITE)
				btn.toggled.connect(_on_cell_clicked.bind(row, col))
		#var middle_style = StyleBoxFlat.new()


func make_square(n) -> void:
	delete_board()
	var middle = (1+(n/2))
	var normal_style = StyleBoxFlat.new()
	var pressed_style = StyleBoxFlat.new()
	var empty_style = StyleBoxFlat.new()
	pressed_style.bg_color = Color.BLACK  # Replace with the color you want
	normal_style.bg_color = Color.DIM_GRAY
	empty_style.bg_color = Color.WHITE
	
	#btn.add_theme_stylebox_override("hover", pressed_style)
	
	for row in range(n):
		for col in range(n):
			var btn = Button.new()
			#color_handler(btn, 1)
			btn.name = "Cell_%d_%d" % [row, col]
			if btn.name == "Cell_%d_%d" % [n/2, n/2]:
				btn.add_theme_stylebox_override("hover", empty_style)
				btn.disabled = true
				print("disabled=", btn.disabled, " visible=", btn.visible, " modulate=", btn.modulate)
			else:
				btn.add_theme_stylebox_override("normal", normal_style)
			btn.toggle_mode = false
			#btn.button_group = group
			btn.custom_minimum_size = button_size
			var pos_x = col * (button_size.x + spacing.x)
			var pos_y = row * (button_size.y + spacing.y)
			btn.position = Vector2(pos_x, pos_y)
			btn.add_theme_stylebox_override("normal", empty_style)
			add_child(btn)
			btn.pressed.connect(_on_cell_clicked.bind("Cell_%d_%d" % [n/2, n/2], row, col, n))
			
		#var b = get_node("Cell_%d_%d" % [n/2, n/2])
		#b.self_modulate = Color.WHITE
	

func make_triangle(n):
	var rows = n  # Triangle has 5 rows
	var max_cols = rows
	for row in range(rows):
		# Row `row` has `row + 1` buttons
		var cols_in_row = row + 1
	# Calculate how much this row needs to be offset to center it
		var row_width = cols_in_row * button_size.x + (cols_in_row - 1) * spacing.x
		var max_row_width = max_cols * button_size.x + (max_cols - 1) * spacing.x
		var offset_x = (max_row_width - row_width) / 2.0
		for col in range(row + 1):
			if (row/2):
				pass
			var btn = Button.new()
			btn.name = "Cell_%d_%d" % [row, col]
			if btn.name == "Cell_%d_%d" % [n/2, n/2]:
				btn.self_modulate = Color.DIM_GRAY
			else:
				btn.self_modulate = Color.WHITE
			btn.toggle_mode = false
			btn.custom_minimum_size = button_size
			btn.size = button_size
			
			# Key: calculate x, y position yourself
			var pos_x = col * (button_size.x + spacing.x)
			var pos_y = row * (button_size.y + spacing.y)
			btn.position = Vector2(pos_x+offset_x, pos_y)
			
			add_child(btn)
			btn.pressed.connect(_on_cell_clicked.bind(row, col))

func color_handler(btn, move):
	
	var normal_style = StyleBoxFlat.new()
	var pressed_style = StyleBoxFlat.new()
	var empty_style = StyleBoxFlat.new()
	pressed_style.bg_color = Color.BLACK  # Replace with the color you want
	normal_style.bg_color = Color.GRAY
	empty_style.bg_color = Color.WHITE
	
	#btn.add_theme_stylebox_override("hover", pressed_style)
	btn.add_theme_stylebox_override("normal", empty_style)
	

func delete_board():
	for child in get_children():
		child.free()

func _choose_board(board, type, size) -> void:
	match type:
		'English': board.make_english_board(size)
		'Square': board.make_square(size)
		'Triangle': board.make_triangle(size)
		_: print("Unknown board type or WIP board type")

func is_valid_cell_for_move(row: int, col: int, n: int) -> bool:
	#if r < 0 or r >= n or c < 0 or c >= n:
		#return false
	#var a = n / 3
	#var b = n - a
	## absent if BOTH row and col are in the corner bands
	#var row_absent = (r < a or r >= b)
	#var col_absent = (c < a or c >= b)
	#return not (row_absent and col_absent)
	
	# detect invalid
	
	var style = get_theme_stylebox("normal") as StyleBoxFlat
	if style:
		var bg = style.bg_color
		# Perform checks on bg, for example:
		if bg == Color.GRAY:
			print("Button is gray")
			
	return true

func _on_cell_clicked(center, row: int, col: int, n) -> void:
	print("Clicked: ", row, ", ", col)
	print("ALL Possible moves for this peg: ")
	
	
	var buttons = [
		"Cell_%d_%d" % [row, col-2], # 
		"Cell_%d_%d" % [row, col+2], # north
		"Cell_%d_%d" % [row-2, col], # west
		"Cell_%d_%d" % [row+2, col], # east
	]
	
	var valid_style = StyleBoxFlat.new()
	var pressed_style = StyleBoxFlat.new()
	var empty_style = StyleBoxFlat.new()
	pressed_style.bg_color = Color.BLACK  # Replace with the color you want
	valid_style.bg_color = Color.GREEN
	empty_style.bg_color = Color.WHITE
	
	for b in buttons:
		var target = get_node_or_null(b)
		if target == null:
			continue
			
		var style = target.get_theme_stylebox("normal") as StyleBoxFlat
		if style.bg_color.is_equal_approx(Color.DIM_GRAY):
			print(style.bg_color.is_equal_approx(Color.DIM_GRAY))
			pass
			
		else:
			print(style.bg_color.is_equal_approx(Color.DIM_GRAY)) 
			target.add_theme_stylebox_override("pressed", valid_style)
			print(target)


func _ready():
	pass
