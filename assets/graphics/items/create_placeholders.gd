@tool
extends EditorScript

# Script to create placeholder projectile sprites
func _run():
	print("Creating placeholder sprites...")
	
	# Create drumstick sprite (16x6 brown rectangle)
	var drumstick_image = Image.create(16, 6, false, Image.FORMAT_RGBA8)
	drumstick_image.fill(Color(0.6, 0.3, 0.1, 1.0))  # Brown color
	var drumstick_texture = ImageTexture.new()
	drumstick_texture.set_image(drumstick_image)
	ResourceSaver.save(drumstick_texture, "res://assets/graphics/items/drumstick.png")
	
	# Create camera sprite (12x8 black rectangle with flash)
	var camera_image = Image.create(12, 8, false, Image.FORMAT_RGBA8)
	camera_image.fill(Color(0.1, 0.1, 0.1, 1.0))  # Dark grey/black
	# Add a small white "flash" rectangle
	for x in range(2, 6):
		for y in range(2, 4):
			camera_image.set_pixel(x, y, Color.WHITE)
	
	var camera_texture = ImageTexture.new()
	camera_texture.set_image(camera_image)
	ResourceSaver.save(camera_texture, "res://assets/graphics/items/camera.png")
	
	print("Placeholder sprites created!")
	print("- drumstick.png: 16x6 brown rectangle")
	print("- camera.png: 12x8 dark grey with white flash")