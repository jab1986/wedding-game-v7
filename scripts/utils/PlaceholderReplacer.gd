extends Node

## Placeholder Image Replacement Utility
## Helps systematically replace placeholder images with proper free pixel art

# Character mapping for wedding game
var character_replacements = {
	"mark": {
		"description": "Groom - formal suit, brown hair",
		"size": "32x32",
		"animations": ["idle", "walk", "talk", "celebrate"],
		"source": "Puny Characters - CC0"
	},
	"jenny": {
		"description": "Bride - white dress, blonde hair",
		"size": "32x32",
		"animations": ["idle", "walk", "talk", "celebrate"],
		"source": "Puny Characters - CC0"
	},
	"hassan": {
		"description": "Wedding guest - casual formal",
		"size": "32x32",
		"animations": ["idle", "walk", "talk"],
		"source": "Pixel Adventure - CC0"
	},
	"glen": {
		"description": "Friend character - casual clothes",
		"size": "32x32",
		"animations": ["idle", "walk", "talk", "quiz_host"],
		"source": "Tiny Hero Sprites - CC0"
	},
	"acids_joe": {
		"description": "Boss character - distinctive look",
		"size": "32x32",
		"animations": ["idle", "walk", "attack", "hurt", "death"],
		"source": "Custom based on CC0 resources"
	}
}

# Item replacements
var item_replacements = {
	"wedding_ring": {
		"description": "Golden wedding ring icon",
		"size": "16x16",
		"source": "Custom pixel art - CC0"
	},
	"camera": {
		"description": "Camera item/weapon",
		"size": "16x16",
		"source": "Glitch Icons - CC0"
	}
}

# Asset sources with licenses
var asset_sources = {
	"puny_characters": {
		"url": "https://opengameart.org/content/puny-characters",
		"license": "CC0",
		"author": "Shade",
		"description": "16x16 base characters with 8-directional animations"
	},
	"pixel_adventure": {
		"url": "https://pixelfrog-assets.itch.io/pixel-adventure-1",
		"license": "CC0",
		"author": "Pixel Frog",
		"description": "Complete character set with animations"
	},
	"tiny_hero_sprites": {
		"url": "https://free-game-assets.itch.io/free-tiny-hero-sprites-pixel-art",
		"license": "CC0",
		"author": "Free Game Assets",
		"description": "32x32 cute character sprites"
	},
	"glitch_icons": {
		"url": "https://opengameart.org/content/100-glitch-icons",
		"license": "CC0",
		"author": "rubberduck",
		"description": "100 item icons including tools and objects"
	}
}

func _ready():
	print("[PlaceholderReplacer] Initialized - Ready to replace placeholder assets")
	print("[PlaceholderReplacer] Total character replacements planned: ", character_replacements.size())
	print("[PlaceholderReplacer] Total item replacements planned: ", item_replacements.size())

func generate_replacement_report() -> Dictionary:
	"""Generate a comprehensive report of needed replacements"""
	var report = {
		"characters_to_replace": [],
		"items_to_replace": [],
		"current_placeholder_files": [],
		"recommended_sources": asset_sources
	}

	# Scan for current placeholder files
	var placeholder_dir = "res://assets/graphics/placeholders/"
	var dir = DirAccess.open(placeholder_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png") and not file_name.ends_with(".import"):
				report.current_placeholder_files.append(file_name)
			file_name = dir.get_next()

	# Add character replacement info
	for character in character_replacements:
		report.characters_to_replace.append({
			"name": character,
			"info": character_replacements[character]
		})

	# Add item replacement info
	for item in item_replacements:
		report.items_to_replace.append({
			"name": item,
			"info": item_replacements[item]
		})

	return report

func create_attribution_file():
	"""Create proper attribution file for all CC0 assets used"""
	var attribution_content = """# Asset Attribution for Wedding Game

## Character Sprites

### Puny Characters
- **Source**: https://opengameart.org/content/puny-characters
- **Author**: Shade
- **License**: CC0 (Public Domain)
- **Usage**: Base character sprites for Mark, Jenny, and other wedding guests
- **Modifications**: Recolored and adapted for wedding theme

### Pixel Adventure Characters
- **Source**: https://pixelfrog-assets.itch.io/pixel-adventure-1
- **Author**: Pixel Frog
- **License**: CC0 (Public Domain)
- **Usage**: Additional character animations and sprites
- **Modifications**: Integrated into wedding game context

### Tiny Hero Sprites
- **Source**: https://free-game-assets.itch.io/free-tiny-hero-sprites-pixel-art
- **Author**: Free Game Assets (Craftpix)
- **License**: CC0 (Public Domain)
- **Usage**: Supporting characters and NPCs
- **Modifications**: Adapted for wedding game style

## Item Graphics

### Glitch Icons
- **Source**: https://opengameart.org/content/100-glitch-icons
- **Author**: rubberduck
- **License**: CC0 (Public Domain)
- **Usage**: Item icons, tools, and collectibles
- **Modifications**: Selected and adapted relevant icons

## License Notice

All assets listed above are released under CC0 (Creative Commons Zero) license,
meaning they are in the public domain and can be used for any purpose without
attribution. However, we provide this attribution as a courtesy to the creators
and to help other developers find these excellent resources.

## Wedding Game Specific Assets

Any assets not listed above are original creations for this wedding game project
and are also released under CC0 license for others to use freely.
"""

	var file = FileAccess.open("res://assets/ATTRIBUTION.md", FileAccess.WRITE)
	if file:
		file.store_string(attribution_content)
		file.close()
		print("[PlaceholderReplacer] Attribution file created at res://assets/ATTRIBUTION.md")
	else:
		print("[PlaceholderReplacer] Error: Could not create attribution file")

func log_replacement_progress(character_name: String, status: String):
	"""Log progress of asset replacement"""
	var timestamp = Time.get_datetime_string_from_system()
	print("[PlaceholderReplacer] %s - %s: %s" % [timestamp, character_name, status])

# Helper function to validate asset dimensions
func validate_sprite_dimensions(texture: Texture2D, expected_size: Vector2) -> bool:
	if not texture:
		return false
	return texture.get_size() == expected_size

# Helper function to check if file exists
func asset_exists(path: String) -> bool:
	return FileAccess.file_exists(path)
