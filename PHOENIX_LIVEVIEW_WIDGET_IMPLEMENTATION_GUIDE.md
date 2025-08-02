# Phoenix LiveView Widget System Implementation Guide

This guide provides a step-by-step implementation plan for the Phoenix LiveView Widget System. Follow each phase and section in order, testing thoroughly after each step to ensure system stability.

## Overview

This implementation creates a comprehensive widget system where **everything is a widget**. The system features two modes:
- **Dumb Mode**: Static data for rapid prototyping
- **Connected Mode**: Full Ash framework integration

Key principles:
- Wrap Phoenix LiveView form components for forms
- Use DaisyUI components for UI elements
- Every widget supports grid system and debug mode
- No raw HTML/CSS in LiveViews - only widgets

## Phase 1: Foundation & Base Architecture

### Section 1.1: Create Widget Base Module
- [ ] Create directory structure: `lib/forcefoundation_web/widgets/`
- [ ] Create `lib/forcefoundation_web/widgets/base.ex` with the base behavior
- [ ] Create `lib/forcefoundation_web/widgets/helpers.ex` with spacing/grid helpers
- [ ] **TEST**: Run `mix compile` to ensure no syntax errors
- [ ] **VISUAL TEST**: Start server with `mix phx.server` and take screenshot of homepage to ensure nothing is broken

### Section 1.2: Widget Registry & Import System
- [ ] Create `lib/forcefoundation_web/widgets.ex` as the widget registry
- [ ] Update `lib/forcefoundation_web.ex` to import widgets in the `html` function
- [ ] **TEST**: Run `mix compile` again
- [ ] **VISUAL TEST**: Reload homepage and screenshot to verify no regression

### Section 1.3: Connection Resolution System
- [ ] Create `lib/forcefoundation_web/widgets/connection_resolver.ex`
- [ ] Implement all connection types:
  - `:static` (default)
  - `{:interface, function}`
  - `{:resource, resource, opts}`
  - `{:stream, name}`
  - `{:form, action}`
  - `{:action, action, record}`
  - `{:subscribe, topic}`
- [ ] **TEST**: Create a simple test module to verify connection resolver works
- [ ] **TEST**: Run `mix test` to ensure no breaking changes

## Phase 2: Essential Layout Widgets (Wrapping DaisyUI Components)

### Section 2.1: Grid and Layout Widgets
- [ ] Create `grid_widget.ex` - 12-column grid using Tailwind grid classes
- [ ] Create `flex_widget.ex` - Flexbox container
- [ ] Create `section_widget.ex` - Content sections with padding
- [ ] **TEST**: Create a test page at `/test-widgets` route to display these widgets
- [ ] **VISUAL TEST**: Navigate to test page, screenshot grid layout with different span values

### Section 2.2: Card Widget (DaisyUI Integration)
- [ ] Create `card_widget.ex` wrapping DaisyUI's card component
- [ ] Implement slots: `:header`, `:body`, `:footer`, `:image`
- [ ] Add grid span support
- [ ] **TEST**: Add card examples to test page
- [ ] **VISUAL TEST**: Screenshot cards in different configurations

### Section 2.3: Basic Display Widgets
- [ ] Create `text_widget.ex` with size/color/weight options
- [ ] Create `heading_widget.ex` with levels 1-6
- [ ] Create `badge_widget.ex` wrapping DaisyUI badge
- [ ] **TEST**: Add all display widgets to test page
- [ ] **VISUAL TEST**: Screenshot text hierarchy and badges

## Phase 3: Form Widgets (Wrapping Phoenix LiveView Components)

### Section 3.1: Form Container Widget
- [ ] Create `form_widget.ex` that wraps Phoenix's `<.form>` component
- [ ] Implement AshPhoenix.Form support
- [ ] Add `on_submit` and `on_change` handlers
- [ ] **TEST**: Create a simple form on test page
- [ ] **VISUAL TEST**: Screenshot form structure

