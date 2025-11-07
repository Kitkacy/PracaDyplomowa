extends Control

@onready var start_button = $Panel/VBoxContainer/StartButton
@onready var quit_button = $Panel/VBoxContainer/QuitButton
@onready var title_label = $Panel/VBoxContainer/TitleLabel

func _ready():
	# Connect button signals
	start_button.pressed.connect(_on_start_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	
	# Make sure the menu is visible
	show()

func _on_start_button_pressed():
	# Load the game scene
	get_tree().change_scene_to_file("res://World/world.tscn")

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()
