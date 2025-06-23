extends Node2D

## GlenBingoLevel: A quiz mini-game scene with Glen.
## Players must answer bingo questions correctly to proceed.
class_name GlenBingoLevel

# Node references
@onready var dialogue_box: DialogueBox = $UI/DialogueBox

# Resources
const BINGO_QUESTIONS_DATA = preload("res://resources/dialogue/bingo_questions.tres")

# Game state
var score: int = 0
var bingo_questions: DialogueResource

func _ready():
	bingo_questions = BINGO_QUESTIONS_DATA.duplicate(true)
	_setup_bingo_questions()
	
	dialogue_box.dialogue_choice_made.connect(_on_dialogue_choice_made)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	
	dialogue_box.start_dialogue(bingo_questions)

func _setup_bingo_questions():
	bingo_questions.entries.clear()
	
	# --- Questions ---
	bingo_questions.add_entry("q1", "Glen", "What's the 'something borrowed' that Jenny is wearing?")
	bingo_questions.add_choice("q1", "Her mother's veil", "wrong_q1")
	bingo_questions.add_choice("q1", "A lucky sixpence", "wrong_q1")
	bingo_questions.add_choice("q1", "My limited edition Star Wars collector's plate", "correct_q1")

	bingo_questions.add_entry("q2", "Glen", "What did Mark accidentally book for the honeymoon?")
	bingo_questions.add_choice("q2", "A romantic trip to Paris", "wrong_q2")
	bingo_questions.add_choice("q2", "A seven-day silent meditation retreat", "correct_q2")
	bingo_questions.add_choice("q2", "A cruise to the Bahamas", "wrong_q2")

	bingo_questions.add_entry("q3", "Glen", "What flavor is the wedding cake?")
	bingo_questions.add_choice("q3", "Red Velvet with cream cheese frosting", "wrong_q3")
	bingo_questions.add_choice("q3", "Vanilla bean with raspberry filling", "wrong_q3")
	bingo_questions.add_choice("q3", "Spicy tuna roll and wasabi", "correct_q3")

	# --- Response Entries ---
	bingo_questions.add_entry("correct_q1", "Glen", "That's it! You're surprisingly good at this.", "", "q2")
	bingo_questions.add_entry("wrong_q1", "Glen", "Nope! It was my plate! She knows how much I love the prequels.", "", "q2")
	
	bingo_questions.add_entry("correct_q2", "Glen", "Correct! He thought 'serenity' was a brand of tequila.", "", "q3")
	bingo_questions.add_entry("wrong_q2", "Glen", "Wrong! He mixed up the dates for his silent retreat booking.", "", "q3")

	bingo_questions.add_entry("correct_q3", "Glen", "You got it! Mark has... unconventional taste.", "", "end_game")
	bingo_questions.add_entry("wrong_q3", "Glen", "Incorrect! He said he wanted 'sushi-grade' cake.", "", "end_game")

	bingo_questions.add_entry("end_game", "Glen", "Well, that was fun. For me, anyway.")

func _on_dialogue_choice_made(choice_index: int):
	var choice = dialogue_box.current_entry.choices[choice_index]
	
	if choice.next_id.begins_with("correct_"):
		score += 1
		print("Correct! Score is now: %d" % score)
	else:
		print("Wrong answer chosen.")

func _on_dialogue_finished():
	print("Bingo finished! Final score: %d" % score)
	SceneTransition.change_scene("res://scenes/levels/AmsterdamLevel.tscn")