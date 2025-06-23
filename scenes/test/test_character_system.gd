extends Node2D
## Test script for character system validation

@onready var player: Player = $Player
@onready var happiness_label: Label = $UI/StatsPanel/VBoxContainer/HappinessLabel
@onready var energy_label: Label = $UI/StatsPanel/VBoxContainer/EnergyLabel
@onready var character_label: Label = $UI/StatsPanel/VBoxContainer/CharacterLabel

func _ready():
	# Connect to GameManager signals
	GameManager.happiness_changed.connect(_on_happiness_changed)
	GameManager.energy_changed.connect(_on_energy_changed)
	GameManager.character_switched.connect(_on_character_switched)
	
	# Enable Jenny for testing
	GameManager.has_jenny = true
	
	# Update initial display
	_update_ui()
	
	print("Character system test started!")
	print("Controls:")
	print("- WASD/Arrow Keys: Move")
	print("- Space: Jump")
	print("- X: Attack")
	print("- Tab: Switch character")
	print("- Page Down: Debug unlock Jenny")

func _update_ui():
	happiness_label.text = "Happiness: %d" % GameManager.happiness
	energy_label.text = "Energy: %d" % GameManager.energy
	character_label.text = "Character: %s" % GameManager.current_player.capitalize()

func _on_happiness_changed(new_value: int):
	happiness_label.text = "Happiness: %d" % new_value

func _on_energy_changed(new_value: int):
	energy_label.text = "Energy: %d" % new_value

func _on_character_switched(new_character: String):
	character_label.text = "Character: %s" % new_character.capitalize()
	print("Switched to: %s" % new_character.capitalize())

func _input(event):
	if event.is_action_pressed("ui_accept"):
		print("Current Stats:")
		print("- Happiness: %d" % GameManager.happiness)
		print("- Energy: %d" % GameManager.energy)
		print("- Character: %s" % GameManager.current_player)
		print("- Has Jenny: %s" % GameManager.has_jenny)