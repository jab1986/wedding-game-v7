extends Node2D
class_name GlenBingoScene
## Glen Bingo - Quiz mini-game about Glen's personality
## Answer questions correctly to unlock Jenny as playable

signal quiz_completed(score: int)
signal jenny_unlocked()

# Scene references
const GLEN_HOUSE_SCENE := "res://scenes/levels/GlenHouseLevel.tscn"
const LEO_CAFE_SCENE := "res://scenes/levels/LeoCafeScene.tscn"

# Node references
@onready var glen_host: NPC = $GlenHost
@onready var question_panel: Panel = $UI/QuestionPanel
@onready var question_label: Label = $UI/QuestionPanel/QuestionLabel
@onready var answer_container: VBoxContainer = $UI/QuestionPanel/AnswerContainer
@onready var score_label: Label = $UI/ScoreLabel
@onready var timer_bar: ProgressBar = $UI/TimerBar
@onready var results_panel: Panel = $UI/ResultsPanel
@onready var sparkle_particles: CPUParticles2D = $Effects/SparkleParticles
@onready var spotlight: PointLight2D = $Effects/Spotlight
@onready var drumroll_audio: AudioStreamPlayer = $Audio/DrumrollAudio
@onready var correct_audio: AudioStreamPlayer = $Audio/CorrectAudio
@onready var wrong_audio: AudioStreamPlayer = $Audio/WrongAudio
@onready var fanfare_audio: AudioStreamPlayer = $Audio/FanfareAudio

# Quiz state
var current_question: int = 0
var score: int = 0
var time_per_question: float = 10.0
var time_remaining: float = 10.0
var quiz_active: bool = false
var answer_buttons: Array[Button] = []

# Questions and answers
var questions := [
	{
		"question": "Glen sees aliens in his garden. What does he say?",
		"answers": [
			{"text": "QUINN! HELP!", "correct": false},
			{"text": "Are these your friends, Mark?", "correct": true},
			{"text": "I'll call the police!", "correct": false},
			{"text": "Is this normal for weddings?", "correct": false}
		]
	},
	{
		"question": "The shed catches fire. Glen's reaction?",
		"answers": [
			{"text": "I'll put it out myself!", "correct": false},
			{"text": "Quinn will handle this", "correct": true},
			{"text": "This is fine.", "correct": false},
			{"text": "Should I call the fire brigade?", "correct": false}
		]
	},
	{
		"question": "Sewage starts flooding the garden. Glen asks:",
		"answers": [
			{"text": "Who did this?!", "correct": false},
			{"text": "Is this covered by insurance?", "correct": false},
			{"text": "Should I be worried?", "correct": false},
			{"text": "Is this normal for weddings?", "correct": true}
		]
	},
	{
		"question": "Glen's priority during all disasters is:",
		"answers": [
			{"text": "Saving his family", "correct": false},
			{"text": "Fixing the problems", "correct": false},
			{"text": "Watching the Chelsea game", "correct": true},
			{"text": "Calling emergency services", "correct": false}
		]
	},
	{
		"question": "Final Question: Glen's catchphrase is:",
		"answers": [
			{"text": "I'll handle it!", "correct": false},
			{"text": "Quinn knows best", "correct": false},
			{"text": "Are you sure about this?", "correct": false},
			{"text": "Quinn will handle this", "correct": true}
		]
	}
]

func _ready() -> void:
	# Hide UI initially
	question_panel.visible = false
	results_panel.visible = false
	
	# Create game show environment
	_create_game_show_set()
	
	# Configure Glen as host
	_setup_glen_host()
	
	# Play game show music
	AudioManager.play_music("glen_bingo")
	
	# Start intro sequence
	_play_intro_sequence()

