extends Control
@onready var board_selection = $Board
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
	board_selection.delete_board()
	board_type = $Board_Type_Selection.get_item_text(index)   # no var
	#print("TYPE handler: board_type='%s' board_size=%s" % [board_type, board_size])
	board_selection._choose_board(board_selection, $Board_Type_Selection.get_item_text(index), board_size)

func _on_board_size_selection_item_selected(index: int) -> void:
	board_selection.delete_board()
	board_size = $Board_Size_Selection.get_item_id(index)
	#print("SIZE handler: board_type='%s' board_size=%s" % [board_type, board_size])
	board_selection._choose_board(board_selection, board_type, $Board_Size_Selection.get_item_id(index))

func _on_new_game_pressed() -> void:
	board_selection.delete_board()
	board_selection._choose_board(board_selection, board_type, board_size)
	
func _check_valid_move(move):
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # add_theme_stylebox_override("panel", stylebox)
