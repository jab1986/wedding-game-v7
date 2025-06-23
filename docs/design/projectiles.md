# Projectiles Design Document

## Drumstick (Mark's Weapon)
### Properties
- Damage: 10
- Speed: 300.0
- Lifetime: 3.0 seconds
- Spin Speed: 720.0 degrees/second
- Pierce Count: 2 enemies
- Bounce Count: 1 bounce

### Behavior
- Fast-flying spinning projectile
- Can pierce through multiple enemies
- Can bounce off walls once
- Spins rapidly in flight

## Camera Bomb (Jenny's Weapon)
### Properties
- Direct Damage: 15
- Explosion Damage: 20
- Speed: 250.0
- Arc Strength: 200.0
- Explosion Radius: 80.0
- Lifetime: 4.0 seconds
- Fuse Time: 2.0 seconds

### Behavior
- Arc trajectory (follows a parabolic path)
- Explodes after fuse time or on impact
- Area damage to all enemies in explosion radius
- Flashes and beeps before explosion

## Visual Effects
- Drumstick: Spinning animation, trail particles
- Camera Bomb: Flashing light, smoke trail, explosion particles

## Sound Effects
- Drumstick: Whoosh sound, impact sound
- Camera Bomb: Beeping sound, explosion sound