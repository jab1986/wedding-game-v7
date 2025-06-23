#!/usr/bin/env python3
"""Create placeholder sprites for the wedding game"""

from PIL import Image
import os

def create_drumstick():
    """Create a brown drumstick sprite"""
    img = Image.new('RGBA', (16, 6), (139, 69, 19, 255))  # Brown
    return img

def create_camera():
    """Create a camera sprite"""
    img = Image.new('RGBA', (12, 8), (32, 32, 32, 255))  # Dark grey
    # Add white flash
    for x in range(2, 6):
        for y in range(2, 4):
            img.putpixel((x, y), (255, 255, 255, 255))
    return img

def main():
    items_dir = "assets/graphics/items"
    os.makedirs(items_dir, exist_ok=True)
    
    # Create drumstick
    drumstick = create_drumstick()
    drumstick.save(os.path.join(items_dir, "drumstick.png"))
    print("Created drumstick.png")
    
    # Create camera
    camera = create_camera()
    camera.save(os.path.join(items_dir, "camera.png"))
    print("Created camera.png")
    
    print("Placeholder sprites created successfully!")

if __name__ == "__main__":
    main()