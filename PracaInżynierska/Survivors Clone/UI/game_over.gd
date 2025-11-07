extends Control

@onready var score_label = $CenterContainer/VBoxContainer/ScoreLabel
@onready var title_label = $CenterContainer/VBoxContainer/GameOverLabel

var is_victory: bool = false

func _ready():
	print("Game Over screen ready!")
	update_survival_time()

func update_survival_time():
	var game_stats = get_node("/root/GameStats")
	if game_stats and score_label:
		var time_text = game_stats.get_survival_time_formatted()
		if is_victory:
			score_label.text = "You completed all phases in " + time_text
		else:
			score_label.text = "You survived for " + time_text

func _on_restart_button_pressed():
	# Go back to the world scene
	get_tree().change_scene_to_file("res://World/world.tscn")

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()

func show_game_over():
	is_victory = false
	if title_label:
		title_label.text = "Game Over"
	update_survival_time()
	show()

func show_victory():
	is_victory = true
	if title_label:
		title_label.text = "Victory!"
	update_survival_time()
	show()
