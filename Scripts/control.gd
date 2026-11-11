extends Control
@onready var board = $Board
@onready var board_type_menu = $Board_Type_Selection
@onready var board_size_menu = $Board_Size_Selection

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var board_type
var board_size: int
var default_board_type = "English"
var default_board_size = 5

func _on_board_type_selection_item_selected(index: int) -> void:
	board.delete_board()
	board_type = $Board_Type_Selection.get_item_text(index)   # no var
	#print("TYPE handler: board_type='%s' board_size=%s" % [board_type, board_size])
	board._choose_board(board, $Board_Type_Selection.get_item_text(index), board_size)

func _on_board_size_selection_item_selected(index: int) -> void:
	board.delete_board()
	board_size = $Board_Size_Selection.get_item_id(index)
	#print("SIZE handler: board_type='%s' board_size=%s" % [board_type, board_size])
	board._choose_board(board, board_type, $Board_Size_Selection.get_item_id(index))

func _on_new_game_pressed() -> void:
	board.delete_board()
	board._choose_board(board, board_type, board_size)
	
func _on_randomize_pressed() -> void:
	board.randomize_board()

func _on_autoplay_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		board.start_autoplay()
	else:
		board.autoplay_timer.stop()

func _on_replay_pressed() -> void:
	$Panel.hide()
	_on_new_game_pressed()
	
	# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
