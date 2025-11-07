extends Node2D

@onready var background = $Background
@onready var boundary_placer = $BoundaryPlacer

func _ready():
	# Set up automatic boundaries based on background size
	setup_automatic_boundaries()

func setup_automatic_boundaries():
	if not background or not boundary_placer:
		print("Error: Background or BoundaryPlacer not found!")
		return
	
	# Clear any existing boundary rocks first
	clear_existing_boundaries()
	
	# Get background properties
	var bg_position = background.position
	var bg_scale = background.scale
	var bg_region = background.region_rect
	
	# Calculate actual background size in world coordinates
	var world_width = bg_region.size.x * bg_scale.x
	var world_height = bg_region.size.y * bg_scale.y
	
	# Calculate the boundaries (edges of the background)
	# Account for the background's position and region offset
	var region_offset = Vector2(bg_region.position.x * bg_scale.x, bg_region.position.y * bg_scale.y)
	var top_left = bg_position + region_offset
	var bottom_right = top_left + Vector2(world_width, world_height)
	
	# Add some padding inside the background edges so boundaries are visible
	var padding = 50.0  # Pixels inside the background edge
	top_left += Vector2(padding, padding)
	bottom_right -= Vector2(padding, padding)
	
	print("=== Automatic Boundary Setup ===")
	print("Background world size: ", world_width, " x ", world_height)
	print("Boundary area - Top-left: ", top_left)
	print("Boundary area - Bottom-right: ", bottom_right)
	print("Boundary area size: ", bottom_right - top_left)
	
	# Create boundaries at the calculated edges
	create_background_boundaries(top_left, bottom_right)

func create_background_boundaries(top_left: Vector2, bottom_right: Vector2):
	var rock_spacing = 32.0  # Distance between rocks
	
	print("Creating square boundary walls...")
	var rocks_placed = 0
	
	# Create the four boundary walls to form a complete square
	# Top wall
	var top_rocks = create_rock_line(
		Vector2(top_left.x, top_left.y), 
		Vector2(bottom_right.x, top_left.y), 
		rock_spacing
	)
	rocks_placed += top_rocks
	
	# Bottom wall
	var bottom_rocks = create_rock_line(
		Vector2(top_left.x, bottom_right.y), 
		Vector2(bottom_right.x, bottom_right.y), 
		rock_spacing
	)
	rocks_placed += bottom_rocks
	
	# Left wall (excluding corners to avoid overlap)
	var left_rocks = create_rock_line(
		Vector2(top_left.x, top_left.y + rock_spacing), 
		Vector2(top_left.x, bottom_right.y - rock_spacing), 
		rock_spacing
	)
	rocks_placed += left_rocks
	
	# Right wall (excluding corners to avoid overlap)
	var right_rocks = create_rock_line(
		Vector2(bottom_right.x, top_left.y + rock_spacing), 
		Vector2(bottom_right.x, bottom_right.y - rock_spacing), 
		rock_spacing
	)
	rocks_placed += right_rocks
	
	print("Square boundary created! Total rocks placed: ", rocks_placed)
	print("Boundary blocks player (layer 2) but allows enemies to pass through")

func create_rock_line(start_pos: Vector2, end_pos: Vector2, spacing: float) -> int:
	var distance = start_pos.distance_to(end_pos)
	var direction = (end_pos - start_pos).normalized()
	var num_rocks = max(1, int(distance / spacing) + 1)
	
	for i in range(num_rocks):
		var pos = start_pos + direction * (i * spacing)
		boundary_placer.place_rock_at_position(pos)
	
	return num_rocks

# Debug function to visualize boundary area
func _draw():
	if not background:
		return
		
	# Only draw in debug mode (you can remove this or add a debug flag)
	if not OS.is_debug_build():
		return
	
	# Draw debug rectangle showing background bounds
	var bg_position = background.position
	var bg_scale = background.scale
	var bg_region = background.region_rect
	
	var world_width = bg_region.size.x * bg_scale.x
	var world_height = bg_region.size.y * bg_scale.y
	var region_offset = Vector2(bg_region.position.x * bg_scale.x, bg_region.position.y * bg_scale.y)
	var top_left = bg_position + region_offset
	
	# Draw debug rectangle (remove if you don't want visual debug)
	# draw_rect(Rect2(top_left, Vector2(world_width, world_height)), Color.RED, false, 2.0)

func clear_existing_boundaries():
	# Remove any existing boundary rocks
	var existing_boundaries = get_tree().get_nodes_in_group("boundary")
	for boundary in existing_boundaries:
		boundary.queue_free()
	print("Cleared ", existing_boundaries.size(), " existing boundary rocks")