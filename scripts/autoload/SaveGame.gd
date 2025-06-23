extends Node

const SAVE_PATH = "user://savegame.save"
const BROWSER_SAVE_KEY = "wedding_game_save"

# Check if we're running in a browser
var is_web_platform = OS.has_feature("web")

func save_game():
	var save_data = {
		"player": {
			"health": GameManager.player_health,
			"score": GameManager.score,
			"collected_items": GameManager.collected_items,
			"name": GameManager.player_data.name,
			"abilities": GameManager.player_data.abilities,
			"inventory": GameManager.player_data.inventory
		},
		"game_progress": {
			"current_level": GameManager.current_level,
			"levels_completed": GameManager.levels_completed
		},
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	if is_web_platform:
		save_to_browser(save_data)
	else:
		var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if file:
			file.store_var(save_data)
			print("Game saved successfully")
		else:
			push_error("Failed to save game: " + str(FileAccess.get_open_error()))

# Save game data to browser localStorage
func save_to_browser(save_data: Dictionary) -> bool:
	if not is_web_platform:
		return false
	
	# Only use JavaScript interface when actually running on web
	if not OS.has_feature("web"):
		print("JavaScript interface not available (not running on web)")
		return false
		
	var json_string = JSON.stringify(save_data)
	var js_code = "localStorage.setItem('%s', '%s'); true;" % [BROWSER_SAVE_KEY, json_string]
	var result = JavaScriptBridge.eval(js_code)
	
	if result:
		print("Game saved to browser localStorage")
		return true
	else:
		push_error("Failed to save game to browser localStorage")
		return false

func load_game() -> bool:
	var save_data
	
	if is_web_platform:
		save_data = load_from_browser()
		if not save_data:
			print("No browser save data found")
			return false
	else:
		if not FileAccess.file_exists(SAVE_PATH):
			print("No save file found")
			return false
		
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if not file:
			push_error("Failed to load game: " + str(FileAccess.get_open_error()))
			return false
			
		save_data = file.get_var()
	
	# Load player data
	GameManager.player_health = save_data.player.health
	GameManager.score = save_data.player.score
	GameManager.collected_items = save_data.player.collected_items
	GameManager.player_data.name = save_data.player.name
	GameManager.player_data.abilities = save_data.player.abilities
	GameManager.player_data.inventory = save_data.player.inventory
	
	# Load game progress
	GameManager.current_level = save_data.game_progress.current_level
	GameManager.levels_completed = save_data.game_progress.levels_completed
	
	print("Game loaded successfully")
	return true

# Load game data from browser localStorage
func load_from_browser() -> Variant:
	if not is_web_platform:
		return null
	
	# Only use JavaScript interface when actually running on web
	if not OS.has_feature("web"):
		print("JavaScript interface not available (not running on web)")
		return null
		
	var js_code = "localStorage.getItem('%s');" % BROWSER_SAVE_KEY
	var json_string = JavaScriptBridge.eval(js_code)
	
	if json_string and typeof(json_string) == TYPE_STRING:
		var parse_result = JSON.parse_string(json_string)
		if parse_result:
			print("Game loaded from browser localStorage")
			return parse_result
			
	print("Failed to load game from browser localStorage")
	return null

func delete_save():
	if is_web_platform:
		delete_browser_save()
	else:
		if FileAccess.file_exists(SAVE_PATH):
			var dir = DirAccess.open("user://")
			if dir:
				dir.remove(SAVE_PATH)
				print("Save file deleted")
			else:
				push_error("Failed to access user directory")
		else:
			print("No save file to delete")

# Delete save data from browser localStorage
func delete_browser_save() -> bool:
	if not is_web_platform:
		return false
	
	# Only use JavaScript interface when actually running on web
	if not OS.has_feature("web"):
		print("JavaScript interface not available (not running on web)")
		return false
		
	var js_code = "localStorage.removeItem('%s'); true;" % BROWSER_SAVE_KEY
	var result = JavaScriptBridge.eval(js_code)
	
	if result:
		print("Browser save data deleted")
		return true
	else:
		push_error("Failed to delete browser save data")
		return false

func has_save() -> bool:
	if is_web_platform:
		return has_browser_save()
	else:
		return FileAccess.file_exists(SAVE_PATH)
		
# Check if save data exists in browser localStorage
func has_browser_save() -> bool:
	if not is_web_platform:
		return false
	
	# Only use JavaScript interface when actually running on web
	if not OS.has_feature("web"):
		print("JavaScript interface not available (not running on web)")
		return false
		
	var js_code = "localStorage.getItem('%s') !== null;" % BROWSER_SAVE_KEY
	var result = JavaScriptBridge.eval(js_code)
	
	return result == true
