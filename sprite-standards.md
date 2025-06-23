# Wedding Game - Sprite Standards & Art Asset Pipeline

## 🎯 SNES-Style Aesthetic Goals
- **Resolution**: Low-resolution pixel art (16-64 pixels)
- **Color Palette**: Limited color palettes per character
- **Style**: Clean, readable silhouettes
- **Animation**: Simple but expressive

## 📐 Character Sprite Specifications

### Main Playable Characters (32x32 pixels)
```
Mark (Player Character) - 32x32 pixels - Blue Theme (#4169E1)
├── Sprite Sheet: 8 frames horizontal (256x32 total)
├── Idle: 1 frame
├── Walk: 4 frames (side-view walking animation)
├── Attack: 3 frames (drumstick throwing animation)
└── File: mark_spritesheet.png

Jenny (Player Character) - 32x32 pixels - Pink Theme (#FF69B4)
├── Sprite Sheet: 8 frames horizontal (256x32 total)
├── Idle: 1 frame
├── Walk: 4 frames (side-view walking animation)
├── Attack: 3 frames (camera bomb throwing animation)
└── File: jenny_spritesheet.png
```

### Family NPCs (36x36 pixels)
```
Glen (Confused Dad) - 36x36 pixels - Brown Theme (#8B4513)
├── Sprite Sheet: 6 frames horizontal (216x36 total)
├── Idle: 2 frames (standing, occasionally scratching head)
├── Walk: 4 frames (wandering animation)
└── File: glen_spritesheet.png

Quinn (Competent Mom) - 36x36 pixels - Violet Theme (#9932CC)
├── Sprite Sheet: 6 frames horizontal (216x36 total)
├── Idle: 2 frames (confident stance)
├── Walk: 4 frames (purposeful walking)
└── File: quinn_spritesheet.png
```

### Secondary Characters (32x32 pixels)
```
Jack (Cafe Owner) - 32x32 pixels - Green Theme (#228B22)
├── Sprite Sheet: 6 frames horizontal (192x32 total)
├── Idle: 2 frames (behind counter pose)
├── Walk: 4 frames (serving customers)
└── File: jack_spritesheet.png

Tom (Competitive Brother) - 32x32 pixels - Red Theme (#FF6347)
├── Sprite Sheet: 4 frames horizontal (128x32 total)
├── Idle: 2 frames
├── Walk: 2 frames (minimal - background character)
└── File: tom_spritesheet.png
```

### Band Members (32x32 pixels)
```
Hassan (Bass Player) - 32x32 pixels - Purple Theme (#8A2BE2)
├── Sprite Sheet: 4 frames horizontal (128x32 total)
├── Idle: 2 frames (holding bass)
├── Playing: 2 frames (bass playing animation)
└── File: hassan_spritesheet.png

Political Paul (Guitarist) - 32x32 pixels - Crimson Theme (#DC143C)
├── Sprite Sheet: 4 frames horizontal (128x32 total)
├── Idle: 2 frames (holding guitar)
├── Playing: 2 frames (guitar playing animation)
└── File: paul_spritesheet.png
```

### Combat Allies (32x32 pixels)
```
Gaz (Dialogue Warrior) - 32x32 pixels - Turquoise Theme (#00CED1)
├── Sprite Sheet: 4 frames horizontal (128x32 total)
├── Idle: 2 frames (talking pose)
├── Talking: 2 frames (animated conversation)
└── File: gaz_spritesheet.png

Matt Tibble (Demolitions) - 32x32 pixels - Orange Theme (#FF8C00)
├── Sprite Sheet: 6 frames horizontal (192x32 total)
├── Idle: 2 frames
├── Walk: 2 frames
├── Throwing: 2 frames (semtex throwing)
└── File: matt_spritesheet.png

Dan Morisey (Melee) - 32x32 pixels - Purple Theme (#800080)
├── Sprite Sheet: 6 frames horizontal (192x32 total)
├── Idle: 2 frames (holding snooker cue)
├── Walk: 2 frames
├── Attack: 2 frames (cue swinging)
└── File: dan_spritesheet.png
```

### Enemies
```
Aliens - 28x28 pixels - Green Theme (#00FF00)
├── Sprite Sheet: 6 frames horizontal (168x28 total)
├── Idle: 2 frames (floating/hovering)
├── Move: 2 frames (side movement)
├── Death: 2 frames (destruction animation)
└── File: alien_spritesheet.png

Acids Joe (Normal) - 48x48 pixels - Red Theme (#FF0000)
├── Sprite Sheet: 8 frames horizontal (384x48 total)
├── Idle: 2 frames (standing, tooth pain)
├── Walk: 4 frames (slow, confused movement)
├── Attack: 2 frames (slow punches)
└── File: acids_joe_spritesheet.png

Acids Joe (Psychedelic) - 64x64 pixels - Hot Pink Theme (#FF1493)
├── Sprite Sheet: 8 frames horizontal (512x64 total)
├── Idle: 2 frames (cosmic floating)
├── Attack: 4 frames (reality-warping attacks)
├── Special: 2 frames (transformation poses)
└── File: psychedelic_joe_spritesheet.png
```

