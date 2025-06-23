extends Control
class_name PauseMenu
## Pause Menu - Handles game pausing and in-game options
## Can be added to any scene that needs pause functionality

signal resumed()
signal quit_to_menu()
signal settings_changed()

# Node references
@onready var pause_overlay: ColorRect = $PauseOverlay
@onready var menu_panel: Panel = $MenuPanel
@onready var title_label: Label = $MenuPanel/TitleLabel
@onready var button_container: VBoxContainer = $MenuPanel/ButtonContainer
@onready var resume_button: Button = $MenuPanel/ButtonContainer/ResumeButton
@onready var settings_button: Button = $MenuPanel/ButtonContainer/SettingsButton
@onready var save_button: Button = $MenuPanel/ButtonContainer/SaveButton
@onready var quit_button: Button = $MenuPanel/ButtonContainer/QuitButton
@onready var settings_panel: Panel = $SettingsPanel
@onready var settings_back_button: Button = $SettingsPanel/BackButton

# Audio sliders
@onready var master_slider: HSlider = $SettingsPanel/VBoxContainer/MasterVolume/Slider
@onready var music_slider: HSlider = $SettingsPanel/VBoxContainer/MusicVolume/Slider
@onready var sfx_slider: HSlider = $SettingsPanel/VBoxContainer/SFXVolume/Slider

# State
var is_paused: bool = false
var previous_time_scale: float = 1.0

