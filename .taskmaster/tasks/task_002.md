# Task: Implement Acids Joe Boss AI with Beehave

**Priority**: High  
**Status**: Not Started  
**Category**: AI  
**Estimated Time**: 5 hours  

## Description
Create the AI behavior for the Acids Joe boss using the Beehave plugin. Implement both phases of the boss fight with different attack patterns and behaviors.

## Acceptance Criteria
- [ ] Create a behavior tree for Acids Joe using Beehave
- [ ] Implement Phase 1 behaviors (normal attacks, tooth pain vulnerability)
- [ ] Implement Phase 2 behaviors (psychedelic attacks, special abilities)
- [ ] Create transition between phases with visual effects
- [ ] Ensure boss responds appropriately to player position and actions
- [ ] Balance difficulty for an engaging but fair boss fight

## Implementation Notes
Use the Beehave plugin to create a sophisticated behavior tree for the boss. The boss should have two distinct phases:

**Phase 1:**
- Basic melee attacks
- Periodic tooth pain (vulnerability)
- Chase player when out of range

**Phase 2:**
- Psychedelic projectile attacks
- Area-of-effect attacks
- Reality-warping abilities
- More aggressive movement

## Related Files
- scenes/entities/bosses/acids_joe.gd
- examples/acids_joe_behavior.gd
- scenes/levels/BossFightScene.gd
- docs/design/boss_fight_design.md

## Dependencies
- Beehave plugin (already installed)
- Boss character sprites and animations
- Attack effect sprites

## MCP Server Usage
- **Context7**: Use for Beehave plugin documentation and behavior tree patterns
- **Sequential Thinking**: Break down complex boss behavior logic
- **Godot MCP**: Test boss AI behavior in Godot

## Notes
This is a complex task that will require careful balancing and testing. The boss fight should be the most challenging part of the game but still feel fair to the player.