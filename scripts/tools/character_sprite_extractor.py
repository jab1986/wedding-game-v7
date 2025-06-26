#!/usr/bin/env python3
"""
Character Sprite Extractor
Extracts individual character sprites from spritesheets for use in the wedding game.
"""

import os
import sys
from PIL import Image
import json

def extract_character_grid(spritesheet_path, output_dir, grid_width, grid_height, sprite_width, sprite_height, character_names=None):
    """
    Extract characters from a grid-based spritesheet.
    
    Args:
        spritesheet_path: Path to the source spritesheet
        output_dir: Directory to save extracted sprites
        grid_width: Number of sprites horizontally
        grid_height: Number of sprites vertically
        sprite_width: Width of each sprite in pixels
        sprite_height: Height of each sprite in pixels
        character_names: Optional list of names for characters
    """
    
    # Load the spritesheet
    spritesheet = Image.open(spritesheet_path)
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    extracted_sprites = []
    
    for row in range(grid_height):
        for col in range(grid_width):
            # Calculate position
            x = col * sprite_width
            y = row * sprite_height
            
            # Extract sprite
            sprite = spritesheet.crop((x, y, x + sprite_width, y + sprite_height))
            
            # Generate filename
            sprite_index = row * grid_width + col
            if character_names and sprite_index < len(character_names):
                filename = f"{character_names[sprite_index]}.png"
            else:
                filename = f"character_{sprite_index:03d}.png"
            
            # Save sprite
            sprite_path = os.path.join(output_dir, filename)
            sprite.save(sprite_path, "PNG")
            
            extracted_sprites.append({
                "index": sprite_index,
                "filename": filename,
                "position": {"x": x, "y": y},
                "size": {"width": sprite_width, "height": sprite_height}
            })
            
            print(f"Extracted: {filename}")
    
    # Save extraction metadata
    metadata = {
        "source": spritesheet_path,
        "grid": {"width": grid_width, "height": grid_height},
        "sprite_size": {"width": sprite_width, "height": sprite_height},
        "sprites": extracted_sprites
    }
    
    metadata_path = os.path.join(output_dir, "extraction_metadata.json")
    with open(metadata_path, 'w') as f:
        json.dump(metadata, f, indent=2)
    
    print(f"Extracted {len(extracted_sprites)} sprites to {output_dir}")
    return extracted_sprites

def extract_characters_6():
    """Extract characters from characters_6.png (CC0)"""
    source_path = "/home/joe/Documents/wedding-game-v7/assets/downloaded_opengameart/cc0/Unknown/characters_6.png"
    output_dir = "/home/joe/Documents/wedding-game-v7/assets/sprites/characters_cc0"
    
    # Based on the image, it appears to be a 4-row spritesheet with different character types
    # Each character appears to be about 24x32 pixels
    extract_character_grid(
        spritesheet_path=source_path,
        output_dir=output_dir,
        grid_width=24,  # 24 columns
        grid_height=4,  # 4 rows
        sprite_width=24,
        sprite_height=32
    )

def extract_hyptosis_characters():
    """Extract characters from hyptosis spritesheet (CC-BY)"""
    source_path = "/home/joe/Documents/wedding-game-v7/assets/downloaded_opengameart/cc-by/Unknown/hyptosis_sprites-and-tiles-for-you.png"
    output_dir = "/home/joe/Documents/wedding-game-v7/assets/sprites/hyptosis_characters"
    
    # This spritesheet has mixed content, so we'll extract specific character regions
    # Bottom rows have character sprites - let's extract those
    spritesheet = Image.open(source_path)
    
    os.makedirs(output_dir, exist_ok=True)
    
    # Extract character animation frames from bottom rows
    # Characters appear to be around 24x24 pixels
    character_regions = [
        # Bottom character walk cycles
        {"name": "warrior_walk", "x": 0, "y": 520, "width": 24*25, "height": 24*2},
        {"name": "mage_walk", "x": 0, "y": 568, "width": 24*25, "height": 24*2},
        {"name": "archer_walk", "x": 0, "y": 616, "width": 24*4, "height": 24*1},
        # Character portraits/sprites from bottom right
        {"name": "various_chars", "x": 390, "y": 790, "width": 24*6, "height": 24*4}
    ]
    
    extracted_sprites = []
    
    for region in character_regions:
        region_sprite = spritesheet.crop((
            region["x"], 
            region["y"], 
            region["x"] + region["width"], 
            region["y"] + region["height"]
        ))
        
        filename = f"{region['name']}.png"
        sprite_path = os.path.join(output_dir, filename)
        region_sprite.save(sprite_path, "PNG")
        
        extracted_sprites.append({
            "name": region["name"],
            "filename": filename,
            "region": region
        })
        
        print(f"Extracted: {filename}")
    
    # Save metadata
    metadata = {
        "source": source_path,
        "license": "CC-BY",
        "regions": extracted_sprites
    }
    
    metadata_path = os.path.join(output_dir, "extraction_metadata.json")
    with open(metadata_path, 'w') as f:
        json.dump(metadata, f, indent=2)
    
    print(f"Extracted {len(extracted_sprites)} character regions to {output_dir}")

def create_character_spritesheet(character_name, sprite_size=(64, 64)):
    """
    Create a 4-frame animation spritesheet for a character.
    This creates a placeholder structure that can be filled with actual sprites.
    """
    # Create a blank spritesheet
    spritesheet_width = sprite_size[0] * 4
    spritesheet_height = sprite_size[1]
    
    spritesheet = Image.new('RGBA', (spritesheet_width, spritesheet_height), (0, 0, 0, 0))
    
    # For now, create a simple colored rectangle as placeholder
    # In practice, you'd paste actual character sprites here
    
    output_path = f"/home/joe/Documents/wedding-game-v7/assets/graphics/placeholders/{character_name}_spritesheet_new.png"
    spritesheet.save(output_path, "PNG")
    
    print(f"Created placeholder spritesheet: {output_path}")
    return output_path

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python character_sprite_extractor.py <command>")
        print("Commands:")
        print("  extract_cc0 - Extract characters from characters_6.png")
        print("  extract_hyptosis - Extract characters from hyptosis spritesheet")
        print("  extract_all - Extract from all sources")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "extract_cc0":
        extract_characters_6()
    elif command == "extract_hyptosis":
        extract_hyptosis_characters()
    elif command == "extract_all":
        extract_characters_6()
        extract_hyptosis_characters()
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)