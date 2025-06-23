extends RigidBody2D
class_name Drumstick
## Drumstick projectile for Mark's attacks
## Fast-flying spinning projectile with piercing capability

signal hit_enemy(enemy: Node2D)
signal destroyed()

# Projectile properties
@export var damage: int = 10
@export var speed: float = 300.0
@export var lifetime: float = 3.0
@export var spin_speed: float = 720.0
@export var pierce_count: int = 2
@export var bounce_count: int = 1

# Node references
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Hitbox
@onready var lifetime_timer: Timer = $LifetimeTimer

# State
var direction: int = 1
var has_hit: bool = false
var pierce_remaining: int = 2

func _ready() -> void:
	# Set up collision layers
	collision_layer = 16  # Player projectiles layer
	collision_mask = 1 | 4  # World and enemies
	
	# Connect signals
	if hitbox:
		hitbox.area_entered.connect(_on_hitbox_area_entered)
		hitbox.body_entered.connect(_on_hitbox_body_entered)
	
	if lifetime_timer:
		lifetime_timer.timeout.connect(_on_lifetime_timeout)
		lifetime_timer.wait_time = lifetime
		lifetime_timer.start()
	
	# Set initial velocity
	linear_velocity = Vector2(direction * speed, 0)
	
	# Add spin animation
	if sprite:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(sprite, "rotation", TAU, 1.0)
	
	print("Drumstick created")

func set_direction(dir: int) -> void:
	direction = dir
	if sprite:
		sprite.flip_h = direction < 0

func set_speed(new_speed: float) -> void:
	speed = new_speed
	linear_velocity = Vector2(direction * speed, linear_velocity.y)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if has_hit:
		return
		
	# Check if it's an enemy
	if area.is_in_group("enemies") or area.is_in_group("enemy_hurtbox"):
		_hit_enemy(area.get_parent())

func _on_hitbox_body_entered(body: Node2D) -> void:
	if has_hit:
		return
		
	# Hit world geometry
	if body.is_in_group("world") or body.collision_layer == 1:
		_hit_wall()

func _hit_enemy(enemy: Node2D) -> void:
	# Deal damage to enemy
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)
	
	hit_enemy.emit(enemy)
	
	# Check pierce count
	pierce_remaining -= 1
	if pierce_remaining <= 0:
		_destroy()
	else:
		print("Drumstick pierced enemy, %d pierces remaining" % pierce_remaining)

func _hit_wall() -> void:
	has_hit = true
	_destroy()

func _on_lifetime_timeout() -> void:
	print("Drumstick lifetime expired")
	_destroy()

func _destroy() -> void:
	destroyed.emit()
	queue_free()