extends Node2D
class_name BossFightScene
## Boss Fight Scene - Final battle with Acids Joe
## Two-phase boss fight with psychedelic transformation

signal boss_defeated()
signal phase_transition(phase: int)

# Scene references
const CEREMONY_SCENE := "res://scenes/levels/CeremonyScene.tscn"
const ACIDS_JOE_SCENE := preload("res://scenes/entities/bosses/AcidsJoe.tscn")

# Node references
@onready var player: Player = $Player
@onready var hud: HUD = $UI/HUD
@onready var camera: ShakeCamera2D = $Camera2D
@onready var boss_arena: Node2D = $BossArena
@onready var psychedelic_background: Node2D = $PsychedelicBackground
@onready var boss_ui: Control = $UI/BossUI
@onready var boss_health_bar: ProgressBar = $UI/BossUI/BossHealthBar
@onready var boss_name_label: Label = $UI/BossUI/BossNameLabel
@onready var phase_label: Label = $UI/BossUI/PhaseLabel
@onready var warning_label: Label = $UI/WarningLabel
@onready var agent_elf_trigger: Area2D = $AgentElfTrigger

# Boss and fight state
var acids_joe: AcidsJoe = null
var fight_started: bool = false
var boss_phase: int = 1
var agent_elf_played: bool = false
var psychedelic_effect_strength: float = 0.0

# Agent Elf members - they trigger the transformation
var agent_elf_members := ["Hassan", "Political Paul"]

func _ready() -> void:
	# Set up level
	GameManager.current_level = "BossFightScene"
	
	# Position player at entrance
	player.position = Vector2(150, 400)

# Rest of the code from boss_fight_scene.txt