extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var group:= ButtonGroup.new()
	for i in $Radio_Buttons.get_children():
		if i is BaseButton:
			i.button_group = group
			i.toggle_mode = true
			i.toggled.connect(_on_radio_toggled.bind(i.name))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button1_pressed() -> void:
	print("Button1 pressed")
	pass # Replace with function body.


func _on_button2_pressed() -> void:
	print("Button2 pressed")
	pass # Replace with function body.


func _on_button3_pressed() -> void:
	print("Button3 pressed")
	pass # Replace with function body.


func _on_radio_toggled(toggled_on: bool, _extra_arg_0: String, _extra_arg_1: String) -> void:
	if toggled_on:
		print(_extra_arg_1 + ": true")
	else:
		print(_extra_arg_1 + ": false")


func _on_check_button_toggled(toggled_on: bool, extra_arg_0: String) -> void:
	if toggled_on:
		print(extra_arg_0 + ": true")
	else:
		print(extra_arg_0 + ": false")
	pass # Replace with function body.
