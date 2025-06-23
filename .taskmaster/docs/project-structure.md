# Wedding Game Project Structure

Based on Godot 4 best practices and Context7 documentation.

## Directory Structure

```
/project.godot
/scenes/                    # All .tscn files
  /levels/
    /amsterdam_level.tscn
    /glen_house_level.tscn
    /reception_level.tscn
  /ui/
    /main_menu.tscn
    /hud.tscn
    /pause_menu.tscn
    /settings_menu.tscn
    /dialogue_box.tscn
  /characters/
    /player.tscn
    /npc.tscn
    /wedding_party_member.tscn
  /items/
    /wedding_ring_item.tscn
    /flower_item.tscn
    /invitation_item.tscn
  /effects/
    /particle_effect.tscn
    /transition_effect.tscn

/scripts/                   # All .gd files
  /managers/
    /game_manager.gd
    /audio_manager.gd
    /save_manager.gd
    /scene_manager.gd
  /characters/
    /player.gd
    /npc.gd
    /wedding_party_member.gd
  /ui/
    /main_menu.gd
    /hud.gd
    /pause_menu.gd
    /dialogue_system.gd
  /items/
    /collectible_item.gd
    /wedding_ring.gd
  /levels/
    /base_level.gd
    /amsterdam_level.gd
    /glen_house_level.gd

/assets/                    # Art, audio, fonts
  /sprites/
    /characters/
      /player/
        /idle.png
        /walk.png
        /interact.png
      /npcs/
        /family_member.png
        /friend.png
    /items/
      /wedding_ring.png
      /flowers.png
      /invitation.png
    /ui/
      /buttons/
      /icons/
      /backgrounds/
    /environments/
      /amsterdam/
        /canal_background.png
        /buildings.png
      /glen_house/
        /interior.png
        /garden.png
  /audio/
    /music/
      /main_theme.ogg
      /amsterdam_theme.ogg
      /reception_theme.ogg
    /sfx/
      /item_collect.wav
      /footsteps.wav
      /dialogue_beep.wav
  /fonts/
    /main_font.ttf
    /ui_font.ttf

/data/                      # Game data files
  /character_data.gd
  /level_data.gd
  /dialogue_data.gd
  /item_definitions.gd

/autoload/                  # Singleton scripts
  /GameManager.gd
  /AudioManager.gd
  /SaveManager.gd
  /SceneTransition.gd

/addons/                    # Plugins and tools
  /custom_importer/
  /dialogue_system/

/.taskmaster/               # Task management
  /tasks/
  /docs/
  /reports/

/.vscode/                   # Editor settings
  /settings.json

/.cursor/                   # Cursor AI rules
  /rules/
    /godot.mdc
```

## Scene Organization Patterns

### Main Scene Hierarchy
```
Main (Node)
├── World (Node2D)
│   ├── Level (Node2D)
│   ├── Player (CharacterBody2D)
│   ├── NPCs (Node2D)
│   └── Items (Node2D)
└── GUI (CanvasLayer)
    ├── HUD (Control)
    ├── PauseMenu (Control)
    └── DialogueBox (Control)
```

### Character Scene Structure
```
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
├── InteractionArea (Area2D)
│   └── CollisionShape2D
├── AnimationPlayer
└── StateMachine (Node)
    ├── IdleState (Node)
    ├── WalkState (Node)
    └── InteractState (Node)
```

### Level Scene Structure
```
Level (Node2D)
├── Background (Node2D)
│   ├── ParallaxBackground
│   └── StaticElements (Node2D)
├── Interactables (Node2D)
│   ├── NPCs (Node2D)
│   └── Items (Node2D)
├── Navigation (Node2D)
│   └── NavigationRegion2D
└── Audio (Node2D)
    ├── MusicPlayer (AudioStreamPlayer)
    └── AmbiencePlayer (AudioStreamPlayer)
```

## Naming Conventions

### Files
- **Scenes**: `snake_case.tscn` (e.g., `main_menu.tscn`, `player_character.tscn`)
- **Scripts**: `snake_case.gd` (e.g., `game_manager.gd`, `player_controller.gd`)
- **Assets**: `snake_case.extension` (e.g., `player_idle.png`, `main_theme.ogg`)

