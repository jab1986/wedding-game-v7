extends Node
class_name CameraManager
## Manages dynamic camera system using Phantom Camera
## Handles player following, cutscenes, and dramatic moments

signal camera_transitioned(from_camera: String, to_camera: String)
signal cutscene_started()
signal cutscene_ended()

# Camera references
var player_camera: Camera2D
var cutscene_cameras := {}
var current_camera_name: String = "player"

# Camera settings
var follow_smoothing: float = 5.0
var zoom_speed: float = 2.0
var shake_intensity: float = 0.0
var shake_duration: float = 0.0

func _ready():
	print("Camera Manager initialized")

## Setup the main player following camera
func setup_player_camera(player: Node2D) -> void:
	# Create or find the player camera
	if not player_camera:
		player_camera = Camera2D.new()
		player_camera.name = "PlayerCamera"
		player.add_child(player_camera)
	
	# Configure camera settings
	player_camera.enabled = true
	player_camera.position_smoothing_enabled = true
	player_camera.position_smoothing_speed = follow_smoothing
	
	# Set default zoom for pixel art
	player_camera.zoom = Vector2(2.0, 2.0)
	
	print("Player camera setup complete")

## Create a cutscene camera at specific position
func create_cutscene_camera(name: String, position: Vector2, zoom: Vector2 = Vector2.ONE) -> Camera2D:
	var camera = Camera2D.new()
	camera.name = name + "Camera"
	camera.global_position = position
	camera.zoom = zoom
	camera.enabled = false
	
	# Add to scene tree
	get_tree().current_scene.add_child(camera)
	cutscene_cameras[name] = camera
	
	print("Created cutscene camera: %s at %s" % [name, position])
	return camera

## Switch to a specific camera
func switch_to_camera(camera_name: String, transition_duration: float = 1.0) -> void:
	var from_camera = current_camera_name
	
	# Disable current camera
	match current_camera_name:
		"player":
			if player_camera:
				player_camera.enabled = false
		_:
			if current_camera_name in cutscene_cameras:
				cutscene_cameras[current_camera_name].enabled = false
	
	# Enable target camera
	match camera_name:
		"player":
			if player_camera:
				player_camera.enabled = true
				player_camera.make_current()
		_:
			if camera_name in cutscene_cameras:
				cutscene_cameras[camera_name].enabled = true
				cutscene_cameras[camera_name].make_current()
	
	current_camera_name = camera_name
	camera_transitioned.emit(from_camera, camera_name)
	print("Switched camera from %s to %s" % [from_camera, camera_name])

## Start a cutscene with camera movement
func start_cutscene(camera_positions: Array, durations: Array = []) -> void:
	cutscene_started.emit()
	
	# Pause player input during cutscene
	get_tree().call_group("player", "set_input_enabled", false)
	
	# Create and move through camera positions
	for i in range(camera_positions.size()):
		var pos = camera_positions[i]
		var duration = durations[i] if i < durations.size() else 2.0
		
		var cutscene_cam = create_cutscene_camera("cutscene_%d" % i, pos)
		switch_to_camera("cutscene_%d" % i)
		
		await get_tree().create_timer(duration).timeout
	
	# Return to player camera
	end_cutscene()

## End cutscene and return to player
func end_cutscene() -> void:
	# Re-enable player input
	get_tree().call_group("player", "set_input_enabled", true)
	
	# Clean up cutscene cameras
	for camera_name in cutscene_cameras:
		if "cutscene_" in camera_name:
			cutscene_cameras[camera_name].queue_free()
			cutscene_cameras.erase(camera_name)
	
	# Return to player camera
	switch_to_camera("player")
	cutscene_ended.emit()
	print("Cutscene ended")

## Camera shake effect for impacts
func shake_camera(intensity: float, duration: float) -> void:
	shake_intensity = intensity
	shake_duration = duration
	
	# Create shake effect
	var original_pos = player_camera.offset
	var shake_timer = 0.0
	
	while shake_timer < duration:
		var shake_x = randf_range(-intensity, intensity)
		var shake_y = randf_range(-intensity, intensity)
		player_camera.offset = Vector2(shake_x, shake_y)
		
		shake_timer += get_process_delta_time()
		await get_tree().process_frame
	
	# Reset camera position
	player_camera.offset = original_pos
	shake_intensity = 0.0
	shake_duration = 0.0

## Zoom camera for dramatic effect
func zoom_to(target_zoom: Vector2, duration: float = 1.0) -> void:
	if not player_camera:
		return
	
	var tween = create_tween()
	tween.tween_property(player_camera, "zoom", target_zoom, duration)
	await tween.finished

## Special camera movements for wedding moments
func wedding_ceremony_shot() -> void:
	# Wide shot of ceremony
	zoom_to(Vector2(1.0, 1.0), 2.0)
	await get_tree().create_timer(3.0).timeout
	zoom_to(Vector2(2.0, 2.0), 1.0)

func boss_fight_camera() -> void:
	# Dynamic camera for boss fights
	zoom_to(Vector2(1.5, 1.5), 0.5)
	shake_camera(5.0, 0.3)

func romantic_moment_camera() -> void:
	# Close-up for romantic moments
	zoom_to(Vector2(3.0, 3.0), 1.5)
	await get_tree().create_timer(2.0).timeout
	zoom_to(Vector2(2.0, 2.0), 1.0)

## Update camera smoothing
func set_follow_smoothing(smoothing: float) -> void:
	follow_smoothing = smoothing
	if player_camera:
		player_camera.position_smoothing_speed = smoothing

## Set camera limits for level boundaries
func set_camera_limits(left: int, top: int, right: int, bottom: int) -> void:
	if player_camera:
		player_camera.limit_left = left
		player_camera.limit_top = top
		player_camera.limit_right = right
		player_camera.limit_bottom = bottom
		player_camera.limit_smoothed = true