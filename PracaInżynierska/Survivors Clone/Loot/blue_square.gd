extends Area2D

@export var pickup_sound_enabled: bool = true
@export var float_speed: float = 30.0
@export var float_amplitude: float = 5.0

var original_position: Vector2
var time: float = 0.0
var position_set: bool = false

func _ready():
	# Create a blue square texture
	var sprite = $Sprite2D
	sprite.texture = create_blue_square_texture()
	
	# Add a slight random offset to the floating animation
	time = randf() * 2.0 * PI
	
	# Start the despawn timer
	$DespawnTimer.start()
	
	# Wait one frame to ensure position is set correctly, then store it
	await get_tree().process_frame
	original_position = global_position
	position_set = true

func _process(delta):
	# Only start floating animation after position is properly set
	if position_set:
		# Gentle floating animation
		time += delta * float_speed
		global_position.y = original_position.y + sin(time) * float_amplitude

func create_blue_square_texture() -> ImageTexture:
	# Create a simple blue square texture
	var image = Image.create(12, 12, false, Image.FORMAT_RGBA8)
	
	for x in range(12):
		for y in range(12):
			# Create a blue square with slightly darker border
			if x == 0 or x == 11 or y == 0 or y == 11:
				image.set_pixel(x, y, Color(0, 0.3, 0.8, 1))  # Darker blue border
			else:
				image.set_pixel(x, y, Color(0, 0.5, 1, 1))  # Bright blue fill
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func _on_pickup_area_body_entered(body):
	print("Something entered pickup area: ", body.name)
	if body.is_in_group("player"):
		print("Player picked up blue square!")
		
		# Add to game stats
		var game_stats = get_node("/root/GameStats")
		if game_stats:
			if game_stats.has_method("add_blue_square"):
				game_stats.add_blue_square()
				print("Called add_blue_square method")
			else:
				print("add_blue_square method not found")
		else:
			print("GameStats node not found")
		
		# Remove the loot item
		queue_free()
	else:
		print("Not a player: ", body)

func _on_despawn_timer_timeout():
	print("Blue square despawned after 30 seconds")
	queue_free()

func _on_pickup_area_area_entered(area):
	print("Area entered pickup area: ", area.name)
	# Check if the area belongs to a player (like player's hurtbox)
	var area_owner = area.get_parent()
	if area_owner and area_owner.is_in_group("player"):
		print("Player area picked up blue square!")
		
		# Add to game stats
		var game_stats = get_node("/root/GameStats")
		if game_stats:
			if game_stats.has_method("add_blue_square"):
				game_stats.add_blue_square()
				print("Called add_blue_square method via area detection")
		
		# Remove the loot item
		queue_free()