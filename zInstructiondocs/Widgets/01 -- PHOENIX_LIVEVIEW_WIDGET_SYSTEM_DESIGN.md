# Phoenix LiveView Total Widget System Design

## Executive Summary

This document presents a revolutionary approach to building Phoenix LiveView applications where **everything is a widget**. Unlike traditional approaches that mix raw HTML, Phoenix components, and custom patterns, this system provides a unified, consistent way to build entire applications using only widgets.

The system features just two modes:
- **Dumb Mode**: Static data for rapid prototyping and UI development
- **Connected Mode**: Full Ash framework integration with a single attribute change

This approach dramatically simplifies development by providing one way to build UIs that works consistently from prototype to production.

## Table of Contents

1. [Core Philosophy & Architecture](#core-philosophy--architecture)
2. [Understanding Ash Connection Patterns](#understanding-ash-connection-patterns)
3. [Widget Base Architecture](#widget-base-architecture)
4. [The Two-Mode Pattern](#the-two-mode-pattern)
5. [Complete Widget Catalog](#complete-widget-catalog)
6. [Connection Configuration](#connection-configuration)
7. [Real-World Implementation Examples](#real-world-implementation-examples)
8. [Pros/Cons Analysis](#proscons-analysis)
9. [Implementation Roadmap](#implementation-roadmap)
10. [Technical Implementation Guide](#technical-implementation-guide)

---

## Core Philosophy & Architecture

### The "Everything is a Widget" Commitment

In this system, there are no exceptions. Every visual element on screen is a widget:

```elixir
# Traditional Phoenix LiveView approach (NOT what we do)
<div class="p-4">
  <h1 class="text-2xl"><%= @title %></h1>
  <.button phx-click="save">Save</.button>
</div>

# Our widget approach (what we ALWAYS do)
<.section_widget padding={4}>
  <.heading_widget level={1} text={@title} />
  <.button_widget action={:save} label="Save" />
</.section_widget>
```

### Why Total Widgetization?

1. **Consistency**: One pattern to learn, one pattern to master
2. **Encapsulation**: Best practices baked into every widget
3. **Rapid Development**: Start with dumb widgets, connect later
4. **Team Scaling**: New developers learn one system
5. **Maintenance**: Changes propagate through widget updates

### The Two-Mode Principle

Every widget operates in exactly one of two modes:

**Dumb Mode**:
- Receives data via attributes
- No Ash connection
- Perfect for prototyping
- Fully functional UI

**Connected Mode**:
- Connects to Ash via `data_source`
- Handles real-time updates
- Manages loading states
- Same visual output as dumb mode

### Mental Model Simplification

Traditional Phoenix LiveView development requires juggling:
- HTML structure
- Tailwind classes
- Phoenix components
- LiveView assigns
- Ash resources
- Data flow patterns

Our widget system reduces this to:
- Choose a widget
- Provide data (dumb) or connection (connected)
- Done

---

## Phoenix LiveView Standards Integration

### Embracing Phoenix LiveView's Component System

This widget system is built on top of Phoenix LiveView's standard components, not as a replacement. Every form widget internally uses the recommended Phoenix components:

- `<.form_widget>` wraps Phoenix's `<.form>`
- `<.input_widget>` wraps Phoenix's `<.input>`
- `<.nested_form_widget>` wraps Phoenix's `<.inputs_for>`

This approach provides several benefits:

1. **Best Practices Built-in**: All Phoenix LiveView's form handling best practices are preserved
2. **Seamless Ash Integration**: AshPhoenix.Form works perfectly with the standard components
3. **Consistent API**: Developers familiar with Phoenix get the expected behavior
4. **Widget Benefits**: Additional features like grid integration, debug mode, and connection patterns

### Form Component Standards

When working with forms in this widget system:

```elixir
# What you write (widget abstraction)
<.form_widget for={@form} on_submit={:save_user}>
  <.input_widget field={@form[:name]} label="Name" />
  <.input_widget field={@form[:email]} label="Email" />
</.form_widget>

# What it renders internally (Phoenix standards)
<.form for={@form} phx-submit="save_user" phx-change="validate">
  <.input field={@form[:name]} label="Name" {...widget_enhancements} />
  <.input field={@form[:email]} label="Email" {...widget_enhancements} />
</.form>
```

The widgets add consistent spacing, error handling, loading states, and other enhancements while preserving all Phoenix LiveView functionality.

---

## Understanding Ash Connection Patterns

Before diving into widgets, let's understand how Phoenix LiveView typically connects to Ash:

### 1. Code Interfaces

The preferred pattern for accessing Ash resources:

```elixir
# Define in domain
resource User do
  define :get_by_id, action: :read, get_by: [:id]
  define :list_active, action: :read, filter: [active: true]
end

# Use in LiveView
user = MyApp.Accounts.get_user_by_id!(id)
users = MyApp.Accounts.list_active_users!()
```

### 2. AshPhoenix.Form

For form handling with automatic validation:

```elixir
# Create form
form = AshPhoenix.Form.for_create(MyApp.User, :create)

# Validate
form = AshPhoenix.Form.validate(form, params)

# Submit
case AshPhoenix.Form.submit(form) do
  {:ok, user} -> # success
  {:error, form} -> # show errors
end
```

### 3. Direct Queries (Discouraged in Views)

```elixir
# Not recommended in LiveViews
users = MyApp.User
  |> Ash.Query.filter(active == true)
  |> Ash.read!()
```

### 4. PubSub for Real-time Updates

```elixir
# In resource
pub_sub do
  module MyAppWeb.Endpoint
  prefix "user"
  publish :update, ["updated", :id]
end

# In LiveView
def mount(_params, _session, socket) do
  PubSub.subscribe(MyAppWeb.Endpoint, "user:updated:#{user_id}")
  {:ok, socket}
end
```

### 5. Phoenix Streams

For efficient list updates:

```elixir
socket
|> stream(:users, users)
|> stream_insert(:users, new_user, at: 0)
```

### 6. Action Invocation

```elixir
# Via code interface
MyApp.Posts.publish_post!(post_id)

# Via changeset
post
|> Ash.Changeset.for_update(:publish)
|> Ash.update!()
```

Our widget system abstracts ALL of these patterns behind a simple interface.

---

## Widget Base Architecture

### The Universal Widget Module

Every widget in the system inherits from a base behavior:

```elixir
defmodule MyApp.Widgets.Base do
  @moduledoc """
  Base behavior for all widgets in the system.
  """
  
  @callback render(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  @callback connect(data_source :: term(), socket :: Phoenix.LiveView.Socket.t()) :: 
    {:ok, Phoenix.LiveView.Socket.t()} | {:error, term()}
  
  defmacro __using__(opts) do
    quote do
      use Phoenix.Component
      import MyApp.Widgets.Helpers
      
      @behaviour MyApp.Widgets.Base
      
      # Common attributes all widgets share
      attr :class, :string, default: ""
      attr :data_source, :any, default: :static
      attr :debug_mode, :boolean, default: false
      attr :span, :integer, default: nil
      attr :padding, :integer, default: 4
      attr :id, :string, default: nil
      
      # Form-specific: Form widgets MUST wrap Phoenix LiveView components
      # This ensures compatibility with AshPhoenix.Form and all its features
      
      # Grid and spacing integration
      defp widget_classes(assigns) do
        [
          span_class(assigns[:span]),
          padding_class(assigns[:padding]),
          assigns[:class]
        ]
        |> Enum.filter(& &1)
        |> Enum.join(" ")
      end
      
      # Debug overlay
      defp render_debug(assigns) do
        ~H"""
        <div :if={@debug_mode} class="absolute top-1 right-1 text-xs px-1 bg-base-300 rounded">
          {inspect(@data_source)}
        </div>
        """
      end
    end
  end
end
```

### Widget Type System

Using Phoenix.Component's attribute system for type safety:

```elixir
defmodule MyApp.Widgets.UserCard do
  use MyApp.Widgets.Base
  
  # Dumb mode attributes
  attr :name, :string, default: nil
  attr :email, :string, default: nil
  attr :avatar, :string, default: nil
  attr :role, :string, default: nil
  
  # Connected mode configuration
  attr :load, :list, default: []
  attr :subscribe, :boolean, default: true
  
  def render(assigns) do
    # Resolve data based on mode
    assigns = resolve_data(assigns)
    
    ~H"""
    <div class={["card", widget_classes(assigns)]}>
      {render_debug(assigns)}
      
      <div class="card-body">
        <div class="flex items-center space-x-4">
          <.avatar_widget src={@avatar} size={:lg} />
          <div>
            <.heading_widget level={3} text={@name} />
            <.text_widget size={:sm} color={:muted} text={@email} />
            <.badge_widget label={@role} color={:primary} />
          </div>
        </div>
      </div>
    </div>
    """
  end
  
  defp resolve_data(%{data_source: :static} = assigns), do: assigns
  
  defp resolve_data(%{data_source: {:interface, function}} = assigns) do
    case apply_interface(function, assigns) do
      {:ok, data} -> Map.merge(assigns, data)
      {:error, _} -> put_error_state(assigns)
    end
  end
end
```

### Grid Integration

Following the 4px atomic spacing system:

```elixir
defmodule MyApp.Widgets.Helpers do
  def span_class(nil), do: nil
  def span_class(1), do: "span-1"
  def span_class(2), do: "span-2"
  def span_class(3), do: "span-3"
  def span_class(4), do: "span-4"
  def span_class(6), do: "span-6"
  def span_class(8), do: "span-8"
  def span_class(12), do: "span-12"
  
  def padding_class(1), do: "p-1"  # 4px
  def padding_class(2), do: "p-2"  # 8px
  def padding_class(3), do: "p-3"  # 12px
  def padding_class(4), do: "p-4"  # 16px
  def padding_class(6), do: "p-6"  # 24px
  def padding_class(8), do: "p-8"  # 32px
end
```

---

## The Two-Mode Pattern

### Mode Detection and Switching

Every widget automatically detects its mode based on the presence of data:

```elixir
defmodule MyApp.Widgets.TableWidget do
  use MyApp.Widgets.Base
  
  # Dumb mode: direct data
  attr :rows, :list, default: []
  attr :columns, :list, required: true
  
  # Connected mode options
  attr :stream, :atom, default: nil
  attr :sort, :list, default: []
  attr :filter, :list, default: []
  
  def render(assigns) do
    assigns = determine_mode(assigns)
    
    ~H"""
    <div class={["overflow-x-auto", widget_classes(assigns)]}>
      {render_debug(assigns)}
      
      <table class="table">
        <thead>
          <tr>
            <th :for={col <- @columns}>{col.label}</th>
          </tr>
        </thead>
        <tbody>
          {render_rows(assigns)}
        </tbody>
      </table>
    </div>
    """
  end
  
  defp determine_mode(%{rows: rows} = assigns) when is_list(rows) do
    Map.put(assigns, :mode, :dumb)
  end
  
  defp determine_mode(%{data_source: source} = assigns) when source != :static do
    Map.put(assigns, :mode, :connected)
  end
  
  defp render_rows(%{mode: :dumb} = assigns) do
    ~H"""
    <tr :for={row <- @rows}>
      <td :for={col <- @columns}>{Map.get(row, col.field)}</td>
    </tr>
    """
  end
  
  defp render_rows(%{mode: :connected, stream: stream} = assigns) when not is_nil(stream) do
    ~H"""
    <tr :for={{id, row} <- @streams[stream]} id={id}>
      <td :for={col <- @columns}>{Map.get(row, col.field)}</td>
    </tr>
    """
  end
end
```

### Progressive Enhancement Example

Starting with a dumb implementation and upgrading to connected:

```elixir
defmodule MyAppWeb.UsersLive do
  use MyAppWeb, :live_view
  
  def mount(_params, _session, socket) do
    # Stage 1: Dumb mode for rapid prototyping
    socket = assign(socket, :development_stage, :prototype)
    {:ok, socket}
  end
  
  def render(%{development_stage: :prototype} = assigns) do
    ~H"""
    <.layout_widget type={:dashboard}>
      <:sidebar>
        <.nav_widget items={[
          %{label: "Users", icon: :users, active: true},
          %{label: "Settings", icon: :cog}
        ]} />
      </:sidebar>
      
      <:main>
        <.page_header_widget 
          title="Users"
          actions={[
            %{label: "Add User", icon: :plus, color: :primary}
          ]}
        />
        
        <!-- Dumb mode with static data -->
        <.table_widget
          columns={[
            %{field: :name, label: "Name"},
            %{field: :email, label: "Email"},
            %{field: :role, label: "Role"}
          ]}
          rows={[
            %{name: "John Doe", email: "john@example.com", role: "Admin"},
            %{name: "Jane Smith", email: "jane@example.com", role: "User"}
          ]}
        />
      </:main>
    </.layout_widget>
    """
  end
  
  def render(%{development_stage: :connected} = assigns) do
    ~H"""
    <.layout_widget type={:dashboard}>
      <:sidebar>
        <.nav_widget 
          data_source={:interface, :get_navigation}
          active_item={:users}
        />
      </:sidebar>
      
      <:main>
        <.page_header_widget 
          title="Users"
          data_source={:interface, :get_user_actions}
        />
        
        <!-- Connected mode with Ash integration -->
        <.table_widget
          columns={[
            %{field: :name, label: "Name", sortable: true},
            %{field: :email, label: "Email", sortable: true},
            %{field: :role, label: "Role", filterable: true}
          ]}
          data_source={:interface, :list_users}
          stream={:users}
          sort={@sort}
          filter={@filter}
        />
      </:main>
    </.layout_widget>
    """
  end
end
```

---

## Complete Widget Catalog

### Layout Widgets

Pure presentation widgets that structure the page:

```elixir
# Page layout with sidebar
<.layout_widget type={:dashboard}>
  <:sidebar>...</:sidebar>
  <:main>...</:main>
</.layout_widget>

# Grid container
<.grid_widget columns={12} gap={6}>
  <!-- widgets automatically respect grid -->
</.grid_widget>

# Section with consistent spacing
<.section_widget padding={8} margin_bottom={6}>
  <!-- content -->
</.section_widget>

# Flex container
<.flex_widget direction={:row} align={:center} gap={4}>
  <!-- widgets -->
</.flex_widget>
```

### Display Widgets

Show data with optional Ash connections:

```elixir
# Stat card
<.stat_widget
  label="Total Users"
  value={1234}
  change={+12.5}
  trend={:up}
/>

# Connected version
<.stat_widget
  label="Total Users"
  data_source={:interface, :get_user_count}
  refresh_interval={5000}
/>

# Info card
<.card_widget span={4}>
  <:header>
    <.heading_widget level={3} text="Revenue" />
  </:header>
  <:body>
    <.metric_widget 
      value="$12,345"
      subtitle="This month"
    />
  </:body>
</.card_widget>

# Badge
<.badge_widget 
  label={@user.role}
  color={role_color(@user.role)}
/>
```

### Table/List Widgets

Data display with built-in Ash query support:

```elixir
# Basic table
<.table_widget
  columns={@columns}
  rows={@users}
/>

# Connected with streams
<.table_widget
  columns={@columns}
  data_source={:interface, :list_users}
  stream={:users}
  sort={@sort}
  filter={@filter}
  on_row_click={&navigate_to_user/1}
/>

# List widget
<.list_widget orientation={:vertical} gap={2}>
  <:item :for={item <- @items}>
    <.list_item_widget
      title={item.name}
      subtitle={item.description}
      avatar={item.image}
      actions={[
        %{icon: :edit, action: {:edit_item, item.id}},
        %{icon: :delete, action: {:delete_item, item.id}}
      ]}
    />
  </:item>
</.list_widget>

# Kanban board
<.kanban_widget
  columns={[
    %{id: :todo, label: "To Do"},
    %{id: :in_progress, label: "In Progress"},
    %{id: :done, label: "Done"}
  ]}
  data_source={:interface, :list_tasks}
  group_by={:status}
  on_drop={&handle_task_move/2}
/>
```

### Form Widgets

Form widgets provide a thin wrapper around Phoenix LiveView's standard form components while adding widget system benefits. They maintain full compatibility with AshPhoenix.Form:

#### Form Initialization with AshPhoenix.Form

```elixir
# In your LiveView mount or update
def mount(_params, _session, socket) do
  # For new records
  form = AshPhoenix.Form.for_create(MyApp.User, :create)
  
  # For updates
  form = AshPhoenix.Form.for_update(user, :update)
  
  {:ok, assign(socket, :form, form)}
end
```

#### Using Form Widgets

```elixir
# Simple form with Phoenix LiveView components wrapped in widgets
<.form_widget
  for={@form}
  on_submit={:save_user}
  on_change={:validate_user}
>
  <.input_widget field={@form[:name]} label="Name" />
  <.input_widget field={@form[:email]} label="Email" type={:email} />
  <.select_widget 
    field={@form[:role]} 
    label="Role"
    options={[
      {"Admin", :admin},
      {"User", :user}
    ]}
  />
  <.button_widget type={:submit} label="Save" />
</.form_widget>

# How form_widget internally uses Phoenix's <.form> component
defmodule MyApp.Widgets.FormWidget do
  use MyApp.Widgets.Base
  
  attr :for, AshPhoenix.Form, required: true
  attr :on_submit, :string, required: true
  attr :on_change, :string, default: "validate"
  slot :inner_block, required: true
  
  def render(assigns) do
    ~H"""
    <.form 
      for={@for} 
      phx-submit={@on_submit} 
      phx-change={@on_change}
      class={widget_classes(assigns)}
    >
      {render_debug(assigns)}
      <%= render_slot(@inner_block, @for) %>
    </.form>
    """
  end
end

# Nested forms
<.form_widget for={@form}>
  <.fieldset_widget legend="User Details">
    <.input_widget field={@form[:name]} />
    <.input_widget field={@form[:email]} />
  </.fieldset_widget>
  
  <.fieldset_widget legend="Addresses">
    <.nested_form_widget field={@form[:addresses]}>
      <:fields :let={address}>
        <.input_widget field={address[:street]} />
        <.input_widget field={address[:city]} />
      </:fields>
      <:add_button>
        <.button_widget icon={:plus} label="Add Address" />
      </:add_button>
    </.nested_form_widget>
  </.fieldset_widget>
</.form_widget>
```

### Form Validation and Submission

The widget system fully supports AshPhoenix.Form's validation and submission patterns:

#### Real-time Validation

All form widgets automatically enable real-time validation through AshPhoenix.Form:

```elixir
# In your LiveView
def handle_event("validate", %{"form" => params}, socket) do
  form = AshPhoenix.Form.validate(socket.assigns.form, params)
  {:noreply, assign(socket, :form, form)}
end

def handle_event("save_user", %{"form" => params}, socket) do
  case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
    {:ok, user} ->
      socket
      |> put_flash(:info, "User created successfully")
      |> redirect(to: ~p"/users/#{user.id}")
      |> then(&{:noreply, &1})
    
    {:error, form} ->
      {:noreply, assign(socket, :form, form)}
  end
end
```

#### Benefits of AshPhoenix.Form Integration

1. **Automatic Validation**: All Ash validations are automatically applied
2. **Policy Enforcement**: Ash policies are checked during submission
3. **Change Tracking**: Ash changes are executed in the correct order
4. **Error Handling**: Validation errors are automatically displayed
5. **Nested Forms**: Full support for nested resources and relationships

### Dynamic Forms with Special Parameters

The widget system fully supports AshPhoenix.Form's special parameters for dynamic form manipulation:

#### List Manipulation Parameters

```elixir
# Adding items to a list
<.button_widget 
  name="form[addresses][_add_addresses]" 
  value="true"
  label="Add Address"
  type={:button}
/>

# Removing items from a list
<.button_widget 
  name="form[addresses][0][_drop_addresses]" 
  value="true"
  label="Remove"
  type={:button}
  color={:danger}
/>

# Sorting items in a list
<.input_widget 
  type={:hidden}
  name="form[addresses][0][_sort_addresses]" 
  value={0}
/>
```

#### Practical Example: Dynamic Address Management

```elixir
<.form_widget for={@form}>
  <.repeater_widget field={@form[:addresses]}>
    <:template :let={address_form}>
      <.card_widget>
        <:body>
          <.input_widget field={address_form[:street]} label="Street" />
          <.input_widget field={address_form[:city]} label="City" />
          
          <!-- Hidden sort field for drag-and-drop reordering -->
          <input type="hidden" 
                 name={address_form[:_sort_addresses].name} 
                 value={address_form.index} />
          
          <!-- Remove button with special parameter -->
          <.button_widget 
            type={:button}
            name={address_form[:_drop_addresses].name}
            value="true"
            label="Remove Address"
            color={:danger}
            icon={:trash}
          />
        </:body>
      </.card_widget>
    </:template>
    
    <:add_button>
      <!-- Add button with special parameter -->
      <.button_widget 
        type={:button}
        name={@form[:addresses][:_add_addresses].name}
        value="true"
        label="Add Address"
        icon={:plus}
      />
    </:add_button>
  </.repeater_widget>
</.form_widget>
```

#### Union Type Handling

For polymorphic associations and union types:

```elixir
# Selecting union type
<.select_widget 
  field={@form[:content][:_union_type]}
  label="Content Type"
  options={[
    {"Text Block", "text_block"},
    {"Image", "image"},
    {"Video", "video"}
  ]}
/>

# Conditional rendering based on union type
<%= case @form[:content][:_union_type].value do %>
  <% "text_block" -> %>
    <.textarea_widget field={@form[:content][:text]} label="Text Content" />
  <% "image" -> %>
    <.input_widget field={@form[:content][:url]} label="Image URL" />
    <.input_widget field={@form[:content][:alt_text]} label="Alt Text" />
  <% "video" -> %>
    <.input_widget field={@form[:content][:embed_code]} label="Video Embed Code" />
<% end %>
```

#### Event Handling for Dynamic Forms

The form widget automatically handles these special parameters in the validate event:

```elixir
def handle_event("validate", params, socket) do
  # AshPhoenix.Form automatically processes special parameters:
  # - _add_* creates new nested forms
  # - _drop_* removes nested forms
  # - _sort_* reorders nested forms
  # - _union_type switches union types
  
  form = AshPhoenix.Form.validate(socket.assigns.form, params)
  {:noreply, assign(socket, :form, form)}
end
```

### Action Widgets

Buttons and interactive elements:

```elixir
# Simple button
<.button_widget
  label="Click me"
  on_click={:handle_click}
  color={:primary}
  size={:lg}
/>

# Connected to Ash action
<.button_widget
  label="Publish Post"
  data_source={:action, :publish_post, @post.id}
  confirm="Are you sure?"
  loading_text="Publishing..."
/>

# Dropdown actions
<.dropdown_widget
  trigger={
    <.button_widget label="Actions" icon={:chevron_down} />
  }
>
  <.dropdown_item_widget
    label="Edit"
    icon={:edit}
    action={:edit, @resource}
  />
  <.dropdown_item_widget
    label="Delete"
    icon={:trash}
    action={:delete, @resource}
    confirm="Delete this item?"
    danger={true}
  />
</.dropdown_widget>

# Toolbar
<.toolbar_widget>
  <:left>
    <.button_group_widget>
      <.button_widget label="Bold" icon={:bold} />
      <.button_widget label="Italic" icon={:italic} />
    </.button_group_widget>
  </:left>
  <:right>
    <.button_widget label="Save" color={:success} />
  </:right>
</.toolbar_widget>
```

### Navigation Widgets

Links and navigation with Ash relationship awareness:

```elixir
# Navigation menu
<.nav_widget
  items={[
    %{label: "Dashboard", path: "/", icon: :home},
    %{label: "Users", path: "/users", icon: :users},
    %{label: "Settings", path: "/settings", icon: :cog}
  ]}
  current_path={@current_path}
/>

# Connected navigation
<.nav_widget
  data_source={:interface, :get_navigation_items}
  current_path={@current_path}
/>

# Breadcrumbs
<.breadcrumb_widget
  items={[
    %{label: "Home", path: "/"},
    %{label: "Users", path: "/users"},
    %{label: @user.name}
  ]}
/>

# Tabs
<.tab_widget
  tabs={[
    %{id: :overview, label: "Overview"},
    %{id: :activity, label: "Activity"},
    %{id: :settings, label: "Settings"}
  ]}
  active_tab={@active_tab}
  on_change={:change_tab}
>
  <:panel id={:overview}>
    <!-- Overview content -->
  </:panel>
  <:panel id={:activity}>
    <!-- Activity content -->
  </:panel>
  <:panel id={:settings}>
    <!-- Settings content -->
  </:panel>
</.tab_widget>
```

### Feedback Widgets

User feedback and system state:

```elixir
# Alert
<.alert_widget
  type={:success}
  title="Success!"
  message="Your changes have been saved."
  dismissible={true}
/>

# Toast notifications
<.toast_container_widget position={:top_right}>
  <.toast_widget
    :for={toast <- @toasts}
    id={toast.id}
    type={toast.type}
    message={toast.message}
    auto_dismiss={5000}
  />
</.toast_container_widget>

# Loading states
<.loading_widget 
  :if={@loading}
  type={:spinner}
  message="Loading users..."
/>

# Empty state
<.empty_state_widget
  :if={Enum.empty?(@items)}
  icon={:inbox}
  title="No items yet"
  description="Create your first item to get started"
  action={%{label: "Create Item", action: :new_item}}
/>

# Progress
<.progress_widget
  value={@upload_progress}
  max={100}
  label="Uploading..."
  show_percentage={true}
/>
```

### Modal/Overlay Widgets

```elixir
# Modal
<.modal_widget
  :if={@show_modal}
  title="Edit User"
  on_close={:close_modal}
>
  <:body>
    <.form_widget for={@form}>
      <!-- form fields -->
    </.form_widget>
  </:body>
  <:footer>
    <.button_widget label="Cancel" on_click={:close_modal} />
    <.button_widget label="Save" color={:primary} type={:submit} />
  </:footer>
</.modal_widget>

# Drawer
<.drawer_widget
  :if={@show_drawer}
  position={:right}
  title="Filters"
  on_close={:close_drawer}
>
  <!-- filter widgets -->
</.drawer_widget>

# Popover
<.popover_widget
  trigger={
    <.button_widget label="More info" icon={:info} />
  }
>
  <.text_widget text="Additional information here" />
</.popover_widget>
```

---

## Connection Configuration

### Data Source Types

Every widget accepts a `data_source` attribute that determines its connection:

```elixir
# Static (dumb mode)
data_source: :static  # default

# Code interface
data_source: {:interface, :function_name}
data_source: {:interface, :function_name, args}

# Direct resource query
data_source: {:resource, MyApp.User, [filter: [active: true]]}

# Stream
data_source: {:stream, :users}

# Form
data_source: {:form, :create_user}
data_source: {:form, :update_user, @user}

# Action
data_source: {:action, :publish, @post}

# PubSub subscription
data_source: {:subscribe, "user:updated:#{@user.id}"}
```

### Widget Connection Resolution

How widgets resolve their connections:

```elixir
defmodule MyApp.Widgets.ConnectionResolver do
  def resolve({:interface, function}, socket) when is_atom(function) do
    # Find domain module from socket context
    domain = socket.assigns[:current_domain] || raise "No domain in context"
    
    # Call the interface function
    case apply(domain, function, []) do
      {:ok, data} -> {:ok, data}
      data when is_list(data) -> {:ok, data}
      data -> {:ok, data}
    end
  end
  
  def resolve({:interface, function, args}, socket) do
    domain = socket.assigns[:current_domain]
    apply(domain, function, args)
  end
  
  def resolve({:resource, resource, opts}, socket) do
    # Build query
    query = resource
    query = if opts[:filter], do: Ash.Query.filter(query, opts[:filter]), else: query
    query = if opts[:sort], do: Ash.Query.sort(query, opts[:sort]), else: query
    query = if opts[:load], do: Ash.Query.load(query, opts[:load]), else: query
    
    # Execute with socket context
    Ash.read(query, scope: socket.assigns.scope)
  end
  
  def resolve({:stream, stream_name}, socket) do
    # Streams are handled differently - return stream reference
    {:stream, stream_name}
  end
  
  def resolve({:form, action}, socket) do
    # Generate form for create
    resource = infer_resource_from_action(action)
    form = AshPhoenix.Form.for_create(resource, action)
    
    # Enable automatic validation
    Map.put(form, :auto_validate, true)
  end
  
  def resolve({:form, action, record}, socket) do
    # Generate form for update
    form = AshPhoenix.Form.for_update(record, action)
    
    # Enable automatic validation
    Map.put(form, :auto_validate, true)
  end
  
  def resolve({:form, :validate, form, params}, socket) do
    # Handle form validation
    AshPhoenix.Form.validate(form, params)
  end
  
  def resolve({:action, action, record}, socket) do
    # Return action configuration for button handling
    {:action, action, record}
  end
  
  def resolve({:subscribe, topic}, socket) do
    # Subscribe to PubSub topic
    PubSub.subscribe(socket.assigns.pubsub, topic)
    {:subscribed, topic}
  end
end
```

### Auto-Detection and Optimization

Widgets automatically optimize based on their type:

```elixir
defmodule MyApp.Widgets.TableWidget do
  use MyApp.Widgets.Base
  
  def mount(socket) do
    # Auto-detect optimal connection strategy
    socket = 
      case socket.assigns.data_source do
        {:resource, _, _} -> optimize_for_query(socket)
        {:interface, _, _} -> optimize_for_interface(socket)
        {:stream, _} -> optimize_for_stream(socket)
        _ -> socket
      end
    
    {:ok, socket}
  end
  
  defp optimize_for_stream(socket) do
    # Set up stream with pagination
    socket
    |> assign(:per_page, 50)
    |> assign(:enable_virtual_scroll, true)
  end
  
  defp optimize_for_query(socket) do
    # Enable query caching
    socket
    |> assign(:cache_ttl, :timer.seconds(30))
    |> assign(:enable_query_batching, true)
  end
end
```

---

## Real-World Implementation Examples

### Example 1: Complete Admin Dashboard

A full admin dashboard built entirely with widgets:

```elixir
defmodule MyAppWeb.Admin.DashboardLive do
  use MyAppWeb, :live_view
  
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign_domain(MyApp.Admin)
      |> assign(:current_user, session["current_user"])
      |> assign(:debug_mode, Application.get_env(:my_app, :widget_debug, false))
    
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <.layout_widget type={:admin} class="min-h-screen">
      <:header>
        <.navbar_widget
          logo="/images/logo.png"
          data_source={:interface, :get_admin_nav}
          user={@current_user}
        >
          <:actions>
            <.notification_bell_widget
              data_source={:subscribe, "notifications:#{@current_user.id}"}
            />
            <.user_menu_widget user={@current_user} />
          </:actions>
        </.navbar_widget>
      </:header>
      
      <:sidebar>
        <.sidebar_nav_widget
          data_source={:interface, :get_sidebar_items}
          current_path={@current_path}
          collapsible={true}
        />
      </:sidebar>
      
      <:main>
        <.page_widget padding={6}>
          <.page_header_widget
            title="Dashboard"
            breadcrumbs={[
              %{label: "Home", path: "/"},
              %{label: "Dashboard"}
            ]}
          />
          
          <.grid_widget columns={12} gap={6}>
            <!-- Stat cards row -->
            <.stat_widget
              span={3}
              label="Total Users"
              data_source={:interface, :count_users}
              icon={:users}
              color={:blue}
            />
            
            <.stat_widget
              span={3}
              label="Revenue"
              data_source={:interface, :calculate_revenue}
              icon={:dollar}
              color={:green}
              format={:currency}
            />
            
            <.stat_widget
              span={3}
              label="Active Sessions"
              data_source={:subscribe, "metrics:active_sessions"}
              icon={:activity}
              color={:purple}
            />
            
            <.stat_widget
              span={3}
              label="Conversion Rate"
              data_source={:interface, :conversion_rate}
              icon={:trending_up}
              color={:orange}
              format={:percentage}
            />
            
            <!-- Charts row -->
            <.card_widget span={8}>
              <:header>
                <.heading_widget level={3} text="Revenue Over Time" />
              </:header>
              <:body>
                <.chart_widget
                  type={:line}
                  data_source={:interface, :revenue_chart_data}
                  height={300}
                  refresh_interval={60000}
                />
              </:body>
            </.card_widget>
            
            <.card_widget span={4}>
              <:header>
                <.heading_widget level={3} text="Top Products" />
              </:header>
              <:body>
                <.list_widget
                  data_source={:interface, :top_products}
                  render_item={&render_product_item/1}
                  max_items={5}
                />
              </:body>
            </.card_widget>
            
            <!-- Recent activity -->
            <.card_widget span={12}>
              <:header>
                <.flex_widget justify={:between} align={:center}>
                  <.heading_widget level={3} text="Recent Orders" />
                  <.button_widget
                    label="View All"
                    size={:sm}
                    variant={:ghost}
                    navigate="/admin/orders"
                  />
                </.flex_widget>
              </:header>
              <:body>
                <.table_widget
                  data_source={:interface, :recent_orders}
                  stream={:orders}
                  columns={[
                    %{field: :id, label: "Order ID", width: "10%"},
                    %{field: :customer_name, label: "Customer"},
                    %{field: :items_count, label: "Items"},
                    %{field: :total, label: "Total", format: :currency},
                    %{field: :status, label: "Status", render: &render_status_badge/1},
                    %{field: :created_at, label: "Date", format: :relative_time}
                  ]}
                  row_actions={[
                    %{icon: :eye, label: "View", action: :view_order},
                    %{icon: :download, label: "Invoice", action: :download_invoice}
                  ]}
                />
              </:body>
            </.card_widget>
          </.grid_widget>
        </.page_widget>
      </:main>
    </.layout_widget>
    """
  end
  
  defp render_product_item(product) do
    ~H"""
    <.flex_widget justify={:between} align={:center} padding={2}>
      <.flex_widget gap={3} align={:center}>
        <.avatar_widget src={product.image} size={:sm} />
        <div>
          <.text_widget text={product.name} weight={:medium} />
          <.text_widget text={"#{product.sales} sales"} size={:sm} color={:muted} />
        </div>
      </.flex_widget>
      <.text_widget text={format_currency(product.revenue)} weight={:bold} />
    </.flex_widget>
    """
  end
  
  defp render_status_badge(status) do
    ~H"""
    <.badge_widget
      label={humanize(status)}
      color={status_color(status)}
      size={:sm}
    />
    """
  end
end
```

### Example 2: CRUD Interface Progression

Building a complete CRUD interface, starting dumb and upgrading to connected:

```elixir
defmodule MyAppWeb.ProductsLive do
  use MyAppWeb, :live_view
  
  # Stage 1: Dumb prototype
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:products, sample_products())
      |> assign(:show_form, false)
      |> assign(:form, nil)
    
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <.page_widget>
      <.page_header_widget
        title="Products"
        subtitle="Manage your product catalog"
      >
        <:actions>
          <.button_widget
            label="Add Product"
            icon={:plus}
            color={:primary}
            on_click={:show_form}
          />
        </:actions>
      </.page_header_widget>
      
      <.card_widget>
        <.table_widget
          columns={[
            %{field: :name, label: "Name", sortable: true},
            %{field: :sku, label: "SKU"},
            %{field: :price, label: "Price", format: :currency},
            %{field: :stock, label: "Stock"},
            %{field: :status, label: "Status", render: &status_badge/1}
          ]}
          rows={@products}
          row_click={:edit_product}
          empty_state={%{
            icon: :package,
            title: "No products yet",
            description: "Add your first product to get started",
            action: %{label: "Add Product", action: :show_form}
          }}
        />
      </.card_widget>
      
      <.modal_widget :if={@show_form} title="Add Product" on_close={:hide_form}>
        <:body>
          <.form_widget for={@form} on_submit={:save_product}>
            <.input_widget field={@form[:name]} label="Product Name" />
            <.input_widget field={@form[:sku]} label="SKU" />
            <.input_widget field={@form[:price]} label="Price" type={:currency} />
            <.input_widget field={@form[:stock]} label="Stock" type={:number} />
            <.select_widget
              field={@form[:status]}
              label="Status"
              options={[
                {"Active", :active},
                {"Draft", :draft},
                {"Archived", :archived}
              ]}
            />
          </.form_widget>
        </:body>
        <:footer>
          <.button_widget label="Cancel" on_click={:hide_form} />
          <.button_widget label="Save" color={:primary} type={:submit} />
        </:footer>
      </.modal_widget>
    </.page_widget>
    """
  end
  
  # Stage 2: Connected with Ash
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_domain(MyApp.Inventory)
      |> stream(:products, [])
      |> assign(:show_form, false)
      |> assign(:form, nil)
    
    # Load initial data
    {:ok, load_products(socket)}
  end
  
  def render(assigns) do
    ~H"""
    <.page_widget>
      <.page_header_widget
        title="Products"
        subtitle="Manage your product catalog"
        data_source={:interface, :get_product_stats}
      >
        <:actions>
          <.button_widget
            label="Add Product"
            icon={:plus}
            color={:primary}
            data_source={:form, :create_product}
          />
        </:actions>
      </.page_header_widget>
      
      <.filter_bar_widget
        filters={[
          %{field: :status, label: "Status", type: :select, options: product_statuses()},
          %{field: :category, label: "Category", type: :select, data_source: {:interface, :list_categories}},
          %{field: :price_range, label: "Price Range", type: :range}
        ]}
        on_change={:apply_filters}
      />
      
      <.card_widget>
        <.table_widget
          data_source={:interface, :list_products}
          stream={:products}
          columns={[
            %{field: :name, label: "Name", sortable: true},
            %{field: :sku, label: "SKU"},
            %{field: :price, label: "Price", format: :currency, sortable: true},
            %{field: :stock, label: "Stock", sortable: true},
            %{field: :category, label: "Category", filterable: true},
            %{field: :status, label: "Status", render: &status_badge/1, filterable: true}
          ]}
          bulk_actions={[
            %{label: "Archive", action: :bulk_archive, confirm: true},
            %{label: "Export", action: :export_products}
          ]}
          row_actions={[
            %{icon: :edit, action: :edit_product},
            %{icon: :copy, action: :duplicate_product},
            %{icon: :trash, action: :delete_product, confirm: true}
          ]}
        />
      </.card_widget>
      
      <.form_modal_widget
        :if={@show_form}
        title={modal_title(@form)}
        form={@form}
        on_submit={:save_product}
        on_change={:validate_product}
        on_cancel={:hide_form}
      >
        <.tabs_widget>
          <:tab id={:basic} label="Basic Info">
            <.input_widget field={@form[:name]} label="Product Name" />
            <.input_widget field={@form[:sku]} label="SKU" />
            <.textarea_widget field={@form[:description]} label="Description" />
          </:tab>
          
          <:tab id={:pricing} label="Pricing & Inventory">
            <.input_widget field={@form[:price]} label="Price" type={:currency} />
            <.input_widget field={@form[:cost]} label="Cost" type={:currency} />
            <.input_widget field={@form[:stock]} label="Stock" type={:number} />
            <.select_widget
              field={@form[:track_inventory]}
              label="Track Inventory"
              options={[{"Yes", true}, {"No", false}]}
            />
          </:tab>
          
          <:tab id={:organization} label="Organization">
            <.select_widget
              field={@form[:category_id]}
              label="Category"
              data_source={:interface, :list_categories}
            />
            <.select_widget
              field={@form[:status]}
              label="Status"
              options={product_statuses()}
            />
            <.tag_input_widget
              field={@form[:tags]}
              label="Tags"
              suggestions_source={:interface, :suggest_tags}
            />
          </:tab>
        </.tabs_widget>
      </.form_modal_widget>
    </.page_widget>
    """
  end
  
  # Event handlers work with both modes
  def handle_event("validate_product", %{"form" => params}, socket) do
    # Real-time validation as user types
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, :form, form)}
  end
  
  def handle_event("save_product", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, product} ->
        socket =
          socket
          |> put_flash(:info, "Product saved successfully")
          |> hide_form()
          |> stream_insert(:products, product)
        
        {:noreply, socket}
      
      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
  
  # Handle dynamic form actions
  def handle_event("add_variant", _, socket) do
    # Using special parameters to add a product variant
    params = %{"form" => %{"variants" => %{"_add_variants" => "true"}}}
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, :form, form)}
  end
end
```

### Example 3: Real-time Dashboard

A dashboard with live updates via PubSub:

```elixir
defmodule MyAppWeb.MetricsLive do
  use MyAppWeb, :live_view
  
  def mount(_params, _session, socket) do
    # Subscribe to all metric channels
    if connected?(socket) do
      subscribe_to_metrics()
    end
    
    socket =
      socket
      |> assign_domain(MyApp.Analytics)
      |> assign(:time_range, :last_hour)
      |> assign(:refresh_interval, 5000)
    
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <.dashboard_layout_widget>
      <:header>
        <.flex_widget justify={:between} align={:center}>
          <.heading_widget level={1} text="Real-time Metrics" />
          <.time_range_picker_widget
            value={@time_range}
            on_change={:change_time_range}
            options={[:last_hour, :last_day, :last_week]}
          />
        </.flex_widget>
      </:header>
      
      <:content>
        <.grid_widget columns={12} gap={4}>
          <!-- Real-time counters -->
          <.metric_card_widget
            span={3}
            title="Active Users"
            data_source={:subscribe, "metrics:active_users"}
            animation={:pulse}
            trend_enabled={true}
          />
          
          <.metric_card_widget
            span={3}
            title="Requests/sec"
            data_source={:subscribe, "metrics:request_rate"}
            format={:number}
            suffix="/s"
          />
          
          <.metric_card_widget
            span={3}
            title="Avg Response Time"
            data_source={:subscribe, "metrics:response_time"}
            format={:duration}
            threshold_warning={200}
            threshold_danger={500}
          />
          
          <.metric_card_widget
            span={3}
            title="Error Rate"
            data_source={:subscribe, "metrics:error_rate"}
            format={:percentage}
            color_scale={:reverse}
          />
          
          <!-- Real-time chart -->
          <.card_widget span={8}>
            <:header>
              <.heading_widget level={3} text="Traffic Over Time" />
            </:header>
            <:body>
              <.realtime_chart_widget
                data_source={:subscribe, "metrics:traffic"}
                type={:area}
                max_points={60}
                update_interval={1000}
                y_axis={%{label: "Requests", min: 0}}
              />
            </:body>
          </.card_widget>
          
          <!-- Server status -->
          <.card_widget span={4}>
            <:header>
              <.heading_widget level={3} text="Server Status" />
            </:header>
            <:body>
              <.server_list_widget
                data_source={:subscribe, "metrics:servers"}
                show_health={true}
                show_load={true}
                compact={true}
              />
            </:body>
          </.card_widget>
          
          <!-- Activity feed -->
          <.card_widget span={6}>
            <:header>
              <.heading_widget level={3} text="Recent Events" />
            </:header>
            <:body>
              <.activity_feed_widget
                data_source={:subscribe, "events:all"}
                max_items={10}
                auto_scroll={true}
                highlight_new={true}
              />
            </:body>
          </.card_widget>
          
          <!-- Error log -->
          <.card_widget span={6}>
            <:header>
              <.heading_widget level={3} text="Recent Errors" />
            </:header>
            <:body>
              <.error_log_widget
                data_source={:subscribe, "errors:recent"}
                max_items={10}
                show_stacktrace={false}
                group_similar={true}
              />
            </:body>
          </.card_widget>
        </.grid_widget>
      </:content>
    </.dashboard_layout_widget>
    """
  end
  
  # Handle PubSub messages
  def handle_info({:metric_update, metric, value}, socket) do
    # Widgets handle their own updates based on subscriptions
    {:noreply, socket}
  end
  
  defp subscribe_to_metrics do
    topics = [
      "metrics:active_users",
      "metrics:request_rate", 
      "metrics:response_time",
      "metrics:error_rate",
      "metrics:traffic",
      "metrics:servers",
      "events:all",
      "errors:recent"
    ]
    
    Enum.each(topics, fn topic ->
      PubSub.subscribe(MyApp.PubSub, topic)
    end)
  end
end
```

### Example 4: Complex Form with Relationships

A sophisticated form showing nested relationships and validations:

```elixir
defmodule MyAppWeb.EmployeeFormLive do
  use MyAppWeb, :live_view
  
  def mount(%{"id" => id}, _session, socket) do
    employee = MyApp.HR.get_employee!(id, load: [:addresses, :emergency_contacts, :documents])
    
    socket =
      socket
      |> assign_domain(MyApp.HR)
      |> assign(:employee, employee)
      |> assign(:form, build_form(employee))
    
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <.page_widget max_width={:xl}>
      <.form_wizard_widget
        for={@form}
        on_submit={:save_employee}
        on_cancel={:cancel}
        steps={[
          %{id: :personal, label: "Personal Info", icon: :user},
          %{id: :contact, label: "Contact Details", icon: :phone},
          %{id: :employment, label: "Employment", icon: :briefcase},
          %{id: :documents, label: "Documents", icon: :file}
        ]}
      >
        <:step id={:personal}>
          <.grid_widget columns={2} gap={4}>
            <.input_widget field={@form[:first_name]} label="First Name" required={true} />
            <.input_widget field={@form[:last_name]} label="Last Name" required={true} />
            <.date_picker_widget field={@form[:birth_date]} label="Date of Birth" />
            <.select_widget
              field={@form[:gender]}
              label="Gender"
              options={gender_options()}
            />
            <.input_widget 
              field={@form[:ssn]} 
              label="SSN" 
              mask="999-99-9999"
              span={2}
            />
          </.grid_widget>
        </:step>
        
        <:step id={:contact}>
          <.fieldset_widget legend="Primary Contact">
            <.input_widget field={@form[:email]} label="Email" type={:email} />
            <.input_widget field={@form[:phone]} label="Phone" type={:tel} />
          </.fieldset_widget>
          
          <.fieldset_widget legend="Addresses">
            <.repeater_widget field={@form[:addresses]} min={1} max={3}>
              <:template :let={address}>
                <.card_widget margin_bottom={4}>
                  <:body>
                    <.select_widget
                      field={address[:type]}
                      label="Address Type"
                      options={[
                        {"Home", :home},
                        {"Work", :work},
                        {"Other", :other}
                      ]}
                    />
                    <.input_widget field={address[:street]} label="Street Address" />
                    <.grid_widget columns={3} gap={4}>
                      <.input_widget field={address[:city]} label="City" />
                      <.select_widget
                        field={address[:state]}
                        label="State"
                        data_source={:interface, :list_states}
                      />
                      <.input_widget field={address[:zip]} label="ZIP" mask="99999" />
                    </.grid_widget>
                  </:body>
                </.card_widget>
              </:template>
              <:add_button>
                <.button_widget icon={:plus} label="Add Address" variant={:outline} />
              </:add_button>
            </.repeater_widget>
          </.fieldset_widget>
          
          <.fieldset_widget legend="Emergency Contacts">
            <.repeater_widget field={@form[:emergency_contacts]} min={1}>
              <:template :let={contact}>
                <.grid_widget columns={2} gap={4}>
                  <.input_widget field={contact[:name]} label="Name" />
                  <.input_widget field={contact[:relationship]} label="Relationship" />
                  <.input_widget field={contact[:phone]} label="Phone" type={:tel} />
                  <.input_widget field={contact[:email]} label="Email" type={:email} />
                </.grid_widget>
              </:template>
            </.repeater_widget>
          </.fieldset_widget>
        </:step>
        
        <:step id={:employment}>
          <.grid_widget columns={2} gap={4}>
            <.input_widget field={@form[:employee_id]} label="Employee ID" />
            <.date_picker_widget field={@form[:hire_date]} label="Hire Date" />
            
            <.select_widget
              field={@form[:department_id]}
              label="Department"
              data_source={:interface, :list_departments}
              on_change={:department_changed}
            />
            
            <.select_widget
              field={@form[:position_id]}
              label="Position"
              data_source={:interface, :list_positions, @form[:department_id].value}
              disabled={!@form[:department_id].value}
            />
            
            <.select_widget
              field={@form[:manager_id]}
              label="Reports To"
              data_source={:interface, :list_managers}
              search_enabled={true}
            />
            
            <.select_widget
              field={@form[:employment_type]}
              label="Employment Type"
              options={employment_type_options()}
            />
            
            <.currency_input_widget
              field={@form[:salary]}
              label="Annual Salary"
              span={2}
            />
          </.grid_widget>
        </:step>
        
        <:step id={:documents}>
          <.file_upload_widget
            field={@form[:documents]}
            label="Employment Documents"
            accept={[".pdf", ".doc", ".docx"]}
            max_files={10}
            max_size_mb={5}
            data_source={:interface, :upload_document}
            existing_files={@employee.documents}
          />
          
          <.checkbox_group_widget
            field={@form[:certifications]}
            label="Certifications"
            data_source={:interface, :list_certifications}
            columns={2}
          />
          
          <.rich_text_widget
            field={@form[:notes]}
            label="Additional Notes"
            toolbar={:basic}
            height={200}
          />
        </:step>
      </.form_wizard_widget>
    </.page_widget>
    """
  end
  
  # Handle dynamic form updates
  def handle_event("department_changed", %{"value" => dept_id}, socket) do
    # Clear position when department changes
    form = 
      socket.assigns.form
      |> AshPhoenix.Form.put_value([:position_id], nil)
    
    {:noreply, assign(socket, :form, form)}
  end
  
  defp build_form(employee) do
    AshPhoenix.Form.for_update(employee, :update,
      forms: [
        addresses: [
          type: :list,
          resource: MyApp.HR.Address,
          create_action: :create,
          update_action: :update
        ],
        emergency_contacts: [
          type: :list,
          resource: MyApp.HR.EmergencyContact,
          create_action: :create,
          update_action: :update
        ]
      ]
    )
  end
end
```

---

## Pros/Cons Analysis

### Pros

#### 1. Extreme Consistency
- **One Pattern**: Every UI element follows the same pattern
- **Predictable**: Developers always know how to add new UI elements
- **Refactorable**: Changes to widget behavior propagate everywhere

#### 2. Rapid Prototyping
- **Start Dumb**: Build entire UIs with static data
- **Progressive**: Connect to real data when ready
- **Visual First**: Design and UX can proceed independently

#### 3. Encapsulated Best Practices
- **Spacing**: 4px system enforced automatically
- **Grid**: All widgets are grid-aware
- **Accessibility**: ARIA attributes built-in
- **Performance**: Optimizations baked into widgets

#### 4. Simplified Mental Model
- **No HTML**: Developers think in widgets, not markup
- **No CSS Classes**: Widgets handle their own styling
- **Clear Data Flow**: Dumb vs connected is obvious

#### 5. Team Scalability
- **Easy Onboarding**: New developers learn one system
- **Consistent Output**: All developers produce similar code
- **Reduced Bikeshedding**: Fewer decisions to debate

#### 6. Type Safety
- **Compile-time Checks**: Phoenix.Component attributes
- **IDE Support**: Autocomplete for all widget options
- **Clear Contracts**: Widget APIs are explicit

### Cons

#### 1. Initial Learning Curve
- **New Abstraction**: Developers must learn widget API
- **Different Mindset**: Thinking in widgets vs HTML
- **Documentation Burden**: Team needs widget reference

#### 2. Performance Overhead
- **Extra Abstraction Layer**: Widgets add function calls
- **Memory Usage**: More assigns and state management
- **Render Cycles**: Potential for unnecessary re-renders

#### 3. Framework Lock-in
- **Custom System**: Hard to migrate away from
- **Hiring**: New developers need training
- **Community**: Can't directly use Phoenix examples

#### 4. Debugging Complexity
- **Stack Traces**: More layers in error messages
- **Component Tree**: Deeper nesting than raw HTML
- **Custom Patterns**: Standard debugging tools less helpful

#### 5. Flexibility Constraints
- **Widget Limitations**: Some designs hard to achieve
- **Escape Hatches**: Needed for edge cases
- **Override Complexity**: Customizing widgets can be tricky

#### 6. Maintenance Burden
- **Widget Library**: Large codebase to maintain
- **Version Updates**: Phoenix/LiveView changes need propagation
- **Testing**: Widgets need comprehensive test coverage

### Tradeoff Analysis

#### When This System Excels:
- **Large Teams**: Consistency matters more than flexibility
- **Rapid Development**: Speed more important than optimization
- **Business Applications**: Standard UI patterns dominate
- **Long-term Projects**: Investment in widgets pays off

#### When to Avoid:
- **Small Teams**: Overhead might not be worth it
- **Unique UIs**: Heavy custom design requirements
- **Performance Critical**: Every millisecond counts
- **Short Projects**: Not enough time to see ROI

---

## Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)

**Goal**: Establish core widget system

1. **Base Architecture**
   - Create `MyApp.Widgets.Base` behavior
   - Implement attribute system
   - Add debug mode support
   - Set up spacing/grid helpers

2. **Essential Layout Widgets**
   - `layout_widget` - Page layouts
   - `grid_widget` - 12-column grid
   - `flex_widget` - Flexbox container
   - `section_widget` - Content sections

3. **Basic Display Widgets**
   - `text_widget` - Typography
   - `heading_widget` - Headers
   - `card_widget` - Content cards
   - `badge_widget` - Status badges

4. **Connection System**
   - Implement `ConnectionResolver`
   - Add `:static` mode support
   - Create `{:interface, function}` support

### Phase 2: Forms and Actions (Weeks 3-4)

**Goal**: Full form support with Ash integration

1. **Form Widgets**
   - `form_widget` - Form container
   - `input_widget` - Text inputs
   - `select_widget` - Dropdowns
   - `checkbox_widget` - Checkboxes
   - `radio_widget` - Radio buttons

2. **Form Features**
   - AshPhoenix.Form integration
   - Validation display
   - Error handling
   - Nested form support

3. **Action Widgets**
   - `button_widget` - All button types
   - `dropdown_widget` - Action menus
   - `toolbar_widget` - Action bars

4. **Ash Action Support**
   - `{:form, action}` connections
   - `{:action, action, record}` support
   - Loading states
   - Confirmation dialogs

### Phase 3: Data Display (Weeks 5-6)

**Goal**: Tables, lists, and real-time data

1. **Table Widgets**
   - `table_widget` - Data tables
   - Column sorting
   - Filtering
   - Pagination
   - Row actions

2. **List Widgets**
   - `list_widget` - Vertical/horizontal lists
   - `kanban_widget` - Kanban boards
   - `tree_widget` - Hierarchical data

3. **Stream Integration**
   - Phoenix.LiveView streams
   - Efficient updates
   - Virtual scrolling
   - Bulk operations

4. **Real-time Features**
   - PubSub subscriptions
   - Auto-refresh
   - Optimistic updates
   - Connection indicators

### Phase 4: Advanced Features (Weeks 7-8)

**Goal**: Complex widgets and developer experience

1. **Navigation Widgets**
   - `nav_widget` - Navigation menus
   - `breadcrumb_widget` - Breadcrumbs
   - `tab_widget` - Tab interfaces
   - `stepper_widget` - Multi-step flows

2. **Feedback Widgets**
   - `toast_widget` - Notifications
   - `alert_widget` - Alerts
   - `modal_widget` - Modals
   - `loading_widget` - Loading states

3. **Developer Tools**
   - Widget generator task
   - Documentation generator
   - Debug toolbar
   - Performance profiler

4. **Testing Infrastructure**
   - Widget test helpers
   - Snapshot testing
   - Integration test support
   - Visual regression tests

### Phase 5: Optimization (Weeks 9-10)

**Goal**: Production readiness

1. **Performance**
   - Render optimization
   - Lazy loading
   - Code splitting
   - Bundle size reduction

2. **Documentation**
   - Complete widget reference
   - Migration guide
   - Best practices
   - Video tutorials

3. **Tooling**
   - VS Code extension
   - Widget preview tool
   - Design system export
   - Storybook integration

4. **Community**
   - Open source preparation
   - Example applications
   - Widget marketplace
   - Community widgets

---

## Technical Implementation Guide

### Setting Up the Widget System

1. **Install Dependencies**

```elixir
# mix.exs
defp deps do
  [
    {:phoenix_live_view, "~> 0.20"},
    {:ash, "~> 3.0"},
    {:ash_phoenix, "~> 2.0"},
    # ... other deps
  ]
end
```

2. **Create Base Module**

```elixir
# lib/my_app_web/widgets/base.ex
defmodule MyAppWeb.Widgets.Base do
  @moduledoc """
  Base module for all widgets in the system.
  """
  
  defmacro __using__(_opts) do
    quote do
      use Phoenix.Component
      import MyAppWeb.Widgets.Helpers
      
      # Standard attributes
      attr :id, :string, default: nil
      attr :class, :string, default: ""
      attr :data_source, :any, default: :static
      attr :debug_mode, :boolean, default: false
      
      # Grid support
      attr :span, :integer, default: nil
      attr :padding, :integer, default: nil
      attr :margin, :integer, default: nil
      
      # Hooks
      def mount(socket), do: {:ok, socket}
      def update(assigns, socket), do: {:ok, assign(socket, assigns)}
      
      defoverridable mount: 1, update: 2
    end
  end
end
```

3. **Create First Widget**

```elixir
# lib/my_app_web/widgets/text_widget.ex
defmodule MyAppWeb.Widgets.TextWidget do
  use MyAppWeb.Widgets.Base
  
  attr :text, :string, required: true
  attr :size, :atom, default: :base, values: [:xs, :sm, :base, :lg, :xl]
  attr :color, :atom, default: :default
  attr :weight, :atom, default: :normal
  
  def render(assigns) do
    ~H"""
    <span class={[
      text_size_class(@size),
      text_color_class(@color),
      text_weight_class(@weight),
      widget_class(assigns)
    ]}>
      {@text}
    </span>
    """
  end
  
  defp text_size_class(:xs), do: "text-xs"
  defp text_size_class(:sm), do: "text-sm"
  defp text_size_class(:base), do: "text-base"
  defp text_size_class(:lg), do: "text-lg"
  defp text_size_class(:xl), do: "text-xl"
end
```

4. **Import Widgets**

```elixir
# lib/my_app_web.ex
defmodule MyAppWeb do
  def html do
    quote do
      use Phoenix.Component
      
      # Import all widgets
      import MyAppWeb.Widgets
      
      # ... rest of imports
    end
  end
end
```

5. **Create Form Widget Implementation**

Here's a complete example of implementing a form widget that wraps Phoenix LiveView's standard form component:

```elixir
# lib/my_app_web/widgets/form_widget.ex
defmodule MyAppWeb.Widgets.FormWidget do
  use MyAppWeb.Widgets.Base
  
  attr :for, AshPhoenix.Form, required: true, 
    doc: "The AshPhoenix.Form struct"
  attr :on_submit, :string, required: true,
    doc: "Event handler for form submission"
  attr :on_change, :string, default: "validate",
    doc: "Event handler for form changes (validation)"
  
  slot :inner_block, required: true
  slot :actions, doc: "Form action buttons"
  
  def render(assigns) do
    ~H"""
    <.form 
      for={@for} 
      phx-submit={@on_submit} 
      phx-change={@on_change}
      class={["widget-form", widget_classes(assigns)]}
      id={@id || "form-#{System.unique_integer([:positive])}"}
    >
      {render_debug(assigns)}
      
      <div class="form-content">
        <%= render_slot(@inner_block, @for) %>
      </div>
      
      <div :if={@actions} class="form-actions mt-6">
        <%= render_slot(@actions) %>
      </div>
    </.form>
    """
  end
end

# lib/my_app_web/widgets/input_widget.ex
defmodule MyAppWeb.Widgets.InputWidget do
  use MyAppWeb.Widgets.Base
  
  attr :field, Phoenix.HTML.FormField, required: true,
    doc: "The form field struct from the form"
  attr :label, :string, default: nil
  attr :type, :atom, default: :text
  attr :placeholder, :string, default: nil
  attr :help_text, :string, default: nil
  attr :required, :boolean, default: false
  
  def render(assigns) do
    ~H"""
    <div class={["form-control", widget_classes(assigns)]}>
      <.input 
        field={@field}
        label={@label}
        type={@type}
        placeholder={@placeholder}
        required={@required}
        help_text={@help_text}
        class="input input-bordered"
      />
      {render_debug(assigns)}
    </div>
    """
  end
end

# lib/my_app_web/widgets/nested_form_widget.ex
defmodule MyAppWeb.Widgets.NestedFormWidget do
  use MyAppWeb.Widgets.Base
  
  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, default: nil
  
  slot :fields, required: true,
    doc: "Template for each nested form item"
  slot :add_button,
    doc: "Button to add new items"
  slot :empty_message,
    doc: "Message when no items exist"
  
  def render(assigns) do
    ~H"""
    <div class={["nested-form-widget", widget_classes(assigns)]}>
      <.label :if={@label}>{@label}</.label>
      
      <.inputs_for :let={nested_form} field={@field}>
        <div class="nested-form-item">
          <%= render_slot(@fields, nested_form) %>
        </div>
      </.inputs_for>
      
      <div :if={Enum.empty?(@field.value || [])} class="empty-message">
        <%= render_slot(@empty_message) || "No items yet" %>
      </div>
      
      <div :if={@add_button} class="mt-4">
        <%= render_slot(@add_button) %>
      </div>
      
      {render_debug(assigns)}
    </div>
    """
  end
end
```

6. **Create Widget Registry**

```elixir
# lib/my_app_web/widgets.ex
defmodule MyAppWeb.Widgets do
  @moduledoc """
  Widget registry and imports.
  """
  
  defmacro __using__(_) do
    quote do
      import MyAppWeb.Widgets.{
        TextWidget,
        HeadingWidget,
        ButtonWidget,
        CardWidget,
        GridWidget,
        TableWidget,
        FormWidget,
        # ... all other widgets
      }
    end
  end
end
```

### Best Practices

1. **Widget Naming**
   - Always end with `_widget`
   - Use descriptive names
   - Group related widgets

2. **Attribute Design**
   - Required attributes for core functionality
   - Optional attributes for customization
   - Consistent naming across widgets

3. **Connection Patterns**
   - Keep connection logic in widgets
   - Use consistent data_source format
   - Handle errors gracefully

4. **Performance**
   - Minimize assigns
   - Use streams for lists
   - Implement lazy loading

5. **Testing**
   - Test each widget in isolation
   - Test dumb and connected modes
   - Test error states

### Migration Strategy

For existing Phoenix LiveView applications:

1. **Gradual Adoption**
   - Start with new features
   - Wrap existing components
   - Migrate page by page

2. **Hybrid Approach**
   - Allow raw HTML during transition
   - Create adapter widgets
   - Maintain both systems temporarily

3. **Team Training**
   - Widget workshops
   - Pair programming
   - Code reviews focused on widgets

---

## Conclusion

The Phoenix LiveView Total Widget System represents a radical simplification of web development. By committing fully to widgets and providing just two modes (dumb and connected), we create an environment where:

- Developers think in terms of functionality, not markup
- UI consistency is automatic, not aspirational  
- The gap from prototype to production is just changing an attribute
- Best practices are encoded in widgets, not documentation
- Teams can scale without losing coherence

This system isn't for everyone or every project. It requires commitment and has real tradeoffs. But for teams building large Phoenix LiveView applications with Ash, especially those valuing consistency and velocity over ultimate flexibility, it offers a compelling path forward.

The key insight is that by constraining choices, we paradoxically increase productivity. When everything is a widget, and widgets have just two modes, the entire complexity of modern web development collapses into a simple question: "Which widget do I need, and is it connected yet?"

In a world of endless options, sometimes the best choice is to have fewer choices.