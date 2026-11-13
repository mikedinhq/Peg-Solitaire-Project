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

# tests board size
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

# tests if valid moves changes state
func test_invalid_execute_move_is_noop():
	var cells: Array[Vector2i] = [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2)]
	model.setup(cells, false)
	var before: int = model.count_pegs()
	model.execute_move(Vector2i(0,0), Vector2i(0,2))  # midpoint filled? yes
	model.setup(cells, false)
	model.set_empty(Vector2i(0,1))   # kill the midpoint
	before = model.count_pegs()
	model.execute_move(Vector2i(0,0), Vector2i(0,2))
	assert_eq(model.count_pegs(), before, "invalid move must not change state")

# tests finding more moves and if they're legal
func test_find_any_move_returns_valid_pair():
	model.setup(model.english_board(5), false)
	var move = model.find_any_move()
	assert_eq(move.size(), 2, "find_any_move returns [from, to]")
	assert_true(model.can_move(move[0], move[1]), "returned pair must be legal")

# tests when there are no more moves
func test_find_any_move_empty_when_stuck():
	model.setup([Vector2i(0,0), Vector2i(0,1)], false)
	assert_true(model.find_any_move().is_empty(),
		"stuck board: no move found")

# tests direction of movements
func test_rect_jump_destinations():
	assert_has(model.jump_destinations(Vector2i(2, 2)), Vector2i(4, 2))
	assert_has(model.jump_destinations(Vector2i(2, 2)), Vector2i(0, 2))
	assert_has(model.jump_destinations(Vector2i(2, 2)), Vector2i(2, 4))
	assert_has(model.jump_destinations(Vector2i(2, 2)), Vector2i(2, 0))
	assert_eq(model.jump_destinations(Vector2i(2, 2)).size(), 4, "rect: 4 directions")

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

# tests if making a move will remove only 1 peg
func test_execute_move_removes_exactly_one_peg():
	var cells: Array[Vector2i] = [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2)]
	model.setup(cells, false)
	model.set_empty(Vector2i(0,2))
	var before: int = model.count_pegs()
	model.execute_move(Vector2i(0,0), Vector2i(0,2))
	assert_eq(model.count_pegs(), before - 1)

# tests if the remaining pegs are counted when a game_over() happens
func test_stuck_board_is_game_over():
	# Two adjacent pegs, no third cell to jump over → no moves
	var cells: Array[Vector2i] = [Vector2i(0,0), Vector2i(0,1)]
	model.setup(cells, false)
	assert_true(model.is_game_over(), "two pegs with no jump = game over")
	assert_eq(model.count_pegs(), 2, "sanity: still 2 pegs")

# tests when no more pegs remain on the board
func test_winning_state_is_game_over():
	var cells: Array[Vector2i] = [Vector2i(0,0)]
	model.setup(cells, false)
	assert_true(model.is_game_over(), "one peg = victory, game over")
	assert_eq(model.count_pegs(), 1)

# tests autoplay
func test_autoplay_terminates():
	model.setup(model.english_board(5), false)
	var guard := 0
	while not model.find_any_move().is_empty():
		var move = model.find_any_move()
		model.execute_move(move[0], move[1])
		guard += 1
		assert_lt(guard, 100, "autoplay must terminate")
		if guard >= 100: break
	assert_true(model.is_game_over(), "autoplay ends in a final state")
	assert_gte(model.count_pegs(), 1, "autoplay never reaches 0 pegs")
