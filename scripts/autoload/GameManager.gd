extends Node
## GameManager - Core game state and progression management
## Handles player stats, inventory, and game flow

signal happiness_changed(new_value: int)
signal energy_changed(new_value: int)
signal inventory_changed(item: String, added: bool)
signal character_switched(new_character: String)
signal game_over()

const SAVE_PATH := "user://savegame.dat"
const MAX_HAPPINESS := 100
const MAX_ENERGY := 100

# Game State
var current_level: String = ""
var current_player: String = "mark"
var has_jenny: bool = false
var has_ring: bool = false
var glen_bingo_score: int = 0

# Player Stats
var happiness: int = 50:
	set(value):
		happiness = clampi(value, 0, MAX_HAPPINESS)
		happiness_changed.emit(happiness)
		if happiness <= 0:
			trigger_game_over()

var energy: int = 100:
	set(value):
		energy = clampi(value, 0, MAX_ENERGY)
		energy_changed.emit(energy)

# Inventory
var inventory: Array[String] = []

# Game Flags
var flags := {
	"tutorial_complete": false,
	"shed_on_fire": false,
	"sewage_exploded": false,
	"defeated_acids_joe": false,
	"switch_tutorial_shown": false,
	"glen_talked_count": 0,
}

# Level Progression
var level_order := [
	"AmsterdamLevel",
	"GlenHouseLevel",
	"GlenBingoLevel",
	"LeoCafeLevel",
	"WeddingVenueLevel",
	"BossFightLevel",
	"CeremonyLevel"
]

## Ready
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("GameManager initialized")

## Add item to inventory
func add_item(item_name: String) -> void:
	if item_name not in inventory:
		inventory.append(item_name)
		inventory_changed.emit(item_name, true)
		
		# Special item effects
		match item_name:
			"ring":
				has_ring = true
				happiness += 20
			"vegan_food":
				energy = min(MAX_ENERGY, energy + 50)
				happiness += 10

## Remove item from inventory
func remove_item(item_name: String) -> bool:
	if item_name in inventory:
		inventory.erase(item_name)
		inventory_changed.emit(item_name, false)
		return true
	return false

## Check if player has item
func has_item(item_name: String) -> bool:
	return item_name in inventory

## Switch active character
func switch_character() -> void:
	if not has_jenny:
		push_warning("Jenny not unlocked yet!")
		return
	
	current_player = "jenny" if current_player == "mark" else "mark"
	character_switched.emit(current_player)

## Damage player (affects both happiness and energy)
func take_damage(amount: int) -> void:
	energy -= amount
	happiness -= amount / 2.0

## Restore energy
func restore_energy(amount: int) -> void:
	energy += amount

## Trigger game over
func trigger_game_over() -> void:
	game_over.emit()
	# Don't change scene immediately, let current scene handle it
	print("Game Over triggered!")

## Get next level in progression
func get_next_level() -> String:
	var current_index := level_order.find(current_level)
	if current_index >= 0 and current_index < level_order.size() - 1:
		return level_order[current_index + 1]
	return ""

## Reset game state
func reset_game() -> void:
	happiness = 50
	energy = 100
	inventory.clear()
	current_player = "mark"
	has_jenny = false
	has_ring = false
	glen_bingo_score = 0
	
	# Reset flags
	for key in flags:
		match key:
			"glen_talked_count":
				flags[key] = 0
			_:
				flags[key] = false

## Save game state
func save_game() -> void:
	var save_dict := {
		"happiness": happiness,
		"energy": energy,
		"inventory": inventory,
		"current_player": current_player,
		"current_level": current_level,
		"has_jenny": has_jenny,
		"has_ring": has_ring,
		"glen_bingo_score": glen_bingo_score,
		"flags": flags
	}
	
	var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file:
		save_file.store_var(save_dict)
		save_file.close()
		print("Game saved successfully")

## Load game state
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	
	var save_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file:
		var save_dict = save_file.get_var()
		save_file.close()
		
		# Restore state
		happiness = save_dict.get("happiness", 50)
		energy = save_dict.get("energy", 100)
		inventory = save_dict.get("inventory", [])
		current_player = save_dict.get("current_player", "mark")
		current_level = save_dict.get("current_level", "")
		has_jenny = save_dict.get("has_jenny", false)
		has_ring = save_dict.get("has_ring", false)
		glen_bingo_score = save_dict.get("glen_bingo_score", 0)
		
		var loaded_flags = save_dict.get("flags", {})
		for key in loaded_flags:
			if key in flags:
				flags[key] = loaded_flags[key]
		
		print("Game loaded successfully")
		return true
	
	return false

## Debug functions
func _unhandled_key_input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event.is_action_pressed("ui_page_up"):
			print("Debug: Restoring full stats")
			happiness = MAX_HAPPINESS
			energy = MAX_ENERGY
		elif event.is_action_pressed("ui_page_down"):
			print("Debug: Unlocking Jenny")
			has_jenny = true
		elif event.is_action_pressed("ui_home"):
			print("Debug: Adding all items")
			add_item("ring")
			add_item("vegan_food")
			add_item("drumstick")