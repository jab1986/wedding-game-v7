extends CharacterBody2D
class_name NPC
## Base NPC class for all non-player characters
## Handles dialogue, wandering, and interactions

signal dialogue_started()
signal dialogue_finished()
signal interacted()

# NPC configuration
@export_group("Character")
@export var npc_name: String = "NPC"
@export var npc_portrait: Texture2D
@export var sprite_frames: SpriteFrames

@export_group("Behavior")
@export var can_wander: bool = false
@export var wander_distance: float = 100.0
@export var wander_speed: float = 50.0
@export var interactive: bool = true
@export var face_player_when_talking: bool = true

@export_group("Dialogue")
@export_multiline var dialogue_lines: Array[String] = ["..."]
@export var dialogue_sound: AudioStream
@export var use_random_dialogue: bool = false

# Node references
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var dialogue_bubble: Node2D = $DialogueBubble
@onready var name_label: Label = $NameLabel
@onready var emote_position: Marker2D = $EmotePosition
@onready var wander_timer: Timer = $WanderTimer
@onready var state_machine: Node = $StateMachine

# State
var current_dialogue_index: int = 0
var is_speaking: bool = false
var home_position: Vector2
var wander_target: Vector2
var player_reference: Player = null
var is_wandering: bool = false

# Constants
const GRAVITY := 980.0
const DIALOGUE_COOLDOWN := 0.5

func _ready() -> void:
	# Set up sprite
	if sprite_frames:
		sprite.sprite_frames = sprite_frames
	sprite.play("idle")
	
	# Set up name label
	if name_label:
		name_label.text = npc_name
		name_label.visible = true
	
	# Set up collision
	collision_layer = 64  # NPC layer
	collision_mask = 1  # Only collide with world
	
	# Store home position
	home_position = global_position
	wander_target = home_position
	
	# Set up interaction area
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered_interaction)
		interaction_area.body_exited.connect(_on_body_exited_interaction)
	
	# Set up wandering
	if can_wander and wander_timer:
		wander_timer.timeout.connect(_on_wander_timer_timeout)
		wander_timer.start(randf_range(2.0, 5.0))
	
	# Hide dialogue bubble initially
	if dialogue_bubble:
		dialogue_bubble.visible = false

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
	
	# Wandering behavior
	if can_wander and is_wandering and not is_speaking:
		_handle_wandering(delta)
	else:
		# Apply friction when not wandering
		velocity.x = move_toward(velocity.x, 0, wander_speed * 2 * delta)
	
	# Face player when talking
	if is_speaking and face_player_when_talking and player_reference:
		sprite.flip_h = global_position.x > player_reference.global_position.x
	
	# Apply movement
	move_and_slide()
	
	# Update animation
	_update_animation()

func _handle_wandering(delta: float) -> void:
	var direction_to_target = (wander_target.x - global_position.x)
	var distance_to_target = abs(direction_to_target)
	
	if distance_to_target > 5:
		# Move towards target
		var direction = sign(direction_to_target)
		velocity.x = move_toward(velocity.x, direction * wander_speed, wander_speed * 2 * delta)
		sprite.flip_h = direction < 0
	else:
		# Reached target, stop wandering
		is_wandering = false
		velocity.x = 0

func _update_animation() -> void:
	if abs(velocity.x) > 10:
		sprite.play("walk")
	else:
		sprite.play("idle")

func interact() -> void:
	if is_speaking:
		return
	
	interacted.emit()
	
	# Choose dialogue line
	var dialogue_text: String
	if use_random_dialogue and dialogue_lines.size() > 0:
		dialogue_text = dialogue_lines[randi() % dialogue_lines.size()]
	else:
		dialogue_text = dialogue_lines[current_dialogue_index]
		current_dialogue_index = (current_dialogue_index + 1) % dialogue_lines.size()
	
	# Start dialogue
	speak(dialogue_text)

func speak(text: String, duration: float = 3.0) -> void:
	if is_speaking:
		return
	
	is_speaking = true
	dialogue_started.emit()
	
	# Show dialogue bubble
	if dialogue_bubble:
		dialogue_bubble.show_text(text)
		dialogue_bubble.visible = true
	
	# Play dialogue sound
	if dialogue_sound:
		AudioManager.play_sfx(dialogue_sound)
	
	# Stop wandering
	if can_wander:
		is_wandering = false
		velocity.x = 0
	
	# Hide dialogue after duration
	await get_tree().create_timer(duration).timeout
	
	if dialogue_bubble:
		dialogue_bubble.visible = false
	
	is_speaking = false
	dialogue_finished.emit()

func show_emote(emote: String, duration: float = 1.0) -> void:
	if not emote_position:
		return
	
	# Create emote label
	var emote_label = Label.new()
	emote_label.text = emote
	emote_label.add_theme_font_size_override("font_size", 24)
	emote_label.position = emote_position.position
	add_child(emote_label)
	
	# Animate emote
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(emote_label, "position:y", emote_label.position.y - 20, duration)
	tween.tween_property(emote_label, "modulate:a", 0.0, duration)
	tween.finished.connect(emote_label.queue_free)

func give_item(item_name: String, target_player: Player) -> void:
	if not target_player:
		return
	
	# Create item visual
	var item_sprite = Sprite2D.new()
	item_sprite.texture = load("res://assets/sprites/items/" + item_name + ".png")
	item_sprite.position = Vector2(0, -20)
	add_child(item_sprite)
	
	# Animate to player
	var tween = create_tween()
	var target_pos = to_local(target_player.global_position)
	tween.tween_property(item_sprite, "position", target_pos, 0.5)
	tween.finished.connect(func():
		item_sprite.queue_free()
		GameManager.add_item(item_name)
		speak("Here's some " + item_name.replace("_", " ") + "!")
	)

func set_home_position(pos: Vector2) -> void:
	home_position = pos

func return_home() -> void:
	wander_target = home_position
	is_wandering = true

# Signal callbacks
func _on_body_entered_interaction(body: Node2D) -> void:
	if body is Player:
		player_reference = body
		
		# Show interaction prompt
		if interactive:
			# This would show an interaction prompt above the NPC
			pass

func _on_body_exited_interaction(body: Node2D) -> void:
	if body == player_reference:
		player_reference = null
		
		# Hide interaction prompt
		pass

func _on_wander_timer_timeout() -> void:
	if not is_speaking and can_wander:
		# Choose new wander target
		var wander_offset = randf_range(-wander_distance, wander_distance)
		wander_target = Vector2(home_position.x + wander_offset, home_position.y)
		is_wandering = true
		
		# Restart timer with random interval
		wander_timer.start(randf_range(3.0, 7.0))

# Special NPC behaviors (override in child classes)
func special_behavior() -> void:
	# Override this in specific NPCs like Glen, Quinn, etc.
	pass

# Save/Load NPC state
func save_state() -> Dictionary:
	return {
		"position": global_position,
		"dialogue_index": current_dialogue_index,
		"home_position": home_position
	}

func load_state(data: Dictionary) -> void:
	if data.has("position"):
		global_position = data["position"]
	if data.has("dialogue_index"):
		current_dialogue_index = data["dialogue_index"]
	if data.has("home_position"):
		home_position = data["home_position"]