### Section 3.2: Form Input Widgets
- [ ] Create `input_widget.ex` wrapping Phoenix's `<.input>` with DaisyUI styling
- [ ] Create `select_widget.ex` for dropdowns
- [ ] Create `checkbox_widget.ex` and `radio_widget.ex`
- [ ] Create `textarea_widget.ex` for multi-line input
- [ ] **TEST**: Add all input types to test form
- [ ] **VISUAL TEST**: Screenshot each input type, verify DaisyUI styling applied

### Section 3.3: Nested Form Support
- [ ] Create `nested_form_widget.ex` wrapping `<.inputs_for>`
- [ ] Create `fieldset_widget.ex` for grouping
- [ ] Create `repeater_widget.ex` for dynamic lists
- [ ] Implement special parameters support:
  - `_add_*` for adding items
  - `_drop_*` for removing items
  - `_sort_*` for reordering
  - `_union_type` for polymorphic associations
- [ ] **TEST**: Create a form with nested addresses
- [ ] **FUNCTIONAL TEST**: Test adding/removing nested items
- [ ] **VISUAL TEST**: Screenshot nested form behavior

## Phase 4: Action Widgets

### Section 4.1: Button Widget
- [ ] Create `button_widget.ex` wrapping DaisyUI button classes
- [ ] Support all DaisyUI button variants:
  - Colors: primary, secondary, accent, neutral, info, success, warning, error
  - Variants: solid, outline, ghost, link
  - Sizes: xs, sm, md, lg
- [ ] Implement `on_click`, `type`, loading states
- [ ] Add icon support using Heroicons
- [ ] **TEST**: Create button showcase on test page
- [ ] **VISUAL TEST**: Screenshot all button variants

### Section 4.2: Action Integration
- [ ] Implement `data_source={:action, action, record}` support in buttons
- [ ] Add confirmation dialog support
- [ ] Add loading state animations
- [ ] **TEST**: Create buttons that trigger Ash actions
- [ ] **FUNCTIONAL TEST**: Test action execution and loading states

### Section 4.3: Additional Action Widgets
- [ ] Create `dropdown_widget.ex` for action menus
- [ ] Create `toolbar_widget.ex` for action bars
- [ ] Create `button_group_widget.ex` for grouped actions
- [ ] **TEST**: Add examples to test page
- [ ] **VISUAL TEST**: Screenshot action components

## Phase 5: Data Display Widgets

### Section 5.1: Table Widget
- [ ] Create `table_widget.ex` using DaisyUI table classes
- [ ] Implement column configuration:
  - field, label, sortable, filterable
  - format options (currency, date, etc.)
  - custom render functions
- [ ] Add both dumb mode (static rows) and connected mode
- [ ] **TEST**: Create table with static data
- [ ] **VISUAL TEST**: Screenshot table with sample data

### Section 5.2: Phoenix Streams Integration
- [ ] Add stream support to table widget
- [ ] Implement `data_source={:stream, name}` connection
- [ ] Add row actions and bulk actions
- [ ] Implement efficient updates with `stream_insert`
- [ ] **TEST**: Create live updating table
- [ ] **FUNCTIONAL TEST**: Test adding/removing rows via streams

### Section 5.3: List Widget
- [ ] Create `list_widget.ex` with vertical/horizontal orientation
- [ ] Create `list_item_widget.ex` with title/subtitle/avatar/actions
- [ ] Add empty state support
- [ ] **TEST**: Add list examples to test page
- [ ] **VISUAL TEST**: Screenshot different list configurations

### Section 5.4: Advanced Data Widgets
- [ ] Create `kanban_widget.ex` for drag-and-drop boards
- [ ] Create `stat_widget.ex` for metric display
- [ ] **TEST**: Implement working examples
- [ ] **VISUAL TEST**: Screenshot advanced widgets

## Phase 6: Navigation & Feedback Widgets

### Section 6.1: Navigation Widgets
- [ ] Create `nav_widget.ex` using DaisyUI menu components
- [ ] Create `breadcrumb_widget.ex` using DaisyUI breadcrumbs
- [ ] Create `tab_widget.ex` using DaisyUI tabs
- [ ] Add active state tracking
- [ ] **TEST**: Add navigation examples
- [ ] **VISUAL TEST**: Screenshot navigation components

