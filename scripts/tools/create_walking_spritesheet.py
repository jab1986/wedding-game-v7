#!/usr/bin/env python3
"""
Create walking spritesheet from individual character sprite
"""

import os
from PIL import Image

def create_walking_spritesheet(character_sprite_path, output_path, sprite_width=24, sprite_height=32):
    """
    Create a walking spritesheet from a single character sprite by duplicating it in 4 frames
    """
    # Load the source character sprite
    char_sprite = Image.open(character_sprite_path)
    
    # Create a new image for the spritesheet (4 frames wide)
    spritesheet_width = sprite_width * 4
    spritesheet_height = sprite_height
    spritesheet = Image.new('RGBA', (spritesheet_width, spritesheet_height), (0, 0, 0, 0))
    
    # Place the character sprite 4 times (basic walking cycle)
    for i in range(4):
        x_offset = i * sprite_width
        spritesheet.paste(char_sprite, (x_offset, 0))
    
    # Save the spritesheet
    spritesheet.save(output_path)
    print(f"Created walking spritesheet: {output_path}")

def main():
    project_root = "/home/joe/Documents/wedding-game-v7"
    characters_path = os.path.join(project_root, "assets/sprites/characters_cc0")
    placeholders_path = os.path.join(project_root, "assets/graphics/placeholders")
    
    # Character mappings - which extracted sprite to use for each game character
    character_mappings = {
        "glen_spritesheet.png": "character_048.png",  # Green character for Glen
        "dan_spritesheet.png": "character_000.png",   # Brown character for Dan
        "gaz_spritesheet.png": "character_024.png",   # Different colored character for Gaz
        "hassan_spritesheet.png": "character_012.png", # Another character for Hassan
        "jack_spritesheet.png": "character_036.png",   # Different character for Jack
        "matt_spritesheet.png": "character_060.png",   # Another character for Matt
        "paul_spritesheet.png": "character_072.png",   # Another character for Paul
        "tom_spritesheet.png": "character_084.png",    # Another character for Tom
        "quinn_spritesheet.png": "character_016.png",  # Character for Quinn
    }
    
    # Create walking spritesheets for each character
    for placeholder_name, character_file in character_mappings.items():
        character_sprite_path = os.path.join(characters_path, character_file)
        output_path = os.path.join(placeholders_path, placeholder_name)
        
        if os.path.exists(character_sprite_path):
            create_walking_spritesheet(character_sprite_path, output_path)
        else:
            print(f"Warning: Character sprite not found: {character_sprite_path}")

if __name__ == "__main__":
    main()