extends RigidBody2D
class_name CameraBomb
## Camera Bomb projectile for Jenny's attacks
## Arc-trajectory explosive with area damage

signal exploded(position: Vector2)
signal hit_enemy(enemy: Node2D)

# Projectile properties
@export var damage: int = 15
@export var explosion_damage: int = 20
@export var speed: float = 250.0
@export var arc_strength: float = 200.0
@export var explosion_radius: float = 80.0
@export var lifetime: float = 4.0
@export var fuse_time: float = 2.0

# Node references
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var explosion_area: Area2D = $ExplosionArea
@onready var explosion_collision: CollisionShape2D = $ExplosionArea/CollisionShape2D
@onready var fuse_timer: Timer = $FuseTimer
@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var flash_timer: Timer = $FlashTimer

# State
var direction: int = 1
var has_exploded: bool = false
var use_arc: bool = false

func _ready() -> void:
	# Set up collision layers
	collision_layer = 16  # Player projectiles layer
	collision_mask = 1 | 4  # World and enemies
	
	# Connect signals
	if fuse_timer:
		fuse_timer.timeout.connect(_explode)
		fuse_timer.wait_time = fuse_time
		fuse_timer.start()
	
	if lifetime_timer:
		lifetime_timer.timeout.connect(_on_lifetime_timeout)
		lifetime_timer.wait_time = lifetime
		lifetime_timer.start()
	
	if flash_timer:
		flash_timer.timeout.connect(_flash_sprite)
		flash_timer.wait_time = 0.1
		flash_timer.start()
	
	# Set initial velocity
	if use_arc:
		linear_velocity = Vector2(direction * speed, -arc_strength)
	else:
		linear_velocity = Vector2(direction * speed, 0)
		gravity_scale = 0.0  # No gravity for straight throws
	
	print("Camera bomb created")

func set_direction(dir: int) -> void:
	direction = dir
	if sprite:
		sprite.flip_h = direction < 0

func set_speed(new_speed: float) -> void:
	speed = new_speed

func set_arc_trajectory(enable_arc: bool) -> void:
	use_arc = enable_arc
	if use_arc:
		gravity_scale = 1.0
		linear_velocity = Vector2(direction * speed, -arc_strength)
	else:
		gravity_scale = 0.0
		linear_velocity = Vector2(direction * speed, 0)

func _flash_sprite() -> void:
	if sprite and not has_exploded:
		# Flash red as it gets closer to exploding
		sprite.modulate = Color.RED if sprite.modulate == Color.WHITE else Color.WHITE

func _explode() -> void:
	if has_exploded:
		return
		
	has_exploded = true
	print("Camera bomb exploding!")
	
	# Stop flashing
	if flash_timer:
		flash_timer.stop()
	
	# Enable explosion area
	if explosion_area:
		explosion_area.monitoring = true
		var areas = explosion_area.get_overlapping_areas()
		var bodies = explosion_area.get_overlapping_bodies()
		
		# Damage enemies in explosion radius
		for area in areas:
			if area.is_in_group("enemies") or area.is_in_group("enemy_hurtbox"):
				var enemy = area.get_parent()
				if enemy.has_method("take_damage"):
					enemy.take_damage(explosion_damage)
					print("Explosion hit enemy: ", enemy.name)
		
		# Also check bodies
		for body in bodies:
			if body.is_in_group("enemies"):
				if body.has_method("take_damage"):
					body.take_damage(explosion_damage)
					print("Explosion hit enemy body: ", body.name)
	
	# Visual explosion effect (simple flash)
	if sprite:
		sprite.modulate = Color.WHITE
		sprite.scale = Vector2(3, 3)
	
	exploded.emit(global_position)
	
	# Remove after short delay to show explosion
	await get_tree().create_timer(0.2).timeout
	queue_free()

func _on_lifetime_timeout() -> void:
	if not has_exploded:
		print("Camera bomb lifetime expired, exploding")
		_explode()

func _on_body_entered(body: Node2D) -> void:
	if has_exploded:
		return
		
	# Explode on contact with world or enemies
	if body.collision_layer == 1 or body.is_in_group("world") or body.is_in_group("enemies"):
		print("Camera bomb hit something, exploding")
		_explode()