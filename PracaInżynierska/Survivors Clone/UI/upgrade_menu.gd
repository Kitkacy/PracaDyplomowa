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
		
		_:
			print("Unknown upgrade type: ", upgrade.upgrade_type)