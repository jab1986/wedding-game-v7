#!/usr/bin/env python3
"""
Create placeholder sprites for the wedding game with exact dimensions
"""
from PIL import Image, ImageDraw, ImageFont
import os

# Character specifications
CHARACTERS = {
    # Main Playable Characters (32x32)
    'mark': {'size': (32, 32), 'frames': 8, 'color': '#4169E1', 'name': 'Mark'},
    'jenny': {'size': (32, 32), 'frames': 8, 'color': '#FF69B4', 'name': 'Jenny'},
    
    # Family NPCs (36x36)
    'glen': {'size': (36, 36), 'frames': 6, 'color': '#8B4513', 'name': 'Glen'},
    'quinn': {'size': (36, 36), 'frames': 6, 'color': '#9932CC', 'name': 'Quinn'},
    
    # Cafe and Brothers (32x32)
    'jack': {'size': (32, 32), 'frames': 6, 'color': '#228B22', 'name': 'Jack'},
    'tom': {'size': (32, 32), 'frames': 4, 'color': '#FF6347', 'name': 'Tom'},
    
    # Band Members (32x32)
    'hassan': {'size': (32, 32), 'frames': 4, 'color': '#8A2BE2', 'name': 'Hassan'},
    'paul': {'size': (32, 32), 'frames': 4, 'color': '#DC143C', 'name': 'Paul'},
    
    # Combat Allies (32x32)
    'gaz': {'size': (32, 32), 'frames': 4, 'color': '#00CED1', 'name': 'Gaz'},
    'matt': {'size': (32, 32), 'frames': 6, 'color': '#FF8C00', 'name': 'Matt'},
    'dan': {'size': (32, 32), 'frames': 6, 'color': '#800080', 'name': 'Dan'},
    
    # Enemies
    'alien': {'size': (28, 28), 'frames': 6, 'color': '#00FF00', 'name': 'Alien'},
    'acids_joe': {'size': (48, 48), 'frames': 8, 'color': '#FF0000', 'name': 'Acids Joe'},
    'psychedelic_joe': {'size': (64, 64), 'frames': 8, 'color': '#FF1493', 'name': 'Psychedelic Joe'},
}

def create_placeholder_sprite(char_name, char_data):
    """Create a placeholder sprite sheet for a character"""
    width, height = char_data['size']
    frames = char_data['frames']
    color = char_data['color']
    name = char_data['name']
    
    # Create sprite sheet (horizontal strip)
    sheet_width = width * frames
    sheet_height = height
    
    # Create image with transparency
    sprite_sheet = Image.new('RGBA', (sheet_width, sheet_height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(sprite_sheet)
    
    for frame in range(frames):
        x_offset = frame * width
        
        # Draw character placeholder (simple colored rectangle with border)
        draw.rectangle(
            [x_offset + 2, 2, x_offset + width - 2, height - 2],
            fill=color,
            outline='#000000'
        )
        
        # Add simple face (dots for eyes)
        if width >= 16:  # Only add face if sprite is big enough
            eye_size = max(1, width // 16)
            draw.ellipse([x_offset + width//4, height//4, 
                         x_offset + width//4 + eye_size, height//4 + eye_size], 
                        fill='#000000')
            draw.ellipse([x_offset + 3*width//4, height//4, 
                         x_offset + 3*width//4 + eye_size, height//4 + eye_size], 
                        fill='#000000')
        
        # Add simple animation variation (slightly different positions)
        if frame % 2 == 1:  # Odd frames - slightly different
            draw.rectangle(
                [x_offset + 4, 4, x_offset + width - 4, height - 4],
                fill=None,
                outline='#FFFFFF'
            )
    
    return sprite_sheet

def main():
    # Create placeholders directory
    placeholder_dir = '/home/joe/Documents/wedding-game-v7/assets/graphics/placeholders'
    os.makedirs(placeholder_dir, exist_ok=True)
    
    print("Creating placeholder sprites...")
    
    for char_name, char_data in CHARACTERS.items():
        try:
            sprite_sheet = create_placeholder_sprite(char_name, char_data)
            filename = f"{char_name}_spritesheet.png"
            filepath = os.path.join(placeholder_dir, filename)
            
            sprite_sheet.save(filepath)
            print(f"✓ Created {filename} ({char_data['size'][0]}x{char_data['size'][1]}, {char_data['frames']} frames)")
            
        except Exception as e:
            print(f"✗ Failed to create {char_name}: {e}")
    
    print(f"\nPlaceholder sprites created in: {placeholder_dir}")
    print("\nSprite Sheet Format:")
    print("- Horizontal strips (frames side by side)")
    print("- PNG with transparency")
    print("- Exact dimensions as specified")

if __name__ == "__main__":
    main()