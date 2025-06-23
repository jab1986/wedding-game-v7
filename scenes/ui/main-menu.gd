extends Control
## Main Menu scene - Entry point for the game
## Handles menu navigation and game start

signal start_game()
signal continue_game()
signal show_options()
signal quit_game()

# Scene paths
const AMSTERDAM_SCENE := "res://scenes/levels/AmsterdamLevel.tscn"
const OPTIONS_SCENE := "res://scenes/ui/OptionsMenu.tscn"

# Node references
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $VBoxContainer/SubtitleLabel
@onready var menu_container: VBoxContainer = $VBoxContainer/MenuContainer
@onready var start_button: Button = $VBoxContainer/MenuContainer/StartButton
@onready var continue_button: Button = $VBoxContainer/MenuContainer/ContinueButton
@onready var options_button: Button = $VBoxContainer/MenuContainer/OptionsButton
@onready var quit_button: Button = $VBoxContainer/MenuContainer/QuitButton
@onready var version_label: Label = $VersionLabel
@onready var background: TextureRect = $Background
@onready var characters_preview: Node2D = $CharactersPreview
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Menu state
var can_continue: bool = false
var is_transitioning: bool = false

func _ready() -> void:
	# Set up UI
	_setup_ui()
	
	# Connect buttons
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Check for save file
	can_continue = FileAccess.file_exists(GameManager.SAVE_PATH)
	continue_button.disabled = not can_continue
	
	# Play intro animation
	if animation_player:
		animation_player.play("intro")
	
	# Set version
	version_label.text = "v" + ProjectSettings.get_setting("application/config/version", "1.0.0")
	
	# Focus first button
	start_button.grab_focus()
	
	# Create background effects
	_create_background_effects()
	
	# Add character previews
	_create_character_previews()

func _setup_ui() -> void:
	# Title styling
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	title_label.add_theme_constant_override("shadow_offset_x", 4)
	title_label.add_theme_constant_override("shadow_offset_y", 4)
	
	# Subtitle styling
	subtitle_label.add_theme_font_size_override("font_size", 18)
	subtitle_label.add_theme_color_override("font_color", Color.YELLOW)
	
	# Button styling
	for button in menu_container.get_children():
		if button is Button:
			button.add_theme_font_size_override("font_size", 24)
			button.mouse_entered.connect(_on_button_hover.bind(button))
			button.focus_entered.connect(_on_button_focus.bind(button))

func _create_background_effects() -> void:
	# Create gradient background
	var gradient_rect = ColorRect.new()
	gradient_rect.size = get_viewport_rect().size
	gradient_rect.z_index = -2
	
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0.53, 0.81, 0.92))  # Sky blue
	gradient.add_point(1.0, Color(1.0, 0.89, 0.88))   # Pink
	
	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill_to = Vector2(0, 1)
	
	# Can't directly apply gradient to ColorRect, so we'll use a shader
	add_child(gradient_rect)
	move_child(gradient_rect, 0)
	
	# Add floating hearts
	for i in range(10):
		_create_floating_heart()

func _create_floating_heart() -> void:
	var heart = Label.new()
	heart.text = "❤️"
	heart.add_theme_font_size_override("font_size", randi_range(16, 32))
	heart.modulate.a = 0.3
	heart.position = Vector2(
		randf_range(0, get_viewport_rect().size.x),
		randf_range(0, get_viewport_rect().size.y)
	)
	add_child(heart)
	
	# Animate floating
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(heart, "position:y", heart.position.y - 50, 3.0)
	tween.tween_property(heart, "position:y", heart.position.y, 3.0)

