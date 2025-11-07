extends Control

@onready var time_label = $HBoxContainer/TimeLabel
@onready var health_icon = $HBoxContainer/HealthIcon

var total_time: float
var remaining_time: float

func setup(timer_duration: float):
	total_time = timer_duration
	remaining_time = timer_duration
	
	# Wait for the node to be ready before updating display
	if not is_node_ready():
		await ready
	
	update_display()

func update_timer(time_left: float):
	remaining_time = time_left
	update_display()

func update_display():
	# Ensure nodes are ready before accessing them
	if not time_label or not health_icon:
		return
		
	# Format time as MM:SS
	var minutes = int(remaining_time) / 60
	var seconds = int(remaining_time) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]
	
	# Add visual feedback when close to spawning
	if remaining_time <= 10.0:
		# Pulse effect when close to spawning
		var pulse_alpha = (sin(Time.get_ticks_msec() * 0.005) + 1.0) * 0.5
		modulate = Color(1.0, 1.0, 1.0, 0.7 + pulse_alpha * 0.3)
		health_icon.modulate = Color(1.0, 0.8 + pulse_alpha * 0.2, 0.8 + pulse_alpha * 0.2)
	else:
		modulate = Color(1.0, 1.0, 1.0, 0.8)
		health_icon.modulate = Color(1.0, 1.0, 1.0, 1.0)

func show_pickup_generated():
	# Brief flash when pickup is generated
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0, 1, 0, 1), 0.2)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0.8), 0.3)
