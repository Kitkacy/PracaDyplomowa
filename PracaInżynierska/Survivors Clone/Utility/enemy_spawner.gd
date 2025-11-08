extends Node2D


@export var spawns: Array[Spawn_info] = []

@onready var player = get_tree().get_first_node_in_group("player")

var time = 0
var strong_kobold_spawned = false
@export var weak_kobold_scene: PackedScene = preload("res://Enemy/enemy.tscn")
@export var strong_kobold_scene: PackedScene = preload("res://Enemy/enemy_kobold_strong.tscn")
@export var strong_kobold_2_scene: PackedScene = preload("res://Enemy/enemy_kobold_strong_2.tscn")
@export var strong_kobold_3_scene: PackedScene = preload("res://Enemy/enemy_kobold_strong_3.tscn")
@export var strong_kobold_4_scene: PackedScene = preload("res://Enemy/enemy_kobold_strong_4.tscn")
@export var strong_kobold_5_scene: PackedScene = preload("res://Enemy/enemy_kobold_strong_5.tscn")

# Progressive enemy spawning system
var current_enemy_tier = 0
var kobold_scenes = []
var active_spawns = []  # Track currently active spawn infos

# Difficulty scaling variables
var last_difficulty_increase = 0
var difficulty_multiplier = 1.0
var base_spawn_rates = {}  # Store original spawn rates
var difficulty_increase_interval = 60  # Increase difficulty every 60 seconds (1 minute)

func _ready():
	# Initialize kobold progression system
	kobold_scenes = [
		weak_kobold_scene,      # Tier 0
		strong_kobold_scene,    # Tier 1 - should appear at 3 minutes
		strong_kobold_2_scene,  # Tier 2 - should appear at 6 minutes  
		strong_kobold_3_scene,  # Tier 3 - should appear at 9 minutes
		strong_kobold_4_scene,  # Tier 4 - should appear at 12 minutes
		strong_kobold_5_scene   # Tier 5 - should appear at 15 minutes
	]
	
	print("Kobold progression order:")
	for i in range(kobold_scenes.size()):
		print("  Tier ", i, ": ", kobold_scenes[i].resource_path.get_file())
	
	# Store base spawn rates for scaling and ensure weak kobolds spawn indefinitely
	for spawn_info in spawns:
		base_spawn_rates[spawn_info] = {
			"enemy_num": spawn_info.enemy_num,
			"enemy_spawn_delay": spawn_info.enemy_spawn_delay
		}
		active_spawns.append(spawn_info)
		
		# Ensure weak kobolds (enemy.tscn) spawn indefinitely by removing time_end
		if is_weak_kobold_spawn(spawn_info):
			spawn_info.time_end = 0  # No end time
			print("Set weak kobold spawn to run indefinitely")

func _on_timer_timeout():
	time += 1
	
	# Check for difficulty increases every 1 minute (60 seconds)
	var current_difficulty_tier = int(time / difficulty_increase_interval)
	if current_difficulty_tier > last_difficulty_increase:
		increase_difficulty()
		last_difficulty_increase = current_difficulty_tier
		
		# Progress enemy tiers every 3 minutes (every 3rd difficulty increase)
		if current_difficulty_tier > 0 and current_difficulty_tier % 3 == 0:
			progress_enemy_tier()
	
	var enemy_spawns = spawns
	for i in enemy_spawns:
		# Check time constraints for spawning - modified to ensure weak kobolds continue
		if time < i.time_start:
			continue
		# Only check time_end if it's > 0 AND it's not the original weak kobold
		if i.time_end > 0 and time > i.time_end and not is_weak_kobold_spawn(i):
			continue
			
		if i.spawn_delay_counter < i.enemy_spawn_delay:
			i.spawn_delay_counter += 1
		else:
			i.spawn_delay_counter = 0
			var new_enemy = load(str(i.enemy.resource_path))
			var counter = 0
			# Use scaled enemy count based on difficulty
			var scaled_enemy_count = get_scaled_enemy_count(i)
			while counter < scaled_enemy_count:
				var enemy_spawn = new_enemy.instantiate()
				enemy_spawn.global_position = get_random_position()
				add_child(enemy_spawn)
				counter += 1

func get_random_position():
	var vpr = get_viewport_rect().size * randf_range(1.1,1.4)
	var top_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y - vpr.y/2)     
	var top_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y - vpr.y/2)
	var bottom_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y + vpr.y/2)
	var bottom_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y + vpr.y/2)
	var pos_side = ["up", "down", "right", "left"].pick_random()
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left

	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)
	return Vector2(x_spawn,y_spawn)

