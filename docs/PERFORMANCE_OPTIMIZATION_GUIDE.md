# Wedding Game Performance Optimization Guide

This document outlines the comprehensive performance optimization systems implemented in the wedding game project.

## Overview

The performance optimization system consists of several interconnected components designed to ensure smooth gameplay across target platforms:

- **PerformanceMonitor**: Real-time performance tracking and alerting
- **ObjectPool**: Memory-efficient object reuse system
- **SpriteOptimizer**: LOD and texture optimization for visual assets
- **MemoryManager**: Advanced memory management and leak detection

## Performance Monitoring

### PerformanceMonitor Features

The `PerformanceMonitor` autoload provides comprehensive real-time performance tracking:

```gdscript
# Access performance metrics
var fps = PerformanceMonitor.current_fps
var memory_usage = PerformanceMonitor.current_memory
var frame_time = PerformanceMonitor.current_frame_time

# Get detailed performance summary
var summary = PerformanceMonitor.get_performance_summary()
```

### Key Metrics Tracked

- **Frame Rate**: Current and average FPS with history
- **Memory Usage**: Current, peak, and baseline memory tracking
- **Frame Time**: CPU rendering time in milliseconds
- **Draw Calls**: Number of rendering operations per frame
- **GPU Memory**: Video memory consumption

### Performance Alerts

Automatic warnings when thresholds are exceeded:
- FPS drops below 30
- Memory usage exceeds 512MB
- Draw calls exceed 1000 per frame
- Memory leaks detected (>100MB growth)

### Profiling Functions

```gdscript
# Profile a specific function
var profile_data = PerformanceMonitor.start_profiling("my_function")
my_expensive_function()
var results = PerformanceMonitor.end_profiling(profile_data)

# Profile a callable directly
var results = PerformanceMonitor.profile_function(my_callable, "Function Name")
```

## Object Pooling System

### ObjectPool Implementation

The object pooling system reduces garbage collection overhead by reusing objects:

```gdscript
# Create a pool
ObjectPool.create_pool("bullets", bullet_scene, 50, ObjectPool.PoolType.PROJECTILE)

# Get object from pool
var bullet = ObjectPool.get_object("bullets")
if bullet:
    bullet.setup(position, direction)

# Return object to pool (usually automatic)
ObjectPool.return_object("bullets", bullet)
```

### Pre-configured Pools

Default pools are automatically created for common objects:
- **Particles**: 50 particle effects
- **Audio Players**: 20 pooled audio players
- **UI Notifications**: 10 notification widgets

### Pool Types and Optimization

Different pool types provide specialized behavior:
- `NODE`: General node objects
- `PARTICLE`: Particle effects with emission control
- `PROJECTILE`: Bullets, arrows, throwable objects
- `UI_ELEMENT`: Interface components
- `AUDIO_PLAYER`: Sound effect players
- `EFFECT`: Visual effects

### Performance Benefits

- **Reduced GC Pressure**: Eliminates constant object creation/destruction
- **Predictable Performance**: No allocation spikes during gameplay
- **Memory Efficiency**: Pre-allocated objects reduce memory fragmentation

## Sprite Optimization

### SpriteOptimizer Features

The sprite optimization system provides automatic visual optimizations:

```gdscript
# Register sprite for optimization
SpriteOptimizer.register_sprite(my_sprite, true)

# Batch optimize entire scenes
var report = SpriteOptimizer.optimize_scene_sprites(scene_root)
```

### Level of Detail (LOD) System

Automatic quality reduction based on distance:
- **HIGH**: Full resolution for nearby objects
- **MEDIUM**: 50% resolution for medium distance
- **LOW**: 25% resolution for far objects

### Visibility Culling

Objects outside the viewport are automatically hidden to reduce rendering load.

### Texture Optimization

- **Compression**: Automatic texture compression for GPU memory savings
- **Streaming**: Load textures on-demand to reduce memory usage
- **Caching**: Intelligent caching of frequently used textures

## Memory Management

### MemoryManager Features

Advanced memory tracking and cleanup:

```gdscript
# Track object lifecycle
var weak_ref = MemoryManager.track_object(my_object, "MyObjectType")

# Force garbage collection
var cleanup_results = MemoryManager.force_garbage_collection()

# Get memory analysis
var leak_report = MemoryManager.get_leak_report()
```

### Leak Detection

Automatic detection of memory leaks through:
- Object creation/destruction tracking
- Memory usage pattern analysis
- Weak reference cleanup monitoring

### Automatic Cleanup

Configurable automatic cleanup:
- Periodic garbage collection (default: every 30 seconds)
- Memory threshold warnings (default: 256MB)
- Dead object reference cleanup

## Audio System Optimization

