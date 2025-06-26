extends Control

var current_category: FeedbackManager.FeedbackCategory
var current_rating: int = 0
var level_name: String = ""

@onready var title_label = $Background/VBox/Title
@onready var question_label = $Background/VBox/Question
@onready var star_buttons = $Background/VBox/StarRating.get_children()
@onready var comment_input = $Background/VBox/CommentInput
@onready var skip_button = $Background/VBox/Buttons/SkipButton
@onready var submit_button = $Background/VBox/Buttons/SubmitButton

func _ready():
	# Connect star buttons
	for i in range(star_buttons.size()):
		var star_button = star_buttons[i]
		star_button.pressed.connect(_on_star_pressed.bind(i + 1))
	
	# Connect action buttons
	skip_button.pressed.connect(_on_skip_pressed)
	submit_button.pressed.connect(_on_submit_pressed)
	
	# Pause the game while showing feedback
	get_tree().paused = true

func setup_quick_rating(category: FeedbackManager.FeedbackCategory):
	"""Setup for quick rating feedback"""
	current_category = category
	title_label.text = "Quick Feedback"
	question_label.text = "How would you rate: " + FeedbackManager.category_names[category] + "?"

func setup_level_completion_feedback(level: String):
	"""Setup for level completion feedback"""
	level_name = level
	current_category = FeedbackManager.FeedbackCategory.FUN_FACTOR
	title_label.text = "Level Complete!"
	question_label.text = "How fun was " + level + "?"

func _on_star_pressed(rating: int):
	"""Handle star button press"""
	current_rating = rating
	update_star_display()
	
	# Enable submit button
	submit_button.disabled = false

func update_star_display():
	"""Update visual star display based on current rating"""
	for i in range(star_buttons.size()):
		var star_button = star_buttons[i]
		if i < current_rating:
			star_button.modulate = Color.YELLOW
			star_button.text = "★"
		else:
			star_button.modulate = Color.GRAY
			star_button.text = "☆"

func _on_submit_pressed():
	"""Submit the feedback"""
	if current_rating > 0:
		var comment = comment_input.text
		FeedbackManager.submit_quick_rating(current_category, current_rating, comment)
		
		# Show thank you briefly
		show_thank_you_message()
	
	close_prompt()

func _on_skip_pressed():
	"""Skip feedback collection"""
	close_prompt()

func show_thank_you_message():
	"""Show brief thank you message"""
	title_label.text = "Thank You!"
	question_label.text = "Your feedback helps improve the game!"
	
	# Hide other UI elements
	$Background/VBox/StarRating.visible = false
	$Background/VBox/CommentLabel.visible = false
	$Background/VBox/CommentInput.visible = false
	$Background/VBox/Buttons.visible = false
	
	# Auto-close after 2 seconds
	await get_tree().create_timer(2.0).timeout

func close_prompt():
	"""Close the feedback prompt and resume game"""
	get_tree().paused = false
	queue_free()

func _input(event):
	"""Handle input for quick dismissal"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_on_skip_pressed()