# MCP Server Setup for Mark & Jenny's Wedding Adventure

This document explains how the MCP (Model Context Protocol) servers are set up for this project.

## Installed MCP Servers

1. **Context7** - Documentation access
   - Repository: https://github.com/upstash/context7
   - Configuration: `.context7.json`

2. **Claude Task Master** - Task management
   - Repository: https://github.com/eyaltoledano/claude-task-master
   - Configuration: `.taskmaster.json`
   - Tasks Directory: `.taskmaster/tasks/`

3. **Sequential Thinking** - Problem solving
   - Repository: https://github.com/modelcontextprotocol/servers/tree/HEAD/src/sequentialthinking
   - Configuration: `.sequential_thinking.json`

4. **Godot MCP** - Implementation & error handling
   - Repository: https://github.com/coding-solo/godot-mcp
   - Configuration: `.godot_mcp.json`
   - Logs Directory: `logs/`

## Setup Instructions

### 1. Install MCP Servers

Follow the installation instructions for each MCP server from their respective repositories.

### 2. Configure MCP Servers

The configuration files for each MCP server are already set up in the project root:
- `.context7.json`
- `.taskmaster.json`
- `.sequential_thinking.json`
- `.godot_mcp.json`

### 3. Start MCP Servers

Start each MCP server according to its documentation:

```bash
# Example commands (refer to each server's documentation for actual commands)
context7 start --config .context7.json
taskmaster start --config .taskmaster.json
sequential-thinking start --config .sequential_thinking.json
godot-mcp start --config .godot_mcp.json
```

### 4. Connect Claude Code to MCP Servers

Ensure Claude Code is configured to connect to the running MCP servers.

## Directory Structure

```
.
├── .context7.json              # Context7 configuration
├── .taskmaster.json            # TaskMaster configuration
├── .sequential_thinking.json   # Sequential Thinking configuration
├── .godot_mcp.json             # Godot MCP configuration
├── .taskmaster/                # TaskMaster files
│   ├── tasks/                  # Task definitions
│   ├── templates/              # Task templates
│   ├── state.json              # Current state
│   └── config.json             # TaskMaster config
└── logs/                       # Godot error logs
    └── screenshots/            # Godot screenshots
```

## Verification

To verify that the MCP servers are running correctly:

1. **Context7**: Try querying for Godot documentation
2. **TaskMaster**: List the current tasks
3. **Sequential Thinking**: Try breaking down a simple problem
4. **Godot MCP**: Try running a simple Godot command

## Troubleshooting

If you encounter issues with any MCP server:

1. Check that the configuration file is correctly formatted
2. Verify that the server is running
3. Check the server logs for error messages
4. Restart the server if necessary
5. Ensure Claude Code has the correct permissions to access the server