extends CanvasLayer
## Custom Dialogue UI System
## Handles dialogue display, character names, and response options

# Signals for dialogue events
signal dialogue_finished
signal response_selected(response_index: int)
signal dialogue_skipped

# UI references
@onready var dialogue_panel = $DialoguePanel
@onready var dialogue_box = $DialoguePanel/DialogueBox
@onready var speaker_name = $DialoguePanel/DialogueBox/DialogueContent/SpeakerName
@onready var dialogue_text = $DialoguePanel/DialogueBox/DialogueContent/DialogueText
@onready var responses_container = $DialoguePanel/DialogueBox/DialogueContent/ResponsesContainer
@onready var continue_button = $DialoguePanel/DialogueBox/DialogueContent/ContinueButton
@onready var skip_button = $DialoguePanel/SkipButton

# State
var current_dialogue: Dictionary = {}
var response_buttons: Array[Button] = []
var is_dialogue_active: bool = false

func _ready() -> void:
	_setup_ui()
	_connect_signals()
	hide_dialogue()

func _setup_ui() -> void:
	# Set up dialogue box styling
	dialogue_box.modulate = Color(0.95, 0.95, 0.95, 0.95)
	
	# Initially hide response elements
	continue_button.hide()
	skip_button.hide()

func _connect_signals() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	skip_button.pressed.connect(_on_skip_pressed)

func show_dialogue(dialogue_data: Dictionary) -> void:
	current_dialogue = dialogue_data
	is_dialogue_active = true
	
	# Set speaker name
	if dialogue_data.has("speaker"):
		speaker_name.text = dialogue_data.speaker
		speaker_name.show()
	else:
		speaker_name.hide()
	
	# Set dialogue text
	if dialogue_data.has("text"):
		dialogue_text.text = dialogue_data.text
	
	# Handle responses
	_clear_responses()
	if dialogue_data.has("responses") and dialogue_data.responses.size() > 0:
		_create_response_buttons(dialogue_data.responses)
		continue_button.hide()
	else:
		continue_button.show()
	
	# Show the dialogue
	dialogue_panel.show()
	skip_button.show()
	
	# Play dialogue sound effect
	if AudioManager:
		AudioManager.play_sfx("dialogue_open")

func hide_dialogue() -> void:
	is_dialogue_active = false
	dialogue_panel.hide()
	skip_button.hide()
	_clear_responses()

func _create_response_buttons(responses: Array) -> void:
	for i in range(responses.size()):
		var response_button = Button.new()
		response_button.text = responses[i]
		response_button.theme_override_font_sizes["font_size"] = 14
		response_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		# Connect button signal
		response_button.pressed.connect(_on_response_pressed.bind(i))
		
		# Add to container and track
		responses_container.add_child(response_button)
		response_buttons.append(response_button)

func _clear_responses() -> void:
	for button in response_buttons:
		if button and is_instance_valid(button):
			button.queue_free()
	response_buttons.clear()

func _on_continue_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("dialogue_continue")
	hide_dialogue()
	dialogue_finished.emit()

func _on_response_pressed(response_index: int) -> void:
	if AudioManager:
		AudioManager.play_sfx("dialogue_select")
	hide_dialogue()
	response_selected.emit(response_index)

func _on_skip_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("dialogue_skip")
	hide_dialogue()
	dialogue_skipped.emit()

func _input(event: InputEvent) -> void:
	if not is_dialogue_active:
		return
	
	# Allow skipping with Escape or specific action
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("skip_dialogue"):
		_on_skip_pressed()
	# Continue with Space or Enter
	elif event.is_action_pressed("ui_accept") and continue_button.visible:
		_on_continue_pressed()

# Helper method for external systems to check if dialogue is active
func is_showing_dialogue() -> bool:
	return is_dialogue_active

# Method to update dialogue text (for typewriter effects, etc.)
func update_dialogue_text(new_text: String) -> void:
	dialogue_text.text = new_text