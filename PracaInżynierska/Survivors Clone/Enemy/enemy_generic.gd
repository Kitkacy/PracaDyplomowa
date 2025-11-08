extends CharacterBody2D

@export var movement_speed = 25.0  # Fastest but weakest
@onready var sprite = $Sprite2D
@export var hp = 15  # Updated to match scene file
@onready var walk_timer = get_node("walk_timer")
var target = null
var player = null
var obelisk = null

# Hit feedback variables
var original_modulate: Color
var flash_tween: Tween
var damage_number_scene = preload("res://UI/damage_number.tscn")

# Knockback variables
@export var knockback_strength = 100.0
@export var knockback_duration = 0.3
var knockback_velocity = Vector2.ZERO
var knockback_timer = 0.0

# No obstacle avoidance - simple charge movement

func _ready():
	# Store original sprite color for hit flash effect
	original_modulate = sprite.modulate
	
	# Set up collision system - enemies still collide with destructible rocks
	collision_layer = 4  # Enemy layer
	collision_mask = 67   # World (1) + Player (2) + Boundary (64) - enemies collide with rocks but don't avoid them
	
	# Configure hitbox for attacking rocks
	if has_node("Hitbox"):
		var hitbox = $Hitbox
		# Apply phase modifier to damage
		var game_stats = get_node("/root/GameStats")
		var damage_multiplier = game_stats.get_enemy_damage_multiplier() if game_stats else 1.0
		hitbox.damage = int(5 * damage_multiplier)  # Set enemy melee damage with modifier
		print("Enemy hitbox configured - base damage: 5, multiplier: ", damage_multiplier, ", final damage: ", hitbox.damage, " layer: ", hitbox.collision_layer, " mask: ", hitbox.collision_mask)
	else:
		print("ERROR: No Hitbox found on enemy!")
	
	# Connect hurtbox signal for taking damage from projectiles
	if has_node("Hurtbox"):
		var hurtbox = $Hurtbox
		print("Enemy _ready: Hurtbox found, checking connection...")
		if not hurtbox.hurt.is_connected(_on_hurtbox_hurt):
			hurtbox.hurt.connect(_on_hurtbox_hurt)
			print("  Enemy hurtbox signal connected successfully")
		else:
			print("  Enemy hurtbox signal was already connected")
		print("  Current hurtbox.hurt connections: ", hurtbox.hurt.get_connections())
	else:
		print("ERROR: No Hurtbox found on enemy!")
	
	# Wait a frame to ensure all nodes are ready
	await get_tree().process_frame
	
	# Dynamic target selection based on available targets
	player = get_tree().get_first_node_in_group("player")
	obelisk = get_tree().get_first_node_in_group("obelisk")
	var towers = get_tree().get_nodes_in_group("tower")
	
	print("Enemy collision setup - layer: ", collision_layer, " mask: ", collision_mask)
	
	# Choose target with equal probability for each available target type
	choose_target_dynamically(towers)
	
	print("Enemy targeting: ", get_target_name())

func _physics_process(delta):
	# Handle knockback
	if knockback_timer > 0:
		knockback_timer -= delta
		# Apply knockback velocity (decreasing over time)
		var knockback_factor = knockback_timer / knockback_duration
		velocity = knockback_velocity * knockback_factor
		move_and_slide()
		return  # Skip normal movement while being knocked back
	
	# Simple charge movement - no obstacle avoidance
	if target:
		var direction = global_position.direction_to(target.global_position)
		# Apply phase modifier to movement speed
		var game_stats = get_node("/root/GameStats")
		var speed_multiplier = game_stats.get_enemy_speed_multiplier() if game_stats else 1.0
		velocity = direction * movement_speed * speed_multiplier
		
		# Move without any collision handling
		move_and_slide()
		
		# Update sprite facing direction based on movement direction
		if direction.x > 0.1:
			sprite.flip_h = true
		elif direction.x < -0.1:
			sprite.flip_h = false

		# Animate sprite
		if walk_timer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walk_timer.start()
	else:
		print("Enemy has no target!")


