# Wedding Game - Godot 4 Integration Guide

This guide explains how to integrate all the created scripts and systems into a complete Godot 4 project.

## 🏗️ Project Structure Setup

### 1. Create Base Godot Project
```
wedding-game-godot/
├── project.godot
├── .gitignore
├── scenes/
├── scripts/
├── assets/
└── resources/
```

### 2. Scene File Structure (.tscn files)

#### Main Menu Scene (MainMenu.tscn)
```
MainMenu (Control)
├── Background (TextureRect)
├── VBoxContainer
│   ├── TitleLabel (Label)
│   ├── SubtitleLabel (Label)
│   └── MenuContainer (VBoxContainer)
│       ├── StartButton (Button)
│       ├── ContinueButton (Button)
│       ├── OptionsButton (Button)
│       └── QuitButton (Button)
├── CharactersPreview (Node2D)
├── VersionLabel (Label)
```

# Rest of the content from godot_project_integration.md