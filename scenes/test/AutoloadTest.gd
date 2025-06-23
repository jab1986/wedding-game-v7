extends Control
## Autoload Test Scene - Verifies all core systems work correctly

@onready var output_label: Label = $VBoxContainer/OutputLabel
@onready var test_button: Button = $VBoxContainer/TestButton

var test_results: Array[String] = []

func _ready() -> void:
	print("=== AUTOLOAD SYSTEM TEST ===")
	test_button.pressed.connect(_run_all_tests)
	_run_all_tests()

func _run_all_tests() -> void:
	test_results.clear()
	output_label.text = \"Running tests...\\n\"

	# Test 1: GameManager
	_test_game_manager()

	# Test 2: AudioManager
	_test_audio_manager()

	# Test 3: SceneTransition
	_test_scene_transition()

	# Test 4: SaveGame
	_test_save_game()

	# Display results
	_display_results()

func _test_game_manager() -> void:
	print(\"Testing GameManager...\")

	if GameManager == null:
		test_results.append(\"❌ GameManager: Not found\")
		return

	try:
		# Test basic properties
		GameManager.happiness = 75
		GameManager.energy = 90
		GameManager.current_level = \"test_level\"

		if GameManager.happiness == 75 and GameManager.energy == 90:
			test_results.append(\"✅ GameManager: Basic properties work\")
		else:
			test_results.append(\"❌ GameManager: Property assignment failed\")

		# Test inventory
		GameManager.add_item(\"test_item\")
		if GameManager.has_item(\"test_item\"):
			test_results.append(\"✅ GameManager: Inventory system works\")
		else:
			test_results.append(\"❌ GameManager: Inventory system failed\")

	exceptException as e:
		test_results.append(\"❌ GameManager: Error - \" + str(e))

func _test_audio_manager() -> void:
	print(\"Testing AudioManager...\")

	if AudioManager == null:
		test_results.append(\"❌ AudioManager: Not found\")
		return

	try:
		# Test basic functionality (without actual audio files)
		var initial_music_volume = AudioManager.music_volume
		var initial_sfx_volume = AudioManager.sfx_volume

		AudioManager.set_music_volume(0.7)
		AudioManager.set_sfx_volume(0.8)

		if AudioManager.music_volume == 0.7 and AudioManager.sfx_volume == 0.8:
			test_results.append(\"✅ AudioManager: Volume controls work\")
		else:
			test_results.append(\"❌ AudioManager: Volume controls failed\")

		# Test mute functionality
		AudioManager.set_music_enabled(false)
		if not AudioManager.music_enabled:
			test_results.append(\"✅ AudioManager: Mute functionality works\")
		else:
			test_results.append(\"❌ AudioManager: Mute functionality failed\")

		# Restore settings
		AudioManager.set_music_enabled(true)
		AudioManager.set_music_volume(initial_music_volume)
		AudioManager.set_sfx_volume(initial_sfx_volume)

	exceptException as e:
		test_results.append(\"❌ AudioManager: Error - \" + str(e))

func _test_scene_transition() -> void:
	print(\"Testing SceneTransition...\")

	if SceneTransition == null:
		test_results.append(\"❌ SceneTransition: Not found\")
		return

	try:
		# Test basic properties
		if SceneTransition.has_method(\"fade_to_scene\") and SceneTransition.has_method(\"slide_to_scene\"):
			test_results.append(\"✅ SceneTransition: Required methods exist\")
		else:
			test_results.append(\"❌ SceneTransition: Missing required methods\")

		# Test transition types
		if SceneTransition.has_method(\"set_transition_type\"):
			test_results.append(\"✅ SceneTransition: Transition type system available\")
		else:
			test_results.append(\"❌ SceneTransition: No transition type system\")

	exceptException as e:
		test_results.append(\"❌ SceneTransition: Error - \" + str(e))

func _test_save_game() -> void:
	print(\"Testing SaveGame...\")

	if SaveGame == null:
		test_results.append(\"❌ SaveGame: Not found\")
		return

	try:
		# Test save data structure
		var test_data = { \"test_key\": \"test_value\", \"test_number\": 42}

		if SaveGame.has_method(\"save_game\") and SaveGame.has_method(\"load_game\"):
			test_results.append(\"✅ SaveGame: Save/Load methods exist\")
		else:
			test_results.append(\"❌ SaveGame: Missing save/load methods\")

		# Test if we can access save data structure
		if SaveGame.has_method(\"get_save_data\"):
			test_results.append(\"✅ SaveGame: Save data access available\")
		else:
			test_results.append(\"❌ SaveGame: No save data access method\")

	exceptException as e:
		test_results.append(\"❌ SaveGame: Error - \" + str(e))

func _display_results() -> void:
	var output_text = \"=== AUTOLOAD TEST RESULTS ===\\n\\n\"

	var passed = 0
	var total = test_results.size()

	for result in test_results:
		output_text += result + \"\\n\"
		if result.begins_with(\"✅\"):
			passed += 1

	output_text += \"\\n=== SUMMARY ===\\n\"
	output_text += \"Passed: %d/%d tests\\n\" % [passed, total]

	if passed == total:
		output_text += \"🎉 ALL TESTS PASSED! Systems ready for development.\"
	else:
		output_text += \"⚠️ Some tests failed. Check individual systems.\"

	output_label.text = output_text
	print(output_text)

# Quick access method for debugging
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(\"ui_accept\"):  # Enter key
		_run_all_tests()
