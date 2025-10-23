extends StaticBody2D

signal health_changed(current_health, max_health)

var max_hp = 100
var hp = 100
@onready var healthbar = $HealthBar

func _ready():
	# Initialize healthbar
	health_changed.emit(hp, max_hp)
	print("Obelisk initialized with ", hp, " HP")
	
	# Debug: Check if hurtbox is connected
	var hurtbox = $Hurtbox
	if hurtbox:
		print("Obelisk Hurtbox found, collision_layer: ", hurtbox.collision_layer, " collision_mask: ", hurtbox.collision_mask)

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

	# Stop survival timer
	var game_stats = get_node("/root/GameStats")
	if game_stats:
		game_stats.stop_survival_timer()

	# Change to the game over scene
	get_tree().change_scene_to_file("res://UI/game_over.tscn")

func _on_hurtbox_hurt(damage: Variant) -> void:
	print("Obelisk hurtbox triggered! Damage: ", damage)
	take_damage(damage)