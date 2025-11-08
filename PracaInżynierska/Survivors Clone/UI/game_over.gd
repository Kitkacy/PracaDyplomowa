extends Control

# This script handles GAME OVER only. Victory is handled by victory_screen.tscn
@onready var score_label = $CenterContainer/VBoxContainer/ScoreLabel
@onready var title_label = $CenterContainer/VBoxContainer/GameOverLabel

func _ready():
	print("Game Over screen ready!")
	# Allow processing when the game is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Pause the game when showing game over screen
	get_tree().paused = true
	
	# Ensure the screen is visible and on top
	show()
	z_index = 100  # High z-index to overlay everything
	
	update_survival_time()

func update_survival_time():
	var game_stats = get_node("/root/GameStats")
	if game_stats and score_label:
		var time_text = game_stats.get_survival_time_formatted()
		score_label.text = "You survived for " + time_text
		# Set title color for game over
		if title_label:
			title_label.add_theme_color_override("font_color", Color.RED)

func _on_restart_button_pressed():
	# Unpause the game before changing scene
	get_tree().paused = false
	# Go back to the world scene
	get_tree().change_scene_to_file("res://World/world.tscn")

func _on_main_menu_button_pressed():
	# Unpause the game before changing scene
	get_tree().paused = false
	# Go back to the main menu
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()

# This function is no longer needed as it's called automatically in _ready()
# Kept for compatibility if called from other scripts
func show_game_over():
	if title_label:
		title_label.text = "Game Over"
	update_survival_time()