## ⚙️ Godot Import Settings

### Texture Import Settings (ResourceImporterTexture)
```yaml
# Optimal settings for pixel art sprites
compress/mode: 0                    # Lossless (preserves pixel-perfect quality)
compress/high_quality: false       # Not needed for 2D pixel art
compress/lossy_quality: 0.7        # Not used with lossless
compress/hdr_compression: 1         # Opaque Only (sprites don't need HDR)
compress/normal_map: 0              # Detect (not needed for character sprites)
compress/channel_pack: 0            # sRGB Friendly

# Processing settings for pixel art
process/fix_alpha_border: true      # Prevents outlines on transparent edges
process/premult_alpha: false        # Keep standard alpha
process/size_limit: 0               # No size limit (sprites are already small)

# Channel remapping (default values)
process/channel_remap/red: 0        # Red channel
process/channel_remap/green: 1      # Green channel  
process/channel_remap/blue: 2       # Blue channel
process/channel_remap/alpha: 3      # Alpha channel

# Mipmaps (disable for pixel art)
mipmaps/generate: false             # No mipmaps for sharp pixel art
mipmaps/limit: -1                   # Not applicable

# 3D detection (disable for 2D sprites)
detect_3d/compress_to: 1            # Not relevant for 2D sprites
```

### Animation Import Settings
```yaml
# For AnimatedSprite2D resources
animation/fps: 8                    # 8 FPS for retro feel
animation/loop: true                # Most animations loop
animation/autoplay: "idle"          # Default to idle animation
```

## 🎨 Color Palette Standards

### Character Color Schemes
- **Primary Color**: Main character color (clothing/theme)
- **Secondary Color**: Accent color (details, highlights)
- **Skin Tone**: Consistent across family members
- **Outline**: Dark color (#000000 or very dark version of primary)

### SNES-Inspired Limitations
- **Maximum Colors per Sprite**: 16 colors
- **Consistent Palette**: Family members share skin tones
- **High Contrast**: Colors must be readable at small sizes

## 📁 File Organization

```
assets/graphics/
├── placeholders/           # Auto-generated placeholder sprites
│   ├── mark_spritesheet.png
│   ├── jenny_spritesheet.png
│   └── ...
├── characters/            # Final character art (organized by character)
│   ├── mark/
│   │   ├── mark_spritesheet.png
│   │   ├── mark_portrait.png
│   │   └── animations/
│   ├── jenny/
│   └── ...
├── items/                 # Game items and objects
├── backgrounds/           # Level backgrounds and tilesets
├── ui/                    # Interface elements
└── effects/               # Particle effects and visual effects
```

## 🔧 Godot AnimatedSprite2D Setup

### Creating Character Animations
1. **Create AnimatedSprite2D node**
2. **Create SpriteFrames resource**
3. **Import sprite sheet with correct settings**
4. **Set up animations**:
   - `idle`: Frames 0-1 (or frame 0 for single-frame idle)
   - `walk`: Frames 1-4 (or appropriate walk frames)
   - `attack`: Remaining frames

### Animation Properties
```gdscript
# Example AnimatedSprite2D setup
@export var character_animations: SpriteFrames
@export var animation_speed: float = 1.0

func _ready():
    sprite_frames = character_animations
    play("idle")
    speed_scale = animation_speed
```

## 🎯 Performance Optimization

### Memory Optimization
- **Lossless Compression**: Preserves pixel art quality
- **No Mipmaps**: Saves memory for 2D sprites
- **Proper Sizing**: Exact dimensions prevent scaling artifacts
- **Alpha Optimization**: Fix alpha borders enabled

### Import Performance
- **Fast Import**: Lossless mode imports quickly
- **No 3D Detection**: Disabled for 2D-only sprites
- **Batch Processing**: Import multiple sprites with same settings

## ✅ Quality Checklist

### Before Finalizing Sprites:
- [ ] Correct dimensions (32x32, 36x36, etc.)
- [ ] Horizontal sprite sheet layout
- [ ] PNG format with transparency
- [ ] Consistent color palette per character
- [ ] Clean pixel art (no anti-aliasing)
- [ ] Proper frame count for character type
- [ ] Clear animation timing
- [ ] Readable at target resolution

### Import Verification:
- [ ] Lossless compression applied
- [ ] No mipmaps generated
- [ ] Alpha borders fixed
- [ ] Proper animation setup in AnimatedSprite2D
- [ ] Correct frame assignments
- [ ] Animation loops properly
- [ ] Performance acceptable

## 🚀 Workflow Summary

1. **Create/Edit Sprites**: Use external pixel art tools (Aseprite, GIMP, etc.)
2. **Follow Standards**: Adhere to size and frame count specifications
3. **Import to Godot**: Use optimized import settings
4. **Set Up Animations**: Create AnimatedSprite2D with proper frame assignments
5. **Test**: Verify animations play correctly in-game
6. **Optimize**: Check performance and adjust if needed

This pipeline ensures consistent, optimized sprites that maintain the SNES-style aesthetic while performing well in Godot Engine.