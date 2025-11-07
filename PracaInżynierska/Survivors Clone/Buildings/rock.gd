@tool
extends StaticBody2D

# Destructible rock with health system
@export var max_hp = 50
@export var hp = 50

# Hit feedback variables
var original_modulate: Color
var flash_tween: Tween
var damage_number_scene = preload("res://UI/damage_number.tscn")

# No health bar for rocks - only visual feedback

func _ready():
	# Set collision on World layer (1) so both player and enemies collide
	collision_layer = 1  # World layer
	collision_mask = 0   # Doesn't need to detect anything
	
	# Add to building group for identification
	add_to_group("building")
	add_to_group("rock")
	
	# Store original sprite color for hit flash effect
	if has_node("Sprite2D"):
		var sprite = $Sprite2D
		original_modulate = sprite.modulate
	
	# Set up hurtbox collision layers so enemies can damage rocks
	if has_node("Hurtbox"):
		var hurtbox = $Hurtbox
		hurtbox.collision_layer = 32  # Layer that enemy hitboxes can hit
		hurtbox.collision_mask = 8   # Detect enemy hitboxes (layer 8)
		
		# Connect the signal manually to be sure
		if not hurtbox.hurt.is_connected(_on_hurtbox_hurt):
			hurtbox.hurt.connect(_on_hurtbox_hurt)

func _on_hurtbox_hurt(damage, attacker_position):
	hp -= damage
	
	# Show damage number
	show_damage_number(damage)
	
	# Flash sprite (blink effect like enemies)
	flash_sprite()
	
	if hp <= 0:
		destroy_rock()

func show_damage_number(damage: int):
	# Create damage number at rock position with some random offset
	var damage_number = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(damage_number)
	
	# Position it slightly above the rock with some random horizontal offset
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

# Health bar functions removed - rocks only show visual feedback

func destroy_rock():
	# Optional: Create destruction particles or effect here
	
	# Remove the rock
	queue_free()

# Optional: Add method for debugging or interaction
func get_object_type() -> String:
	return "Destructible Rock"

# Visual feedback system confirmed working - issue is with enemy collision system
