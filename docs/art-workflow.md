# Art Asset Pipeline & Workflow

## 🎯 Overview
This document outlines the complete art creation workflow for the Wedding Game, from concept to implementation in Godot Engine.

## 🛠 Recommended Tools

### Pixel Art Creation
1. **Aseprite** (Recommended)
   - Industry standard for pixel art
   - Built-in animation tools
   - Export to sprite sheets
   - Onion skinning for animation

2. **GIMP** (Free Alternative)
   - Pixel art with no anti-aliasing
   - Use pencil tool only
   - Grid overlay for precision
   - Export as PNG

3. **LibreSprite** (Free Alternative)
   - Open source fork of old Aseprite
   - Similar feature set
   - Good for beginners

### Color Palette Tools
- **Coolors.co** - Generate palettes
- **Lospec Palette List** - SNES-era palettes
- **Adobe Color** - Color theory tools

## 🎨 Art Creation Process

### 1. Concept & Reference
- Sketch character concepts
- Gather SNES-era reference images
- Define color palette (max 16 colors per sprite)
- Plan animation frames

### 2. Base Sprite Creation
```
Character Dimensions:
- Main Characters: 32x32 pixels
- Family NPCs: 36x36 pixels  
- Enemies: 28x28 pixels (Aliens) to 64x64 pixels (Boss)
```

**Key Principles:**
- No anti-aliasing
- Clean pixel placement
- High contrast for readability
- Strong silhouettes

### 3. Animation Frames
Follow sprite standards for frame counts:
- **Player Characters**: 8 frames (1 idle, 4 walk, 3 attack)
- **NPCs**: 4-6 frames (2 idle, 2-4 walk)
- **Enemies**: 6-8 frames (idle, move, attack, death)

**Animation Guidelines:**
- Keep timing consistent (8 FPS for retro feel)
- Use squash and stretch sparingly
- Emphasize key poses
- Loop seamlessly

### 4. Sprite Sheet Layout
- **Horizontal strips** (frames side by side)
- **No padding** between frames
- **Consistent frame size** across the sheet
- **PNG format** with transparency

Example layout for Mark (8 frames):
```
[Idle] [Walk1] [Walk2] [Walk3] [Walk4] [Attack1] [Attack2] [Attack3]
```

## 📁 File Organization

### Source Files (Keep for editing)
```
assets/graphics/source/
├── mark/
│   ├── mark.aseprite           # Source animation file
│   ├── mark_concept.png        # Concept art
│   └── mark_palette.png        # Color reference
└── ...
```

### Game-Ready Assets
```
assets/graphics/
├── placeholders/               # Auto-generated placeholders
├── characters/                 # Final character sprites
│   ├── mark/
│   │   └── mark_spritesheet.png
│   └── ...
├── templates/                  # Godot scene templates
└── import_presets/            # Import setting presets
```

## ⚙️ Godot Integration Workflow

### 1. Import Setup
1. Copy sprite sheet to `/assets/graphics/characters/[name]/`
2. Select sprite in FileSystem dock
3. Go to Import tab in Inspector
4. Apply settings from `/assets/graphics/import_presets/pixel_art_sprite.import`
5. Click "Reimport"

### 2. Scene Creation
1. Duplicate appropriate template:
   - `PlayerCharacter.tscn` for Mark/Jenny
   - `NPCCharacter.tscn` for Glen/Quinn/etc.
   - `EnemyCharacter.tscn` for Aliens/Acids Joe
2. Rename scene file
3. Configure AnimatedSprite2D node

### 3. Animation Setup
```gdscript
# Create SpriteFrames resource
var sprite_frames = SpriteFrames.new()

# Add animations
sprite_frames.add_animation("idle")
sprite_frames.add_animation("walk")
sprite_frames.add_animation("attack")

# Add frames to animations
# (Done in editor or via script)

# Assign to AnimatedSprite2D
$Sprite.sprite_frames = sprite_frames
$Sprite.play("idle")
```

### 4. Collision Setup
- Use RectangleShape2D for most characters
- Size collision to ~80% of sprite size
- Position at character's feet for ground collision
- Test with debug collision shapes enabled

## 🎯 Quality Assurance

### Before Finalizing Art:
- [ ] Correct pixel dimensions
- [ ] No anti-aliasing artifacts
- [ ] Proper color palette adherence
- [ ] Clean animation timing
- [ ] Sprite sheet format correct
- [ ] PNG transparency working

### In Godot Engine:
- [ ] Import settings applied correctly
- [ ] Animations play smoothly
- [ ] Collision shapes accurate
- [ ] Performance acceptable
- [ ] No visual artifacts
- [ ] Consistent art style

## 🔄 Iteration Process

### Art Feedback Loop:
1. **Create** initial sprite
2. **Import** to Godot with proper settings
3. **Test** in game context
4. **Gather feedback** on readability/style
5. **Iterate** on source file
6. **Re-export** and test again

### Common Issues & Solutions:
- **Blurry sprites**: Check import settings (use Lossless compression)
- **Animation stuttering**: Verify frame timing and loop settings
- **Color inconsistency**: Use reference palette and color picker
- **Size mismatch**: Follow exact pixel dimensions in standards

## 📊 Performance Considerations

### Optimization Guidelines:
- **Texture size**: Keep sprite sheets under 512x512 pixels
- **Compression**: Use Lossless for pixel art
- **Memory**: Disable mipmaps for 2D sprites
- **Loading**: Group related animations in single sprite sheet

### Batch Operations:
- Import multiple sprites with same settings
- Use templates for consistent scene structure
- Automate sprite sheet generation when possible

## 🎨 Style Guide Enforcement

### Character Consistency:
- Family members share skin tones
- Consistent outline thickness (1-2 pixels)
- Similar shading style across all characters
- Recognizable silhouettes at small sizes

### Technical Standards:
- Exact pixel dimensions per character type
- Horizontal sprite sheet layout
- PNG format with alpha transparency
- 16-color limit per sprite

This workflow ensures consistent, high-quality art assets that maintain the SNES aesthetic while optimizing for Godot Engine performance.