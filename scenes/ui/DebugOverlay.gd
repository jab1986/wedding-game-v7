extends Control

## Debug Overlay UI for Wedding Game Testing
## Displays real-time debug information and testing metrics

@onready var fps_label = $Panel/VBoxContainer/FPSLabel
@onready var memory_label = $Panel/VBoxContainer/MemoryLabel
@onready var session_label = $Panel/VBoxContainer/SessionLabel
@onready var events_label = $Panel/VBoxContainer/EventsLabel
@onready var collision_label = $Panel/VBoxContainer/CollisionLabel
@onready var navigation_label = $Panel/VBoxContainer/NavigationLabel

var update_timer: Timer

func _ready():
	# Initially hide the overlay
	visible = false

	# Create update timer
	update_timer = Timer.new()
	update_timer.wait_time = 0.5 # Update every 0.5 seconds
	update_timer.timeout.connect(_update_debug_info)
	add_child(update_timer)
	update_timer.start()

	# Connect to TestingManager signals
	if TestingManager:
		TestingManager.debug_mode_changed.connect(_on_debug_mode_changed)
		TestingManager.test_event_logged.connect(_on_test_event_logged)

func _update_debug_info():
	if not visible:
		return

	# Update FPS
	var fps = Engine.get_frames_per_second()
	fps_label.text = "FPS: " + str(fps)
	if fps < 30:
		fps_label.modulate = Color.RED
	elif fps < 50:
		fps_label.modulate = Color.YELLOW
	else:
		fps_label.modulate = Color.WHITE

	# Update Memory Usage
	var memory_mb = OS.get_static_memory_usage() / 1024.0 / 1024.0
	memory_label.text = "Memory: " + str("%.1f" % memory_mb) + " MB"

	# Update TestingManager info if available
	if TestingManager:
		session_label.text = "Session: " + TestingManager.current_test_session
		events_label.text = "Events: " + str(TestingManager.test_session_data.get("events", []).size())

		# Update debug status
		collision_label.text = "Collisions: " + ("ON" if TestingManager.debug_collision_enabled else "OFF")
		collision_label.modulate = Color.GREEN if TestingManager.debug_collision_enabled else Color.RED

		navigation_label.text = "Navigation: " + ("ON" if TestingManager.debug_navigation_enabled else "OFF")
		navigation_label.modulate = Color.GREEN if TestingManager.debug_navigation_enabled else Color.RED

func _on_debug_mode_changed(enabled: bool):
	# This is called when F1 is pressed to toggle debug overlay
	visible = enabled

func _on_test_event_logged(event_data: Dictionary):
	# Flash the events label when new events are logged
	if visible:
		var tween = create_tween()
		tween.tween_property(events_label, "modulate", Color.YELLOW, 0.1)
		tween.tween_property(events_label, "modulate", Color.WHITE, 0.1)

func show_overlay():
	visible = true

func hide_overlay():
	visible = false

func toggle_overlay():
	visible = !visible