### Classes and Nodes
- **Classes**: `PascalCase` (e.g., `PlayerController`, `GameManager`)
- **Node Names**: `PascalCase` (e.g., `Player`, `MainMenu`, `DialogueBox`)

### Code Elements
- **Functions**: `snake_case` (e.g., `handle_input()`, `play_animation()`)
- **Variables**: `snake_case` (e.g., `current_health`, `movement_speed`)
- **Constants**: `CONSTANT_CASE` (e.g., `MAX_HEALTH`, `JUMP_VELOCITY`)
- **Signals**: `snake_case` past tense (e.g., `health_changed`, `dialogue_started`)
- **Private members**: `_snake_case` (e.g., `_internal_state`, `_update_ui()`)

## Scene Management

### Autoload Singletons
Create these in the Project Settings > Autoload:

1. **GameManager** (`autoload/GameManager.gd`)
   - Game state management
   - Level progression
   - Player data persistence

2. **AudioManager** (`autoload/AudioManager.gd`)
   - Music and SFX playback
   - Volume control
   - Audio streaming

3. **SaveManager** (`autoload/SaveManager.gd`)
   - Save/load game data
   - Progress tracking
   - Settings persistence

4. **SceneTransition** (`autoload/SceneTransition.gd`)
   - Scene changing with transitions
   - Loading screens
   - Fade effects

### Resource Organization

#### Custom Resources
```
/data/
  character_stats.tres
  level_config.tres
  dialogue_tree.tres
  item_database.tres
```

#### Preloaded Scenes
```gdscript
# In a scenes namespace class
class_name GameScenes extends RefCounted

const Player = preload("res://scenes/characters/player.tscn")
const MainMenu = preload("res://scenes/ui/main_menu.tscn")
const AmsterdamLevel = preload("res://scenes/levels/amsterdam_level.tscn")
```

## Communication Patterns

### Signal-Based Communication
```gdscript
# Player.gd
signal health_changed(new_health: int)
signal item_collected(item_name: String)
signal dialogue_requested(npc: NPC)

# GameManager.gd (autoload)
func _ready():
    # Connect to player signals when player is instantiated
    get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node):
    if node.name == "Player":
        node.health_changed.connect(_on_player_health_changed)
        node.item_collected.connect(_on_item_collected)
```

### Direct References for Parent-Child
```gdscript
# HUD.gd
@onready var health_bar: ProgressBar = $HealthBar
@onready var item_counter: Label = $ItemCounter

func update_health(value: int):
    health_bar.value = value

func update_item_count(count: int):
    item_counter.text = str(count)
```

## Performance Considerations

### Node Caching
```gdscript
# ✅ Cache references with @onready
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer

# ✅ Or cache in _ready()
var ui_elements: Dictionary = {}

func _ready():
    ui_elements["health_bar"] = $GUI/HealthBar
    ui_elements["item_display"] = $GUI/ItemDisplay
```

### Scene Preloading
```gdscript
# ✅ Preload frequently used scenes
const BulletScene = preload("res://scenes/effects/bullet.tscn")
const ParticleEffect = preload("res://scenes/effects/particle_burst.tscn")

func shoot():
    var bullet = BulletScene.instantiate()
    get_tree().current_scene.add_child(bullet)
```

### Memory Management
```gdscript
# ✅ Proper cleanup
func _exit_tree():
    # Disconnect signals
    if health_changed.is_connected(_on_health_changed):
        health_changed.disconnect(_on_health_changed)

    # Clear references
    cached_nodes.clear()

# ✅ Use queue_free() for nodes
func remove_item():
    item_node.queue_free()
```

## Testing Structure

### Test Organization
```
/tests/
  /unit/
    /test_player_movement.gd
    /test_inventory_system.gd
  /integration/
    /test_scene_transitions.gd
    /test_save_load.gd
  /helpers/
    /test_helpers.gd
    /mock_objects.gd
```

### Test Naming
```gdscript
# test_player_movement.gd
extends GutTest

func test_player_moves_right_when_input_pressed():
    # Arrange, Act, Assert
    pass

func test_player_stops_when_collision_detected():
    # Test implementation
    pass
```

This structure follows Godot 4 best practices and ensures:
- Clear separation of concerns
- Easy navigation and maintenance
- Optimal performance through proper caching
- Scalable architecture for team development
- Consistent naming conventions
- Proper resource management
