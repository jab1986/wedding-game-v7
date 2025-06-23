# Plugin Integration Guide

This document explains how to use the integrated plugins in the Mark & Jenny's Wedding Adventure game.

## Installed Plugins

1. **Dialogue Manager** - For character dialogue and conversations
2. **Beehave** - For enemy and boss AI behavior trees
3. **Phantom Camera** - For dynamic camera control and effects

## Dialogue Manager

### Overview
Dialogue Manager provides a simple way to create and manage dialogue in your game. It uses a custom dialogue script format that's easy to write and maintain.

### How to Use

1. **Create Dialogue Files**:
   - Dialogue files are stored in the `dialogues/` directory with the `.dialogue` extension
   - Example: `dialogues/wedding_ceremony.dialogue`

2. **Basic Dialogue Format**:
   ```
   ~ start

   Character: This is what they say.
   Other: This is a response.
   
   => END
   ```

3. **Showing Dialogue in Game**:
   ```gdscript
   func _on_npc_interaction():
       DialogueManager.show_dialogue_balloon("res://dialogues/wedding_ceremony.dialogue")
   ```

4. **Dialogue with Choices**:
   ```
   ~ question
   
   Glen: Do you understand what's happening?
   - Yes, it's a wedding
       Glen: Oh good, I was confused.
       => END
   - Not really
       Glen: Me neither!
       => END
   ```

5. **Connecting to Game Events**:
   ```gdscript
   # In your dialogue file
   ~ boss_intro
   
   Acids Joe: My tooth hurts! You'll pay for this!
   do GameManager.start_boss_fight()
   
   => END
   ```

### Key Scenes to Implement
- Glen Bingo Scene - Quiz dialogue
- Leo's Cafe Scene - Character conversations
- Wedding Ceremony - Final dialogue sequence

## Beehave

### Overview
Beehave is a behavior tree system for creating complex AI behaviors. It's particularly useful for enemies and boss fights.

### How to Use

1. **Setting Up a Behavior Tree**:
   ```gdscript
   # In your enemy scene
   @onready var behavior_tree = $BehaviorTree
   ```

2. **Creating Behavior Tree Structure**:
   - Add a `BeehaveBehaviorTree` node to your enemy scene
   - Add composite nodes (Selector, Sequence) as children
   - Add condition and action nodes as needed

3. **Example Structure for Acids Joe Boss**:
   ```
   BehaviorTree
   └── Selector (Phase Selector)
       ├── Sequence (Phase 1)
       │   ├── Condition (IsPhase1)
       │   └── Selector (Phase 1 Actions)
       │       ├── Sequence (Attack Player)
       │       ├── Sequence (Chase Player)
       │       └── Action (Wander)
       └── Sequence (Phase 2)
           ├── Condition (IsPhase2)
           └── Selector (Phase 2 Actions)
               ├── Sequence (Psychedelic Attack)
               ├── Sequence (Special Attack)
               └── Sequence (Basic Attack)
   ```

4. **Creating Custom Conditions and Actions**:
   ```gdscript
   class IsPlayerVisible extends BeehaveCondition:
       func tick(actor, blackboard):
           if actor.can_see_player():
               return SUCCESS
           return FAILURE
   
   class AttackPlayer extends BeehaveAction:
       func tick(actor, blackboard):
           actor.attack_player()
           return SUCCESS
   ```

### Key Implementations
- Alien enemies in Glen's House and Wedding Venue
- Acids Joe boss with two phases
- NPC behaviors in various scenes

## Phantom Camera

### Overview
Phantom Camera provides advanced camera control for creating dynamic and cinematic camera movements.

### How to Use

1. **Setting Up a Phantom Camera**:
   - Add a `PhantomCamera2D` node to your scene
   - Set it as the active camera

2. **Following a Target**:
   ```gdscript
   # Make camera follow the player
   phantom_camera.set_follow_target(player)
   phantom_camera.set_follow_mode(PhantomCamera2D.FollowMode.FOLLOW)
   phantom_camera.set_follow_smoothing(0.5)
   ```

3. **Camera Transitions**:
   ```gdscript
   # Transition to a new target
   phantom_camera.set_follow_target(new_target)
   phantom_camera.set_tween_duration(1.0)
   phantom_camera.set_tween_transition(Tween.TRANS_SINE)
   phantom_camera.set_tween_ease(Tween.EASE_IN_OUT)
   ```

4. **Camera Shake**:
   ```gdscript
   # Add trauma for camera shake
   phantom_camera.add_trauma(0.5)  # 0.0 to 1.0
   ```

5. **Region Limits**:
   ```gdscript
   # Limit camera movement to a specific region
   phantom_camera.set_limit_left(0)
   phantom_camera.set_limit_right(1000)
   phantom_camera.set_limit_top(0)
   phantom_camera.set_limit_bottom(600)
   ```

### Key Implementations
- Boss fight camera movements and effects
- Ceremony scene camera control
- Transition effects between areas

## Integration Examples

### Dialogue During Boss Fight
```gdscript
func _on_boss_phase_changed(new_phase):
    if new_phase == 2:
        # Show transformation dialogue
        DialogueManager.show_dialogue_balloon("res://dialogues/boss_transformation.dialogue")
        
        # Change camera behavior
        phantom_camera.add_trauma(0.6)
        phantom_camera.set_zoom(Vector2(0.8, 0.8))
```

### NPC with AI Behavior and Dialogue
```gdscript
func _on_player_interaction():
    # Stop the NPC's behavior tree temporarily
    $BehaviorTree.enabled = false
    
    # Show dialogue
    var balloon = DialogueManager.show_dialogue_balloon("res://dialogues/glen_dialogue.dialogue")
    await balloon.dialogue_ended
    
    # Resume behavior tree
    $BehaviorTree.enabled = true
```

## Additional Resources

- Dialogue Manager Documentation: https://github.com/nathanhoad/godot_dialogue_manager
- Beehave Documentation: https://github.com/bitbrain/beehave
- Phantom Camera Documentation: https://github.com/ramokz/phantom-camera