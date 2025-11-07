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

func get_random_upgrades(count: int = 3) -> Array[Upgrade]:
	var shuffled_upgrades = available_upgrades.duplicate()
	shuffled_upgrades.shuffle()
	
	var selected_upgrades: Array[Upgrade] = []
	for i in range(min(count, shuffled_upgrades.size())):
		selected_upgrades.append(shuffled_upgrades[i])
	
	return selected_upgrades

func add_upgrade(new_upgrade: Upgrade):
	available_upgrades.append(new_upgrade)