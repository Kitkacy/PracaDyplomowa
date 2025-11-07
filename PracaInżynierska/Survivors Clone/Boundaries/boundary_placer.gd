extends Node2D

# Tool for placing boundary rocks around the map
# Can be used in editor or spawned via script to create map boundaries

@export var rock_scene: PackedScene = preload("res://Boundaries/boundary_rock.tscn")
@export var auto_place_on_ready: bool = false
@export var boundary_points: Array[Vector2] = []

func _ready():
	if auto_place_on_ready and boundary_points.size() > 0:
		place_boundary_rocks()

# Place rocks at all specified boundary points
func place_boundary_rocks():
	for point in boundary_points:
		place_rock_at_position(point)

# Place a single rock at the specified position
func place_rock_at_position(pos: Vector2):
	if rock_scene:
		var rock = rock_scene.instantiate()
		get_parent().add_child(rock)
		rock.global_position = pos
		return rock
	else:
		print("Error: Rock scene not loaded!")
		return null

# Create a line of rocks between two points
func create_rock_wall(start_pos: Vector2, end_pos: Vector2, spacing: float = 32.0):
	var distance = start_pos.distance_to(end_pos)
	var direction = (end_pos - start_pos).normalized()
	var num_rocks = int(distance / spacing) + 1
	
	for i in range(num_rocks):
		var pos = start_pos + direction * (i * spacing)
		place_rock_at_position(pos)

# Create a rectangular boundary around a specific area
func create_boundary_rectangle(top_left: Vector2, bottom_right: Vector2, spacing: float = 32.0):
	var width = bottom_right.x - top_left.x
	var height = bottom_right.y - top_left.y
	
	# Top wall
	create_rock_wall(top_left, Vector2(bottom_right.x, top_left.y), spacing)
	
	# Bottom wall  
	create_rock_wall(Vector2(top_left.x, bottom_right.y), bottom_right, spacing)
	
	# Left wall
	create_rock_wall(top_left, Vector2(top_left.x, bottom_right.y), spacing)
	
	# Right wall
	create_rock_wall(Vector2(bottom_right.x, top_left.y), bottom_right, spacing)

# Example usage function - call this to set up map boundaries
func setup_map_boundaries():
	# Example: Create a boundary around a 800x600 area centered at origin
	var map_size = Vector2(800, 600)
	var top_left = -map_size / 2
	var bottom_right = map_size / 2
	
	create_boundary_rectangle(top_left, bottom_right, 32.0)
