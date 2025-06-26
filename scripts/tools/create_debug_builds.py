#!/usr/bin/env python3
"""
Create debug export builds using Godot 4 command line export
"""

import os
import subprocess
import sys
from pathlib import Path

def find_godot_executable():
    """Find the Godot executable on the system"""
    # Common Godot executable names to try
    godot_names = [
        'godot',
        'godot4',
        'godot.exe',
        'Godot.exe',
        'flatpak run org.godotengine.Godot',
        'snap run godot'
    ]
    
    for name in godot_names:
        try:
            if 'flatpak' in name or 'snap' in name:
                # Test full command
                result = subprocess.run(name.split() + ['--version'], 
                                      capture_output=True, text=True, timeout=10)
                if result.returncode == 0:
                    return name.split()
            else:
                # Test single executable
                result = subprocess.run([name, '--version'], 
                                      capture_output=True, text=True, timeout=10)
                if result.returncode == 0:
                    return [name]
        except (FileNotFoundError, subprocess.TimeoutExpired):
            continue
    
    return None

def export_debug_build(project_path, export_preset, output_path, godot_cmd):
    """Export a debug build using Godot command line"""
    try:
        cmd = godot_cmd + [
            '--headless',
            '--export-debug',
            export_preset,
            output_path
        ]
        
        print(f"Running: {' '.join(cmd)}")
        print(f"Working directory: {project_path}")
        
        result = subprocess.run(
            cmd,
            cwd=project_path,
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout
        )
        
        if result.returncode == 0:
            print(f"Successfully exported {export_preset} to {output_path}")
            return True
        else:
            print(f"Export failed for {export_preset}:")
            print(f"STDOUT: {result.stdout}")
            print(f"STDERR: {result.stderr}")
            return False
            
    except subprocess.TimeoutExpired:
        print(f"Export timed out for {export_preset}")
        return False
    except Exception as e:
        print(f"Error exporting {export_preset}: {e}")
        return False

def main():
    project_root = "/home/joe/Documents/wedding-game-v7"
    builds_dir = os.path.join(project_root, "builds", "debug")
    
    # Ensure builds directory exists
    Path(builds_dir).mkdir(parents=True, exist_ok=True)
    
    # Find Godot executable
    godot_cmd = find_godot_executable()
    if not godot_cmd:
        print("ERROR: Could not find Godot executable")
        print("Please install Godot 4.x or ensure it's in your PATH")
        return False
    
    print(f"Found Godot: {' '.join(godot_cmd)}")
    
    # Export presets to try
    exports = [
        ("Linux/X11", "wedding-game-debug-linux.x86_64"),
        ("Windows Desktop", "wedding-game-debug-windows.exe")
    ]
    
    success_count = 0
    for preset_name, filename in exports:
        output_path = os.path.join(builds_dir, filename)
        if export_debug_build(project_root, preset_name, output_path, godot_cmd):
            success_count += 1
        print("-" * 50)
    
    print(f"Export complete: {success_count}/{len(exports)} builds successful")
    
    # List created files
    if os.path.exists(builds_dir):
        print("\nCreated files:")
        for file in os.listdir(builds_dir):
            file_path = os.path.join(builds_dir, file)
            if os.path.isfile(file_path):
                size_mb = os.path.getsize(file_path) / (1024 * 1024)
                print(f"  {file} ({size_mb:.1f} MB)")
    
    return success_count > 0

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)