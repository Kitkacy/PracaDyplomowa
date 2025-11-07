extends Resource
class_name Upgrade

@export var name: String
@export var description: String
@export var icon: Texture2D
@export var upgrade_type: String
@export var value: float

func _init(p_name: String = "", p_description: String = "", p_upgrade_type: String = "", p_value: float = 0.0):
	name = p_name
	description = p_description
	upgrade_type = p_upgrade_type
	value = p_value