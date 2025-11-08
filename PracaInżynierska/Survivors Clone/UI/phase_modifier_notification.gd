extends CanvasLayer

@onready var label = $Panel/Label
@onready var panel = $Panel

var fade_tween: Tween

func _ready():
	hide()
	layer = 50  # Above game UI but below pause menu

func show_modifier(modifier_text: String):
	label.text = modifier_text
	panel.modulate.a = 0.0
	show()
	
	# Fade in
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.tween_property(panel, "modulate:a", 1.0, 0.5)
	fade_tween.tween_interval(4.0)  # Stay visible for 4 seconds
	fade_tween.tween_property(panel, "modulate:a", 0.0, 1.0)
	fade_tween.tween_callback(hide)
