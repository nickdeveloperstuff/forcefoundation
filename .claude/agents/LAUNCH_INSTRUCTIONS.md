# Orchestrator Agent Launch Instructions

This document explains how to launch the orchestrator agent that will implement the 10-phase Phoenix LiveView Widget System.

## Prerequisites

1. Ensure you have Claude Code installed and configured
2. Verify all agent files are in place:
   - `.claude/agents/orchestrator.yaml`
   - `.claude/agents/phase-01.yaml` through `.claude/agents/phase-10.yaml`
3. The implementation guide exists at:
   `/Users/nicholasprice/Documents/DEVELOPMENT/SCRATCH/beginagain/forcefoundation/documents/zInstructiondocs/Widgets/mainimplementationinstructions/PHOENIX_LIVEVIEW_WIDGET_IMPLEMENTATION_GUIDE.md`

## How to Launch the Orchestrator

### Method 1: Direct Request (Recommended)
Simply tell Claude:
```
Use the orchestrator agent to implement the widget system
```

Or more specifically:
```
Run the orchestrator subagent to execute all 10 phases of the widget implementation
```

### Method 2: Using /agents Command
1. Type `/agents` to see all available agents
2. You should see "orchestrator" in the list
3. Request it by saying: "Use the orchestrator agent"

### Method 3: Using Task Tool with Spawn
If you want to launch it programmatically:
```
Please spawn the orchestrator agent with --dangerously-skip-approval flag
```

## What Happens When Launched

1. **Orchestrator Starts**: Reads the implementation guide and creates a master todo list
2. **Phase Execution**: For each phase (1-10):
   - Spawns the appropriate phase agent
   - Phase agent creates its own detailed todo list
   - Phase agent implements all tasks
   - Phase agent updates checkboxes in the guide
   - Phase agent commits changes
   - Phase agent reports completion
3. **Validation**: Orchestrator validates each phase completed successfully
4. **Completion**: Final summary report of all phases

## Monitoring Progress

- Each phase agent will create detailed todo lists
- Progress is tracked via checkbox updates in the implementation guide
- Git commits mark completion of major sections
- Look for "Phase X Complete:" messages

## Troubleshooting

### If a Phase Fails
- The orchestrator will stop and report which phase failed
- Check the error message for details
- You can manually run individual phases: "Use the phase-03 agent"

### To Run in Test Mode
If you want to test without making changes:
1. Create a test branch first
2. Then launch the orchestrator
3. Review changes before merging

### Manual Phase Execution
To run a specific phase manually:
```
Use the phase-01 agent to implement Phase 1
```

## Important Notes

- The entire process runs autonomously with `--dangerously-skip-approval`
- Each phase builds on the previous one - don't skip phases
- All changes are committed to git automatically
- The implementation guide is updated in real-time
- Total execution time: Approximately 2-4 hours for all 10 phases

## Quick Start Command

To start the full implementation immediately:
```
Please use the orchestrator agent to implement the entire widget system following the 10-phase plan
```