extends Control

@onready var phase_label = $Panel/VBoxContainer/PhaseLabel
@onready var time_label = $Panel/VBoxContainer/TimeLabel
@onready var progress_bar = $Panel/VBoxContainer/ProgressBar

func _ready():
	# Connect to GameStats signals
	var game_stats = get_node("/root/GameStats")
	if game_stats:
		game_stats.phase_changed.connect(_on_phase_changed)
		game_stats.game_victory.connect(_on_game_victory)
	
	# Initialize display
	update_display(1, 600.0)

func _on_phase_changed(phase: int, time_remaining: float):
	update_display(phase, time_remaining)

func update_display(phase: int, time_remaining: float):
	if phase_label:
		phase_label.text = "Phase %d" % phase
	
	if time_label:
		var total_seconds = int(time_remaining)
		var minutes = total_seconds / 60
		var seconds = total_seconds % 60
		time_label.text = "%02d:%02d" % [minutes, seconds]
	
	if progress_bar:
		progress_bar.value = 600.0 - time_remaining

func _on_game_victory():
	if phase_label:
		phase_label.text = "VICTORY!"
	if time_label:
		time_label.text = "00:00"
	if progress_bar:
		progress_bar.value = progress_bar.max_value
