extends GutTest

var model

# initialize class for methods
func before_each():
	model = BoardModel.new()

# tests the setup of the cells
func test_setup_initializes_board_correctly():
	var cells: Array[Vector2i] = [
		Vector2i(0,0),
		Vector2i(0,1),
		Vector2i(1,0),
		Vector2i(1,1),
		]
	model.setup(cells, false)
	
	assert_eq(model.get_board_cells().size(), 4, "Should store 2 cells")
	assert_true(model.is_filled(Vector2i(0,0)), "Cells should be filled by default")
	assert_false(model.get_hex(), "Should not be in hex mode")

func test_board_size():
	var cells = model.english_board(5)
	assert_eq(cells.size(), 21)

# tests valid moves
func test_can_move_valid_jump_square():
	# Setup 3 cells in a line: [Peg] -> [Peg] -> [Empty]
	var cells: Array[Vector2i] = [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2)]
	model.setup(cells, false)
	model.set_empty(Vector2i(0,2)) # Make the destination empty
	
	# Jump from (0,0) over (0,1) to (0,2)
	assert_true(model.can_move(Vector2i(0,0), Vector2i(0,2)), "Should be a valid jump")

# tests invalid move (adjacent cell is empty)
func test_cannot_move_if_midpoint_is_empty():
	var cells: Array[Vector2i] = [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2)]
	model.setup(cells, false)
	model.set_empty(Vector2i(0,1)) # Empty the middle
	model.set_empty(Vector2i(0,2)) # Empty the destination
	
	assert_false(model.can_move(Vector2i(0,0), Vector2i(0,2)), "Cannot jump over an empty space")

# test invalid move (out of bound move)
func test_cannot_move_out_of_bounds():
	var cells: Array[Vector2i] = [Vector2i(0,0), Vector2i(0,1)]
	model.setup(cells, false)
	model.set_empty(Vector2i(0,1))
	
	# Trying to jump to (0,2) which doesn't exist
	assert_false(model.can_move(Vector2i(0,0), Vector2i(0,2)), "Cannot jump off the board")

# tests making the moves and updating the board based on that
func test_execute_move_updates_state():
	var cells: Array[Vector2i] = [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2)]
	model.setup(cells, false)
	model.set_empty(Vector2i(0,2))
	
	model.execute_move(Vector2i(0,0), Vector2i(0,2))
	
	assert_true(model.is_empty(Vector2i(0,0)), "From cell should be empty")
	assert_true(model.is_empty(Vector2i(0,1)), "Mid cell should be empty")
	assert_true(model.is_filled(Vector2i(0,2)), "To cell should be filled")

# tests the hexagon board and valid directions
func test_hex_directions():
	var cells: Array[Vector2i] = [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0)]
	model.setup(cells, true) # True = Hex mode
	model.set_empty(Vector2i(2,0))
	
	# In hex axial, (1,0) is a valid direction, so a jump from (0,0) to (2,0) should work
	assert_true(model.can_move(Vector2i(0,0), Vector2i(2,0)), "Should be valid hex jump")

# tests game over detection
func test_game_over_detection():
	# 1 peg, no moves possible = Game Over
	var cells: Array[Vector2i] = [Vector2i(0,0)]
	model.setup(cells, false)
	assert_true(model.is_game_over(), "Game should be over with 1 isolated peg")
	
	# Valid move exists = Not Game Over
	var cells2: Array[Vector2i] = [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2)]
	model.setup(cells2, false)
	model.set_empty(Vector2i(0,2))
	assert_false(model.is_game_over(), "Game should not be over if a move exists")