### Pooled Audio Players

Optimized audio playback using object pooling:

```gdscript
# Use pooled audio (preferred for frequent sounds)
AudioManager.play_sfx_pooled("menu_select", 0.0, 1.0)

# Traditional audio (for one-time sounds)
AudioManager.play_sfx("explosion", -5.0, 0.8)
```

### Benefits

- **Reduced Audio Latency**: Pre-allocated players eliminate creation delays
- **Memory Efficiency**: Reused audio players prevent memory fragmentation
- **Automatic Cleanup**: Audio players return to pool when finished

## Integration and Usage

### Scene Setup

Optimize scenes automatically on load:

```gdscript
func _ready() -> void:
    # Optimize all sprites in the scene
    var optimization_report = SpriteOptimizer.optimize_scene_sprites(self)
    print("Optimized %d sprites" % optimization_report.sprites_optimized)
    
    # Register important objects for memory tracking
    MemoryManager.track_object(self, "LevelScene")
```

### Performance Testing

Use the comprehensive testing framework:

```gdscript
# Run performance tests
var test_runner = TestRunner.new()
test_runner.run_tests_matching("performance")
```

### Configuration

All systems can be configured for different target platforms:

```gdscript
# High-end devices
PerformanceMonitor.configure_monitoring(true, true, 0.5)
SpriteOptimizer.configure_optimization(true, true, true, 300.0)

# Low-end devices
PerformanceMonitor.configure_monitoring(true, false, 2.0)
SpriteOptimizer.configure_optimization(true, true, false, 800.0)
```

## Best Practices

### Object Lifecycle

1. **Use Object Pools**: For frequently created/destroyed objects
2. **Track Important Objects**: Use MemoryManager for critical resources
3. **Clean Up References**: Ensure proper signal disconnections
4. **Avoid Circular References**: Use weak references where appropriate

### Rendering Optimization

1. **Register Sprites**: Let SpriteOptimizer handle LOD and culling
2. **Minimize Draw Calls**: Batch similar objects when possible
3. **Use Appropriate Textures**: Compress textures for GPU memory savings
4. **Monitor Performance**: Keep an eye on FPS and memory usage

### Audio Optimization

1. **Use Pooled Audio**: For UI sounds and frequent effects
2. **Limit Concurrent Sounds**: Avoid audio spam
3. **Choose Appropriate Formats**: Use compressed formats for music
4. **Clean Up Streams**: Don't hold references to large audio files

### Memory Management

1. **Monitor Memory Growth**: Watch for unexpected increases
2. **Force Cleanup**: Trigger GC before memory-intensive operations
3. **Use Weak References**: For non-essential object references
4. **Profile Regular Operations**: Identify memory hotspots

## Performance Targets

### Frame Rate
- **Target**: 60 FPS on desktop, 30 FPS on mobile
- **Minimum**: 30 FPS consistently
- **Warning Threshold**: 30 FPS

### Memory Usage
- **Target**: Under 256MB for mobile devices
- **Maximum**: 512MB before warnings
- **Leak Threshold**: 100MB growth without cleanup

### Loading Times
- **Scene Transitions**: Under 2 seconds
- **Asset Loading**: Under 1 second for individual assets
- **Cold Start**: Under 5 seconds to main menu

## Troubleshooting

### Common Issues

1. **High Memory Usage**: Check for unreleased object references
2. **Low FPS**: Review sprite optimization and draw call counts
3. **Audio Stuttering**: Ensure audio pool has sufficient capacity
4. **Memory Leaks**: Use MemoryManager leak detection tools

### Debugging Tools

1. **Performance Summary**: `PerformanceMonitor.get_performance_summary()`
2. **Object Pool Stats**: `ObjectPool.get_efficiency_report()`
3. **Memory Analysis**: `MemoryManager.get_leak_report()`
4. **Sprite Optimization**: `SpriteOptimizer.get_optimization_stats()`

### Performance Testing

Run the performance test suite regularly:

```bash
# Run all performance tests
godot --test --test-case="*performance*"

# Profile specific operations
godot --profiling --scene="res://scenes/TestScene.tscn"
```

## Platform-Specific Optimizations

### Desktop (High Performance)
- Enable all optimization features
- Higher LOD thresholds
- Larger object pools
- More frequent performance monitoring

### Mobile (Resource Constrained)
- Aggressive texture compression
- Lower LOD thresholds
- Smaller object pools
- Less frequent monitoring to save CPU

### Web (Memory Limited)
- Streaming texture loading
- Minimal memory caches
- Aggressive garbage collection
- Simplified particle effects

This optimization system ensures the wedding game maintains smooth performance across all target platforms while providing detailed insights into resource usage and potential bottlenecks.