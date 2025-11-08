extends Node

var available_upgrades: Array[Upgrade] = []

func _ready():
	setup_upgrades()

func setup_upgrades():
	available_upgrades.clear()
	
	# Movement Speed Upgrade
	var speed_upgrade = Upgrade.new(
		"Swift Feet",
		"Increase movement speed by 10%",
		"movement_speed",
		0.1
	)
	available_upgrades.append(speed_upgrade)
	
	# Damage Upgrade
	var damage_upgrade = Upgrade.new(
		"Sharp Weapons",
		"Increase weapon damage by 10%",
		"damage",
		0.1
	)
	available_upgrades.append(damage_upgrade)
	
	# Attack Speed Upgrade
	var attack_speed_upgrade = Upgrade.new(
		"Quick Draw",
		"Increase fire rate by 10%",
		"attack_speed",
		0.1
	)
	available_upgrades.append(attack_speed_upgrade)
	
	# Health Upgrade
	var health_upgrade = Upgrade.new(
		"Sturdy Body",
		"Increase maximum health by 10%",
		"max_health",
		0.1
	)
	available_upgrades.append(health_upgrade)
	
	# Magnet Range Upgrade
	var magnet_upgrade = Upgrade.new(
		"Longer Reach",
		"Increase collection range by 10%",
		"magnet_range",
		0.1
	)
	available_upgrades.append(magnet_upgrade)
	
	# Tower Damage Upgrade
	var tower_damage_upgrade = Upgrade.new(
		"Reinforced Towers",
		"Towers deal 10% more damage",
		"tower_damage",
		0.1
	)
	available_upgrades.append(tower_damage_upgrade)
	
	# Tower Fire Rate Upgrade
	var tower_fire_rate_upgrade = Upgrade.new(
		"Rapid Fire Towers",
		"Towers shoot 10% more frequently",
		"tower_fire_rate",
		0.1
	)
	available_upgrades.append(tower_fire_rate_upgrade)
	
	# Tower Health Upgrade
	var tower_health_upgrade = Upgrade.new(
		"Fortified Towers",
		"Towers have 10% more health",
		"tower_health",
		0.1
	)
	available_upgrades.append(tower_health_upgrade)
	
	# Drone Damage Upgrade
	var drone_damage_upgrade = Upgrade.new(
		"Enhanced Drones",
		"Drones deal 10% more damage",
		"drone_damage",
		0.1
	)
	available_upgrades.append(drone_damage_upgrade)
	
	# Drone Speed Upgrade
	var drone_speed_upgrade = Upgrade.new(
		"Swift Drones",
		"Drones spin 10% faster",
		"drone_speed",
		0.1
	)
	available_upgrades.append(drone_speed_upgrade)
	
	# Drone Health Upgrade
	var drone_health_upgrade = Upgrade.new(
		"Armored Drones",
		"Drones have 10% more health",
		"drone_health",
		0.1
	)
	available_upgrades.append(drone_health_upgrade)
	
	# Base Health Upgrade
	var base_health_upgrade = Upgrade.new(
		"Reinforced Base",
		"Base has 10% more health",
		"base_health",
		0.1
	)
	available_upgrades.append(base_health_upgrade)
	
	# Mine Damage Upgrade
	var mine_damage_upgrade = Upgrade.new(
		"Explosive Mines",
		"Mines deal 10% more damage",
		"mine_damage",
		0.1
	)
	available_upgrades.append(mine_damage_upgrade)

func get_random_upgrades(count: int = 3) -> Array[Upgrade]:
	var shuffled_upgrades = available_upgrades.duplicate()
	shuffled_upgrades.shuffle()
	
	var selected_upgrades: Array[Upgrade] = []
	for i in range(min(count, shuffled_upgrades.size())):
		selected_upgrades.append(shuffled_upgrades[i])
	
	return selected_upgrades

func add_upgrade(new_upgrade: Upgrade):
	available_upgrades.append(new_upgrade)