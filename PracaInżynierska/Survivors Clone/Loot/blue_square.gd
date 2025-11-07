extends Area2D

@export var pickup_sound_enabled: bool = true
@export var float_speed: float = 30.0
@export var float_amplitude: float = 5.0

var original_position: Vector2
var time: float = 0.0
var position_set: bool = false

# Magnet system variables
var player: Node2D = null
var is_being_attracted: bool = false
var magnet_speed: float = 0.0

func _ready():
	# Create a blue square texture
	var sprite = $Sprite2D
	sprite.texture = create_blue_square_texture()
	
	# Add a slight random offset to the floating animation
	time = randf() * 2.0 * PI
	
	# Start the despawn timer
	$DespawnTimer.start()
	
	# Find the player reference
	player = get_tree().get_first_node_in_group("player")
	
	# Wait one frame to ensure position is set correctly, then store it
	await get_tree().process_frame
	original_position = global_position
	position_set = true

func _process(delta):
	# Only start processing after position is properly set
	if not position_set or not player:
		return
	
	# Check distance to player for magnet attraction
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Get player's magnet properties
	var magnet_range = player.get("magnet_range") if player.has_method("get") else 80.0
	var magnet_strength = player.get("magnet_strength") if player.has_method("get") else 150.0
	
	if distance_to_player <= magnet_range:
		# Player is within magnet range - attract the loot
		is_being_attracted = true
		var direction_to_player = (player.global_position - global_position).normalized()
		
		# Calculate attraction speed (faster when closer)
		var attraction_factor = 1.0 - (distance_to_player / magnet_range)
		magnet_speed = magnet_strength * (1.0 + attraction_factor * 2.0)  # Speed increases as it gets closer
		
		# Move toward player
		global_position += direction_to_player * magnet_speed * delta
		
		# Update original position for floating effect
		original_position = global_position
		
		# Add visual feedback - make it glow when being attracted
		var sprite = $Sprite2D
		sprite.modulate = Color(0.3, 0.8, 1.2, 1)  # Brighter blue when attracted
	else:
		# Not being attracted - normal floating animation
		is_being_attracted = false
		magnet_speed = 0.0
		
		# Reset sprite color
		var sprite = $Sprite2D
		sprite.modulate = Color(0, 0.5, 1, 1)  # Normal blue color
		
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
	if body.is_in_group("player"):
		collect_loot()

func collect_loot():
	# Add visual/audio feedback for collection
	var sprite = $Sprite2D
	sprite.modulate = Color(1, 1, 1, 1)  # Flash white briefly
	
	# Add to game stats
	var game_stats = get_node("/root/GameStats")
	if game_stats and game_stats.has_method("add_blue_square"):
		game_stats.add_blue_square()
	
	# Remove the loot item
	queue_free()

func _on_despawn_timer_timeout():
	print("Blue square despawned after 30 seconds")
	queue_free()

func _on_pickup_area_area_entered(area):
	# Check if the area belongs to a player (like player's hurtbox)
	var area_owner = area.get_parent()
	if area_owner and area_owner.is_in_group("player"):
		collect_loot()