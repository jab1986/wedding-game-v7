extends Control

# Glen's Underground Quiz Show - Sim Gangster themed family quiz
# Glen tests Mark's knowledge about him during wedding disaster chaos

@onready var background: ColorRect = $Background
@onready var title_label: Label = $UI/TitleContainer/TitleLabel
@onready var glen_sprite: AnimatedSprite2D = $UI/MainContent/LeftPanel/GlenContainer/GlenSprite
@onready var question_label: Label = $UI/MainContent/LeftPanel/QuestionContainer/QuestionLabel
@onready var option_buttons: VBoxContainer = $UI/MainContent/LeftPanel/OptionsContainer/OptionButtons
@onready var score_label: Label = $UI/MainContent/RightPanel/StatusContainer/ScoreLabel
@onready var timer_bar: ProgressBar = $UI/MainContent/RightPanel/StatusContainer/TimerBar
@onready var scrolling_ticker: Label = $UI/ScrollingTicker/TickerLabel
@onready var status_log: RichTextLabel = $UI/MainContent/RightPanel/StatusLog/LogText

# Sim Gangster color palette
const DARK_BG = Color(0, 0, 0)  # Black background
const NEON_GREEN = Color(75.0/255, 202.0/255, 41.0/255)  # Signature neon green
const DARK_GREEN = Color(0, 128.0/255, 0)  # Darker green
const HIGHLIGHT_WHITE = Color(1, 1, 1)  # White highlights  
const WARNING_GOLD = Color(241.0/255, 216.0/255, 7.0/255)  # Gold accents

# Quiz game state
var current_question: int = 0
var score: int = 0
var correct_answers: int = 0
var timer: float = 10.0
var max_time: float = 10.0
var game_active: bool = false

# Scrolling ticker messages
var ticker_messages: Array[String] = [
	"Glen adjusts his microphone nervously...",
	"Chelsea score update: 2-1 (Glen gets distracted)",
	"Disaster level: Moderate sewage backup detected",
	"Quinn status: Still handling everything perfectly",
	"Wedding venue status: Partially flooded",
	"Alien activity: Minimal (for now)",
	"Shed fire: Contained but still 'warm'",
	"Glen's confusion level: Maximum",
	"Emergency services: Still trying to understand situation",
	"Football commentary: More important than disasters"
]

var current_ticker_index: int = 0

# Quiz questions about Glen's character
var quiz_questions = [
	{
		"question": "When aliens invaded Glen's house, what was his first reaction?",
		"options": [
			"Called the police immediately",
			"Asked 'Are these your friends, Mark?'", 
			"Ran away screaming",
			"Started filming them"
		],
		"correct": 1,
		"glen_comment": "I was just being polite! They seemed friendly enough..."
	},
	{
		"question": "What's Glen's priority even during wedding disasters?",
		"options": [
			"Protecting the wedding cake",
			"Calling emergency services",
			"Watching Chelsea football games",
			"Finding Quinn"
		],
		"correct": 2,
		"glen_comment": "Well, Chelsea was playing! That's important!"
	},
	{
		"question": "Glen's catchphrase when problems arise is:",
		"options": [
			"I'll handle this myself!",
			"Quinn will handle this",
			"This is fine",
			"Call the authorities!"
		],
		"correct": 1,
		"glen_comment": "Quinn always knows what to do. She's brilliant!"
	},
	{
		"question": "When the shed caught fire, Glen said:",
		"options": [
			"Fire! Fire! Everyone evacuate!",
			"The shed is... warm?",
			"This is a disaster!",
			"Someone call the fire department!"
		],
		"correct": 1,
		"glen_comment": "It was warm! That's not wrong, is it?"
	},
	{
		"question": "Glen's reaction to the sewage explosion was:",
		"options": [
			"Immediate panic and evacuation",
			"Professional damage assessment",
			"Is this normal for weddings?",
			"Angry complaints to the council"
		],
		"correct": 2,
		"glen_comment": "I really didn't know! First wedding I've hosted..."
	}
]

func _ready():
	setup_ui_theme()
	setup_scrolling_elements()
	start_quiz_show()

func setup_ui_theme():
	# Apply Sim Gangster color scheme
	background.color = DARK_BG
	
	# Title with neon green glow effect
	title_label.add_theme_color_override("font_color", NEON_GREEN)
	title_label.text = "GLEN'S UNDERGROUND QUIZ SHOW"
	
	# Question styling
	question_label.add_theme_color_override("font_color", HIGHLIGHT_WHITE)
	
	# Score and timer
	score_label.add_theme_color_override("font_color", WARNING_GOLD)
	timer_bar.add_theme_color_override("font_color", NEON_GREEN)
	
	# Scrolling ticker styling
	scrolling_ticker.add_theme_color_override("font_color", NEON_GREEN)
	
	# Status log styling  
	status_log.add_theme_color_override("default_color", HIGHLIGHT_WHITE)
	status_log.add_theme_color_override("font_color", HIGHLIGHT_WHITE)

func setup_scrolling_elements():
	# Start the scrolling ticker
	start_ticker_scroll()
	
	# Initialize status log
	add_status_message("[color=#4BCA29]GLEN'S QUIZ SHOW STARTING...[/color]")
	add_status_message("Contestant: Mark")
	add_status_message("Host: Glen (Confused Dad)")
	add_status_message("Disaster Level: Manageable")

func start_ticker_scroll():
	# Create scrolling ticker effect
	var ticker_timer = Timer.new()
	ticker_timer.wait_time = 3.0
	ticker_timer.timeout.connect(_update_ticker)
	add_child(ticker_timer)
	ticker_timer.start()
	
	_update_ticker()  # Show first message immediately

