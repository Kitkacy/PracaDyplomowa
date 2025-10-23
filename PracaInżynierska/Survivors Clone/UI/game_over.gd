extends Control

@onready var score_label = $CenterContainer/VBoxContainer/ScoreLabel

func _ready():
	print("Game Over screen ready!")
	update_survival_time()

func update_survival_time():
	var game_stats = get_node("/root/GameStats")
	if game_stats and score_label:
		var time_text = game_stats.get_survival_time_formatted()
		score_label.text = "You survived for " + time_text

func _on_restart_button_pressed():
	# Go back to the world scene
	get_tree().change_scene_to_file("res://World/world.tscn")

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()