func increase_difficulty():
	# Exponential growth: 1.1^minutes (10% compounding each minute)
	var difficulty_tier = int(time / difficulty_increase_interval)
	difficulty_multiplier = pow(1.1, difficulty_tier)
	
	print("=== DIFFICULTY INCREASED ===")
	print("Minute: ", difficulty_tier, " | Multiplier: ", "%.2f" % difficulty_multiplier, "x")
	print("Enemy Tier: ", current_enemy_tier, " | Time: ", time, "s")
	print("Enemy spawn count: ", int(difficulty_multiplier * 100), "% of base rates")
	
	# Debug: List current active spawns
	print("Active enemy types:")
	for spawn_info in active_spawns:
		if spawn_info.enemy:
			var scene_name = spawn_info.enemy.resource_path.get_file()
			var count = get_scaled_enemy_count(spawn_info)
			print("  - ", scene_name, ": ", count, " enemies every ", spawn_info.enemy_spawn_delay, " seconds")
	print("============================")

func get_scaled_enemy_count(spawn_info: Spawn_info) -> int:
	# Apply difficulty scaling to enemy count
	if spawn_info in base_spawn_rates:
		var base_count = base_spawn_rates[spawn_info]["enemy_num"]
		return max(1, int(base_count * difficulty_multiplier))
	return spawn_info.enemy_num

func progress_enemy_tier():
	current_enemy_tier += 1
	
	# Ensure we don't exceed available kobold types
	if current_enemy_tier >= kobold_scenes.size():
		current_enemy_tier = kobold_scenes.size() - 1
		print("Maximum enemy tier reached: ", current_enemy_tier)
		return
	
	print("Progressing to enemy tier: ", current_enemy_tier)
	
	# Remove the weakest enemy type (except if we're still at tier 0 or 1)
	if current_enemy_tier > 1:
		# Find and remove the weakest active spawn
		var weakest_spawn = find_weakest_spawn()
		if weakest_spawn:
			spawns.erase(weakest_spawn)
			active_spawns.erase(weakest_spawn)
			base_spawn_rates.erase(weakest_spawn)
			print("Removed weakest enemy: ", weakest_spawn.enemy.resource_path.get_file())
	
	# Add the new stronger enemy type - use current_enemy_tier directly
	var new_kobold_scene = kobold_scenes[current_enemy_tier]
	print("Adding kobold tier ", current_enemy_tier, ": ", new_kobold_scene.resource_path.get_file())
	add_kobold_spawn(new_kobold_scene, current_enemy_tier)

func find_weakest_spawn() -> Spawn_info:
	# Find the spawn with the lowest tier kobold (earliest in kobold_scenes array)
	var weakest_spawn = null
	var lowest_tier = 999
	
	for spawn_info in active_spawns:
		for i in range(kobold_scenes.size()):
			if spawn_info.enemy == kobold_scenes[i]:
				if i < lowest_tier:
					lowest_tier = i
					weakest_spawn = spawn_info
				break
	
	return weakest_spawn

func add_kobold_spawn(kobold_scene: PackedScene, tier: int):
	# Create spawn info for the new kobold type
	var kobold_spawn = Spawn_info.new()
	kobold_spawn.time_start = time  # Start immediately
	kobold_spawn.time_end = 0       # No end time
	kobold_spawn.enemy = kobold_scene
	kobold_spawn.enemy_num = 1      # Base spawn count
	
	# Stronger kobolds spawn less frequently but are more dangerous
	var spawn_delays = [5, 7, 9, 11, 13, 15]  # Delays for each tier
	kobold_spawn.enemy_spawn_delay = spawn_delays[min(tier, spawn_delays.size() - 1)]
	
	# Add to arrays
	spawns.append(kobold_spawn)
	active_spawns.append(kobold_spawn)
	
	# Store base spawn rate for scaling
	base_spawn_rates[kobold_spawn] = {
		"enemy_num": kobold_spawn.enemy_num,
		"enemy_spawn_delay": kobold_spawn.enemy_spawn_delay
	}
	
	print("Added new kobold: ", kobold_scene.resource_path.get_file(), " with ", kobold_spawn.enemy_spawn_delay, "s delay")

func add_strong_kobold_spawning():
	# This function is now replaced by progress_enemy_tier system
	# But keeping for compatibility if called elsewhere
	if current_enemy_tier == 0:
		current_enemy_tier = 1
		add_kobold_spawn(strong_kobold_scene, 1)

func is_weak_kobold_spawn(spawn_info: Spawn_info) -> bool:
	# Check if this is the original weak kobold spawn by comparing against the weak kobold scene
	if spawn_info.enemy and weak_kobold_scene:
		return spawn_info.enemy.resource_path == weak_kobold_scene.resource_path
	return false

func skip_time_by_minutes(minutes: int):
	# Add minutes * 60 seconds to current time
	time += minutes * 60
	print("Time skipped by ", minutes, " minutes. Current time: ", time, " seconds")
	
	# Check for difficulty increases and enemy tier progressions that may have been skipped
	var new_difficulty_tier = int(time / difficulty_increase_interval)
	while last_difficulty_increase < new_difficulty_tier:
		increase_difficulty()
		last_difficulty_increase += 1
		
		# Progress enemy tiers every 3rd difficulty increase (every 3 minutes)
		if last_difficulty_increase > 0 and last_difficulty_increase % 3 == 0:
			progress_enemy_tier()
	
	print("After time skip - Current enemy tier: ", current_enemy_tier)
	print("Active enemy types: ", active_spawns.size())