func _create_game_show_set() -> void:
	var width = 800
	var height = 600
	
	# Flashy gradient background
	var bg = Node2D.new()
	add_child(bg)
	move_child(bg, 0)
	
	for i in range(height):
		var color = Color.from_hsv(
			float(i) / height * 0.3 + 0.8,  # Purple to red
			0.8,
			0.9
		)
		var line = ColorRect.new()
		line.size = Vector2(width, 1)
		line.position = Vector2(0, i)
		line.color = color
		bg.add_child(line)
	
	# Spotlights
	for i in range(5):
		var spot = PointLight2D.new()
		spot.position = Vector2(randf_range(100, 700), randf_range(100, 500))
		spot.texture = preload("res://assets/sprites/effects/spotlight.png")
		spot.energy = randf_range(0.3, 0.5)
		spot.texture_scale = randf_range(2.0, 3.0)
		spot.color = Color(1, 1, randf_range(0.8, 1.0))
		add_child(spot)
		
		# Animate spotlight
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(spot, "energy", spot.energy * 1.3, randf_range(1.0, 2.0))
		tween.tween_property(spot, "energy", spot.energy, randf_range(1.0, 2.0))
	
	# Title
	var title = Label.new()
	title.text = "GLEN BINGO!"
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color.YELLOW)
	title.add_theme_color_override("font_shadow_color", Color.BLACK)
	title.add_theme_constant_override("shadow_offset_x", 4)
	title.add_theme_constant_override("shadow_offset_y", 4)
	title.position = Vector2(400, 50)
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(title)
	
	# Animate title
	var title_tween = create_tween()
	title_tween.set_loops()
	title_tween.tween_property(title, "scale", Vector2(1.1, 1.1), 0.5)
	title_tween.tween_property(title, "scale", Vector2(1.0, 1.0), 0.5)
	
	# Sparkle effects
	_create_sparkle_effects()

func _create_sparkle_effects() -> void:
	var sparkle_timer = Timer.new()
	sparkle_timer.wait_time = 0.2
	sparkle_timer.timeout.connect(func():
		var sparkle = Label.new()
		sparkle.text = "✨"
		sparkle.add_theme_font_size_override("font_size", randf_range(16, 32))
		sparkle.position = Vector2(randf_range(0, 800), randf_range(0, 150))
		sparkle.modulate.a = 0.8
		add_child(sparkle)
		
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(sparkle, "scale", Vector2(0, 0), 1.0).from(Vector2(1, 1))
		tween.tween_property(sparkle, "rotation", randf_range(0, TAU), 1.0)
		tween.chain().tween_callback(sparkle.queue_free)
	)
	add_child(sparkle_timer)
	sparkle_timer.start()

func _setup_glen_host() -> void:
	glen_host.npc_name = "Glen (Host)"
	glen_host.position = Vector2(100, 300)
	glen_host.scale = Vector2(2, 2)  # Make him bigger as host
	glen_host.can_wander = false
	
	# Add microphone
	var mic = Label.new()
	mic.text = "🎤"
	mic.add_theme_font_size_override("font_size", 32)
	mic.position = Vector2(40, -10)
	glen_host.add_child(mic)
	
	# Add bow tie
	var bowtie = Label.new()
	bowtie.text = "🎀"
	bowtie.add_theme_font_size_override("font_size", 24)
	bowtie.position = Vector2(0, 10)
	bowtie.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	glen_host.add_child(bowtie)

func _play_intro_sequence() -> void:
	# Glen's introduction
	glen_host.speak("Welcome to GLEN BINGO!")
	
	await get_tree().create_timer(2.0).timeout
	
	glen_host.speak("The game show where you prove you know ME!")
	
	await get_tree().create_timer(2.0).timeout
	
	glen_host.speak("Answer 3 out of 5 correctly to unlock Jenny!")
	
	await get_tree().create_timer(2.0).timeout
	
	# Start quiz
	_start_quiz()

func _start_quiz() -> void:
	quiz_active = true
	current_question = 0
	score = 0
	
	# Show UI
	question_panel.visible = true
	_update_score_display()
	
	# Show first question
	_show_question()

