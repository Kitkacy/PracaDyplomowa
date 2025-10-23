extends CharacterBody2D

@export var movement_speed = 20.0
@onready var sprite = $Sprite2D
@export var hp = 10
@onready var walk_timer = get_node("walk_timer")
var target = null
var player = null
var obelisk = null

func _ready():
	# Wait a frame to ensure all nodes are ready
	await get_tree().process_frame
	
	# Choose target randomly: 50% chance for player, 50% for obelisk
	player = get_tree().get_first_node_in_group("player")
	obelisk = get_tree().get_first_node_in_group("obelisk")
	
	print("Player found: ", player != null)
	print("Obelisk found: ", obelisk != null)
	
	if randf() < 0.5 and player:
		target = player
	elif obelisk:
		target = obelisk
	else:
		target = player  # Fallback to player if obelisk not found
	
	print("Enemy targeting: ", "Player" if target == player else ("Obelisk" if target == obelisk else "None"))

func _physics_process(_delta):
	if target:
		var direction = global_position.direction_to(target.global_position)
		velocity = direction * movement_speed
		move_and_slide()
		if direction.x > 0.1:
			sprite.flip_h = true
		elif direction.x < -0.1:
			sprite.flip_h = false

		if velocity != Vector2.ZERO:
			if walk_timer.is_stopped():
				if sprite.frame >= sprite.hframes - 1:
					sprite.frame = 0
				else:
					sprite.frame += 1
				walk_timer.start()
	else:
		print("Enemy has no target!")


func _on_hurtbox_hurt(damage: Variant) -> void:
	hp -= damage
	if hp <= 0:
		# Store position before calling drop_loot to ensure we have the correct position
		var death_position = global_position
		call_deferred("drop_loot", death_position)
		call_deferred("queue_free")

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
	
	# Add EXP
	var game_stats = get_node("/root/GameStats")
	if game_stats:
		game_stats.add_exp(10)  # Kobolds give 10 EXP
