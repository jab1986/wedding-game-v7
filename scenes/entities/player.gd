extends CharacterBody2D
class_name Player
## Player character controller for Mark and Jenny
## Handles movement, attacks, and character switching

signal health_changed(new_health: int)
signal attacked()
signal character_changed(character_type: String)

# Movement constants
var base_speed := 160.0
const JUMP_VELOCITY := -330.0
const GRAVITY := 980.0
const FRICTION := 0.2
const ACCELERATION := 0.25

# Combat constants
const ATTACK_COOLDOWN := 0.5
const DRUMSTICK_SPEED := 300.0
const CAMERA_BOMB_SPEED := 250.0

# Character types
enum CharacterType { MARK, JENNY }

# Exported variables
@export var character_type: CharacterType = CharacterType.MARK
@export var drumstick_scene: PackedScene
@export var camera_bomb_scene: PackedScene

# Node references
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer
@onready var hurtbox: Area2D = $Hurtbox
@onready var interaction_area: Area2D = $InteractionArea
@onready var state_machine: Node = $StateMachine
@onready var inventory_node: Node = $PlayerInventory
var inventory: Inventory

# State
var can_attack: bool = true
var facing_direction: int = 1
var is_switching: bool = false
var current_state: String = "idle"

# Mobile controls removed - desktop only

func _ready() -> void:
	# Connect to GameManager (temporarily disabled for testing)
	# GameManager.character_switched.connect(_on_character_switched)
	
	# Create inventory
	_setup_inventory()
	
	# Set up character
	_setup_character()
	
	# Connect timers
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	
	# Set up collision layers
	collision_layer = 2  # Player layer
	collision_mask = 1 | 4 | 8  # World, items, triggers
	
	# Connect hurtbox
	if hurtbox:
		hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	
	# Setup camera to follow player (AddonManager temporarily disabled)
	# if AddonManager and AddonManager.camera_manager:
	#	AddonManager.setup_player_camera(self)

func _setup_inventory() -> void:
	# Create a new inventory resource
	inventory = Inventory.new()
	inventory.width = 20  # Single row inventory with 20 slots
	print("Player inventory created with %d slots" % inventory.width)

func _setup_character() -> void:
	# Update sprite based on character type
	match character_type:
		CharacterType.MARK:
			sprite.sprite_frames = load("res://assets/graphics/characters/mark/mark_frames.tres")
			# Mark is faster
			base_speed = 180.0
		CharacterType.JENNY:
			sprite.sprite_frames = load("res://assets/graphics/characters/jenny/jenny_frames.tres")
			# Jenny is slightly slower but more powerful
			base_speed = 150.0
	
	# Play idle animation
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, 1000.0)  # Terminal velocity
	
	# Skip input during character switching, but allow physics
	if is_switching:
		move_and_slide()
		return
	
	# Handle jump
	if _is_jump_pressed() and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sprite.play("jump")
	
	# Handle horizontal movement
	var direction := _get_movement_direction()
	
	if direction != 0:
		# Accelerate
		velocity.x = move_toward(velocity.x, direction * base_speed, base_speed * ACCELERATION)
		facing_direction = sign(direction)
		sprite.flip_h = facing_direction < 0
		
		if is_on_floor():
			sprite.play("walk")
	else:
		# Apply friction
		velocity.x = move_toward(velocity.x, 0, base_speed * FRICTION)
		
		if is_on_floor() and abs(velocity.x) < 10:
			sprite.play("idle")
	
	# Handle attack
	if Input.is_action_just_pressed("attack") and can_attack:
		_perform_attack()
	
	# Character switching (temporarily disabled)
	# if Input.is_action_just_pressed("switch_character") and GameManager.has_jenny:
	#	GameManager.switch_character()
	
	# Apply movement
	move_and_slide()
	
	# Update state
	_update_animation_state()

func _get_movement_direction() -> float:
	var direction := 0.0
	
	# Keyboard/gamepad input
	direction = Input.get_axis("move_left", "move_right")
	
	# Mobile touch override removed - desktop only
	
	return direction

func _is_jump_pressed() -> bool:
	return Input.is_action_just_pressed("jump")

func _perform_attack() -> void:
	# Energy check temporarily disabled
	# if GameManager.energy < 5:
	#	print("Not enough energy to attack!")
	#	return
	
	can_attack = false
	attack_timer.start(ATTACK_COOLDOWN)
	sprite.play("attack")
	attacked.emit()
	
	# Use energy (temporarily disabled)
	# GameManager.energy -= 5
	
	# Create projectile
	match character_type:
		CharacterType.MARK:
			_throw_drumstick()
		CharacterType.JENNY:
			_throw_camera_bomb()

