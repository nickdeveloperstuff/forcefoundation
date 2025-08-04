# Phase 3 - Section 3.3: Nested Forms Implementation Notes

## Summary
Successfully implemented nested form widgets (NestedFormWidget, FieldsetWidget, RepeaterWidget) with full Phoenix LiveView integration and JavaScript hooks for sortable functionality.

## Widgets Created
1. **NestedFormWidget** - Handles has_many associations with dynamic add/remove
2. **FieldsetWidget** - Groups related fields with collapsible functionality
3. **RepeaterWidget** - Simple repeater for non-association lists (tags, emails, etc.)

## Key Implementation Details

### 1. Phoenix.HTML.Form.inputs_for Issue
- **Issue**: Initial attempt to use `Phoenix.HTML.Form.inputs_for` directly failed
- **Solution**: Used `<.inputs_for>` component syntax in template
- **Learning**: Phoenix LiveView 1.1.2 uses component-based approach for nested forms

### 2. phx-hook ID Requirement
- **Issue**: phx-hook requires an ID attribute to be set
- **Solution**: Added unique IDs to all elements with phx-hook attributes
- **Pattern**: `id={"#{@container_id}-items"}`

### 3. Pattern Matching in Case Statement
- **Issue**: Cannot use `assigns.field` directly in pattern match
- **Solution**: Extract to variable first: `field = assigns.field`

### 4. JavaScript Module Syntax
- **Issue**: Documentation examples had syntax errors
- **Solution**: Used string interpolation with escape: `"phone_\#{idx}"`

### 5. Phoenix.HTML.FormField Struct
- **Issue**: FormField struct requires both :field and :form keys
- **Solution**: Switched to plain HTML inputs for custom templates in repeater

### 6. JS Module Namespace
- **Issue**: `JS.toggle` undefined
- **Solution**: Use full namespace: `Phoenix.LiveView.JS.toggle`

## Testing Results
- Nested forms successfully add/remove line items
- Collapsible fieldsets expand/collapse correctly
- Repeater widgets add/remove items dynamically
- All styling applied correctly with DaisyUI
- Form validation shows error at form level (needs error handling in event handlers)

## JavaScript Hook Implementation
Created simple drag-and-drop sortable functionality:
- Basic drag/drop handlers
- Visual feedback during drag
- Sends reorder event to server
- Works but could be enhanced with library like Sortable.js

## Deviations from Plan
1. Used component syntax `<.inputs_for>` instead of function call
2. Simplified repeater template to use plain HTML inputs
3. Added CSS for all widget states and variants

## Time Taken
Approximately 40 minutes including:
- Widget creation
- JavaScript hooks
- CSS styling
- Compilation fixes
- Visual testing

## Recommendations
1. Add proper error handling in LiveView event handlers
2. Consider using Sortable.js library for better drag-drop UX
3. Add loading states during add/remove operations
4. Implement undo/redo for form changes