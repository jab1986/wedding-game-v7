# Wedding Game Testing Workflow

## Overview

This document outlines the comprehensive internal testing environment for Mark & Jenny's Wedding Adventure. The testing system provides debugging tools, automated testing capabilities, and feedback collection mechanisms.

## TestingManager Singleton

The `TestingManager` is automatically loaded as a singleton and provides the core testing functionality.

### Debug Shortcuts (Function Keys)

| Key | Function | Description |
|-----|----------|-------------|
| **F1** | Toggle Debug Overlay | Enable/disable wireframe debug visualization |
| **F2** | Toggle Debug Collisions | Show/hide collision shapes and physics bodies |
| **F3** | Toggle Debug Navigation | Enable/disable navigation mesh visualization |
| **F4** | Simulate Random Input | Test random input actions for stress testing |
| **F5** | Export Test Session | Save current test session data to JSON file |

### Command Line Debug Flags

When launching Godot from command line, use these flags for enhanced debugging:

```bash
# Enable collision shape visualization
godot --debug-collisions

# Enable navigation debugging
godot --debug-navigation

# Verbose logging
godot --verbose

# Remote debugging
godot --remote-debug <host>:<port>
```

## Testing Features

### 1. Automatic Event Logging

The TestingManager automatically captures:
- User input events
- Scene changes
- Node additions/removals
- Performance metrics
- Debug messages

### 2. Input Simulation

```gdscript
# Simulate button press
TestingManager.simulate_input_event("ui_accept", true)

# Simulate mouse click at position
TestingManager.simulate_mouse_click(Vector2(100, 200))
```

### 3. Performance Monitoring

```gdscript
# Record performance metrics
TestingManager.measure_performance_metric("fps", Engine.get_frames_per_second())
TestingManager.measure_performance_metric("memory_usage", OS.get_static_memory_usage())
```

### 4. Wedding Game Specific Tests

```gdscript
# Run comprehensive wedding mechanics test
await TestingManager.test_wedding_mechanics()

# Test individual components
await TestingManager.test_character_dialogues()
await TestingManager.test_item_collection()
await TestingManager.test_boss_fight()
```

## Testing Workflow

### Phase 1: Internal Testing Setup

1. **Launch Game with Debug Mode**
   ```bash
   godot --debug-collisions --verbose
   ```

2. **Enable Debug Features**
   - Press `F1` to enable debug overlay
   - Press `F2` to show collision shapes
   - Press `F3` for navigation debugging

3. **Start Test Session**
   - TestingManager automatically starts a new session on launch
   - Session data is logged to `user://test_sessions/`

### Phase 2: Manual Testing

1. **Character Interaction Testing**
   - Approach each wedding character (Glen, Jenny, Mark, Hassan)
   - Test dialogue system responsiveness
   - Verify character-specific interactions

2. **Gameplay Mechanics Testing**
   - Test movement controls (WASD/Arrow keys)
   - Verify jump mechanics (Space)
   - Test attack system (X key)
   - Test interaction system (E key)

3. **Wedding-Specific Features**
   - Test wedding ring collection
   - Verify boss fight mechanics (Acids Joe)
   - Test disaster scenarios (Glen's house)
   - Verify audio feedback systems

### Phase 3: Automated Testing

1. **Run Automated Test Suite**
   ```gdscript
   # In console or script
   await TestingManager.test_wedding_mechanics()
   ```

2. **Stress Testing**
   - Use `F4` for random input simulation
   - Monitor performance metrics
   - Check for memory leaks or crashes

3. **Export Test Data**
   - Press `F5` to export session data
   - Review JSON files in `user://test_sessions/`

## Debug Visualization Features

### Collision Debug Mode (F2)
- Shows collision shapes for all physics bodies
- Displays collision layers and masks
- Useful for debugging player-enemy interactions

### Navigation Debug Mode (F3)
- Visualizes navigation meshes
- Shows pathfinding routes
- Helpful for NPC movement debugging

### Debug Overlay (F1)
- Wireframe rendering mode
- Shows node hierarchy visually
- Useful for understanding scene structure

## Performance Testing

### Key Metrics to Monitor

1. **Frame Rate (FPS)**
   - Target: 60 FPS minimum
   - Monitor during boss fights and complex scenes

2. **Memory Usage**
   - Watch for memory leaks during extended play
   - Check texture and audio memory consumption

3. **Input Latency**
   - Measure response time for player actions
   - Ensure responsive controls for wedding game mechanics

### Performance Testing Script

```gdscript
# Add to any scene for performance monitoring
func _process(delta):
    TestingManager.measure_performance_metric("fps", Engine.get_frames_per_second())
    TestingManager.measure_performance_metric("memory", OS.get_static_memory_usage())
    TestingManager.measure_performance_metric("delta_time", delta)
```

## Wedding Game Specific Testing Scenarios

### Scenario 1: Complete Wedding Adventure
1. Start from main menu
2. Navigate through all levels
3. Interact with all wedding characters
4. Collect all wedding rings
5. Complete boss fight with Acids Joe
6. Verify ending sequence

### Scenario 2: Accessibility Testing
1. Test with keyboard-only input
2. Verify gamepad support
3. Test with different screen resolutions
4. Check text readability and UI scaling

### Scenario 3: Audio Integration Testing
1. Verify SNES-style audio playback
2. Test audio feedback for all actions
3. Check audio balance and mixing
4. Test audio in different game scenarios

## Troubleshooting Common Issues

### Debug Features Not Working
- Ensure TestingManager is loaded as autoload
- Check that debug build is being used
- Verify input map includes debug shortcuts

### Performance Issues
- Check collision layer complexity
- Monitor texture memory usage
- Review script performance in profiler
- Use debug overlay to identify bottlenecks

### Input Simulation Problems
- Verify action names match input map
- Check that Input.parse_input_event() is working
- Ensure proper event timing in automated tests

## Test Data Analysis

### Session Data Structure
```json
{
  "session_id": "test_session_2024-01-01_10-30-00",
  "start_time": "2024-01-01T10:30:00",
  "events": [
    {
      "timestamp": "2024-01-01T10:30:01",
      "type": "user_action",
      "data": {
        "action": "move_right",
        "context": {}
      }
    }
  ],
  "performance_metrics": {
    "fps": [
      {"timestamp": "2024-01-01T10:30:01", "value": 60.0}
    ]
  },
  "user_actions": [],
  "debug_info": {}
}
```

### Key Metrics to Review
- Average FPS during gameplay
- Input response times
- Memory usage patterns
- Error frequency and types
- User action sequences

## Integration with External Tools

### VS Code Debugging
- Use launch.json configuration for Godot debugging
- Set breakpoints in wedding game scripts
- Monitor variable states during testing

### Git Integration
- Commit test results with code changes
- Use test data for regression testing
- Track performance improvements over time

## Best Practices

1. **Consistent Testing Environment**
   - Use same debug settings across team
   - Document any custom testing configurations
   - Maintain test data naming conventions

2. **Regular Test Sessions**
   - Run automated tests before major commits
   - Conduct manual testing for new features
   - Review performance metrics weekly

3. **Documentation**
   - Log significant findings in test sessions
   - Document bugs with reproduction steps
   - Maintain testing checklist for releases

4. **Team Coordination**
   - Share test session data with team
   - Coordinate testing schedules
   - Review testing results in team meetings

## Future Enhancements

- Integration with CI/CD pipeline
- Automated regression testing
- Performance benchmarking
- User behavior analytics
- Remote testing capabilities

---

*This testing workflow ensures comprehensive coverage of the wedding game's functionality while maintaining high quality and performance standards.*
