# MCP Server Usage Guide

This document provides detailed instructions on how to use the MCP servers with Claude Code for developing Mark & Jenny's Wedding Adventure.

## Context7

### Purpose
Access Godot documentation, examples, and best practices.

### How to Use
1. **Request Godot Documentation**:
   ```
   Context7: Please provide documentation on [Godot feature]
   ```

2. **Search for Examples**:
   ```
   Context7: Find examples of [specific implementation] in Godot
   ```

3. **Get Plugin Documentation**:
   ```
   Context7: Show me how to use [plugin name] in Godot
   ```

### Example Queries
- "Context7: How do I implement character movement in Godot?"
- "Context7: Show me examples of dialogue systems in Godot"
- "Context7: What's the best way to handle animations in Godot?"

## TaskMaster

### Purpose
Track development tasks and maintain project progress.

### How to Use
1. **Create New Task**:
   ```
   TaskMaster: Create a new task for [feature/bug]
   ```

2. **Update Task Status**:
   ```
   TaskMaster: Update task [ID] status to [new status]
   ```

3. **List Tasks**:
   ```
   TaskMaster: List all [status] tasks
   ```

4. **Get Task Details**:
   ```
   TaskMaster: Show details for task [ID]
   ```

### Example Commands
- "TaskMaster: Create a new task for implementing player jump mechanics"
- "TaskMaster: Update task 003 status to In Progress"
- "TaskMaster: List all Not Started tasks in Core Gameplay category"
- "TaskMaster: Show details for task 002"

## Sequential Thinking

### Purpose
Break down complex problems into manageable steps.

### How to Use
1. **Analyze Complex Problem**:
   ```
   Sequential Thinking: Break down how to implement [complex feature]
   ```

2. **Debug Issue**:
   ```
   Sequential Thinking: Analyze why [problem] is occurring
   ```

3. **Plan Implementation**:
   ```
   Sequential Thinking: Plan steps to create [feature]
   ```

### Example Queries
- "Sequential Thinking: Break down how to implement the boss phase transition"
- "Sequential Thinking: Analyze why the camera shake isn't working properly"
- "Sequential Thinking: Plan steps to create the dialogue choice system"

## Godot MCP

### Purpose
Implement code and process error logs from Godot.

### How to Use
1. **Implement Feature**:
   ```
   Godot MCP: Implement [feature] in [file]
   ```

2. **Process Error Log**:
   ```
   Godot MCP: Analyze error log: [paste error]
   ```

3. **Test Implementation**:
   ```
   Godot MCP: Test [feature] implementation
   ```

### Example Commands
- "Godot MCP: Implement player movement in scenes/entities/player.gd"
- "Godot MCP: Analyze error log: ERROR: Method not found..."
- "Godot MCP: Test dialogue system implementation"

## Combined Workflow Examples

### Example 1: Implementing a New Feature
1. **Start with TaskMaster**:
   ```
   TaskMaster: Show details for task 001 (Set up Dialogue Manager)
   ```

2. **Research with Context7**:
   ```
   Context7: How to set up Dialogue Manager plugin in Godot 4
   ```

3. **Plan with Sequential Thinking**:
   ```
   Sequential Thinking: Break down steps to implement dialogue UI
   ```

4. **Implement with Godot MCP**:
   ```
   Godot MCP: Create dialogue balloon UI based on the plan
   ```

5. **Update Progress**:
   ```
   TaskMaster: Update task 001 status to In Progress
   ```

### Example 2: Debugging an Issue
1. **Identify the Problem**:
   ```
   Godot MCP: Here's the error I'm getting: [paste error]
   ```

2. **Research the Issue**:
   ```
   Context7: What causes [specific error] in Godot?
   ```

3. **Analyze with Sequential Thinking**:
   ```
   Sequential Thinking: Analyze possible causes for this error
   ```

4. **Fix the Issue**:
   ```
   Godot MCP: Implement the fix in [file]
   ```

5. **Verify the Fix**:
   ```
   Godot MCP: Test if the issue is resolved
   ```

## Best Practices

1. **Be Specific**: Clearly state which MCP server you're addressing
2. **Provide Context**: Include relevant file paths and code snippets
3. **One Task at a Time**: Focus on completing one task before moving to the next
4. **Document Everything**: Keep task updates and implementation notes in TaskMaster
5. **Test Thoroughly**: Use Godot MCP to verify implementations work as expected

## Troubleshooting

If you encounter issues with the MCP servers:

1. **Check Configuration**: Verify the MCP server configuration files
2. **Restart Server**: Sometimes restarting the MCP server can resolve issues
3. **Clear Cache**: Clear any cached data that might be causing problems
4. **Update Dependencies**: Ensure all dependencies are up to date
5. **Check Logs**: Review server logs for any error messages