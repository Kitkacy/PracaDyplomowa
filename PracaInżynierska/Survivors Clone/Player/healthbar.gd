extends Control

@onready var background = $Background
@onready var fill = $Fill

var tween: Tween
var initial_fill_width: float = 0.0

func _ready():
	# Create a tween for smooth animations
	tween = create_tween()
	tween.set_loops()
	
	# Wait for the next frame to ensure nodes are properly sized
	await get_tree().process_frame
	
	# Store the initial fill width
	initial_fill_width = fill.size.x
	
	# Initialize with full health (will be overridden when player emits health_changed)
	initialize_full_health()

func initialize_full_health():
	# Show the healthbar at full health initially
	fill.anchor_right = 1.0
	fill.offset_right = -2.0
	fill.color = Color.GREEN  # Full health color
	fill.visible = true
	
	# Set semi-transparent
	modulate.a = 0.7  # Semi-transparent when at full health

func update_health(current_health: int, max_health: int):
	var health_percentage = float(current_health) / float(max_health)
	print("Healthbar update - HP: ", current_health, "/", max_health, " (", health_percentage * 100, "%)")
	
	# Calculate the fill width based on percentage
	# The fill should go from offset_left (2) to a percentage of the total width
	# Total available width is background width - 4 (2px margin on each side)
	var total_width = background.size.x - 4.0
	var target_fill_width = total_width * health_percentage
	
	# Use anchor_right = 0 and set offset_right to control width
	fill.anchor_right = 0.0
	fill.offset_right = 2.0 + target_fill_width
	
	# Make sure the fill is visible
	fill.visible = current_health > 0
	
	# Animate color change
	var target_color: Color
	if health_percentage > 0.6:
		target_color = Color.GREEN
	elif health_percentage > 0.3:
		target_color = Color.YELLOW
	else:
		target_color = Color.RED
	
	# Animate color change smoothly
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(fill, "color", target_color, 0.2)
	
	# Adjust opacity based on health
	if health_percentage >= 1.0:
		modulate.a = 0.7  # Semi-transparent when full
	else:
		modulate.a = 1.0  # Full opacity when damaged
