extends CharacterBody2D
class_name AcidsJoe
## Acids Joe - Final boss with two phases
## Phase 1: Normal Joe with tooth pain, Phase 2: Psychedelic transformation

signal phase_changed(new_phase: int)
signal defeated()
signal tooth_pain_triggered()

# Boss stats
@export var phase1_max_health: int = 100
@export var phase2_max_health: int = 150
@export var move_speed: float = 60.0
@export var chase_speed: float = 100.0
@export var attack_damage: int = 15
@export var psychedelic_damage: int = 25

# Node references
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var attack_area: Area2D = $AttackArea
@onready var state_machine: StateMachine = $StateMachine
@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var phase_indicator: Label = $UI/PhaseIndicator
@onready var dialogue_bubble: Node2D = $DialogueBubble
@onready var psychedelic_effect: Node2D = $PsychedelicEffect
@onready var transformation_particles: CPUParticles2D = $TransformationParticles
@onready var tooth_pain_timer: Timer = $ToothPainTimer
@onready var attack_timer: Timer = $AttackTimer

# Boss state
var current_phase: int = 1
var current_health: int
var max_health: int
var player_target: Player = null
var is_transforming: bool = false
var is_defeated: bool = false
var tooth_pain_frequency: float = 8.0  # Every 8 seconds

# Dialogue arrays
# Rest of the code from acids_joe_boss.txt