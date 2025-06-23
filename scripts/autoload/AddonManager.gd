extends Node
## AddonManager - Integrates all addons (Dialogue Manager, Beehave, Phantom Camera)
## Provides unified interface for wedding game features

signal addon_system_ready(addon_name: String)

# Addon system references
var dialogue_system: DialogueSystem
var ai_behavior_manager: AIBehaviorManager  
var camera_manager: CameraManager

# Integration state
var addons_ready := {
	"dialogue": false,
	"beehave": false, 
	"phantom_camera": false
}

func _ready() -> void:
	print("AddonManager initializing...")
	
	# Initialize addon systems
	_setup_dialogue_system()
	_setup_ai_system()
	_setup_camera_system()
	
	# Wait for all systems to be ready
	await _wait_for_addons()
	print("All addon systems ready!")

func _setup_dialogue_system() -> void:
	dialogue_system = preload("res://scripts/utils/dialogue-system.gd").new()
	dialogue_system.name = "DialogueSystem"
	add_child(dialogue_system)
	
	addons_ready["dialogue"] = true
	addon_system_ready.emit("dialogue")
	print("Dialogue system ready")

func _setup_ai_system() -> void:
	ai_behavior_manager = preload("res://scripts/utils/ai-behavior-manager.gd").new()
	ai_behavior_manager.name = "AIBehaviorManager"
	add_child(ai_behavior_manager)
	
	addons_ready["beehave"] = true
	addon_system_ready.emit("beehave")
	print("AI Behavior system ready")

func _setup_camera_system() -> void:
	camera_manager = preload("res://scripts/utils/camera-manager.gd").new()
	camera_manager.name = "CameraManager"
	add_child(camera_manager)
	
	addons_ready["phantom_camera"] = true
	addon_system_ready.emit("phantom_camera")
	print("Camera system ready")

func _wait_for_addons() -> void:
	while not all_addons_ready():
		await get_tree().process_frame

func all_addons_ready() -> bool:
	for addon in addons_ready.values():
		if not addon:
			return false
	return true

## Dialogue System Interface
func start_conversation(character_name: String) -> void:
	match character_name.to_lower():
		"glen":
			dialogue_system.talk_to_glen()
		"jenny":
			dialogue_system.talk_to_jenny()
		"mark":
			dialogue_system.talk_to_mark()
		_:
			print("No dialogue found for character: " + character_name)

func start_wedding_ceremony() -> void:
	dialogue_system.wedding_ceremony_dialogue()

## AI Behavior Interface  
func setup_npc_behavior(npc: Node, personality: String) -> void:
	ai_behavior_manager.setup_guest_behavior(npc, personality)

func setup_boss_ai(boss: Node, boss_type: String) -> void:
	ai_behavior_manager.setup_boss_behavior(boss, boss_type)

## Camera System Interface
func setup_player_camera(player: Node2D) -> void:
	camera_manager.setup_player_camera(player)

func start_cutscene(positions: Array, durations: Array = []) -> void:
	camera_manager.start_cutscene(positions, durations)

func shake_camera(intensity: float, duration: float) -> void:
	camera_manager.shake_camera(intensity, duration)

func zoom_camera(target_zoom: Vector2, duration: float = 1.0) -> void:
	camera_manager.zoom_to(target_zoom, duration)

## Wedding-specific integrations
func wedding_disaster_sequence() -> void:
	# Combine all addons for dramatic wedding disasters
	camera_manager.boss_fight_camera()
	start_conversation("glen")
	
func acids_joe_boss_fight(boss: Node) -> void:
	# Setup boss AI and camera for epic fight
	setup_boss_ai(boss, "acids_joe")
	camera_manager.boss_fight_camera()
	
func romantic_moment() -> void:
	# Camera and dialogue for sweet moments
	camera_manager.romantic_moment_camera()
	start_conversation("jenny")

## Debug functions
func test_all_systems() -> void:
	print("Testing addon integrations...")
	
	# Test dialogue
	await get_tree().create_timer(1.0).timeout
	start_conversation("glen")
	
	# Test camera
	await get_tree().create_timer(2.0).timeout
	shake_camera(10.0, 0.5)
	
	print("Addon test complete!")