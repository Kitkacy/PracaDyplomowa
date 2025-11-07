extends Control

@onready var count_label = $HBoxContainer/CountLabel
@onready var square_icon = $HBoxContainer/SquareIcon

func _ready():
	# Connect to GameStats signal
	var game_stats = get_node("/root/GameStats")
	if game_stats:
		game_stats.blue_squares_changed.connect(_on_blue_squares_changed)
		# Initialize with current count
		_on_blue_squares_changed(game_stats.get_blue_squares_count())

func _on_blue_squares_changed(count: int):
	if count_label:
		count_label.text = str(count)
