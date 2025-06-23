# Godot 4 Wedding Game Project Structure

wedding-game-godot/
├── project.godot
├── .gitignore
├── .gdignore
├── README.md
├── assets/
│   ├── sprites/
│   │   ├── characters/
│   │   │   ├── mark/
│   │   │   │   ├── mark_spritesheet.png
│   │   │   │   └── mark_spritesheet.png.import
│   │   │   ├── jenny/
│   │   │   ├── glen/
│   │   │   └── ...
│   │   ├── items/
│   │   ├── effects/
│   │   └── ui/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   └── fonts/
├── scenes/
│   ├── game/
│   │   ├── Game.tscn
│   │   └── Game.gd
│   ├── levels/
│   │   ├── AmsterdamLevel.tscn
│   │   ├── AmsterdamLevel.gd
│   │   ├── GlenHouseLevel.tscn
│   │   ├── GlenHouseLevel.gd
│   │   ├── GlenBingoLevel.tscn
│   │   ├── GlenBingoLevel.gd
│   │   ├── LeoCafeLevel.tscn
│   │   ├── LeoCafeLevel.gd
│   │   ├── WeddingVenueLevel.tscn
│   │   ├── WeddingVenueLevel.gd
│   │   ├── BossFightLevel.tscn
│   │   ├── BossFightLevel.gd
│   │   ├── CeremonyLevel.tscn
│   │   └── CeremonyLevel.gd
│   ├── ui/
│   │   ├── MainMenu.tscn
│   │   ├── MainMenu.gd
│   │   ├── HUD.tscn
│   │   ├── HUD.gd
│   │   ├── DialogueBox.tscn
│   │   └── DialogueBox.gd
│   ├── entities/
│   │   ├── player/
│   │   │   ├── Player.tscn
│   │   │   └── Player.gd
│   │   ├── npcs/
│   │   │   ├── NPC.tscn
│   │   │   ├── NPC.gd
│   │   │   ├── Glen.tscn
│   │   │   └── Glen.gd
│   │   ├── enemies/
│   │   │   ├── Alien.tscn
│   │   │   ├── Alien.gd
│   │   │   ├── AcidsJoe.tscn
│   │   │   └── AcidsJoe.gd
│   │   └── projectiles/
│   │       ├── Drumstick.tscn
│   │       ├── Drumstick.gd
│   │       ├── CameraBomb.tscn
│   │       └── CameraBomb.gd
│   └── components/
│       ├── Health.tscn
│       ├── Health.gd
│       ├── Hitbox.tscn
│       ├── Hitbox.gd
│       ├── Hurtbox.tscn
│       └── Hurtbox.gd
├── scripts/
│   ├── autoload/
│   │   ├── GameManager.gd
│   │   ├── AudioManager.gd
│   │   ├── SceneTransition.gd
│   │   └── SaveGame.gd
│   ├── resources/
│   │   ├── CharacterData.gd
│   │   ├── DialogueResource.gd
│   │   └── LevelData.gd
│   └── utils/
│       ├── StateMachine.gd
│       ├── InputHandler.gd
└── resources/
    ├── characters/
    │   ├── mark_data.tres
    │   ├── jenny_data.tres
    │   └── glen_data.tres
    ├── dialogue/
    │   ├── glen_dialogue.tres
    │   └── bingo_questions.tres
    └── levels/
        └── level_progression.tres