func _create_character_previews() -> void:
	if not characters_preview:
		characters_preview = Node2D.new()
		add_child(characters_preview)
	
	var viewport_size = get_viewport_rect().size
	var preview_y = viewport_size.y - 120
	
	# Create Mark sprite
	var mark_sprite = AnimatedSprite2D.new()
	mark_sprite.sprite_frames = load("res://assets/sprites/characters/mark/mark_frames.tres")
	mark_sprite.play("idle")
	mark_sprite.position = Vector2(viewport_size.x / 2 - 50, preview_y)
	characters_preview.add_child(mark_sprite)
	
	# Create Jenny sprite
	var jenny_sprite = AnimatedSprite2D.new()
	jenny_sprite.sprite_frames = load("res://assets/sprites/characters/jenny/jenny_frames.tres")
	jenny_sprite.play("idle")
	jenny_sprite.position = Vector2(viewport_size.x / 2 + 50, preview_y)
	characters_preview.add_child(jenny_sprite)
	
	# Add labels
	var mark_label = Label.new()
	mark_label.text = "Mark"
	mark_label.position = mark_sprite.position + Vector2(0, 25)
	mark_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	characters_preview.add_child(mark_label)
	
	var jenny_label = Label.new()
	jenny_label.text = "Jenny"
	jenny_label.position = jenny_sprite.position + Vector2(0, 25)
	jenny_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	characters_preview.add_child(jenny_label)
	
	# Animate them
	var tween = create_tween()
	tween.set_loops()
	tween.set_parallel()
	tween.tween_property(mark_sprite, "position:y", preview_y - 10, 1.0).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(jenny_sprite, "position:y", preview_y - 10, 1.0).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property(mark_sprite, "position:y", preview_y, 1.0).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(jenny_sprite, "position:y", preview_y, 1.0).set_ease(Tween.EASE_IN_OUT)

func _on_button_hover(button: Button) -> void:
	# Scale effect on hover
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)

func _on_button_focus(button: Button) -> void:
	# Same effect for gamepad/keyboard navigation
	_on_button_hover(button)

func _on_start_pressed() -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	start_game.emit()
	
	# Reset game state
	GameManager.reset_game()
	
	# Play sound
	AudioManager.play_sfx("menu_select")
	
	# Transition to first level
	SceneTransition.change_scene(AMSTERDAM_SCENE)

func _on_continue_pressed() -> void:
	if is_transitioning or not can_continue:
		return
	
	is_transitioning = true
	continue_game.emit()
	
	# Load saved game
	if GameManager.load_game():
		# Play sound
		AudioManager.play_sfx("menu_select")
		
		# Load the saved level
		var level_path = "res://scenes/levels/" + GameManager.current_level + ".tscn"
		if ResourceLoader.exists(level_path):
			SceneTransition.change_scene(level_path)
		else:
			# Fallback to first level
			SceneTransition.change_scene(AMSTERDAM_SCENE)
	else:
		push_error("Failed to load save game!")
		is_transitioning = false

func _on_options_pressed() -> void:
	if is_transitioning:
		return
	
	show_options.emit()
	
	# Play sound
	AudioManager.play_sfx("menu_select")
	
	# For now, just show a message
	# In a full game, this would open an options menu
	print("Options menu not implemented yet!")

func _on_quit_pressed() -> void:
	if is_transitioning:
		return
	
	quit_game.emit()
	
	# Play sound
	AudioManager.play_sfx("menu_select")
	
	# Quit the game
	get_tree().quit()

func _input(event: InputEvent) -> void:
	# Handle menu navigation with keyboard/gamepad
	if event.is_action_pressed("ui_cancel"):
		if get_viewport().gui_get_focus_owner() != null:
			get_viewport().gui_release_focus()
		else:
			_on_quit_pressed()
	
	# Quick start for development
	if OS.is_debug_build() and event.is_action_pressed("ui_page_down"):
		print("Debug: Quick starting game")
		_on_start_pressed()

# Handle button animations when losing focus
func _notification(what: int) -> void:
	if what == NOTIFICATION_FOCUS_EXIT:
		# Reset all button scales
		for button in menu_container.get_children():
			if button is Button:
				button.scale = Vector2.ONE