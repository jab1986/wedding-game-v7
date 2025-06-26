extends CharacterBody2D
class_name Alien
## Alien enemy for wedding game disaster sequences
## Provides chaos and challenge during Glen's house level

signal alien_defeated()
signal player_spotted(player: Node2D)

@export var max_health: int = 30
@export var movement_speed: float = 80.0
@export var chase_speed: float = 120.0
@export var attack_damage: int = 10
@export var detection_range: float = 150.0
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.5

# Node references
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $HitBox
@onready var attack_timer: Timer
@onready var death_timer: Timer

# State management
enum AlienState { PATROL, CHASE, ATTACK, STUNNED, DYING }
var current_state: AlienState = AlienState.PATROL
var health: int
var facing_direction: int = 1
var last_attack_time: float = 0.0

# AI and movement
var player_reference: Node2D = null
var patrol_target: Vector2
var patrol_center: Vector2
var patrol_radius: float = 100.0
var gravity: float = 980.0

# Wedding-themed properties
var is_wedding_crasher: bool = true
var chaos_level: float = 1.0

func _ready() -> void:
	health = max_health
	patrol_center = global_position
	patrol_target = _get_random_patrol_point()
	
	# Set up collision layers
	collision_layer = 8  # Enemy layer
	collision_mask = 1 | 2  # World and player
	
	# Set up hitbox
	_setup_hitbox()
	
	# Set up timers
	_setup_timers()
	
	# Set up sprite
	_setup_sprite()
	
	# Add to enemy group
	add_to_group("enemies")
	add_to_group("alien_enemies")
	
	print("[Alien] Alien spawned at: %s" % global_position)

func _setup_hitbox() -> void:
	if hitbox:
		# Create collision shape for hitbox
		var hitbox_collision = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = 20.0
		hitbox_collision.shape = circle_shape
		hitbox.add_child(hitbox_collision)
		
		# Set up collision layers for damage detection
		hitbox.collision_layer = 32  # Enemy attack layer
		hitbox.collision_mask = 0
		
		# Connect hitbox signals
		hitbox.area_entered.connect(_on_hitbox_area_entered)

func _setup_timers() -> void:
	# Attack cooldown timer
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	add_child(attack_timer)
	
	# Death animation timer
	death_timer = Timer.new()
	death_timer.wait_time = 1.0
	death_timer.one_shot = true
	death_timer.timeout.connect(_on_death_complete)
	add_child(death_timer)

func _setup_sprite() -> void:
	if sprite:
		# Use existing alien sprite or create basic animations
		if not sprite.sprite_frames:
			var frames = SpriteFrames.new()
			frames.add_animation("idle")
			frames.add_animation("walk")
			frames.add_animation("attack")
			frames.add_animation("death")
			sprite.sprite_frames = frames
		
		sprite.play("idle")
	
	# Set up default collision shape
	if collision_shape and not collision_shape.shape:
		var capsule = CapsuleShape2D.new()
		capsule.height = 32.0
		capsule.radius = 12.0
		collision_shape.shape = capsule

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle state machine
	match current_state:
		AlienState.PATROL:
			_handle_patrol_state(delta)
		AlienState.CHASE:
			_handle_chase_state(delta)
		AlienState.ATTACK:
			_handle_attack_state(delta)
		AlienState.STUNNED:
			_handle_stunned_state(delta)
		AlienState.DYING:
			_handle_dying_state(delta)
	
	# Look for player
	_detect_player()
	
	# Apply movement
	move_and_slide()

func _handle_patrol_state(delta: float) -> void:
	var direction = (patrol_target - global_position).normalized()
	
	if global_position.distance_to(patrol_target) < 10.0:
		patrol_target = _get_random_patrol_point()
	
	velocity.x = direction.x * movement_speed
	_update_facing_direction(direction.x)
	
	if sprite.animation != "walk":
		sprite.play("walk")

