extends Node
class_name StateMachine
## Generic State Machine for managing entity states
## Can be used for player, enemies, NPCs, etc.

signal state_changed(old_state: State, new_state: State)

# Current state
var current_state: State
var previous_state: State
var states: Dictionary = {}

# State history for debugging
var state_history: Array[String] = []
var max_history_size: int = 10

func _ready() -> void:
	# Initialize all child states
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.state_machine = self
			child.ready()
	
	# Set initial state to first child
	if get_child_count() > 0 and get_child(0) is State:
		current_state = get_child(0)
		current_state.enter()
		state_history.append(current_state.name)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

## Transition to a new state by name
func transition_to(state_name: String, data: Dictionary = {}) -> void:
	if not state_name in states:
		push_error("State '%s' not found in state machine" % state_name)
		return
	
	var new_state = states[state_name]
	
	# Don't transition to the same state unless it allows re-entry
	if new_state == current_state and not current_state.allow_reentry:
		return
	
	# Exit current state
	if current_state:
		current_state.exit()
		previous_state = current_state
	
	# Enter new state
	current_state = new_state
	current_state.enter(data)
	
	# Update history
	state_history.append(state_name)
	if state_history.size() > max_history_size:
		state_history.pop_front()
	
	# Emit signal
	state_changed.emit(previous_state, current_state)

## Get current state name
func get_current_state_name() -> String:
	return current_state.name if current_state else ""

## Check if in specific state
func is_in_state(state_name: String) -> bool:
	return current_state and current_state.name == state_name

## Get state by name
func get_state(state_name: String) -> State:
	return states.get(state_name, null)

## Force exit current state (use carefully)
func force_exit_current_state() -> void:
	if current_state:
		current_state.exit()
		previous_state = current_state
		current_state = null

# Base State class
class_name State
extends Node
## Base class for all states in a state machine

# Reference to the state machine
var state_machine: StateMachine

# Configuration
@export var allow_reentry: bool = false  # Can transition to self

# Called when state machine is ready
func ready() -> void:
	pass

# Called when entering this state
func enter(data: Dictionary = {}) -> void:
	pass

# Called when exiting this state
func exit() -> void:
	pass

# Called every frame
func update(_delta: float) -> void:
	pass

# Called every physics frame
func physics_update(_delta: float) -> void:
	pass

# Handle input events
func handle_input(_event: InputEvent) -> void:
	pass

# Utility function to transition to another state
func transition_to(state_name: String, data: Dictionary = {}) -> void:
	if state_machine:
		state_machine.transition_to(state_name, data)

# Example States for Player
class IdleState extends State:
	func enter(_data: Dictionary = {}) -> void:
		owner.sprite.play("idle")
	
	func physics_update(_delta: float) -> void:
		# Check for movement input
		if Input.get_axis("move_left", "move_right") != 0:
			transition_to("Walk")
		elif Input.is_action_just_pressed("jump") and owner.is_on_floor():
			transition_to("Jump")
		elif Input.is_action_just_pressed("attack"):
			transition_to("Attack")

class WalkState extends State:
	func enter(_data: Dictionary = {}) -> void:
		owner.sprite.play("walk")
	
	func physics_update(delta: float) -> void:
		# Handle movement
		var direction = Input.get_axis("move_left", "move_right")
		
		if direction == 0:
			transition_to("Idle")
		else:
			owner.velocity.x = move_toward(owner.velocity.x, direction * owner.SPEED, owner.ACCELERATION * delta)
			owner.sprite.flip_h = direction < 0
		
		# Check for other transitions
		if Input.is_action_just_pressed("jump") and owner.is_on_floor():
			transition_to("Jump")
		elif Input.is_action_just_pressed("attack"):
			transition_to("Attack")