func _update_ticker():
	scrolling_ticker.text = ticker_messages[current_ticker_index]
	current_ticker_index = (current_ticker_index + 1) % ticker_messages.size()
	
	# Animate the ticker scrolling
	var tween = create_tween()
	scrolling_ticker.position.x = get_viewport().size.x
	tween.tween_property(scrolling_ticker, "position:x", -scrolling_ticker.size.x, 8.0)

func start_quiz_show():
	add_status_message("[color=#F1D807]Glen taps microphone: 'Is this thing on?'[/color]")
	await get_tree().create_timer(2.0).timeout
	
	add_status_message("Glen: 'Right then, Mark... let's see how well you know your old dad!'")
	await get_tree().create_timer(1.5).timeout
	
	game_active = true
	show_question()

func show_question():
	if current_question >= quiz_questions.size():
		end_quiz()
		return
	
	var question_data = quiz_questions[current_question]
	question_label.text = question_data.question
	
	# Clear previous option buttons
	for child in option_buttons.get_children():
		child.queue_free()
	
	# Create new option buttons with Sim Gangster styling
	for i in range(question_data.options.size()):
		var option_button = Button.new()
		option_button.text = question_data.options[i]
		option_button.custom_minimum_size = Vector2(400, 50)
		
		# Style with gangster theme
		style_option_button(option_button)
		
		option_button.pressed.connect(_on_option_selected.bind(i))
		option_button.mouse_entered.connect(_on_option_hovered)
		option_buttons.add_child(option_button)
	
	# Reset and start timer
	timer = max_time
	timer_bar.value = 100
	
	add_status_message("Question " + str(current_question + 1) + " of " + str(quiz_questions.size()))

func style_option_button(button: Button):
	var style_normal = StyleBoxFlat.new()
	var style_hover = StyleBoxFlat.new()
	var style_pressed = StyleBoxFlat.new()
	
	# Normal state
	style_normal.bg_color = Color(0.2, 0.2, 0.2)
	style_normal.border_width_top = 2
	style_normal.border_width_bottom = 2
	style_normal.border_width_left = 2
	style_normal.border_width_right = 2
	style_normal.border_color = NEON_GREEN
	
	# Hover state
	style_hover.bg_color = DARK_GREEN
	style_hover.border_width_top = 2
	style_hover.border_width_bottom = 2
	style_hover.border_width_left = 2
	style_hover.border_width_right = 2
	style_hover.border_color = WARNING_GOLD
	
	# Pressed state
	style_pressed.bg_color = NEON_GREEN
	style_pressed.border_width_top = 2
	style_pressed.border_width_bottom = 2
	style_pressed.border_width_left = 2
	style_pressed.border_width_right = 2
	style_pressed.border_color = HIGHLIGHT_WHITE
	
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)
	button.add_theme_color_override("font_color", HIGHLIGHT_WHITE)

func _on_option_hovered():
	AudioManager.play_sfx("menu_select_snes")

func _on_option_selected(option_index: int):
	if not game_active:
		return
	
	game_active = false
	var question_data = quiz_questions[current_question]
	
	if option_index == question_data.correct:
		# Correct answer
		correct_answers += 1
		score += 100
		AudioManager.play_sfx("bingo_correct")
		add_status_message("[color=#4BCA29]CORRECT! +" + str(100) + " points[/color]")
		add_status_message("[color=#F1D807]Glen: '" + question_data.glen_comment + "'[/color]")
	else:
		# Wrong answer
		AudioManager.play_sfx("bingo_wrong")
		add_status_message("[color=#FF4444]WRONG! The correct answer was: " + question_data.options[question_data.correct] + "[/color]")
		add_status_message("[color=#F1D807]Glen: 'Oh dear... " + question_data.glen_comment + "'[/color]")
	
	update_score_display()
	current_question += 1
	
	await get_tree().create_timer(3.0).timeout
	game_active = true
	show_question()

func update_score_display():
	score_label.text = "Score: " + str(score) + " | Correct: " + str(correct_answers) + "/" + str(quiz_questions.size())

func end_quiz():
	add_status_message("[color=#F1D807]QUIZ COMPLETE![/color]")
	
	if correct_answers >= 3:
		AudioManager.play_sfx("celebration_fanfare")
		add_status_message("[color=#4BCA29]PASSED! You know Glen well enough![/color]")
		add_status_message("Glen: 'Brilliant! You're ready for the family!'")
		
		# Unlock Jenny if not already unlocked
		GameManager.unlock_character("jenny")
		AudioManager.play_sfx("success_chime")
		add_status_message("[color=#F1D807]Jenny is now available as a playable character![/color]")
	else:
		add_status_message("[color=#FF4444]FAILED! You need to get to know Glen better![/color]")
		add_status_message("Glen: 'Maybe we should have a proper chat sometime...'")
	
	await get_tree().create_timer(3.0).timeout
	add_status_message("Press any key to return to Glen's House")

func add_status_message(message: String):
	status_log.append_text(message + "\n")
	# Auto-scroll to bottom
	status_log.scroll_to_line(status_log.get_line_count() - 1)

func _process(delta):
	if game_active and current_question < quiz_questions.size():
		timer -= delta
		timer_bar.value = (timer / max_time) * 100
		
		if timer <= 0:
			_on_option_selected(-1)  # Time's up, wrong answer

func _input(event):
	if not game_active and current_question >= quiz_questions.size() and event.is_pressed():
		# Return to Glen's house
		SceneTransition.change_scene("res://scenes/levels/GlenHouseLevel.tscn")