func _handle_chase_state(delta: float) -> void:
	if not player_reference:
		current_state = AlienState.PATROL
		return
	
	var distance_to_player = global_position.distance_to(player_reference.global_position)
	
	if distance_to_player > detection_range * 1.5:
		# Lost player
		player_reference = null
		current_state = AlienState.PATROL
		return
	
	if distance_to_player <= attack_range:
		current_state = AlienState.ATTACK
		return
	
	# Chase player
	var direction = global_position.direction_to(player_reference.global_position)
	velocity.x = direction.x * chase_speed
	_update_facing_direction(direction.x)
	
	if sprite.animation != "walk":
		sprite.play("walk")

func _handle_attack_state(delta: float) -> void:
	if not player_reference:
		current_state = AlienState.PATROL
		return
	
	var distance_to_player = global_position.distance_to(player_reference.global_position)
	
	if distance_to_player > attack_range:
		current_state = AlienState.CHASE
		return
	
	# Stop movement during attack
	velocity.x = 0
	
	# Face player
	var direction = global_position.direction_to(player_reference.global_position)
	_update_facing_direction(direction.x)
	
	# Attack if cooldown is ready
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_attack_time >= attack_cooldown:
		_perform_attack()
		last_attack_time = current_time

func _handle_stunned_state(delta: float) -> void:
	velocity.x = 0
	# Stunned state handled by timer

func _handle_dying_state(delta: float) -> void:
	velocity.x = 0
	if sprite.animation != "death":
		sprite.play("death")

func _detect_player() -> void:
	if current_state == AlienState.DYING:
		return
	
	# Simple player detection
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(detection_range * facing_direction, 0)
	)
	query.collision_mask = 2  # Player layer
	
	var result = space_state.intersect_ray(query)
	if result and result.collider:
		var collider = result.collider
		if collider.is_in_group("player") or collider is Player:
			if not player_reference:
				player_spotted.emit(collider)
				print("[Alien] Player spotted!")
			
			player_reference = collider
			if current_state == AlienState.PATROL:
				current_state = AlienState.CHASE

func _perform_attack() -> void:
	print("[Alien] Attacking player!")
	
	if sprite.animation != "attack":
		sprite.play("attack")
	
	# Deal damage to player
	if player_reference and player_reference.has_method("take_damage"):
		player_reference.take_damage(attack_damage)
	
	# Play attack sound
	if AudioManager:
		AudioManager.play_sfx("alien_attack")

func _get_random_patrol_point() -> Vector2:
	var angle = randf() * 2 * PI
	var distance = randf_range(30.0, patrol_radius)
	return patrol_center + Vector2(cos(angle), sin(angle)) * distance

func _update_facing_direction(direction_x: float) -> void:
	if direction_x != 0:
		facing_direction = sign(direction_x)
		sprite.flip_h = facing_direction < 0

func take_damage(amount: int) -> void:
	if current_state == AlienState.DYING:
		return
	
	health -= amount
	print("[Alien] Took %d damage, health: %d/%d" % [amount, health, max_health])
	
	# Flash effect
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE
	
	if health <= 0:
		_die()
	else:
		# Brief stun
		current_state = AlienState.STUNNED
		await get_tree().create_timer(0.5).timeout
		if current_state == AlienState.STUNNED:
			current_state = AlienState.PATROL

func _die() -> void:
	current_state = AlienState.DYING
	collision_layer = 0  # Stop colliding
	
	# Play death sound
	if AudioManager:
		AudioManager.play_sfx("alien_death")
	
	# Analytics tracking
	if AnalyticsManager:
		AnalyticsManager.track_player_action("enemy_defeated", {
			"enemy_type": "alien",
			"position": global_position
		})
	
	alien_defeated.emit()
	death_timer.start()

func _on_death_complete() -> void:
	print("[Alien] Death animation complete, removing alien")
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	# Check for player attacks
	if area.is_in_group("player_attacks"):
		take_damage(20)  # Standard player attack damage

## Set chaos level (affects behavior intensity)
func set_chaos_level(level: float) -> void:
	chaos_level = clamp(level, 0.0, 2.0)
	movement_speed *= chaos_level
	chase_speed *= chaos_level
	attack_damage = int(attack_damage * chaos_level)

## Get alien info for debugging/analytics
func get_alien_info() -> Dictionary:
	return {
		"health": health,
		"max_health": max_health,
		"state": AlienState.keys()[current_state],
		"position": global_position,
		"has_player_target": player_reference != null,
		"chaos_level": chaos_level
	}