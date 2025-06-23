# Task: Set up Dialogue Manager for NPC Conversations

**Priority**: High  
**Status**: Not Started  
**Category**: Dialogue  
**Estimated Time**: 3 hours  

## Description
Configure and implement the Dialogue Manager plugin to handle NPC conversations throughout the game. Create a test dialogue for the wedding ceremony scene.

## Acceptance Criteria
- [ ] Dialogue Manager plugin is properly configured
- [ ] Create a test dialogue file for the wedding ceremony
- [ ] Implement a simple dialogue balloon UI
- [ ] Test dialogue triggering from NPC interaction
- [ ] Ensure dialogue advances correctly with player input

## Implementation Notes
Use the Dialogue Manager plugin that's already been added to the project. The plugin provides a balloon scene that can be customized for our game's visual style.

The dialogue system should support:
- Character names and portraits
- Basic text formatting
- Dialogue choices (for Glen Bingo quiz)
- Triggering game events from dialogue

## Related Files
- addons/dialogue_manager/
- dialogues/wedding_ceremony.dialogue
- scenes/entities/npc.gd
- scenes/levels/CeremonyScene.gd

## Dependencies
- Dialogue Manager plugin (already installed)

## MCP Server Usage
- **Context7**: Use for Dialogue Manager plugin documentation
- **Sequential Thinking**: Break down dialogue UI customization if needed
- **Godot MCP**: Test dialogue triggering in Godot

## Notes
This is a foundational task that will enable character conversations throughout the game. The wedding ceremony dialogue is a good test case as it involves multiple characters speaking in sequence.