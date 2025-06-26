extends Node

## Testing Manager for Wedding Game
## Provides comprehensive debugging and testing tools for internal playtesting

signal test_event_logged(event_data: Dictionary)
signal debug_mode_changed(enabled: bool)

@export var debug_collision_enabled: bool = false
@export var debug_navigation_enabled: bool = false
@export var auto_capture_enabled: bool = false

var test_session_data: Dictionary = {}
var current_test_session: String = ""
var debug_overlay_enabled: bool = false
var debug_overlay_scene: Control = null

func _ready():
	# Initialize test session
	start_new_test_session()

	# Set up EngineDebugger message capture
	if EngineDebugger.is_active():
		EngineDebugger.register_message_capture("wedding_game_test", _capture_debug_message)

	# Connect to common game signals for automatic testing
	_setup_automatic_event_capture()

	# Load and add debug overlay
	_setup_debug_overlay()

func start_new_test_session(session_name: String = ""):
	if session_name.is_empty():
		session_name = "test_session_" + Time.get_datetime_string_from_system().replace(":", "-")

	current_test_session = session_name
	test_session_data = {
		"session_id": session_name,
		"start_time": Time.get_datetime_string_from_system(),
		"events": [],
		"performance_metrics": {},
		"user_actions": [],
		"debug_info": {}
	}

	log_test_event("session_started", {"session_id": session_name})
	print("[TestingManager] Started new test session: ", session_name)

func enable_debug_collisions(enabled: bool):
	debug_collision_enabled = enabled
	# Note: --debug-collisions is a command line flag, but we can enable collision shapes in-game
	get_tree().debug_collisions_hint = enabled
	log_test_event("debug_collisions_toggled", {"enabled": enabled})
	print("[TestingManager] Debug collisions: ", "enabled" if enabled else "disabled")

func enable_debug_navigation(enabled: bool):
	debug_navigation_enabled = enabled
	NavigationServer2D.set_debug_enabled(enabled)
	if Engine.has_singleton("NavigationServer3D"):
		NavigationServer3D.set_debug_enabled(enabled)
	log_test_event("debug_navigation_toggled", {"enabled": enabled})
	print("[TestingManager] Debug navigation: ", "enabled" if enabled else "disabled")

func toggle_debug_overlay():
	debug_overlay_enabled = !debug_overlay_enabled

	# Toggle the debug UI overlay
	if debug_overlay_scene:
		debug_overlay_scene.visible = debug_overlay_enabled

	# Get the main viewport and toggle debug draw
	var viewport = get_viewport()
	if viewport:
		if debug_overlay_enabled:
			viewport.debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
		else:
			viewport.debug_draw = Viewport.DEBUG_DRAW_DISABLED

	debug_mode_changed.emit(debug_overlay_enabled)
	log_test_event("debug_overlay_toggled", {"enabled": debug_overlay_enabled})
	print("[TestingManager] Debug overlay: ", "enabled" if debug_overlay_enabled else "disabled")

func simulate_input_event(action: String, pressed: bool = true):
	"""Simulate user input for automated testing"""
	var input_event = InputEventAction.new()
	input_event.action = action
	input_event.pressed = pressed

	Input.parse_input_event(input_event)
	log_test_event("input_simulated", {"action": action, "pressed": pressed})
	print("[TestingManager] Simulated input: ", action, " (pressed: ", pressed, ")")

func simulate_mouse_click(position: Vector2):
	"""Simulate mouse click at specific position"""
	var click_event = InputEventMouseButton.new()
	click_event.button_index = MOUSE_BUTTON_LEFT
	click_event.pressed = true
	click_event.position = position

	Input.parse_input_event(click_event)

	# Also send release event
	var release_event = InputEventMouseButton.new()
	release_event.button_index = MOUSE_BUTTON_LEFT
	release_event.pressed = false
	release_event.position = position

	Input.parse_input_event(release_event)
	log_test_event("mouse_click_simulated", {"position": position})

func log_test_event(event_type: String, event_data: Dictionary = {}):
	"""Log a test event with timestamp"""
	var full_event_data = {
		"timestamp": Time.get_datetime_string_from_system(),
		"type": event_type,
		"session_id": current_test_session,
		"data": event_data
	}

	test_session_data.events.append(full_event_data)
	test_event_logged.emit(full_event_data)

func log_user_action(action: String, context: Dictionary = {}):
	"""Log user actions for analysis"""
	var action_data = {
		"timestamp": Time.get_datetime_string_from_system(),
		"action": action,
		"context": context
	}

	test_session_data.user_actions.append(action_data)
	log_test_event("user_action", action_data)

func measure_performance_metric(metric_name: String, value: float):
	"""Record performance metrics"""
	if not test_session_data.performance_metrics.has(metric_name):
		test_session_data.performance_metrics[metric_name] = []

	test_session_data.performance_metrics[metric_name].append({
		"timestamp": Time.get_datetime_string_from_system(),
		"value": value
	})

	log_test_event("performance_metric", {"metric": metric_name, "value": value})

