extends StaticBody2D

signal health_changed(current_health, max_health)

# Base stats
var base_max_hp: int = 200

# Current stats (modified by upgrades)
var max_hp = 200
var hp = 200
@onready var healthbar = $HealthBar

# Health pickup generation
@export var health_pickup_scene: PackedScene = preload("res://Loot/health_pickup.tscn")
@export var timer_ui_scene: PackedScene = preload("res://UI/obelisk_timer.tscn")
@export var repair_prompt_scene: PackedScene = preload("res://UI/obelisk_repair_prompt.tscn")
@export var pickup_generation_time: float = 120.0  # 2 minutes
@export var repair_interaction_range: float = 50.0
@export var hp_per_blue_square: int = 2
@export var repair_rate: float = 0.3  # Time between each repair when holding F

var pickup_timer: Timer
var timer_display: Control
var repair_prompt: Control
var player_in_range: bool = false
var player_ref: Node2D = null
var repair_timer: Timer

func _ready():
	# Apply global upgrade multipliers from GameStats
	apply_upgrade_multipliers()
	
	# Initialize healthbar
	health_changed.emit(hp, max_hp)
	print("Obelisk initialized with ", hp, " HP")
	
	# Debug: Check if hurtbox is connected
	var hurtbox = $Hurtbox
	if hurtbox:
		print("Obelisk Hurtbox found, collision_layer: ", hurtbox.collision_layer, " collision_mask: ", hurtbox.collision_mask)
	
	# Set up health pickup generation timer
	setup_pickup_timer()
	
	# Set up timer UI display
	setup_timer_ui()
	
	# Set up repair prompt
	setup_repair_prompt()
	
	# Set up repair timer
	setup_repair_timer()

func apply_upgrade_multipliers():
	# Apply GameStats multipliers to obelisk stats
	var game_stats = get_node("/root/GameStats")
	if game_stats:
		max_hp = int(base_max_hp * game_stats.base_health_multiplier)
		hp = max_hp
		print("Obelisk created with health multiplier: ", max_hp)

func take_damage(damage: int):
	hp -= damage
	hp = max(hp, 0)  # Prevent negative health
	print("Obelisk HP:", hp)
	update_healthbar()

	# Check if obelisk is destroyed
	if hp <= 0:
		print("Obelisk destroyed!")
		game_over()

func update_healthbar():
	# Emit signal to update the healthbar
	health_changed.emit(hp, max_hp)

func game_over():
	print("Game over - Obelisk destroyed!")
	
	# Stop the pickup generation timer
	if pickup_timer:
		pickup_timer.stop()
	
	# Hide timer display
	if timer_display:
		timer_display.visible = false

	# Stop survival timer
	var game_stats = get_node("/root/GameStats")
	if game_stats:
		game_stats.stop_survival_timer()

	# Change to the game over scene immediately to avoid tree issues
	# Use a single-frame timer to defer but ensure we're still in tree
	var timer = Timer.new()
	get_tree().root.add_child(timer)
	timer.wait_time = 0.001
	timer.one_shot = true
	timer.timeout.connect(_safe_scene_change)
	timer.start()

func _safe_scene_change():
	# This function is called by a timer that's attached to the root
	# so it should always have access to the scene tree
	var main_tree = Engine.get_main_loop() as SceneTree
	if main_tree:
		main_tree.change_scene_to_file("res://UI/game_over.tscn")
	else:
		print("Error: Could not access scene tree for game over transition")

func change_to_game_over_scene():
	# Legacy function - keeping for compatibility
	_safe_scene_change()

func setup_pickup_timer():
	# Create and configure the timer for health pickup generation
	pickup_timer = Timer.new()
	pickup_timer.wait_time = pickup_generation_time
	pickup_timer.one_shot = false  # Repeat every 2 minutes
	pickup_timer.autostart = true
	pickup_timer.timeout.connect(_on_pickup_timer_timeout)
	add_child(pickup_timer)
	print("Obelisk: Health pickup timer started - will generate pickup every ", pickup_generation_time, " seconds")
	
	# Create a warning timer for 10 seconds before pickup generation
	var warning_timer = Timer.new()
	warning_timer.wait_time = pickup_generation_time - 10.0  # 1:50
	warning_timer.one_shot = false
	warning_timer.autostart = true
	warning_timer.timeout.connect(_on_pickup_warning)
	add_child(warning_timer)

func _on_pickup_timer_timeout():
	if hp > 0:  # Only generate pickups if obelisk is still alive
		generate_health_pickup()

func _on_pickup_warning():
	if hp > 0:  # Only show warning if obelisk is still alive
		# Glow effect to indicate upcoming pickup generation
		var sprite = $MainBase
		if sprite:
			var tween = create_tween()
			tween.tween_property(sprite, "modulate", Color(1.2, 1.2, 1.2, 1.0), 5.0)  # Brighten over 5 seconds
			tween.tween_property(sprite, "modulate", Color(0.65, 0.65, 0.65, 1.0), 5.0)  # Return to normal over 5 seconds