### Section 6.2: Feedback Widgets
- [ ] Create `alert_widget.ex` using DaisyUI alert
- [ ] Create `toast_widget.ex` for notifications
- [ ] Create `loading_widget.ex` with spinner/skeleton options
- [ ] Create `empty_state_widget.ex` for empty data
- [ ] Create `progress_widget.ex` for progress bars
- [ ] **TEST**: Trigger various feedback states
- [ ] **VISUAL TEST**: Screenshot all feedback states

## Phase 7: Ash Data Flow Integration

### Section 7.1: Code Interface Connections
- [ ] Implement `{:interface, function}` resolution in widgets
- [ ] Create example domain module with interface functions
- [ ] Update test page to use interface connections
- [ ] Handle domain context assignment in socket
- [ ] **TEST**: Verify widgets can call domain functions
- [ ] **FUNCTIONAL TEST**: Test data loading through interfaces

### Section 7.2: Form-to-Ash Integration
- [ ] Test AshPhoenix.Form creation in forms
- [ ] Implement validation flow:
  ```elixir
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, :form, form)}
  end
  ```
- [ ] Implement submission flow with `AshPhoenix.Form.submit`
- [ ] **TEST**: Create full CRUD form
- [ ] **FUNCTIONAL TEST**: Test create/update/delete operations

### Section 7.3: Real-time Updates
- [ ] Implement PubSub subscription support
- [ ] Add `data_source={:subscribe, topic}` to widgets
- [ ] Handle subscription in widget mount
- [ ] Test real-time updates in relevant widgets
- [ ] **TEST**: Create widget that updates via PubSub
- [ ] **FUNCTIONAL TEST**: Trigger updates and verify display

### Section 7.4: Resource Queries
- [ ] Implement `{:resource, resource, opts}` connections
- [ ] Support filter, sort, load options
- [ ] Add pagination support
- [ ] **TEST**: Create widgets using direct resource queries
- [ ] **FUNCTIONAL TEST**: Test filtering and sorting

## Phase 8: Modal & Overlay Widgets

### Section 8.1: Modal Widget
- [ ] Create `modal_widget.ex` using DaisyUI modal
- [ ] Add header/body/footer slots
- [ ] Implement close handlers and backdrop clicks
- [ ] Support different sizes
- [ ] **TEST**: Add modal examples
- [ ] **VISUAL TEST**: Screenshot open modals

### Section 8.2: Advanced Overlays
- [ ] Create `drawer_widget.ex` using DaisyUI drawer
- [ ] Create `dropdown_widget.ex` using DaisyUI dropdown
- [ ] Create `popover_widget.ex` for tooltips
- [ ] **TEST**: Test all overlay behaviors
- [ ] **VISUAL TEST**: Screenshot overlays in action

### Section 8.3: Form Modals
- [ ] Create `form_modal_widget.ex` combining modal and form
- [ ] Add submit/cancel button integration
- [ ] **TEST**: Create edit forms in modals
- [ ] **FUNCTIONAL TEST**: Test form submission in modals

## Phase 9: Debug Mode & Developer Experience

### Section 9.1: Debug Mode Implementation
- [ ] Implement debug overlay rendering in base widget
- [ ] Show data source information when `debug_mode={true}`
- [ ] Display widget name and key attributes
- [ ] Add visual border/background to debug widgets
- [ ] **TEST**: Enable debug mode on test page
- [ ] **VISUAL TEST**: Screenshot widgets with debug overlays

### Section 9.2: Error States
- [ ] Implement graceful error handling in connection resolver
- [ ] Add error display to widgets when connections fail
- [ ] Show helpful error messages
- [ ] **TEST**: Force connection errors
- [ ] **VISUAL TEST**: Screenshot error states

### Section 9.3: Developer Tools
- [ ] Create widget generator mix task
- [ ] Add widget documentation helpers
- [ ] Create widget playground page
- [ ] **TEST**: Use generator to create new widget
- [ ] **VERIFY**: Generated widget works correctly

## Phase 10: Final Integration & Testing

