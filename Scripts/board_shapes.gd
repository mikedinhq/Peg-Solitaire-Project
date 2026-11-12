class_name BoardShapes

static func _rect_to_pixel(row: int, col: int, btn_size: Vector2, spacing: Vector2) -> Vector2:
	return Vector2(	col * (btn_size.x + spacing.x), row * (btn_size.y + spacing.y))

static func _hex_to_pixel(q: int, r: int, btn_size: Vector2) -> Vector2:
	var size = btn_size.x / sqrt(3.0)
	return Vector2(
		size * sqrt(5.0) * (q + r / 2.0),
		size * 2 * r
	)

static func diamond_board(diameter: int) -> Array[Vector2i]:
	diameter /= 2
	var cells: Array[Vector2i] = []
	var n := 2 * diameter + 1
	var center := diameter
	for r in range(n):
		for c in range(n):
			if abs(r-center) + abs(c-center) <= diameter:
				cells.append(Vector2i(r, c))
	return cells
	
static func english_board(diameter: int) -> Array[Vector2i]:
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
static func hexagon_board(radius: int) -> Array[Vector2i]:
	radius /= 2
	var cells: Array[Vector2i] = []
	for q in range(-radius, radius + 1):
		for r in range(-radius, radius + 1):
			if abs(q) + abs(r) + abs(q + r) <= 2 * radius:
				cells.append(Vector2i(q, r))
	return cells
