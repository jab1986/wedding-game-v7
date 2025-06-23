extends Node
class_name SpriteManagerUtils
## SpriteManager - Handles consistent sprite loading and sizing
## Ensures all sprites follow the established sizing standards

const SPRITE_SIZES := {
	"character": Vector2(64, 64),
	"item": Vector2(32, 32),
	"projectile": Vector2(16, 16),
	"effect": Vector2(48, 48),
	"ui": Vector2(32, 32)
}

const CHARACTER_SPRITES := {
	"mark": "res://assets/graphics/characters/mark/mark-sprite.png",
	"jenny": "res://assets/graphics/characters/jenny/jenny-sprite.png",
	"glen": "res://assets/graphics/characters/glen/glen.png",
	"quinn": "res://assets/graphics/characters/quinn/quinn.png",
	"jack": "res://assets/graphics/characters/jack/jack.png",
	"hassan": "res://assets/graphics/characters/hassan/hassan-sprite.png",
	"paul": "res://assets/graphics/characters/political_paul/paul-sprite.png",
	"gaz": "res://assets/graphics/characters/gaz/gaz-sprite.png",
	"matt": "res://assets/graphics/characters/matt_tibble/sprite.png",
	"dan": "res://assets/graphics/characters/dan_morisey/Dan.png",
	"alien": "res://assets/graphics/characters/aliens/generation-7cfd13c1-c8b1-4e36-b0b0-7e024af5127a.png",
	"acids_joe": "res://assets/graphics/characters/acids_joe/joe.png"
}

const ITEM_SPRITES := {
	"drumstick": "res://assets/graphics/items/drumstick.png",
	"camera": "res://assets/graphics/items/camera.png"
}

## Create a sprite with proper sizing for the given type
static func create_sprite(sprite_type: String, sprite_name: String = "") -> Sprite2D:
	var sprite = Sprite2D.new()
	
	# Get size for type
	var target_size = SPRITE_SIZES.get(sprite_type, Vector2(32, 32))
	
	# Load texture based on type and name
	var texture_path = ""
	match sprite_type:
		"character":
			texture_path = CHARACTER_SPRITES.get(sprite_name, "")
		"item":
			texture_path = ITEM_SPRITES.get(sprite_name, "")
		_:
			push_warning("Unknown sprite type: " + sprite_type)
			return sprite
	
	if texture_path.is_empty():
		push_warning("Sprite not found: %s/%s" % [sprite_type, sprite_name])
		return sprite
	
	# Load and set texture
	var texture = load(texture_path) as Texture2D
	if texture:
		sprite.texture = texture
		
		# Calculate scale to match target size
		var texture_size = texture.get_size()
		var scale_factor = Vector2(
			target_size.x / texture_size.x,
			target_size.y / texture_size.y
		)
		sprite.scale = scale_factor
	
	return sprite

## Create an animated sprite with proper sizing
static func create_animated_sprite(sprite_type: String, sprite_name: String, frame_data: SpriteFrames = null) -> AnimatedSprite2D:
	var animated_sprite = AnimatedSprite2D.new()
	
	# Get size for type
	var target_size = SPRITE_SIZES.get(sprite_type, Vector2(32, 32))
	
	# Set sprite frames
	if frame_data:
		animated_sprite.sprite_frames = frame_data
	else:
		# Create basic sprite frames from single texture
		var sprite_frames = SpriteFrames.new()
		var texture_path = ""
		
		match sprite_type:
			"character":
				texture_path = CHARACTER_SPRITES.get(sprite_name, "")
			"item":
				texture_path = ITEM_SPRITES.get(sprite_name, "")
		
		if not texture_path.is_empty():
			var texture = load(texture_path) as Texture2D
			if texture:
				sprite_frames.add_animation("default")
				sprite_frames.add_frame("default", texture)
				animated_sprite.sprite_frames = sprite_frames
				
				# Calculate scale to match target size
				var texture_size = texture.get_size()
				var scale_factor = Vector2(
					target_size.x / texture_size.x,
					target_size.y / texture_size.y
				)
				animated_sprite.scale = scale_factor
	
	return animated_sprite

## Load character sprite frames from existing resources
static func load_character_frames(character_name: String) -> SpriteFrames:
	var frames_path = "res://assets/graphics/characters/%s/%s_frames.tres" % [character_name, character_name]
	if ResourceLoader.exists(frames_path):
		return load(frames_path) as SpriteFrames
	return null

## Utility function to set sprite size directly
static func set_sprite_size(sprite: Node2D, target_size: Vector2) -> void:
	if sprite is Sprite2D:
		var sprite_2d = sprite as Sprite2D
		if sprite_2d.texture:
			var texture_size = sprite_2d.texture.get_size()
			sprite_2d.scale = Vector2(
				target_size.x / texture_size.x,
				target_size.y / texture_size.y
			)
	elif sprite is AnimatedSprite2D:
		var animated_sprite = sprite as AnimatedSprite2D
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.get_frame_count("default") > 0:
			var texture = animated_sprite.sprite_frames.get_frame_texture("default", 0)
			if texture:
				var texture_size = texture.get_size()
				animated_sprite.scale = Vector2(
					target_size.x / texture_size.x,
					target_size.y / texture_size.y
				)

## Get standard size for sprite type
static func get_sprite_size(sprite_type: String) -> Vector2:
	return SPRITE_SIZES.get(sprite_type, Vector2(32, 32))

## Check if sprite path exists
static func sprite_exists(sprite_type: String, sprite_name: String) -> bool:
	match sprite_type:
		"character":
			return CHARACTER_SPRITES.has(sprite_name)
		"item":
			return ITEM_SPRITES.has(sprite_name)
	return false