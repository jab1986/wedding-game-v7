extends Node2D
class_name WeddingVenueScene
## Wedding Venue Scene - Combat gauntlet before the final boss
## Features allies helping and multiple enemy waves

signal level_completed()
signal ally_dialogue(ally_name: String, text: String)

# Scene references
const BOSS_FIGHT_SCENE := "res://scenes/levels/BossFightScene.tscn"
const ALIEN_SCENE := preload("res://scenes/entities/enemies/Alien.tscn")

# Node references
@onready var player: Player = $Player
@onready var hud: HUD = $UI/HUD
@onready var camera: ShakeCamera2D = $Camera2D
@onready var venue_environment: Node2D = $VenueEnvironment
@onready var combat_areas: Node2D = $CombatAreas
@onready var allies: Node2D = $Allies
@onready var enemy_spawners: Node2D = $EnemySpawners
@onready var wave_timer: Timer = $WaveTimer
@onready var dialogue_system: Node2D = $DialogueSystem

# Ally NPCs
@onready var gaz: NPC = $Allies/Gaz
@onready var matt_tibble: NPC = $Allies/MattTibble
@onready var dan_morisey: NPC = $Allies/DanMorisey

# Combat state
var current_area: int = 0
var current_wave: int = 0
var enemies_remaining: int = 0
var allies_available: Array[String] = ["gaz", "matt", "dan"]
var area_complete: bool = false

# Combat areas configuration
var combat_areas_config := [
	{
		"name": "Parking Lot",
		"ally": "gaz",
		"enemy_type": "dialogue_combat",
		"waves": 1,
		"description": "Gaz talks aliens to death"
	},
	{
		"name": "Garden Path", 
		"ally": "matt",
		# Rest of the code from wedding_venue_scene.txt