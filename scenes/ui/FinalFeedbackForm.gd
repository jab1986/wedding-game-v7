extends Control

var overall_rating: int = 0

@onready var overall_stars = $Background/ScrollContainer/VBox/OverallRating.get_children()
@onready var favorite_input = $Background/ScrollContainer/VBox/FavoritePartInput
@onready var improvement_input = $Background/ScrollContainer/VBox/ImprovementInput
@onready var recommend_choice = $Background/ScrollContainer/VBox/RecommendChoice
@onready var technical_input = $Background/ScrollContainer/VBox/TechnicalIssuesInput
@onready var export_button = $Background/ScrollContainer/VBox/Buttons/ExportButton
@onready var submit_button = $Background/ScrollContainer/VBox/Buttons/SubmitButton

func _ready():
	# Setup star rating buttons
	for i in range(overall_stars.size()):
		var star_button = overall_stars[i]
		star_button.pressed.connect(_on_overall_star_pressed.bind(i + 1))
	
	# Setup recommendation options
	recommend_choice.add_item("Select an option")
	recommend_choice.add_item("Yes, definitely!")
	recommend_choice.add_item("Yes, probably")
	recommend_choice.add_item("Maybe")
	recommend_choice.add_item("Probably not")
	recommend_choice.add_item("No, not really")
	
	# Connect buttons
	export_button.pressed.connect(_on_export_pressed)
	submit_button.pressed.connect(_on_submit_pressed)
	
	# Pause game
	get_tree().paused = true

func _on_overall_star_pressed(rating: int):
	"""Handle overall rating star press"""
	overall_rating = rating
	update_overall_stars()

func update_overall_stars():
	"""Update visual display of overall rating stars"""
	for i in range(overall_stars.size()):
		var star_button = overall_stars[i]
		if i < overall_rating:
			star_button.modulate = Color.YELLOW
			star_button.text = "★"
		else:
			star_button.modulate = Color.GRAY
			star_button.text = "☆"

func _on_export_pressed():
	"""Export feedback data to file"""
	# Submit current form data first
	submit_form_data()
	
	# Export to file
	var file_path = FeedbackManager.save_feedback_to_file()
	if file_path != "":
		show_export_success_message(file_path)
	else:
		show_export_error_message()

func _on_submit_pressed():
	"""Submit feedback and close form"""
	submit_form_data()
	
	# Show thank you message
	show_thank_you_message()
	
	# Close after delay
	await get_tree().create_timer(3.0).timeout
	close_form()

func submit_form_data():
	"""Submit the final form data to FeedbackManager"""
	# Submit overall rating
	if overall_rating > 0:
		FeedbackManager.submit_quick_rating(
			FeedbackManager.FeedbackCategory.FUN_FACTOR, 
			overall_rating, 
			"Overall game rating"
		)
	
	# Submit text feedback
	var favorite_text = favorite_input.text.strip_edges()
	if favorite_text != "":
		FeedbackManager.submit_text_feedback(favorite_text, "favorite_part")
	
	var improvement_text = improvement_input.text.strip_edges()
	if improvement_text != "":
		FeedbackManager.submit_text_feedback(improvement_text, "improvement_suggestions")
	
	var technical_text = technical_input.text.strip_edges()
	if technical_text != "":
		FeedbackManager.log_technical_issue(technical_text, "user_reported")
	
	# Submit recommendation data
	var recommend_index = recommend_choice.selected
	if recommend_index > 0:
		var recommend_text = recommend_choice.get_item_text(recommend_index)
		FeedbackManager.submit_text_feedback(recommend_text, "recommendation")

func show_export_success_message(file_path: String):
	"""Show success message for data export"""
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "Feedback data exported successfully!\n\nFile saved to:\n" + file_path + "\n\nYou can share this file with the developers."
	dialog.title = "Export Successful"
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(dialog.queue_free)

func show_export_error_message():
	"""Show error message for failed export"""
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "Sorry, there was an error exporting your feedback data. Please try again or contact support."
	dialog.title = "Export Failed"
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(dialog.queue_free)

func show_thank_you_message():
	"""Show thank you message"""
	# Hide all form elements
	$Background/ScrollContainer.visible = false
	
	# Create thank you content
	var thank_you_label = Label.new()
	thank_you_label.text = "Thank You for Your Feedback!\n\nYour input helps us make the Wedding Game better for everyone.\n\nHappy gaming! 💒✨"
	thank_you_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	thank_you_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	thank_you_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	$Background.add_child(thank_you_label)
	thank_you_label.anchors_preset = Control.PRESET_FULL_RECT
	thank_you_label.offset_left = 20
	thank_you_label.offset_right = -20
	thank_you_label.offset_top = 20
	thank_you_label.offset_bottom = -20

func close_form():
	"""Close the feedback form and resume game"""
	get_tree().paused = false
	queue_free()

func _input(event):
	"""Handle escape key to close form"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			close_form()