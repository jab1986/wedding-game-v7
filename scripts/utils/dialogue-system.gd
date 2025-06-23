extends Node
class_name DialogueSystem
## Wrapper for Dialogue Manager integration
## Handles character conversations and cutscenes

signal dialogue_started(character_name: String)
signal dialogue_finished()
signal response_selected(response_index: int)

# Current dialogue state
var is_dialogue_active: bool = false
var current_speaker: String = ""
var dialogue_balloon = null

func _ready():
	# Connect to DialogueManager signals
	# DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	pass
	
func start_dialogue(resource_name: String, title: String = "start", character_name: String = "") -> void:
	if is_dialogue_active:
		print("Dialogue already active!")
		return
	
	is_dialogue_active = true
	current_speaker = character_name
	
	# Pause the game during dialogue
	get_tree().paused = true
	
	# Load and start the dialogue (DialogueManager temporarily disabled)
	print("Dialogue system temporarily disabled")
	print("Would start dialogue: %s with %s" % [resource_name, character_name])
	_end_dialogue()

func _on_dialogue_ended(resource):
	_end_dialogue()

func _end_dialogue():
	is_dialogue_active = false
	current_speaker = ""
	
	# Unpause the game
	get_tree().paused = false
	
	dialogue_finished.emit()
	print("Dialogue ended")

# Utility functions for common wedding characters
func talk_to_glen() -> void:
	start_dialogue("glen_conversations", "start", "Glen")

func talk_to_jenny() -> void:
	start_dialogue("jenny_conversations", "start", "Jenny")

func talk_to_mark() -> void:
	start_dialogue("mark_conversations", "start", "Mark")

func wedding_ceremony_dialogue() -> void:
	start_dialogue("wedding_ceremony", "start", "Officiant")