### Section 10.1: Complete Example Page
- [ ] Create a full dashboard using only widgets
- [ ] Include all widget types and connection modes
- [ ] No raw HTML should be present
- [ ] **TEST**: Verify all widgets work together
- [ ] **VISUAL TEST**: Screenshot complete dashboard

### Section 10.2: Two-Mode Demonstration
- [ ] Create page showing same UI in dumb mode
- [ ] Add toggle to switch to connected mode
- [ ] Verify identical visual output
- [ ] **TEST**: Verify mode switching works
- [ ] **FUNCTIONAL TEST**: Test that both modes display same UI

### Section 10.3: Performance Optimization
- [ ] Review widget rendering performance
- [ ] Optimize connection resolver caching
- [ ] Minimize assigns in widgets
- [ ] **TEST**: Profile widget rendering times
- [ ] **VERIFY**: No performance regressions

### Section 10.4: Documentation
- [ ] Document any deviations from the plan
- [ ] Note any widgets that needed special handling
- [ ] List any issues encountered
- [ ] Create widget reference documentation
- [ ] **FINAL TEST**: Run full application test suite

## Testing Requirements

After EACH section:
1. Run `mix compile` - should have no errors
2. Run `mix phx.server` and check for runtime errors
3. Use Puppeteer MCP to navigate to test pages and take screenshots
4. Compare screenshots to ensure no visual regressions
5. Document any unexpected behavior in comments

### Puppeteer Testing Commands

```javascript
// Navigate to test page
await page.goto('http://localhost:4000/test-widgets')

// Take screenshot
await page.screenshot({ name: 'phase-X-section-Y' })

// Test interactions
await page.click('[data-widget="button_widget"]')
await page.fill('[data-widget="input_widget"]', 'test value')
```

## Important Implementation Notes

### Widget Naming Convention
- All widgets must end with `_widget`
- Use descriptive names (e.g., `form_input_widget`, not just `input_widget`)
- Group related widgets in subdirectories if needed

### Required Widget Attributes
Every widget must support:
- `id` - optional string for identification
- `class` - additional CSS classes
- `data_source` - connection configuration (default: `:static`)
- `debug_mode` - boolean to show debug overlay
- `span` - grid column span (1-12)
- `padding` - spacing using 4px system (1-8)

### Phoenix Component Integration
Form widgets MUST wrap Phoenix components:
```elixir
# Good - wrapping Phoenix component
<.form for={@for} phx-submit={@on_submit}>
  <%= render_slot(@inner_block) %>
</.form>

# Bad - reimplementing form logic
<form action="#" method="post">
  ...
</form>
```

### DaisyUI Component Usage
UI widgets should use DaisyUI classes:
```elixir
# Good - using DaisyUI classes
<div class={["card", @class]}>
  ...
</div>

# Bad - custom styling
<div class="rounded-lg shadow-md p-4">
  ...
</div>
```

## Success Criteria

The implementation is complete when:
- [ ] All widgets work in both dumb and connected modes
- [ ] Forms integrate properly with AshPhoenix.Form
- [ ] All Ash connection patterns are working
- [ ] Widgets properly wrap Phoenix/DaisyUI components as specified
- [ ] Debug mode shows data sources
- [ ] No HTML/CSS is written directly in LiveViews - only widgets are used
- [ ] Full test coverage exists
- [ ] Documentation is complete

## Troubleshooting Guide

### Common Issues

1. **Widget not rendering**
   - Check widget is imported in registry
   - Verify attributes are properly defined
   - Check for compile errors

2. **Connection not working**
   - Verify connection resolver handles the type
   - Check domain context is assigned to socket
   - Ensure Ash resource/action exists

3. **Styling issues**
   - Verify DaisyUI classes are used
   - Check Tailwind is processing widget files
   - Ensure base CSS includes DaisyUI

4. **Form validation failing**
   - Confirm AshPhoenix.Form is used
   - Check changeset/form creation
   - Verify event handlers match

## Next Steps After Implementation

1. Create more specialized widgets as needed
2. Build widget documentation site
3. Consider open-sourcing widget library
4. Create VS Code snippets for widgets
5. Build widget preview/playground tool