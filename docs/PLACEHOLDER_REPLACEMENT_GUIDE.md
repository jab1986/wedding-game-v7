# Placeholder Image Replacement Guide

## Overview

This guide provides step-by-step instructions for replacing the current "sixes" placeholder images with proper free pixel art assets. All recommended resources are CC0 licensed (public domain) and can be used commercially without attribution.

## Priority Replacement Order

### 1. Character Sprites (Highest Priority)
- **Mark** (Groom) - Main character
- **Jenny** (Bride) - Main character
- **Hassan** - Wedding guest
- **Glen** - Friend character with quiz mini-game
- **Acids Joe** - Boss character
- **Dan, Gaz, Matt, Paul, Quinn, Tom** - Supporting characters

### 2. Item Graphics (Medium Priority)
- **Wedding Ring** - Key collectible item
- **Camera** - Weapon/tool item
- **Collectibles** - Various pickup items

### 3. Enemy Sprites (Medium Priority)
- **Aliens** - Enemy characters
- **Boss enemies** - Special encounter sprites

### 4. UI Elements (Lower Priority)
- **Icons** - Menu and interface elements
- **Buttons** - Interactive UI components

## Recommended Free Resources

### Character Sprites

#### 1. Puny Characters (Best for Main Characters)
- **Download**: https://opengameart.org/content/puny-characters
- **License**: CC0 (Public Domain)
- **Author**: Shade
- **Size**: 16x16 (fits in 32x32 canvas)
- **Features**: 8-directional movement, multiple animations
- **Animations**: Idle, Walk, Sword Attack, Bow Attack, Staff Attack, Throw, Hurt, Death
- **Perfect for**: Mark, Jenny, Hassan, Glen

#### 2. Pixel Adventure Characters
- **Download**: https://pixelfrog-assets.itch.io/pixel-adventure-1
- **License**: CC0 (Public Domain)
- **Author**: Pixel Frog
- **Features**: Complete character set with animations
- **Perfect for**: Supporting wedding guests, NPCs

#### 3. Tiny Hero Sprites
- **Download**: https://free-game-assets.itch.io/free-tiny-hero-sprites-pixel-art
- **License**: CC0 (Public Domain)
- **Author**: Free Game Assets (Craftpix)
- **Size**: 32x32
- **Features**: Cute character style, multiple animations
- **Perfect for**: Supporting characters, friendly NPCs

### Item Graphics

#### 1. 100 Glitch Icons
- **Download**: https://opengameart.org/content/100-glitch-icons
- **License**: CC0 (Public Domain)
- **Author**: rubberduck
- **Features**: 100 different item icons
- **Perfect for**: Wedding ring, camera, tools, collectibles

#### 2. RPG Item Collections
- **Download**: https://opengameart.org/content/rpg-item-collection-1
- **License**: CC0 (Public Domain)
- **Features**: Various RPG items and objects
- **Perfect for**: Additional collectibles and items

### Enemy Sprites

#### 1. Alien Characters
- **Download**: https://opengameart.org/content/space-shooter-pack
- **License**: CC0 (Public Domain)
- **Features**: Various alien enemy sprites
- **Perfect for**: Alien enemies in the game

## Step-by-Step Replacement Process

### Phase 1: Download and Organize

1. **Create a workspace folder** on your computer for downloaded assets
2. **Download the recommended asset packs** from the links above
3. **Extract all files** and organize by type (characters, items, enemies)
4. **Review the assets** and select the best fits for each character

### Phase 2: Character Replacement

#### For Mark (Groom):
1. Download "Puny Characters" pack
2. Select a character sprite that looks formal/groom-like
3. Recolor if needed to match wedding theme (dark suit, etc.)
4. Replace `assets/graphics/placeholders/mark_spritesheet.png`
5. Update any character references in Godot scenes

#### For Jenny (Bride):
1. Use "Puny Characters" pack
2. Select a character that can represent a bride
3. Recolor to white/wedding dress colors if possible
4. Replace `assets/graphics/placeholders/jenny_spritesheet.png`

#### For Supporting Characters:
1. Use "Pixel Adventure" or "Tiny Hero Sprites"
2. Assign different characters to Hassan, Glen, Dan, etc.
3. Ensure visual variety between characters
4. Replace respective placeholder files

### Phase 3: Item Replacement

#### Wedding Ring:
1. Use "100 Glitch Icons" pack
2. Find a ring or jewelry icon
3. Recolor to gold if needed
4. Replace current wedding ring asset

#### Camera:
1. Use "100 Glitch Icons" pack
2. Find camera or tool icon
3. Ensure it fits the game's pixel art style
4. Replace current camera asset

### Phase 4: Testing and Integration

1. **Test in Godot**: Import new assets and test in game
2. **Check animations**: Ensure sprite sheets work correctly
3. **Verify scaling**: Confirm assets look good at game resolution
4. **Update references**: Fix any broken texture references

## Technical Guidelines

### Sprite Sheet Format
- Ensure sprite sheets maintain the same layout as originals
- Keep frame counts consistent for animations
- Maintain transparent backgrounds

### Color Palette
- Try to maintain a consistent color palette across characters
- Wedding theme: whites, golds, pastels for formal wear
- Character variety: different hair colors, clothing styles

### File Naming
- Keep original file names for easy replacement
- Use descriptive names for new custom assets
- Maintain folder structure for organization

## Asset Attribution

While CC0 assets don't require attribution, we include it as good practice:

```markdown
# Asset Credits

## Character Sprites
- Puny Characters by Shade (CC0) - https://opengameart.org/content/puny-characters
- Pixel Adventure by Pixel Frog (CC0) - https://pixelfrog-assets.itch.io/pixel-adventure-1
- Tiny Hero Sprites by Free Game Assets (CC0) - https://free-game-assets.itch.io/free-tiny-hero-sprites-pixel-art

## Item Graphics
- 100 Glitch Icons by rubberduck (CC0) - https://opengameart.org/content/100-glitch-icons
```

## Customization Tips

### Recoloring Characters
- Use image editing software (GIMP, Photoshop, Aseprite)
- Maintain the original sprite structure
- Keep consistent lighting and shading style

### Wedding Theme Adaptations
- **Groom**: Dark suit colors (black, navy, gray)
- **Bride**: White, cream, or light colors
- **Guests**: Variety of formal wear colors
- **Accessories**: Ties, jewelry, formal shoes

### Animation Considerations
- Ensure walk cycles are smooth
- Maintain consistent frame timing
- Test animations in Godot before finalizing

## Quality Checklist

Before finalizing replacements:
- [ ] All sprites are properly sized and formatted
- [ ] Animations play smoothly in Godot
- [ ] Characters are visually distinct from each other
- [ ] Wedding theme is maintained throughout
- [ ] No broken texture references in scenes
- [ ] Attribution file is updated
- [ ] Assets are organized in proper folders

## Backup Strategy

**Important**: Always backup your original placeholder files before replacement:
1. Copy `assets/graphics/placeholders/` to `assets/graphics/placeholders_backup/`
2. This allows you to revert changes if needed
3. Keep downloaded source files organized for future reference

## Future Improvements

As you develop the game further, consider:
- Creating custom sprites specifically for your wedding theme
- Commissioning unique character art for main characters
- Adding more animation frames for smoother movement
- Creating seasonal or outfit variations for characters

---

*This guide ensures all placeholder images are replaced with high-quality, legally-safe pixel art that enhances the visual appeal of your wedding game while maintaining the retro aesthetic.*
