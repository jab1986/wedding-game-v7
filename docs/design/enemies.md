# Enemies Design Document

## Alien Enemy
### Stats
- Health: 30
- Move Speed: 80.0
- Chase Speed: 120.0
- Attack Damage: 8
- Detection Range: 150.0
- Attack Range: 50.0
- Music Play Chance: 2% per frame

### Behavior
- Wanders randomly when no player is detected
- Chases player when within detection range
- Attacks player when within attack range
- Occasionally plays bad Ghostbusters covers
- Spawns in Glen's house and the wedding venue

### Visual Design
- Small (28x28 pixels)
- Green/gray alien appearance
- Simple animations for idle, walk, attack
- Death particle effect

## Special Abilities
- **Bad Music**: Occasionally plays music that temporarily slows the player
- **Group Behavior**: Tends to attack in groups
- **Teleport**: Some variants can teleport short distances