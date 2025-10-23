extends CharacterBody2D

@export var speed: float = 300.0
@export var damage: int = 10

var direction: Vector2 = Vector2.RIGHT

func _ready():
	# Start the lifetime timer
	$LifetimeTimer.start()
	
	# Create a simple circular sprite
	var sprite = $Sprite2D
	sprite.texture = create_circle_texture()

func _physics_process(_delta):
	# Move the projectile
	velocity = direction * speed
	move_and_slide()
	
	# Debug: Check if we're near any enemies
	if randf() < 0.01:  # Print occasionally to avoid spam
		print("Projectile at position: ", global_position)

func create_circle_texture() -> ImageTexture:
	# Create a simple yellow circle texture
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	var center = Vector2(8, 8)
	var radius = 6
	
	for x in range(16):
		for y in range(16):
			var pixel_pos = Vector2(x, y)
			var distance = center.distance_to(pixel_pos)
			if distance <= radius:
				# Yellow circle
				image.set_pixel(x, y, Color.YELLOW)
			else:
				# Transparent background
				image.set_pixel(x, y, Color.TRANSPARENT)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()

func _on_area_2d_body_entered(body):
	# Check if we hit an enemy or obelisk
	if body.is_in_group("enemy") or body.is_in_group("obelisk"):
		print("Projectile hit target!")
		# Deal damage to the target
		if body.has_method("take_damage"):
			body.take_damage(damage)
		elif body.has_method("_on_hurtbox_hurt"):
			body._on_hurtbox_hurt(damage)
		
		# Destroy the projectile
		queue_free()

func _on_area_2d_area_entered(area):
	# Check if we hit an enemy's or obelisk's hurtbox
	if (area.is_in_group("enemy") or area.is_in_group("obelisk") or 
		(area.get_parent() and (area.get_parent().is_in_group("enemy") or area.get_parent().is_in_group("obelisk")))):
		print("Projectile hit target area!")
		var target = area.get_parent() if (area.get_parent() and (area.get_parent().is_in_group("enemy") or area.get_parent().is_in_group("obelisk"))) else area
		
		# Deal damage to the target
		if target.has_method("take_damage"):
			target.take_damage(damage)
		elif target.has_method("_on_hurtbox_hurt"):
			target._on_hurtbox_hurt(damage)
		
		# Destroy the projectile
		queue_free()

func _on_lifetime_timer_timeout():
	# Destroy projectile after 5 seconds
	print("Projectile expired")
	queue_free()
