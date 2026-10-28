# test_board_game.gd
extends GutTest

# Preload the script/class you want to test
const BoardGame = preload("res://Scripts/game_setup.gd")

var game: BoardGame

# Runs before EACH test to give a fresh instance
func before_each() -> void:
	game = autofree(BoardGame.new())

# --- 1. Choose board size and type ---

func test_can_select_board_size() -> void:
	game.set_board_size(8)
	assert_eq(game.board_size, 8, "Board size should be set to 8")

func test_can_select_board_type() -> void:
	game.set_board_type("hex")
	assert_eq(game.board_type, "hex", "Board type should be 'hex'")

func test_invalid_board_size_is_rejected() -> void:
	# Example: assuming negative or zero sizes are invalid
	var result = game.set_board_size(-1)
	assert_false(result, "Negative board size should be rejected")

# --- 2. Start a new game of the chosen board size and type ---

func test_start_new_game_initializes_correct_state() -> void:
	game.set_board_size(5)
	game.set_board_type("square")
	game.start_new_game()
	
	assert_true(game.is_game_active, "Game should be marked as active")
	assert_eq(game.current_turn, 1, "Game should start on turn 1")
	assert_eq(game.board.size(), 25, "5x5 board should have 25 tiles")

func test_start_new_game_clears_previous_state() -> void:
	# Simulate a dirty state
	game.board = [1, 2, 3]
	game.current_turn = 5
	
	game.start_new_game()
	
	assert_ne(game.current_turn, 5, "Turn should reset on new game")
	# Depending on implementation, board might be regenerated or cleared
	assert_ne(game.board.size(), 3, "Old board data should be discarded")

# --- 3. Making a move ---

func test_making_a_valid_move_updates_board() -> void:
	game.set_board_size(3)
	game.start_new_game()
	
	# Assuming move_piece returns true on success and updates a cell
	var success = game.make_move(Vector2i(1, 1), "player_1")
	
	assert_true(success, "Valid move should return true")
	assert_eq(game.get_piece_at(Vector2i(1, 1)), "player_1", "Board should reflect the moved piece")

func test_making_an_invalid_move_is_rejected() -> void:
	game.set_board_size(3)
	game.start_new_game()
	
	# Example: moving to an occupied space or out of bounds
	game.make_move(Vector2i(1, 1), "player_1")
	var second_move = game.make_move(Vector2i(1, 1), "player_2")
	var third_move = game.make_move(Vector2i(4,4), "player_1")
	
	assert_false(second_move, "Cannot move to an occupied position")
	
func test_making_a_move_advances_turn() -> void:
	game.set_board_size(3)
	game.start_new_game()
	
	game.make_move(Vector2i(0, 0), "player_1")
	
	assert_eq(game.current_turn, 2, "Turn should advance after a move")

# --- 4. Checking the end of game ---

func test_game_is_not_over_at_start() -> void:
	game.start_new_game()
	assert_false(game.is_game_over(), "Game should not be over immediately")

func test_game_over_when_win_condition_met() -> void:
	# Example: assume a 3x3 board where filling a row ends the game
	game.set_board_size(3)
	game.start_new_game()
	
	# Simulate a winning sequence
	game.make_move(Vector2i(0, 0), "player_1")
	game.make_move(Vector2i(0, 1), "player_1")
	game.make_move(Vector2i(0, 2), "player_1")
	
	assert_true(game.is_game_over(), "Game should end when a player wins")

func test_game_over_on_draw() -> void:
	# Example: 1x1 board fills up immediately
	game.set_board_size(1)
	game.start_new_game()
	
	game.make_move(Vector2i(0, 0), "player_1")
	
	assert_true(game.is_game_over(), "Full board with no winner should be a draw")
