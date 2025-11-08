extends Area2D

# Base stats (never change these)
var base_max_hp: int = 50
var base_damage: int = 10
var base_orbit_speed: float = 2.0

# Current stats (modified by upgrades)
@export var max_hp: int = 50
@export var current_hp: int = 50
@export var damage: int = 10
@export var orbit_radius: float = 60.0
@export var orbit_speed: float = 2.0

var player: Node2D = null
var orbit_angle: float = 0.0
var drone_index: int = 0  # Which position in the circle (0-4)
var total_drones: int = 1  # Total number of drones

# Visual feedback
var sprite: ColorRect
var collision_shape: CollisionShape2D
var original_modulate: Color
var flash_tween: Tween

# Damage number
var damage_number_scene = preload("res://UI/damage_number.tscn")

func _ready():
	# Apply global upgrade multipliers from GameStats
	apply_upgrade_multipliers()
	
	# Set up collision layers
	collision_layer = 16  # Projectile layer
	collision_mask = 8  # Enemy hurtbox layer
	
	# Get the ColorRect as sprite
	sprite = $ColorRect if has_node("ColorRect") else null
	if sprite:
		original_modulate = sprite.modulate
	
	# Connect signals
	area_entered.connect(_on_area_entered)
	
	# Find player
	player = get_tree().get_first_node_in_group("player")
	
	print("Drone _ready() called - player found: ", player != null)
	
	# Set initial position
	if player:
		update_orbit_position()
	else:
		print("ERROR: Player not found in drone _ready()")

func apply_upgrade_multipliers():
	# Apply GameStats multipliers to drone stats
	var game_stats = get_node("/root/GameStats")
	if game_stats:
		# Apply damage multiplier
		damage = int(base_damage * game_stats.drone_damage_multiplier)
		
		# Apply speed multiplier
		orbit_speed = base_orbit_speed * game_stats.drone_speed_multiplier
		
		# Apply health multiplier
		max_hp = int(base_max_hp * game_stats.drone_health_multiplier)
		current_hp = max_hp
		
		print("Drone created with multipliers - Damage: ", damage, " Speed: ", orbit_speed, " HP: ", max_hp)

func _process(delta):
	if not player or not is_instance_valid(player):
		queue_free()
		return
	
	# Update position (rotation is handled in update_orbit_position using shared timing)
	update_orbit_position()

func update_orbit_position():
	if not player:
		return
	
	# Use Engine time for shared rotation so all drones rotate together
	var shared_rotation = Engine.get_process_frames() * orbit_speed * 0.01
	
	# Calculate evenly spaced angle based on drone index and total drones
	var base_angle = (TAU / float(total_drones)) * float(drone_index)
	var final_angle = base_angle + shared_rotation
	
	# Calculate position in orbit
	var offset = Vector2(cos(final_angle), sin(final_angle)) * orbit_radius
	global_position = player.global_position + offset
	
	# Debug output for positioning issues
	if randf() < 0.01:  # Print occasionally, not every frame
		print("Drone ", drone_index, "/", total_drones, " - base_angle: ", rad_to_deg(base_angle), "° spacing: ", rad_to_deg(TAU / float(total_drones)), "° position: ", global_position)

func set_orbit_parameters(index: int, total: int):
	drone_index = index
	total_drones = total
	print("Drone orbit parameters set - Index: ", index, " Total: ", total, " Angle spacing: ", rad_to_deg(TAU / float(total)), "°")

func _on_area_entered(area: Area2D):
	# Check if it's an enemy hurtbox
	if area.collision_layer & 8:  # Enemy hurtbox layer
		# Deal damage to enemy
		if area.has_signal("hurt"):
			area.hurt.emit(damage, global_position)
			print("Drone hit enemy for ", damage, " damage")
		
		# Flash effect
		flash_sprite()
		
		# Take damage (drones have durability)
		take_damage(1)

func take_damage(damage_amount: int):
	current_hp -= damage_amount
	
	# Flash red when taking damage
	flash_red()
	
	if current_hp <= 0:
		print("Drone destroyed!")
		destroy_drone()
	else:
		print("Drone HP: ", current_hp, "/", max_hp)

func destroy_drone():
	# Start destruction sequence with flickering
	start_destruction_flicker()

func start_destruction_flicker():
	if not sprite:
		complete_destruction()
		return
	
	# Stop any existing tweens
	if flash_tween:
		flash_tween.kill()
	
	# Create flickering effect before destruction
	flash_tween = create_tween()
	flash_tween.set_loops(6)  # Flicker 6 times
	
	# Flicker between invisible and red
	flash_tween.tween_property(sprite, "modulate:a", 0.0, 0.1)
	flash_tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	flash_tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	flash_tween.tween_property(sprite, "modulate", original_modulate, 0.1)
	
	# After flickering, complete destruction
	flash_tween.tween_callback(complete_destruction)

func complete_destruction():
	# Notify player to remove from drone list
	if player and player.has_method("remove_drone"):
		player.remove_drone(self)
	
	queue_free()

func flash_sprite():
	if not sprite:
		return
	
	# Stop any existing flash tween
	if flash_tween:
		flash_tween.kill()
	
	# Create new tween for flash effect
	flash_tween = create_tween()
	
	# Flash white then back to normal
	sprite.modulate = Color.WHITE
	flash_tween.tween_property(sprite, "modulate", original_modulate, 0.1)

func flash_red():
	if not sprite:
		return
	
	# Stop any existing flash tween
	if flash_tween:
		flash_tween.kill()
	
	# Create new tween for red flash effect
	flash_tween = create_tween()
	
	# Flash red then back to normal
	sprite.modulate = Color.RED
	flash_tween.tween_property(sprite, "modulate", original_modulate, 0.2)
