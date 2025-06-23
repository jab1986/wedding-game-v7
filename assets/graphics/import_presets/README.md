# Import Presets for Wedding Game

This directory contains import preset files that can be applied to textures in Godot to ensure consistent quality and performance.

## Available Presets

### pixel_art_sprite.import
Optimal settings for character sprites and pixel art:
- **Lossless compression** preserves pixel-perfect quality
- **No mipmaps** for sharp 2D graphics
- **Alpha border fix** prevents transparent edge artifacts
- **sRGB color space** for proper color reproduction

## How to Use

1. **In Godot Editor**:
   - Select your sprite in the FileSystem dock
   - Go to Import tab in the Inspector
   - Copy settings from the preset file
   - Click "Reimport"

2. **Batch Apply**:
   - Select multiple sprites
   - Change import settings on one
   - Other selected sprites will inherit the same settings

## Settings Explained

### Compression
- `compress/mode=0` (Lossless): Preserves original quality
- `compress/high_quality=false`: Fast compression for 2D
- `compress/channel_pack=0`: sRGB friendly color channels

### Processing
- `process/fix_alpha_border=true`: Fixes transparent edge artifacts
- `process/premult_alpha=false`: Standard alpha blending
- `process/size_limit=0`: No size restrictions

### Mipmaps
- `mipmaps/generate=false`: Disabled for pixel art sharpness
- `mipmaps/limit=-1`: Not applicable

### 3D Detection
- `detect_3d/compress_to=1`: Disabled for 2D-only sprites

These settings ensure your sprites look crisp and load quickly while maintaining the SNES-style aesthetic.