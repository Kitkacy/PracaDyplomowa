extends Area2D

@export var damage = 1
@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableHitBoxTImer

func tempdisable():
	collision.call_deferred("set","disabled", true)
	disableTimer.start()

func _on_disable_hit_box_t_imer_timeout():
	collision.call_deferred("set","disabled", false)
