extends CanvasLayer
class_name HUD
## HUD (Heads Up Display) for showing player stats and game info
## Manages health/energy bars, inventory display, and notifications

signal pause_requested()

# Node references
@onready var happiness_bar: ProgressBar = $StatsContainer/HappinessContainer/HappinessBar
@onready var happiness_icon: TextureRect = $StatsContainer/HappinessContainer/HappinessIcon
@onready var happiness_label: Label = $StatsContainer/HappinessContainer/HappinessLabel
@onready var energy_bar: ProgressBar = $StatsContainer/EnergyContainer/EnergyBar
@onready var energy_icon: TextureRect = $StatsContainer/EnergyContainer/EnergyIcon
@onready var energy_label: Label = $StatsContainer/EnergyContainer/EnergyLabel
@onready var character_label: Label = $StatsContainer/CharacterLabel
@onready var inventory_container: HBoxContainer = $InventoryContainer
@onready var notification_label: Label = $NotificationLabel
@onready var objective_label: Label = $ObjectiveLabel
@onready var pause_button: Button = $PauseButton

# Inventory icons
var inventory_icons: Dictionary = {}

# Animation
var notification_tween: Tween

func _ready() -> void:
	# Connect to GameManager signals
	GameManager.happiness_changed.connect(_on_happiness_changed)
	GameManager.energy_changed.connect(_on_energy_changed)
	GameManager.inventory_changed.connect(_on_inventory_changed)
	GameManager.character_switched.connect(_on_character_switched)
	
	# Set up UI
	_setup_ui()
	
	# Update initial values
	_on_happiness_changed(GameManager.happiness)
	_on_energy_changed(GameManager.energy)
	_on_character_switched(GameManager.current_player)
	
	# Mobile controls removed - desktop only
	
	# Connect pause button
	if pause_button:
		pause_button.pressed.connect(_on_pause_pressed)

func _setup_ui() -> void:
	# Configure happiness bar
	happiness_bar.max_value = GameManager.MAX_HAPPINESS
	happiness_bar.value = GameManager.happiness
	happiness_bar.modulate = Color.GREEN
	
	# Configure energy bar
	energy_bar.max_value = GameManager.MAX_ENERGY
	energy_bar.value = GameManager.energy
	energy_bar.modulate = Color.CYAN
	
	# Set up icons (using emojis as placeholders)
	happiness_icon.texture = preload("res://assets/sprites/ui/happiness_icon.png")
	energy_icon.texture = preload("res://assets/sprites/ui/energy_icon.png")
	
	# Hide objective label initially
	objective_label.visible = false
	notification_label.visible = false

# Mobile controls removed - desktop only

func _on_happiness_changed(value: int) -> void:
	happiness_bar.value = value
	happiness_label.text = "%d/%d" % [value, GameManager.MAX_HAPPINESS]
	
	# Change bar color based on value
	if value > 50:
		happiness_bar.modulate = Color.GREEN
	elif value > 25:
		happiness_bar.modulate = Color.YELLOW
	else:
		happiness_bar.modulate = Color.RED
		# Flash when low
		var tween = create_tween()
		tween.set_loops(3)
		tween.tween_property(happiness_bar, "modulate:a", 0.5, 0.2)
		tween.tween_property(happiness_bar, "modulate:a", 1.0, 0.2)

func _on_energy_changed(value: int) -> void:
	energy_bar.value = value
	energy_label.text = "%d/%d" % [value, GameManager.MAX_ENERGY]
	
	# Change bar color based on value
	if value > 50:
		energy_bar.modulate = Color.CYAN
	elif value > 25:
		energy_bar.modulate = Color.YELLOW
	else:
		energy_bar.modulate = Color.RED

func _on_character_switched(character: String) -> void:
	character_label.text = "Playing as: " + character.to_upper()
	
	# Animate character label
	var tween = create_tween()
	tween.tween_property(character_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(character_label, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Update switch button visibility (disabled for now)
	# if switch_button:
	#	switch_button.visible = GameManager.has_jenny

func _on_inventory_changed(item: String, added: bool) -> void:
	if added:
		# Add item to inventory display
		var icon = TextureRect.new()
		icon.texture = load("res://assets/sprites/items/" + item + "_icon.png")
		icon.custom_minimum_size = Vector2(32, 32)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		inventory_container.add_child(icon)
		inventory_icons[item] = icon
		
		# Animate addition
		icon.scale = Vector2.ZERO
		var tween = create_tween()
		tween.tween_property(icon, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		
		# Show notification
		show_notification("Obtained " + item.capitalize() + "!")
	else:
		# Remove item from inventory display
		if item in inventory_icons:
			var icon = inventory_icons[item]
			inventory_icons.erase(item)
			
			# Animate removal
			var tween = create_tween()
			tween.tween_property(icon, "scale", Vector2.ZERO, 0.2)
			tween.finished.connect(icon.queue_free)

func show_notification(text: String, duration: float = 3.0) -> void:
	# Cancel previous notification animation
	if notification_tween and notification_tween.is_running():
		notification_tween.kill()
	
	notification_label.text = text
	notification_label.visible = true
	notification_label.modulate.a = 0.0
	
	# Animate notification
	notification_tween = create_tween()
	notification_tween.tween_property(notification_label, "modulate:a", 1.0, 0.3)
	notification_tween.tween_interval(duration)
	notification_tween.tween_property(notification_label, "modulate:a", 0.0, 0.3)
	notification_tween.finished.connect(func(): notification_label.visible = false)

func show_objective(text: String) -> void:
	objective_label.text = "🎯 " + text
	objective_label.visible = true
	
	# Pulse animation
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(objective_label, "scale", Vector2(1.05, 1.05), 0.5)
	tween.tween_property(objective_label, "scale", Vector2(1.0, 1.0), 0.5)

func hide_objective() -> void:
	var tween = create_tween()
	tween.tween_property(objective_label, "modulate:a", 0.0, 0.3)
	tween.finished.connect(func(): 
		objective_label.visible = false
		objective_label.modulate.a = 1.0
	)

func _on_pause_pressed() -> void:
	pause_requested.emit()

# Mobile control helpers
func get_mobile_input() -> Dictionary:
	# Mobile controls removed - desktop only
	return {}

# Debug display
func show_debug_info(info: Dictionary) -> void:
	if not OS.is_debug_build():
		return
	
	# Create debug label if it doesn't exist
	if not has_node("DebugLabel"):
		var debug_label = Label.new()
		debug_label.name = "DebugLabel"
		debug_label.add_theme_color_override("font_color", Color.YELLOW)
		debug_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		debug_label.position = Vector2(10, 200)
		add_child(debug_label)
	
	var debug_label = $DebugLabel
	var debug_text = "=== DEBUG ===\n"
	for key in info:
		debug_text += "%s: %s\n" % [key, info[key]]
	debug_label.text = debug_text