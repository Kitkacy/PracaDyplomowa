extends Control

@onready var victory_label = $CenterContainer/VBoxContainer/VictoryLabel
@onready var time_label = $CenterContainer/VBoxContainer/TimeLabel
@onready var exp_label = $CenterContainer/VBoxContainer/StatsContainer/ExpLabel

func _ready():
	print("Victory screen ready!")
	# Allow processing when the game is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Pause the game when showing victory screen
	get_tree().paused = true
	
	# Ensure the screen is visible and on top
	show()
	z_index = 100  # High z-index to overlay everything
	
	update_victory_stats()
	
	# Add some visual flair
	if victory_label:
		victory_label.add_theme_color_override("font_color", Color.GOLD)
		victory_label.text = "VICTORY!"

func update_victory_stats():
	var game_stats = get_node("/root/GameStats")
	if not game_stats:
		return
		
	# Update completion time
	if time_label:
		var time_text = game_stats.get_survival_time_formatted()
		time_label.text = "You survived for " + time_text
		time_label.add_theme_color_override("font_color", Color.YELLOW)
	
	# Update experience stats - show level and current exp
	if exp_label:
		var level = game_stats.level if "level" in game_stats else 1
		var exp = game_stats.get_current_exp() if game_stats.has_method("get_current_exp") else 0
		exp_label.text = "Final Level: " + str(level) + " | EXP: " + str(exp)
		exp_label.add_theme_color_override("font_color", Color.CYAN)

func _on_play_again_button_pressed():
	print("Play Again button pressed!")
	# Unpause the game before changing scene
	get_tree().paused = false
	# Restart the game
	get_tree().change_scene_to_file("res://World/world.tscn")

func _on_main_menu_button_pressed():
	print("Main Menu button pressed!")
	# Unpause the game before changing scene
	get_tree().paused = false
	# Go back to the main menu
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")

func _on_quit_button_pressed():
	print("Quit button pressed!")
	# Quit the game
	get_tree().quit()