func _on_hurtbox_hurt(damage: Variant, attacker_position: Vector2 = Vector2.ZERO) -> void:
	print("Enemy _on_hurtbox_hurt called! Damage: ", damage, " Current HP: ", hp)
	
	# Apply phase modifier damage resistance
	var game_stats = get_node("/root/GameStats")
	var resistance = game_stats.get_enemy_damage_resistance() if game_stats else 0.0
	var actual_damage = damage * (1.0 - resistance)
	
	hp -= actual_damage
	
	# Show damage number
	show_damage_number(int(actual_damage))
	
	# Flash sprite
	flash_sprite()
	
	# Apply knockback if attacker position is provided
	if attacker_position != Vector2.ZERO:
		apply_knockback(attacker_position)
	
	print("  New HP: ", hp)
	if hp <= 0:
		# Store position before calling drop_loot to ensure we have the correct position
		var death_position = global_position
		call_deferred("drop_loot", death_position)
		call_deferred("queue_free")

func show_damage_number(damage: int):
	# Create damage number at enemy position with some random offset
	var damage_number = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(damage_number)
	
	# Position it slightly above the enemy with some random horizontal offset
	var offset = Vector2(randf_range(-20, 20), -30)
	damage_number.setup(damage, global_position + offset)

func flash_sprite():
	# Stop any existing flash tween
	if flash_tween:
		flash_tween.kill()
	
	# Create new tween for flash effect
	flash_tween = create_tween()
	
	# Flash red then back to normal
	sprite.modulate = Color.RED
	flash_tween.tween_property(sprite, "modulate", original_modulate, 0.1)

func drop_loot(death_position: Vector2):
	# Drop a blue square at the exact enemy death position
	var blue_square_scene = preload("res://Loot/blue_square.tscn")
	var blue_square = blue_square_scene.instantiate()
	
	print("Enemy died at position: ", death_position)
	
	# Add to the current scene
	get_tree().current_scene.add_child(blue_square)
	
	# Set position to exact enemy death position
	blue_square.global_position = death_position
	print("Blue square created at position: ", blue_square.global_position)
	
	# 1% chance to drop health pickup
	if randf() < 0.01:  # 1% chance
		var health_pickup_scene = preload("res://Loot/health_pickup.tscn")
		var health_pickup = health_pickup_scene.instantiate()
		get_tree().current_scene.add_child(health_pickup)
		# Offset slightly so it doesn't overlap with blue square
		health_pickup.global_position = death_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
		print("Health pickup dropped!")
	
	# Add EXP
	var game_stats = get_node("/root/GameStats")
	if game_stats:
		game_stats.add_exp(15)  # Weak Kobolds give 15 EXP

func apply_knockback(attacker_position: Vector2):
	# Calculate knockback direction (away from attacker)
	var knockback_direction = (global_position - attacker_position).normalized()
	
	# Apply knockback velocity
	knockback_velocity = knockback_direction * knockback_strength
	knockback_timer = knockback_duration

func choose_target_dynamically(towers: Array):
	# Create list of available targets
	var available_targets = []
	
	# Always add player and obelisk if they exist
	if player:
		available_targets.append({"type": "player", "target": player})
	if obelisk:
		available_targets.append({"type": "obelisk", "target": obelisk})
	
	# Add all towers
	for tower in towers:
		if tower and is_instance_valid(tower):
			available_targets.append({"type": "tower", "target": tower})
	
	print("Available targets: ", available_targets.size(), " (Player: ", player != null, ", Obelisk: ", obelisk != null, ", Towers: ", towers.size(), ")")
	
	# Choose random target with equal probability
	if available_targets.size() > 0:
		var random_index = randi() % available_targets.size()
		var selected = available_targets[random_index]
		target = selected.target
		print("Selected target type: ", selected.type)
	else:
		# Fallback to player
		target = player
		print("No targets found, defaulting to player")

func get_target_name() -> String:
	if target == player:
		return "Player"
	elif target == obelisk:
		return "Obelisk" 
	elif target and target.is_in_group("tower"):
		return "Tower"
	else:
		return "None"

# All obstacle avoidance and collision handling functions removed - using simple charge movement
