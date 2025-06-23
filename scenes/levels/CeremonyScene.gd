extends Node2D
class_name CeremonyScene
## Wedding Ceremony Scene - Final scene where Mark and Jenny get married
## Peaceful conclusion with all characters present

signal ceremony_completed()
signal game_finished()

# Node references
@onready var mark: NPC = $Characters/Mark
@onready var jenny: NPC = $Characters/Jenny
@onready var officiant: NPC = $Characters/Officiant
@onready var glen: NPC = $Characters/Glen
@onready var quinn: NPC = $Characters/Quinn
@onready var wedding_guests: Node2D = $Characters/WeddingGuests
@onready var ceremony_altar: Node2D = $CeremonyEnvironment/Altar
@onready var camera: Camera2D = $Camera2D
@onready var ui: Control = $UI
@onready var dialogue_box: Control = $UI/DialogueBox
@onready var dialogue_text: Label = $UI/DialogueBox/DialogueText
@onready var continue_prompt: Label = $UI/DialogueBox/ContinuePrompt
@onready var confetti_particles: CPUParticles2D = $Effects/ConfettiParticles
@onready var flower_petals: CPUParticles2D = $Effects/FlowerPetals

# Ceremony state
var ceremony_step: int = 0
var is_ceremony_active: bool = false
var ceremony_dialogue_index: int = 0
var all_guests_seated: bool = false

# Ceremony dialogue sequence
var ceremony_dialogue := [
	{"speaker": "Officiant", "text": "Dearly beloved, we are gathered here today..."},
	{"speaker": "Officiant", "text": "To celebrate the union of Mark and Jenny."},
	{"speaker": "Officiant", "text": "Despite aliens, fires, sewage, and psychedelic bosses..."},
	{"speaker": "Glen", "text": "Is this normal for weddings?"},
	{"speaker": "Quinn", "text": "Glen, just... shh."},
	{"speaker": "Officiant", "text": "Mark, do you take Jenny to be your wife?"},
	{"speaker": "Mark", "text": "I do! Even through all this chaos!"},
	{"speaker": "Officiant", "text": "Jenny, do you take Mark to be your husband?"},
	{"speaker": "Jenny", "text": "I do! Let's never have a boring day!"},
	{"speaker": "Officiant", "text": "You may now kiss the bride!"},
	{"speaker": "Everyone", "text": "🎉 CONGRATULATIONS! 🎉"}
]

func _ready() -> void:
	# Rest of the code from ceremony_scene.txt