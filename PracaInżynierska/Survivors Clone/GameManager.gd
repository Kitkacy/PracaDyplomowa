extends Node

@onready var game_over_scene = preload("res://UI/game_over.tscn")
var game_over_instance = null

func show_game_over():
	if game_over_instance == null:
		game_over_instance = game_over_scene.instantiate()
		get_tree().current_scene.add_child(game_over_instance)
		
		# Move to front so it's visible on top
		game_over_instance.z_index = 100

func _ready():
	# Make this node persist across scene changes (autoload)
	process_mode = Node.PROCESS_MODE_ALWAYS