func _throw_drumstick() -> void:
	if not drumstick_scene:
		push_error("Drumstick scene not set!")
		return
	
	var drumstick = drumstick_scene.instantiate()
	get_tree().current_scene.add_child(drumstick)
	
	drumstick.global_position = global_position + Vector2(facing_direction * 20, -10)
	drumstick.set_direction(facing_direction)
	drumstick.set_speed(DRUMSTICK_SPEED)

func _throw_camera_bomb() -> void:
	if not camera_bomb_scene:
		push_error("Camera bomb scene not set!")
		return
	
	var bomb = camera_bomb_scene.instantiate()
	get_tree().current_scene.add_child(bomb)
	
	bomb.global_position = global_position + Vector2(facing_direction * 20, -10)
	bomb.set_direction(facing_direction)
	bomb.set_speed(CAMERA_BOMB_SPEED)
	bomb.set_arc_trajectory(true)

func _update_animation_state() -> void:
	# Don't override attack animation
	if sprite.animation == "attack" and sprite.is_playing():
		return
	
	if not is_on_floor():
		if velocity.y < 0:
			current_state = "jump"
		else:
			current_state = "fall"
	elif abs(velocity.x) > 10:
		current_state = "walk"
	else:
		current_state = "idle"

func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Check if it's an enemy attack
	if area.is_in_group("enemy_attacks"):
		take_damage(10)
		
		# Knockback
		var knockback_direction = global_position.direction_to(area.global_position) * -1
		velocity = knockback_direction * 200
		velocity.y = -150

func take_damage(amount: int) -> void:
	# GameManager.take_damage(amount)
	print("Player took %d damage (GameManager disabled)" % amount)
	
	# Flash effect
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color.WHITE

func heal(amount: int) -> void:
	# GameManager.happiness = min(GameManager.MAX_HAPPINESS, GameManager.happiness + amount)
	# GameManager.energy = min(GameManager.MAX_ENERGY, GameManager.energy + amount)
	print("Player healed %d (GameManager disabled)" % amount)

func _on_character_switched(new_character: String) -> void:
	# Switch character type
	character_type = CharacterType.JENNY if new_character == "jenny" else CharacterType.MARK
	
	# Visual effect
	is_switching = true
	
	# Create switch effect
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(0, 1), 0.2)
	tween.tween_callback(_setup_character)
	tween.tween_property(sprite, "scale", Vector2(1, 1), 0.2)
	tween.finished.connect(func(): is_switching = false)

# Mobile touch controls removed - desktop only

# Interaction system
func get_interaction_area() -> Area2D:
	return interaction_area

func can_interact() -> bool:
	return interaction_area.has_overlapping_areas()

func get_nearest_interactable() -> Node2D:
	var areas = interaction_area.get_overlapping_areas()
	if areas.is_empty():
		return null
	
	var nearest = areas[0]
	var nearest_distance = global_position.distance_to(nearest.global_position)
	
	for area in areas:
		var distance = global_position.distance_to(area.global_position)
		if distance < nearest_distance:
			nearest = area
			nearest_distance = distance
	
	return nearest

# Inventory functions
func pickup_item(item_type: ItemType, amount: int = 1) -> bool:
	if not inventory:
		print("No inventory available!")
		return false
	
	var item_stack = ItemStack.new(item_type, amount)
	
	# Try to add the item to inventory
	var deposited_count = inventory.try_add_item(item_stack)
	if deposited_count > 0:
		print("Picked up: %s x%d" % [item_type.name, deposited_count])
		return true
	else:
		print("Inventory full!")
		return false

func has_item(item_type: ItemType) -> bool:
	if not inventory:
		return false
	# Check all stacks for this item type
	for item_stack in inventory.items:
		if item_stack.item_type == item_type:
			return true
	return false

func get_item_count(item_type: ItemType) -> int:
	if not inventory:
		return 0
	var total_count = 0
	for item_stack in inventory.items:
		if item_stack.item_type == item_type:
			total_count += item_stack.count
	return total_count

func remove_item_by_type(item_type: ItemType, amount: int = 1) -> bool:
	if not inventory:
		return false
	# Find and remove items of this type
	for item_stack in inventory.items:
		if item_stack.item_type == item_type:
			if item_stack.count >= amount:
				item_stack.count -= amount
				if item_stack.count <= 0:
					inventory.remove_item(item_stack)
				return true
	return false