class JumpState extends State:
	func enter(_data: Dictionary = {}) -> void:
		owner.sprite.play("jump")
		owner.velocity.y = owner.JUMP_VELOCITY
	
	func physics_update(delta: float) -> void:
		# Air movement
		var direction = Input.get_axis("move_left", "move_right")
		if direction != 0:
			owner.velocity.x = move_toward(owner.velocity.x, direction * owner.SPEED * 0.8, owner.ACCELERATION * delta)
			owner.sprite.flip_h = direction < 0
		
		# Check for landing
		if owner.is_on_floor():
			if abs(owner.velocity.x) > 10:
				transition_to("Walk")
			else:
				transition_to("Idle")
		
		# Air attack
		if Input.is_action_just_pressed("attack"):
			transition_to("AirAttack")

class AttackState extends State:
	var attack_finished: bool = false
	
	func enter(_data: Dictionary = {}) -> void:
		owner.sprite.play("attack")
		attack_finished = false
		owner.sprite.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)
		
		# Slow down during attack
		owner.velocity.x *= 0.5
	
	func exit() -> void:
		attack_finished = false
	
	func _on_animation_finished() -> void:
		attack_finished = true
	
	func physics_update(_delta: float) -> void:
		if attack_finished:
			if abs(owner.velocity.x) > 10:
				transition_to("Walk")
			else:
				transition_to("Idle")

# Example States for Enemy AI
class EnemyIdleState extends State:
	var idle_time: float = 0.0
	var idle_duration: float = 2.0
	
	func enter(_data: Dictionary = {}) -> void:
		owner.sprite.play("idle")
		idle_time = 0.0
		idle_duration = randf_range(1.5, 3.0)
	
	func physics_update(delta: float) -> void:
		idle_time += delta
		
		# Look for player
		if owner.player_in_range:
			transition_to("Chase")
		elif idle_time >= idle_duration:
			transition_to("Patrol")

class EnemyPatrolState extends State:
	var patrol_direction: int = 1
	
	func enter(_data: Dictionary = {}) -> void:
		owner.sprite.play("walk")
		patrol_direction = 1 if randf() > 0.5 else -1
	
	func physics_update(_delta: float) -> void:
		# Move in patrol direction
		owner.velocity.x = patrol_direction * owner.PATROL_SPEED
		owner.sprite.flip_h = patrol_direction < 0
		
		# Check for walls or ledges
		if owner.is_on_wall() or not owner.is_floor_ahead():
			patrol_direction *= -1
		
		# Look for player
		if owner.player_in_range:
			transition_to("Chase")
		
		# Random chance to idle
		if randf() < 0.01:
			transition_to("Idle")

class EnemyChaseState extends State:
	func enter(_data: Dictionary = {}) -> void:
		owner.sprite.play("run")
	
	func physics_update(_delta: float) -> void:
		if not owner.player_target:
			transition_to("Idle")
			return
		
		# Move toward player
		var direction = sign(owner.player_target.global_position.x - owner.global_position.x)
		owner.velocity.x = direction * owner.CHASE_SPEED
		owner.sprite.flip_h = direction < 0
		
		# Check attack range
		var distance = owner.global_position.distance_to(owner.player_target.global_position)
		if distance <= owner.ATTACK_RANGE:
			transition_to("Attack")
		elif distance > owner.CHASE_RANGE:
			transition_to("Idle")

class EnemyAttackState extends State:
	var attack_cooldown: float = 0.0
	
	func enter(_data: Dictionary = {}) -> void:
		owner.sprite.play("attack")
		attack_cooldown = 0.0
		owner.velocity.x = 0
		
		# Perform attack
		owner.perform_attack()
	
	func physics_update(delta: float) -> void:
		attack_cooldown += delta
		
		if attack_cooldown >= owner.ATTACK_COOLDOWN:
			# Check if player still in range
			if owner.player_in_range and owner.player_in_attack_range:
				owner.perform_attack()
				attack_cooldown = 0.0
			else:
				transition_to("Chase" if owner.player_in_range else "Idle")