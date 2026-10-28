extends Control

@export var button_size := Vector2(32, 32)
@export var spacing := Vector2(8, 8)

func _setup():
	pass

func make_english_board(n) -> void:
	# for the first n*1/3 print nothing out
	var absent_n1 = n/3
	var absent_n2 = n - (absent_n1)

	for row in range(n):
		for col in range(n):
			var btn = Button.new()
			if (col < absent_n1 or col >= absent_n2) and (row < absent_n1 or row >= absent_n2):
				btn.hide()
			else:
				btn.toggle_mode = true
				btn.custom_minimum_size = button_size
				var pos_x = col * (button_size.x + spacing.x)
				var pos_y = row * (button_size.y + spacing.y)
				btn.position = Vector2(pos_x, pos_y)
				
				add_child(btn)
				#btn.pressed.connect(_on_cell_clicked.bind(row, col))

func make_square(n) -> void:
	for row in range(n):
		for col in range(n):
			var btn = Button.new()
			btn.toggle_mode = true
			btn.custom_minimum_size = button_size
			var pos_x = col * (button_size.x + spacing.x)
			var pos_y = row * (button_size.y + spacing.y)
			btn.position = Vector2(pos_x, pos_y)
			
			add_child(btn)
			#btn.pressed.connect(_on_cell_clicked.bind(row, col))

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
			var btn = Button.new()
			btn.toggle_mode = true
			btn.text = "(%d,%d)" % [row, col]
			btn.custom_minimum_size = button_size
			btn.size = button_size
			
			# Key: calculate x, y position yourself
			var pos_x = col * (button_size.x + spacing.x)
			var pos_y = row * (button_size.y + spacing.y)
			btn.position = Vector2(pos_x+offset_x, pos_y)
			
			add_child(btn)
			#btn.pressed.connect(_on_cell_clicked.bind(row, col))
