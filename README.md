# Mark & Jenny's Wedding Adventure - Godot 4 Version

A disaster-filled SNES-style wedding adventure game where you navigate through chaos to finally say "I do!"

**Note: This is a desktop-only game optimized for keyboard, mouse, and gamepad controls.**

## 🎮 Game Overview

Play as Mark and Jenny as they try to make it to their wedding ceremony despite:
- 👽 Alien invasions playing bad Ghostbusters covers
- 🔥 Mysterious shed fires
- 💩 Sewage explosions
- 🤪 A psychedelic final boss named Acids Joe
- 😕 Glen's general confusion about everything

## 🚀 Getting Started

### Requirements
- Godot 4.3 or higher
- 2GB RAM minimum
- OpenGL ES 3.0 compatible graphics
- Desktop platform (Windows, macOS, or Linux)

### Installation
1. Clone this repository
2. Open Godot 4
3. Import the project by selecting the `project.godot` file
4. Press F5 or click the Play button to run

## 🎯 Game Features

### Characters
- **Mark**: Punk drummer with fast drumstick attacks
- **Jenny**: Photographer with powerful camera bombs (unlockable)
- **Glen**: Confused dad who makes everything worse
- **Quinn**: Competent mom trying to manage the chaos
- **Jack**: Hipster cafe owner with vegan supplies
- **Acids Joe**: Final boss with tooth problems and psychedelic powers

### Levels
1. **Amsterdam Tutorial** - Learn controls and propose
2. **Glen's House** - Survive escalating disasters
3. **Glen Bingo** - Quiz mini-game to unlock Jenny
4. **Leo's Cafe** - Rest and restore energy
5. **Wedding Venue** - Combat gauntlet with allies
6. **Boss Fight** - Two-phase battle with Acids Joe
7. **Ceremony** - Finally get married!

## 🎨 Controls

### Keyboard
- **Arrow Keys/WASD**: Move
- **Space**: Jump/Interact
- **X**: Attack
- **Tab**: Switch characters (when Jenny is unlocked)
- **Escape**: Pause

### Gamepad
- **D-Pad/Left Stick**: Move
- **A Button**: Jump/Interact
- **X Button**: Attack
- **L1**: Switch characters
- **Start**: Pause

## 📁 Project Structure

```
wedding-game-godot/
├── assets/                 # Game assets
│   ├── sprites/           # Character and item sprites
│   ├── audio/             # Music and sound effects
│   └── fonts/             # Game fonts
├── scenes/                # Godot scenes
│   ├── levels/            # Level scenes
│   ├── entities/          # Player, enemies, NPCs
│   ├── ui/                # Menus and HUD
│   └── effects/           # Visual effects
├── scripts/               # GDScript files
│   ├── autoload/          # Global scripts
│   ├── entities/          # Entity behaviors
│   └── utils/             # Utility scripts
└── resources/             # Godot resources
    ├── characters/        # Character data
    └── dialogue/          # Dialogue resources
```

## 🛠️ Development with MCP

This project uses Model Context Protocol (MCP) servers to assist development:

1. **Context7** - For accessing Godot documentation
2. **TaskMaster** - For tracking development tasks
3. **Sequential Thinking** - For breaking down complex problems
4. **Godot MCP** - For implementing and testing code

See `docs/mcp_setup.md` and `docs/mcp_server_guide.md` for details on using these tools.

## 🛠️ Development

### Adding New Sprites
1. Place sprite files in `assets/sprites/` appropriate subfolder
2. Update `SpriteConfig.gd` with display sizes
3. Use `SpriteManager.create_sprite()` to ensure consistent sizing

### Creating New Levels
1. Create new scene inheriting from `Node2D`
2. Add to `scenes/levels/` folder
3. Update `GameManager.level_order` array
4. Implement save/load support if needed

### State Machine Usage
All entities use the State Machine pattern:
```gdscript
extends Node2D

@onready var state_machine: StateMachine = $StateMachine

func _ready():
    # States are added as children of StateMachine node
    state_machine.transition_to("Idle")
```

### Integrated Plugins
This project uses several third-party plugins to enhance functionality:

1. **Dialogue Manager** - For character dialogue and conversations
   - Used in NPC interactions and cutscenes
   - Dialogue files stored in `dialogues/` directory

2. **Beehave** - For enemy and boss AI behavior trees
   - Used for complex enemy behaviors
   - Particularly for the Acids Joe boss fight

3. **Phantom Camera** - For dynamic camera control
   - Used for cinematic camera movements
   - Enhances boss fights and key scenes

See `docs/plugins_integration.md` for detailed usage information.

## 🐛 Debug Mode

Press F1-F3 for debug options:
- **F1**: Toggle hitbox display
- **F2**: Skip to boss fight
- **F3**: Unlock all items

## 🎵 Audio Credits

- Menu Theme: [Placeholder]
- Boss Music: [Placeholder]
- Agent Elf MIDI: [Placeholder]

## 📝 Known Issues

- Some sprite assets need proper sizing
- Audio files need to be added
- Performance optimization needed for particle effects

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Follow Godot 4 best practices
4. Submit a pull request

## 📜 License

[Your License Here]

## 🙏 Acknowledgments

- Special thanks to Agent Elf for the MIDI magic
- The aliens for their terrible music
- Glen for being Glen

---

Made with ❤️ and chaos using Godot 4