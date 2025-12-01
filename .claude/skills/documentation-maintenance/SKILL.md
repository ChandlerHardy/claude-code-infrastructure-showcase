# Documentation Maintenance Skill

**Purpose:** Automated assistance for keeping development documentation current and comprehensive throughout the development lifecycle.

## When to Use This Skill

- Completing feature implementation and need to document changes
- Finishing development sessions and want to capture progress
- Updating API documentation after backend changes
- Documenting new components or architecture decisions
- Creating comprehensive project documentation
- Maintaining development logs and progress tracking

## Key Capabilities

### Automated Documentation Reminders
- **Change Detection**: Monitors file modifications to suggest documentation updates
- **Progress Tracking**: Tracks development progress across sessions
- **Context Awareness**: Recognizes when significant changes warrant documentation
- **Smart Suggestions**: Provides targeted suggestions for documentation updates

### Documentation Types Handled
- **Development Documentation**: Session notes, implementation decisions, progress tracking
- **API Documentation**: Endpoint changes, new features, deprecation notices
- **Architecture Documentation**: Design decisions, system changes, pattern updates
- **User Documentation**: Feature updates, usage examples, troubleshooting guides

## Integration with Development Workflow

### Post-Tool-Use Hook Integration
Works seamlessly with the `post-tool-use-tracker.sh` hook to:
1. **Track file changes** automatically as you work
2. **Detect documentation-worthy changes** based on file patterns and content
3. **Provide timely reminders** when documentation should be updated
4. **Support auto-updates** for hands-off documentation maintenance

### Development Commands Integration
Integrates with common documentation commands:
- `/dev-docs` - Create new development documentation entries
- `/dev-docs-update` - Update existing documentation with latest changes
- Automatic suggestions for running these commands when appropriate

## Documentation Best Practices Provided

### What to Document
- **Implementation Decisions**: Why specific approaches were chosen
- **API Changes**: New endpoints, modified responses, breaking changes
- **Architecture Updates**: System design changes, new patterns
- **Bug Fixes**: Issues encountered and solutions implemented
- **Performance Optimizations**: Changes made and their impact

### Documentation Structure
- **Executive Summary**: High-level overview of changes
- **Technical Details**: Specific implementation notes
- **Impact Analysis**: What changes affect other parts of the system
- **Next Steps**: Follow-up tasks or considerations

### Automated Reminders
The skill provides intelligent reminders when:
- Multiple files are modified in a session
- TODO/FIXME comments are present in code
- New features are implemented
- API endpoints are added or modified
- Configuration files are changed

## Configuration Options

### Auto-Update Mode
Create a `.claude/dev-docs-auto-update` file in any project to enable automatic documentation updates:
```bash
touch .claude/dev-docs-auto-update
```

### Customization
- **File Patterns**: Configure which file types trigger documentation reminders
- **Content Patterns**: Set up specific content that warrants documentation
- **Reminder Frequency**: Adjust how often reminders are provided
- **Documentation Templates**: Customize templates for different documentation types

## Resources

### Documentation Templates
- `development-session.md` - Template for documenting development sessions
- `api-change-log.md` - Template for API change documentation
- `architecture-decisions.md` - Template for design decision records
- `feature-completion.md` - Template for completed feature documentation

### Integration Guides
- `hook-integration.md` - Setting up automatic documentation tracking
- `command-customization.md` - Customizing documentation commands
- `workflow-automation.md` - Automating documentation workflows

## Quick Start

This skill automatically provides documentation suggestions when you:
1. **Complete features**: Detects when implementation is finished
2. **Make significant changes**: Identifies documentation-worthy modifications
3. **End development sessions**: Suggests progress capture
4. **Update APIs**: Reminds to document endpoint changes
5. **Modify architecture**: Prompts for design decision documentation

The skill works proactively in the background, ensuring your documentation stays current without requiring manual intervention.

**Benefits:**
- Eliminates forgotten documentation updates
- Maintains comprehensive project history
- Improves team collaboration with current documentation
- Reduces onboarding time for new developers
- Preserves institutional knowledge and implementation decisions