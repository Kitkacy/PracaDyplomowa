extends Node

signal blue_squares_changed(count)
signal exp_changed(current_exp, max_exp, level)
signal level_changed(new_level)
signal phase_changed(phase, time_remaining)
signal game_victory

var survival_time: float = 0.0
var is_game_active: bool = false
var blue_squares_collected: int = 0

var current_exp: int = 0
var max_exp: int = 100
var level: int = 1

# Phase system variables
var current_phase: int = 1
var phase_time: float = 600.0  # 10 minutes in seconds
var current_phase_time: float = 0.0
var max_phases: int = 3

func _ready():
	# Start the survival timer when the game starts
	start_survival_timer()

func start_survival_timer():
	survival_time = 0.0
	is_game_active = true

func stop_survival_timer():
	is_game_active = false

func _process(delta):
	if is_game_active:
		survival_time += delta
		current_phase_time += delta
		
		# Check if phase should advance
		if current_phase_time >= phase_time:
			advance_phase()
		
		# Emit phase timer update
		var time_remaining = phase_time - current_phase_time
		phase_changed.emit(current_phase, time_remaining)

func get_survival_time_formatted() -> String:
	var total_seconds = int(survival_time)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	if minutes > 0:
		return "%d minutes %d seconds" % [minutes, seconds]
	else:
		return "%d seconds" % seconds

func reset_survival_time():
	survival_time = 0.0
	is_game_active = true
	current_phase = 1
	current_phase_time = 0.0
	reset_blue_squares()  # Reset blue squares when starting new game
	reset_exp()  # Reset EXP when starting new game

func add_blue_square():
	blue_squares_collected += 1
	blue_squares_changed.emit(blue_squares_collected)
	print("Blue squares collected: ", blue_squares_collected)

func reset_blue_squares():
	blue_squares_collected = 0
	blue_squares_changed.emit(blue_squares_collected)
	print("Blue squares reset to 0")

func get_blue_squares_count() -> int:
	return blue_squares_collected

func spend_blue_squares(amount: int) -> bool:
	if blue_squares_collected >= amount:
		blue_squares_collected -= amount
		blue_squares_changed.emit(blue_squares_collected)
		print("Spent ", amount, " blue squares. Remaining: ", blue_squares_collected)
		return true
	else:
		print("Not enough blue squares! Have: ", blue_squares_collected, " Need: ", amount)
		return false

func add_exp(amount: int):
	current_exp += amount
	var leveled_up = false
	while current_exp >= max_exp:
		current_exp -= max_exp
		level += 1
		max_exp = ceil(max_exp * 1.1)
		leveled_up = true
	exp_changed.emit(current_exp, max_exp, level)
	if leveled_up:
		level_changed.emit(level)
		show_upgrade_menu()
	print("EXP: ", current_exp, "/", max_exp, " Level: ", level)

func show_upgrade_menu():
	# Find and show the upgrade menu
	var upgrade_menu_canvas = get_tree().get_first_node_in_group("upgrade_menu")
	if not upgrade_menu_canvas:
		# If no upgrade menu in scene, try to instantiate one
		var upgrade_menu_scene = load("res://UI/upgrade_menu.tscn")
		if upgrade_menu_scene:
			upgrade_menu_canvas = upgrade_menu_scene.instantiate()
			get_tree().current_scene.add_child(upgrade_menu_canvas)
	
	# Get the actual UpgradeMenu control inside the CanvasLayer
	var upgrade_menu = upgrade_menu_canvas.get_node_or_null("UpgradeMenu")
	if upgrade_menu and upgrade_menu.has_method("show_upgrade_menu"):
		upgrade_menu.show_upgrade_menu()

func reset_exp():
	current_exp = 0
	max_exp = 100
	level = 1
	exp_changed.emit(current_exp, max_exp, level)
	print("EXP reset to 0, level 1")

func get_current_exp() -> int:
	return current_exp

func get_max_exp() -> int:
	return max_exp

func get_level() -> int:
	return level

func advance_phase():
	current_phase += 1
	current_phase_time = 0.0
	
	if current_phase > max_phases:
		# Victory condition reached
		is_game_active = false
		game_victory.emit()
		show_victory_screen()
	else:
		print("Phase ", current_phase, " started!")
		# Reset phase timer
		var time_remaining = phase_time - current_phase_time
		phase_changed.emit(current_phase, time_remaining)

func get_current_phase() -> int:
	return current_phase

func get_phase_time_remaining() -> float:
	return phase_time - current_phase_time

func get_phase_time_formatted() -> String:
	var time_remaining = get_phase_time_remaining()
	var total_seconds = int(time_remaining)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]

func skip_time_by_minutes(minutes: int):
	# Skip time in survival timer and phase timer
	var seconds_to_skip = minutes * 60.0
	survival_time += seconds_to_skip
	current_phase_time += seconds_to_skip
	
	print("GameStats: Skipped ", minutes, " minutes. Survival time: ", get_survival_time_formatted())
	
	# Check if phase should advance due to time skip
	while current_phase_time >= phase_time:
		advance_phase()

func show_victory_screen():
	# Find and show the game over screen, but change it to victory
	var game_over = get_tree().get_first_node_in_group("game_over")
	if not game_over:
		# If no game over in scene, try to instantiate one
		var game_over_scene = load("res://UI/game_over.tscn")
		if game_over_scene:
			game_over = game_over_scene.instantiate()
			
			# Find the player's camera and add the screen to it
			var player = get_tree().get_first_node_in_group("player")
			if player:
				var camera = player.get_node_or_null("Camera2D")
				if camera:
					camera.add_child(game_over)
					game_over.add_to_group("game_over")
				else:
					get_tree().current_scene.add_child(game_over)
					game_over.add_to_group("game_over")
			else:
				get_tree().current_scene.add_child(game_over)
				game_over.add_to_group("game_over")
	
	if game_over and game_over.has_method("show_victory"):
		game_over.show_victory()
	elif game_over and game_over.has_method("show_game_over"):
		game_over.show_game_over()
