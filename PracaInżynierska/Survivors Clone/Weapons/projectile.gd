extends CharacterBody2D

@export var speed: float = 300.0
@export var damage: int = 10

var direction: Vector2 = Vector2.RIGHT

func _ready():
	print("Projectile _ready() called - damage: ", damage)
	# Add Area2D to attack group so hurtbox system recognizes it
	var area = $Area2D
	print("  Area2D found: ", area != null)
	area.add_to_group("attack")
	print("  Area2D added to attack group")
	
	# Transfer damage property to Area2D so hurtbox can read it
	area.damage = damage
	print("  Area2D damage set to: ", area.damage)
	
	# Start the lifetime timer
	$LifetimeTimer.start()
	print("  Lifetime timer started")

func _physics_process(_delta):
	# Move the projectile
	velocity = direction * speed
	move_and_slide()
	
func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()

func _on_area_2d_body_entered(body):
	# Only destroy projectile on solid collision (walls, etc.)
	# Damage is handled by area_entered detecting hurtboxes
	if body.is_in_group("boundary") or body.is_in_group("building"):
		print("Projectile hit solid object!")
		queue_free()

func _on_area_2d_area_entered(area):
	# The hurtbox system will automatically handle this
	# when our Area2D (which should be in "attack" group) enters a hurtbox
	# Just destroy the projectile - damage is handled by the hurtbox system
	if area.has_signal("hurt"):
		print("Projectile hit hurtbox!")
		queue_free()

func _on_lifetime_timer_timeout():
	# Destroy projectile after 5 seconds
	print("Projectile expired")
	queue_free()
