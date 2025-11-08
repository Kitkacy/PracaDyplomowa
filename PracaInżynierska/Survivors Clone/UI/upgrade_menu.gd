extends Control

@onready var upgrade_button1 = $Panel/VBoxContainer/UpgradeContainer/UpgradeButton1
@onready var upgrade_button2 = $Panel/VBoxContainer/UpgradeContainer/UpgradeButton2
@onready var upgrade_button3 = $Panel/VBoxContainer/UpgradeContainer/UpgradeButton3

var current_upgrades: Array[Upgrade] = []
var upgrade_manager: Node

func _ready():
	upgrade_manager = get_node("/root/UpgradeManager")
	if not upgrade_manager:
		print("Warning: UpgradeManager not found!")
	
	# Connect button signals
	upgrade_button1.pressed.connect(_on_upgrade_selected.bind(0))
	upgrade_button2.pressed.connect(_on_upgrade_selected.bind(1))
	upgrade_button3.pressed.connect(_on_upgrade_selected.bind(2))
	
	hide()

func show_upgrade_menu():
	if not upgrade_manager:
		return
		
	# Get 3 random upgrades
	current_upgrades = upgrade_manager.get_random_upgrades(3)
	
	# Update button texts
	if current_upgrades.size() > 0:
		upgrade_button1.text = current_upgrades[0].name + "\n" + current_upgrades[0].description
	if current_upgrades.size() > 1:
		upgrade_button2.text = current_upgrades[1].name + "\n" + current_upgrades[1].description
	if current_upgrades.size() > 2:
		upgrade_button3.text = current_upgrades[2].name + "\n" + current_upgrades[2].description
	
	# Pause the game and show menu
	get_tree().paused = true
	show()

func _on_upgrade_selected(upgrade_index: int):
	if upgrade_index < current_upgrades.size():
		var selected_upgrade = current_upgrades[upgrade_index]
		apply_upgrade(selected_upgrade)
	
	# Hide menu and resume game
	hide()
	get_tree().paused = false

