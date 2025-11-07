extends Control

@onready var label = $Label
var tween: Tween

func setup(damage_amount: int, spawn_position: Vector2):
	# Wait until the node is ready
	if not is_node_ready():
		await ready
	
	label.text = str(damage_amount)
	global_position = spawn_position
	
	# Create tween animation
	tween = create_tween()
	tween.set_parallel(true)  # Allow multiple property animations
	
	# Float upward
	tween.tween_property(self, "position", position + Vector2(0, -50), 1.0)
	
	# Fade out
	tween.tween_property(label, "modulate", Color(1, 1, 1, 0), 1.0)
	
	# Scale animation for impact
	label.scale = Vector2(1.5, 1.5)
	tween.tween_property(label, "scale", Vector2(0.8, 0.8), 1.0)
	
	# Remove when finished
	tween.finished.connect(queue_free)