func _ready() -> void:
	# Hide by default
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Setup UI
	_setup_ui()
	
	# Connect buttons
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	save_button.pressed.connect(_on_save_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	settings_back_button.pressed.connect(_on_settings_back_pressed)
	
	# Connect sliders
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Set initial slider values
	master_slider.value = AudioManager.master_volume
	music_slider.value = AudioManager.music_volume
	sfx_slider.value = AudioManager.sfx_volume

func _setup_ui() -> void:
	# Set up pause overlay
	pause_overlay.color = Color(0, 0, 0, 0.7)
	pause_overlay.size = get_viewport_rect().size
	
	# Center menu panel
	menu_panel.size = Vector2(400, 300)
	menu_panel.position = (get_viewport_rect().size - menu_panel.size) / 2
	
	# Title
	title_label.text = "PAUSED"
	title_label.add_theme_font_size_override("font_size", 32)
	
	# Style buttons
	for button in button_container.get_children():
		if button is Button:
			button.add_theme_font_size_override("font_size", 20)
			button.custom_minimum_size = Vector2(200, 40)
	
	# Hide settings panel initially
	settings_panel.visible = false
	settings_panel.size = Vector2(400, 400)
	settings_panel.position = (get_viewport_rect().size - settings_panel.size) / 2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused:
			resume()
		else:
			pause()

func pause() -> void:
	if is_paused:
		return
	
	is_paused = true
	visible = true
	
	# Store current time scale and pause
	previous_time_scale = Engine.time_scale
	get_tree().paused = true
	
	# Focus first button
	resume_button.grab_focus()
	
	# Play pause sound
	AudioManager.play_sfx("menu_pause")

func resume() -> void:
	if not is_paused:
		return
	
	is_paused = false
	visible = false
	
	# Restore time scale and unpause
	Engine.time_scale = previous_time_scale
	get_tree().paused = false
	
	resumed.emit()
	
	# Play resume sound
	AudioManager.play_sfx("menu_resume")

func _on_resume_pressed() -> void:
	resume()

func _on_settings_pressed() -> void:
	menu_panel.visible = false
	settings_panel.visible = true
	
	# Update slider values
	master_slider.value = AudioManager.master_volume
	music_slider.value = AudioManager.music_volume
	sfx_slider.value = AudioManager.sfx_volume

func _on_settings_back_pressed() -> void:
	settings_panel.visible = false
	menu_panel.visible = true
	
	# Save settings
	SaveGame.save_settings()
	settings_changed.emit()

func _on_save_pressed() -> void:
	# Save current game state
	var success = SaveGame.save_game()
	
	# Show feedback
	if success:
		_show_save_notification("Game Saved!", Color.GREEN)
	else:
		_show_save_notification("Save Failed!", Color.RED)

func _on_quit_pressed() -> void:
	# Show confirmation dialog
	_show_quit_confirmation()

func _show_quit_confirmation() -> void:
	var confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.dialog_text = "Return to main menu?\n\nUnsaved progress will be lost!"
	confirm_dialog.ok_button_text = "Quit"
	confirm_dialog.cancel_button_text = "Cancel"
	
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()
	
	confirm_dialog.confirmed.connect(func():
		resume()  # Unpause first
		quit_to_menu.emit()
		get_tree().paused = false
		SceneTransition.change_scene("res://scenes/ui/MainMenu.tscn")
		confirm_dialog.queue_free()
	)
	
	confirm_dialog.canceled.connect(func():
		confirm_dialog.queue_free()
	)

func _show_save_notification(text: String, color: Color) -> void:
	var notification = Label.new()
	notification.text = text
	notification.add_theme_font_size_override("font_size", 24)
	notification.add_theme_color_override("font_color", color)
	notification.position = Vector2(200, 400)
	menu_panel.add_child(notification)
	
	# Fade out
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(notification, "modulate:a", 0.0, 0.5)
	tween.tween_callback(notification.queue_free)

# Audio settings handlers
func _on_master_volume_changed(value: float) -> void:
	AudioManager.master_volume = value
	
	# Visual feedback
	if value == 0:
		$SettingsPanel/VBoxContainer/MasterVolume/Icon.text = "🔇"
	else:
		$SettingsPanel/VBoxContainer/MasterVolume/Icon.text = "🔊"

func _on_music_volume_changed(value: float) -> void:
	AudioManager.music_volume = value
	
	# Test sound
	if not $SettingsPanel/MusicTestTimer.is_stopped():
		return
	
	$SettingsPanel/MusicTestTimer.start(0.5)

func _on_sfx_volume_changed(value: float) -> void:
	AudioManager.sfx_volume = value
	
	# Play test sound
	AudioManager.play_sfx("menu_select")

# Create the settings panel UI in code
func _create_settings_ui() -> void:
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(20, 60)
	settings_panel.add_child(vbox)
	
	# Title
	var settings_title = Label.new()
	settings_title.text = "Settings"
	settings_title.add_theme_font_size_override("font_size", 28)
	vbox.add_child(settings_title)
	
	vbox.add_child(HSeparator.new())
	
	# Master Volume
	var master_container = HBoxContainer.new()
	vbox.add_child(master_container)
	
	var master_icon = Label.new()
	master_icon.text = "🔊"
	master_icon.custom_minimum_size = Vector2(30, 30)
	master_container.add_child(master_icon)
	
	var master_label = Label.new()
	master_label.text = "Master Volume"
	master_label.custom_minimum_size = Vector2(150, 30)
	master_container.add_child(master_label)
	
	master_slider = HSlider.new()
	master_slider.custom_minimum_size = Vector2(150, 30)
	master_slider.max_value = 1.0
	master_slider.step = 0.05
	master_slider.value = AudioManager.master_volume
	master_container.add_child(master_slider)
	
	# Music Volume
	var music_container = HBoxContainer.new()
	vbox.add_child(music_container)
	
	var music_icon = Label.new()
	music_icon.text = "🎵"
	music_icon.custom_minimum_size = Vector2(30, 30)
	music_container.add_child(music_icon)
	
	var music_label = Label.new()
	music_label.text = "Music Volume"
	music_label.custom_minimum_size = Vector2(150, 30)
	music_container.add_child(music_label)
	
	music_slider = HSlider.new()
	music_slider.custom_minimum_size = Vector2(150, 30)
	music_slider.max_value = 1.0
	music_slider.step = 0.05
	music_slider.value = AudioManager.music_volume
	music_container.add_child(music_slider)
	
	# SFX Volume
	var sfx_container = HBoxContainer.new()
	vbox.add_child(sfx_container)
	
	var sfx_icon = Label.new()
	sfx_icon.text = "💥"
	sfx_icon.custom_minimum_size = Vector2(30, 30)
	sfx_container.add_child(sfx_icon)
	
	var sfx_label = Label.new()
	sfx_label.text = "SFX Volume"
	sfx_label.custom_minimum_size = Vector2(150, 30)
	sfx_container.add_child(sfx_label)
	
	sfx_slider = HSlider.new()
	sfx_slider.custom_minimum_size = Vector2(150, 30)
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.05
	sfx_slider.value = AudioManager.sfx_volume
	sfx_container.add_child(sfx_slider)
	
	# Music test timer
	var music_test_timer = Timer.new()
	music_test_timer.name = "MusicTestTimer"
	music_test_timer.one_shot = true
	settings_panel.add_child(music_test_timer)