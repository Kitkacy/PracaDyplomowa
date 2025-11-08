extends Resource
class_name PhaseModifier

enum ModifierType {
	SPEED,
	DAMAGE_RESISTANCE,
	DAMAGE_BOOST
}

var modifier_type: ModifierType
var name: String
var description: String
var value: float

func _init(p_type: ModifierType, p_name: String, p_description: String, p_value: float):
	modifier_type = p_type
	name = p_name
	description = p_description
	value = p_value
