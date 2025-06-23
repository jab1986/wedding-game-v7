# Placeholder Sprites

This directory contains placeholder sprite sheets for all characters in the wedding game. Each sprite sheet follows the exact specifications outlined in the game design.

## Sprite Specifications

### Main Playable Characters (32x32 pixels)
- **mark_spritesheet.png** - Mark (8 frames: 1 idle, 4 walk, 3 attack)
- **jenny_spritesheet.png** - Jenny (8 frames: 1 idle, 4 walk, 3 attack)

### Family NPCs (36x36 pixels)
- **glen_spritesheet.png** - Glen/Confused Dad (6 frames: 2 idle, 4 walk)
- **quinn_spritesheet.png** - Quinn/Competent Mom (6 frames: 2 idle, 4 walk)

### Secondary Characters (32x32 pixels)
- **jack_spritesheet.png** - Jack/Cafe Owner (6 frames: 2 idle, 4 walk)
- **tom_spritesheet.png** - Tom/Competitive Brother (4 frames: 2 idle, 2 walk)

### Band Members (32x32 pixels)
- **hassan_spritesheet.png** - Hassan/Bass Player (4 frames: 2 idle, 2 playing)
- **paul_spritesheet.png** - Political Paul/Guitarist (4 frames: 2 idle, 2 playing)

### Combat Allies (32x32 pixels)
- **gaz_spritesheet.png** - Gaz/Dialogue Warrior (4 frames: 2 idle, 2 talking)
- **matt_spritesheet.png** - Matt Tibble/Demolitions (6 frames: 2 idle, 2 walk, 2 throwing)
- **dan_spritesheet.png** - Dan Morisey/Melee (6 frames: 2 idle, 2 walk, 2 attack)

### Enemies
- **alien_spritesheet.png** - Aliens (28x28 pixels, 6 frames: 2 idle, 2 move, 2 death)
- **acids_joe_spritesheet.png** - Acids Joe Normal (48x48 pixels, 8 frames: 2 idle, 4 walk, 2 attack)
- **psychedelic_joe_spritesheet.png** - Psychedelic Joe (64x64 pixels, 8 frames: 2 idle, 4 attack, 2 special)

## Usage in Godot

### AnimatedSprite2D Setup
1. Create an AnimatedSprite2D node
2. Create a SpriteFrames resource
3. Import the sprite sheet
4. Set up animations with correct frame counts

### Frame Layout
All sprite sheets use horizontal strips:
- Frame 0: First animation frame (leftmost)
- Frame N: Last animation frame (rightmost)

### Animation Mapping
- **Idle**: Usually first 1-2 frames
- **Walk**: Next 2-4 frames
- **Attack/Special**: Remaining frames

## Color Coding
Each character has a distinct color for easy identification:
- Mark: Royal Blue (#4169E1)
- Jenny: Hot Pink (#FF69B4)
- Glen: Saddle Brown (#8B4513)
- Quinn: Dark Violet (#9932CC)
- And so on...

## Replacement Strategy
These placeholders can be easily replaced with final art:
1. Keep the same filename
2. Maintain the same dimensions
3. Keep the same frame count
4. Use the same horizontal strip layout

## Total Sprite Count
- **84 individual frames** across 14 characters
- **Exact dimensions** as specified in game design
- **PNG format** with transparency support