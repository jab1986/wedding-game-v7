extends CharacterBody2D
class_name Alien
## Alien enemy - Basic enemy that plays bad Ghostbusters covers
## Spawns in Glen's house and the wedding venue

signal died()
signal played_bad_music()

# Enemy stats
@export var max_health: int = 30
@export var move_speed: float = 80.0
@export var chase_speed: float = 120.0
@export var attack_damage: int = 8
@export var detection_range: float = 150.0
@export var attack_range: float = 50.0
@export var music_play_chance: float = 0.02  # 2% chance per frame

# Node references
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var state_machine: StateMachine = $StateMachine
@onready var health_bar: ProgressBar = $HealthBar
@onready var music_label: Label = $MusicLabel
@onready var death_particles: CPUParticles2D = $DeathParticles
@onready var music_timer: Timer = $MusicTimer

# State
# Rest of the code from alien_enemy.txt