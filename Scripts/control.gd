extends Control
@onready var board = $Board
@onready var board_type_menu = $Board_Type_Selection
@onready var board_size_menu = $Board_Size_Selection

var board_type
var board_size: int
var default_board_type = "English"
var default_board_size = 5

func _on_board_type_selection_item_selected(index: int) -> void:
	board_type = board_type_menu.get_item_text(index)   # no var
	board.new_game(board_type, board_size)

func _on_board_size_selection_item_selected(index: int) -> void:
	board_size = int(board_size_menu.get_item_text(index))
	board.new_game(board_type, board_size)

func _on_new_game_pressed() -> void:
	board.new_game(board_type, board_size)
	
func _on_randomize_pressed() -> void:
	print("randomized button pressed")
	board.randomize_board(30)

func _on_autoplay_toggled(toggled_on: bool) -> void:
	if toggled_on:
		print("autoplay button toggled: ", toggled_on)
		board.start_autoplay()
	else:
		print("autoplay button toggled: ", toggled_on)
		board.stop_autoplay()

func _on_replay_pressed() -> void:
	print("play again button pressed")
	board.replay_function(board_type, board_size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Our main function
func _ready() -> void:
	pass
	