func setup_timer_ui():
	if not timer_ui_scene:
		print("Error: Timer UI scene not loaded!")
		return
	
	# Create the timer display
	timer_display = timer_ui_scene.instantiate()
	
	# Position it above the obelisk
	timer_display.position = Vector2(-50, -80)  # Center above obelisk
	timer_display.setup(pickup_generation_time)
	
	# Add it as a child of the obelisk
	add_child(timer_display)
	print("Obelisk timer UI created")

func _process(_delta):
	# Update the timer display if it exists
	if timer_display and pickup_timer:
		var time_left = pickup_timer.time_left
		if time_left > 0:
			timer_display.update_timer(time_left)
	
	# Check if player is in range and update prompt visibility
	check_player_proximity()
	
	# Handle repair input
	if player_in_range and hp < max_hp:
		if Input.is_action_pressed("interact"):  # F key
			print("DEBUG: F key pressed, player in range, hp: ", hp, "/", max_hp)
			if not repair_timer.is_stopped():
				# Timer is already running, do nothing
				print("DEBUG: Repair timer already running")
				pass
			else:
				# Start repair timer
				print("DEBUG: Starting repair timer")
				repair_timer.start()
				_on_repair_timer_timeout()  # Repair immediately on first press
		elif Input.is_action_just_released("interact"):
			# Stop repair when F is released
			print("DEBUG: F key released, stopping repair")
			repair_timer.stop()

func generate_health_pickup():
	if not health_pickup_scene:
		print("Error: Health pickup scene not loaded!")
		return
	
	# Show pickup generated effect on timer
	if timer_display:
		timer_display.show_pickup_generated()
	
	# Create the health pickup
	var pickup = health_pickup_scene.instantiate()
	
	# Position it near the obelisk with some random offset
	var spawn_offset = Vector2(
		randf_range(-40, 40),  # Random X offset
		randf_range(-40, 40)   # Random Y offset
	)
	pickup.global_position = global_position + spawn_offset
	
	# Add to the world (parent's parent, since obelisk might be in a group node)
	var world = get_parent()
	if world:
		world.add_child(pickup)
		print("Obelisk generated health pickup at position: ", pickup.global_position)
	else:
		pickup.queue_free()
		print("Error: Could not find world node to spawn health pickup")

func _on_hurtbox_hurt(damage: Variant, attacker_position: Vector2 = Vector2.ZERO) -> void:
	print("Obelisk hurtbox triggered! Damage: ", damage)
	take_damage(damage)

func setup_repair_prompt():
	if not repair_prompt_scene:
		return
	
	repair_prompt = repair_prompt_scene.instantiate()
	repair_prompt.position = Vector2(-75, 30)  # Position below obelisk
	repair_prompt.visible = false
	add_child(repair_prompt)

func setup_repair_timer():
	repair_timer = Timer.new()
	repair_timer.wait_time = repair_rate
	repair_timer.one_shot = false
	repair_timer.timeout.connect(_on_repair_timer_timeout)
	add_child(repair_timer)

func check_player_proximity():
	if not player_ref:
		player_ref = get_tree().get_first_node_in_group("player")
		if not player_ref:
			return
	
	var distance = global_position.distance_to(player_ref.global_position)
	var was_in_range = player_in_range
	player_in_range = distance <= repair_interaction_range
	
	# Show/hide prompt based on proximity and obelisk health
	if repair_prompt:
		var should_show = player_in_range and hp < max_hp
		if repair_prompt.visible != should_show:
			print("DEBUG: Prompt visibility changed to ", should_show, " (distance: ", distance, ", hp: ", hp, ")")
		repair_prompt.visible = should_show
		
	# Stop repair if player moves out of range
	if was_in_range and not player_in_range:
		print("DEBUG: Player moved out of range, stopping repair")
		repair_timer.stop()

func _on_repair_timer_timeout():
	print("DEBUG: Repair timer timeout called")
	# Check if we can still repair
	if not player_in_range or hp >= max_hp:
		print("DEBUG: Stopping repair - player_in_range: ", player_in_range, " hp: ", hp, "/", max_hp)
		repair_timer.stop()
		return
	
	# Get GameStats to check and consume blue squares
	var game_stats = get_node("/root/GameStats")
	if not game_stats:
		print("DEBUG: GameStats not found!")
		repair_timer.stop()
		return
	
	print("DEBUG: GameStats found")
	# Check if player has blue squares using the proper method
	var blue_squares = game_stats.get_blue_squares_count()
	print("DEBUG: Blue squares available: ", blue_squares)
	if blue_squares <= 0:
		print("DEBUG: No blue squares available")
		repair_timer.stop()
		return
	
	# Consume one blue square using the proper method
	print("DEBUG: Consuming 1 blue square, had: ", blue_squares)
	if game_stats.spend_blue_squares(1):
		# Heal the obelisk
		var old_hp = hp
		heal(hp_per_blue_square)
		print("DEBUG: Healed obelisk from ", old_hp, " to ", hp)
		
		# Stop if obelisk is fully healed
		if hp >= max_hp:
			print("DEBUG: Obelisk fully healed!")
			repair_timer.stop()
	else:
		print("DEBUG: Failed to spend blue square")
		repair_timer.stop()

func heal(amount: int):
	hp += amount
	hp = min(hp, max_hp)  # Don't exceed max health
	update_healthbar()