func _show_question() -> void:
	if current_question >= questions.size():
		_end_quiz()
		return
	
	var q = questions[current_question]
	
	# Update question text
	question_label.text = "Question %d: %s" % [current_question + 1, q.question]
	
	# Clear old answer buttons
	for button in answer_buttons:
		button.queue_free()
	answer_buttons.clear()
	
	# Create answer buttons
	var button_colors = [Color.RED, Color.BLUE, Color.GREEN, Color.PURPLE]
	var button_labels = ["A", "B", "C", "D"]
	
	for i in range(q.answers.size()):
		var answer = q.answers[i]
		
		var button = Button.new()
		button.custom_minimum_size = Vector2(300, 50)
		button.text = "%s) %s" % [button_labels[i], answer.text]
		button.add_theme_font_size_override("font_size", 18)
		
		# Style
		var style = StyleBoxFlat.new()
		style.bg_color = button_colors[i]
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_color = Color.WHITE
		button.add_theme_stylebox_override("normal", style)
		
		# Hover effect
		var hover_style = style.duplicate()
		hover_style.bg_color = button_colors[i].lightened(0.2)
		button.add_theme_stylebox_override("hover", hover_style)
		
		# Connect
		button.pressed.connect(_on_answer_selected.bind(i, answer.correct))
		
		answer_container.add_child(button)
		answer_buttons.append(button)
	
	# Reset timer
	time_remaining = time_per_question
	timer_bar.max_value = time_per_question
	timer_bar.value = time_remaining
	
	# Animate Glen
	glen_host.show_emote("❓")

func _on_answer_selected(index: int, is_correct: bool) -> void:
	# Disable all buttons
	for button in answer_buttons:
		button.disabled = true
	
	# Highlight selected answer
	var selected_button = answer_buttons[index]
	selected_button.modulate = Color(1.5, 1.5, 1.5)
	
	# Check answer
	if is_correct:
		_show_correct_feedback(index)
	else:
		_show_wrong_feedback(index)
	
	# Next question after delay
	await get_tree().create_timer(2.0).timeout
	current_question += 1
	_show_question()

func _show_correct_feedback(index: int) -> void:
	score += 1
	_update_score_display()
	
	# Visual feedback
	answer_buttons[index].modulate = Color.GREEN
	
	# Sound
	if correct_audio:
		correct_audio.play()
	
	# Glen's reaction
	glen_host.speak("Correct! You know me well!")
	glen_host.show_emote("✅")
	
	# Confetti burst
	_create_confetti_burst(answer_buttons[index].global_position)

func _show_wrong_feedback(index: int) -> void:
	# Visual feedback
	answer_buttons[index].modulate = Color.RED
	
	# Show correct answer
	for i in range(answer_buttons.size()):
		if questions[current_question].answers[i].correct:
			answer_buttons[i].modulate = Color.GREEN
			
			# Pulse effect
			var tween = create_tween()
			tween.set_loops(3)
			tween.tween_property(answer_buttons[i], "scale", Vector2(1.1, 1.1), 0.2)
			tween.tween_property(answer_buttons[i], "scale", Vector2(1.0, 1.0), 0.2)
	
	# Sound
	if wrong_audio:
		wrong_audio.play()
	
	# Glen's reaction
	glen_host.speak("Wrong! Quinn would know that!")
	glen_host.show_emote("❌")

