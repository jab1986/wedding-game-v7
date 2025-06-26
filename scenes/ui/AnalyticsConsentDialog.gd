extends AcceptDialog
## Analytics Consent Dialog
## Provides user-friendly analytics consent interface

@onready var description_label = $VBoxContainer/DescriptionLabel
@onready var benefits_label = $VBoxContainer/BenefitsLabel
@onready var privacy_label = $VBoxContainer/PrivacyLabel
@onready var anonymous_checkbox = $VBoxContainer/AnonymousCheckBox
@onready var accept_button = $VBoxContainer/ButtonContainer/AcceptButton
@onready var decline_button = $VBoxContainer/ButtonContainer/DeclineButton

signal consent_given(accepted: bool, anonymous: bool)

func _ready() -> void:
	# Set up dialog properties
	title = "Help Improve the Game"
	unresizable = false
	
	# Set up content
	_setup_content()
	
	# Connect buttons
	accept_button.pressed.connect(_on_accept_pressed)
	decline_button.pressed.connect(_on_decline_pressed)
	
	# Make dialog modal
	popup_exclusive = true

func _setup_content() -> void:
	description_label.text = """This wedding game can collect optional analytics to help improve your experience.

Analytics help us:"""
	
	benefits_label.text = """• Identify difficult areas that need balancing
• Detect performance issues on different devices
• Understand which features players enjoy most
• Fix bugs and crashes more effectively"""
	
	privacy_label.text = """Your privacy is important:
• No personal information is collected
• All data can be made anonymous
• You can change these settings anytime
• Data stays on your device unless you choose to share"""
	
	anonymous_checkbox.text = "Keep all data anonymous (recommended)"
	anonymous_checkbox.button_pressed = true
	
	accept_button.text = "Enable Analytics"
	decline_button.text = "No Thanks"

func show_consent_dialog() -> void:
	popup_centered(Vector2i(480, 400))

func _on_accept_pressed() -> void:
	var anonymous_mode = anonymous_checkbox.button_pressed
	consent_given.emit(true, anonymous_mode)
	hide()

func _on_decline_pressed() -> void:
	consent_given.emit(false, false)
	hide()