extends Node

"""
Test script for the feedback collection system
Run this to verify all feedback components work correctly
"""

func _ready():
	print("=== Feedback System Test ===")
	
	# Test 1: Basic feedback manager functionality
	test_feedback_manager_basic()
	
	# Test 2: Rating submission
	test_rating_submission()
	
	# Test 3: Text feedback submission
	test_text_feedback()
	
	# Test 4: Gameplay event logging
	test_event_logging()
	
	# Test 5: Data export
	test_data_export()
	
	print("=== All Tests Complete ===")

func test_feedback_manager_basic():
	print("\n--- Test 1: Basic FeedbackManager ---")
	
	# Check if FeedbackManager is available
	if FeedbackManager:
		print("✓ FeedbackManager singleton found")
		print("✓ Session ID:", FeedbackManager.session_id)
		print("✓ Feedback collection enabled:", FeedbackManager.collect_feedback)
	else:
		print("✗ FeedbackManager singleton not found!")

func test_rating_submission():
	print("\n--- Test 2: Rating Submission ---")
	
	# Test quick rating submission
	FeedbackManager.submit_quick_rating(
		FeedbackManager.FeedbackCategory.CONTROLS,
		4,
		"Controls feel responsive"
	)
	print("✓ Controls rating submitted")
	
	FeedbackManager.submit_quick_rating(
		FeedbackManager.FeedbackCategory.FUN_FACTOR,
		5,
		"Really enjoying the wedding theme!"
	)
	print("✓ Fun factor rating submitted")
	
	# Verify ratings were stored
	var ratings = FeedbackManager.feedback_data.ratings
	if ratings.has("Controls & Movement") and ratings.has("Fun Factor"):
		print("✓ Ratings properly stored in feedback data")
	else:
		print("✗ Ratings not found in feedback data")

func test_text_feedback():
	print("\n--- Test 3: Text Feedback ---")
	
	# Test text feedback submission
	FeedbackManager.submit_text_feedback(
		"The wedding theme is charming and the pixel art looks great!",
		"visual_feedback"
	)
	print("✓ Visual feedback submitted")
	
	FeedbackManager.submit_text_feedback(
		"Maybe add more variety to the background music?",
		"audio_suggestion"
	)
	print("✓ Audio suggestion submitted")
	
	# Verify text feedback was stored
	var text_feedback = FeedbackManager.feedback_data.text_feedback
	if text_feedback.size() >= 2:
		print("✓ Text feedback properly stored (", text_feedback.size(), " entries)")
	else:
		print("✗ Text feedback not properly stored")

func test_event_logging():
	print("\n--- Test 4: Event Logging ---")
	
	# Test gameplay event logging
	FeedbackManager.set_current_level("test_level")
	print("✓ Current level set")
	
	FeedbackManager.log_gameplay_event("player_jump", {"height": 150})
	FeedbackManager.log_gameplay_event("item_collected", {"item": "wedding_ring"})
	FeedbackManager.log_gameplay_event("enemy_defeated", {"enemy_type": "alien"})
	print("✓ Gameplay events logged")
	
	# Test technical issue logging
	FeedbackManager.log_technical_issue("Test audio stutter during scene transition", "low")
	print("✓ Technical issue logged")
	
	# Verify events were stored
	var events = FeedbackManager.feedback_data.gameplay_events
	var issues = FeedbackManager.feedback_data.technical_issues
	if events.size() >= 4 and issues.size() >= 1:  # 3 gameplay + 1 level_entered + 1 technical
		print("✓ Events and issues properly stored (", events.size(), " events, ", issues.size(), " issues)")
	else:
		print("✗ Events or issues not properly stored")

func test_data_export():
	print("\n--- Test 5: Data Export ---")
	
	# Test JSON export
	var json_data = FeedbackManager.export_feedback_data()
	if json_data.length() > 100:  # Should be substantial JSON
		print("✓ JSON export successful (", json_data.length(), " characters)")
	else:
		print("✗ JSON export failed or too small")
	
	# Test file save
	var file_path = FeedbackManager.save_feedback_to_file()
	if file_path != "":
		print("✓ Feedback file saved:", file_path)
		
		# Verify file exists and has content
		if FileAccess.file_exists(file_path):
			var file = FileAccess.open(file_path, FileAccess.READ)
			if file:
				var content = file.get_as_text()
				file.close()
				if content.length() > 50:
					print("✓ File contains valid data (", content.length(), " characters)")
				else:
					print("✗ File content too small")
			else:
				print("✗ Could not read feedback file")
		else:
			print("✗ Feedback file not found")
	else:
		print("✗ File save failed")

func print_feedback_summary():
	"""Print a summary of collected feedback data"""
	print("\n=== Feedback Summary ===")
	var data = FeedbackManager.feedback_data
	
	print("Session ID: ", data.session_id)
	print("Ratings: ", data.ratings.size(), " categories")
	print("Text Feedback: ", data.text_feedback.size(), " entries")
	print("Gameplay Events: ", data.gameplay_events.size(), " events")
	print("Technical Issues: ", data.technical_issues.size(), " issues")
	
	# Show sample data
	if data.ratings.size() > 0:
		print("\nSample Ratings:")
		for category in data.ratings:
			var ratings = data.ratings[category]
			if ratings.size() > 0:
				print("  ", category, ": ", ratings[0].rating, " stars")
	
	if data.text_feedback.size() > 0:
		print("\nSample Text Feedback:")
		print("  \"", data.text_feedback[0].text.substr(0, 50), "...\"")

# Add this to GameManager or call from debug console
func trigger_test():
	"""Public function to trigger the test from elsewhere"""
	call_deferred("_ready")