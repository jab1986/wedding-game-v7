# Character Templates

This directory contains pre-built Godot scene templates for different character types in the wedding game.

## Available Templates

### PlayerCharacter.tscn
Template for player-controlled characters (Mark & Jenny):
- **Root**: CharacterBody2D
- **Sprite**: AnimatedSprite2D (for sprite animations)
- **Collision**: CollisionShape2D (for physics)

**Usage**:
1. Duplicate this scene
2. Rename to your character (e.g., "Mark.tscn")
3. Assign sprite sheet to AnimatedSprite2D
4. Set up collision shape
5. Attach player movement script

### NPCCharacter.tscn
Template for non-player characters (Glen, Quinn, Jack, etc.):
- **Root**: CharacterBody2D
- **Sprite**: AnimatedSprite2D
- **Collision**: CollisionShape2D

**Usage**:
1. Duplicate this scene
2. Rename to your NPC (e.g., "Glen.tscn")
3. Assign sprite sheet with idle/walk animations
4. Set up collision shape
5. Attach NPC AI script

### EnemyCharacter.tscn
Template for enemy characters (Aliens, Acids Joe):
- **Root**: CharacterBody2D
- **Sprite**: AnimatedSprite2D
- **Collision**: CollisionShape2D

**Usage**:
1. Duplicate this scene
2. Rename to your enemy (e.g., "Alien.tscn")
3. Assign sprite sheet with attack animations
4. Set up collision shape
5. Attach enemy AI script

## Setup Instructions

### 1. Sprite Configuration
- Select the **Sprite** (AnimatedSprite2D) node
- Create new SpriteFrames resource
- Import your sprite sheet using the import presets
- Set up animations: "idle", "walk", "attack", etc.

### 2. Collision Setup
- Select the **Collision** (CollisionShape2D) node
- Create new shape resource (usually RectangleShape2D)
- Adjust size to ~80% of sprite size for characters
- Position at character's feet for ground-based collision

### 3. Animation Frame Setup
Follow the sprite standards:
- **32x32 characters**: Mark, Jenny, Jack, Tom, Band Members, Combat Allies
- **36x36 characters**: Glen, Quinn (parents are bigger)
- **28x28 enemies**: Aliens (smaller, floating)
- **48x48+ bosses**: Acids Joe variants

### 4. Script Attachment
- Attach appropriate script to root node:
  - `player.gd` for PlayerCharacter
  - `npc.gd` for NPCCharacter  
  - `enemy.gd` for EnemyCharacter

## Animation Setup Example

```gdscript
# In _ready() function of character script
$Sprite.sprite_frames = load("res://assets/graphics/characters/mark/mark_spritesheet.tres")
$Sprite.play("idle")

# Animation mapping (from sprite standards)
# Mark (8 frames): idle(1), walk(4), attack(3)
# Glen (6 frames): idle(2), walk(4)
# Alien (6 frames): idle(2), move(2), death(2)
```

## File Naming Convention
- **Characters**: [character_name].tscn (e.g., Mark.tscn, Glen.tscn)
- **Location**: Store in `/scenes/characters/` when ready
- **Scripts**: Attach to `/scripts/characters/` directory

These templates ensure consistent character setup and make it easy to create new characters following the established patterns.