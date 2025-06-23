extends Camera2D
class_name ShakeCamera2D
## Extended Camera2D with shake functionality
## Provides screen shake effects for impacts and explosions

# Shake state
var shake_amount: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0
var original_offset: Vector2
var is_shaking: bool = false

# Shake configuration
@export var decay_rate: float = 5.0  # How quickly shake decreases
@export var max_shake_offset: float = 50.0  # Maximum shake distance
@export var shake_speed: float = 30.0  # Shake frequency

func _ready() -> void:
	original_offset = offset
	set_process(false)  # Only process when shaking

## Start camera shake
func shake(duration: float, amount: float) -> void:
	shake_duration = duration
	shake_amount = min(amount, max_shake_offset)
	shake_timer = duration
	is_shaking = true
	set_process(true)

## Stop camera shake immediately
func stop_shake() -> void:
	is_shaking = false
	shake_timer = 0.0
	offset = original_offset
	set_process(false)

func _process(delta: float) -> void:
	if not is_shaking:
		return
	
	# Update shake timer
	shake_timer -= delta
	
	if shake_timer <= 0:
		stop_shake()
		return
	
	# Calculate shake intensity (decreases over time)
	var shake_percentage = shake_timer / shake_duration
	var current_shake = shake_amount * shake_percentage
	
	# Apply shake offset
	var shake_offset = Vector2(
		randf_range(-current_shake, current_shake),
		randf_range(-current_shake, current_shake)
	)
	
	offset = original_offset + shake_offset

## Shake with specific pattern
func impact_shake(direction: Vector2 = Vector2.ZERO) -> void:
	# Quick, sharp shake for impacts
	shake(0.2, 15.0)
	
	if direction != Vector2.ZERO:
		# Directional shake
		offset = original_offset + direction.normalized() * 20.0
		var tween = create_tween()
		tween.tween_property(self, "offset", original_offset, 0.3).set_trans(Tween.TRANS_ELASTIC)

## Shake for explosions
func explosion_shake(distance: float = 0.0) -> void:
	# Intensity based on distance (0 = at explosion center)
	var intensity = max(5.0, 30.0 - distance * 0.1)
	shake(0.5, intensity)

## Continuous shake (e.g., for earthquakes)
func continuous_shake(amount: float) -> void:
	shake_amount = amount
	is_shaking = true
	set_process(true)
	# Don't set timer for continuous shake

## Get current shake intensity (0.0 to 1.0)
func get_shake_intensity() -> float:
	if not is_shaking:
		return 0.0
	return shake_timer / shake_duration if shake_duration > 0 else 0.0