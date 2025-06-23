extends Control
## Main Menu UI System
## Handles navigation, settings, and game flow

# Signals for scene transitions
signal new_game_requested
signal load_game_requested
signal settings_requested
signal quit_requested

# References to UI elements
@onready var title_label = $MenuContainer/TitleLabel
@onready var new_game_button = $MenuContainer/NewGameButton
@onready var load_game_button = $MenuContainer/LoadGameButton
@onready var settings_button = $MenuContainer/SettingsButton
@onready var quit_button = $MenuContainer/QuitButton
@onready var menu_container = $MenuContainer

func _ready() -> void:
	_setup_ui()
	_connect_signals()
	_start_menu_music()

func _setup_ui() -> void:
	# Set up title
	title_label.text = "Mark & Jenny's\nWedding Adventure"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Set up buttons
	new_game_button.text = "New Game"
	load_game_button.text = "Load Game"
	settings_button.text = "Settings"
	quit_button.text = "Quit"
	
	# Center the menu container
	menu_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	menu_container.custom_minimum_size = Vector2(200, 300)
	
	# Set up container spacing
	menu_container.add_theme_constant_override("separation", 20)

func _connect_signals() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _start_menu_music() -> void:
	if AudioManager:
		AudioManager.play_music("menu_theme")

func _on_new_game_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	new_game_requested.emit()
	# Example transition to first level
	SceneTransition.change_scene("res://scenes/levels/GlenHouseLevel.tscn")

func _on_load_game_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	load_game_requested.emit()

func _on_settings_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	settings_requested.emit()

func _on_quit_pressed() -> void:
	AudioManager.play_sfx("menu_back")
	quit_requested.emit()
	get_tree().quit()

# Called when returning to main menu
func show_menu() -> void:
	show()
	_start_menu_music()

func hide_menu() -> void:
	hide()