extends CharacterBody2D

signal health_changed(current_health, max_health)

var movement_speed = 40.0
var max_hp = 70
var hp = 70
@onready var sprite = $Sprite2D
@onready var walk_timer = get_node("walk_timer")
@onready var healthbar = $HealthBar

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
	
	# Simply change to the game over scene
	get_tree().change_scene_to_file("res://UI/game_over.tscn")

func heal(amount: int):
	hp += amount
	hp = min(hp, max_hp)  # Don't exceed max health
	update_healthbar()

func _on_hurtbox_hurt(damage: Variant) -> void:
	take_damage(damage)
