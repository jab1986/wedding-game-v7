extends Node
class_name AIBehaviorManager
## Manages AI behaviors using Beehave behavior trees
## Handles wedding guest AI, boss fights, and NPC interactions

signal behavior_changed(entity: Node, behavior_name: String)

# Behavior tree references
var guest_behaviors := {}
var boss_behaviors := {}

func _ready():
	print("AI Behavior Manager initialized")

## Setup behavior tree for wedding guest NPCs
func setup_guest_behavior(npc: Node, personality_type: String) -> void:
	var behavior_tree = _create_guest_behavior_tree(personality_type)
	if behavior_tree:
		npc.add_child(behavior_tree)
		guest_behaviors[npc] = behavior_tree
		print("Setup %s behavior for guest: %s" % [personality_type, npc.name])

## Setup behavior tree for boss fights (Acids Joe)
func setup_boss_behavior(boss: Node, boss_type: String) -> void:
	var behavior_tree = _create_boss_behavior_tree(boss_type)
	if behavior_tree:
		boss.add_child(behavior_tree)
		boss_behaviors[boss] = behavior_tree
		print("Setup %s behavior for boss: %s" % [boss_type, boss.name])

## Create guest behavior trees based on personality
func _create_guest_behavior_tree(personality: String) -> Node:
	var tree = preload("res://addons/beehave/addons/beehave/nodes/beehave_tree.gd").new()
	tree.name = "BehaviorTree"
	
	match personality:
		"shy":
			return _create_shy_guest_tree(tree)
		"party":
			return _create_party_guest_tree(tree)
		"drunk":
			return _create_drunk_guest_tree(tree)
		"confused":
			return _create_confused_guest_tree(tree)
		_:
			return _create_default_guest_tree(tree)

## Shy guest behavior - avoids player, hides in corners
func _create_shy_guest_tree(tree: Node) -> Node:
	# Create root sequence
	var root = _create_sequence_node("ShyGuestRoot")
	tree.add_child(root)
	
	# Check if player is near
	var check_player = _create_condition_node("CheckPlayerNear")
	root.add_child(check_player)
	
	# If player near, move away
	var move_away = _create_action_node("MoveAwayFromPlayer")
	root.add_child(move_away)
	
	return tree

## Party guest behavior - dances, socializes, celebrates
func _create_party_guest_tree(tree: Node) -> Node:
	var root = _create_selector_node("PartyGuestRoot")
	tree.add_child(root)
	
	# Dance sequence
	var dance_seq = _create_sequence_node("DanceSequence")
	root.add_child(dance_seq)
	
	var check_music = _create_condition_node("CheckMusicPlaying")
	dance_seq.add_child(check_music)
	
	var dance_action = _create_action_node("DanceToMusic")
	dance_seq.add_child(dance_action)
	
	# Default wandering
	var wander = _create_action_node("WanderAround")
	root.add_child(wander)
	
	return tree

## Drunk guest behavior - stumbles, causes problems
func _create_drunk_guest_tree(tree: Node) -> Node:
	var root = _create_selector_node("DrunkGuestRoot")
	tree.add_child(root)
	
	var stumble = _create_action_node("StumbleWalk")
	root.add_child(stumble)
	
	var hiccup = _create_action_node("RandomHiccup")
	root.add_child(hiccup)
	
	return tree

## Confused guest behavior - Glen's special behavior
func _create_confused_guest_tree(tree: Node) -> Node:
	var root = _create_sequence_node("ConfusedGuestRoot")
	tree.add_child(root)
	
	var look_around = _create_action_node("LookAroundConfused")
	root.add_child(look_around)
	
	var check_bingo = _create_condition_node("CheckBingoTime")
	root.add_child(check_bingo)
	
	var play_bingo = _create_action_node("PlayBingo")
	root.add_child(play_bingo)
	
	return tree

## Default guest behavior - basic mingling
func _create_default_guest_tree(tree: Node) -> Node:
	var root = _create_selector_node("DefaultGuestRoot")
	tree.add_child(root)
	
	var mingle = _create_action_node("MingleWithOthers")
	root.add_child(mingle)
	
	var idle = _create_action_node("IdleStanding")
	root.add_child(idle)
	
	return tree

## Create boss behavior tree for Acids Joe
func _create_boss_behavior_tree(boss_type: String) -> Node:
	var tree = preload("res://addons/beehave/addons/beehave/nodes/beehave_tree.gd").new()
	tree.name = "BossBehaviorTree"
	
	if boss_type == "acids_joe":
		return _create_acids_joe_tree(tree)
	
	return null

## Acids Joe behavior - psychedelic transformation boss fight
func _create_acids_joe_tree(tree: Node) -> Node:
	var root = _create_selector_node("AcidsJoeRoot")
	tree.add_child(root)
	
	# Phase 1: Normal Joe
	var phase1 = _create_sequence_node("Phase1Normal")
	root.add_child(phase1)
	
	var check_health_high = _create_condition_node("CheckHealthAbove75")
	phase1.add_child(check_health_high)
	
	var normal_attacks = _create_action_node("NormalAttackPattern")
	phase1.add_child(normal_attacks)
	
	# Phase 2: Transformation
	var phase2 = _create_sequence_node("Phase2Transform")
	root.add_child(phase2)
	
	var check_health_mid = _create_condition_node("CheckHealthAbove25")
	phase2.add_child(check_health_mid)
	
	var transform = _create_action_node("PsychedelicTransform")
	phase2.add_child(transform)
	
	# Phase 3: Full psychedelic mode
	var phase3 = _create_action_node("FullPsychedelicMode")
	root.add_child(phase3)
	
	return tree

## Helper functions to create behavior tree nodes
func _create_sequence_node(node_name: String) -> Node:
	var sequence = preload("res://addons/beehave/addons/beehave/nodes/composites/sequence.gd").new()
	sequence.name = node_name
	return sequence

func _create_selector_node(node_name: String) -> Node:
	var selector = preload("res://addons/beehave/addons/beehave/nodes/composites/selector.gd").new()
	selector.name = node_name
	return selector

func _create_condition_node(node_name: String) -> Node:
	var condition = preload("res://addons/beehave/addons/beehave/nodes/leaves/condition.gd").new()
	condition.name = node_name
	return condition

func _create_action_node(node_name: String) -> Node:
	var action = preload("res://addons/beehave/addons/beehave/nodes/leaves/action.gd").new()
	action.name = node_name
	return action

## Get behavior tree for entity
func get_behavior_tree(entity: Node) -> Node:
	if entity in guest_behaviors:
		return guest_behaviors[entity]
	elif entity in boss_behaviors:
		return boss_behaviors[entity]
	return null

## Enable/disable behavior tree
func set_behavior_active(entity: Node, active: bool) -> void:
	var tree = get_behavior_tree(entity)
	if tree:
		tree.enabled = active