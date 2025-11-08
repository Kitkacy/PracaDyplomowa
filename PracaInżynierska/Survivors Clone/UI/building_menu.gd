extends Control

@onready var tower_button = $Panel/HBoxContainer/TowerButton
@onready var barricade_button = $Panel/HBoxContainer/BarricadeButton
@onready var mine_button = $Panel/HBoxContainer/MineButton
@onready var drone_button = $Panel/HBoxContainer/DroneButton if has_node("Panel/HBoxContainer/DroneButton") else null
@onready var blue_square_counter = $"../BlueSquareCounter"

var tower_scene = preload("res://Buildings/tower.tscn")
var barricade_scene = preload("res://Buildings/barricade.tscn")
var mine_scene = preload("res://Buildings/mine.tscn")
var rotation_prompt_scene = preload("res://UI/rotation_prompt.tscn")
var is_placing_building: bool = false
var building_ghost: Node2D = null
var rotation_prompt: Control = null
var tower_cost: int = 30
var barricade_cost: int = 15
var mine_cost: int = 15
var drone_cost: int = 10

func _ready():
	tower_button.pressed.connect(_on_tower_button_pressed)
	barricade_button.pressed.connect(_on_barricade_button_pressed)
	mine_button.pressed.connect(_on_mine_button_pressed)
	if drone_button:
		drone_button.pressed.connect(_on_drone_button_pressed)
		print("Drone button connected successfully")
	else:
		print("ERROR: Drone button not found!")

func _on_tower_button_pressed():
	var game_stats = get_node("/root/GameStats")
	if game_stats and game_stats.get_blue_squares_count() >= tower_cost:
		start_building_placement(tower_scene, tower_cost)
	else:
		print("Not enough blue squares! Need: ", tower_cost)

func _on_barricade_button_pressed():
	var game_stats = get_node("/root/GameStats")
	if game_stats and game_stats.get_blue_squares_count() >= barricade_cost:
		start_building_placement(barricade_scene, barricade_cost)
	else:
		print("Not enough blue squares! Need: ", barricade_cost)

func _on_mine_button_pressed():
	var game_stats = get_node("/root/GameStats")
	if game_stats and game_stats.get_blue_squares_count() >= mine_cost:
		start_building_placement(mine_scene, mine_cost)
	else:
		print("Not enough blue squares! Need: ", mine_cost)

func _on_drone_button_pressed():
	print("=== DRONE BUTTON PRESSED ===")
	var game_stats = get_node("/root/GameStats")
	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		print("ERROR: Player not found!")
		return
	
	print("Player found: ", player.name)
	print("Current drones: ", player.get_drone_count(), "/", player.max_drones)
	
	# Check if player has reached max drones
	if player.get_drone_count() >= player.max_drones:
		print("Maximum drones reached (", player.max_drones, ")")
		show_max_drones_popup()
		return
	
	# Check if player has enough blue squares
	var blue_squares = game_stats.get_blue_squares_count() if game_stats else 0
	print("Blue squares available: ", blue_squares, " (need ", drone_cost, ")")
	
	if game_stats and blue_squares >= drone_cost:
		print("Attempting to spend ", drone_cost, " blue squares...")
		# Spend blue squares
		if game_stats.spend_blue_squares(drone_cost):
			print("Blue squares spent successfully, adding drone...")
			# Add drone to player
			if player.add_drone():
				print("SUCCESS: Drone purchased! Cost: ", drone_cost, " blue squares")
			else:
				print("ERROR: Failed to add drone, refunding...")
				# Refund if drone couldn't be added
				game_stats.blue_squares_collected += drone_cost
				game_stats.blue_squares_changed.emit(game_stats.blue_squares_collected)
		else:
			print("ERROR: Failed to spend blue squares")
	else:
		print("Not enough blue squares! Have: ", blue_squares, ", Need: ", drone_cost)
	print("===========================")

func start_building_placement(building_scene: PackedScene, _cost: int):
	if is_placing_building:
		return
		
	is_placing_building = true
	building_ghost = building_scene.instantiate()
	get_tree().current_scene.add_child(building_ghost)
	
	# Make it semi-transparent and disable collision
	building_ghost.modulate.a = 0.7
	building_ghost.set_collision_layer_value(1, false)
	building_ghost.set_collision_mask_value(1, false)
	
	# Disable firing while placing (for towers)
	var fire_timer = building_ghost.get_node_or_null("FireTimer")
	if fire_timer:
		fire_timer.stop()
	
	# Show rotation prompt if placing a barricade (has rotate_building method)
	if building_ghost.has_method("rotate_building"):
		if not rotation_prompt:
			rotation_prompt = rotation_prompt_scene.instantiate()
			var camera = get_viewport().get_camera_2d()
			if camera:
				camera.add_child(rotation_prompt)
		rotation_prompt.show_prompt()

