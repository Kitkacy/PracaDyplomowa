extends Control

@onready var level_label = $LevelLabel
@onready var background = $Background
@onready var fill = $Fill

var tween: Tween

func _ready():
	# Wait for the next frame to ensure nodes are properly sized
	await get_tree().process_frame
	
	setup_fill_bar()
	
	# Connect to GameStats signals
	var game_stats = get_node("/root/GameStats")
	if game_stats:
		game_stats.exp_changed.connect(update_exp)
		# Initialize with current values
		update_exp(game_stats.get_current_exp(), game_stats.get_max_exp(), game_stats.get_level())

func setup_fill_bar():
	# Reset anchors to use manual positioning
	fill.anchor_left = 0
	fill.anchor_top = 0
	fill.anchor_right = 0
	fill.anchor_bottom = 0
	fill.offset_left = 0
	fill.offset_top = 0
	fill.offset_right = 0
	fill.offset_bottom = 0
	
	# Set initial position relative to background
	fill.position.x = 52  # Left margin relative to ExpBar
	fill.position.y = 2
	fill.size.y = 12  # Height

func update_exp(current_exp: int, max_exp: int, level: int):
	var exp_percentage = float(current_exp) / float(max_exp)
	print("EXP update - EXP: ", current_exp, "/", max_exp, " (", exp_percentage * 100, "%) Level: ", level)
	
	# Update level label
	level_label.text = "Level %d" % level
	
	# Calculate fill width
	var bg_size = background.size
	var available_width = bg_size.x - 4  # 2px margin on each side
	var fill_width = available_width * exp_percentage
	
	# Position and size the fill bar manually (assuming anchors reset)
	fill.size.x = max(fill_width, 0)
	
	# Animate color if needed, but keep yellow for now
	# Could add different colors for different levels, but for simplicity, keep yellow