extends Node2D

@export var projectile_speed: float = 300.0
@export var fire_rate: float = 1.0  # Shots per second
@export var detection_range: float = 150.0

@onready var fire_timer = $FireTimer
@onready var projectile_scene = preload("res://Weapons/projectile.tscn")

var player: Node2D

func _ready():
	# Set up the fire timer
	fire_timer.wait_time = 1.0 / fire_rate
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start()
	
	# Get reference to the player
	player = get_parent()

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
	
	# Add it to the scene
	get_tree().current_scene.add_child(projectile)
	
	# Set projectile position to player position
	projectile.global_position = global_position
	
	# Calculate direction to target
	var direction = (target.global_position - global_position).normalized()
	projectile.set_direction(direction)
	
	# Set projectile speed
	projectile.speed = projectile_speed
	
	print("Shooting at enemy!")

func set_fire_rate(new_rate: float):
	fire_rate = new_rate
	if fire_timer:
		fire_timer.wait_time = 1.0 / fire_rate