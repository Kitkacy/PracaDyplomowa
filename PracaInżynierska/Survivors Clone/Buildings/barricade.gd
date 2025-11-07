extends StaticBody2D

signal health_changed(current_health, max_health)

var max_hp = 200
var hp = 200
@onready var healthbar = $HealthBar

# Hit feedback variables
var original_modulate: Color
var flash_tween: Tween
var damage_number_scene = preload("res://UI/damage_number.tscn")

func _ready():
	# Store original sprite color for hit flash effect
	if has_node("Sprite2D"):
		var sprite = $Sprite2D
		original_modulate = sprite.modulate
	
	# Initialize healthbar
	health_changed.emit(hp, max_hp)
	print("Barricade initialized with ", hp, " HP")

func take_damage(damage: int):
	hp -= damage
	hp = max(hp, 0)  # Prevent negative health
	print("Barricade HP:", hp)
	update_healthbar()

	# Check if barricade is destroyed
	if hp <= 0:
		print("Barricade destroyed!")
		queue_free()

func update_healthbar():
	# Emit signal to update the healthbar
	health_changed.emit(hp, max_hp)

func _on_hurtbox_hurt(damage: Variant, attacker_position: Vector2 = Vector2.ZERO) -> void:
	print("Barricade hurtbox triggered! Damage: ", damage)
	
	# Show damage number
	show_damage_number(damage)
	
	# Flash sprite (blink effect)
	flash_sprite()
	
	take_damage(damage)

# For building system compatibility
var can_place: bool = true
var current_rotation: float = 0.0

func set_placement_valid(valid: bool):
	can_place = valid
	var sprite = $Sprite2D
	if sprite:
		if valid:
			sprite.modulate = Color.WHITE
		else:
			sprite.modulate = Color.RED

func place_building():
	if can_place:
		# Barricade is now placed
		return true
	return false

func rotate_building():
	current_rotation += 45.0
	if current_rotation >= 360.0:
		current_rotation = 0.0
	
	rotation_degrees = current_rotation
	print("Barricade rotated to: ", current_rotation, " degrees")

func show_damage_number(damage: int):
	# Create damage number at barricade position with some random offset
	var damage_number = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(damage_number)
	
	# Position it slightly above the barricade with some random horizontal offset
	var offset = Vector2(randf_range(-20, 20), -30)
	damage_number.setup(damage, global_position + offset)

func flash_sprite():
	if not has_node("Sprite2D"):
		return
		
	var sprite = $Sprite2D
	
	# Stop any existing flash tween
	if flash_tween:
		flash_tween.kill()
	
	# Create new tween for flash effect
	flash_tween = create_tween()
	
	# Flash red then back to normal
	sprite.modulate = Color.RED
	flash_tween.tween_property(sprite, "modulate", original_modulate, 0.1)
