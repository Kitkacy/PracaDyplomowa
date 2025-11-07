extends Area2D

@export var heal_amount: int = 10
@export var attraction_range: float = 60.0
@export var attraction_speed: float = 80.0

var player: Node2D
var is_being_attracted: bool = false

# Levitation variables
var levitation_amplitude: float = 3.0  # How high/low it moves (much calmer than blue squares)
var levitation_speed: float = 1.5      # How fast it levitates (slower than blue squares)
var base_position: Vector2
var time_passed: float = 0.0

func _ready():
	# Start the despawn timer
	$DespawnTimer.start()
	
	# Find the player
	player = get_tree().get_first_node_in_group("player")
	
	# Set up collision for loot layer (128) and player detection (2)
	collision_layer = 128
	collision_mask = 2
	
	# Add glow effect
	modulate = Color(1.0, 0.8, 0.8, 1.0)  # Slight red tint for health
	
	# Store initial position for levitation
	base_position = global_position
	
	# Random offset for levitation timing so multiple health pickups don't sync
	time_passed = randf() * 2 * PI

func _physics_process(delta):
	# Update time for levitation
	time_passed += delta
	
	if player and is_instance_valid(player):
		var distance_to_player = global_position.distance_to(player.global_position)
		
		# Attract to player if within range
		if distance_to_player <= attraction_range:
			if not is_being_attracted:
				is_being_attracted = true
				# Add visual feedback when attraction starts
				create_tween().tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
			
			# Move towards player
			var direction = (player.global_position - global_position).normalized()
			var move_speed = attraction_speed
			
			# Increase speed as we get closer
			if distance_to_player < 30:
				move_speed = attraction_speed * 2
			
			# Update base position as we move toward player
			base_position += direction * move_speed * delta
			
			# Apply levitation on top of movement toward player
			var levitation_offset = Vector2(0, sin(time_passed * levitation_speed) * levitation_amplitude)
			global_position = base_position + levitation_offset
		else:
			if is_being_attracted:
				is_being_attracted = false
				create_tween().tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
			
			# Calm levitation when not being attracted
			var levitation_offset = Vector2(0, sin(time_passed * levitation_speed) * levitation_amplitude)
			global_position = base_position + levitation_offset

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Heal the player
		if body.has_method("heal"):
			body.heal(heal_amount)
		elif body.has_method("take_damage"):
			# If no heal method, try negative damage
			body.take_damage(-heal_amount)
		
		# Show healing effect
		show_heal_effect()
		
		print("Player healed for ", heal_amount, " health!")
		
		# Remove the pickup
		queue_free()

func show_heal_effect():
	# Create a quick healing visual effect
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color(0, 1, 0, 1), 0.1)
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.15)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)

func _on_despawn_timer_timeout():
	# Fade out and despawn after 30 seconds
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)