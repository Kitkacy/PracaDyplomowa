extends Node

signal blue_squares_changed(count)
signal exp_changed(current_exp, max_exp, level)
signal level_changed(new_level)

var survival_time: float = 0.0
var is_game_active: bool = false
var blue_squares_collected: int = 0

var current_exp: int = 0
var max_exp: int = 100
var level: int = 1

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

func add_exp(amount: int):
	current_exp += amount
	while current_exp >= max_exp:
		current_exp -= max_exp
		level += 1
		max_exp = ceil(max_exp * 1.1)
	exp_changed.emit(current_exp, max_exp, level)
	if level > 1:  # Only emit level_changed if leveled up
		level_changed.emit(level)
	print("EXP: ", current_exp, "/", max_exp, " Level: ", level)

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