func export_test_session_data() -> String:
	"""Export current test session data as JSON"""
	test_session_data.end_time = Time.get_datetime_string_from_system()
	test_session_data.duration = Time.get_time_dict_from_system()

	var json_string = JSON.stringify(test_session_data, "\t")

	# Save to file
	var file_path = "user://test_sessions/" + current_test_session + ".json"
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("test_sessions"):
		dir.make_dir("test_sessions")

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("[TestingManager] Test session data exported to: ", file_path)

	return json_string

func _capture_debug_message(message: String, data: Array) -> bool:
	"""Capture debug messages from EngineDebugger"""
	log_test_event("debug_message", {"message": message, "data": data})
	print("[TestingManager] Debug message captured: ", message)
	return true

func _setup_automatic_event_capture():
	"""Set up automatic capture of common game events"""
	# Connect to scene tree signals
	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)

	# Monitor scene changes
	get_tree().tree_changed.connect(_on_tree_changed)

func _on_node_added(node: Node):
	if auto_capture_enabled:
		log_test_event("node_added", {"node_name": node.name, "node_type": node.get_class()})

func _on_node_removed(node: Node):
	if auto_capture_enabled:
		log_test_event("node_removed", {"node_name": node.name, "node_type": node.get_class()})

func _on_tree_changed():
	if auto_capture_enabled:
		log_test_event("scene_tree_changed", {})

# Input handling for debug shortcuts
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				toggle_debug_overlay()
			KEY_F2:
				enable_debug_collisions(!debug_collision_enabled)
			KEY_F3:
				enable_debug_navigation(!debug_navigation_enabled)
			KEY_F4:
				# Quick test: simulate random input
				var actions = ["ui_accept", "ui_cancel", "move_left", "move_right"]
				simulate_input_event(actions[randi() % actions.size()])
			KEY_F5:
				# Export current test session
				export_test_session_data()

# Wedding Game Specific Testing Functions
func test_wedding_mechanics():
	"""Run automated tests for wedding-specific game mechanics"""
	log_test_event("wedding_mechanics_test_started", {})

	# Test character interactions
	await test_character_dialogues()

	# Test wedding ring collection
	await test_item_collection()

	# Test boss fight mechanics
	await test_boss_fight()

	log_test_event("wedding_mechanics_test_completed", {})

func test_character_dialogues():
	"""Test dialogue system with wedding characters"""
	log_test_event("dialogue_test_started", {})

	# Simulate approaching different characters
	var characters = ["glen", "jenny", "mark", "hassan"]
	for character in characters:
		log_user_action("approach_character", {"character": character})
		simulate_input_event("ui_accept") # Start dialogue
		await get_tree().create_timer(1.0).timeout
		simulate_input_event("ui_cancel") # End dialogue
		await get_tree().create_timer(0.5).timeout

	log_test_event("dialogue_test_completed", {})

func test_item_collection():
	"""Test wedding ring and item collection mechanics"""
	log_test_event("item_collection_test_started", {})

	# Simulate moving to item locations and collecting
	simulate_input_event("move_right")
	await get_tree().create_timer(2.0).timeout
	simulate_input_event("ui_accept") # Collect item

	log_test_event("item_collection_test_completed", {})

func test_boss_fight():
	"""Test boss fight mechanics (Acids Joe)"""
	log_test_event("boss_fight_test_started", {})

	# Simulate combat actions
	for i in range(5):
		simulate_input_event("attack")
		await get_tree().create_timer(0.5).timeout
		simulate_input_event("move_left")
		await get_tree().create_timer(0.3).timeout
		simulate_input_event("move_right")
		await get_tree().create_timer(0.3).timeout

	log_test_event("boss_fight_test_completed", {})

func get_testing_report() -> Dictionary:
	"""Generate a comprehensive testing report"""
	return {
		"session_summary": {
			"session_id": current_test_session,
			"start_time": test_session_data.get("start_time", ""),
			"total_events": test_session_data.events.size(),
			"total_user_actions": test_session_data.user_actions.size()
		},
		"debug_status": {
			"collisions_enabled": debug_collision_enabled,
			"navigation_enabled": debug_navigation_enabled,
			"overlay_enabled": debug_overlay_enabled
		},
		"performance_metrics": test_session_data.performance_metrics,
		"recent_events": test_session_data.events.slice(-10) # Last 10 events
	}

func _setup_debug_overlay():
	"""Load and setup the debug overlay UI"""
	var debug_overlay_resource = preload("res://scenes/ui/DebugOverlay.tscn")
	if debug_overlay_resource:
		debug_overlay_scene = debug_overlay_resource.instantiate()

		# Add to the scene tree at the highest level to ensure it's always visible
		var main_scene = get_tree().current_scene
		if main_scene:
			main_scene.add_child(debug_overlay_scene)
			# Move to front to ensure it's always on top
			main_scene.move_child(debug_overlay_scene, -1)

		print("[TestingManager] Debug overlay UI loaded successfully")
