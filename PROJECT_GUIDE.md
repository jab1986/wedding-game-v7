# Wedding Game Project Completion Guide

## Remaining Components

### Scenes to Complete
1. **Glen Bingo Scene** - Quiz mini-game
2. **Leo's Cafe Scene** - Rest area with character switching
3. **Wedding Venue Scene** - Combat gauntlet before boss
4. **Boss Fight Scene** - Acids Joe battle
5. **Ceremony Scene** - Final victory scene

### Systems to Implement
1. **Specific NPC implementations** - Glen, Quinn, Jack, etc.
2. **Dialogue System** - For managing conversations
3. **Desktop Controls & Optimization** - Performance and usability
4. **Save/Load System** - Persistent game state

## Development Rules

### Code Organization
- All scripts must follow the established directory structure
- Use class_name for all script classes
- Add comments with `##` for class descriptions and `#` for method descriptions
- Follow GDScript style guide (snake_case for variables/functions, PascalCase for classes)

### Scene Organization
- Each scene should have a root node named after the scene (e.g., "GlenBingoLevel")
- Group related nodes using Node2D containers with descriptive names
- Use consistent Z-indexing: background (-10), world (0), characters (10), UI (100)
- Add scene metadata comments at the top of each script

### Asset Guidelines
- Follow sprite standards in `assets/sprites/README.md`
- Audio files: OGG format, 44.1kHz, stereo for music, mono for SFX
- Maximum texture size: 1024x1024 (prefer smaller when possible)
- Use texture atlases for related sprites

## MCP Integration Guidelines

### Context 7 (Documentation)
- Document all public methods and properties
- Create separate documentation files for complex systems
- Use markdown format for documentation
- Include usage examples for key systems

### Taskmaster (Task Management)
- Break down each remaining component into subtasks
- Prioritize tasks based on dependencies
- Track progress with completion percentages
- Link tasks to relevant files/scenes

### Godot MCP Server (Debugging)
- Set up logging for key game events
- Create debug visualization tools for hitboxes, paths, etc.
- Implement performance monitoring
- Add debug commands accessible through a console

### Rovo Dev (Troubleshooting)
- Document common issues and solutions
- Create minimal reproduction cases for bugs
- Use version control effectively (branches for features)
- Implement automated tests where possible

## Development Workflow

1. **Planning Phase**
   - Break down scene/system into components
   - Create task list in Taskmaster
   - Design data structures and interfaces

2. **Implementation Phase**
   - Create basic scene structure
   - Implement core functionality
   - Add placeholder assets
   - Test basic functionality

3. **Polish Phase**
   - Replace placeholders with final assets
   - Add visual effects and polish
   - Optimize performance
   - Add sound effects and music

4. **Testing Phase**
   - Test on target platforms
   - Fix bugs and issues
   - Balance difficulty
   - Get feedback from testers

## Scene-Specific Guidelines

### Glen Bingo Scene
- Implement question/answer data structure
- Create UI for displaying questions and options
- Add scoring system
- Implement rewards for completion

### Leo's Cafe Scene
- Create character switching mechanic
- Implement NPC interactions
- Add healing/buff items
- Design peaceful environment with ambient animations

### Wedding Venue Scene
- Create combat encounter system
- Implement enemy waves
- Add environmental hazards
- Design progression gates

### Boss Fight Scene
- Implement multi-phase boss behavior
- Create special attacks and patterns
- Add visual effects for phase transitions
- Balance difficulty curve

### Ceremony Scene
- Create cutscene system
- Implement dialogue sequences
- Add particle effects and celebration visuals
- Design credits sequence

## System-Specific Guidelines

### NPC Implementation
- Create base NPC class with common functionality
- Extend for specific characters with unique behaviors
- Implement interaction system
- Add personality through dialogue and animations

### Dialogue System
- Create dialogue tree data structure
- Implement dialogue UI with portraits
- Add choice system for player responses
- Support for triggering events from dialogue

### Desktop Controls & Optimization
- Implement keyboard/mouse controls
- Create desktop-compatible UI
- Optimize asset loading for performance
- Implement control customization settings

### Save/Load System
- Define serializable game state
- Implement save file format
- Add auto-save functionality
- Create save/load UI

## Useful Commands and Snippets

### Debug Helpers
```gdscript
# Print debug info
print("Debug: ", some_variable)

# Visual debugging
func _draw():
    draw_rect(Rect2(0, 0, 100, 100), Color.RED, false)

# Performance monitoring
var start_time = Time.get_ticks_msec()
# ... code to measure ...
var elapsed = Time.get_ticks_msec() - start_time
print("Operation took: ", elapsed, "ms")
```

### Common Patterns
```gdscript
# Singleton access
var game_manager = get_node("/root/GameManager")

# Signal connection
some_node.connect("signal_name", _on_signal_name)

# Timer usage
var timer = Timer.new()
timer.wait_time = 2.0
timer.one_shot = true
timer.timeout.connect(_on_timer_timeout)
add_child(timer)
timer.start()

# Scene switching
get_tree().change_scene_to_file("res://scenes/levels/NextLevel.tscn")
```

## Testing Checklist

- [ ] Test with different screen resolutions
- [ ] Test keyboard/mouse controls
- [ ] Verify save/load functionality
- [ ] Check loading performance
- [ ] Test all dialogue paths
- [ ] Verify progression through all levels
- [ ] Test audio playback
- [ ] Verify all collectibles can be obtained
- [ ] Test performance with profiling tools