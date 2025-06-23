extends Node
## Quick audio test script

func _ready():
	print("Testing AudioManager...")
	
	# Test sound effects
	if AudioManager:
		print("AudioManager found!")
		
		# Play menu select sound
		AudioManager.play_sfx("menu_select")
		await get_tree().create_timer(1.0).timeout
		
		# Play pickup sound
		AudioManager.play_sfx("pickup")
		await get_tree().create_timer(1.0).timeout
		
		# Play jump sound
		AudioManager.play_sfx("jump")
		await get_tree().create_timer(1.0).timeout
		
		# Test background music
		AudioManager.play_music("menu_theme")
		await get_tree().create_timer(3.0).timeout
		
		# Switch to romantic music
		AudioManager.play_music("amsterdam_romantic")
		await get_tree().create_timer(3.0).timeout
		
		print("Audio test complete!")
	else:
		print("AudioManager not found!")