extends StaticBody2D

# Boundary rock that blocks player movement but allows enemies to pass through
# Uses collision layers to selectively block only the player

func _ready():
	# Set collision layers for boundary rocks
	# Layer 64 (Boundary) - only blocks player (layer 2)
	collision_layer = 64  # Boundary layer
	collision_mask = 0    # Don't need to detect anything
	
	# Add to boundary group for identification
	add_to_group("boundary")
	
	print("Boundary rock collision setup: layer=", collision_layer, ", mask=", collision_mask)

# Optional: Add visual feedback when player touches the rock
func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		# Could add particle effect or sound here
		pass
