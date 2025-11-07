extends SceneTree

func _init():
	print("=== Testing Collision System ===")
	
	# Test projectile
	var proj_scene = load("res://Weapons/projectile.tscn")
	var proj = proj_scene.instantiate()
	
	print("\n1. Projectile Main Body:")
	print("  collision_layer: ", proj.collision_layer)
	print("  collision_mask: ", proj.collision_mask)
	
	print("\n2. Projectile Area2D (before _ready):")
	var proj_area = proj.get_node("Area2D")
	print("  collision_layer: ", proj_area.collision_layer)
	print("  collision_mask: ", proj_area.collision_mask)
	print("  in attack group: ", proj_area.is_in_group("attack"))
	print("  has damage: ", proj_area.get("damage"))
	
	# Simulate adding to tree
	var root = Node.new()
	root.add_child(proj)
	
	print("\n3. Projectile Area2D (after _ready):")
	print("  collision_layer: ", proj_area.collision_layer)
	print("  collision_mask: ", proj_area.collision_mask)
	print("  in attack group: ", proj_area.is_in_group("attack"))
	print("  has damage: ", proj_area.get("damage"))
	print("  damage value: ", proj.damage)
	
	# Test enemy
	var enemy_scene = load("res://Enemy/enemy.tscn")
	var enemy = enemy_scene.instantiate()
	root.add_child(enemy)
	
	print("\n4. Enemy Hurtbox:")
	var hurtbox = enemy.get_node("Hurtbox")
	print("  collision_layer: ", hurtbox.collision_layer)
	print("  collision_mask: ", hurtbox.collision_mask)
	print("  has area_entered signal: ", hurtbox.has_signal("area_entered"))
	
	print("\n5. Collision Check:")
	print("  Proj Area (layer 16, mask 8) vs Enemy Hurtbox (layer 8, mask 16)")
	print("  Proj can hit Enemy: ", (proj_area.collision_mask & hurtbox.collision_layer) != 0)
	print("  Enemy can detect Proj: ", (hurtbox.collision_mask & proj_area.collision_layer) != 0)
	
	quit()
