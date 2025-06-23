# Mark & Jenny's Wedding Adventure - Project Plan

## Project Overview
Mark & Jenny's Wedding Adventure is a SNES-style adventure game where players navigate through chaos to reach their wedding ceremony. The game features multiple levels, character switching, combat, and a boss fight.

## Development Approach
This project will use Claude Code with multiple MCP servers to assist in development:

1. **Context7** - For accessing Godot documentation and examples
2. **TaskMaster** - For tracking development tasks and progress
3. **Sequential Thinking** - For breaking down complex problems
4. **Godot MCP** - For implementing and testing code in Godot

## Development Workflow

### 1. Planning Phase
- Define task in TaskMaster
- Break down complex problems using Sequential Thinking
- Research Godot features using Context7

### 2. Implementation Phase
- Claude Code provides implementation guidance
- Developer implements changes in Godot
- Godot MCP processes error logs and provides feedback

### 3. Testing Phase
- Test implemented features in Godot
- Report issues back to Claude Code
- Iterate on implementation as needed

## Project Structure

```
wedding-game-godot/
├── addons/                 # Third-party plugins
│   ├── dialogue_manager/   # Dialogue system
│   ├── beehave/            # AI behavior trees
│   └── phantom_camera/     # Dynamic camera control
├── assets/                 # Game assets
│   └── graphics/           # Visual assets
├── dialogues/              # Dialogue files
├── docs/                   # Documentation
│   └── design/             # Design documents
├── examples/               # Example implementations
├── logs/                   # Error logs and screenshots
├── scenes/                 # Godot scenes
│   ├── components/         # Reusable components
│   ├── entities/           # Characters and objects
│   ├── levels/             # Game levels
│   ├── test/               # Test scenes
│   └── ui/                 # User interface
├── scripts/                # GDScript files
│   ├── autoload/           # Global scripts
│   └── utils/              # Utility scripts
└── .taskmaster/            # Task management
    ├── tasks/              # Task definitions
    └── templates/          # Task templates
```

## Development Timeline

### Phase 1: Core Systems (Weeks 1-2)
- Set up project structure and plugins
- Implement player movement and controls
- Create dialogue system
- Implement basic combat

### Phase 2: Level Development (Weeks 3-5)
- Create Amsterdam Tutorial level
- Implement Glen's House level
- Design Glen Bingo mini-game
- Create Leo's Cafe scene

### Phase 3: Boss Fight & Finale (Weeks 6-8)
- Implement Wedding Venue combat gauntlet
- Create Acids Joe boss fight
- Design wedding ceremony scene
- Add final polish and bug fixes

## MCP Server Usage Guidelines

### Context7
- Use for Godot API documentation
- Research plugin usage and examples
- Find solutions to common Godot problems

### TaskMaster
- Track all development tasks
- Update task status as work progresses
- Add new tasks as needed
- Document dependencies between tasks

### Sequential Thinking
- Break down complex gameplay systems
- Analyze difficult bugs or issues
- Plan implementation approaches for complex features

### Godot MCP
- Implement code in Godot
- Process error logs
- Test gameplay features
- Capture screenshots for reference

## Communication Guidelines

When communicating with Claude Code:

1. **Be specific** about which MCP server to use
2. **Provide context** about the current task and goal
3. **Share error messages** from Godot when relevant
4. **Ask for step-by-step guidance** for complex tasks
5. **Reference existing code** when asking for modifications

## Next Steps

1. Complete initial setup of MCP servers
2. Begin with Task 001: Set up Dialogue Manager
3. Proceed through tasks in priority order
4. Update project plan as development progresses