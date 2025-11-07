extends CharacterBody2D

signal health_changed(current_health, max_health)

var movement_speed = 40.0
var max_hp = 70
var hp = 70
@onready var sprite = $Sprite2D
@onready var walk_timer = get_node("walk_timer")
@onready var healthbar = $HealthBar

# Magnet system properties
@export var magnet_range = 80.0  # Distance at which loot starts being attracted
@export var magnet_strength = 150.0  # How fast loot moves toward player

func _physics_process(_delta):
	movement()

func _input(event):
	# Temporary test controls (remove later)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			print("Space pressed - taking damage!")
			take_damage(10)
		elif event.keycode == KEY_ENTER:
			print("Enter pressed - healing!")
			heal(10)
		elif event.keycode == KEY_E:
			print("E pressed - adding 50 EXP!")
			var game_stats = get_node("/root/GameStats")
			if game_stats:
				game_stats.add_exp(50)
		elif event.keycode == KEY_P:
			print("P pressed - adding 10 blue squares!")
			var game_stats = get_node("/root/GameStats")
			if game_stats:
				for i in 10:
					game_stats.add_blue_square()
		elif event.keycode == KEY_T:
			print("T pressed - skipping 1 minute!")
			# Skip time in enemy spawner
			var enemy_spawner = get_tree().get_first_node_in_group("enemy_spawner")
			if enemy_spawner and enemy_spawner.has_method("skip_time_by_minutes"):
				enemy_spawner.skip_time_by_minutes(1)
			else:
				print("Enemy spawner not found or doesn't have skip_time_by_minutes method")
			
			# Skip time in GameStats too
			var game_stats = get_node("/root/GameStats")
			if game_stats and game_stats.has_method("skip_time_by_minutes"):
				game_stats.skip_time_by_minutes(1)
		elif event.keycode == KEY_O:
			print("O pressed - toggling obstacle avoidance debug!")
			# Toggle debug for all enemies
			var enemies = get_tree().get_nodes_in_group("enemy")
			for enemy in enemies:
				if enemy.has_method("toggle_debug_avoidance"):
					enemy.toggle_debug_avoidance()
				elif enemy.has_property("debug_avoidance"):
					enemy.debug_avoidance = !enemy.debug_avoidance
					print("Enemy debug_avoidance set to: ", enemy.debug_avoidance)
	
func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov,y_mov)
	if mov.x > 0:
		sprite.flip_h = true
	elif mov.x < 0:
		sprite.flip_h = false
		
	if mov != Vector2.ZERO:
		if walk_timer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walk_timer.start()
	
	velocity = mov.normalized()*movement_speed
	move_and_slide()
	


func _ready():
	# Initialize healthbar
	health_changed.emit(hp, max_hp)
	
	# Start survival timer
	var game_stats = get_node("/root/GameStats")
	if game_stats:
		game_stats.reset_survival_time()

func update_healthbar():
	# Emit signal to update the standalone healthbar scene
	health_changed.emit(hp, max_hp)

func take_damage(damage: int):
	hp -= damage
	hp = max(hp, 0)  # Prevent negative health
	print("Player HP:", hp)
	update_healthbar()
	
	# Check if player is dead
	if hp <= 0:
		print("Player died!")
		die()

func die():
	print("Player dying - changing to game over scene")
	
	# Stop survival timer
	var game_stats = get_node("/root/GameStats")
	if game_stats:
		game_stats.stop_survival_timer()
	
	# Disable player movement and input
	set_physics_process(false)
	set_process_input(false)
	
	# Use call_deferred to change scene to avoid physics callback issues
	get_tree().call_deferred("change_scene_to_file", "res://UI/game_over.tscn")

func heal(amount: int):
	hp += amount
	hp = min(hp, max_hp)  # Don't exceed max health
	print("Player healed! HP:", hp, "/", max_hp)
	update_healthbar()

func _on_hurtbox_hurt(damage: Variant, attacker_position: Vector2 = Vector2.ZERO) -> void:
	take_damage(damage)

# Optional: Draw magnet range for debugging (you can remove this later)
func _draw():
	if Engine.is_editor_hint():
		return
	# Draw a subtle circle to show magnet range (optional - remove if you don't want visual)
	# draw_arc(Vector2.ZERO, magnet_range, 0, 2 * PI, 32, Color(0, 0.8, 1, 0.1), 2.0)