func _create_confetti_burst(pos: Vector2) -> void:
	for i in range(20):
		var confetti = Label.new()
		confetti.text = ["🎊", "🎉", "✨"][randi() % 3]
		confetti.position = pos
		add_child(confetti)
		
		var end_pos = pos + Vector2(
			randf_range(-100, 100),
			randf_range(-150, -50)
		)
		
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(confetti, "position", end_pos, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(confetti, "rotation", randf_range(-PI, PI), 1.0)
		tween.tween_property(confetti, "modulate:a", 0.0, 1.0)
		tween.chain().tween_callback(confetti.queue_free)

func _update_score_display() -> void:
	score_label.text = "Score: %d / %d" % [score, questions.size()]

func _end_quiz() -> void:
	quiz_active = false
	question_panel.visible = false
	
	# Show results
	_show_results()

func _show_results() -> void:
	results_panel.visible = true
	
	var result_title = Label.new()
	result_title.text = "QUIZ COMPLETE!"
	result_title.add_theme_font_size_override("font_size", 48)
	result_title.position = Vector2(400, 200)
	result_title.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	results_panel.add_child(result_title)
	
	var score_text = Label.new()
	score_text.text = "Final Score: %d / %d" % [score, questions.size()]
	score_text.add_theme_font_size_override("font_size", 32)
	score_text.position = Vector2(400, 280)
	score_text.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	results_panel.add_child(score_text)
	
	# Check if passed
	var message: String
	var unlocked_jenny: bool = false
	
	if score >= 3:
		message = "🎉 You understand Glen!\nJenny is now playable!"
		unlocked_jenny = true
		
		# Play fanfare
		if fanfare_audio:
			fanfare_audio.play()
		
		# Celebration effects
		_play_victory_celebration()
	else:
		message = "😅 You need to know Glen better!\nTry again?"
	
	var message_label = Label.new()
	message_label.text = message
	message_label.add_theme_font_size_override("font_size", 24)
	message_label.position = Vector2(400, 360)
	message_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	results_panel.add_child(message_label)
	
	# Continue button
	var continue_button = Button.new()
	continue_button.text = "Continue"
	continue_button.size = Vector2(200, 50)
	continue_button.position = Vector2(300, 450)
	continue_button.add_theme_font_size_override("font_size", 24)
	results_panel.add_child(continue_button)
	
	continue_button.pressed.connect(func():
		if unlocked_jenny:
			GameManager.has_jenny = true
			GameManager.glen_bingo_score = score
			jenny_unlocked.emit()
		
		quiz_completed.emit(score)
		
		# Return to appropriate scene
		if unlocked_jenny:
			SceneTransition.change_scene(LEO_CAFE_SCENE)
		else:
			SceneTransition.change_scene(GLEN_HOUSE_SCENE)
	)

func _play_victory_celebration() -> void:
	# Massive confetti
	for i in range(50):
		var delay = i * 0.05
		get_tree().create_timer(delay).timeout.connect(func():
			var confetti = Label.new()
			confetti.text = ["🎊", "🎉", "✨", "🎈", "🎆"][randi() % 5]
			confetti.add_theme_font_size_override("font_size", randf_range(24, 48))
			confetti.position = Vector2(randf_range(0, 800), 0)
			add_child(confetti)
			
			var tween = create_tween()
			tween.set_parallel()
			tween.tween_property(confetti, "position:y", 600, randf_range(2.0, 4.0))
			tween.tween_property(confetti, "position:x", confetti.position.x + randf_range(-50, 50), randf_range(2.0, 4.0))
			tween.tween_property(confetti, "rotation", randf_range(-TAU, TAU), randf_range(2.0, 4.0))
			tween.chain().tween_callback(confetti.queue_free)
		)
	
	# Glen celebrates
	glen_host.speak("Well done! You really do know me!")
	glen_host.show_emote("🎉")
	
	# Dancing Glen
	var dance_tween = create_tween()
	dance_tween.set_loops(5)
	dance_tween.tween_property(glen_host, "position:x", glen_host.position.x + 20, 0.2)
	dance_tween.tween_property(glen_host, "position:x", glen_host.position.x - 20, 0.2)
	dance_tween.tween_property(glen_host, "position:x", glen_host.position.x, 0.2)

func _process(delta: float) -> void:
	# Update timer
	if quiz_active and time_remaining > 0:
		time_remaining -= delta
		timer_bar.value = time_remaining
		
		# Timer warning
		if time_remaining < 3.0:
			timer_bar.modulate = Color(1.0, sin(time_remaining * 10), sin(time_remaining * 10))
		
		# Time's up
		if time_remaining <= 0:
			_on_answer_selected(-1, false)  # Auto-fail