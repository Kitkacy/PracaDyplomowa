extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var title_label = $VBoxContainer/TitleLabel

func _ready():
	# Connect button signals with safety checks
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)
	else:
		print("ERROR: Start button not found!")
		
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)
	else:
		print("ERROR: Quit button not found!")
	
	# Make sure the menu is visible
	show()

func _on_start_button_pressed():
	# Load the game scene
	get_tree().change_scene_to_file("res://World/world.tscn")

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()
