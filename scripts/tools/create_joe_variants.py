#!/usr/bin/env python3
"""
Create Joe character variants from CC0 sprites
"""

import os
from PIL import Image

def create_walking_spritesheet(character_sprite_path, output_path, sprite_width=24, sprite_height=32):
    """Create a walking spritesheet from a single character sprite"""
    char_sprite = Image.open(character_sprite_path)
    
    spritesheet_width = sprite_width * 4
    spritesheet_height = sprite_height
    spritesheet = Image.new('RGBA', (spritesheet_width, spritesheet_height), (0, 0, 0, 0))
    
    for i in range(4):
        x_offset = i * sprite_width
        spritesheet.paste(char_sprite, (x_offset, 0))
    
    spritesheet.save(output_path)
    print(f"Created walking spritesheet: {output_path}")

def main():
    project_root = "/home/joe/Documents/wedding-game-v7"
    characters_path = os.path.join(project_root, "assets/sprites/characters_cc0")
    placeholders_path = os.path.join(project_root, "assets/graphics/placeholders")
    
    # Joe character variants
    joe_variants = {
        "acids_joe_spritesheet.png": "character_006.png",      # Colorful character for Acids Joe
        "psychedelic_joe_spritesheet.png": "character_018.png"  # Different character for Psychedelic Joe
    }
    
    for placeholder_name, character_file in joe_variants.items():
        character_sprite_path = os.path.join(characters_path, character_file)
        output_path = os.path.join(placeholders_path, placeholder_name)
        
        if os.path.exists(character_sprite_path):
            create_walking_spritesheet(character_sprite_path, output_path)
        else:
            print(f"Warning: Character sprite not found: {character_sprite_path}")

if __name__ == "__main__":
    main()