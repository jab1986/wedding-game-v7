extends CanvasLayer
## SceneTransition - Handles smooth transitions between scenes
## Provides various transition effects (fade, slide, etc.)

signal transition_finished()

enum TransitionType {
	FADE_BLACK,
	FADE_WHITE,
	SLIDE_LEFT,
	SLIDE_RIGHT,
	CIRCLE_WIPE,
	DIAMOND_WIPE
}

# Node references
@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Transition state
var is_transitioning: bool = false
var next_scene_path: String = ""
var transition_speed: float = 1.0

func _ready() -> void:
	# Ensure transition layer is on top
	layer = 10
	
	# Hide transition overlay initially
	color_rect.visible = false
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Create animation player if not in scene
	if not animation_player:
		animation_player = AnimationPlayer.new()
		add_child(animation_player)
		_create_default_animations()

func _create_default_animations() -> void:
	# Create fade to black animation
	var fade_black = Animation.new()
	fade_black.length = 1.0
	
	var track_idx = fade_black.add_track(Animation.TYPE_VALUE)
	fade_black.track_set_path(track_idx, NodePath("ColorRect:modulate:a"))
	fade_black.track_insert_key(track_idx, 0.0, 0.0)
	fade_black.track_insert_key(track_idx, 1.0, 1.0)
	
	animation_player.add_animation("fade_to_black", fade_black)
	
	# Create fade from black animation
	var fade_from = Animation.new()
	fade_from.length = 1.0
	
	track_idx = fade_from.add_track(Animation.TYPE_VALUE)
	fade_from.track_set_path(track_idx, NodePath("ColorRect:modulate:a"))
	fade_from.track_insert_key(track_idx, 0.0, 1.0)
	fade_from.track_insert_key(track_idx, 1.0, 0.0)
	
	animation_player.add_animation("fade_from_black", fade_from)

## Change to a new scene with transition
func change_scene(scene_path: String, transition: TransitionType = TransitionType.FADE_BLACK) -> void:
	if is_transitioning:
		push_warning("Transition already in progress!")
		return
	
	is_transitioning = true
	next_scene_path = scene_path
	
	# Start transition out
	_transition_out(transition)

## Change scene with custom transition settings
func change_scene_custom(scene_path: String, settings: Dictionary) -> void:
	if is_transitioning:
		return
	
	var transition = settings.get("type", TransitionType.FADE_BLACK)
	transition_speed = settings.get("speed", 1.0)
	
	# Custom color for fade
	if settings.has("color"):
		color_rect.color = settings["color"]
	
	change_scene(scene_path, transition)

## Reload current scene with transition
func reload_scene(transition: TransitionType = TransitionType.FADE_BLACK) -> void:
	var current_scene = get_tree().current_scene.scene_file_path
	change_scene(current_scene, transition)

## Quick fade (useful for deaths/resets)
func quick_fade(duration: float = 0.3) -> void:
	color_rect.visible = true
	color_rect.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	tween.tween_interval(0.1)
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)
	tween.finished.connect(func(): color_rect.visible = false)

## Flash effect (for impacts, powerups, etc.)
func flash(color: Color = Color.WHITE, duration: float = 0.2) -> void:
	color_rect.color = color
	color_rect.visible = true
	color_rect.modulate.a = 0.8
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)
	tween.finished.connect(func(): color_rect.visible = false)

func _transition_out(type: TransitionType) -> void:
	color_rect.visible = true
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	match type:
		TransitionType.FADE_BLACK:
			color_rect.color = Color.BLACK
			animation_player.play("fade_to_black", -1, transition_speed)
		
		TransitionType.FADE_WHITE:
			color_rect.color = Color.WHITE
			animation_player.play("fade_to_black", -1, transition_speed)
		
		TransitionType.SLIDE_LEFT:
			_slide_transition(Vector2(-get_viewport().size.x, 0))
		
		TransitionType.SLIDE_RIGHT:
			_slide_transition(Vector2(get_viewport().size.x, 0))
		
		TransitionType.CIRCLE_WIPE:
			_circle_wipe_out()
		
		TransitionType.DIAMOND_WIPE:
			_diamond_wipe_out()
	
	# Wait for transition to complete
	await animation_player.animation_finished
	_load_next_scene()

func _transition_in(type: TransitionType) -> void:
	match type:
		TransitionType.FADE_BLACK, TransitionType.FADE_WHITE:
			animation_player.play("fade_from_black", -1, transition_speed)
		
		TransitionType.SLIDE_LEFT:
			_slide_transition(Vector2(0, 0), Vector2(get_viewport().size.x, 0))
		
		TransitionType.SLIDE_RIGHT:
			_slide_transition(Vector2(0, 0), Vector2(-get_viewport().size.x, 0))
		
		TransitionType.CIRCLE_WIPE:
			_circle_wipe_in()
		
		TransitionType.DIAMOND_WIPE:
			_diamond_wipe_in()
	
	# Wait for transition to complete
	await animation_player.animation_finished
	
	# Hide overlay and complete
	color_rect.visible = false
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
	transition_finished.emit()

func _load_next_scene() -> void:
	# Change the scene
	get_tree().change_scene_to_file(next_scene_path)
	
	# Small delay to ensure scene is loaded
	await get_tree().process_frame
	
	# Transition in
	_transition_in(TransitionType.FADE_BLACK) # Use same type as out transition

func _slide_transition(to_position: Vector2, from_position: Vector2 = Vector2.ZERO) -> void:
	color_rect.position = from_position
	
	var tween = create_tween()
	tween.tween_property(color_rect, "position", to_position, 0.5 / transition_speed)
	
	await tween.finished

func _circle_wipe_out() -> void:
	# This would use a shader for circular wipe effect
	# For now, just fade
	animation_player.play("fade_to_black", -1, transition_speed)

func _circle_wipe_in() -> void:
	# This would use a shader for circular wipe effect
	# For now, just fade
	animation_player.play("fade_from_black", -1, transition_speed)

func _diamond_wipe_out() -> void:
	# This would use a shader for diamond wipe effect
	# For now, just fade
	animation_player.play("fade_to_black", -1, transition_speed)

func _diamond_wipe_in() -> void:
	# This would use a shader for diamond wipe effect
	# For now, just fade
	animation_player.play("fade_from_black", -1, transition_speed)

## Get transition progress (0.0 to 1.0)
func get_progress() -> float:
	if not is_transitioning or not animation_player.is_playing():
		return 0.0
	
	return animation_player.current_animation_position / animation_player.current_animation_length