extends CanvasLayer

@onready var panel = $Panel
@onready var paused_label = $Panel/VBoxContainer/PausedLabel
@onready var continue_button = $Panel/VBoxContainer/ContinueButton
@onready var menu_button = $Panel/VBoxContainer/MenuButton

func _ready():
	# Connect button signals
	continue_button.pressed.connect(_on_continue_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	
	# Hide pause menu initially
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS  # Allow processing when paused

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_pause()

func toggle_pause():
	if get_tree().paused:
		unpause()
	else:
		pause()

func pause():
	get_tree().paused = true
	show()

func unpause():
	get_tree().paused = false
	hide()

func _on_continue_button_pressed():
	unpause()

func _on_menu_button_pressed():
	# Unpause before changing scene
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
