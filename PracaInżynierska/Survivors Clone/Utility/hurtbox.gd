extends Area2D

@export_enum("Cooldown","HitOnce","DisableHitBox") var HurtBoxType = 0

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer

signal hurt(damage, attacker_position)

func _on_area_entered(area):
	print("Hurtbox: area entered - ", area.name, " in attack group: ", area.is_in_group("attack"))
	if area.is_in_group("attack"):
		var area_damage = area.get("damage")
		print("  Area damage value: ", area_damage)
		if not area_damage == null:
			match HurtBoxType:
				0: #Cooldown
					collision.call_deferred("set", "disabled", true)
					disableTimer.start()
				1: #HitOnce
					pass
				2: #DisableHitBox
					if area.has_method("tempdisable"):
						area.tempdisable()
			var damage = area.damage
			var attacker_pos = area.global_position
			print("  Emitting hurt signal with damage: ", damage)
			emit_signal("hurt", damage, attacker_pos)
				
func _on_disable_timer_timeout():
	collision.call_deferred("set","disabled",false)