func apply_upgrade(upgrade: Upgrade):
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("Warning: Player not found!")
		return
	
	print("Applying upgrade: ", upgrade.name, " (", upgrade.upgrade_type, " +", upgrade.value * 100, "%)")
	
	match upgrade.upgrade_type:
		"movement_speed":
			var current_speed = player.movement_speed
			player.movement_speed = current_speed * (1.0 + upgrade.value)
			print("Movement speed: ", current_speed, " -> ", player.movement_speed)
		
		"damage":
			# Apply to auto weapon if it exists
			var auto_weapon = player.get_node_or_null("AutoWeapon")
			if auto_weapon and auto_weapon.has_method("increase_damage"):
				auto_weapon.increase_damage(upgrade.value)
			else:
				print("AutoWeapon not found or doesn't have increase_damage method")
		
		"attack_speed":
			# Apply to auto weapon if it exists
			var auto_weapon = player.get_node_or_null("AutoWeapon")
			if auto_weapon and auto_weapon.has_method("increase_attack_speed"):
				auto_weapon.increase_attack_speed(upgrade.value)
			else:
				print("AutoWeapon not found or doesn't have increase_attack_speed method")
		
		"max_health":
			var current_max_hp = player.max_hp
			var new_max_hp = int(current_max_hp * (1.0 + upgrade.value))
			var hp_increase = new_max_hp - current_max_hp
			player.max_hp = new_max_hp
			player.hp += hp_increase  # Also heal the player by the increase amount
			player.update_healthbar()
			print("Max health: ", current_max_hp, " -> ", new_max_hp, " (healed by ", hp_increase, ")")
		
		"magnet_range":
			var current_range = player.magnet_range
			player.magnet_range = current_range * (1.0 + upgrade.value)
			print("Magnet range: ", current_range, " -> ", player.magnet_range)
		
		"tower_damage":
			var game_stats = get_node("/root/GameStats")
			if game_stats:
				game_stats.tower_damage_multiplier *= (1.0 + upgrade.value)
				print("Tower damage multiplier: ", game_stats.tower_damage_multiplier)
				apply_to_all_towers("damage")
		
		"tower_fire_rate":
			var game_stats = get_node("/root/GameStats")
			if game_stats:
				game_stats.tower_fire_rate_multiplier *= (1.0 + upgrade.value)
				print("Tower fire rate multiplier: ", game_stats.tower_fire_rate_multiplier)
				apply_to_all_towers("fire_rate")
		
		"tower_health":
			var game_stats = get_node("/root/GameStats")
			if game_stats:
				game_stats.tower_health_multiplier *= (1.0 + upgrade.value)
				print("Tower health multiplier: ", game_stats.tower_health_multiplier)
				apply_to_all_towers("health")
		
		"drone_damage":
			var game_stats = get_node("/root/GameStats")
			if game_stats:
				game_stats.drone_damage_multiplier *= (1.0 + upgrade.value)
				print("Drone damage multiplier: ", game_stats.drone_damage_multiplier)
				apply_to_all_drones("damage")
		
		"drone_speed":
			var game_stats = get_node("/root/GameStats")
			if game_stats:
				game_stats.drone_speed_multiplier *= (1.0 + upgrade.value)
				print("Drone speed multiplier: ", game_stats.drone_speed_multiplier)
				apply_to_all_drones("speed")
		
		"drone_health":
			var game_stats = get_node("/root/GameStats")
			if game_stats:
				game_stats.drone_health_multiplier *= (1.0 + upgrade.value)
				print("Drone health multiplier: ", game_stats.drone_health_multiplier)
				apply_to_all_drones("health")
		
		"base_health":
			var game_stats = get_node("/root/GameStats")
			var obelisk = get_tree().get_first_node_in_group("obelisk")
			if game_stats and obelisk:
				var old_multiplier = game_stats.base_health_multiplier
				game_stats.base_health_multiplier *= (1.0 + upgrade.value)
				print("Base health multiplier: ", game_stats.base_health_multiplier)
				# Apply exponentially to obelisk
				if obelisk.has_property("max_hp"):
					var hp_ratio = float(obelisk.hp) / float(obelisk.max_hp) if obelisk.max_hp > 0 else 1.0
					obelisk.max_hp = int(obelisk.max_hp * (1.0 + upgrade.value))
					obelisk.hp = int(obelisk.max_hp * hp_ratio)
					if obelisk.has_method("update_healthbar"):
						obelisk.update_healthbar()
		
		"mine_damage":
			var game_stats = get_node("/root/GameStats")
			if game_stats:
				game_stats.mine_damage_multiplier *= (1.0 + upgrade.value)
				print("Mine damage multiplier: ", game_stats.mine_damage_multiplier)
		
		_:
			print("Unknown upgrade type: ", upgrade.upgrade_type)

func apply_to_all_towers(stat_type: String):
	var towers = get_tree().get_nodes_in_group("tower")
	var game_stats = get_node("/root/GameStats")
	if not game_stats:
		return
	
	for tower in towers:
		if not is_instance_valid(tower):
			continue
		
		match stat_type:
			"damage":
				if tower.has_property("base_damage"):
					tower.damage = int(tower.base_damage * game_stats.tower_damage_multiplier)
			"fire_rate":
				if tower.has_property("base_attack_cooldown"):
					tower.attack_cooldown = tower.base_attack_cooldown / game_stats.tower_fire_rate_multiplier
			"health":
				if tower.has_property("max_hp"):
					var hp_ratio = float(tower.hp) / float(tower.max_hp) if tower.max_hp > 0 else 1.0
					tower.max_hp = int(tower.max_hp * 1.1)  # Increase current towers by 10%
					tower.hp = int(tower.max_hp * hp_ratio)
					if tower.has_method("update_healthbar"):
						tower.update_healthbar()

func apply_to_all_drones(stat_type: String):
	var player = get_tree().get_first_node_in_group("player")
	var game_stats = get_node("/root/GameStats")
	if not player or not game_stats:
		return
	
	var drones = []
	if player.has_property("drones"):
		drones = player.drones
	
	for drone in drones:
		if not is_instance_valid(drone):
			continue
		
		match stat_type:
			"damage":
				if drone.has_property("damage"):
					drone.damage = int(drone.damage * 1.1)  # Increase by 10%
			"speed":
				if drone.has_property("orbit_speed"):
					drone.orbit_speed *= 1.1  # Increase by 10%
			"health":
				if drone.has_property("max_hp"):
					var hp_ratio = float(drone.current_hp) / float(drone.max_hp) if drone.max_hp > 0 else 1.0
					drone.max_hp = int(drone.max_hp * 1.1)  # Increase by 10%
					drone.current_hp = int(drone.max_hp * hp_ratio)