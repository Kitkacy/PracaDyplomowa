extends SceneTree

func _init():
	print("=== Testing Damage Flow ===")
	
	# Test projectile
	var proj_scene = load("res://Weapons/projectile.tscn")
	var proj = proj_scene.instantiate()
	proj.damage = 25  # Set damage before adding to scene
	
	# Simulate adding to tree
	var root = Node.new()
	root.add_child(proj)
	
	print("\n1. Projectile after _ready:")
	var proj_area = proj.get_node("Area2D")
	print("  Projectile.damage: ", proj.damage)
	print("  Area2D.damage: ", proj_area.get("damage"))
	print("  Area2D in attack group: ", proj_area.is_in_group("attack"))
	
	# Test enemy
	var enemy_scene = load("res://Enemy/enemy.tscn")
	var enemy = enemy_scene.instantiate()
	root.add_child(enemy)
	
	print("\n2. Enemy Hurtbox:")
	var hurtbox = enemy.get_node("Hurtbox")
	print("  collision_layer: ", hurtbox.collision_layer)
	print("  collision_mask: ", hurtbox.collision_mask)
	print("  has _on_area_entered: ", hurtbox.has_method("_on_area_entered"))
	print("  area_entered signal connected: ", hurtbox.area_entered.get_connections().size() > 0)
	
	# Check if enemy has the damage handler
	print("\n3. Enemy script:")
	print("  has _on_hurtbox_hurt: ", enemy.has_method("_on_hurtbox_hurt"))
	print("  hurtbox.hurt signal connections: ", hurtbox.hurt.get_connections())
	
	quit()