func _input(event):
	if not is_placing_building or not building_ghost:
		return
		
	if event is InputEventMouseMotion:
		# Move building ghost to mouse position
		var camera = get_viewport().get_camera_2d()
		if camera:
			var mouse_pos = camera.get_global_mouse_position()
			building_ghost.global_position = mouse_pos
			
			# Check if placement is valid
			var valid = is_placement_valid(mouse_pos)
			building_ghost.set_placement_valid(valid)
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Try to place building
			if attempt_place_building():
				finish_placement()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Cancel placement
			cancel_placement()
	
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_Q:
			# Rotate building if it has a rotate_building method (barricades)
			if building_ghost.has_method("rotate_building"):
				building_ghost.rotate_building()

func is_placement_valid(pos: Vector2) -> bool:
	var min_distance_to_obelisk = 80.0
	var min_distance_to_player = 50.0
	var min_distance_to_buildings = 40.0
	
	# Mines have different placement rules - can be placed right next to things
	var is_mine = building_ghost and building_ghost.scene_file_path.ends_with("mine.tscn")
	if is_mine:
		min_distance_to_obelisk = 30.0
		min_distance_to_player = 20.0
		min_distance_to_buildings = 10.0  # Just needs to not overlap
	
	# Check distance to obelisk
	var obelisk = get_tree().get_first_node_in_group("obelisk")
	if obelisk:
		var distance_to_obelisk = pos.distance_to(obelisk.global_position)
		if distance_to_obelisk < min_distance_to_obelisk:
			return false
	
	# Check distance to player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance_to_player = pos.distance_to(player.global_position)
		if distance_to_player < min_distance_to_player:
			return false
	
	# Check distance to other buildings
	var buildings = get_tree().get_nodes_in_group("building")
	for building in buildings:
		if building != building_ghost:
			var distance_to_building = pos.distance_to(building.global_position)
			if distance_to_building < min_distance_to_buildings:
				return false
	
	return true

func attempt_place_building() -> bool:
	if not building_ghost:
		return false
		
	var valid = is_placement_valid(building_ghost.global_position)
	if valid:
		# Determine cost based on building type
		var cost = tower_cost
		if building_ghost.scene_file_path.ends_with("barricade.tscn"):
			cost = barricade_cost
		elif building_ghost.scene_file_path.ends_with("mine.tscn"):
			cost = mine_cost
		
		# Spend blue squares
		var game_stats = get_node("/root/GameStats")
		if game_stats and game_stats.get_blue_squares_count() >= cost:
			# Finalize building placement
			building_ghost.modulate.a = 1.0
			building_ghost.set_collision_layer_value(1, true)
			building_ghost.set_collision_mask_value(1, true)
			
			# Call appropriate placement method
			if building_ghost.has_method("place_tower"):
				building_ghost.place_tower()
			elif building_ghost.has_method("place_building"):
				building_ghost.place_building()
			elif building_ghost.has_method("place_mine"):
				building_ghost.place_mine()
			
			# Spend the blue squares
			spend_blue_squares(cost)
			
			return true
	
	return false

func spend_blue_squares(amount: int):
	var game_stats = get_node("/root/GameStats")
	if game_stats:
		game_stats.spend_blue_squares(amount)

func finish_placement():
	# Hide rotation prompt if it's shown
	if rotation_prompt:
		rotation_prompt.hide_prompt()
	
	is_placing_building = false
	building_ghost = null

func cancel_placement():
	# Hide rotation prompt if it's shown
	if rotation_prompt:
		rotation_prompt.hide_prompt()
	
	if building_ghost:
		building_ghost.queue_free()
	finish_placement()

func show_max_drones_popup():
	# Create a temporary popup label
	var popup = Label.new()
	popup.text = "Maximum drones reached (5/5)!"
	popup.add_theme_color_override("font_color", Color.RED)
	popup.add_theme_font_size_override("font_size", 20)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Position it above the building menu
	popup.position = Vector2(-50, -40)
	popup.size = Vector2(200, 30)
	
	# Add to scene
	add_child(popup)
	
	# Animate the popup
	var popup_tween = create_tween()
	popup.modulate.a = 0.0
	popup_tween.tween_property(popup, "modulate:a", 1.0, 0.3)
	popup_tween.tween_interval(2.0)  # Stay visible for 2 seconds
	popup_tween.tween_property(popup, "modulate:a", 0.0, 0.5)
	popup_tween.tween_callback(popup.queue_free)
