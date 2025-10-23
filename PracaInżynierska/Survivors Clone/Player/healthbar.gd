extends Control

@onready var background = $Background
@onready var fill = $Fill

var tween: Tween

func _ready():
	# Create a tween for smooth animations
	tween = create_tween()
	tween.set_loops()
	
	# Wait for the next frame to ensure nodes are properly sized
	await get_tree().process_frame
	
	# Initialize the fill bar positioning
	setup_fill_bar()
	
	# Initialize with full health (will be overridden when player emits health_changed)
	initialize_full_health()

func initialize_full_health():
	# Show the healthbar at full health initially
	# This ensures it's visible from game start
	var bg_size = background.size
	var available_width = bg_size.x - 4
	var available_height = bg_size.y - 4
	
	# Set to full health (100%)
	fill.position.x = 2
	fill.position.y = 2
	fill.size.x = available_width  # Full width
	fill.size.y = available_height
	fill.color = Color.GREEN  # Full health color
	fill.visible = true
	
	# Set full opacity
	modulate.a = 0.7  # Semi-transparent when at full health

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

func update_health(current_health: int, max_health: int):
	var health_percentage = float(current_health) / float(max_health)
	print("Healthbar update - HP: ", current_health, "/", max_health, " (", health_percentage * 100, "%)")
	
	# Ensure setup is done first
	setup_fill_bar()
	
	# Use the background size as reference since it defines the frame
	var bg_size = background.size
	var available_width = bg_size.x - 4  # 2px margin on each side
	var available_height = bg_size.y - 4  # 2px margin on top/bottom
	var fill_width = available_width * health_percentage
	
	# Position and size the fill bar manually (relative to healthbar position)
	fill.size.x = max(fill_width, 0)  # Ensure it's never negative
	fill.size.y = available_height
	
	# Make sure the fill is visible
	fill.visible = true
	
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
