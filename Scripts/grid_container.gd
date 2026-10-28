extends GridContainer

func make_square_grid(n) -> void:
	for row in range(n):
		for col in range(n):
			var btn = Button.new()
			
			btn.custom_minimum_size = Vector2(32, 32)
			
			btn.pressed.connect(_on_cell_clicked.bind(row, col))
			add_child(btn)

func foo():
	columns = 8
	#make_square_grid(columns)

	for row in range(columns):
		var btn = Button.new()
		
		btn.custom_minimum_size = Vector2(32, 32)
		btn.pressed.connect(_on_cell_clicked.bind(row))
		
		add_child(btn)

func _ready():
	columns = 3

	for i in range(9):
		var btn = Button.new()
		btn.text = str(i)
		
		# Set different minimum sizes for different buttons
		if i == 0:
			btn.custom_minimum_size = Vector2(120, 80)  # Large button
		elif i == 1:
			btn.custom_minimum_size = Vector2(60, 40)   # Small button
		else:
			btn.custom_minimum_size = Vector2(60, 60)
		
		# Let buttons fill their cells (optional)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		add_child(btn)
		btn.pressed.connect(_on_cell_clicked.bind(i))
	

func _on_cell_clicked(row: int, col: int):
	print("Clicked cell: Row ", row, ", Col ", col)
