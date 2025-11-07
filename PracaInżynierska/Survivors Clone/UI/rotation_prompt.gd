extends Control

func show_prompt():
	visible = true

func hide_prompt():
	visible = false

func _ready():
	hide_prompt()