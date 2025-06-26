extends Node

signal feedback_submitted(feedback_data: Dictionary)

var feedback_data: Dictionary = {}
var session_id: String = ""
var session_start_time: float
var current_level: String = ""

# Feedback collection settings (DISABLED FOR PLAYTESTING)
var collect_feedback: bool = false  # Disabled to prevent popup interruptions
var feedback_interval: float = 60.0  # Ask for feedback every minute
var last_feedback_time: float = 0.0

# Quick rating categories
enum FeedbackCategory {
	CONTROLS,
	DIFFICULTY,
	FUN_FACTOR,
	VISUAL_APPEAL,
	AUDIO_QUALITY,
	STORY_ENGAGEMENT
}

var category_names: Dictionary = {
	FeedbackCategory.CONTROLS: "Controls & Movement",
	FeedbackCategory.DIFFICULTY: "Difficulty Level", 
	FeedbackCategory.FUN_FACTOR: "Fun Factor",
	FeedbackCategory.VISUAL_APPEAL: "Visual Appeal",
	FeedbackCategory.AUDIO_QUALITY: "Audio Quality",
	FeedbackCategory.STORY_ENGAGEMENT: "Story & Characters"
}

func _ready():
	session_id = generate_session_id()
	session_start_time = Time.get_ticks_msec()
	feedback_data = initialize_feedback_data()
	
	# Connect to game events for automatic feedback triggers (if signals exist)
	if GameManager:
		if GameManager.has_signal("level_completed"):
			GameManager.connect("level_completed", _on_level_completed)
		if GameManager.has_signal("player_died"):
			GameManager.connect("player_died", _on_player_died)

func generate_session_id() -> String:
	var timestamp = Time.get_datetime_string_from_system()
	var random_suffix = str(randi() % 10000).pad_zeros(4)
	return "feedback_session_" + timestamp.replace(":", "-").replace(" ", "_") + "_" + random_suffix

func initialize_feedback_data() -> Dictionary:
	return {
		"session_id": session_id,
		"start_time": session_start_time,
		"game_version": "1.0.0",
		"platform": OS.get_name(),
		"ratings": {},
		"text_feedback": [],
		"gameplay_events": [],
		"completion_data": {},
		"technical_issues": []
	}

func _process(_delta):
	if not collect_feedback:
		return
		
	# Check if it's time for periodic feedback
	var current_time = Time.get_ticks_msec()
	if current_time - last_feedback_time > feedback_interval * 1000:
		show_periodic_feedback_prompt()
		last_feedback_time = current_time

func show_periodic_feedback_prompt():
	"""Show a quick rating prompt during gameplay"""
	var feedback_ui = preload("res://scenes/ui/FeedbackPrompt.tscn").instantiate()
	get_tree().current_scene.add_child(feedback_ui)
	feedback_ui.setup_quick_rating(FeedbackCategory.FUN_FACTOR)

func show_level_feedback_prompt(level_name: String):
	"""Show feedback prompt after completing a level"""
	var feedback_ui = preload("res://scenes/ui/FeedbackPrompt.tscn").instantiate()
	get_tree().current_scene.add_child(feedback_ui)
	feedback_ui.setup_level_completion_feedback(level_name)

func submit_quick_rating(category: FeedbackCategory, rating: int, comment: String = ""):
	"""Submit a quick rating (1-5 stars) for a specific category"""
	var category_name = category_names[category]
	
	if not feedback_data.ratings.has(category_name):
		feedback_data.ratings[category_name] = []
	
	var rating_data = {
		"rating": rating,
		"comment": comment,
		"timestamp": Time.get_ticks_msec(),
		"level": current_level
	}
	
	feedback_data.ratings[category_name].append(rating_data)
	print("Feedback submitted: ", category_name, " - ", rating, " stars")

func submit_text_feedback(feedback_text: String, category: String = "general"):
	"""Submit open-ended text feedback"""
	var text_data = {
		"text": feedback_text,
		"category": category,
		"timestamp": Time.get_ticks_msec(),
		"level": current_level
	}
	
	feedback_data.text_feedback.append(text_data)
	print("Text feedback submitted: ", feedback_text)

func log_gameplay_event(event_type: String, event_data: Dictionary = {}):
	"""Log gameplay events for analysis"""
	var event = {
		"type": event_type,
		"data": event_data,
		"timestamp": Time.get_ticks_msec(),
		"level": current_level
	}
	
	feedback_data.gameplay_events.append(event)

func log_technical_issue(issue_description: String, severity: String = "medium"):
	"""Log technical issues or bugs"""
	var issue = {
		"description": issue_description,
		"severity": severity,
		"timestamp": Time.get_ticks_msec(),
		"level": current_level
	}
	
	feedback_data.technical_issues.append(issue)

func set_current_level(level_name: String):
	"""Update the current level for context"""
	current_level = level_name
	log_gameplay_event("level_entered", {"level": level_name})

func export_feedback_data() -> String:
	"""Export all feedback data as JSON string"""
	feedback_data.end_time = Time.get_ticks_msec()
	feedback_data.session_duration = feedback_data.end_time - feedback_data.start_time
	
	return JSON.stringify(feedback_data, "\t")

func save_feedback_to_file():
	"""Save feedback data to file for collection"""
	var file_path = "user://feedback_" + session_id + ".json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		file.store_string(export_feedback_data())
		file.close()
		print("Feedback saved to: ", file_path)
		return file_path
	else:
		print("Error saving feedback file")
		return ""

# Event handlers
func _on_level_completed(level_name: String):
	log_gameplay_event("level_completed", {"level": level_name})
	show_level_feedback_prompt(level_name)

func _on_player_died(cause: String):
	log_gameplay_event("player_died", {"cause": cause})
	
	# Ask for difficulty feedback if player dies repeatedly
	if get_death_count() >= 3:
		show_difficulty_feedback_prompt()

func show_difficulty_feedback_prompt():
	"""Show specific difficulty feedback prompt"""
	var feedback_ui = preload("res://scenes/ui/FeedbackPrompt.tscn").instantiate()
	get_tree().current_scene.add_child(feedback_ui)
	feedback_ui.setup_quick_rating(FeedbackCategory.DIFFICULTY)

func get_death_count() -> int:
	"""Count how many times player died in current session"""
	var death_count = 0
	for event in feedback_data.gameplay_events:
		if event.type == "player_died":
			death_count += 1
	return death_count

# Public API for triggering feedback collection
func request_feedback(_category: FeedbackCategory):
	"""Manually request feedback for a specific category"""
	show_periodic_feedback_prompt()

func show_final_feedback():
	"""Show comprehensive feedback form at end of session"""
	var feedback_ui = preload("res://scenes/ui/FinalFeedbackForm.tscn").instantiate()
	get_tree().current_scene.add_child(feedback_ui)