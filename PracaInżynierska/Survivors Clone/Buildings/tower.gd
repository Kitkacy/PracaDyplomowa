extends Node2D

@export var damage: int = 15
@export var fire_rate: float = 2.0  # Shots per second
@export var detection_range: float = 120.0
@export var max_health: int = 50
@export var current_health: int = 50

@onready var fire_timer = $FireTimer
@onready var sprite = $Sprite2D2
@onready var range_indicator = $RangeIndicator
@onready var projectile_scene = preload("res://Weapons/projectile.tscn")
@onready var hurtbox = $Hurtbox
@onready var healthbar = $Healthbar

# Hit feedback variables
var original_modulate: Color
var flash_tween: Tween
var damage_number_scene = preload("res://UI/damage_number.tscn")

var can_place: bool = true
var is_placing: bool = false  # Track if currently in placement mode

func _ready():
	# Store original sprite color for hit flash effect
	if sprite:
		original_modulate = sprite.modulate
	
	# Set up the fire timer
	fire_timer.wait_time = 1.0 / fire_rate
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start()
	
	# Setup range indicator (optional visual)
	if range_indicator:
		range_indicator.visible = false
	
	# Setup health system
	current_health = max_health
	if hurtbox:
		hurtbox.hurt.connect(_on_damage_received)
	if healthbar:
		healthbar.update_health(current_health, max_health)

func _on_fire_timer_timeout():
	# Find the nearest enemy and shoot at it
	var nearest_enemy = find_nearest_enemy()
	if nearest_enemy:
		shoot_at_target(nearest_enemy)

func find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var nearest_enemy = null
	var nearest_distance = detection_range
	
	for enemy in enemies:
		if enemy and is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_enemy = enemy
	
	return nearest_enemy

func shoot_at_target(target: Node2D):
	# Create a projectile
	var projectile = projectile_scene.instantiate()
	
	# Set projectile damage and speed BEFORE adding to scene
	projectile.damage = damage
	projectile.speed = 200.0
	
	# Add it to the scene
	get_tree().current_scene.add_child(projectile)
	
	# Set projectile position to tower position
	projectile.global_position = global_position
	
	# Calculate direction to target
	var direction = (target.global_position - global_position).normalized()
	projectile.set_direction(direction)

func set_placement_valid(valid: bool):
	can_place = valid
	is_placing = true
	if sprite:
		if valid:
			# Green tint when valid placement
			sprite.modulate = Color(0.5, 1.0, 0.5, 1.0)
		else:
			# Red tint when invalid placement
			sprite.modulate = Color(1.0, 0.3, 0.3, 1.0)

func place_tower():
	if can_place:
		# Tower is now placed, restore normal appearance
		is_placing = false
		if sprite:
			sprite.modulate = Color(0.4351923, 0.43519226, 0.43519226, 1)  # Original dark grey color
			original_modulate = sprite.modulate  # Update original color after placement
		fire_timer.start()
		return true
	return false

func _on_damage_received(damage_amount: int):
	# Show damage number
	show_damage_number(damage_amount)
	
	# Flash sprite (blink effect)
	flash_sprite()
	
	take_damage(damage_amount)

func take_damage(damage_amount: int):
	current_health -= damage_amount
	if current_health <= 0:
		current_health = 0
		destroy_tower()
	else:
		if healthbar:
			healthbar.update_health(current_health, max_health)

func destroy_tower():
	# Stop firing
	if fire_timer:
		fire_timer.stop()
	
	# Play destruction effect or sound here if needed
	print("Tower destroyed!")
	
	# Remove the tower
	queue_free()

func show_damage_number(damage: int):
	# Create damage number at tower position with some random offset
	var damage_number = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(damage_number)
	
	# Position it slightly above the tower with some random horizontal offset
	var offset = Vector2(randf_range(-20, 20), -30)
	damage_number.setup(damage, global_position + offset)

func flash_sprite():
	if not sprite:
		return
		
	# Stop any existing flash tween
	if flash_tween:
		flash_tween.kill()
	
	# Create new tween for flash effect
	flash_tween = create_tween()
	
	# Flash red then back to normal
	sprite.modulate = Color.RED
	flash_tween.tween_property(sprite, "modulate", original_modulate, 0.1)
