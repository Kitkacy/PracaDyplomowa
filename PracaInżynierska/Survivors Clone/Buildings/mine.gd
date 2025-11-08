extends StaticBody2D

# Base stats
var base_explosion_damage: int = 50

# Current stats (modified by upgrades)
@export var explosion_damage: int = 50
@export var explosion_radius: float = 60.0
@export var fuse_time: float = 3.0

@onready var sprite = $ColorRect
@onready var sprite_image = $Sprite2D
@onready var explosion_radius_indicator = $ExplosionRadiusIndicator
@onready var trigger_area = $TriggerArea
@onready var fuse_timer = $FuseTimer
@onready var blink_timer = $BlinkTimer

var is_triggered: bool = false
var is_placed: bool = false
var can_place: bool = true
var original_color: Color
var blink_interval: float = 0.5
var time_elapsed: float = 0.0

# Explosion visual
var explosion_texture = preload("res://Textures/Enemy/explosion_pixelfied.png")

func _ready():
	# Apply global upgrade multipliers from GameStats
	apply_upgrade_multipliers()
	
	# Store original color
	original_color = sprite.color
	
	# Set up collision - mine body doesn't collide with anything when placed
	collision_layer = 128  # Building layer
	collision_mask = 0  # Don't collide with anything
	
	# Set up trigger area to detect enemies
	if trigger_area:
		trigger_area.collision_layer = 0
		trigger_area.collision_mask = 8  # Detect enemy hurtboxes (layer 8)
		trigger_area.area_entered.connect(_on_trigger_area_entered)
	
	# Set up timers
	if fuse_timer:
		fuse_timer.wait_time = fuse_time
		fuse_timer.one_shot = true
		fuse_timer.timeout.connect(_on_fuse_timer_timeout)
	
	if blink_timer:
		blink_timer.timeout.connect(_on_blink_timer_timeout)
	
	# Set up explosion radius indicator to draw the circle
	if explosion_radius_indicator:
		explosion_radius_indicator.visible = true
		var script = GDScript.new()
		script.source_code = """
extends Node2D

var radius = 60.0
var color = Color(1, 1, 0, 0.3)

func _draw():
	draw_circle(Vector2.ZERO, radius, color)
"""
		script.reload()
		explosion_radius_indicator.set_script(script)
		explosion_radius_indicator.set("radius", explosion_radius)
		explosion_radius_indicator.queue_redraw()

func set_placement_valid(valid: bool):
	can_place = valid
	if sprite:
		if valid:
			sprite.color = Color(0.2, 0.2, 0.2, 0.8)
		else:
			sprite.color = Color(1, 0, 0, 0.8)

func apply_upgrade_multipliers():
	# Apply GameStats multipliers to mine stats
	var game_stats = get_node("/root/GameStats")
	if game_stats:
		explosion_damage = int(base_explosion_damage * game_stats.mine_damage_multiplier)
		print("Mine created with damage multiplier: ", explosion_damage)

func place_mine():
	if can_place:
		is_placed = true
		sprite.color = original_color
		
		# Make the mine solid for building placement detection
		collision_mask = 128  # Detect other buildings
		
		# Make radius indicator semi-transparent after placement
		if explosion_radius_indicator:
			explosion_radius_indicator.set("color", Color(1, 1, 0, 0.15))
			explosion_radius_indicator.queue_redraw()
		
		# Check for enemies already in range when placed
		check_for_enemies_in_range()
		
		return true
	return false

func check_for_enemies_in_range():
	# Check if any enemies are already within the blast radius when mine is placed
	print("Checking for enemies already in mine range...")
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for enemy in enemies:
		if enemy and is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			print("Enemy found at distance: ", distance, " (blast radius: ", explosion_radius, ")")
			if distance <= explosion_radius:
				print("Enemy already in range! Triggering mine immediately...")
				trigger_mine()
				return

func _on_trigger_area_entered(area: Area2D):
	# Only trigger if placed and not already triggered
	if not is_placed or is_triggered:
		return
	
	print("Mine trigger area entered by: ", area.name, " from parent: ", area.get_parent().name if area.get_parent() else "no parent")
	
	# Check if it's an enemy hurtbox (collision layer 8) or if the parent is an enemy
	if area.collision_layer == 8 or (area.get_parent() and area.get_parent().is_in_group("enemy")):
		print("Enemy detected in mine blast zone! Triggering mine...")
		trigger_mine()
	else:
		print("Non-enemy area detected, ignoring.")

func trigger_mine():
	if is_triggered:
		return
	
	is_triggered = true
	print("Mine triggered! Starting fuse...")
	
	# Start the fuse timer
	fuse_timer.start()
	
	# Start blinking
	blink_timer.wait_time = blink_interval
	blink_timer.start()

func _on_blink_timer_timeout():
	# Toggle sprite visibility for blinking effect
	sprite.visible = !sprite.visible
	if sprite_image:
		sprite_image.visible = !sprite_image.visible
	
	# Increase blink speed as time passes
	time_elapsed += blink_timer.wait_time
	var progress = time_elapsed / fuse_time
	blink_interval = lerp(0.5, 0.05, progress)
	blink_timer.wait_time = blink_interval

func _on_fuse_timer_timeout():
	# Stop blinking
	blink_timer.stop()
	sprite.visible = true
	if sprite_image:
		sprite_image.visible = true
	
	# Explode!
	explode()

func explode():
	print("Mine exploding!")
	
	# Find all enemies in explosion radius
	var enemies = get_tree().get_nodes_in_group("enemy")
	var hit_count = 0
	
	for enemy in enemies:
		if enemy and is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			print("Enemy at distance: ", distance, " from mine (radius: ", explosion_radius, ")")
			if distance <= explosion_radius:
				# Damage the enemy through its hurtbox
				var hurtbox = enemy.get_node("Hurtbox")
				if hurtbox and hurtbox.has_signal("hurt"):
					print("Damaging enemy with ", explosion_damage, " damage")
					hurtbox.hurt.emit(explosion_damage, global_position)
					hit_count += 1
				elif enemy.has_method("_on_hurtbox_hurt"):
					print("Direct damage to enemy with ", explosion_damage, " damage")
					enemy._on_hurtbox_hurt(explosion_damage, global_position)
					hit_count += 1
	
	print("Mine hit ", hit_count, " enemies")
	
	# Show explosion visual
	show_explosion()
	
	# Remove the mine after explosion animation
	await get_tree().create_timer(1.0).timeout
	queue_free()

func show_explosion():
	# Create explosion sprite
	var explosion_sprite = Sprite2D.new()
	explosion_sprite.texture = explosion_texture
	explosion_sprite.global_position = global_position
	explosion_sprite.scale = Vector2(explosion_radius / 100.0, explosion_radius / 100.0)  # Scale to match radius
	
	# IMPORTANT: Allow explosion sprite to process when game is paused (e.g., during level up)
	explosion_sprite.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Add to scene
	get_parent().add_child(explosion_sprite)
	
	# Fade out animation - this tween will continue even when game is paused
	var tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)  # Use physics process to continue during pause
	tween.tween_property(explosion_sprite, "modulate:a", 0.0, 1.0)
	tween.tween_callback(explosion_sprite.queue_free)
	
	# Hide mine sprite immediately
	sprite.visible = false
	if sprite_image:
		sprite_image.visible = false
	if explosion_radius_indicator:
		explosion_radius_indicator.visible = false
