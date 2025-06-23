extends CanvasLayer
## Pause Menu Overlay System
## Handles game pause state and menu interactions

# Signals for pause menu actions
signal resume_requested
signal settings_requested
signal main_menu_requested

# UI references
@onready var background = $Background
@onready var pause_container = $PauseContainer
@onready var paused_label = $PauseContainer/PausedLabel
@onready var resume_button = $PauseContainer/ResumeButton
@onready var settings_button = $PauseContainer/SettingsButton
@onready var main_menu_button = $PauseContainer/MainMenuButton

# State
var is_paused: bool = false

func _ready() -> void:
	_setup_ui()
	_connect_signals()
	hide_pause_menu()
	
	# Set process mode to always so it works when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		toggle_pause()

func _setup_ui() -> void:
	# Set up semi-transparent background
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0, 0, 0, 0.7)  # Semi-transparent black
	
	# Center the pause container
	pause_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	pause_container.custom_minimum_size = Vector2(200, 250)
	
	# Set up text and buttons
	paused_label.text = "PAUSED"
	paused_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	resume_button.text = "Resume"
	settings_button.text = "Settings"
	main_menu_button.text = "Main Menu"
	
	# Set up container spacing
	pause_container.add_theme_constant_override("separation", 15)

func _connect_signals() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		pause_game()

func pause_game() -> void:
	is_paused = true
	get_tree().paused = true
	show_pause_menu()
	AudioManager.play_sfx("menu_select")

func resume_game() -> void:
	is_paused = false
	get_tree().paused = false
	hide_pause_menu()
	AudioManager.play_sfx("menu_back")

func show_pause_menu() -> void:
	show()
	resume_button.grab_focus()

func hide_pause_menu() -> void:
	hide()

func _on_resume_pressed() -> void:
	resume_game()
	resume_requested.emit()

func _on_settings_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	settings_requested.emit()

func _on_main_menu_pressed() -> void:
	AudioManager.play_sfx("menu_back")
	resume_game()  # Unpause before switching scenes
	main_menu_requested.emit()
	SceneTransition.change_scene("res://scenes/ui/MainMenu.tscn")