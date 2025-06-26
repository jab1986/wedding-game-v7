#!/usr/bin/env python3
"""
Create debug package for playtesting by packaging the project files
"""

import os
import shutil
import zipfile
from pathlib import Path
from datetime import datetime

def create_debug_package(project_root, output_dir):
    """Create a debug package of the wedding game project"""
    
    # Create timestamp for build
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    package_name = f"wedding-game-debug_{timestamp}"
    package_dir = os.path.join(output_dir, package_name)
    
    print(f"Creating debug package: {package_name}")
    
    # Create package directory
    os.makedirs(package_dir, exist_ok=True)
    
    # Files and directories to include
    include_patterns = [
        "project.godot",
        "scenes/",
        "scripts/",
        "assets/",
        "addons/",
        "export_presets.cfg",
        "icon.svg"
    ]
    
    # Files to exclude
    exclude_patterns = [
        "__pycache__",
        ".git",
        ".godot",
        "builds/",
        ".tmp",
        "*.log",
        "*.tmp"
    ]
    
    # Copy project files
    for pattern in include_patterns:
        source_path = os.path.join(project_root, pattern)
        dest_path = os.path.join(package_dir, pattern)
        
        if os.path.exists(source_path):
            if os.path.isfile(source_path):
                # Copy file
                os.makedirs(os.path.dirname(dest_path), exist_ok=True)
                shutil.copy2(source_path, dest_path)
                print(f"  Copied file: {pattern}")
            elif os.path.isdir(source_path):
                # Copy directory
                shutil.copytree(source_path, dest_path, 
                              ignore=shutil.ignore_patterns(*exclude_patterns))
                print(f"  Copied directory: {pattern}")
    
    # Create instructions file
    instructions = """# Wedding Game Debug Build - Testing Instructions

## System Requirements
- Godot Engine 4.4+ (Download from https://godotengine.org/)
- Operating System: Windows, Mac, or Linux

## How to Run the Game
1. Install Godot Engine 4.4 or later
2. Open Godot Engine
3. Click "Import" and select the project.godot file in this folder
4. Once imported, click the "Play" button (▶) to start the game

## Controls
- Arrow Keys or WASD: Move character
- Space: Jump
- Enter: Interact/Confirm
- Escape: Pause/Back
- F1-F5: Debug shortcuts (for testing)

## Testing Focus Areas
Please test and provide feedback on:

### 1. Character Movement & Controls
- How responsive do the controls feel?
- Are the jump mechanics intuitive?
- Any issues with character getting stuck?

### 2. Wedding Theme & Story
- Is the wedding theme engaging and fun?
- Are the characters likeable and memorable?
- Does the story flow make sense?

### 3. Visual & Audio Experience
- How do the graphics look? (SNES-style pixel art)
- Is the audio pleasant and fitting?
- Any visual glitches or issues?

### 4. Difficulty & Accessibility
- Is the game too easy or too hard?
- Are the objectives clear?
- Can you complete the wedding adventure?

### 5. Overall Fun Factor
- Would you recommend this game to friends?
- What did you enjoy most?
- What needs improvement?

## Feedback Collection
Please provide feedback via:
- Email: [your-email@example.com]
- Or create a text file with your feedback and include it when returning

## Technical Issues
If you encounter crashes or technical problems:
1. Check the Godot console for error messages
2. Note exactly what you were doing when the issue occurred
3. Include system specs (OS, graphics card, etc.)

## Debug Features (For Advanced Testers)
- F1: Toggle collision visualization
- F2: Toggle navigation mesh display  
- F3: Show performance metrics
- F4: Enable debug draw mode
- F5: Export test session data

Thank you for helping test the Wedding Game!
Generated: """ + datetime.now().strftime("%Y-%m-%d %H:%M:%S") + """
"""
    
    with open(os.path.join(package_dir, "TESTING_INSTRUCTIONS.txt"), "w") as f:
        f.write(instructions)
    
    # Create zip file
    zip_path = os.path.join(output_dir, f"{package_name}.zip")
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(package_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arc_path = os.path.relpath(file_path, package_dir)
                zipf.write(file_path, arc_path)
    
    # Calculate package size
    package_size = os.path.getsize(zip_path) / (1024 * 1024)
    
    print(f"Debug package created successfully!")
    print(f"Package: {zip_path}")
    print(f"Size: {package_size:.1f} MB")
    
    # Clean up directory version
    shutil.rmtree(package_dir)
    
    return zip_path

def main():
    project_root = "/home/joe/Documents/wedding-game-v7"
    output_dir = os.path.join(project_root, "builds", "debug")
    
    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)
    
    # Create debug package
    package_path = create_debug_package(project_root, output_dir)
    
    print("\nDebug package ready for distribution!")
    print(f"Location: {package_path}")
    print("\nNext steps:")
    print("1. Test the package yourself by extracting and running in Godot")
    print("2. Distribute to testers with TESTING_INSTRUCTIONS.txt")
    print("3. Collect feedback and analyze results")

if __name__ == "__main__":
    main()