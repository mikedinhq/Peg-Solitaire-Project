extends GutTest

# Adjust this path to wherever your grid script lives
const GridScript = preload("res://Scripts/grid.gd")

var grid

func before_each():
	grid = GridScript.new()
	add_child_autofree(grid)  # ensures cleanup after each test

func test_creates_correct_number_of_buttons_for_n3():
	grid.make_square(3)
	# Count only Button nodes among children
	var button_count = 0
	for child in grid.get_children():
		if child is Button:
			button_count += 1
	assert_eq(button_count, 9, "3x3 grid should create 9 buttons")

func test_button_names_follow_expected_format():
	grid.make_square(3)
	# Check a few specific names that should exist
	assert_not_null(grid.get_node_or_null("Cell_0_0"), "Cell_0_0 should exist")
	assert_not_null(grid.get_node_or_null("Cell_2_2"), "Cell_2_2 should exist")

func test_buttons_are_in_toggle_mode():
	grid.make_square(2)
	var btn = grid.get_node_or_null("Cell_0_0")
	assert_not_null(btn)
	assert_true(btn.toggle_mode, "Grid buttons should have toggle_mode enabled")
