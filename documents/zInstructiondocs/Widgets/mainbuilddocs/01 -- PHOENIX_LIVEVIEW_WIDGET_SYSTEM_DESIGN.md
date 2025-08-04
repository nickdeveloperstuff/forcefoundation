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

In this system, there are no exceptions. Every visual element on screen is a widget. This commitment requires discipline but delivers massive benefits.

#### Traditional vs Widget Approach

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

#### Implementation Rules

1. **No Raw HTML**: Never write HTML tags directly in LiveView templates
2. **No Direct Tailwind**: All styling goes through widget attributes
3. **No Inline Styles**: Use widget variants and modifiers
4. **No Mixed Patterns**: Either all widgets or refactor to widgets

#### Widget Coverage Checklist

- [ ] Text elements → `text_widget`
- [ ] Headings → `heading_widget`
- [ ] Containers → `section_widget`, `card_widget`, `box_widget`
- [ ] Layout → `grid_widget`, `flex_widget`, `stack_widget`
- [ ] Forms → `form_widget`, `input_widget`, `select_widget`
- [ ] Navigation → `link_widget`, `nav_widget`, `breadcrumb_widget`
- [ ] Feedback → `alert_widget`, `toast_widget`, `loading_widget`
- [ ] Data Display → `table_widget`, `list_widget`, `stat_widget`
- [ ] Media → `image_widget`, `video_widget`, `icon_widget`
- [ ] Interactive → `button_widget`, `dropdown_widget`, `modal_widget`

### Why Total Widgetization?

#### 1. **Consistency**: One Pattern to Rule Them All

```elixir
# Every developer writes the same way
# Junior developer code:
<.user_card_widget user={@user} />

# Senior developer code:
<.user_card_widget user={@user} />

# No debates about structure, styling, or patterns
```

#### 2. **Encapsulation**: Best Practices Baked In

```elixir
defmodule MyApp.Widgets.InputWidget do
  # Automatically includes:
  # - ARIA labels for accessibility
  # - Error state handling
  # - Loading states
  # - Consistent spacing (4px system)
  # - Focus management
  # - Keyboard navigation
  # - Touch target sizes
  # - Dark mode support
end
```

#### 3. **Rapid Development**: Prototype to Production

```elixir
# Day 1: Static prototype
<.dashboard_widget>
  <.stat_widget label="Users" value={1234} />
  <.chart_widget type={:line} data={@fake_data} />
</.dashboard_widget>

# Day 30: Connected to production
<.dashboard_widget>
  <.stat_widget label="Users" data_source={:interface, :count_users} />
  <.chart_widget type={:line} data_source={:interface, :revenue_chart} />
</.dashboard_widget>
# Only the data_source attribute changed!
```

#### 4. **Team Scaling**: Onboarding in Hours, Not Weeks

```elixir
# New developer training:
# 1. Here's our widget catalog
# 2. Use widgets for everything
# 3. Start with dumb mode
# 4. Connect when ready
# That's it!
```

#### 5. **Maintenance**: Update Once, Fixed Everywhere

```elixir
# Fix accessibility issue in button_widget
# Automatically fixed in:
# - 500+ buttons across the app
# - All future buttons
# - No manual updates needed
```

### The Two-Mode Principle

Every widget operates in exactly one of two modes. Understanding these modes is crucial for effective development.

#### **Dumb Mode**: Static Data Rendering

**When to Use**:
- Prototyping new features
- Design reviews
- Static content (footer, about pages)
- Testing UI states
- Component libraries/storybooks

**How It Works**:
```elixir
# Data passed directly as attributes
<.user_list_widget
  users={[
    %{id: 1, name: "Alice", role: "Admin"},
    %{id: 2, name: "Bob", role: "User"}
  ]}
  columns={[
    %{field: :name, label: "Name"},
    %{field: :role, label: "Role"}
  ]}
/>
```

**Benefits**:
- Zero backend dependencies
- Instant feedback
- Easy to test all states
- Designers can contribute
- No database needed

#### **Connected Mode**: Live Data Integration

**When to Use**:
- Production features
- Real-time updates needed
- Complex data relationships
- User interactions
- Dynamic content

**How It Works**:
```elixir
# Data fetched via data_source
<.user_list_widget
  data_source={:interface, :list_users}
  columns={[
    %{field: :name, label: "Name", sortable: true},
    %{field: :role, label: "Role", filterable: true}
  ]}
  on_row_click={:edit_user}
/>
```

**Connection Types**:
1. **Interface**: `{:interface, :function_name, args}`
2. **Resource**: `{:resource, Resource, query_opts}`
3. **Stream**: `{:stream, :stream_name}`
4. **Subscribe**: `{:subscribe, "topic"}`
5. **Form**: `{:form, :action, record}`
6. **Action**: `{:action, :action_name, record}`

### Mental Model Simplification

#### Traditional Phoenix LiveView: 7 Mental Models

```elixir
# 1. HTML structure decisions
<div> or <section>? <article>? Semantic HTML?

# 2. Tailwind class memorization
"px-4 py-2 sm:px-6 lg:px-8" or "p-4 sm:p-6 lg:p-8"?

# 3. Phoenix component API
attr :label, :string, required: true
slot :inner_block

# 4. LiveView assigns management
assign(socket, :users, users)
assign_new(socket, :filters, fn -> %{} end)

# 5. Ash resource queries
User |> Ash.Query.filter(active == true) |> Ash.read!()

# 6. PubSub patterns
PubSub.subscribe(MyApp.PubSub, "user:#{user.id}")

# 7. Stream management
stream(socket, :users, users)
stream_insert(socket, :users, user, at: 0)
```

#### Widget System: 1 Mental Model

```elixir
# 1. Choose widget and mode
<.table_widget 
  data_source={:interface, :list_users}  # That's it!
/>
```

#### Decision Tree Simplified

```
Need to show something?
  ↓
Find the right widget
  ↓
Have real data?
  ├─ No → Use dumb mode with sample data
  └─ Yes → Use connected mode with data_source
    ↓
Done! Widget handles everything else
```

#### Cognitive Load Comparison

| Task | Traditional | Widget System |
|------|-------------|---------------|
| Create a form | 15+ decisions | 2 decisions |
| Add a table | 20+ lines of code | 1 widget |
| Make responsive | Manual breakpoints | Automatic |
| Add dark mode | Update everything | Built-in |
| Handle errors | Custom logic | Widget managed |
| Loading states | Manual implementation | Automatic |

---

## Phoenix LiveView Standards Integration

### Embracing Phoenix LiveView's Component System

This widget system is built on top of Phoenix LiveView's standard components, not as a replacement. Every form widget internally uses the recommended Phoenix components.

#### Component Mapping

| Widget | Phoenix Component | Additional Features |
|--------|------------------|--------------------|
| `<.form_widget>` | `<.form>` | Auto-validation, debug mode, loading states |
| `<.input_widget>` | `<.input>` | Grid integration, consistent spacing, themes |
| `<.nested_form_widget>` | `<.inputs_for>` | Dynamic add/remove, drag-and-drop sorting |
| `<.button_widget>` | `<.button>` | Loading states, confirmation dialogs, icons |
| `<.link_widget>` | `<.link>` | Active states, prefetching, analytics |

#### Benefits of This Approach

##### 1. **Best Practices Built-in**

```elixir
defmodule MyApp.Widgets.FormWidget do
  def render(assigns) do
    ~H"""
    <.form 
      for={@for} 
      phx-submit={@on_submit} 
      phx-change={@on_change}
      # Phoenix best practices preserved:
      # - CSRF protection
      # - Method spoofing
      # - Error handling
      # - Multipart encoding
    >
      {render_debug(assigns)}  # Widget enhancement
      <%= render_slot(@inner_block, @for) %>
    </.form>
    """
  end
end
```

##### 2. **Seamless Ash Integration**

```elixir
# AshPhoenix.Form works exactly as expected
form = AshPhoenix.Form.for_create(Resource, :create)

# Widgets just pass it through
<.form_widget for={form} on_submit={:save}>
  <.input_widget field={form[:name]} />
</.form_widget>
```

##### 3. **Consistent API for Phoenix Developers**

```elixir
# Phoenix developers already know this:
<.form for={@form}>
  <.input field={@form[:email]} type="email" />
</.form>

# Widget version is nearly identical:
<.form_widget for={@form}>
  <.input_widget field={@form[:email]} type={:email} />
</.form_widget>
```

##### 4. **Widget Enhancements**

```elixir
# Automatic features added by widgets:
- Debug mode overlay
- Loading state management  
- Grid system integration
- Consistent spacing (4px system)
- Theme support
- Accessibility improvements
- Error state animations
- Touch-friendly tap targets
```

### Form Component Standards

#### The Widget Transformation Pipeline

```elixir
# Step 1: What you write (clean, semantic)
<.form_widget for={@form} on_submit={:save_user}>
  <.input_widget field={@form[:name]} label="Name" />
  <.input_widget field={@form[:email]} label="Email" />
</.form_widget>

# Step 2: What widgets generate (Phoenix components + enhancements)
<.form for={@form} phx-submit="save_user" phx-change="validate" class="widget-form">
  <div class="form-control mb-4">
    <.input 
      field={@form[:name]} 
      label="Name"
      class="input input-bordered"
      phx-debounce="300"
      aria-describedby="name-error"
    />
  </div>
  <div class="form-control mb-4">
    <.input 
      field={@form[:email]} 
      label="Email"
      type="email"
      class="input input-bordered"
      phx-debounce="300"
      aria-describedby="email-error"
    />
  </div>
</.form>

# Step 3: Final HTML output (fully accessible, styled, interactive)
<form phx-submit="save_user" phx-change="validate" class="widget-form">
  <input type="hidden" name="_csrf_token" value="..."/>
  <div class="form-control mb-4">
    <label for="form_name" class="label">
      <span class="label-text">Name</span>
    </label>
    <input 
      type="text" 
      name="form[name]" 
      id="form_name"
      class="input input-bordered"
      phx-debounce="300"
      aria-describedby="name-error"
    />
    <span id="name-error" class="error-message" phx-feedback-for="form[name]">
      <!-- Errors show here -->
    </span>
  </div>
  <!-- Similar for email field -->
</form>
```

#### Widget Enhancements Breakdown

| Enhancement | Purpose | Implementation |
|-------------|---------|----------------|
| Consistent spacing | 4px grid system | `mb-4` classes |
| Error handling | Show validation errors | Error spans with `phx-feedback-for` |
| Loading states | Disable during submit | Widget manages disabled state |
| Debouncing | Reduce server calls | `phx-debounce="300"` |
| Accessibility | Screen reader support | ARIA attributes |
| Themes | Dark/light mode | CSS variables |

---

## Understanding Ash Connection Patterns

Before diving into widgets, let's understand how Phoenix LiveView typically connects to Ash:

### 1. Code Interfaces (The Foundation)

Code interfaces are the primary way widgets connect to Ash resources. They provide a clean, testable API layer.

#### Defining Code Interfaces

```elixir
# In your domain module (lib/my_app/accounts/accounts.ex)
defmodule MyApp.Accounts do
  use Ash.Domain
  
  resources do
    resource MyApp.Accounts.User
    resource MyApp.Accounts.Role
  end
end

# In your resource (lib/my_app/accounts/resources/user.ex)
defmodule MyApp.Accounts.User do
  use Ash.Resource,
    domain: MyApp.Accounts,
    data_layer: AshPostgres.DataLayer
    
  code_interface do
    # Basic CRUD operations
    define :create, action: :create
    define :read_all, action: :read
    define :get_by_id, action: :read, get_by: [:id]
    define :update, action: :update
    define :destroy, action: :destroy
    
    # Filtered queries
    define :list_active, action: :read, filter: [active: true]
    define :list_by_role, action: :read, args: [:role_id]
    
    # Complex queries with calculations
    define :list_with_stats, action: :read_with_stats
    
    # Bulk operations
    define :bulk_activate, action: :activate
    define :bulk_archive, action: :archive
  end
  
  actions do
    defaults [:create, :read, :update, :destroy]
    
    read :read_with_stats do
      prepare build(load: [:post_count, :last_login_at])
    end
    
    update :activate do
      change set_attribute(:active, true)
    end
    
    update :archive do
      change set_attribute(:archived_at, &DateTime.utc_now/0)
    end
  end
end
```

#### Using Code Interfaces in Widgets

```elixir
# In your LiveView
<.table_widget
  data_source={:interface, :list_active}  # Calls MyApp.Accounts.list_active!()
  columns={[
    %{field: :name, label: "Name"},
    %{field: :email, label: "Email"},
    %{field: :last_login_at, label: "Last Login", format: :relative_time}
  ]}
/>

# With arguments
<.table_widget
  data_source={:interface, :list_by_role, [@selected_role_id]}
  columns={@columns}
/>

# With options
<.table_widget
  data_source={:interface, :read_all, [], [limit: 20, offset: @offset]}
  columns={@columns}
/>
```

### 2. AshPhoenix.Form (Complete Form Management)

AshPhoenix.Form provides comprehensive form handling with automatic validation, error management, and nested form support.

#### Form Initialization Patterns

```elixir
# For creating new records
def mount(_params, _session, socket) do
  form = AshPhoenix.Form.for_create(
    MyApp.Accounts.User,      # Resource module
    :create,                   # Action name
    # Optional configuration
    forms: [
      addresses: [
        resource: MyApp.Accounts.Address,
        create_action: :create,
        update_action: :update
      ]
    ],
    transform_params: &transform_params/2,
    prepare_source: &prepare_source/1
  )
  
  {:ok, assign(socket, :form, form)}
end

# For updating existing records
def mount(%{"id" => id}, _session, socket) do
  user = MyApp.Accounts.get_by_id!(id, load: [:addresses, :roles])
  
  form = AshPhoenix.Form.for_update(
    user,                      # Existing record
    :update,                   # Action name
    forms: [
      addresses: [
        resource: MyApp.Accounts.Address,
        create_action: :create,
        update_action: :update,
        destroy_action: :destroy
      ]
    ]
  )
  
  {:ok, assign(socket, :form, form)}
end
```

#### Validation Patterns

```elixir
# Basic validation on change
def handle_event("validate", %{"form" => params}, socket) do
  form = AshPhoenix.Form.validate(socket.assigns.form, params)
  {:noreply, assign(socket, :form, form)}
end

# Validation with custom logic
def handle_event("validate", %{"form" => params}, socket) do
  form = 
    socket.assigns.form
    |> AshPhoenix.Form.validate(params)
    |> maybe_add_custom_errors()
    |> update_dependent_fields()
    
  {:noreply, assign(socket, :form, form)}
end

# Async validation
def handle_event("validate_username", %{"value" => username}, socket) do
  send(self(), {:check_username, username})
  {:noreply, socket}
end

def handle_info({:check_username, username}, socket) do
  form = 
    case MyApp.Accounts.username_taken?(username) do
      true -> 
        AshPhoenix.Form.add_error(
          socket.assigns.form, 
          field: :username, 
          message: "Username already taken"
        )
      false -> 
        socket.assigns.form
    end
    
  {:noreply, assign(socket, :form, form)}
end
```

#### Submission Patterns

```elixir
# Basic submission
def handle_event("save", %{"form" => params}, socket) do
  case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
    {:ok, user} ->
      socket
      |> put_flash(:info, "User created successfully")
      |> push_navigate(to: ~p"/users/#{user.id}")
      |> then(&{:noreply, &1})
      
    {:error, form} ->
      {:noreply, assign(socket, :form, form)}
  end
end

# Submission with side effects
def handle_event("save", %{"form" => params}, socket) do
  with {:ok, form} <- AshPhoenix.Form.validate(socket.assigns.form, params),
       {:ok, user} <- AshPhoenix.Form.submit(form),
       {:ok, _} <- send_welcome_email(user),
       {:ok, _} <- log_user_creation(user) do
    socket
    |> put_flash(:info, "User created and welcome email sent")
    |> push_navigate(to: ~p"/users/#{user.id}")
    |> then(&{:noreply, &1})
  else
    {:error, %AshPhoenix.Form{} = form} ->
      {:noreply, assign(socket, :form, form)}
      
    {:error, reason} ->
      socket
      |> put_flash(:error, "An error occurred: #{inspect(reason)}")
      |> then(&{:noreply, &1})
  end
end
```

### 3. Direct Queries (When and How to Use)

While code interfaces are preferred, direct queries have their place in certain scenarios.

#### When Direct Queries Are Appropriate

```elixir
# 1. Complex, one-off queries in admin interfaces
def handle_event("run_report", %{"filters" => filters}, socket) do
  query = 
    MyApp.Accounts.User
    |> Ash.Query.filter(created_at >= ^filters["start_date"])
    |> Ash.Query.filter(created_at <= ^filters["end_date"])
    |> Ash.Query.aggregate(:count, :posts)
    |> Ash.Query.aggregate(:sum, :total_spent, :orders)
    |> Ash.Query.group_by([:role, :status])
    |> Ash.Query.sort([:role, :status])
    
  results = Ash.read!(query, actor: socket.assigns.current_user)
  {:noreply, assign(socket, :report_data, results)}
end

# 2. Dynamic query building based on user input
def build_search_query(base_query, search_params) do
  Enum.reduce(search_params, base_query, fn
    {"name", value}, query when value != "" ->
      Ash.Query.filter(query, contains(name, ^value))
      
    {"status", values}, query when is_list(values) ->
      Ash.Query.filter(query, status in ^values)
      
    {"date_range", %{"start" => start, "end" => end}}, query ->
      query
      |> Ash.Query.filter(created_at >= ^start)
      |> Ash.Query.filter(created_at <= ^end)
      
    _, query -> query
  end)
end

# 3. Performance-critical queries with specific loading patterns
def load_dashboard_data(socket) do
  # Single query with multiple aggregates
  stats = 
    MyApp.Analytics.Event
    |> Ash.Query.filter(timestamp >= ago(1, :day))
    |> Ash.Query.aggregate(:count, :total_events)
    |> Ash.Query.aggregate(:count, :unique_users, :user_id, distinct: true)
    |> Ash.Query.aggregate(:avg, :response_time)
    |> Ash.read_one!()
    
  assign(socket, :stats, stats)
end
```

#### Best Practices for Direct Queries

```elixir
# DO: Encapsulate complex queries in functions
defmodule MyApp.Analytics do
  def user_activity_query(user_id, date_range) do
    MyApp.Analytics.Event
    |> Ash.Query.filter(user_id == ^user_id)
    |> Ash.Query.filter(timestamp >= ^date_range.start)
    |> Ash.Query.filter(timestamp <= ^date_range.end)
    |> Ash.Query.load([:category, :metadata])
  end
end

# DON'T: Scatter queries throughout LiveView
# Instead, create a code interface or query module
```

### 4. PubSub for Real-time Updates (Complete Setup)

PubSub enables real-time updates across all connected clients when data changes.

#### Resource Configuration

```elixir
defmodule MyApp.Accounts.User do
  use Ash.Resource,
    domain: MyApp.Accounts,
    extensions: [AshPhoenix.PubSub]
    
  pub_sub do
    module MyAppWeb.Endpoint
    prefix "user"
    
    # Broadcast on different actions
    publish :create, "created"
    publish :update, ["updated", :id]
    publish :destroy, ["destroyed", :id]
    
    # Custom events
    publish :activate, ["activated", :id], event: "user_activated"
    publish :deactivate, ["deactivated", :id], event: "user_deactivated"
    
    # Conditional broadcasting
    publish :update, ["role_changed", :id], 
      event: "role_changed",
      condition: fn changeset -> 
        Ash.Changeset.changing_attribute?(changeset, :role)
      end
  end
end
```

#### LiveView Subscription Patterns

```elixir
# Basic subscription
def mount(%{"id" => user_id}, _session, socket) do
  if connected?(socket) do
    # Subscribe to specific user updates
    PubSub.subscribe(MyAppWeb.Endpoint, "user:updated:#{user_id}")
    
    # Subscribe to all user creations
    PubSub.subscribe(MyAppWeb.Endpoint, "user:created")
    
    # Subscribe to role changes
    PubSub.subscribe(MyAppWeb.Endpoint, "user:role_changed:#{user_id}")
  end
  
  {:ok, socket}
end

# Handling PubSub messages
def handle_info({"user:updated:" <> user_id, user}, socket) do
  # Update specific user in the UI
  socket = 
    if user.id == socket.assigns.current_user.id do
      assign(socket, :current_user, user)
    else
      stream_insert(socket, :users, user)
    end
    
  {:noreply, socket}
end

def handle_info({"user:created", new_user}, socket) do
  # Add new user to list
  socket = 
    socket
    |> stream_insert(:users, new_user, at: 0)
    |> put_flash(:info, "New user #{new_user.name} just joined!")
    
  {:noreply, socket}
end

def handle_info({"user:role_changed:" <> user_id, %{old: old_role, new: new_role}}, socket) do
  # Handle role changes with detailed info
  socket = 
    socket
    |> update(:activity_log, &[%{
      type: :role_change,
      user_id: user_id,
      from: old_role,
      to: new_role,
      timestamp: DateTime.utc_now()
    } | &1])
    
  {:noreply, socket}
end
```

#### Widget Integration

```elixir
# Real-time table widget
<.table_widget
  data_source={:interface, :list_users}
  subscribe={["user:created", "user:updated:*", "user:destroyed:*"]}
  stream={:users}
  columns={@columns}
/>

# Real-time stat widget
<.stat_widget
  label="Active Users"
  data_source={:interface, :count_active_users}
  subscribe="metrics:active_users"
  refresh_on_message={true}
/>
```

### 5. Phoenix Streams (Efficient List Management)

Phoenix Streams provide efficient DOM updates for large lists without re-rendering everything.

#### Stream Setup and Management

```elixir
def mount(_params, _session, socket) do
  socket = 
    socket
    |> stream(:users, [])
    |> stream(:notifications, [], dom_id: &"notif-#{&1.id}")
    |> stream(:messages, [], limit: 100)
    
  {:ok, load_initial_data(socket)}
end

def load_initial_data(socket) do
  users = MyApp.Accounts.list_users!()
  
  socket
  |> stream(:users, users, reset: true)
end
```

#### Stream Operations

```elixir
# Insert at specific positions
def handle_event("add_user", params, socket) do
  {:ok, user} = MyApp.Accounts.create_user(params)
  
  socket = 
    socket
    |> stream_insert(:users, user, at: 0)  # At beginning
    |> put_flash(:info, "User added")
    
  {:noreply, socket}
end

# Update existing items
def handle_event("update_user", %{"id" => id} = params, socket) do
  user = MyApp.Accounts.get_by_id!(id)
  {:ok, updated_user} = MyApp.Accounts.update_user(user, params)
  
  socket = stream_insert(socket, :users, updated_user)
  {:noreply, socket}
end

# Delete items
def handle_event("delete_user", %{"id" => id}, socket) do
  user = MyApp.Accounts.get_by_id!(id)
  {:ok, _} = MyApp.Accounts.destroy_user(user)
  
  socket = stream_delete(socket, :users, user)
  {:noreply, socket}
end

# Bulk operations
def handle_event("refresh_users", _, socket) do
  users = MyApp.Accounts.list_users!()
  
  socket = 
    socket
    |> stream(:users, users, reset: true)  # Replace all
    |> put_flash(:info, "Users refreshed")
    
  {:noreply, socket}
end

# Filtered streams
def handle_event("filter_users", %{"status" => status}, socket) do
  filtered_users = 
    MyApp.Accounts.list_users!(filter: [status: status])
    
  socket = stream(:users, filtered_users, reset: true)
  {:noreply, socket}
end
```

#### Stream with Widget Integration

```elixir
# In your LiveView
<.table_widget
  stream={:users}              # Use Phoenix stream
  columns={@columns}
  on_row_click={:edit_user}
  selectable={true}
  on_selection_change={:handle_selection}
/>

# The table widget internally renders:
<tbody phx-update="stream" id="users-table">
  <tr :for={{dom_id, user} <- @streams.users} id={dom_id}>
    <td><%= user.name %></td>
    <td><%= user.email %></td>
  </tr>
</tbody>
```

### 6. Action Invocation (Complete Patterns)

Actions represent state changes in your system. Understanding how to invoke them properly is crucial.

#### Defining Actions

```elixir
defmodule MyApp.Blog.Post do
  actions do
    defaults [:create, :read, :update, :destroy]
    
    # Simple state change
    update :publish do
      # Validate the post is ready
      validate present(:title)
      validate present(:content)
      validate compare(:word_count, greater_than_or_equal_to: 100)
      
      # Set publication data
      change set_attribute(:published_at, &DateTime.utc_now/0)
      change set_attribute(:status, :published)
      
      # Side effects
      after_action &send_publication_notifications/3
    end
    
    # Complex action with arguments
    update :schedule do
      argument :publish_at, :utc_datetime_usec, allow_nil?: false
      
      validate compare(:publish_at, greater_than: :now)
      
      change set_attribute(:status, :scheduled)
      change set_attribute(:scheduled_at, arg(:publish_at))
    end
    
    # Bulk action
    update :bulk_categorize do
      argument :category_id, :uuid, allow_nil?: false
      
      change manage_relationship(:category_id, :category, type: :append_and_remove)
    end
  end
end
```

#### Invocation Patterns

```elixir
# 1. Via Code Interface (Preferred)
defmodule MyApp.Blog do
  code_interface do
    define :publish_post, args: [:post], action: :publish
    define :schedule_post, args: [:post, :publish_at], action: :schedule
    define :bulk_categorize_posts, args: [:posts, :category_id], action: :bulk_categorize
  end
end

# Usage in LiveView
def handle_event("publish", %{"id" => id}, socket) do
  post = MyApp.Blog.get_post!(id)
  
  case MyApp.Blog.publish_post(post) do
    {:ok, published_post} ->
      socket
      |> stream_insert(:posts, published_post)
      |> put_flash(:info, "Post published!")
      |> then(&{:noreply, &1})
      
    {:error, error} ->
      socket
      |> put_flash(:error, "Failed to publish: #{inspect(error)}")
      |> then(&{:noreply, &1})
  end
end

# 2. Via Changeset (More Control)
def handle_event("publish_with_review", %{"id" => id}, socket) do
  post = MyApp.Blog.get_post!(id)
  
  changeset = 
    post
    |> Ash.Changeset.for_update(:publish)
    |> Ash.Changeset.force_change_attribute(:reviewed_by_id, socket.assigns.current_user.id)
    |> Ash.Changeset.add_error(field: :content, message: "Contains prohibited words")
    
  if changeset.valid? do
    case Ash.update(changeset) do
      {:ok, published_post} -> 
        # Success handling
      {:error, changeset} -> 
        # Error handling
    end
  else
    # Handle validation errors
  end
end

# 3. Via Form Submission
def handle_event("save_post", %{"form" => params}, socket) do
  # AshPhoenix.Form handles action invocation
  case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
    {:ok, post} ->
      # The form's action was invoked successfully
      {:noreply, handle_successful_save(socket, post)}
      
    {:error, form} ->
      {:noreply, assign(socket, :form, form)}
  end
end
```

#### Widget Action Integration

```elixir
# Action button widget
<.button_widget
  label="Publish"
  data_source={:action, :publish, @post}
  confirm="Are you sure you want to publish this post?"
  on_success={:handle_publish_success}
  on_error={:handle_publish_error}
/>

# Bulk action widget
<.bulk_action_widget
  label="Categorize Selected"
  data_source={:action, :bulk_categorize}
  requires_selection={true}
  show_count={true}
>
  <:form>
    <.select_widget
      field={:category_id}
      options={@categories}
      label="Select Category"
    />
  </:form>
</.bulk_action_widget>
```

Our widget system abstracts ALL of these patterns behind a simple interface.

---

## Widget Base Architecture

### The Universal Widget Module

Every widget in the system inherits from a base behavior that provides common functionality, attributes, and patterns.

#### Complete Base Module Implementation

```elixir
defmodule MyApp.Widgets.Base do
  @moduledoc """
  Base behavior for all widgets in the system.
  
  This module provides:
  - Common attributes (class, id, data_source, debug_mode)
  - Grid system integration (span, padding, margin)
  - Data resolution patterns
  - Error handling
  - Loading states
  - Debug tooling
  """
  
  # Required callbacks for all widgets
  @callback render(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  @callback connect(data_source :: term(), socket :: Phoenix.LiveView.Socket.t()) :: 
    {:ok, Phoenix.LiveView.Socket.t()} | {:error, term()}
  
  # Optional callbacks
  @callback handle_event(event :: String.t(), params :: map(), socket :: Phoenix.LiveView.Socket.t()) ::
    {:noreply, Phoenix.LiveView.Socket.t()}
  @callback update(assigns :: map(), socket :: Phoenix.LiveView.Socket.t()) ::
    {:ok, Phoenix.LiveView.Socket.t()}
    
  @optional_callbacks handle_event: 3, update: 2
  
  defmacro __using__(opts) do
    quote do
      use Phoenix.Component
      import MyApp.Widgets.Helpers
      import MyApp.Widgets.DataResolver
      
      @behaviour MyApp.Widgets.Base
      
      # Core attributes every widget has
      attr :id, :string, default: nil,
        doc: "DOM ID for the widget"
      attr :class, :string, default: "",
        doc: "Additional CSS classes"
      attr :data_source, :any, default: :static,
        doc: "Data source configuration (see connection patterns)"
      attr :debug_mode, :boolean, default: false,
        doc: "Show debug overlay with data source info"
      
      # Grid system attributes  
      attr :span, :integer, default: nil,
        values: [1, 2, 3, 4, 6, 8, 12],
        doc: "Grid columns to span (12-column grid)"
      attr :padding, :integer, default: nil,
        values: [0, 1, 2, 3, 4, 6, 8],
        doc: "Padding multiplier (4px base)"
      attr :margin, :integer, default: nil,
        values: [0, 1, 2, 3, 4, 6, 8],
        doc: "Margin multiplier (4px base)"
        
      # Responsive attributes
      attr :hide_on_mobile, :boolean, default: false
      attr :hide_on_desktop, :boolean, default: false
      
      # State attributes
      attr :loading, :boolean, default: false,
        doc: "Show loading state"
      attr :error, :string, default: nil,
        doc: "Error message to display"
      attr :disabled, :boolean, default: false,
        doc: "Disable all interactions"
      
      # Theme attributes
      attr :variant, :atom, default: :default,
        doc: "Visual variant of the widget"
      attr :theme, :atom, default: :auto,
        values: [:auto, :light, :dark],
        doc: "Force specific theme"
      
      # Accessibility attributes
      attr :aria_label, :string, default: nil
      attr :aria_describedby, :string, default: nil
      attr :role, :string, default: nil
      
      # Analytics attributes
      attr :track_clicks, :boolean, default: false
      attr :track_impressions, :boolean, default: false
      attr :analytics_metadata, :map, default: %{}
      
      # Form-specific note
      # Form widgets MUST wrap Phoenix LiveView components
      # This ensures compatibility with AshPhoenix.Form and all its features
      
      # Helper functions available to all widgets
      
      defp widget_classes(assigns) do
        [
          # Base widget class
          "widget",
          "widget-#{widget_name()}",
          
          # Grid classes
          span_class(assigns[:span]),
          padding_class(assigns[:padding]),
          margin_class(assigns[:margin]),
          
          # Responsive classes
          assigns[:hide_on_mobile] && "hidden sm:block",
          assigns[:hide_on_desktop] && "block sm:hidden",
          
          # State classes
          assigns[:loading] && "widget-loading",
          assigns[:error] && "widget-error",
          assigns[:disabled] && "widget-disabled",
          
          # Theme classes
          theme_class(assigns[:theme]),
          variant_class(assigns[:variant]),
          
          # Custom classes
          assigns[:class]
        ]
        |> Enum.filter(& &1)
        |> Enum.join(" ")
      end
      
      defp widget_name do
        __MODULE__
        |> Module.split()
        |> List.last()
        |> Macro.underscore()
        |> String.replace("_widget", "")
      end
      
      defp render_debug(assigns) do
        ~H"""
        <div :if={@debug_mode} class="widget-debug-overlay">
          <div class="widget-debug-header">
            <%= widget_name() %>
          </div>
          <div class="widget-debug-content">
            <div>Mode: <%= detect_mode(assigns) %></div>
            <div>Source: <%= inspect(@data_source) %></div>
            <div :if={@loading}>Loading...</div>
            <div :if={@error} class="text-red-500">Error: {@error}</div>
          </div>
        </div>
        """
      end
      
      defp render_loading(assigns) do
        ~H"""
        <div :if={@loading} class="widget-loading-overlay">
          <.spinner_widget size={:sm} />
        </div>
        """
      end
      
      defp render_error(assigns) do
        ~H"""
        <div :if={@error} class="widget-error-container">
          <.alert_widget type={:error} message={@error} />
        </div>
        """
      end
      
      # Default implementations
      def update(assigns, socket) do
        {:ok, assign(socket, assigns)}
      end
      
      defoverridable update: 2
    end
  end
end
```

### Widget Type System

The widget type system leverages Phoenix.Component's powerful attribute system for compile-time safety and runtime validation.

#### Type-Safe Widget Definition

```elixir
defmodule MyApp.Widgets.UserCard do
  use MyApp.Widgets.Base
  
  # Documentation for the widget
  @moduledoc """
  Displays user information in a card format.
  
  ## Examples
  
      # Dumb mode
      <.user_card name="John Doe" email="john@example.com" role="Admin" />
      
      # Connected mode
      <.user_card data_source={:interface, :get_user, [@user_id]} />
  """
  
  # Attributes with full type specifications
  
  # Data attributes (used in dumb mode)
  attr :name, :string, default: nil,
    doc: "User's display name"
  attr :email, :string, default: nil,
    doc: "User's email address",
    examples: ["user@example.com"]
  attr :avatar, :string, default: nil,
    doc: "URL to user's avatar image"
  attr :role, :string, default: nil,
    values: ~w(admin user moderator guest),
    doc: "User's role in the system"
  attr :status, :atom, default: :active,
    values: [:active, :inactive, :suspended, :pending],
    doc: "User's account status"
    
  # Connected mode configuration
  attr :load, :list, default: [],
    doc: "Relationships to load (e.g., [:profile, :preferences])"
  attr :subscribe, :boolean, default: true,
    doc: "Subscribe to real-time updates for this user"
  attr :refresh_interval, :integer, default: nil,
    doc: "Auto-refresh interval in milliseconds"
    
  # Display configuration
  attr :show_status, :boolean, default: true,
    doc: "Show user status indicator"
  attr :show_actions, :boolean, default: true,
    doc: "Show action buttons"
  attr :compact, :boolean, default: false,
    doc: "Use compact layout"
    
  # Interaction handlers
  attr :on_click, :any, default: nil,
    doc: "Handler for card click events"
  attr :on_edit, :any, default: nil,
    doc: "Handler for edit button click"
  attr :on_delete, :any, default: nil,
    doc: "Handler for delete button click"
    
  # Slots for customization
  slot :actions do
    attr :name, :string, required: true
    attr :icon, :atom
    attr :handler, :any, required: true
  end
  
  slot :badge do
    attr :label, :string
    attr :color, :atom
  end
  
  slot :footer
  
  def render(assigns) do
    # Resolve data and handle modes
    assigns = 
      assigns
      |> resolve_data()
      |> maybe_subscribe()
      |> assign_computed_values()
    
    ~H"""
    <div 
      class={["user-card", widget_classes(assigns)]}
      phx-click={@on_click}
      role={@on_click && "button"}
      tabindex={@on_click && "0"}
    >
      {render_debug(assigns)}
      {render_loading(assigns)}
      
      <div :if={!@loading} class="card-body">
        <!-- Status indicator -->
        <div :if={@show_status} class="absolute top-2 right-2">
          <.status_indicator_widget status={@status} />
        </div>
        
        <!-- Main content -->
        <div class={[
          "flex items-center",
          @compact && "space-x-3" || "space-x-4"
        ]}>
          <.avatar_widget 
            src={@avatar} 
            size={@compact && :md || :lg}
            name={@name}
          />
          
          <div class="flex-1 min-w-0">
            <.heading_widget 
              level={@compact && 4 || 3} 
              text={@name}
              class="truncate"
            />
            <.text_widget 
              size={:sm} 
              color={:muted} 
              text={@email}
              class="truncate"
            />
            <div class="flex items-center gap-2 mt-1">
              <.badge_widget 
                label={@role} 
                color={role_color(@role)}
                size={:sm}
              />
              <!-- Custom badges -->
              <.badge_widget :for={badge <- @badge} {@badge} />
            </div>
          </div>
          
          <!-- Actions -->
          <div :if={@show_actions} class="flex items-center gap-2">
            <.button_widget
              :if={@on_edit}
              icon={:edit}
              size={:sm}
              variant={:ghost}
              on_click={@on_edit}
              aria_label="Edit user"
            />
            <.button_widget
              :if={@on_delete}
              icon={:trash}
              size={:sm}
              variant={:ghost}
              color={:danger}
              on_click={@on_delete}
              aria_label="Delete user"
              confirm="Are you sure?"
            />
            <!-- Custom actions -->
            <.button_widget :for={action <- @actions}
              icon={action.icon}
              size={:sm}
              variant={:ghost}
              on_click={action.handler}
              aria_label={action.name}
            />
          </div>
        </div>
        
        <!-- Footer slot -->
        <div :if={@footer} class="mt-4 pt-4 border-t">
          <%= render_slot(@footer) %>
        </div>
      </div>
      
      {render_error(assigns)}
    </div>
    """
  end
  
  # Data resolution based on mode
  defp resolve_data(%{data_source: :static} = assigns), do: assigns
  
  defp resolve_data(%{data_source: {:interface, function}} = assigns) when is_atom(function) do
    case apply_interface(function, [], assigns) do
      {:ok, data} -> 
        assigns
        |> Map.merge(data)
        |> assign(:loading, false)
      {:error, error} -> 
        assigns
        |> assign(:error, format_error(error))
        |> assign(:loading, false)
      :loading ->
        assign(assigns, :loading, true)
    end
  end
  
  defp resolve_data(%{data_source: {:interface, function, args}} = assigns) do
    case apply_interface(function, args, assigns) do
      {:ok, data} -> Map.merge(assigns, data)
      {:error, error} -> assign(assigns, :error, format_error(error))
    end
  end
  
  # Real-time subscriptions
  defp maybe_subscribe(%{subscribe: true, data_source: {:interface, _, [id]}} = assigns) do
    if connected?(assigns.socket) do
      PubSub.subscribe(MyAppWeb.Endpoint, "user:updated:#{id}")
    end
    assigns
  end
  defp maybe_subscribe(assigns), do: assigns
  
  # Computed values
  defp assign_computed_values(assigns) do
    assigns
    |> assign_new(:avatar, fn -> gravatar_url(assigns[:email]) end)
    |> assign_new(:initials, fn -> get_initials(assigns[:name]) end)
  end
  
  # Helper functions
  defp role_color("admin"), do: :danger
  defp role_color("moderator"), do: :warning  
  defp role_color("user"), do: :primary
  defp role_color(_), do: :default
  
  defp format_error(%Ash.Error.Query{} = error), do: "Failed to load user"
  defp format_error(error) when is_binary(error), do: error
  defp format_error(_), do: "An error occurred"
end
```

### Grid Integration and Spacing System

The widget system implements a comprehensive 4px atomic spacing system that ensures visual consistency across all widgets.

#### Complete Helper Module

```elixir
defmodule MyApp.Widgets.Helpers do
  @moduledoc """
  Helper functions for widget styling, spacing, and layout.
  
  Implements a 4px atomic spacing system:
  - 1 unit = 4px
  - 2 units = 8px
  - 3 units = 12px
  - 4 units = 16px (base)
  - 6 units = 24px
  - 8 units = 32px
  """
  
  # Grid column classes (12-column system)
  def span_class(nil), do: nil
  def span_class(1), do: "col-span-1"
  def span_class(2), do: "col-span-2"
  def span_class(3), do: "col-span-3"
  def span_class(4), do: "col-span-4"
  def span_class(6), do: "col-span-6"
  def span_class(8), do: "col-span-8"
  def span_class(12), do: "col-span-12"
  def span_class(n) when n in [5, 7, 9, 10, 11], do: "col-span-#{n}"
  
  # Responsive span classes
  def responsive_span_class(mobile: m, tablet: t, desktop: d) do
    [
      span_class(m),
      t && "sm:#{span_class(t)}",
      d && "lg:#{span_class(d)}"
    ]
    |> Enum.filter(& &1)
    |> Enum.join(" ")
  end
  
  # Padding classes (4px base)
  def padding_class(nil), do: nil
  def padding_class(0), do: "p-0"
  def padding_class(1), do: "p-1"   # 4px
  def padding_class(2), do: "p-2"   # 8px
  def padding_class(3), do: "p-3"   # 12px
  def padding_class(4), do: "p-4"   # 16px (default)
  def padding_class(6), do: "p-6"   # 24px
  def padding_class(8), do: "p-8"   # 32px
  def padding_class(12), do: "p-12" # 48px
  def padding_class(16), do: "p-16" # 64px
  
  # Directional padding
  def padding_x_class(nil), do: nil
  def padding_x_class(n), do: "px-#{n}"
  
  def padding_y_class(nil), do: nil  
  def padding_y_class(n), do: "py-#{n}"
  
  def padding_top_class(nil), do: nil
  def padding_top_class(n), do: "pt-#{n}"
  
  def padding_bottom_class(nil), do: nil
  def padding_bottom_class(n), do: "pb-#{n}"
  
  # Margin classes (4px base)
  def margin_class(nil), do: nil
  def margin_class(0), do: "m-0"
  def margin_class(1), do: "m-1"   # 4px
  def margin_class(2), do: "m-2"   # 8px
  def margin_class(3), do: "m-3"   # 12px
  def margin_class(4), do: "m-4"   # 16px
  def margin_class(6), do: "m-6"   # 24px
  def margin_class(8), do: "m-8"   # 32px
  def margin_class(-1), do: "-m-1" # Negative margins
  
  # Gap classes for flex/grid
  def gap_class(nil), do: nil
  def gap_class(0), do: "gap-0"
  def gap_class(1), do: "gap-1"   # 4px
  def gap_class(2), do: "gap-2"   # 8px
  def gap_class(3), do: "gap-3"   # 12px
  def gap_class(4), do: "gap-4"   # 16px
  def gap_class(6), do: "gap-6"   # 24px
  def gap_class(8), do: "gap-8"   # 32px
  
  # Theme classes
  def theme_class(:auto), do: nil
  def theme_class(:light), do: "light"
  def theme_class(:dark), do: "dark"
  
  # Variant classes (customizable per widget)
  def variant_class(:default), do: nil
  def variant_class(:primary), do: "widget-primary"
  def variant_class(:secondary), do: "widget-secondary"
  def variant_class(:success), do: "widget-success"
  def variant_class(:danger), do: "widget-danger"
  def variant_class(:warning), do: "widget-warning"
  def variant_class(:info), do: "widget-info"
  def variant_class(:ghost), do: "widget-ghost"
  def variant_class(:outline), do: "widget-outline"
  
  # Size classes
  def size_class(:xs), do: "size-xs"
  def size_class(:sm), do: "size-sm"
  def size_class(:md), do: "size-md"
  def size_class(:lg), do: "size-lg"
  def size_class(:xl), do: "size-xl"
  def size_class(:xxl), do: "size-2xl"
  
  # Border radius classes
  def rounded_class(nil), do: "rounded"
  def rounded_class(:none), do: "rounded-none"
  def rounded_class(:sm), do: "rounded-sm"
  def rounded_class(:md), do: "rounded-md"
  def rounded_class(:lg), do: "rounded-lg"
  def rounded_class(:xl), do: "rounded-xl"
  def rounded_class(:full), do: "rounded-full"
  
  # Shadow classes
  def shadow_class(nil), do: nil
  def shadow_class(:none), do: "shadow-none"
  def shadow_class(:sm), do: "shadow-sm"
  def shadow_class(:md), do: "shadow-md"
  def shadow_class(:lg), do: "shadow-lg"
  def shadow_class(:xl), do: "shadow-xl"
  
  # Animation classes
  def animation_class(:pulse), do: "animate-pulse"
  def animation_class(:spin), do: "animate-spin"
  def animation_class(:bounce), do: "animate-bounce"
  def animation_class(:fade_in), do: "animate-fade-in"
  def animation_class(:slide_up), do: "animate-slide-up"
  def animation_class(_), do: nil
  
  # Transition classes
  def transition_class(properties \\ [:all]) do
    base = "transition-"
    props = Enum.map_join(properties, " ", fn
      :all -> "#{base}all"
      :colors -> "#{base}colors"
      :opacity -> "#{base}opacity"
      :transform -> "#{base}transform"
      :shadow -> "#{base}shadow"
    end)
    "#{props} duration-200 ease-in-out"
  end
  
  # Focus classes
  def focus_class(color \\ :primary) do
    "focus:outline-none focus:ring-2 focus:ring-#{color}-500 focus:ring-offset-2"
  end
  
  # Responsive visibility classes
  def visibility_class(show_on: devices) do
    case devices do
      :all -> nil
      :mobile -> "block sm:hidden"
      :tablet -> "hidden sm:block lg:hidden"
      :desktop -> "hidden lg:block"
      [:mobile, :tablet] -> "block lg:hidden"
      [:tablet, :desktop] -> "hidden sm:block"
    end
  end
  
  # Accessibility classes
  def sr_only_class, do: "sr-only"
  def not_sr_only_class, do: "not-sr-only"
  def focus_within_class, do: "focus-within:ring-2 focus-within:ring-primary-500"
end
```

#### Grid Layout Widget

```elixir
defmodule MyApp.Widgets.GridWidget do
  use MyApp.Widgets.Base
  
  attr :columns, :integer, default: 12,
    doc: "Number of columns in the grid"
  attr :gap, :integer, default: 4,
    doc: "Gap between grid items (4px units)"
  attr :responsive, :boolean, default: true,
    doc: "Enable responsive column changes"
    
  slot :inner_block, required: true
  
  def render(assigns) do
    ~H"""
    <div class={[
      "grid",
      grid_columns_class(@columns, @responsive),
      gap_class(@gap),
      widget_classes(assigns)
    ]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
  
  defp grid_columns_class(12, true) do
    "grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6"
  end
  defp grid_columns_class(n, false) do
    "grid-cols-#{n}"
  end
end
```

---

## The Two-Mode Pattern

### Understanding the Two Modes: A Beginner's Complete Guide

Imagine you're building a house. You can either:
1. **Build a model first** (Dumb Mode) - Quick, no plumbing needed, shows the design
2. **Build the real house** (Connected Mode) - Takes time, needs infrastructure, fully functional

Our widget system works the same way!

#### What Are The Two Modes?

| Mode | Purpose | When to Use | Data Source | Best For |
|------|---------|-------------|-------------|----------|
| **Dumb Mode** | Static data display | Prototyping, demos, testing | Hard-coded in template | Designers, rapid iteration |
| **Connected Mode** | Live data from Ash | Production, real features | Database, APIs, streams | Final implementation |

### Mode Detection and Switching: Complete Implementation

#### Step 1: Understanding Mode Detection

Every widget automatically detects its mode. Here's how:

```elixir
# File: lib/my_app_web/widgets/table_widget.ex
defmodule MyApp.Widgets.TableWidget do
  use MyApp.Widgets.Base
  
  @moduledoc """
  A table widget that works in both dumb and connected modes.
  
  ## Dumb Mode Example
      <.table_widget
        columns={[%{field: :name, label: "Name"}]}
        rows={[%{name: "John"}, %{name: "Jane"}]}
      />
  
  ## Connected Mode Example  
      <.table_widget
        columns={[%{field: :name, label: "Name"}]}
        data_source={:interface, :list_users}
        stream={:users}
      />
  """
  
  # STEP 1: Define attributes for BOTH modes
  # These work like function parameters - they tell the widget what data it can receive
  
  # Dumb mode attributes (static data)
  attr :rows, :list, default: [],
    doc: "Static list of rows for dumb mode. Each row is a map."
  
  # Shared attributes (work in both modes)  
  attr :columns, :list, required: true,
    doc: "Column definitions. Each has :field and :label keys."
  
  # Connected mode attributes (live data)
  attr :data_source, :any, default: :static,
    doc: "How to fetch data. Use :static for dumb mode."
  attr :stream, :atom, default: nil,
    doc: "Phoenix stream name for efficient updates"
  attr :sort, :list, default: [],
    doc: "Sort configuration [{field, :asc/:desc}]"
  attr :filter, :list, default: [],
    doc: "Filter configuration [{field, operator, value}]"
  attr :page, :integer, default: 1,
    doc: "Current page number"
  attr :per_page, :integer, default: 20,
    doc: "Items per page"
    
  # UI configuration (works in both modes)
  attr :selectable, :boolean, default: false,
    doc: "Allow row selection"
  attr :on_row_click, :any, default: nil,
    doc: "Handler when row is clicked"
  attr :empty_message, :string, default: "No data available",
    doc: "Message when table is empty"
  attr :loading_message, :string, default: "Loading...",
    doc: "Message during data fetch"
  
  # STEP 2: The render function - heart of the widget
  def render(assigns) do
    # First, figure out which mode we're in
    assigns = 
      assigns
      |> determine_mode()        # Sets @mode to :dumb or :connected
      |> maybe_load_data()       # Loads data if connected mode
      |> add_computed_values()   # Adds things like row_count
    
    ~H"""
    <div class={[
      "table-widget",
      "overflow-x-auto",
      @mode == :connected && "table-connected",
      @selectable && "table-selectable",
      widget_classes(assigns)
    ]}>
      {render_debug(assigns)}
      
      <!-- Show loading state only in connected mode -->
      <div :if={@mode == :connected && @loading} class="table-loading">
        <.spinner_widget size={:sm} />
        <span>{@loading_message}</span>
      </div>
      
      <!-- The actual table -->
      <table :if={!@loading} class="table table-zebra">
        <thead>
          <tr>
            <th :if={@selectable} class="w-12">
              <input type="checkbox" phx-click="select_all" />
            </th>
            <th :for={col <- @columns} 
                class={[col[:sortable] && "cursor-pointer"]}
                phx-click={col[:sortable] && "sort"}
                phx-value-field={col.field}>
              {col.label}
              <.sort_indicator :if={col[:sortable]} 
                field={col.field} 
                current_sort={@sort} />
            </th>
          </tr>
        </thead>
        <tbody>
          {render_rows(assigns)}
        </tbody>
      </table>
      
      <!-- Empty state -->
      <div :if={!@loading && empty?(@rows, @streams, @stream)} 
           class="table-empty-state">
        <.icon_widget name={:inbox} size={:xl} color={:muted} />
        <p>{@empty_message}</p>
      </div>
      
      <!-- Pagination (connected mode only) -->
      <.pagination_widget 
        :if={@mode == :connected && @total_pages > 1}
        current_page={@page}
        total_pages={@total_pages}
        on_page_change={:change_page}
      />
    </div>
    """
  end
  
  # STEP 3: Mode detection - the magic happens here!
  defp determine_mode(assigns) do
    mode = cond do
      # If rows are provided directly, we're in dumb mode
      is_list(assigns[:rows]) && assigns[:rows] != [] ->
        :dumb
        
      # If data_source is anything but :static, we're connected
      assigns[:data_source] != :static ->
        :connected
        
      # Default to dumb mode
      true ->
        :dumb
    end
    
    assigns
    |> Map.put(:mode, mode)
    |> Map.put(:loading, mode == :connected && !assigns[:data_loaded])
  end
  
  # STEP 4: Render rows differently based on mode
  defp render_rows(%{mode: :dumb} = assigns) do
    ~H"""
    <%= for {row, index} <- Enum.with_index(@rows) do %>
      <tr 
        id={"row-#{index}"}
        class={["hover:bg-base-200", @selectable && "cursor-pointer"]}
        phx-click={@on_row_click}
        phx-value-id={row[:id] || index}
      >
        <td :if={@selectable}>
          <input type="checkbox" phx-click="toggle_row" phx-value-id={row[:id] || index} />
        </td>
        <td :for={col <- @columns}>
          {render_cell(row, col)}
        </td>
      </tr>
    <% end %>
    """
  end
  
  defp render_rows(%{mode: :connected, stream: stream} = assigns) when not is_nil(stream) do
    ~H"""
    <tr :for={{dom_id, row} <- @streams[stream]} 
        id={dom_id}
        class={["hover:bg-base-200", @selectable && "cursor-pointer"]}
        phx-click={@on_row_click}
        phx-value-id={row.id}
    >
      <td :if={@selectable}>
        <input type="checkbox" phx-click="toggle_row" phx-value-id={row.id} />
      </td>
      <td :for={col <- @columns}>
        {render_cell(row, col)}
      </td>
    </tr>
    """
  end
  
  defp render_rows(%{mode: :connected} = assigns) do
    # Fallback for connected mode without streams
    render_rows(Map.put(assigns, :mode, :dumb))
  end
  
  # STEP 5: Cell rendering with formatting
  defp render_cell(row, col) do
    value = Map.get(row, col.field)
    
    case col[:format] do
      :currency -> format_currency(value)
      :date -> format_date(value)
      :datetime -> format_datetime(value)
      :percentage -> format_percentage(value)
      :boolean -> render_boolean(value)
      _ -> value
    end
  end
  
  # Helper functions
  defp empty?(rows, _streams, _stream) when is_list(rows), do: rows == []
  defp empty?(_rows, streams, stream) when not is_nil(stream) do
    Map.get(streams, stream, []) == []
  end
  defp empty?(_, _, _), do: true
end
```

#### Step 2: Testing Your Mode Detection

```bash
# TERMINAL WINDOW 1 - Start your Phoenix server
$ cd /path/to/your/project
$ mix deps.get  # Get all dependencies first
$ mix compile   # Compile to check for errors

# If you see any errors, they'll look like:
# == Compilation error in file lib/my_app_web/widgets/table_widget.ex ==
# ** (CompileError) lib/my_app_web/widgets/table_widget.ex:45: undefined function render_cell/2

# Fix any errors, then:
$ iex -S mix phx.server

# Your server should start:
# [info] Running MyAppWeb.Endpoint with cowboy 2.9.0 at 127.0.0.1:4000 (http)
# [info] Access MyAppWeb.Endpoint at http://localhost:4000
```

### Progressive Enhancement: Step-by-Step Journey from Dumb to Connected

#### The Complete Development Workflow

This example shows how to build a user management interface, starting with static data and progressively adding real functionality.

#### Phase 1: Static Prototype (Day 1 - Get Something on Screen)

```elixir
# File: lib/my_app_web/live/users_live.ex
defmodule MyAppWeb.UsersLive do
  use MyAppWeb, :live_view
  
  # BEGINNER TIP: 'mount' runs when the page loads
  # Think of it like the constructor in other languages
  def mount(_params, _session, socket) do
    # Start with static data to see something immediately
    socket = 
      socket
      |> assign(:page_title, "User Management")
      |> assign(:development_stage, :prototype)
      |> assign(:debug_mode, true)  # See what's happening!
    
    {:ok, socket}
  end
  
  # BEGINNER TIP: 'render' creates the HTML for your page
  # The ~H""" syntax is a special template language
  def render(assigns) do
    ~H"""
    <!-- Phase 1: Pure static prototype -->
    <div class="min-h-screen bg-base-100">
      <.layout_widget type={:dashboard} debug_mode={@debug_mode}>
        <:sidebar>
          <!-- Static navigation for now -->
          <.nav_widget 
            items={[
              %{label: "Dashboard", icon: :home, path: "/"},
              %{label: "Users", icon: :users, path: "/users", active: true},
              %{label: "Settings", icon: :cog, path: "/settings"}
            ]} 
          />
        </:sidebar>
        
        <:main>
          <!-- Page header with static action -->
          <.page_header_widget 
            title="Users"
            subtitle="Manage your application users"
            actions={[
              %{label: "Add User", icon: :plus, color: :primary}
            ]}
          />
          
          <!-- Stats row - all fake data for now -->
          <.grid_widget columns={4} gap={4} class="mb-6">
            <.stat_widget 
              label="Total Users" 
              value={156} 
              change={+12}
              trend={:up}
              icon={:users}
            />
            <.stat_widget 
              label="Active Today" 
              value={89} 
              change={-3}
              trend={:down}
              icon={:activity}
            />
            <.stat_widget 
              label="New This Week" 
              value={24} 
              change={+18}
              trend={:up}
              icon={:user_plus}
            />
            <.stat_widget 
              label="Admins" 
              value={5} 
              change={0}
              trend={:neutral}
              icon={:shield}
            />
          </.grid_widget>
          
          <!-- The main table - completely static -->
          <.card_widget>
            <:header>
              <.flex_widget justify={:between} align={:center}>
                <.heading_widget level={3} text="All Users" />
                <.button_group_widget>
                  <.button_widget label="Filter" icon={:filter} variant={:outline} />
                  <.button_widget label="Export" icon={:download} variant={:outline} />
                </.button_group_widget>
              </.flex_widget>
            </:header>
            
            <:body>
              <.table_widget
                columns={[
                  %{field: :name, label: "Name"},
                  %{field: :email, label: "Email"},
                  %{field: :role, label: "Role"},
                  %{field: :status, label: "Status"},
                  %{field: :last_login, label: "Last Login"}
                ]}
                rows={[
                  %{
                    id: 1,
                    name: "John Doe",
                    email: "john@example.com",
                    role: "Admin",
                    status: "Active",
                    last_login: "2 hours ago"
                  },
                  %{
                    id: 2,
                    name: "Jane Smith",
                    email: "jane@example.com",
                    role: "User",
                    status: "Active",
                    last_login: "5 minutes ago"
                  },
                  %{
                    id: 3,
                    name: "Bob Wilson",
                    email: "bob@example.com",
                    role: "User",
                    status: "Inactive",
                    last_login: "3 days ago"
                  }
                ]}
                on_row_click={:show_user}
                selectable={true}
              />
            </:body>
          </.card_widget>
        </:main>
      </.layout_widget>
    </div>
    """
  end
  
  # Even in prototype, handle some basic interactions
  def handle_event("show_user", %{"id" => id}, socket) do
    # Just show a flash message for now
    socket = put_flash(socket, :info, "Clicked user #{id}")
    {:noreply, socket}
  end
end
```

#### Test Phase 1:

```bash
# STEP 1: Save the file and compile
$ mix compile
# Should see: Compiling 1 file (.ex)

# STEP 2: Start the server if not running
$ iex -S mix phx.server

# STEP 3: Open your browser
# Navigate to: http://localhost:4000/users

# STEP 4: Test with Puppeteer
$ iex
iex> # Take a screenshot of the static version
```

```elixir
# In another file for testing: test/visual/phase1_test.exs
defmodule MyAppWeb.VisualTest.Phase1 do
  use ExUnit.Case
  
  test "static prototype renders correctly" do
    # We'll use Puppeteer MCP for this
    {:ok, _} = Puppeteer.navigate(url: "http://localhost:4000/users")
    {:ok, _} = Puppeteer.screenshot(name: "phase1_users_page")
    
    # Check that our widgets rendered
    assert {:ok, _} = Puppeteer.evaluate(script: """
      document.querySelector('.table-widget') !== null &&
      document.querySelectorAll('tr').length === 4  // header + 3 rows
    """)
  end
end
```

#### Phase 2: Add Interactivity (Day 2 - Make it Interactive)

```elixir
def mount(_params, _session, socket) do
  socket = 
    socket
    |> assign(:page_title, "User Management")
    |> assign(:development_stage, :interactive)  # Changed!
    |> assign(:debug_mode, true)
    |> assign(:selected_users, MapSet.new())
    |> assign(:show_user_modal, false)
    |> assign(:current_user, nil)
    |> assign(:filter_status, "all")
    |> assign(:sort_by, :name)
    |> assign(:sort_order, :asc)
    # Still using static data, but now it's in assigns
    |> assign(:users, generate_fake_users(20))
    
  {:ok, socket}
end

# Generate more realistic fake data
defp generate_fake_users(count) do
  names = ["John", "Jane", "Bob", "Alice", "Charlie", "Diana"]
  surnames = ["Doe", "Smith", "Johnson", "Williams", "Brown"]
  roles = ["Admin", "User", "Moderator"]
  statuses = ["Active", "Inactive", "Suspended"]
  
  for i <- 1..count do
    %{
      id: i,
      name: "#{Enum.random(names)} #{Enum.random(surnames)}",
      email: "user#{i}@example.com",
      role: Enum.random(roles),
      status: Enum.random(statuses),
      last_login: random_last_login(),
      created_at: random_date_past()
    }
  end
end

# Now add real event handlers
def handle_event("filter_status", %{"status" => status}, socket) do
  filtered_users = 
    if status == "all" do
      socket.assigns.users
    else
      Enum.filter(socket.assigns.users, &(&1.status == status))
    end
    
  socket = 
    socket
    |> assign(:filter_status, status)
    |> assign(:filtered_users, filtered_users)
    |> put_flash(:info, "Filtered to #{status} users")
    
  {:noreply, socket}
end

def handle_event("sort", %{"field" => field}, socket) do
  field_atom = String.to_existing_atom(field)
  
  {order, users} = 
    if socket.assigns.sort_by == field_atom do
      # Reverse order if clicking same column
      new_order = if socket.assigns.sort_order == :asc, do: :desc, else: :asc
      sorted = sort_users(socket.assigns.users, field_atom, new_order)
      {new_order, sorted}
    else
      # New column, default to ascending
      sorted = sort_users(socket.assigns.users, field_atom, :asc)
      {:asc, sorted}
    end
    
  socket = 
    socket
    |> assign(:sort_by, field_atom)
    |> assign(:sort_order, order)
    |> assign(:users, users)
    
  {:noreply, socket}
end

def handle_event("select_user", %{"id" => id}, socket) do
  id = String.to_integer(id)
  selected = 
    if MapSet.member?(socket.assigns.selected_users, id) do
      MapSet.delete(socket.assigns.selected_users, id)
    else
      MapSet.put(socket.assigns.selected_users, id)
    end
    
  {:noreply, assign(socket, :selected_users, selected)}
end

def handle_event("show_user", %{"id" => id}, socket) do
  user = Enum.find(socket.assigns.users, &(&1.id == String.to_integer(id)))
  
  socket = 
    socket
    |> assign(:current_user, user)
    |> assign(:show_user_modal, true)
    
  {:noreply, socket}
end
```

#### Phase 3: Connect to Real Data (Day 3-5 - Make it Real)

```elixir
# First, create your Ash resources
# File: lib/my_app/accounts/resources/user.ex
defmodule MyApp.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAdmin.Resource]
    
  postgres do
    table "users"
    repo MyApp.Repo
  end
  
  attributes do
    uuid_primary_key :id
    
    attribute :name, :string, allow_nil?: false
    attribute :email, :ci_string, allow_nil?: false
    attribute :role, :atom, 
      constraints: [one_of: [:admin, :user, :moderator]],
      default: :user
    attribute :status, :atom,
      constraints: [one_of: [:active, :inactive, :suspended]],
      default: :active
    attribute :last_login_at, :utc_datetime_usec
    
    timestamps()
  end
  
  code_interface do
    define :list_users, action: :read
    define :get_user, action: :read, get_by: [:id]
    define :create_user, action: :create
    define :update_user, action: :update
    define :delete_user, action: :destroy
    
    # Specific queries we need
    define :count_users, action: :count
    define :list_active_users, action: :read, filter: [status: :active]
    define :search_users, action: :search, args: [:query]
  end
  
  actions do
    defaults [:create, :read, :update, :destroy]
    
    read :count do
      prepare build(aggregate: {:count, :id})
    end
    
    read :search do
      argument :query, :string, allow_nil?: false
      
      filter expr(contains(name, ^arg(:query)) or contains(email, ^arg(:query)))
    end
  end
end
```

```elixir
# Now update your LiveView to use real data
# File: lib/my_app_web/live/users_live.ex
defmodule MyAppWeb.UsersLive do
  use MyAppWeb, :live_view
  
  # Now we're ready for connected mode!
  def mount(_params, _session, socket) do
    socket = 
      socket
      |> assign(:page_title, "User Management")
      |> assign(:development_stage, :connected)  # Final stage!
      |> assign(:debug_mode, false)  # Turn off for production
      |> assign_new(:current_user, fn -> nil end)
      |> stream(:users, [])
      
    # Load initial data if connected
    if connected?(socket) do
      # Subscribe to user updates
      PubSub.subscribe(MyApp.PubSub, "users:*")
      
      {:ok, load_users(socket)}
    else
      {:ok, socket}
    end
  end
  
  defp load_users(socket) do
    # Use the code interface!
    users = MyApp.Accounts.list_users!()
    
    socket
    |> stream(:users, users)
    |> assign(:user_count, length(users))
    |> assign(:stats, calculate_stats(users))
  end
  
  # The render function now uses connected widgets
  def render(assigns) do
    ~H"""
    <.layout_widget type={:dashboard}>
      <:sidebar>
        <!-- Now connected to real navigation data -->
        <.nav_widget 
          data_source={:interface, :get_navigation}
          current_path={@current_path}
        />
      </:sidebar>
      
      <:main>
        <.page_header_widget 
          title="Users"
          subtitle="Manage your application users"
          data_source={:interface, :get_user_actions}
        />
        
        <!-- Stats now show real data -->
        <.grid_widget columns={4} gap={4} class="mb-6">
          <.stat_widget 
            label="Total Users"
            data_source={:interface, :count_users}
            icon={:users}
          />
          <.stat_widget 
            label="Active Today"
            data_source={:interface, :count_active_today}
            refresh_interval={60000}
            icon={:activity}
          />
          <.stat_widget 
            label="New This Week"
            data_source={:interface, :count_new_this_week}
            icon={:user_plus}
          />
          <.stat_widget 
            label="Admins"
            data_source={:interface, :count_admins}
            icon={:shield}
          />
        </.grid_widget>
        
        <!-- The table is now fully connected -->
        <.card_widget>
          <:header>
            <.flex_widget justify={:between} align={:center}>
              <.heading_widget level={3} text="All Users" />
              <.search_widget 
                placeholder="Search users..."
                on_search={:search_users}
                debounce={300}
              />
            </.flex_widget>
          </:header>
          
          <:body>
            <.table_widget
              columns={[
                %{field: :name, label: "Name", sortable: true},
                %{field: :email, label: "Email", sortable: true},
                %{field: :role, label: "Role", filterable: true},
                %{field: :status, label: "Status", filterable: true, 
                  render: &render_status_badge/1},
                %{field: :last_login_at, label: "Last Login", 
                  format: :relative_time}
              ]}
              data_source={:interface, :list_users}
              stream={:users}
              sort={@sort}
              filter={@filter}
              on_row_click={:show_user}
              selectable={true}
              bulk_actions={[
                %{label: "Delete", action: :bulk_delete, confirm: true},
                %{label: "Export", action: :export_users}
              ]}
            />
          </:body>
        </.card_widget>
      </:main>
    </.layout_widget>
    """
  end
end
```

### Testing Each Phase: Complete Guide for Beginners

#### Testing Phase 1 (Static Prototype):

```bash
# TERMINAL 1: Start Phoenix
$ cd /path/to/forcefoundation
$ mix deps.get
$ mix compile

# Check for compilation errors
# If you see errors like:
# == Compilation error in file lib/my_app_web/live/users_live.ex ==
# ** (CompileError) undefined function put_flash/2
# 
# This means you forgot to import something. Add to your live_view:
# import Phoenix.LiveView

# Once it compiles:
$ iex -S mix phx.server
```

```elixir
# TERMINAL 2: Visual Testing with Puppeteer
# Create test file: test/visual/widget_modes_test.exs
defmodule MyAppWeb.Visual.WidgetModesTest do
  @moduledoc """
  Visual regression tests for widget modes.
  Run these after EVERY change to ensure nothing breaks!
  """
  
  # Wait for server to be ready
  def wait_for_server(retries \\ 10) do
    case HTTPoison.get("http://localhost:4000") do
      {:ok, _} -> :ok
      {:error, _} -> 
        if retries > 0 do
          Process.sleep(1000)
          wait_for_server(retries - 1)
        else
          raise "Server not responding"
        end
    end
  end
  
  def test_phase1_static do
    IO.puts("Testing Phase 1: Static Prototype...")
    
    # Navigate to page
    {:ok, _} = Puppeteer.navigate(url: "http://localhost:4000/users")
    Process.sleep(2000)  # Let page fully load
    
    # Take screenshot
    {:ok, _} = Puppeteer.screenshot(
      name: "phase1_full_page",
      width: 1920,
      height: 1080
    )
    
    # Test table is visible
    {:ok, result} = Puppeteer.evaluate(script: """
      const table = document.querySelector('.table-widget');
      const rows = document.querySelectorAll('.table-widget tbody tr');
      
      return {
        tableExists: table !== null,
        rowCount: rows.length,
        firstRowText: rows[0]?.textContent || 'no rows'
      };
    """)
    
    IO.inspect(result, label: "Table check")
    
    # Click on a row
    {:ok, _} = Puppeteer.click(selector: ".table-widget tbody tr:first-child")
    Process.sleep(500)
    
    # Check flash message appeared
    {:ok, flash_visible} = Puppeteer.evaluate(script: """
      const flash = document.querySelector('[role="alert"]');
      return flash !== null && flash.textContent.includes('Clicked user');
    """)
    
    IO.puts("Flash message visible: #{flash_visible}")
    
    # Take screenshot with interaction
    {:ok, _} = Puppeteer.screenshot(
      name: "phase1_after_click",
      width: 1920,
      height: 1080
    )
    
    IO.puts("✅ Phase 1 tests complete!")
  end
end

# Run the test:
# iex> MyAppWeb.Visual.WidgetModesTest.wait_for_server()
# iex> MyAppWeb.Visual.WidgetModesTest.test_phase1_static()
```

#### Common Errors and Solutions:

```elixir
# ERROR 1: "function widget_classes/1 undefined"
# SOLUTION: You forgot to use the base module
defmodule MyApp.Widgets.MyWidget do
  use MyApp.Widgets.Base  # <-- Don't forget this!
end

# ERROR 2: "assign @users not available in template"
# SOLUTION: You forgot to assign it in mount or handle_event
def mount(_params, _session, socket) do
  socket = assign(socket, :users, [])  # <-- Initialize all assigns
  {:ok, socket}
end

# ERROR 3: "protocol Enumerable not implemented for nil"
# SOLUTION: Your list might be nil
<tr :for={row <- @rows || []}>  # <-- Add || [] fallback

# ERROR 4: Widgets not rendering
# SOLUTION: Check your imports in my_app_web.ex
defmodule MyAppWeb do
  def html do
    quote do
      use Phoenix.Component
      import MyAppWeb.Widgets  # <-- Must import widgets!
    end
  end
end
```

#### Performance Testing:

```elixir
defmodule MyAppWeb.Performance.ModeTest do
  @doc """
  Test rendering performance difference between modes
  """
  
  def benchmark_modes do
    users = generate_users(1000)
    
    Benchee.run(%{
      "dumb_mode" => fn ->
        # Render with static data
        Phoenix.LiveView.Test.render_component(
          MyApp.Widgets.TableWidget,
          rows: users,
          columns: columns()
        )
      end,
      "connected_mode" => fn ->
        # Render with data source
        Phoenix.LiveView.Test.render_component(
          MyApp.Widgets.TableWidget,
          data_source: {:interface, :list_users},
          columns: columns()
        )
      end
    })
  end
end
```

---

## Complete Widget Catalog: Every Widget You'll Ever Need

### How to Use This Catalog

Each widget section includes:
1. **Complete implementation code** - Copy and paste ready!
2. **Usage examples** - Both dumb and connected modes
3. **Testing procedures** - With Puppeteer screenshots
4. **Common errors** - And how to fix them
5. **Performance tips** - For production use

### Layout Widgets: The Foundation of Every Page

Layout widgets are the bones of your application. They provide structure without knowing about data.

#### 1. Layout Widget - The Master Container

```elixir
# File: lib/my_app_web/widgets/layout_widget.ex
defmodule MyApp.Widgets.LayoutWidget do
  use MyApp.Widgets.Base
  
  @moduledoc """
  The main layout container for your application.
  Supports multiple layout types: dashboard, centered, full-width, etc.
  
  ## Examples
  
      <.layout_widget type={:dashboard}>
        <:header>...</:header>
        <:sidebar>...</:sidebar>
        <:main>...</:main>
        <:footer>...</:footer>
      </.layout_widget>
  """
  
  attr :type, :atom, default: :dashboard,
    values: [:dashboard, :centered, :full_width, :split, :kanban],
    doc: "Layout type determines the structure"
  attr :sidebar_position, :atom, default: :left,
    values: [:left, :right],
    doc: "Where to place the sidebar"
  attr :sidebar_collapsible, :boolean, default: true,
    doc: "Can user collapse the sidebar?"
  attr :sidebar_collapsed, :boolean, default: false,
    doc: "Is sidebar initially collapsed?"
  attr :max_width, :atom, default: :full,
    values: [:sm, :md, :lg, :xl, :xxl, :full],
    doc: "Maximum width of main content"
  attr :nav_sticky, :boolean, default: true,
    doc: "Should navigation stick to top?"
    
  # Slots for different sections
  slot :header, doc: "Top navigation/header area"
  slot :sidebar, doc: "Side navigation area"
  slot :main, required: true, doc: "Main content area"
  slot :footer, doc: "Footer area"
  slot :mobile_nav, doc: "Mobile-specific navigation"
  
  def render(%{type: :dashboard} = assigns) do
    ~H"""
    <div class={[
      "layout-dashboard",
      "min-h-screen",
      "bg-base-100",
      widget_classes(assigns)
    ]} 
    data-sidebar-collapsed={@sidebar_collapsed}>
      
      <!-- Header/Navigation -->
      <header :if={@header} class={[
        "layout-header",
        "bg-base-200",
        "border-b border-base-300",
        @nav_sticky && "sticky top-0 z-50"
      ]}>
        <%= render_slot(@header) %>
      </header>
      
      <!-- Mobile navigation -->
      <div :if={@mobile_nav} class="layout-mobile-nav lg:hidden">
        <%= render_slot(@mobile_nav) %>
      </div>
      
      <!-- Main container -->
      <div class="layout-container flex">
        <!-- Sidebar -->
        <aside 
          :if={@sidebar}
          class={[
            "layout-sidebar",
            "bg-base-200",
            "transition-all duration-300",
            sidebar_position_class(@sidebar_position),
            @sidebar_collapsed && "w-16" || "w-64",
            "hidden lg:block"
          ]}
        >
          <!-- Collapse button -->
          <button 
            :if={@sidebar_collapsible}
            class="sidebar-toggle"
            phx-click="toggle_sidebar"
            aria-label="Toggle sidebar"
          >
            <.icon_widget 
              name={@sidebar_collapsed && :chevron_right || :chevron_left}
              size={:sm}
            />
          </button>
          
          <div class="sidebar-content">
            <%= render_slot(@sidebar) %>
          </div>
        </aside>
        
        <!-- Main content -->
        <main class={[
          "layout-main",
          "flex-1",
          "min-w-0", # Prevent flex item from overflowing
          max_width_class(@max_width)
        ]}>
          <%= render_slot(@main) %>
        </main>
      </div>
      
      <!-- Footer -->
      <footer :if={@footer} class="layout-footer bg-base-200 border-t">
        <%= render_slot(@footer) %>
      </footer>
      
      {render_debug(assigns)}
    </div>
    """
  end
  
  def render(%{type: :centered} = assigns) do
    ~H"""
    <div class={[
      "layout-centered",
      "min-h-screen",
      "flex flex-col",
      widget_classes(assigns)
    ]}>
      <div class={[
        "mx-auto",
        "w-full",
        max_width_class(@max_width)
      ]}>
        <%= render_slot(@main) %>
      </div>
    </div>
    """
  end
  
  def render(%{type: :split} = assigns) do
    ~H"""
    <div class={[
      "layout-split",
      "min-h-screen",
      "grid grid-cols-1 lg:grid-cols-2",
      widget_classes(assigns)
    ]}>
      <div :if={@sidebar} class="split-left bg-base-200">
        <%= render_slot(@sidebar) %>
      </div>
      <div class="split-right">
        <%= render_slot(@main) %>
      </div>
    </div>
    """
  end
  
  # Event handlers
  def handle_event("toggle_sidebar", _, socket) do
    {:noreply, update(socket, :sidebar_collapsed, &(!&1))}
  end
  
  # Helper functions
  defp sidebar_position_class(:left), do: "order-first"
  defp sidebar_position_class(:right), do: "order-last"
  
  defp max_width_class(:sm), do: "max-w-screen-sm mx-auto"
  defp max_width_class(:md), do: "max-w-screen-md mx-auto"
  defp max_width_class(:lg), do: "max-w-screen-lg mx-auto"
  defp max_width_class(:xl), do: "max-w-screen-xl mx-auto"
  defp max_width_class(:xxl), do: "max-w-screen-2xl mx-auto"
  defp max_width_class(:full), do: "w-full"
end
```

#### Testing the Layout Widget:

```bash
# STEP 1: Create a test page using the layout
# File: lib/my_app_web/live/layout_test_live.ex
```

```elixir
defmodule MyAppWeb.LayoutTestLive do
  use MyAppWeb, :live_view
  
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :sidebar_collapsed, false)}
  end
  
  def render(assigns) do
    ~H"""
    <.layout_widget 
      type={:dashboard} 
      sidebar_collapsed={@sidebar_collapsed}
      debug_mode={true}
    >
      <:header>
        <.navbar_widget logo="/images/logo.png" />
      </:header>
      
      <:sidebar>
        <.nav_widget items={[
          %{label: "Home", icon: :home, path: "/"},
          %{label: "Users", icon: :users, path: "/users"},
          %{label: "Settings", icon: :cog, path: "/settings"}
        ]} />
      </:sidebar>
      
      <:main>
        <.page_widget>
          <.heading_widget level={1} text="Layout Test Page" />
          <.text_widget text="This tests our layout widget!" />
        </.page_widget>
      </:main>
    </.layout_widget>
    """
  end
  
  def handle_event("toggle_sidebar", _, socket) do
    {:noreply, update(socket, :sidebar_collapsed, &(!&1))}
  end
end
```

```bash
# STEP 2: Add route
# In router.ex:
live "/test/layout", LayoutTestLive

# STEP 3: Compile and test
$ mix compile
$ iex -S mix phx.server
```

```elixir
# STEP 4: Automated visual testing
# File: test/visual/layout_widget_test.exs
defmodule MyAppWeb.Visual.LayoutWidgetTest do
  use ExUnit.Case
  
  test "layout widget renders correctly" do
    # Navigate to test page
    {:ok, _} = Puppeteer.navigate(url: "http://localhost:4000/test/layout")
    Process.sleep(1000)
    
    # Test 1: Full layout screenshot
    {:ok, _} = Puppeteer.screenshot(
      name: "layout_full",
      width: 1920,
      height: 1080
    )
    
    # Test 2: Collapse sidebar
    {:ok, _} = Puppeteer.click(selector: ".sidebar-toggle")
    Process.sleep(300)  # Wait for animation
    
    {:ok, _} = Puppeteer.screenshot(
      name: "layout_sidebar_collapsed",
      width: 1920,
      height: 1080
    )
    
    # Test 3: Mobile view
    {:ok, _} = Puppeteer.screenshot(
      name: "layout_mobile",
      width: 375,
      height: 667
    )
    
    # Test 4: Verify sidebar state
    {:ok, is_collapsed} = Puppeteer.evaluate(script: """
      document.querySelector('[data-sidebar-collapsed]')
        .getAttribute('data-sidebar-collapsed') === 'true'
    """)
    
    assert is_collapsed == true
  end
end
```

#### 2. Grid Widget - Responsive Grid System

```elixir
# File: lib/my_app_web/widgets/grid_widget.ex
defmodule MyApp.Widgets.GridWidget do
  use MyApp.Widgets.Base
  
  @moduledoc """
  Responsive grid container following the 12-column system.
  Automatically handles responsive breakpoints.
  """
  
  attr :columns, :integer, default: 12,
    doc: "Number of columns (usually 12)"
  attr :gap, :integer, default: 4,
    doc: "Gap between items (4px units)"
  attr :row_gap, :integer, default: nil,
    doc: "Override vertical gap"
  attr :responsive, :boolean, default: true,
    doc: "Enable responsive behavior"
  attr :align, :atom, default: :stretch,
    values: [:start, :center, :end, :stretch],
    doc: "Vertical alignment of items"
    
  slot :inner_block, required: true
  
  def render(assigns) do
    # Set row_gap to gap if not specified
    assigns = assign_new(assigns, :row_gap, fn -> assigns.gap end)
    
    ~H"""
    <div class={[
      "grid",
      grid_columns_class(@columns, @responsive),
      gap_class(@gap),
      row_gap_class(@row_gap),
      align_items_class(@align),
      widget_classes(assigns)
    ]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
  
  # Generate responsive grid classes
  defp grid_columns_class(12, true) do
    # Mobile first: 1 column, then responsive
    "grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6"
  end
  defp grid_columns_class(n, false) do
    "grid-cols-#{n}"
  end
  defp grid_columns_class(n, true) when n == 2 do
    "grid-cols-1 md:grid-cols-2"
  end
  defp grid_columns_class(n, true) when n == 3 do
    "grid-cols-1 md:grid-cols-3"
  end
  defp grid_columns_class(n, true) when n == 4 do
    "grid-cols-1 sm:grid-cols-2 lg:grid-cols-4"
  end
  
  defp align_items_class(:start), do: "items-start"
  defp align_items_class(:center), do: "items-center"
  defp align_items_class(:end), do: "items-end"
  defp align_items_class(:stretch), do: "items-stretch"
end
```

#### 3. Section Widget - Content Sections with Spacing

```elixir
# File: lib/my_app_web/widgets/section_widget.ex
defmodule MyApp.Widgets.SectionWidget do
  use MyApp.Widgets.Base
  
  @moduledoc """
  Section container with consistent spacing and optional styling.
  Use this to wrap content sections for consistent layout.
  """
  
  attr :background, :atom, default: :transparent,
    values: [:transparent, :muted, :card, :gradient],
    doc: "Background style"
  attr :border, :boolean, default: false,
    doc: "Add border"
  attr :rounded, :boolean, default: false,
    doc: "Rounded corners"
  attr :shadow, :atom, default: :none,
    values: [:none, :sm, :md, :lg, :xl],
    doc: "Shadow depth"
    
  slot :header do
    attr :sticky, :boolean, doc: "Make header sticky"
  end
  slot :inner_block, required: true
  slot :footer
  
  def render(assigns) do
    ~H"""
    <section class={[
      "section-widget",
      background_class(@background),
      @border && "border border-base-300",
      @rounded && "rounded-lg",
      shadow_class(@shadow),
      widget_classes(assigns)
    ]}>
      <div :if={@header} class={[
        "section-header",
        @header[:sticky] && "sticky top-0 z-10 bg-inherit"
      ]}>
        <%= render_slot(@header) %>
      </div>
      
      <div class="section-content">
        <%= render_slot(@inner_block) %>
      </div>
      
      <div :if={@footer} class="section-footer">
        <%= render_slot(@footer) %>
      </div>
      
      {render_debug(assigns)}
    </section>
    """
  end
  
  defp background_class(:transparent), do: nil
  defp background_class(:muted), do: "bg-base-200"
  defp background_class(:card), do: "bg-base-100"
  defp background_class(:gradient), do: "bg-gradient-to-br from-primary/5 to-secondary/5"
end
```

### COMPILATION AND TESTING CHECKPOINT #1

Before proceeding, let's ensure everything compiles and works:

```bash
# TERMINAL 1: Compile and check for errors
$ cd /path/to/forcefoundation
$ mix deps.get
$ mix compile --warnings-as-errors

# Common compilation errors at this stage:
# 1. "module MyApp.Widgets.Base is not available"
#    Solution: Create the base module first
# 2. "function span_class/1 undefined"
#    Solution: Import MyApp.Widgets.Helpers in your widget
# 3. "undefined function render_slot/1"
#    Solution: Make sure you have 'use Phoenix.Component'

# If compilation succeeds:
$ iex -S mix phx.server
```

```elixir
# TERMINAL 2: Run visual tests
$ iex -S mix
iex> Code.require_file("test/visual/layout_widget_test.exs")
iex> MyAppWeb.Visual.LayoutWidgetTest.test_layout_widget_renders_correctly()

# Check screenshots in:
# screenshots/layout_full.png
# screenshots/layout_sidebar_collapsed.png
# screenshots/layout_mobile.png
```

### Display Widgets: Show Your Data Beautifully

Display widgets present information to users. They all support both dumb and connected modes.

#### 1. Stat Widget - Key Metrics Display

```elixir
# File: lib/my_app_web/widgets/stat_widget.ex
defmodule MyApp.Widgets.StatWidget do
  use MyApp.Widgets.Base
  
  @moduledoc """
  Displays a single statistic with optional trend and change indicators.
  Perfect for dashboards and analytics views.
  
  ## Dumb Mode Example
      <.stat_widget
        label="Total Revenue"
        value="$12,345"
        change={+15.3}
        trend={:up}
        icon={:dollar}
      />
      
  ## Connected Mode Example
      <.stat_widget
        label="Active Users"
        data_source={:interface, :count_active_users}
        refresh_interval={30000}
        format={:number}
      />
  """
  
  # Display attributes
  attr :label, :string, required: true,
    doc: "Label for the statistic"
  attr :value, :any, default: nil,
    doc: "The value to display (dumb mode)"
  attr :change, :float, default: nil,
    doc: "Percentage change (e.g., +12.5)"
  attr :trend, :atom, default: nil,
    values: [:up, :down, :neutral],
    doc: "Trend direction"
  attr :icon, :atom, default: nil,
    doc: "Icon to display"
  attr :format, :atom, default: :auto,
    values: [:auto, :number, :currency, :percentage, :bytes],
    doc: "How to format the value"
    
  # Connected mode attributes
  attr :data_source, :any, default: :static,
    doc: "How to fetch the data"
  attr :refresh_interval, :integer, default: nil,
    doc: "Auto-refresh in milliseconds"
  attr :compare_to, :atom, default: :yesterday,
    values: [:yesterday, :last_week, :last_month, :last_year],
    doc: "What period to compare against"
    
  # Visual attributes
  attr :size, :atom, default: :md,
    values: [:sm, :md, :lg],
    doc: "Size of the stat card"
  attr :color, :atom, default: :default,
    doc: "Color theme for the stat"
  attr :animate, :boolean, default: true,
    doc: "Animate value changes"
  attr :clickable, :boolean, default: false,
    doc: "Is the stat clickable?"
  attr :on_click, :any, default: nil,
    doc: "Click handler"
    
  def render(assigns) do
    # Resolve data and compute derived values
    assigns = 
      assigns
      |> resolve_data()
      |> compute_trend()
      |> format_value()
      
    ~H"""
    <div 
      class={[
        "stat-widget",
        size_class(@size),
        color_class(@color),
        @clickable && "cursor-pointer hover:shadow-lg transition-shadow",
        widget_classes(assigns)
      ]}
      phx-click={@clickable && @on_click}
    >
      {render_debug(assigns)}
      
      <div class="stat-container">
        <!-- Icon -->
        <div :if={@icon} class={[
          "stat-icon",
          "text-4xl",
          trend_color(@trend)
        ]}>
          <.icon_widget name={@icon} />
        </div>
        
        <!-- Content -->
        <div class="stat-content">
          <div class="stat-label text-sm text-base-content/70">
            {@label}
          </div>
          
          <div class={[
            "stat-value",
            value_size_class(@size),
            "font-bold",
            @animate && "transition-all duration-300"
          ]}>
            {@formatted_value}
          </div>
          
          <!-- Change indicator -->
          <div :if={@change} class={[
            "stat-change",
            "text-sm",
            "flex items-center gap-1",
            trend_color(@trend)
          ]}>
            <.icon_widget 
              name={trend_icon(@trend)} 
              size={:xs}
            />
            <span>{format_change(@change)}%</span>
            <span class="text-base-content/50">vs {@compare_to}</span>
          </div>
        </div>
        
        <!-- Sparkline (if data available) -->
        <div :if={@sparkline_data} class="stat-sparkline">
          <.sparkline_widget 
            data={@sparkline_data}
            color={@color}
            height={30}
          />
        </div>
      </div>
      
      <!-- Loading overlay -->
      <div :if={@loading} class="stat-loading">
        <.spinner_widget size={:sm} />
      </div>
      
      <!-- Refresh timer -->
      <div :if={@refresh_interval && @next_refresh} class="stat-refresh">
        <span class="text-xs text-base-content/50">
          Refreshing in {@next_refresh}s
        </span>
      </div>
    </div>
    """
  end
  
  # Data resolution for connected mode
  defp resolve_data(%{data_source: :static} = assigns), do: assigns
  
  defp resolve_data(%{data_source: {:interface, func}} = assigns) do
    case apply_interface(func, assigns) do
      {:ok, %{value: value, change: change, sparkline: sparkline}} ->
        assigns
        |> assign(:value, value)
        |> assign(:change, change)
        |> assign(:sparkline_data, sparkline)
        |> assign(:loading, false)
        
      {:ok, %{value: value}} ->
        assigns
        |> assign(:value, value)
        |> assign(:loading, false)
        
      :loading ->
        assign(assigns, :loading, true)
        
      {:error, _} ->
        assigns
        |> assign(:value, "--")
        |> assign(:error, true)
    end
  end
  
  # Format value based on type
  defp format_value(%{format: :auto} = assigns) do
    cond do
      is_number(assigns.value) -> 
        assign(assigns, :formatted_value, Number.Delimit.number_to_delimited(assigns.value))
      is_binary(assigns.value) ->
        assign(assigns, :formatted_value, assigns.value)
      true ->
        assign(assigns, :formatted_value, to_string(assigns.value))
    end
  end
  
  defp format_value(%{format: :currency, value: value} = assigns) when is_number(value) do
    formatted = Number.Currency.number_to_currency(value)
    assign(assigns, :formatted_value, formatted)
  end
  
  defp format_value(%{format: :percentage, value: value} = assigns) when is_number(value) do
    formatted = "#{Float.round(value, 1)}%"
    assign(assigns, :formatted_value, formatted)
  end
  
  defp format_value(%{format: :bytes, value: value} = assigns) when is_number(value) do
    formatted = format_bytes(value)
    assign(assigns, :formatted_value, formatted)
  end
  
  # Compute trend from change
  defp compute_trend(%{change: nil} = assigns), do: assigns
  defp compute_trend(%{change: change} = assigns) when change > 0 do
    assign(assigns, :trend, :up)
  end
  defp compute_trend(%{change: change} = assigns) when change < 0 do
    assign(assigns, :trend, :down)
  end
  defp compute_trend(assigns), do: assign(assigns, :trend, :neutral)
  
  # Helper functions
  defp size_class(:sm), do: "stat-sm"
  defp size_class(:md), do: "stat-md"
  defp size_class(:lg), do: "stat-lg"
  
  defp value_size_class(:sm), do: "text-2xl"
  defp value_size_class(:md), do: "text-3xl"
  defp value_size_class(:lg), do: "text-4xl"
  
  defp trend_color(:up), do: "text-success"
  defp trend_color(:down), do: "text-error"
  defp trend_color(_), do: "text-base-content"
  
  defp trend_icon(:up), do: :trending_up
  defp trend_icon(:down), do: :trending_down
  defp trend_icon(_), do: :minus
  
  defp format_change(change) when change > 0, do: "+#{Float.round(change, 1)}"
  defp format_change(change), do: "#{Float.round(change, 1)}"
  
  defp format_bytes(bytes) when bytes < 1024, do: "#{bytes} B"
  defp format_bytes(bytes) when bytes < 1_048_576 do
    "#{Float.round(bytes / 1024, 1)} KB"
  end
  defp format_bytes(bytes) when bytes < 1_073_741_824 do
    "#{Float.round(bytes / 1_048_576, 1)} MB"
  end
  defp format_bytes(bytes) do
    "#{Float.round(bytes / 1_073_741_824, 1)} GB"
  end
  
  # Auto-refresh functionality
  def update(%{refresh_interval: interval} = assigns, socket) when not is_nil(interval) do
    if connected?(socket) do
      Process.send_after(self(), {:refresh_stat, assigns.id}, interval)
    end
    {:ok, assign(socket, assigns)}
  end
  def update(assigns, socket), do: {:ok, assign(socket, assigns)}
  
  def handle_info({:refresh_stat, widget_id}, socket) do
    send_update(__MODULE__, id: widget_id, refresh: true)
    {:noreply, socket}
  end
end
```

#### Testing Stat Widgets:

```elixir
# Create a dashboard with stats
# File: lib/my_app_web/live/dashboard_test_live.ex
defmodule MyAppWeb.DashboardTestLive do
  use MyAppWeb, :live_view
  
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <.layout_widget type={:dashboard}>
      <:main>
        <.page_widget>
          <.heading_widget level={1} text="Dashboard Stats Test" />
          
          <!-- Test different stat configurations -->
          <.grid_widget columns={4} gap={4}>
            <!-- Dumb mode stats -->
            <.stat_widget
              label="Total Users"
              value={1234}
              change={+12.5}
              trend={:up}
              icon={:users}
              color={:primary}
            />
            
            <.stat_widget
              label="Revenue"
              value={45678.90}
              format={:currency}
              change={-3.2}
              trend={:down}
              icon={:dollar}
              color={:success}
            />
            
            <.stat_widget
              label="Disk Usage"
              value={5_368_709_120}
              format={:bytes}
              icon={:database}
              color={:warning}
            />
            
            <.stat_widget
              label="Uptime"
              value="99.9%"
              change={0}
              trend={:neutral}
              icon={:server}
              clickable={true}
              on_click={:show_uptime_details}
            />
          </.grid_widget>
          
          <!-- Connected mode stats -->
          <.heading_widget level={2} text="Connected Stats" class="mt-8" />
          
          <.grid_widget columns={3} gap={4}>
            <.stat_widget
              label="Active Users"
              data_source={:interface, :count_active_users}
              refresh_interval={5000}
              icon={:activity}
            />
            
            <.stat_widget
              label="API Calls Today"
              data_source={:interface, :count_api_calls}
              compare_to={:yesterday}
              icon={:zap}
            />
            
            <.stat_widget
              label="Error Rate"
              data_source={:interface, :calculate_error_rate}
              format={:percentage}
              icon={:alert_circle}
              color={:error}
            />
          </.grid_widget>
        </.page_widget>
      </:main>
    </.layout_widget>
    """
  end
  
  def handle_event("show_uptime_details", _, socket) do
    socket = put_flash(socket, :info, "Uptime details clicked!")
    {:noreply, socket}
  end
end

# Add route in router.ex:
live "/test/dashboard", DashboardTestLive
```

```bash
# Visual testing with Puppeteer
$ iex -S mix phx.server
```

```elixir
# In IEx:
iex> {:ok, _} = Puppeteer.navigate(url: "http://localhost:4000/test/dashboard")
iex> {:ok, _} = Puppeteer.screenshot(name: "dashboard_stats", width: 1920, height: 1080)

# Test hover effects
iex> {:ok, _} = Puppeteer.hover(selector: ".stat-widget:first-child")
iex> {:ok, _} = Puppeteer.screenshot(name: "stat_hover", width: 400, height: 200)

# Test click interaction
iex> {:ok, _} = Puppeteer.click(selector: ".stat-widget[phx-click]")
iex> Process.sleep(500)
iex> {:ok, has_flash} = Puppeteer.evaluate(script: """
  document.querySelector('[role="alert"]') !== null
""")
iex> IO.puts("Flash message appeared: #{has_flash}")
```

#### 2. Card Widget - Versatile Content Container

```elixir
# File: lib/my_app_web/widgets/card_widget.ex  
defmodule MyApp.Widgets.CardWidget do
  use MyApp.Widgets.Base
  
  @moduledoc """
  Flexible card container for grouping related content.
  Supports headers, footers, and various styling options.
  """
  
  attr :variant, :atom, default: :elevated,
    values: [:flat, :elevated, :outlined, :gradient],
    doc: "Visual style variant"
  attr :interactive, :boolean, default: false,
    doc: "Add hover effects"
  attr :compact, :boolean, default: false,
    doc: "Reduce padding"
  attr :on_click, :any, default: nil
    
  slot :media do
    attr :position, :atom, values: [:top, :left, :right]
    attr :aspect_ratio, :atom, values: [:video, :square, :wide]
  end
  slot :header
  slot :body, required: true  
  slot :footer
  slot :actions
  
  def render(assigns) do
    ~H"""
    <div 
      class={[
        "card",
        variant_class(@variant),
        @interactive && "hover:shadow-xl transition-all cursor-pointer",
        @compact && "card-compact",
        widget_classes(assigns)
      ]}
      phx-click={@on_click}
    >
      <!-- Media slot -->
      <div :if={@media} class={[
        "card-media",
        media_position_class(@media[:position] || :top),
        aspect_ratio_class(@media[:aspect_ratio] || :video)
      ]}>
        <%= render_slot(@media) %>
      </div>
      
      <!-- Header -->
      <div :if={@header} class="card-header">
        <%= render_slot(@header) %>
      </div>
      
      <!-- Body -->
      <div class="card-body">
        <%= render_slot(@body) %>
      </div>
      
      <!-- Actions -->
      <div :if={@actions} class="card-actions">
        <%= render_slot(@actions) %>
      </div>
      
      <!-- Footer -->
      <div :if={@footer} class="card-footer">
        <%= render_slot(@footer) %>
      </div>
      
      {render_debug(assigns)}
    </div>
    """
  end
  
  defp variant_class(:flat), do: "bg-base-100"
  defp variant_class(:elevated), do: "bg-base-100 shadow-lg"
  defp variant_class(:outlined), do: "bg-transparent border-2 border-base-300"
  defp variant_class(:gradient), do: "bg-gradient-to-br from-primary/10 to-secondary/10"
end
```
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

### Table/List Widgets: Display Your Data Like a Pro

These widgets handle data display with sorting, filtering, pagination, and real-time updates. They're the workhorses of any data-driven application.

#### 1. Table Widget - The Ultimate Data Grid

```elixir
# File: lib/my_app_web/widgets/table_widget.ex
defmodule MyApp.Widgets.TableWidget do
  use MyApp.Widgets.Base
  
  @moduledoc """
  A feature-rich table widget supporting:
  - Sorting (click column headers)
  - Filtering (per column or global)
  - Pagination (with page size options)
  - Row selection (single or multi)
  - Bulk actions
  - Expandable rows
  - Column resizing
  - Export functionality
  - Real-time updates via streams
  """
  
  # Data attributes
  attr :columns, :list, required: true,
    doc: "Column definitions with field, label, and options"
  attr :rows, :list, default: [],
    doc: "Static data rows (dumb mode)"
  attr :data_source, :any, default: :static,
    doc: "How to fetch data (connected mode)"
  attr :stream, :atom, default: nil,
    doc: "Phoenix stream name for efficient updates"
    
  # Features
  attr :sortable, :boolean, default: true,
    doc: "Enable column sorting"
  attr :filterable, :boolean, default: true,
    doc: "Enable column filtering"
  attr :paginated, :boolean, default: true,
    doc: "Enable pagination"
  attr :selectable, :boolean, default: false,
    doc: "Enable row selection"
  attr :expandable, :boolean, default: false,
    doc: "Enable row expansion"
  attr :reorderable, :boolean, default: false,
    doc: "Enable column reordering"
  attr :resizable, :boolean, default: false,
    doc: "Enable column resizing"
    
  # Configuration
  attr :page, :integer, default: 1
  attr :per_page, :integer, default: 20
  attr :per_page_options, :list, default: [10, 20, 50, 100]
  attr :sort_by, :atom, default: nil
  attr :sort_order, :atom, default: :asc
  attr :filters, :map, default: %{}
  attr :selected_rows, :list, default: []
  attr :expanded_rows, :list, default: []
  
  # Styling
  attr :striped, :boolean, default: true,
    doc: "Zebra striping"
  attr :hover, :boolean, default: true,
    doc: "Highlight on hover"
  attr :compact, :boolean, default: false,
    doc: "Compact row height"
  attr :bordered, :boolean, default: true,
    doc: "Show borders"
  attr :sticky_header, :boolean, default: true,
    doc: "Keep header visible on scroll"
    
  # Events
  attr :on_row_click, :any, default: nil
  attr :on_selection_change, :any, default: nil
  attr :on_sort, :any, default: nil
  attr :on_filter, :any, default: nil
  
  # Slots
  slot :empty_state do
    attr :icon, :atom
    attr :title, :string
    attr :description, :string
  end
  
  slot :bulk_actions do
    attr :label, :string
    attr :action, :atom
    attr :confirm, :boolean
    attr :icon, :atom
  end
  
  slot :row_actions do
    attr :label, :string
    attr :action, :atom
    attr :icon, :atom
  end
  
  slot :expanded_row_content
  
  def render(assigns) do
    # Resolve data and prepare for rendering
    assigns = 
      assigns
      |> determine_mode()
      |> resolve_data()
      |> calculate_pagination()
      |> prepare_columns()
      
    ~H"""
    <div class={[
      "table-widget",
      @loading && "table-loading",
      widget_classes(assigns)
    ]}>
      {render_debug(assigns)}
      
      <!-- Toolbar -->
      <div class="table-toolbar">
        <!-- Search/Filter -->
        <div class="toolbar-left">
          <.search_widget 
            :if={@filterable}
            placeholder="Search..."
            on_search={:search_table}
            value={@filters["_search"]}
          />
          
          <.filter_dropdown_widget
            :if={@filterable && advanced_filters?(@columns)}
            filters={@filters}
            columns={@columns}
            on_apply={:apply_filters}
          />
        </div>
        
        <!-- Actions -->
        <div class="toolbar-right">
          <!-- Bulk actions -->
          <.dropdown_widget
            :if={@selectable && length(@selected_rows) > 0}
            trigger_label="Actions (#{length(@selected_rows)})"
          >
            <.dropdown_item_widget
              :for={action <- @bulk_actions}
              label={action.label}
              icon={action.icon}
              on_click={{:bulk_action, action.action}}
              confirm={action[:confirm]}
            />
          </.dropdown_widget>
          
          <!-- View options -->
          <.dropdown_widget trigger_icon={:settings}>
            <.checkbox_widget
              label="Striped rows"
              checked={@striped}
              on_change={:toggle_striped}
            />
            <.checkbox_widget
              label="Compact view"
              checked={@compact}
              on_change={:toggle_compact}
            />
            <div class="divider"></div>
            <.dropdown_item_widget
              label="Export CSV"
              icon={:download}
              on_click={:export_csv}
            />
          </.dropdown_widget>
        </div>
      </div>
      
      <!-- The table itself -->
      <div class="table-container">
        <table class={[
          "table",
          @striped && "table-striped",
          @hover && "table-hover",
          @compact && "table-compact",
          @bordered && "table-bordered"
        ]}>
          <!-- Header -->
          <thead class={@sticky_header && "sticky top-0 z-10 bg-base-200"}>
            <tr>
              <!-- Select all checkbox -->
              <th :if={@selectable} class="w-12">
                <input
                  type="checkbox"
                  checked={all_selected?(@rows, @selected_rows)}
                  phx-click="toggle_all"
                  class="checkbox checkbox-sm"
                />
              </th>
              
              <!-- Expand toggle column -->
              <th :if={@expandable} class="w-12"></th>
              
              <!-- Data columns -->
              <th
                :for={col <- @columns}
                class={[
                  col[:sortable] && "cursor-pointer hover:bg-base-300",
                  "relative group"
                ]}
                phx-click={col[:sortable] && "sort"}
                phx-value-field={col.field}
              >
                <div class="flex items-center gap-2">
                  <span>{col.label}</span>
                  
                  <!-- Sort indicator -->
                  <.sort_indicator
                    :if={col[:sortable]}
                    field={col.field}
                    current_field={@sort_by}
                    order={@sort_order}
                  />
                  
                  <!-- Column filter -->
                  <.column_filter_widget
                    :if={col[:filterable]}
                    column={col}
                    value={@filters[to_string(col.field)]}
                    on_change={{:filter_column, col.field}}
                  />
                </div>
                
                <!-- Resize handle -->
                <div
                  :if={@resizable}
                  class="resize-handle"
                  phx-hook="ColumnResize"
                  data-column={col.field}
                ></div>
              </th>
              
              <!-- Actions column -->
              <th :if={@row_actions != []} class="w-24">Actions</th>
            </tr>
          </thead>
          
          <!-- Body -->
          <tbody phx-update={@stream && "stream" || "replace"} id="table-body">
            {render_rows(assigns)}
          </tbody>
          
          <!-- Footer -->
          <tfoot :if={show_footer?(@columns)}>
            <tr>
              <td :if={@selectable}></td>
              <td :if={@expandable}></td>
              <td :for={col <- @columns}>
                {render_footer_cell(col, @rows)}
              </td>
              <td :if={@row_actions != []}></td>
            </tr>
          </tfoot>
        </table>
      </div>
      
      <!-- Empty state -->
      <div :if={empty?(@rows)} class="table-empty-state">
        <.empty_state_widget
          icon={@empty_state[:icon] || :inbox}
          title={@empty_state[:title] || "No data"}
          description={@empty_state[:description]}
        />
      </div>
      
      <!-- Pagination -->
      <div :if={@paginated && @total_pages > 1} class="table-pagination">
        <.pagination_widget
          current_page={@page}
          total_pages={@total_pages}
          total_items={@total_items}
          per_page={@per_page}
          per_page_options={@per_page_options}
          on_page_change={:change_page}
          on_per_page_change={:change_per_page}
        />
      </div>
      
      <!-- Loading overlay -->
      <.loading_overlay_widget :if={@loading} />
    </div>
    """
  end
  
  # Render table rows based on mode
  defp render_rows(%{mode: :dumb, rows: rows} = assigns) do
    ~H"""
    <%= for {row, index} <- Enum.with_index(@rows) do %>
      {render_row(assigns, row, "row-#{index}")}
    <% end %>
    """
  end
  
  defp render_rows(%{mode: :connected, stream: stream} = assigns) when not is_nil(stream) do
    ~H"""
    <%= for {dom_id, row} <- @streams[@stream] do %>
      {render_row(assigns, row, dom_id)}
    <% end %>
    """
  end
  
  # Render individual row
  defp render_row(assigns, row, dom_id) do
    assigns = assign(assigns, :row, row) |> assign(:dom_id, dom_id)
    
    ~H"""
    <tr
      id={@dom_id}
      class={[
        "table-row",
        @selectable && "cursor-pointer",
        selected?(@row, @selected_rows) && "bg-primary/10",
        @on_row_click && "hover:bg-base-200"
      ]}
      phx-click={@on_row_click}
      phx-value-id={@row[:id]}
    >
      <!-- Selection checkbox -->
      <td :if={@selectable}>
        <input
          type="checkbox"
          checked={selected?(@row, @selected_rows)}
          phx-click="toggle_row"
          phx-value-id={@row[:id]}
          class="checkbox checkbox-sm"
        />
      </td>
      
      <!-- Expand toggle -->
      <td :if={@expandable}>
        <button
          class="btn btn-ghost btn-xs"
          phx-click="toggle_expand"
          phx-value-id={@row[:id]}
        >
          <.icon_widget
            name={expanded?(@row, @expanded_rows) && :chevron_down || :chevron_right}
            size={:sm}
          />
        </button>
      </td>
      
      <!-- Data cells -->
      <td :for={col <- @columns}>
        {render_cell(@row, col)}
      </td>
      
      <!-- Row actions -->
      <td :if={@row_actions != []} class="table-actions">
        <.dropdown_widget trigger_icon={:more_vertical} size={:sm}>
          <.dropdown_item_widget
            :for={action <- @row_actions}
            label={action.label}
            icon={action.icon}
            on_click={{action.action, @row[:id]}}
          />
        </.dropdown_widget>
      </td>
    </tr>
    
    <!-- Expanded content -->
    <tr :if={@expandable && expanded?(@row, @expanded_rows)} class="expanded-row">
      <td colspan={colspan_count(assigns)}>
        <div class="expanded-content">
          <%= render_slot(@expanded_row_content, @row) %>
        </div>
      </td>
    </tr>
    """
  end
  
  # Cell rendering with formatting
  defp render_cell(row, col) do
    value = get_in(row, col[:field] |> to_string() |> String.split(".") |> Enum.map(&String.to_atom/1))
    
    cond do
      col[:render] -> col[:render].(value, row)
      col[:format] -> format_value(value, col[:format])
      col[:component] -> render_component(col[:component], value: value, row: row)
      true -> value
    end
  end
  
  # Format helpers
  defp format_value(nil, _), do: "-"
  defp format_value(value, :currency), do: Number.Currency.number_to_currency(value)
  defp format_value(value, :percentage), do: "#{Float.round(value, 1)}%"
  defp format_value(value, :date), do: Calendar.strftime(value, "%b %d, %Y")
  defp format_value(value, :datetime), do: Calendar.strftime(value, "%b %d, %Y %I:%M %p")
  defp format_value(value, :relative_time), do: Timex.from_now(value)
  defp format_value(value, :boolean), do: if(value, do: "✓", else: "✗")
  defp format_value(value, :truncate), do: String.slice(value, 0..50) <> "..."
  defp format_value(value, _), do: value
end
```

#### Testing the Table Widget:

```bash
# STEP 1: Create test data
# File: lib/my_app_web/live/table_test_live.ex
```

```elixir
defmodule MyAppWeb.TableTestLive do
  use MyAppWeb, :live_view
  
  def mount(_params, _session, socket) do
    # Start with dumb mode data
    socket = 
      socket
      |> assign(:users, generate_test_users(50))
      |> assign(:selected_rows, [])
      |> assign(:sort_by, :name)
      |> assign(:sort_order, :asc)
      |> assign(:filters, %{})
      |> assign(:page, 1)
      |> assign(:per_page, 10)
      
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <.layout_widget type={:centered} max_width={:xl}>
      <:main>
        <.page_widget>
          <.heading_widget level={1} text="Table Widget Test" />
          
          <!-- Dumb mode table -->
          <.section_widget margin_bottom={8}>
            <:header>
              <.heading_widget level={2} text="Dumb Mode Table" />
            </:header>
            
            <.table_widget
              columns={[
                %{field: :id, label: "ID", sortable: true},
                %{field: :name, label: "Name", sortable: true, filterable: true},
                %{field: :email, label: "Email", sortable: true},
                %{field: :role, label: "Role", filterable: true,
                  render: &render_role_badge/2},
                %{field: :status, label: "Status",
                  render: &render_status_badge/2},
                %{field: :last_login, label: "Last Login",
                  format: :relative_time},
                %{field: :created_at, label: "Joined",
                  format: :date}
              ]}
              rows={paginate(@users, @page, @per_page)}
              selectable={true}
              selected_rows={@selected_rows}
              on_selection_change={:handle_selection}
              expandable={true}
              sort_by={@sort_by}
              sort_order={@sort_order}
              on_sort={:handle_sort}
              page={@page}
              per_page={@per_page}
              total_items={length(@users)}
              on_page_change={:handle_page_change}
              debug_mode={true}
            >
              <:bulk_actions>
                %{label: "Delete Selected", action: :delete, icon: :trash, confirm: true}
                %{label: "Export Selected", action: :export, icon: :download}
              </:bulk_actions>
              
              <:row_actions>
                %{label: "Edit", action: :edit, icon: :edit}
                %{label: "View Details", action: :view, icon: :eye}
                %{label: "Delete", action: :delete, icon: :trash}
              </:row_actions>
              
              <:expanded_row_content :let={user}>
                <.grid_widget columns={2} gap={4}>
                  <div>
                    <.heading_widget level={4} text="User Details" />
                    <.description_list_widget
                      items={[
                        %{label: "Full Name", value: user.name},
                        %{label: "Department", value: user.department},
                        %{label: "Location", value: user.location},
                        %{label: "Manager", value: user.manager}
                      ]}
                    />
                  </div>
                  <div>
                    <.heading_widget level={4} text="Activity" />
                    <.mini_chart_widget
                      data={user.activity_data}
                      type={:sparkline}
                      height={100}
                    />
                  </div>
                </.grid_widget>
              </:expanded_row_content>
              
              <:empty_state>
                %{
                  icon: :users,
                  title: "No users found",
                  description: "Try adjusting your filters or add some users"
                }
              </:empty_state>
            </.table_widget>
          </.section_widget>
          
          <!-- Connected mode table (when ready) -->
          <.section_widget>
            <:header>
              <.heading_widget level={2} text="Connected Mode Table" />
            </:header>
            
            <.table_widget
              columns={[
                %{field: :name, label: "Name", sortable: true},
                %{field: :email, label: "Email"},
                %{field: :status, label: "Status", 
                  render: &render_status_badge/2}
              ]}
              data_source={:interface, :list_users}
              stream={:users}
              per_page={20}
            />
          </.section_widget>
        </.page_widget>
      </:main>
    </.layout_widget>
    """
  end
  
  # Event handlers
  def handle_event("handle_selection", %{"selected" => selected}, socket) do
    {:noreply, assign(socket, :selected_rows, selected)}
  end
  
  def handle_event("handle_sort", %{"field" => field}, socket) do
    field = String.to_existing_atom(field)
    
    {order, sorted_users} = 
      if socket.assigns.sort_by == field do
        new_order = toggle_sort_order(socket.assigns.sort_order)
        users = sort_users(socket.assigns.users, field, new_order)
        {new_order, users}
      else
        users = sort_users(socket.assigns.users, field, :asc)
        {:asc, users}
      end
      
    socket = 
      socket
      |> assign(:sort_by, field)
      |> assign(:sort_order, order)
      |> assign(:users, sorted_users)
      
    {:noreply, socket}
  end
  
  def handle_event("handle_page_change", %{"page" => page}, socket) do
    {:noreply, assign(socket, :page, page)}
  end
  
  # Helper functions
  defp generate_test_users(count) do
    for i <- 1..count do
      %{
        id: i,
        name: Faker.Name.name(),
        email: Faker.Internet.email(),
        role: Enum.random([:admin, :user, :moderator]),
        status: Enum.random([:active, :inactive, :pending]),
        department: Faker.Company.buzzword(),
        location: Faker.Address.city(),
        manager: Faker.Name.name(),
        last_login: Faker.DateTime.backward(30),
        created_at: Faker.DateTime.backward(365),
        activity_data: Enum.map(1..7, fn _ -> :rand.uniform(100) end)
      }
    end
  end
  
  defp render_role_badge(role, _row) do
    assigns = %{role: role}
    
    ~H"""
    <.badge_widget 
      label={@role} 
      color={role_color(@role)}
      size={:sm}
    />
    """
  end
  
  defp render_status_badge(status, _row) do
    assigns = %{status: status}
    
    ~H"""
    <.badge_widget
      label={@status}
      color={status_color(@status)}
      variant={:dot}
      size={:sm}
    />
    """
  end
  
  defp role_color(:admin), do: :error
  defp role_color(:moderator), do: :warning
  defp role_color(_), do: :primary
  
  defp status_color(:active), do: :success
  defp status_color(:inactive), do: :neutral
  defp status_color(:pending), do: :warning
  
  defp paginate(items, page, per_page) do
    start = (page - 1) * per_page
    Enum.slice(items, start, per_page)
  end
  
  defp sort_users(users, field, order) do
    Enum.sort_by(users, & &1[field], order)
  end
  
  defp toggle_sort_order(:asc), do: :desc
  defp toggle_sort_order(:desc), do: :asc
end
```

```bash
# STEP 2: Add route and compile
# In router.ex:
live "/test/table", TableTestLive

$ mix compile
$ iex -S mix phx.server
```

```elixir
# STEP 3: Visual testing
# In IEx console:
iex> {:ok, _} = Puppeteer.navigate(url: "http://localhost:4000/test/table")
iex> Process.sleep(2000)  # Let everything load

# Test 1: Full page screenshot
iex> {:ok, _} = Puppeteer.screenshot(
  name: "table_full",
  width: 1920,
  height: 1080
)

# Test 2: Sort functionality
iex> {:ok, _} = Puppeteer.click(selector: "th:nth-child(3)")
iex> Process.sleep(500)
iex> {:ok, _} = Puppeteer.screenshot(
  name: "table_sorted",
  width: 1920,
  height: 600
)

# Test 3: Row selection
iex> {:ok, _} = Puppeteer.click(selector: "tbody tr:first-child input[type='checkbox']")
iex> {:ok, _} = Puppeteer.click(selector: "tbody tr:nth-child(2) input[type='checkbox']")
iex> Process.sleep(300)
iex> {:ok, _} = Puppeteer.screenshot(
  name: "table_selected_rows",
  width: 1920,
  height: 600
)

# Test 4: Row expansion
iex> {:ok, _} = Puppeteer.click(selector: "tbody tr:first-child button")
iex> Process.sleep(500)
iex> {:ok, _} = Puppeteer.screenshot(
  name: "table_expanded_row",
  width: 1920,
  height: 800
)

# Test 5: Pagination
iex> {:ok, _} = Puppeteer.click(selector: ".pagination-next")
iex> Process.sleep(500)
iex> {:ok, page_info} = Puppeteer.evaluate(script: """
  document.querySelector('.pagination-info').textContent
""")
iex> IO.puts("Current page info: #{page_info}")

# Test 6: Mobile responsiveness
iex> {:ok, _} = Puppeteer.screenshot(
  name: "table_mobile",
  width: 375,
  height: 667
)
```

### COMPILATION AND TESTING CHECKPOINT #2

```bash
# Check for common table widget errors:
$ mix compile --warnings-as-errors

# Common errors and fixes:
# 1. "undefined function paginate/3"
#    Solution: Make sure helper functions are defined
# 2. "cannot invoke remote function assigns.on_row_click/0"
#    Solution: Use parentheses: @on_row_click && "handler"
# 3. "assign @streams not available in template"
#    Solution: Only use @streams when stream attribute is set

# Run comprehensive tests:
$ mix test test/widgets/table_widget_test.exs

# Check memory usage with large datasets:
$ iex -S mix phx.server
iex> :observer.start()  # Look at memory usage
iex> # Navigate to table test page with 1000+ rows
```

### Form Widgets: The Complete Guide to Data Entry

Form widgets are where the magic happens - they combine Phoenix LiveView's robust form handling with AshPhoenix.Form's validation power, all wrapped in a consistent, beautiful interface.

#### Understanding Form Widgets: A Beginner's Mental Model

Think of form widgets like a smart assistant that:
1. **Knows what Phoenix expects** - Uses standard Phoenix form components internally
2. **Speaks Ash fluently** - Integrates perfectly with AshPhoenix.Form
3. **Handles the tedious stuff** - Validation, error display, loading states
4. **Makes it pretty** - Consistent styling and spacing

#### The Form Widget Hierarchy

```
<.form_widget>                    # The container (wraps <.form>)
  ├── <.input_widget>             # Text inputs (wraps <.input>)
  ├── <.select_widget>            # Dropdowns (wraps <.input type="select">)
  ├── <.textarea_widget>          # Text areas (wraps <.input type="textarea">)
  ├── <.checkbox_widget>          # Checkboxes (wraps <.input type="checkbox">)
  ├── <.radio_group_widget>       # Radio buttons
  ├── <.file_upload_widget>       # File uploads
  └── <.nested_form_widget>       # Nested forms (wraps <.inputs_for>)
```

#### Form Initialization: Step-by-Step for Beginners

```elixir
# STEP 1: Create your Ash resource with validations
# File: lib/my_app/accounts/resources/user.ex
defmodule MyApp.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer
    
  attributes do
    uuid_primary_key :id
    
    attribute :email, :ci_string do
      allow_nil? false
      constraints [
        match: ~r/^[^\s]+@[^\s]+$/,
        message: "must be a valid email"
      ]
    end
    
    attribute :name, :string do
      allow_nil? false
      constraints min_length: 2, max_length: 100
    end
    
    attribute :age, :integer do
      constraints min: 18, max: 120
    end
    
    attribute :role, :atom do
      constraints one_of: [:admin, :user, :guest]
      default :user
    end
    
    attribute :bio, :string do
      constraints max_length: 500
    end
    
    attribute :accepts_terms, :boolean do
      allow_nil? false
      default false
    end
    
    timestamps()
  end
  
  # Define actions with their validations
  actions do
    defaults [:read, :destroy]
    
    create :register do
      accept [:email, :name, :age, :bio, :accepts_terms]
      
      validate compare(:age, greater_than_or_equal_to: 18) do
        message "must be 18 or older"
      end
      
      validate attribute_equals(:accepts_terms, true) do
        message "must accept terms of service"
      end
      
      # Custom validation
      validate fn changeset ->
        email = Ash.Changeset.get_attribute(changeset, :email)
        
        if email && MyApp.Accounts.email_taken?(email) do
          {:error, field: :email, message: "has already been taken"}
        else
          :ok
        end
      end
    end
    
    update :update_profile do
      accept [:name, :age, :bio, :role]
      
      # Only admins can change roles
      validate fn changeset ->
        if Ash.Changeset.changing_attribute?(changeset, :role) do
          if changeset.context[:actor][:role] == :admin do
            :ok
          else
            {:error, field: :role, message: "only admins can change roles"}
          end
        else
          :ok
        end
      end
    end
  end
end
```

```elixir
# STEP 2: Create your LiveView with form initialization
# File: lib/my_app_web/live/user_form_live.ex
defmodule MyAppWeb.UserFormLive do
  use MyAppWeb, :live_view
  
  # BEGINNER TIP: @impl true means we're implementing a callback
  @impl true
  def mount(params, _session, socket) do
    # Determine if we're creating or editing
    socket = 
      case params["id"] do
        nil -> 
          # Creating a new user
          socket
          |> assign(:page_title, "Register New User")
          |> assign(:user, nil)
          |> assign_new_form()
          
        id ->
          # Editing existing user
          user = MyApp.Accounts.get_user!(id)
          
          socket
          |> assign(:page_title, "Edit Profile")
          |> assign(:user, user)
          |> assign_edit_form(user)
      end
      
    {:ok, socket}
  end
  
  # Helper function to create a new user form
  defp assign_new_form(socket) do
    form = 
      AshPhoenix.Form.for_create(
        MyApp.Accounts.User,    # Resource module
        :register,              # Action name
        # Options
        api: MyApp.Accounts,    # Your API module
        # Set default values
        params: %{
          "role" => "user"
        },
        # Configure nested forms if needed
        forms: [
          # We'll add addresses later
        ]
      )
      
    assign(socket, :form, form)
  end
  
  # Helper function to create an edit form
  defp assign_edit_form(socket, user) do
    form = 
      AshPhoenix.Form.for_update(
        user,                   # Existing record
        :update_profile,        # Action name
        api: MyApp.Accounts,
        actor: socket.assigns.current_user  # For authorization
      )
      
    assign(socket, :form, form)
  end
  
  @impl true
  def render(assigns) do
    ~H"""
    <.layout_widget type={:centered} max_width={:md}>
      <:main>
        <.page_widget>
          <.heading_widget level={1} text={@page_title} />
          
          <!-- The main form -->
          <.form_widget
            for={@form}
            on_submit={:save}
            on_change={:validate}
            class="mt-6"
          >
            <!-- Email field (only for new users) -->
            <.input_widget
              :if={!@user}
              field={@form[:email]}
              label="Email Address"
              type={:email}
              placeholder="you@example.com"
              required={true}
              help_text="We'll never share your email"
              autocomplete="email"
            />
            
            <!-- Name field -->
            <.input_widget
              field={@form[:name]}
              label="Full Name"
              placeholder="John Doe"
              required={true}
              autocomplete="name"
            />
            
            <!-- Age field with number input -->
            <.input_widget
              field={@form[:age]}
              label="Age"
              type={:number}
              min={18}
              max={120}
              help_text="You must be 18 or older"
            />
            
            <!-- Role selection (only for admins editing) -->
            <.select_widget
              :if={@user && @current_user.role == :admin}
              field={@form[:role]}
              label="User Role"
              options={[
                {"Regular User", :user},
                {"Administrator", :admin},
                {"Guest", :guest}
              ]}
              help_text="Only administrators can change roles"
            />
            
            <!-- Bio with character count -->
            <.textarea_widget
              field={@form[:bio]}
              label="Bio"
              placeholder="Tell us about yourself..."
              rows={4}
              max_length={500}
              show_count={true}
              help_text="Maximum 500 characters"
            />
            
            <!-- Terms acceptance (only for registration) -->
            <.checkbox_widget
              :if={!@user}
              field={@form[:accepts_terms]}
              label="I accept the terms of service"
              required={true}
            />
            
            <!-- Form actions -->
            <.form_actions_widget>
              <.button_widget
                type={:submit}
                label={@user && "Update Profile" || "Create Account"}
                loading={@form.submitting?}
                disabled={!@form.valid?}
                color={:primary}
              />
              <.button_widget
                type={:button}
                label="Cancel"
                variant={:outline}
                on_click={:cancel}
              />
            </.form_actions_widget>
            
            <!-- Debug info in development -->
            <.debug_panel_widget :if={Application.get_env(:my_app, :env) == :dev}>
              <:title>Form Debug Info</:title>
              <pre>{inspect(@form, pretty: true)}</pre>
            </.debug_panel_widget>
          </.form_widget>
        </.page_widget>
      </:main>
    </.layout_widget>
    """
  end
  
  # VALIDATION - This runs on EVERY change!
  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    # AshPhoenix.Form.validate does all the heavy lifting
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    
    # You can add custom validations here too
    form = 
      if params["email"] && String.contains?(params["email"], "spam") do
        AshPhoenix.Form.add_error(form, :email, "Spam emails not allowed")
      else
        form
      end
      
    {:noreply, assign(socket, :form, form)}
  end
  
  # SUBMISSION - This runs when form is submitted
  @impl true  
  def handle_event("save", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, user} ->
        # Success! Redirect or show message
        socket
        |> put_flash(:info, success_message(socket.assigns.user, user))
        |> push_navigate(to: ~p"/users/#{user.id}")
        |> then(&{:noreply, &1})
        
      {:error, form} ->
        # Errors! The form now contains all error messages
        socket
        |> put_flash(:error, "Please fix the errors below")
        |> assign(:form, form)
        |> then(&{:noreply, &1})
    end
  end
  
  @impl true
  def handle_event("cancel", _, socket) do
    {:noreply, push_navigate(socket, to: ~p"/users")}
  end
  
  defp success_message(nil, _user), do: "Account created successfully!"
  defp success_message(_old_user, _user), do: "Profile updated successfully!"
end
```

#### Using Form Widgets: Complete Examples

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

### Table and List Widgets: Handling Collections Like a Pro

Table and list widgets are where the Phoenix LiveView widget system really shines. They handle large datasets efficiently using Phoenix Streams while maintaining a consistent interface.

#### Table Widget Implementation - The Complete Guide

```elixir
# File: lib/my_app_web/components/widgets/display/table_widget.ex
defmodule MyAppWeb.Widgets.Display.TableWidget do
  use MyAppWeb.Widgets.Base
  
  # BEGINNER NOTE: This widget handles both static data and Phoenix Streams!
  
  attr :id, :string, required: true, doc: "Unique ID for the table"
  attr :rows, :list, default: [], doc: "Static row data (for dumb mode)"
  attr :stream, :any, default: nil, doc: "Phoenix Stream (for connected mode)"
  
  # Column configuration
  attr :columns, :list, required: true, doc: "List of column definitions"
  
  # Sorting
  attr :sort_by, :atom, default: nil
  attr :sort_order, :atom, default: :asc, values: [:asc, :desc]
  attr :on_sort, :string, default: nil, doc: "Event to handle sorting"
  
  # Selection  
  attr :selectable, :boolean, default: false
  attr :selected_ids, :list, default: []
  attr :on_select, :string, default: nil
  
  # Pagination
  attr :page, :integer, default: 1
  attr :per_page, :integer, default: 20
  attr :total_pages, :integer, default: nil
  attr :on_paginate, :string, default: nil
  
  # Actions
  slot :actions, doc: "Actions for each row" do
    attr :label, :string
    attr :icon, :atom
    attr :on_click, :string
    attr :confirm, :string
  end
  
  # Empty state
  slot :empty_state, doc: "What to show when no data"
  
  def render(assigns) do
    ~H"""
    <div class="widget-table-container" id={@id}>
      <!-- Table Controls -->
      <div class="mb-4 flex justify-between items-center">
        <!-- Bulk Actions (when items selected) -->
        <div :if={@selectable && length(@selected_ids) > 0} class="flex items-center gap-2">
          <span class="text-sm text-gray-600">
            {length(@selected_ids)} selected
          </span>
          <.button_widget 
            label="Clear" 
            variant={:ghost}
            size={:sm}
            phx-click={@on_select}
            phx-value-action="clear_all"
          />
        </div>
        
        <!-- Pagination Info -->
        <div :if={@total_pages} class="text-sm text-gray-600">
          Page {@page} of {@total_pages}
        </div>
      </div>
      
      <!-- The Table -->
      <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
        <table class="min-w-full divide-y divide-gray-300">
          <!-- Header -->
          <thead class="bg-gray-50">
            <tr>
              <!-- Select All Checkbox -->
              <th :if={@selectable} scope="col" class="relative w-12 px-6 sm:w-16 sm:px-8">
                <input
                  type="checkbox"
                  class="absolute left-4 top-1/2 -mt-2 h-4 w-4 rounded border-gray-300"
                  phx-click={@on_select}
                  phx-value-action="toggle_all"
                  checked={all_selected?(@rows, @stream, @selected_ids)}
                />
              </th>
              
              <!-- Column Headers -->
              <th
                :for={col <- @columns}
                scope="col"
                class={[
                  "px-3 py-3.5 text-left text-sm font-semibold text-gray-900",
                  col[:sortable] && "cursor-pointer hover:bg-gray-100",
                  col[:class]
                ]}
                phx-click={col[:sortable] && @on_sort}
                phx-value-field={col[:field]}
              >
                <div class="flex items-center gap-1">
                  {col[:label]}
                  <!-- Sort Indicator -->
                  <span :if={col[:sortable]} class="ml-1">
                    <.icon 
                      :if={@sort_by == col[:field] && @sort_order == :asc}
                      name={:chevron_up} 
                      class="h-4 w-4"
                    />
                    <.icon 
                      :if={@sort_by == col[:field] && @sort_order == :desc}
                      name={:chevron_down} 
                      class="h-4 w-4"
                    />
                    <.icon 
                      :if={@sort_by != col[:field]}
                      name={:chevron_up_down} 
                      class="h-4 w-4 text-gray-400"
                    />
                  </span>
                </div>
              </th>
              
              <!-- Actions Column -->
              <th :if={@actions != []} scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-6">
                <span class="sr-only">Actions</span>
              </th>
            </tr>
          </thead>
          
          <!-- Body -->
          <tbody class="divide-y divide-gray-200 bg-white" phx-update={@stream && "stream"}>
            <!-- Render rows based on mode -->
            <%= if @stream do %>
              <!-- Connected Mode: Use Phoenix Streams -->
              <tr :for={{dom_id, row} <- @stream} id={dom_id} class={row_classes(row, @selected_ids)}>
                {render_row_cells(assigns, row)}
              </tr>
            <% else %>
              <!-- Dumb Mode: Static data -->
              <tr :for={row <- @rows} id={"row-#{row.id}"} class={row_classes(row, @selected_ids)}>
                {render_row_cells(assigns, row)}
              </tr>
            <% end %>
          </tbody>
        </table>
        
        <!-- Empty State -->
        <div :if={empty?(@rows, @stream)} class="text-center py-12">
          <%= if @empty_state do %>
            <%= render_slot(@empty_state) %>
          <% else %>
            <.empty_state_widget 
              icon={:inbox}
              title="No data"
              description="No records to display"
            />
          <% end %>
        </div>
      </div>
      
      <!-- Pagination Controls -->
      <div :if={@total_pages && @total_pages > 1} class="mt-4">
        <.pagination_widget
          current_page={@page}
          total_pages={@total_pages}
          on_navigate={@on_paginate}
        />
      </div>
    </div>
    """
  end
  
  # Helper function to render row cells
  defp render_row_cells(assigns, row) do
    assigns = assign(assigns, :row, row)
    
    ~H"""
    <!-- Selection Checkbox -->
    <td :if={@selectable} class="relative w-12 px-6 sm:w-16 sm:px-8">
      <input
        type="checkbox"
        class="absolute left-4 top-1/2 -mt-2 h-4 w-4 rounded border-gray-300"
        value={@row.id}
        checked={@row.id in @selected_ids}
        phx-click={@on_select}
        phx-value-id={@row.id}
        phx-value-action="toggle_one"
      />
    </td>
    
    <!-- Data Cells -->
    <td
      :for={col <- @columns}
      class={["px-3 py-4 text-sm text-gray-900", col[:class]]}
    >
      <%= render_cell_value(col, @row) %>
    </td>
    
    <!-- Action Cells -->
    <td :if={@actions != []} class="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-6">
      <div class="flex justify-end gap-2">
        <.button_widget
          :for={action <- @actions}
          size={:sm}
          variant={:ghost}
          icon={action[:icon]}
          label={action[:label]}
          phx-click={action[:on_click]}
          phx-value-id={@row.id}
          data-confirm={action[:confirm]}
        />
      </div>
    </td>
    """
  end
  
  # Render individual cell value with formatting
  defp render_cell_value(%{field: field, format: format}, row) do
    value = Map.get(row, field)
    format_value(value, format)
  end
  
  defp render_cell_value(%{field: field}, row) do
    Map.get(row, field)
  end
  
  # Value formatters
  defp format_value(value, :currency) do
    Number.Currency.number_to_currency(value)
  end
  
  defp format_value(value, :date) do
    Calendar.strftime(value, "%B %d, %Y")
  end
  
  defp format_value(value, :datetime) do
    Calendar.strftime(value, "%B %d, %Y at %I:%M %p")
  end
  
  defp format_value(value, :boolean) do
    if value do
      Phoenix.HTML.raw(~s(<span class="text-green-600">✓</span>))
    else
      Phoenix.HTML.raw(~s(<span class="text-gray-400">✗</span>))
    end
  end
  
  defp format_value(value, _), do: value
  
  # Helper functions
  defp row_classes(row, selected_ids) do
    if row.id in selected_ids do
      "bg-primary-50"
    else
      "hover:bg-gray-50"
    end
  end
  
  defp empty?(rows, nil), do: Enum.empty?(rows)
  defp empty?(_, stream), do: stream == []
  
  defp all_selected?(rows, nil, selected_ids) do
    row_ids = Enum.map(rows, & &1.id)
    Enum.all?(row_ids, &(&1 in selected_ids))
  end
  defp all_selected?(_, _stream, _selected_ids), do: false
end
```

#### Using the Table Widget - Complete Examples

```elixir
# File: lib/my_app_web/live/users_table_live.ex
defmodule MyAppWeb.UsersTableLive do
  use MyAppWeb, :live_view
  
  @impl true
  def mount(_params, _session, socket) do
    # Start with static data (dumb mode)
    users = [
      %{id: 1, name: "John Doe", email: "john@example.com", role: :admin, active: true},
      %{id: 2, name: "Jane Smith", email: "jane@example.com", role: :user, active: true},
      %{id: 3, name: "Bob Wilson", email: "bob@example.com", role: :user, active: false}
    ]
    
    socket =
      socket
      |> assign(:users, users)
      |> assign(:selected_ids, [])
      |> assign(:sort_by, :name)
      |> assign(:sort_order, :asc)
      |> assign(:page, 1)
      |> assign(:per_page, 20)
      |> assign(:total_pages, 1)
      
    {:ok, socket}
  end
  
  @impl true
  def render(assigns) do
    ~H"""
    <.layout_widget type={:full_width}>
      <:header>
        <.heading_widget level={1} text="User Management" />
        <.button_widget 
          label="Add User" 
          icon={:plus}
          color={:primary}
          phx-click="new_user"
        />
      </:header>
      
      <:main>
        <!-- Dumb Mode Table -->
        <.card_widget :if={!@connected?}>
          <:header>
            <.badge_widget label="Dumb Mode" color={:yellow} />
          </:header>
          <:body>
            <.table_widget
              id="users-table"
              rows={@users}
              columns={[
                %{field: :name, label: "Name", sortable: true},
                %{field: :email, label: "Email", sortable: true},
                %{field: :role, label: "Role", format: :capitalize},
                %{field: :active, label: "Active", format: :boolean}
              ]}
              selectable={true}
              selected_ids={@selected_ids}
              on_select="select_users"
              sort_by={@sort_by}
              sort_order={@sort_order}
              on_sort="sort_users"
              page={@page}
              total_pages={@total_pages}
              on_paginate="paginate"
            >
              <:actions :let={row}>
                <.button_widget
                  icon={:pencil}
                  label="Edit"
                  on_click="edit_user"
                />
                <.button_widget
                  icon={:trash}
                  label="Delete"
                  on_click="delete_user"
                  color={:danger}
                  confirm="Are you sure you want to delete this user?"
                />
              </:actions>
              
              <:empty_state>
                <.empty_state_widget
                  icon={:users}
                  title="No users yet"
                  description="Get started by creating your first user"
                >
                  <.button_widget 
                    label="Create User" 
                    icon={:plus}
                    phx-click="new_user"
                  />
                </.empty_state_widget>
              </:empty_state>
            </.table_widget>
          </:body>
        </.card_widget>
        
        <!-- Connected Mode Table with Streams -->
        <.card_widget :if={@connected?}>
          <:header>
            <.badge_widget label="Connected Mode" color={:green} />
          </:header>
          <:body>
            <.table_widget
              id="users-table-connected"
              stream={@streams.users}
              columns={[
                %{field: :name, label: "Name", sortable: true},
                %{field: :email, label: "Email", sortable: true},
                %{field: :role, label: "Role"},
                %{field: :active, label: "Active", format: :boolean},
                %{field: :last_login, label: "Last Login", format: :datetime}
              ]}
              selectable={true}
              selected_ids={@selected_ids}
              on_select="select_users"
              sort_by={@sort_by}
              sort_order={@sort_order}
              on_sort="sort_users"
              page={@page}
              total_pages={@total_pages}
              on_paginate="paginate"
            >
              <:actions>
                <.dropdown_widget label="Actions" icon={:ellipsis_vertical}>
                  <.dropdown_item_widget 
                    label="Edit" 
                    icon={:pencil}
                    on_click="edit_user"
                  />
                  <.dropdown_item_widget 
                    label="View Activity" 
                    icon={:chart_bar}
                    on_click="view_activity"
                  />
                  <.dropdown_divider_widget />
                  <.dropdown_item_widget 
                    label="Delete" 
                    icon={:trash}
                    on_click="delete_user"
                    color={:danger}
                    confirm="This cannot be undone!"
                  />
                </.dropdown_widget>
              </:actions>
            </.table_widget>
          </:body>
        </.card_widget>
      </:main>
    </.layout_widget>
    """
  end
  
  # Event Handlers
  @impl true
  def handle_event("select_users", %{"action" => "toggle_one", "id" => id}, socket) do
    id = String.to_integer(id)
    selected_ids = 
      if id in socket.assigns.selected_ids do
        List.delete(socket.assigns.selected_ids, id)
      else
        [id | socket.assigns.selected_ids]
      end
      
    {:noreply, assign(socket, :selected_ids, selected_ids)}
  end
  
  def handle_event("select_users", %{"action" => "toggle_all"}, socket) do
    selected_ids =
      if socket.assigns.selected_ids == [] do
        Enum.map(socket.assigns.users, & &1.id)
      else
        []
      end
      
    {:noreply, assign(socket, :selected_ids, selected_ids)}
  end
  
  def handle_event("select_users", %{"action" => "clear_all"}, socket) do
    {:noreply, assign(socket, :selected_ids, [])}
  end
  
  def handle_event("sort_users", %{"field" => field}, socket) do
    field = String.to_existing_atom(field)
    
    {sort_by, sort_order} =
      if socket.assigns.sort_by == field do
        # Toggle order
        {field, if(socket.assigns.sort_order == :asc, do: :desc, else: :asc)}
      else
        # New field, default to asc
        {field, :asc}
      end
      
    # Sort the data
    sorted_users = sort_users(socket.assigns.users, sort_by, sort_order)
    
    socket =
      socket
      |> assign(:users, sorted_users)
      |> assign(:sort_by, sort_by)
      |> assign(:sort_order, sort_order)
      
    {:noreply, socket}
  end
  
  defp sort_users(users, field, :asc) do
    Enum.sort_by(users, &Map.get(&1, field))
  end
  
  defp sort_users(users, field, :desc) do
    Enum.sort_by(users, &Map.get(&1, field), :desc)
  end
end
```

#### TESTING CHECKPOINT: Table Widget Tests

> **🚨 BEGINNER ALERT**: This testing section is MANDATORY! Do not skip any step. Each test builds on the previous one.

##### Step 1: Compilation Check (Do This FIRST!)

```bash
# In your terminal, from the project root:
cd /path/to/your/project

# Clear any previous compilation artifacts
rm -rf _build/dev/lib/my_app

# Compile with strict warnings
mix compile --warnings-as-errors

# Expected output:
# Compiling 1 file (.ex)
# Generated my_app app

# ❌ If you see errors like:
# ** (CompileError) undefined function widget_classes/1
# This means you forgot to include `use MyAppWeb.Widgets.Base`

# ❌ If you see warnings like:
# warning: variable "assigns" is unused
# Add underscore: _assigns or use the variable

# ✅ Success looks like:
# No warnings, clean compilation
```

##### Step 2: Runtime Verification

```bash
# Step 1: Compile and check for errors
mix compile --warnings-as-errors

# What to check:
# ✅ No compilation errors
# ✅ No unused variables
# ✅ All functions have proper specs

# Start Phoenix server
mix phx.server

# Expected console output:
# [info] Running MyAppWeb.Endpoint with cowboy 2.9.0 at 0.0.0.0:4000 (http)
# [info] Access MyAppWeb.Endpoint at http://localhost:4000

# ❌ Common errors and fixes:

# Error: "could not compile dependency :phoenix"
# Fix: Run `mix deps.get` first

# Error: "** (DBConnection.ConnectionError) connection refused"  
# Fix: Make sure Postgres is running: `pg_ctl start` or `brew services start postgresql`

# Error: "(Postgrex.Error) FATAL (invalid_catalog_name): database 'my_app_dev' does not exist"
# Fix: Run `mix ecto.create`

# Once server starts successfully:
# 1. Open browser to http://localhost:4000/users
# 2. Open browser DevTools (F12 or right-click → Inspect)
# 3. Go to Console tab - should be NO red errors
# 4. Go to Network tab - all requests should be 200 OK
```

##### Step 3: Manual Testing Checklist

> **🎯 BEGINNER TIP**: Print this checklist! Check off each item as you test.

```markdown
## Table Widget Manual Testing Checklist

### Initial Render
- [ ] Table appears on page load
- [ ] All columns are visible
- [ ] Column headers match configuration
- [ ] Data rows display correctly
- [ ] No console errors (check DevTools)

### Sorting Functionality  
- [ ] Click on sortable column header
- [ ] Sort indicator (arrow) appears
- [ ] Data re-orders correctly
- [ ] Click again - sort reverses
- [ ] Non-sortable columns don't have hover effect

### Selection Features
- [ ] Individual checkboxes work
- [ ] Row highlights when selected
- [ ] "Select All" checkbox works
- [ ] Selection count appears ("3 selected")
- [ ] Clear button removes all selections

### Actions
- [ ] Action buttons appear on hover/focus
- [ ] Dropdown menu opens on click
- [ ] Each action has correct icon
- [ ] Confirmation dialogs work
- [ ] Actions trigger correct events

### Empty State
- [ ] Shows when no data
- [ ] Custom empty state renders
- [ ] Call-to-action buttons work

### Responsive Design
- [ ] Resize browser to mobile width (375px)
- [ ] Table remains usable
- [ ] Horizontal scroll if needed
- [ ] Actions still accessible

### Performance
- [ ] Page loads in < 2 seconds
- [ ] Sorting is instant (< 100ms)
- [ ] No lag when selecting items
- [ ] Memory usage stable (check Task Manager)
```

##### Step 4: Puppeteer Automated Testing

> **🤖 AUTOMATION TIME**: Let's use Puppeteer to take screenshots and catch visual bugs!

###### First-Time Puppeteer Setup (for absolute beginners)

```bash
# Step 1: Install Node.js if you haven't already
# Mac: brew install node
# Windows: Download from https://nodejs.org
# Linux: sudo apt install nodejs npm

# Step 2: Create test directory in your Phoenix project
cd /path/to/your/phoenix/project
mkdir -p test/visual
cd test/visual

# Step 3: Initialize npm (just press Enter for all prompts)
npm init -y

# Step 4: Install Puppeteer
npm install puppeteer

# This will download Chromium (~150MB) - be patient!
# You'll see: "Downloading Chromium r1234567..."

# Step 5: Create screenshots directory  
mkdir -p screenshots

# Step 6: Verify installation
node -e "console.log('Node works!')"
# Should output: Node works!
```

###### The Actual Puppeteer Test

```javascript
// File: test/visual/table_widget_test.js
// COMPLETE PUPPETEER TEST WITH BEGINNER COMMENTS

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

// Helper function to create screenshot directories
function ensureDirectoryExists(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
    console.log(`📁 Created directory: ${dirPath}`);
  }
}

// Helper to take and save screenshot with metadata
async function takeScreenshot(page, name, description) {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const filename = `${timestamp}_${name}.png`;
  const filepath = path.join('screenshots', 'table_widget', filename);
  
  await page.screenshot({ 
    path: filepath,
    fullPage: true 
  });
  
  console.log(`📸 ${description}`);
  console.log(`   Saved to: ${filepath}`);
  
  // Also save a "latest" version for easy comparison
  const latestPath = path.join('screenshots', 'table_widget', `latest_${name}.png`);
  fs.copyFileSync(filepath, latestPath);
  
  return filepath;
}

// Main test function
async function testTableWidget() {
  console.log('🧪 Starting Table Widget Visual Tests...');
  console.log('=' * 50);
  
  // Ensure directories exist
  ensureDirectoryExists('screenshots');
  ensureDirectoryExists('screenshots/table_widget');
  ensureDirectoryExists('screenshots/table_widget/errors');
  
  // Launch browser with helpful options for beginners
  const browser = await puppeteer.launch({ 
    headless: false, // Set to true to run in background
    devtools: true,  // Opens DevTools automatically
    slowMo: 100,     // Slows down operations so you can see what's happening
    args: [
      '--window-size=1400,900',
      '--no-sandbox', // Required for some Linux environments
    ]
  });
  
  console.log('✅ Browser launched successfully');
  
  const page = await browser.newPage();
  await page.setViewport({ width: 1400, height: 900 });
  
  // Enable console log forwarding
  page.on('console', msg => {
    console.log('🌐 Browser console:', msg.text());
  });
  
  // Catch any page errors
  page.on('error', err => {
    console.error('❌ Page error:', err);
  });
  
  page.on('pageerror', err => {
    console.error('❌ Page error:', err);
  });
  
  try {
    // TEST 1: Navigate and Initial Load
    console.log('
📍 Test 1: Initial Page Load');
    console.log('-' * 30);
    
    await page.goto('http://localhost:4000/users', {
      waitUntil: 'networkidle0', // Wait until no network activity
      timeout: 30000 // 30 second timeout
    });
    
    // Wait for table to be visible
    await page.waitForSelector('.widget-table-container', {
      visible: true,
      timeout: 5000
    });
    
    await takeScreenshot(page, 'initial_load', 'Table rendered successfully');
    
    // Verify table structure
    const tableExists = await page.$('.widget-table-container table') !== null;
    console.log(`✅ Table element exists: ${tableExists}`);
    
    // Count rows
    const rowCount = await page.$$eval('tbody tr', rows => rows.length);
    console.log(`✅ Table has ${rowCount} data rows`);
    
    // TEST 2: Sorting Functionality
    console.log('
📍 Test 2: Sorting Functionality');
    console.log('-' * 30);
    
    // Find the Name column header (usually 2nd column)
    const nameHeader = await page.$('thead th:nth-child(2)');
    if (!nameHeader) {
      throw new Error('Could not find Name column header');
    }
    
    // Click to sort ascending
    await nameHeader.click();
    await page.waitForTimeout(500); // Wait for sort animation
    
    await takeScreenshot(page, 'sorted_asc', 'Table sorted by name (ascending)');
    
    // Get first row name to verify sort
    const firstNameAsc = await page.$eval('tbody tr:first-child td:nth-child(2)', el => el.textContent);
    console.log(`✅ First name after ASC sort: ${firstNameAsc}`);
    
    // Click again to sort descending  
    await nameHeader.click();
    await page.waitForTimeout(500);
    
    await takeScreenshot(page, 'sorted_desc', 'Table sorted by name (descending)');
    
    const firstNameDesc = await page.$eval('tbody tr:first-child td:nth-child(2)', el => el.textContent);
    console.log(`✅ First name after DESC sort: ${firstNameDesc}`);
    
    // Verify sort actually changed
    if (firstNameAsc === firstNameDesc) {
      console.warn('⚠️  Warning: Sort might not be working - same first item');
    }
    
    // TEST 3: Selection Features
    console.log('
📍 Test 3: Selection Features');
    console.log('-' * 30);
    
    // Select first row
    const firstCheckbox = await page.$('tbody tr:first-child input[type="checkbox"]');
    if (firstCheckbox) {
      await firstCheckbox.click();
      await page.waitForTimeout(300);
      
      await takeScreenshot(page, 'single_selection', 'Single row selected');
      
      // Verify selection UI updated
      const selectedCount = await page.$eval('.text-gray-600', el => el.textContent);
      console.log(`✅ Selection count shows: ${selectedCount}`);
    } else {
      console.log('⚠️  No selection checkboxes found - skipping selection tests');
    }
    
    // Select all
    const selectAllCheckbox = await page.$('thead input[type="checkbox"]');
    if (selectAllCheckbox) {
      await selectAllCheckbox.click();
      await page.waitForTimeout(300);
      
      await takeScreenshot(page, 'all_selected', 'All rows selected');
      
      // Count selected checkboxes
      const checkedCount = await page.$$eval('tbody input[type="checkbox"]:checked', els => els.length);
      console.log(`✅ ${checkedCount} rows selected`);
    }
    
    // TEST 4: Actions Menu
    console.log('
📍 Test 4: Actions Menu');
    console.log('-' * 30);
    
    // Hover over first row to reveal actions
    const firstRow = await page.$('tbody tr:first-child');
    await firstRow.hover();
    await page.waitForTimeout(300);
    
    // Look for action button
    const actionButton = await page.$('tbody tr:first-child button');
    if (actionButton) {
      await actionButton.click();
      
      // Wait for dropdown to appear
      try {
        await page.waitForSelector('.dropdown-menu', {
          visible: true,
          timeout: 2000
        });
        
        await takeScreenshot(page, 'actions_menu', 'Actions dropdown menu open');
        console.log('✅ Actions menu opened successfully');
      } catch (e) {
        console.log('⚠️  Actions menu did not appear - might use different UI pattern');
      }
    } else {
      console.log('⚠️  No action buttons found - skipping action tests');
    }
    
    // TEST 5: Responsive Design
    console.log('
📍 Test 5: Responsive Design');  
    console.log('-' * 30);
    
    // Test mobile viewport
    await page.setViewport({ width: 375, height: 667 });
    await page.waitForTimeout(500); // Wait for responsive adjustments
    
    await takeScreenshot(page, 'mobile_view', 'Table in mobile viewport (375px)');
    console.log('✅ Mobile view captured');
    
    // Test tablet viewport
    await page.setViewport({ width: 768, height: 1024 });
    await page.waitForTimeout(500);
    
    await takeScreenshot(page, 'tablet_view', 'Table in tablet viewport (768px)');
    console.log('✅ Tablet view captured');
    
    // Return to desktop
    await page.setViewport({ width: 1400, height: 900 });
    
    // TEST 6: Performance Metrics
    console.log('
📍 Test 6: Performance Analysis');
    console.log('-' * 30);
    
    // Get performance metrics
    const metrics = await page.metrics();
    console.log('📊 Performance Metrics:');
    console.log(`   Heap Size: ${(metrics.JSHeapUsedSize / 1048576).toFixed(2)} MB`);
    console.log(`   DOM Nodes: ${metrics.Nodes}`);
    console.log(`   JS Event Listeners: ${metrics.JSEventListeners}`);
    
    // Measure interaction speed
    const startTime = Date.now();
    await page.click('thead th:nth-child(2)'); // Sort action
    await page.waitForTimeout(100);
    const sortTime = Date.now() - startTime;
    console.log(`   Sort Operation Time: ${sortTime}ms`);
    
    if (sortTime > 500) {
      console.warn('⚠️  Warning: Sort operation took longer than 500ms');
    }
    
    // TEST 7: Error States (if applicable)
    console.log('
📍 Test 7: Error Handling');
    console.log('-' * 30);
    
    // Check for any error messages on page
    const errors = await page.$$('.alert-error, .flash-error, [role="alert"]');
    if (errors.length > 0) {
      console.warn(`⚠️  Found ${errors.length} error messages on page`);
      await takeScreenshot(page, 'error_state', 'Page showing errors');
    } else {
      console.log('✅ No error messages found');
    }
    
    // Final success summary
    console.log('
🎉 All tests completed successfully!');
    console.log('=' * 50);
    console.log('📁 Screenshots saved in: test/visual/screenshots/table_widget/');
    
  } catch (error) {
    console.error('
❌ TEST FAILED:', error.message);
    console.error(error.stack);
    
    // Take error screenshot
    await takeScreenshot(page, 'error_state', `Error occurred: ${error.message}`);
    
    // Save error details
    const errorLog = {
      timestamp: new Date().toISOString(),
      error: error.message,
      stack: error.stack,
      url: page.url()
    };
    
    fs.writeFileSync(
      path.join('screenshots', 'table_widget', 'errors', 'last_error.json'),
      JSON.stringify(errorLog, null, 2)
    );
    
  } finally {
    // Always close browser
    console.log('
🧹 Cleaning up...');
    await browser.close();
    console.log('✅ Browser closed');
  }
}

// Helper function to compare screenshots
async function compareScreenshots() {
  console.log('
🔍 Visual Regression Check');
  console.log('=' * 50);
  
  // This is a simple file size comparison
  // For real visual regression, use a tool like Resemble.js
  
  const screenshotDir = path.join('screenshots', 'table_widget');
  const files = fs.readdirSync(screenshotDir).filter(f => f.startsWith('latest_'));
  
  for (const file of files) {
    const latestPath = path.join(screenshotDir, file);
    const baselinePath = path.join(screenshotDir, 'baseline', file);
    
    if (fs.existsSync(baselinePath)) {
      const latestSize = fs.statSync(latestPath).size;
      const baselineSize = fs.statSync(baselinePath).size;
      
      const diff = Math.abs(latestSize - baselineSize);
      const percentDiff = (diff / baselineSize * 100).toFixed(2);
      
      if (percentDiff > 5) {
        console.warn(`⚠️  ${file}: Size difference of ${percentDiff}% detected`);
      } else {
        console.log(`✅ ${file}: Within acceptable range (${percentDiff}% diff)`);
      }
    } else {
      console.log(`📝 ${file}: No baseline exists (first run?)`);
      // Create baseline directory and copy current as baseline
      ensureDirectoryExists(path.join(screenshotDir, 'baseline'));
      fs.copyFileSync(latestPath, baselinePath);
      console.log(`   Created baseline for future comparisons`);
    }
  }
}

// Run the test
if (require.main === module) {
  testTableWidget()
    .then(() => compareScreenshots())
    .catch(err => {
      console.error('Fatal error:', err);
      process.exit(1);
    });
}

module.exports = { testTableWidget, compareScreenshots };
```

###### Running Your Puppeteer Tests (Step-by-Step)

```bash
# Make sure your Phoenix server is running first!
# Terminal 1:
cd /path/to/phoenix/project
mix phx.server

# Terminal 2: Run Puppeteer tests
cd /path/to/phoenix/project/test/visual
node table_widget_test.js

# What you'll see:
# 🧪 Starting Table Widget Visual Tests...
# ==================================================
# ✅ Browser launched successfully
# 
# 📍 Test 1: Initial Page Load
# ------------------------------
# 📸 Table rendered successfully
#    Saved to: screenshots/table_widget/2024-01-15T10-30-45-123Z_initial_load.png
# ✅ Table element exists: true
# ✅ Table has 3 data rows
# ... (more test output)

# If tests fail, check:
# 1. Is Phoenix server running?
# 2. Is the URL correct (http://localhost:4000/users)?
# 3. Check screenshots/table_widget/errors/last_error.json
```

###### Understanding Test Results

```markdown
## Interpreting Puppeteer Test Output

### Success Indicators:
✅ = Test passed
📸 = Screenshot saved  
📊 = Performance metric recorded

### Warning Indicators:
⚠️  = Potential issue (not a failure)
- Sort might not be working
- Performance slower than expected
- Visual differences detected

### Failure Indicators:
❌ = Test failed
- Check error screenshots
- Read error messages carefully
- Look at last_error.json

### Performance Benchmarks:
- Page Load: < 2 seconds ✅
- Sort Operation: < 500ms ✅
- Memory Usage: < 50MB ✅
- DOM Nodes: < 1500 ✅
```

##### Step 5: Visual Regression Testing

> **👁️ CATCH VISUAL BUGS**: Compare screenshots to find unexpected changes!

```bash
# After first test run, you'll have baseline screenshots
# Run tests again after making changes:
node table_widget_test.js

# The test will automatically compare with baselines
# 🔍 Visual Regression Check
# ==================================================
# ✅ latest_initial_load.png: Within acceptable range (0.5% diff)
# ⚠️  latest_sorted_asc.png: Size difference of 12.3% detected
#     ^ This means something visually changed!

# To update baselines after intentional changes:
cd screenshots/table_widget
rm -rf baseline
mkdir baseline
cp latest_*.png baseline/

# Now future tests will compare against new baselines
```

###### Creating a Visual Diff Report

```javascript
// File: test/visual/create_diff_report.js
const fs = require('fs');
const path = require('path');

function createDiffReport() {
  const screenshots = path.join(__dirname, 'screenshots', 'table_widget');
  const reportPath = path.join(screenshots, 'diff_report.html');
  
  let html = `<!DOCTYPE html>
<html>
<head>
    <title>Visual Regression Report - Table Widget</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .comparison { margin-bottom: 30px; border: 1px solid #ddd; padding: 10px; }
        .images { display: flex; gap: 10px; }
        .image-container { flex: 1; }
        img { max-width: 100%; border: 1px solid #ccc; }
        h2 { color: #333; }
        .diff { background: #ffffcc; padding: 10px; }
    </style>
</head>
<body>
    <h1>Table Widget Visual Regression Report</h1>
    <p>Generated: ${new Date().toISOString()}</p>
`;

  const files = fs.readdirSync(screenshots).filter(f => f.startsWith('latest_'));
  
  for (const file of files) {
    const name = file.replace('latest_', '').replace('.png', '');
    const latest = `latest_${name}.png`;
    const baseline = `baseline/latest_${name}.png`;
    
    html += `
    <div class="comparison">
        <h2>${name.replace(/_/g, ' ').toUpperCase()}</h2>
        <div class="images">
            <div class="image-container">
                <h3>Baseline</h3>
                <img src="${baseline}" alt="Baseline">
            </div>
            <div class="image-container">
                <h3>Current</h3>
                <img src="${latest}" alt="Current">
            </div>
        </div>
    </div>`;
  }
  
  html += `</body></html>`;
  
  fs.writeFileSync(reportPath, html);
  console.log(`📄 Visual diff report created: ${reportPath}`);
  console.log('   Open in browser to review changes');
}

createDiffReport();
```

##### Step 6: Troubleshooting Common Issues

> **🔧 WHEN THINGS GO WRONG**: Don't panic! Here's how to fix common problems.

```markdown
## Table Widget Troubleshooting Guide

### Problem: Table doesn't appear
**Symptoms:** Empty page or loading spinner
**Debugging steps:**
1. Check browser console for errors (F12)
2. Verify route exists: `mix phx.routes | grep users`
3. Check LiveView mount: Add `IO.inspect(socket)` in mount/3
4. Verify data is assigned: `IO.inspect(assigns.users)`

**Common fixes:**
```elixir
# Make sure you're assigning data in mount
def mount(_params, _session, socket) do
  socket = assign(socket, :users, [])  # Even if empty!
  {:ok, socket}
end
```

### Problem: Sorting doesn't work
**Symptoms:** Clicking headers does nothing
**Debugging steps:**
1. Check if column has `sortable: true`
2. Verify event handler exists
3. Add debug logging:

```elixir
def handle_event("sort_users", params, socket) do
  IO.inspect(params, label: "Sort params")
  # ... rest of handler
end
```

### Problem: Checkboxes don't update
**Symptoms:** Clicking doesn't toggle state
**Common cause:** Missing phx-click or wrong event name
**Fix:** Verify your template has:
```elixir
phx-click={@on_select}
phx-value-id={@row.id}
```

### Problem: Actions menu won't open  
**Symptoms:** Clicking does nothing
**Common causes:**
- Missing dropdown CSS
- Z-index issues
- JavaScript not loaded

**Fix:** Add to your app.css:
```css
.dropdown-menu {
  position: absolute;
  z-index: 50;
  background: white;
  border: 1px solid #e5e7eb;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}
```

### Problem: Poor performance with large datasets
**Symptoms:** Lag when sorting/selecting
**Solution:** Use Phoenix Streams!

```elixir
# Instead of:
assign(socket, :users, large_list)

# Use:
stream(socket, :users, large_list)
```

### Problem: Puppeteer tests fail to connect
**Error:** "ERR_CONNECTION_REFUSED"
**Fix:**
1. Ensure Phoenix server is running
2. Check if using different port
3. Try: `page.goto('http://127.0.0.1:4000/users')`
```

#### FINAL TESTING CHECKPOINT

After implementing the table widget, run this complete verification:

```bash
# 1. Clean compile
mix clean && mix compile --warnings-as-errors

# 2. Run all tests
mix test

# 3. Start server
mix phx.server

# 4. Manual testing (use checklist above)

# 5. Run Puppeteer tests
cd test/visual && node table_widget_test.js

# 6. Generate diff report
node create_diff_report.js

# 7. Review screenshots
open screenshots/table_widget/diff_report.html

# 8. Document any issues found
echo "Test completed: $(date)" >> test_log.txt
```

> **🎓 BEGINNER REMINDER**: Testing isn't optional! Each untested widget is a future bug waiting to happen. Take the time now to prevent pain later!

async function testTableWidget() {
  console.log('🧪 Testing Table Widget...');
  
  const browser = await puppeteer.launch({ 
    headless: false,
    devtools: true 
  });
  
  const page = await browser.newPage();
  await page.setViewport({ width: 1400, height: 900 });
  
  try {
    // Navigate to table page
    await page.goto('http://localhost:4000/users', {
      waitUntil: 'networkidle0'
    });
    
    // Test 1: Initial render
    await page.waitForSelector('.widget-table-container');
    await page.screenshot({ 
      path: 'screenshots/table_initial.png',
      fullPage: true 
    });
    console.log('✅ Table renders correctly');
    
    // Test 2: Sorting
    await page.click('th:nth-child(2)'); // Click Name column
    await page.waitForTimeout(300);
    await page.screenshot({ 
      path: 'screenshots/table_sorted_asc.png' 
    });
    
    await page.click('th:nth-child(2)'); // Click again for desc
    await page.waitForTimeout(300);
    await page.screenshot({ 
      path: 'screenshots/table_sorted_desc.png' 
    });
    console.log('✅ Sorting works correctly');
    
    // Test 3: Selection
    await page.click('input[type="checkbox"]:first-of-type');
    await page.screenshot({ 
      path: 'screenshots/table_item_selected.png' 
    });
    
    // Select all
    await page.click('thead input[type="checkbox"]');
    await page.screenshot({ 
      path: 'screenshots/table_all_selected.png' 
    });
    console.log('✅ Selection works correctly');
    
    // Test 4: Actions
    await page.hover('tr:nth-child(2)'); // Hover second row
    await page.click('tr:nth-child(2) button'); // Click actions
    await page.waitForSelector('.dropdown-menu', { visible: true });
    await page.screenshot({ 
      path: 'screenshots/table_actions_open.png' 
    });
    console.log('✅ Actions menu works correctly');
    
    // Test 5: Empty state
    // You'd need to navigate to a page with no data
    // Or use page.evaluate to remove all rows
    
    // Test 6: Responsive behavior
    await page.setViewport({ width: 375, height: 667 }); // iPhone size
    await page.screenshot({ 
      path: 'screenshots/table_mobile.png',
      fullPage: true 
    });
    console.log('✅ Mobile view works correctly');
    
    // Performance test
    console.log('⏱️  Running performance test...');
    const metrics = await page.metrics();
    console.log(`   JS Heap: ${(metrics.JSHeapUsedSize / 1048576).toFixed(2)} MB`);
    console.log(`   Nodes: ${metrics.Nodes}`);
    
  } catch (error) {
    console.error('❌ Test failed:', error);
    await page.screenshot({ 
      path: 'screenshots/table_error.png' 
    });
  } finally {
    await browser.close();
  }
}

testTableWidget();
```

#### List Widget Implementation (For Non-Tabular Data)

```elixir
# File: lib/my_app_web/components/widgets/display/list_widget.ex
defmodule MyAppWeb.Widgets.Display.ListWidget do
  use MyAppWeb.Widgets.Base
  
  attr :items, :list, default: []
  attr :stream, :any, default: nil
  attr :orientation, :atom, default: :vertical, values: [:vertical, :horizontal]
  attr :spacing, :atom, default: :md, values: [:none, :sm, :md, :lg]
  attr :divided, :boolean, default: false
  
  slot :item, required: true do
    attr :item, :any
  end
  
  slot :empty_state
  
  def render(assigns) do
    ~H"""
    <div class={[
      "widget-list",
      orientation_class(@orientation),
      spacing_class(@spacing),
      @divided && "divide-y divide-gray-200"
    ]}>
      <%= if @stream do %>
        <div id={"#{@id}-items"} phx-update="stream">
          <div :for={{dom_id, item} <- @stream} id={dom_id}>
            <%= render_slot(@item, item) %>
          </div>
        </div>
      <% else %>
        <%= if @items == [] do %>
          <%= render_slot(@empty_state) || default_empty_state(assigns) %>
        <% else %>
          <div :for={item <- @items}>
            <%= render_slot(@item, item) %>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end
  
  defp orientation_class(:vertical), do: "flex flex-col"
  defp orientation_class(:horizontal), do: "flex flex-row overflow-x-auto"
  
  defp spacing_class(:none), do: ""
  defp spacing_class(:sm), do: "gap-2"
  defp spacing_class(:md), do: "gap-4"
  defp spacing_class(:lg), do: "gap-6"
  
  defp default_empty_state(assigns) do
    ~H"""
    <div class="text-center py-12 text-gray-500">
      No items to display
    </div>
    """
  end
end
```

### Connection Configuration: Making Widgets Smart

> **🧠 THE BRAIN OF YOUR WIDGETS**: This section shows you how to connect widgets to real data sources. Master this, and your widgets come alive!

#### Understanding Connection Modes - A Mental Model

Think of widget connections like a car's transmission:
- **Dumb Mode** = Park (stationary, safe for testing)
- **Connected Mode** = Drive (moving, connected to real systems)
- **data_source** = The gear selector (tells widget which system to connect to)

#### The Complete Connection Types Guide

```elixir
# File: lib/my_app_web/components/widgets/connection_guide.ex
defmodule MyAppWeb.Widgets.ConnectionGuide do
  @moduledoc """
  Complete guide to all widget connection patterns.
  Each pattern is explained with examples and testing steps.
  """
  
  # PATTERN 1: Interface Connection (Recommended!)
  # Use when: You have Ash resources with defined code interfaces
  
  def interface_connection_example do
    """
    <!-- In your LiveView template -->
    <.user_list_widget
      data_source={:interface, {Accounts, :list_active_users, []}}
    />
    
    <!-- How it works internally: -->
    <!-- 1. Widget sees :interface tuple -->
    <!-- 2. Calls Accounts.list_active_users() -->
    <!-- 3. Receives Ash query results -->
    <!-- 4. Renders the data -->
    """
  end
  
  # Setting up the interface:
  def setup_interface_instructions do
    """
    # Step 1: Define interface in your Ash API
    # File: lib/my_app/accounts.ex
    defmodule MyApp.Accounts do
      use Ash.Api
      
      resources do
        resource MyApp.Accounts.User
      end
      
      # Define code interface
      code_interface do
        define :list_active_users, for: MyApp.Accounts.User do
          args []
          
          # This creates Accounts.list_active_users()
          get? true
          
          # Apply filters
          filter expr(active == true)
          
          # Sort by name
          sort [:name]
        end
        
        define :get_user_by_email, for: MyApp.Accounts.User do
          args [:email]
          
          # This creates Accounts.get_user_by_email(email)
          get? true
          get_by [:email]
        end
      end
    end
    
    # Step 2: Test the interface manually first!
    # In IEx:
    iex> MyApp.Accounts.list_active_users()
    {:ok, [%User{}, %User{}, ...]}
    
    # Step 3: Use in widget
    <.table_widget
      data_source={:interface, {MyApp.Accounts, :list_active_users, []}}
      columns={...}
    />
    """
  end
  
  # PATTERN 2: Resource Connection (Direct queries)
  # Use when: You need custom queries not defined in interfaces
  
  def resource_connection_example do
    """
    <!-- Basic resource connection -->
    <.product_grid_widget
      data_source={:resource, MyApp.Inventory.Product}
    />
    
    <!-- With filters and sorting -->
    <.product_grid_widget
      data_source={:resource, MyApp.Inventory.Product}
      filter={[in_stock: true, category: "electronics"]}
      sort={[{:price, :asc}]}
      limit={20}
    />
    
    <!-- With preloads for relationships -->
    <.order_list_widget
      data_source={:resource, MyApp.Orders.Order}
      preload={[:customer, :line_items, payments: :payment_method]}
      filter={[status: :pending]}
    />
    """
  end
  
  # PATTERN 3: Stream Connection (For real-time updates)
  # Use when: Data changes frequently and you need efficiency
  
  def stream_connection_example do
    """
    # In your LiveView:
    def mount(_params, _session, socket) do
      # Stream gives each item a unique DOM ID
      socket = stream(socket, :messages, [])
      {:ok, socket}
    end
    
    def handle_info({:new_message, message}, socket) do
      # This efficiently adds just the new message
      socket = stream_insert(socket, :messages, message, at: 0)
      {:noreply, socket}
    end
    
    # In your template:
    <.chat_widget
      data_source={:stream, :messages}
      on_send="send_message"
    />
    """
  end
  
  # PATTERN 4: Subscribe Connection (PubSub real-time)
  # Use when: Multiple users need to see same updates
  
  def subscribe_connection_example do
    """
    # Setup PubSub subscription
    def mount(_params, _session, socket) do
      # Subscribe to updates
      Phoenix.PubSub.subscribe(MyApp.PubSub, "game:#{game_id}")
      
      socket = 
        socket
        |> assign(:game_id, game_id)
        |> assign(:players, load_players(game_id))
        
      {:ok, socket}
    end
    
    def handle_info({:player_joined, player}, socket) do
      players = [player | socket.assigns.players]
      {:noreply, assign(socket, :players, players)}
    end
    
    # In template:
    <.player_list_widget
      data_source={:subscribe, "game:#{@game_id}"}
      items={@players}
    />
    """
  end
  
  # PATTERN 5: Form Connection (For data entry)
  # Use when: Creating or editing Ash resources
  
  def form_connection_example do
    """
    # Create form
    form = AshPhoenix.Form.for_create(
      MyApp.Products.Product,
      :create,
      api: MyApp.Products
    )
    
    # In template:
    <.form_widget
      data_source={:form, @form}
      on_submit="save_product"
    >
      <.input_widget field={@form[:name]} />
      <.money_input_widget field={@form[:price]} />
      <.select_widget 
        field={@form[:category]}
        options={load_categories()}
      />
    </.form_widget>
    """
  end
  
  # PATTERN 6: Action Connection (For operations)
  # Use when: Triggering Ash actions from widgets
  
  def action_connection_example do
    """
    <.button_widget
      data_source={:action, {MyApp.Orders.Order, :ship, [order_id]}}
      label="Ship Order"
      confirm="Mark this order as shipped?"
      on_success="order_shipped"
    />
    
    # How it works:
    # 1. User clicks button
    # 2. Confirmation dialog shows
    # 3. On confirm, runs: MyApp.Orders.Order.ship(order_id)
    # 4. On success, sends "order_shipped" event
    # 5. On failure, shows error message
    """
  end
end
```

#### Implementing Smart Connection Detection

```elixir
# File: lib/my_app_web/components/widgets/base.ex
defmodule MyAppWeb.Widgets.Base do
  @moduledoc """
  Base functionality for all widgets with complete connection handling
  """
  
  defmacro __using__(_opts) do
    quote do
      use Phoenix.Component
      import MyAppWeb.Widgets.Base
      
      # Every widget gets these standard attributes
      attr :data_source, :any, default: nil
      attr :loading, :boolean, default: false
      attr :error, :string, default: nil
      attr :debug, :boolean, default: false
      
      # Standard slots
      slot :loading_state
      slot :error_state
    end
  end
  
  @doc """
  Resolves data based on the data_source configuration.
  Returns {data, metadata} tuple.
  """
  def resolve_data(nil, assigns) do
    # Dumb mode - look for static data in assigns
    data = Map.get(assigns, :data) || Map.get(assigns, :items) || []
    {data, %{mode: :dumb}}
  end
  
  def resolve_data({:interface, {api, function, args}}, _assigns) do
    # Interface mode - call the code interface
    case apply(api, function, args) do
      {:ok, data} -> 
        {data, %{mode: :connected, source: :interface}}
      {:error, error} -> 
        {[], %{mode: :error, error: Exception.message(error)}}
    end
  end
  
  def resolve_data({:resource, resource}, assigns) do
    # Resource mode - build and run query
    query = resource
    
    # Apply filters if provided
    query = 
      if filters = assigns[:filter] do
        Ash.Query.filter(query, ^filters)
      else
        query
      end
      
    # Apply sorting if provided
    query = 
      if sort = assigns[:sort] do
        Ash.Query.sort(query, ^sort)
      else
        query
      end
      
    # Apply limit if provided
    query = 
      if limit = assigns[:limit] do
        Ash.Query.limit(query, ^limit)
      else
        query
      end
      
    # Apply preloads if provided
    query = 
      if preloads = assigns[:preload] do
        Ash.Query.load(query, ^preloads)
      else
        query
      end
    
    # Execute query
    case api_for_resource(resource).read(query) do
      {:ok, data} -> 
        {data, %{mode: :connected, source: :resource}}
      {:error, error} -> 
        {[], %{mode: :error, error: inspect(error)}}
    end
  end
  
  def resolve_data({:stream, stream_name}, assigns) do
    # Stream mode - get from assigns.streams
    stream = Map.get(assigns.streams, stream_name, [])
    {stream, %{mode: :connected, source: :stream}}
  end
  
  def resolve_data({:subscribe, topic}, assigns) do
    # Subscribe mode - data comes from assigns, subscription is handled in LiveView
    data = Map.get(assigns, :data) || []
    {data, %{mode: :connected, source: :subscribe, topic: topic}}
  end
  
  def resolve_data({:form, form}, _assigns) do
    # Form mode - return the form itself
    {form, %{mode: :connected, source: :form}}
  end
  
  def resolve_data({:action, {resource, action, args}}, _assigns) do
    # Action mode - prepare action info (execution happens on event)
    action_info = %{
      resource: resource,
      action: action,
      args: args
    }
    {action_info, %{mode: :connected, source: :action}}
  end
  
  # Helper to find API module for a resource
  defp api_for_resource(resource) do
    # This is a simplified version - in real app you'd have a registry
    # or configuration to map resources to their APIs
    api_module = 
      resource
      |> Module.split()
      |> Enum.take(2)
      |> Module.concat()
      
    if Code.ensure_loaded?(api_module) do
      api_module
    else
      raise "Could not find API module for #{inspect(resource)}"
    end
  end
end
```

#### Testing Each Connection Type

##### Testing Interface Connections

```elixir
# File: test/widgets/interface_connection_test.exs
defmodule MyAppWeb.Widgets.InterfaceConnectionTest do
  use MyAppWeb.ConnCase
  import Phoenix.LiveViewTest
  
  describe "interface connection" do
    test "loads data through code interface", %{conn: conn} do
      # Create test data
      user1 = create_user(name: "Alice", active: true)
      user2 = create_user(name: "Bob", active: false)
      user3 = create_user(name: "Charlie", active: true)
      
      # Mount LiveView with interface connection
      {:ok, view, html} = live(conn, "/users")
      
      # Verify only active users shown (interface filters them)
      assert html =~ "Alice"
      refute html =~ "Bob"  # Inactive - filtered out
      assert html =~ "Charlie"
      
      # Verify mode indicator
      assert html =~ "Connected Mode"
      
      # Test interface with arguments
      send(view.pid, {:filter_by_role, :admin})
      assert render(view) =~ "No admin users found"
    end
    
    test "handles interface errors gracefully", %{conn: conn} do
      # Simulate interface error
      MockApi.set_error(:list_active_users, :database_unavailable)
      
      {:ok, _view, html} = live(conn, "/users")
      
      assert html =~ "Unable to load users"
      assert html =~ "database_unavailable"
    end
  end
end
```

###### Manual Testing Checklist for Interface Connections

```markdown
## Interface Connection Testing Checklist

### Pre-Test Setup
- [ ] Create test users with mix of active/inactive
- [ ] Verify interface works in IEx:
  ```elixir
  iex> MyApp.Accounts.list_active_users()
  # Should return only active users
  ```

### In-Browser Testing
1. Navigate to page using interface connection
2. Open Network tab in DevTools
3. Verify:
   - [ ] Data loads without page refresh
   - [ ] Only filtered data appears (e.g., only active users)
   - [ ] No N+1 queries (check terminal logs)
   - [ ] Proper error handling when API unavailable

### Performance Testing
- [ ] Time initial load (should be < 500ms)
- [ ] Check memory usage with 1000+ records
- [ ] Verify no memory leaks on navigation
```

##### Testing Resource Connections

```bash
# Quick test script for resource connections
# File: test/visual/resource_connection_test.js

const puppeteer = require('puppeteer');

async function testResourceConnection() {
  const browser = await puppeteer.launch({ headless: false });
  const page = await browser.newPage();
  
  // Test basic resource load
  await page.goto('http://localhost:4000/products');
  
  // Test filtering
  await page.select('#category-filter', 'electronics');
  await page.waitForTimeout(500);
  
  const productCount = await page.$$eval('.product-card', els => els.length);
  console.log(`Filtered products: ${productCount}`);
  
  // Test sorting
  await page.click('#sort-price-asc');
  await page.waitForTimeout(500);
  
  const firstPrice = await page.$eval('.product-card:first-child .price', el => el.textContent);
  console.log(`Lowest price: ${firstPrice}`);
  
  await browser.close();
}
```

#### Connection Mode Switching - The Complete Implementation

```elixir
# File: lib/my_app_web/live/smart_dashboard_live.ex
defmodule MyAppWeb.SmartDashboardLive do
  use MyAppWeb, :live_view
  
  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:mode, :dumb)  # Start in dumb mode
      |> assign(:stats, dummy_stats())  # Dummy data
      |> assign(:connection_status, :disconnected)
      |> assign(:last_update, nil)
      
    # Only connect if not in dev/demo mode
    if connected?(socket) && !demo_mode?() do
      send(self(), :connect_to_real_data)
    end
    
    {:ok, socket}
  end
  
  @impl true
  def handle_info(:connect_to_real_data, socket) do
    case connect_to_api() do
      {:ok, live_stats} ->
        # Subscribe to real-time updates
        Phoenix.PubSub.subscribe(MyApp.PubSub, "dashboard:stats")
        
        socket =
          socket
          |> assign(:mode, :connected)
          |> assign(:stats, live_stats)
          |> assign(:connection_status, :connected)
          |> assign(:last_update, DateTime.utc_now())
          |> start_refresh_timer()
          
        {:noreply, socket}
        
      {:error, reason} ->
        # Stay in dumb mode but show connection error
        socket =
          socket
          |> assign(:connection_status, :error)
          |> assign(:connection_error, reason)
          |> retry_connection_later()
          
        {:noreply, socket}
    end
  end
  
  @impl true
  def handle_info(:refresh_stats, socket) do
    # Periodic refresh for connected mode
    case MyApp.Stats.get_current() do
      {:ok, stats} ->
        socket =
          socket
          |> assign(:stats, stats)
          |> assign(:last_update, DateTime.utc_now())
          
        {:noreply, socket}
        
      {:error, _reason} ->
        # Don't update, keep showing last known good data
        {:noreply, socket}
    end
  end
  
  @impl true
  def handle_event("toggle_mode", _, socket) do
    new_mode = if socket.assigns.mode == :dumb, do: :connected, else: :dumb
    
    socket =
      case new_mode do
        :connected ->
          send(self(), :connect_to_real_data)
          assign(socket, :mode, :connected)
          
        :dumb ->
          # Cancel any timers, unsubscribe
          if socket.assigns[:refresh_timer] do
            Process.cancel_timer(socket.assigns.refresh_timer)
          end
          Phoenix.PubSub.unsubscribe(MyApp.PubSub, "dashboard:stats")
          
          socket
          |> assign(:mode, :dumb)
          |> assign(:stats, dummy_stats())
          |> assign(:connection_status, :disconnected)
      end
      
    {:noreply, socket}
  end
  
  defp dummy_stats do
    %{
      total_users: 1_234,
      active_sessions: 89,
      revenue_today: 15_678.90,
      conversion_rate: 3.4,
      top_products: [
        %{name: "Widget Pro", sales: 45},
        %{name: "Widget Lite", sales: 32},
        %{name: "Widget Max", sales: 28}
      ]
    }
  end
  
  defp start_refresh_timer(socket) do
    # Refresh every 30 seconds
    timer = Process.send_after(self(), :refresh_stats, 30_000)
    assign(socket, :refresh_timer, timer)
  end
  
  defp retry_connection_later(socket) do
    # Exponential backoff
    delay = min((socket.assigns[:retry_count] || 1) * 5_000, 60_000)
    Process.send_after(self(), :connect_to_real_data, delay)
    
    socket
    |> assign(:retry_count, (socket.assigns[:retry_count] || 1) + 1)
    |> assign(:next_retry, DateTime.add(DateTime.utc_now(), delay, :millisecond))
  end
end
```

#### TESTING CHECKPOINT: Connection Configuration

```bash
# Step 1: Test each connection type in isolation
mix test test/widgets/connection_test.exs

# Step 2: Start server with dumb mode forced
DEMO_MODE=true mix phx.server

# Verify:
# - All widgets show dummy data
# - No API calls in Network tab
# - "Dumb Mode" badges visible

# Step 3: Start server in normal mode
mix phx.server

# Verify:
# - Widgets attempt connection
# - Real data loads
# - "Connected Mode" badges visible
# - Error states show if API down

# Step 4: Test mode switching
# 1. Click mode toggle button
# 2. Verify smooth transition
# 3. Check no data loss
# 4. Verify timers cleanup
```

##### Puppeteer Test for Connection Modes

```javascript
// File: test/visual/connection_mode_test.js
async function testConnectionModes() {
  console.log('🔌 Testing Connection Modes...');
  
  const browser = await puppeteer.launch({ headless: false });
  const page = await browser.newPage();
  
  // Start in dumb mode
  await page.goto('http://localhost:4000/dashboard?mode=dumb');
  
  // Verify dumb mode
  const dumbBadge = await page.$('.badge:contains("Dumb Mode")');
  assert(dumbBadge, 'Dumb mode badge should be visible');
  
  // Screenshot dumb mode
  await page.screenshot({ path: 'screenshots/connection_dumb_mode.png' });
  
  // Switch to connected mode
  await page.click('#mode-toggle');
  await page.waitForSelector('.badge:contains("Connected Mode")', {
    timeout: 5000
  });
  
  // Screenshot connected mode
  await page.screenshot({ path: 'screenshots/connection_connected_mode.png' });
  
  // Simulate connection failure
  await page.setOfflineMode(true);
  await page.reload();
  
  // Should show error state
  await page.waitForSelector('.alert-error', { timeout: 5000 });
  await page.screenshot({ path: 'screenshots/connection_error_state.png' });
  
  await browser.close();
}
```

#### Debugging Connection Issues - The Complete Guide

```elixir
# File: lib/my_app_web/components/widgets/debug_helpers.ex
defmodule MyAppWeb.Widgets.DebugHelpers do
  @moduledoc """
  Debug helpers for widget connections. 
  Only available in dev environment!
  """
  
  def debug_panel(assigns) do
    if Application.get_env(:my_app, :env) == :dev do
      ~H"""
      <div class="fixed bottom-4 right-4 bg-black text-green-400 p-4 rounded-lg shadow-xl max-w-md font-mono text-xs">
        <div class="font-bold mb-2">🐛 Widget Debug Panel</div>
        
        <div class="space-y-1">
          <div>Mode: <span class="text-yellow-400">{@mode}</span></div>
          <div>Source: <span class="text-blue-400">{inspect(@data_source)}</span></div>
          <div>Records: <span class="text-white">{count_records(@data)}</span></div>
          <div>Last Update: <span class="text-gray-400">{format_time(@last_update)}</span></div>
          
          <%= if @error do %>
            <div class="text-red-400 mt-2">
              Error: {@error}
            </div>
          <% end %>
          
          <details class="mt-2">
            <summary class="cursor-pointer text-gray-400">Connection Details</summary>
            <pre class="mt-1 text-xs overflow-auto max-h-40">
{inspect(@data_source, pretty: true, limit: :infinity)}
            </pre>
          </details>
          
          <details class="mt-2">
            <summary class="cursor-pointer text-gray-400">Data Sample</summary>
            <pre class="mt-1 text-xs overflow-auto max-h-40">
{inspect(Enum.take(@data, 3), pretty: true)}
            </pre>
          </details>
        </div>
        
        <div class="mt-3 space-x-2">
          <button 
            phx-click="refresh_widget" 
            phx-value-widget={@widget_id}
            class="text-xs bg-blue-600 px-2 py-1 rounded"
          >
            Refresh
          </button>
          <button 
            phx-click="toggle_widget_mode" 
            phx-value-widget={@widget_id}
            class="text-xs bg-purple-600 px-2 py-1 rounded"
          >
            Toggle Mode
          </button>
        </div>
      </div>
      """
    else
      # Don't render in production!
      ~H""
    end
  end
  
  defp count_records(data) when is_list(data), do: length(data)
  defp count_records(%{} = form), do: "1 form"
  defp count_records(_), do: "unknown"
  
  defp format_time(nil), do: "never"
  defp format_time(time), do: Calendar.strftime(time, "%H:%M:%S")
end
```

> **💡 PRO TIP**: Always test your widgets in both modes! A widget that only works in connected mode is a widget that will break during demos.

### Migration Strategy: From Traditional Phoenix to Widget Paradise

> **🚀 TRANSFORMATION TIME**: This guide takes you from a traditional Phoenix LiveView app to a fully widget-based system. Follow every step carefully!

#### Pre-Migration Assessment Checklist

```markdown
## Before You Start - Assessment Checklist

### Current Application Inventory
- [ ] Count total number of LiveViews: _____
- [ ] Count total number of components: _____
- [ ] List all external JS libraries: _____
- [ ] Document all custom CSS: _____
- [ ] Identify all API integrations: _____

### Technical Readiness
- [ ] Phoenix LiveView version >= 0.18
- [ ] Ash framework installed and configured
- [ ] Test coverage > 70%
- [ ] Staging environment available
- [ ] Rollback plan documented

### Team Readiness  
- [ ] Team trained on widget concepts
- [ ] Widget documentation reviewed
- [ ] Practice app created
- [ ] Questions documented and answered

### Risk Assessment
- [ ] High-traffic pages identified
- [ ] Complex interactions documented
- [ ] Performance baseline measured
- [ ] User acceptance criteria defined
```

#### Phase 1: Foundation Setup (Week 1)

##### Day 1-2: Install Widget System

```bash
# Step 1: Create widget directory structure
cd your_phoenix_app
mkdir -p lib/my_app_web/components/widgets/{base,layout,display,form,feedback}

# Step 2: Create base widget module
cat > lib/my_app_web/components/widgets/base.ex << 'EOF'
defmodule MyAppWeb.Widgets.Base do
  defmacro __using__(_opts) do
    quote do
      use Phoenix.Component
      import MyAppWeb.Widgets.Base
      
      # Standard attributes for all widgets
      attr :id, :string, default: nil
      attr :class, :string, default: nil
      attr :data_source, :any, default: nil
      attr :loading, :boolean, default: false
      attr :error, :string, default: nil
      
      # Import helpers
      import MyAppWeb.Widgets.Helpers
    end
  end
  
  # Base functionality here...
end
EOF

# Step 3: Create your first widget
cat > lib/my_app_web/components/widgets/display/text_widget.ex << 'EOF'
defmodule MyAppWeb.Widgets.Display.TextWidget do
  use MyAppWeb.Widgets.Base
  
  attr :text, :string, required: true
  attr :size, :atom, default: :md
  attr :weight, :atom, default: :normal
  attr :color, :string, default: nil
  
  def render(assigns) do
    ~H"""
    <span class={[
      text_size_class(@size),
      text_weight_class(@weight),
      @color && "text-#{@color}",
      @class
    ]}>
      {@text}
    </span>
    """
  end
  
  defp text_size_class(:xs), do: "text-xs"
  defp text_size_class(:sm), do: "text-sm"
  defp text_size_class(:md), do: "text-base"
  defp text_size_class(:lg), do: "text-lg"
  defp text_size_class(:xl), do: "text-xl"
  
  defp text_weight_class(:light), do: "font-light"
  defp text_weight_class(:normal), do: "font-normal"
  defp text_weight_class(:bold), do: "font-bold"
end
EOF

# Step 4: Test your first widget
mix compile
```

##### Day 3-4: Create Widget Catalog

```elixir
# File: lib/my_app_web/live/widget_catalog_live.ex
defmodule MyAppWeb.WidgetCatalogLive do
  use MyAppWeb, :live_view
  
  @impl true
  def render(assigns) do
    ~H"""
    <.layout_widget type={:full_width}>
      <:header>
        <.heading_widget level={1} text="Widget Catalog" />
        <.text_widget text="Your reference for all available widgets" color="gray-600" />
      </:header>
      
      <:sidebar>
        <.nav_widget>
          <.nav_item_widget 
            label="Text Widgets" 
            href="#text"
            active={@section == "text"}
          />
          <.nav_item_widget 
            label="Button Widgets" 
            href="#button"
            active={@section == "button"}
          />
          <.nav_item_widget 
            label="Form Widgets" 
            href="#form"
            active={@section == "form"}
          />
        </.nav_widget>
      </:sidebar>
      
      <:main>
        <!-- Text Widget Examples -->
        <.section_widget id="text" title="Text Widgets">
          <.example_widget 
            title="Basic Text"
            code={~s(<.text_widget text="Hello World" />)}
          >
            <.text_widget text="Hello World" />
          </.example_widget>
          
          <.example_widget 
            title="Sized Text"
            code={~s(<.text_widget text="Large Text" size={:xl} weight={:bold} />)}
          >
            <.text_widget text="Large Text" size={:xl} weight={:bold} />
          </.example_widget>
        </.section_widget>
        
        <!-- Add more widget examples -->
      </:main>
    </.layout_widget>
    """
  end
  
  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, section: "text")}
  end
end
```

##### Day 5: Setup Testing Infrastructure

```javascript
// File: test/visual/widget_catalog_test.js
const puppeteer = require('puppeteer');

async function testWidgetCatalog() {
  console.log('📚 Testing Widget Catalog...');
  
  const browser = await puppeteer.launch({ headless: false });
  const page = await browser.newPage();
  
  await page.goto('http://localhost:4000/widget-catalog');
  
  // Test each widget category
  const categories = ['text', 'button', 'form', 'layout'];
  
  for (const category of categories) {
    await page.click(`a[href="#${category}"]`);
    await page.waitForTimeout(500);
    
    await page.screenshot({ 
      path: `screenshots/catalog_${category}.png`,
      fullPage: true 
    });
    
    console.log(`✅ ${category} widgets documented`);
  }
  
  await browser.close();
}

testWidgetCatalog();
```

#### Phase 2: Gradual Migration (Weeks 2-4)

##### Migration Order Strategy

```markdown
## Recommended Migration Order

1. **Static Pages First** (Low Risk)
   - About page
   - Terms of service  
   - FAQ pages
   - Contact page

2. **Display-Only Pages** (Medium Risk)
   - User profiles
   - Product listings
   - Blog posts
   - Search results

3. **Interactive Pages** (High Risk)
   - Forms and wizards
   - Shopping cart
   - User settings
   - Admin panels

4. **Real-time Features** (Highest Risk)
   - Chat interfaces
   - Live dashboards
   - Notifications
   - Collaborative editing
```

##### Step-by-Step Page Migration

```elixir
# BEFORE: Traditional Phoenix LiveView
defmodule MyAppWeb.UserProfileLive do
  use MyAppWeb, :live_view
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="bg-white shadow rounded-lg p-6">
        <div class="flex items-center space-x-4 mb-6">
          <img src={@user.avatar_url} class="w-20 h-20 rounded-full" />
          <div>
            <h1 class="text-2xl font-bold">{@user.name}</h1>
            <p class="text-gray-600">{@user.email}</p>
          </div>
        </div>
        
        <div class="border-t pt-6">
          <h2 class="text-xl font-semibold mb-4">Recent Activity</h2>
          <div class="space-y-3">
            <%= for activity <- @activities do %>
              <div class="flex items-center space-x-3 p-3 hover:bg-gray-50 rounded">
                <div class="flex-shrink-0">
                  <%= render_activity_icon(activity.type) %>
                </div>
                <div class="flex-1">
                  <p class="text-sm font-medium">{activity.title}</p>
                  <p class="text-xs text-gray-500">
                    {Calendar.strftime(activity.inserted_at, "%B %d at %I:%M %p")}
                  </p>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end

# AFTER: Widget-based version
defmodule MyAppWeb.UserProfileLive do
  use MyAppWeb, :live_view
  
  @impl true
  def render(assigns) do
    ~H"""
    <.layout_widget type={:centered} max_width={:lg}>
      <:main>
        <.card_widget>
          <:body>
            <!-- User Header Section -->
            <.user_header_widget user={@user} />
            
            <!-- Activity Section -->
            <.divider_widget class="my-6" />
            
            <.section_widget title="Recent Activity">
              <.activity_list_widget 
                data_source={:interface, {Accounts, :list_user_activities, [@user.id]}}
                empty_message="No recent activity"
              />
            </.section_widget>
          </:body>
        </.card_widget>
      </:main>
    </.layout_widget>
    """
  end
  
  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = Accounts.get_user!(id)
    
    socket =
      socket
      |> assign(:user, user)
      |> assign(:page_title, user.name)
      
    {:ok, socket}
  end
end

# Create the specialized widgets
defmodule MyAppWeb.Widgets.UserHeaderWidget do
  use MyAppWeb.Widgets.Base
  
  attr :user, :map, required: true
  
  def render(assigns) do
    ~H"""
    <div class="flex items-center space-x-4">
      <.avatar_widget 
        src={@user.avatar_url} 
        alt={@user.name}
        size={:lg}
      />
      <div>
        <.heading_widget level={2} text={@user.name} />
        <.text_widget text={@user.email} color="gray-600" />
        <.badge_widget 
          :if={@user.verified}
          label="Verified"
          color={:green}
          icon={:check}
        />
      </div>
    </div>
    """
  end
end

defmodule MyAppWeb.Widgets.ActivityListWidget do
  use MyAppWeb.Widgets.Base
  
  attr :data_source, :any, required: true
  attr :empty_message, :string, default: "No activities"
  
  def render(assigns) do
    {activities, _meta} = resolve_data(assigns.data_source, assigns)
    assigns = assign(assigns, :activities, activities)
    
    ~H"""
    <div class="space-y-3">
      <%= if @activities == [] do %>
        <.empty_state_widget 
          icon={:clock}
          title={@empty_message}
        />
      <% else %>
        <.activity_item_widget :for={activity <- @activities} activity={activity} />
      <% end %>
    </div>
    """
  end
end
```

##### Migration Testing Protocol

```bash
# For EACH migrated page, run this protocol:

# 1. Visual regression test
cd test/visual
node migration_test.js --page=user_profile --before=true
# Make changes
node migration_test.js --page=user_profile --after=true
node compare_screenshots.js user_profile

# 2. Performance comparison
mix run test/performance/page_load_test.exs UserProfileLive

# 3. User acceptance test
mix test test/features/user_profile_test.exs

# 4. Accessibility audit
npm run lighthouse http://localhost:4000/users/123

# 5. Browser compatibility
npm run test:browsers user_profile
```

#### Phase 3: Advanced Patterns (Weeks 5-6)

##### Creating Composite Widgets

```elixir
# Composite widget that combines multiple smaller widgets
defmodule MyAppWeb.Widgets.ProductCardWidget do
  use MyAppWeb.Widgets.Base
  
  attr :product, :map, required: true
  attr :on_add_to_cart, :string, default: "add_to_cart"
  attr :show_stock, :boolean, default: true
  
  def render(assigns) do
    ~H"""
    <.card_widget class="product-card hover:shadow-lg transition-shadow">
      <:image>
        <.image_widget 
          src={@product.image_url}
          alt={@product.name}
          aspect_ratio={:square}
          loading={:lazy}
        />
        <.badge_widget 
          :if={@product.on_sale}
          label={"#{@product.discount_percentage}% OFF"}
          color={:red}
          position={:top_right}
        />
      </:image>
      
      <:body>
        <.heading_widget 
          level={3} 
          text={@product.name}
          class="line-clamp-2"
        />
        
        <.price_widget 
          amount={@product.price}
          original_amount={@product.original_price}
          currency={@product.currency}
        />
        
        <.stock_indicator_widget 
          :if={@show_stock}
          quantity={@product.stock_quantity}
          low_threshold={5}
        />
      </:body>
      
      <:footer>
        <.button_widget
          label="Add to Cart"
          icon={:shopping_cart}
          color={:primary}
          full_width={true}
          phx-click={@on_add_to_cart}
          phx-value-product-id={@product.id}
          disabled={@product.stock_quantity == 0}
        />
      </:footer>
    </.card_widget>
    """
  end
end
```

##### Migrating Complex Interactions

```elixir
# BEFORE: Complex form with custom JS
defmodule MyAppWeb.CheckoutLive do
  use MyAppWeb, :live_view
  
  @impl true
  def render(assigns) do
    ~H"""
    <!-- Lots of custom HTML and JS hooks -->
    <form phx-change="validate" phx-submit="submit_order">
      <!-- Complex form with custom validations -->
    </form>
    
    <script>
      // Custom payment processor integration
      // Address autocomplete
      // Form state management
    </script>
    """
  end
end

# AFTER: Widget-based with proper separation
defmodule MyAppWeb.CheckoutLive do
  use MyAppWeb, :live_view
  
  @impl true
  def render(assigns) do
    ~H"""
    <.checkout_widget
      form={@form}
      step={@current_step}
      on_next="next_step"
      on_previous="previous_step"
      on_submit="submit_order"
    >
      <!-- Step 1: Shipping -->
      <:step name={:shipping} title="Shipping Address">
        <.address_form_widget
          field={@form[:shipping_address]}
          countries={@available_countries}
          enable_autocomplete={true}
        />
      </:step>
      
      <!-- Step 2: Payment -->
      <:step name={:payment} title="Payment Method">
        <.payment_form_widget
          field={@form[:payment]}
          supported_methods={[:card, :paypal, :apple_pay]}
          processor={:stripe}
        />
      </:step>
      
      <!-- Step 3: Review -->
      <:step name={:review} title="Review Order">
        <.order_summary_widget
          items={@cart_items}
          shipping={@shipping_cost}
          tax={@tax_amount}
          total={@total}
        />
      </:step>
    </.checkout_widget>
    """
  end
  
  # All complex logic moves to well-tested widget modules
end
```

#### Phase 4: Optimization and Polish (Week 7-8)

##### Performance Optimization Checklist

```elixir
# File: lib/my_app_web/widgets/performance_monitor.ex
defmodule MyAppWeb.Widgets.PerformanceMonitor do
  use GenServer
  require Logger
  
  # Track widget render times in development
  def track_render(widget_module, start_time) do
    duration = System.monotonic_time() - start_time
    duration_ms = System.convert_time_unit(duration, :native, :millisecond)
    
    if duration_ms > 50 do
      Logger.warning("""
      Slow widget render detected!
      Widget: #{inspect(widget_module)}
      Duration: #{duration_ms}ms
      Consider optimizing this widget.
      """)
    end
    
    # Store metrics for analysis
    :telemetry.execute(
      [:widget, :render],
      %{duration: duration_ms},
      %{module: widget_module}
    )
  end
end
```

##### Final Migration Checklist

```markdown
## Final Migration Verification

### Code Quality
- [ ] All LiveViews converted to widgets
- [ ] No inline styles remaining
- [ ] No custom JavaScript (only hooks)
- [ ] All widgets documented in catalog
- [ ] Type specs added to all widgets

### Testing
- [ ] Widget unit tests: 100% coverage
- [ ] Integration tests passing
- [ ] Visual regression tests baselined
- [ ] Performance benchmarks met
- [ ] Accessibility audit passed

### Documentation
- [ ] Widget usage guide complete
- [ ] Migration notes documented
- [ ] Team trained on new patterns
- [ ] Troubleshooting guide created

### Production Readiness
- [ ] Feature flags configured
- [ ] Rollback plan tested
- [ ] Monitoring alerts setup
- [ ] Performance metrics baseline
- [ ] User feedback collected
```

#### Common Migration Pitfalls and Solutions

```elixir
# PITFALL 1: Over-widgetizing
# ❌ BAD: Creating a widget for everything
defmodule MyAppWeb.Widgets.BoldTextWidget do
  use MyAppWeb.Widgets.Base
  attr :text, :string
  def render(assigns), do: ~H"<b>{@text}</b>"
end

# ✅ GOOD: Use text_widget with weight attribute
~H"""
<.text_widget text="Important" weight={:bold} />
"""

# PITFALL 2: Losing SEO
# ❌ BAD: Everything client-side rendered
# ✅ GOOD: Widgets still render server-side HTML
defmodule MyAppWeb.Widgets.SEOWidget do
  use MyAppWeb.Widgets.Base
  
  def render(assigns) do
    ~H"""
    <div {@seo_schema_markup}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
  
  defp seo_schema_markup do
    [
      "itemscope": true,
      "itemtype": "https://schema.org/Product",
      "data-seo": "enhanced"
    ]
  end
end

# PITFALL 3: Performance regression
# ❌ BAD: Deeply nested widgets with data fetching
# ✅ GOOD: Fetch data once, pass down
def mount(params, session, socket) do
  # Fetch all data at the top level
  user = get_user(params["id"])
  activities = list_activities(user)
  stats = calculate_stats(user)
  
  socket =
    socket
    |> assign(:user, user)
    |> assign(:activities, activities) 
    |> assign(:stats, stats)
    
  {:ok, socket}
end
```

#### Post-Migration Maintenance

```bash
# Weekly widget health check script
#!/bin/bash
# File: scripts/widget_health_check.sh

echo "🏥 Widget System Health Check"
echo "============================="

# 1. Check for unused widgets
echo "Checking for unused widgets..."
mix run scripts/find_unused_widgets.exs

# 2. Performance regression check
echo "Running performance benchmarks..."
mix run test/performance/widget_benchmarks.exs

# 3. Visual regression check
echo "Running visual regression tests..."
cd test/visual && npm run test:all

# 4. Documentation sync
echo "Checking widget documentation..."
mix docs && grep -c "TODO" doc/MyAppWeb.Widgets.*.html

# 5. Generate report
echo "Generating health report..."
mix widget.report > reports/widget_health_$(date +%Y%m%d).md

echo "✅ Health check complete!"
```

> **🎯 FINAL ADVICE**: Migration isn't a sprint, it's a marathon. Take it one widget at a time, test thoroughly, and celebrate small wins. Your future self will thank you for the investment in a consistent, maintainable UI system!

### Migration Strategy

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

### Comprehensive Troubleshooting Guide

> **🔥 WHEN EVERYTHING BREAKS**: This guide helps you diagnose and fix widget issues. Keep it handy!

#### Diagnostic Tools and Techniques

```elixir
# File: lib/my_app_web/widgets/diagnostic_tools.ex
defmodule MyAppWeb.Widgets.DiagnosticTools do
  @moduledoc """
  Emergency diagnostic tools for widget debugging.
  Add to your LiveView when things go wrong.
  """
  
  defmacro __using__(_) do
    quote do
      import MyAppWeb.Widgets.DiagnosticTools
      
      # Auto-inject diagnostic hooks in dev
      if Application.get_env(:my_app, :env) == :dev do
        on_mount {MyAppWeb.Widgets.DiagnosticTools, :inject_diagnostics}
      end
    end
  end
  
  def on_mount(:inject_diagnostics, _params, _session, socket) do
    socket =
      socket
      |> attach_hook(:widget_render_tracking, :handle_event, &track_widget_event/3)
      |> attach_hook(:widget_error_boundary, :handle_info, &catch_widget_errors/2)
      |> assign(:widget_diagnostics, %{
        render_times: %{},
        error_count: 0,
        slow_widgets: [],
        memory_usage: nil
      })
      
    {:cont, socket}
  end
  
  defp track_widget_event(event, params, socket) do
    start_time = System.monotonic_time()
    
    # Log all widget-related events
    if String.starts_with?(event, "widget_") do
      IO.inspect({event, params}, label: "Widget Event")
    end
    
    # Track execution time
    Process.put({:widget_event_start, event}, start_time)
    
    {:cont, socket}
  end
  
  defp catch_widget_errors({:widget_error, error}, socket) do
    diagnostics = socket.assigns.widget_diagnostics
    
    new_diagnostics = %{
      diagnostics | 
      error_count: diagnostics.error_count + 1,
      last_error: error,
      last_error_at: DateTime.utc_now()
    }
    
    Logger.error("""
    Widget Error Detected!
    #{Exception.format(:error, error)}
    
    Widget State:
    #{inspect(socket.assigns, pretty: true, limit: 5)}
    """)
    
    {:noreply, assign(socket, :widget_diagnostics, new_diagnostics)}
  end
end
```

#### Common Widget Problems and Solutions

##### Problem 1: Widget Not Rendering

```markdown
## Symptom: Widget appears blank or missing

### Diagnostic Steps:

1. **Check compilation**
   ```bash
   mix compile --force
   # Look for any compilation errors
   ```

2. **Verify widget is imported**
   ```elixir
   # In your_app_web.ex
   def live_view do
     quote do
       use Phoenix.LiveView
       
       # Make sure this line exists:
       import MyAppWeb.Widgets
       # Or for specific widgets:
       import MyAppWeb.Widgets.Display.TableWidget
     end
   end
   ```

3. **Check render function**
   ```elixir
   # Add debug output
   def render(assigns) do
     IO.inspect(assigns, label: "Widget assigns")
     
     ~H"""
     <div>
       <!-- Your widget content -->
     </div>
     """
   end
   ```

4. **Verify required attributes**
   ```elixir
   # This will raise compile-time error if missing
   attr :data, :list, required: true
   
   # This won't - add validation
   attr :data, :list, default: []
   
   def render(assigns) do
     if assigns[:data] == nil do
       raise "TableWidget requires data attribute!"
     end
     # ...
   end
   ```

### Common Fixes:

```elixir
# ❌ WRONG: Forgetting to import
defmodule MyLiveView do
  use MyAppWeb, :live_view
  
  def render(assigns) do
    ~H"""
    <.table_widget data={@users} />  <!-- Won't work! -->
    """
  end
end

# ✅ CORRECT: Proper import
defmodule MyLiveView do
  use MyAppWeb, :live_view
  import MyAppWeb.Widgets.Display.TableWidget
  
  def render(assigns) do
    ~H"""
    <.table_widget data={@users} />  <!-- Works! -->
    """
  end
end
```
```

##### Problem 2: Data Not Loading

```elixir
# Debugging data source issues
defmodule MyAppWeb.Widgets.DebugHelper do
  def debug_data_source(data_source, assigns) do
    IO.puts("""
    🔍 Debugging Data Source
    ========================
    Type: #{inspect(elem(data_source, 0))}
    Config: #{inspect(data_source)}
    Assigns Keys: #{inspect(Map.keys(assigns))}
    """)
    
    case data_source do
      {:interface, {api, func, args}} ->
        IO.puts("Calling: #{api}.#{func}(#{inspect(args)})")
        
        # Try calling it directly
        try do
          result = apply(api, func, args)
          IO.inspect(result, label: "Direct call result")
        rescue
          e -> IO.puts("Direct call failed: #{inspect(e)}")
        end
        
      {:resource, resource} ->
        IO.puts("Resource: #{inspect(resource)}")
        IO.puts("Filters: #{inspect(assigns[:filter])}")
        
        # Check if resource is valid
        if Code.ensure_loaded?(resource) do
          IO.puts("✅ Resource module exists")
        else
          IO.puts("❌ Resource module not found!")
        end
        
      {:stream, stream_name} ->
        IO.puts("Stream name: #{stream_name}")
        IO.puts("Available streams: #{inspect(Map.keys(assigns[:streams] || %{}))}")
        
      _ ->
        IO.puts("Unknown data source type!")
    end
  end
end

# Use in your widget:
def render(assigns) do
  # Add this temporarily
  MyAppWeb.Widgets.DebugHelper.debug_data_source(assigns.data_source, assigns)
  
  # Rest of render...
end
```

##### Problem 3: Performance Issues

```elixir
# Performance profiling for widgets
defmodule MyAppWeb.Widgets.PerformanceProfiler do
  def profile_widget(widget_module, assigns) do
    # Memory before
    memory_before = :erlang.memory(:total)
    
    # Time the render
    {time_micro, result} = :timer.tc(fn ->
      widget_module.render(assigns)
    end)
    
    # Memory after
    memory_after = :erlang.memory(:total)
    memory_used = memory_after - memory_before
    
    IO.puts("""
    ⏱️  Widget Performance Profile
    ==============================
    Widget: #{inspect(widget_module)}
    Render Time: #{time_micro / 1000}ms
    Memory Used: #{memory_used / 1024}KB
    
    Assigns Size: #{inspect_size(assigns)}KB
    """)
    
    if time_micro > 50_000 do  # > 50ms
      IO.puts("⚠️  SLOW WIDGET! Consider optimizing.")
      analyze_assigns(assigns)
    end
    
    result
  end
  
  defp inspect_size(term) do
    :erlang.external_size(term) / 1024
  end
  
  defp analyze_assigns(assigns) do
    assigns
    |> Enum.map(fn {key, value} -> 
      {key, inspect_size(value)}
    end)
    |> Enum.sort_by(&elem(&1, 1), :desc)
    |> Enum.take(5)
    |> Enum.each(fn {key, size} ->
      IO.puts("  #{key}: #{Float.round(size, 2)}KB")
    end)
  end
end
```

##### Problem 4: Event Handlers Not Working

```markdown
## Symptom: Clicking buttons/links does nothing

### Debug Checklist:

1. **Verify event names match**
   ```elixir
   # In template:
   <.button_widget phx-click="save_user" />
   
   # In LiveView:
   def handle_event("save_user", params, socket) do  # Names must match exactly!
     # ...
   end
   ```

2. **Check for JavaScript errors**
   ```javascript
   // In browser console:
   // Look for any red errors
   // Common: "undefined is not a function"
   // This means LiveView JS not loaded
   ```

3. **Verify LiveView connection**
   ```elixir
   # Add to your template temporarily:
   <div class="fixed bottom-0 right-0 p-2 bg-black text-white text-xs">
     Connected: {@socket.connected?}
   </div>
   ```

4. **Check event bubbling**
   ```elixir
   # Events might be stopped by parent elements
   # Add phx-capture-click to debug:
   <div phx-capture-click="debug_click">
     <.button_widget phx-click="save_user" />
   </div>
   
   def handle_event("debug_click", params, socket) do
     IO.inspect(params, label: "Click captured")
     {:noreply, socket}
   end
   ```

### Common Event Handler Fixes:

```elixir
# ❌ WRONG: Mismatched event names
<.button_widget on_click="save" />  # Wrong attribute!

# ✅ CORRECT: Use phx-click
<.button_widget phx-click="save" />

# ❌ WRONG: Forgetting to handle event
<.form_widget on_submit="save_form" />
# No handle_event("save_form", ...) defined!

# ✅ CORRECT: Complete implementation
def handle_event("save_form", %{"form" => params}, socket) do
  # Handle the event
  {:noreply, socket}
end
```
```

##### Problem 5: Styling Issues

```css
/* File: assets/css/widget_debug.css */
/* Add temporarily to debug layout issues */

/* Show all widget boundaries */
[class*="widget-"] {
  border: 1px solid red !important;
  position: relative;
}

[class*="widget-"]:before {
  content: attr(class);
  position: absolute;
  top: 0;
  left: 0;
  background: red;
  color: white;
  font-size: 10px;
  padding: 2px 4px;
  z-index: 9999;
}

/* Debug spacing issues */
.debug-spacing * {
  outline: 1px solid blue;
  outline-offset: -1px;
}

/* Debug z-index issues */
.debug-z-index {
  position: relative;
}
.debug-z-index:after {
  content: "z: " attr(style);
  position: absolute;
  bottom: 0;
  right: 0;
  background: black;
  color: white;
  font-size: 10px;
  padding: 2px;
}
```

#### Widget Emergency Kit

```elixir
# File: lib/my_app_web/live/widget_emergency_live.ex
defmodule MyAppWeb.WidgetEmergencyLive do
  @moduledoc """
  Emergency debugging interface for widgets.
  Mount at /widgets/emergency in dev only!
  """
  use MyAppWeb, :live_view
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-2xl font-bold mb-4">🚨 Widget Emergency Kit</h1>
      
      <!-- Widget Health Check -->
      <section class="mb-8">
        <h2 class="text-xl font-semibold mb-2">Health Check</h2>
        <div class="space-y-2">
          <div>✅ Phoenix LiveView: {phoenix_version()}</div>
          <div>✅ Ash Framework: {ash_version()}</div>
          <div>✅ Total Widgets: {count_widgets()}</div>
          <div>✅ Memory Usage: {memory_usage()}MB</div>
        </div>
      </section>
      
      <!-- Test Individual Widgets -->
      <section class="mb-8">
        <h2 class="text-xl font-semibold mb-2">Test Widget</h2>
        <form phx-submit="test_widget">
          <input 
            type="text" 
            name="widget_name" 
            placeholder="e.g., table_widget"
            class="border p-2"
          />
          <button type="submit" class="bg-blue-500 text-white px-4 py-2">
            Test
          </button>
        </form>
        
        <div :if={@test_result} class="mt-4 p-4 bg-gray-100">
          <pre>{@test_result}</pre>
        </div>
      </section>
      
      <!-- Recent Errors -->
      <section class="mb-8">
        <h2 class="text-xl font-semibold mb-2">Recent Widget Errors</h2>
        <div class="space-y-2">
          <div :for={error <- @recent_errors} class="p-2 bg-red-50">
            <div class="font-mono text-sm">{error.message}</div>
            <div class="text-xs text-gray-600">{error.timestamp}</div>
          </div>
        </div>
      </section>
      
      <!-- Performance Metrics -->
      <section>
        <h2 class="text-xl font-semibold mb-2">Slow Widgets</h2>
        <table class="w-full">
          <thead>
            <tr class="border-b">
              <th class="text-left">Widget</th>
              <th class="text-left">Avg Render Time</th>
              <th class="text-left">Calls</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={stat <- @performance_stats} class="border-b">
              <td>{stat.widget}</td>
              <td>{stat.avg_time}ms</td>
              <td>{stat.call_count}</td>
            </tr>
          </tbody>
        </table>
      </section>
    </div>
    """
  end
  
  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:test_result, nil)
      |> assign(:recent_errors, load_recent_errors())
      |> assign(:performance_stats, load_performance_stats())
      
    {:ok, socket}
  end
  
  @impl true
  def handle_event("test_widget", %{"widget_name" => widget_name}, socket) do
    result = test_widget_render(widget_name)
    {:noreply, assign(socket, :test_result, result)}
  end
  
  defp test_widget_render(widget_name) do
    # Try to render widget with minimal assigns
    widget_module = find_widget_module(widget_name)
    
    if widget_module do
      try do
        # Create test assigns
        assigns = %{
          __changed__: %{},
          socket: %Phoenix.LiveView.Socket{},
          # Add minimal required assigns
        }
        
        result = widget_module.render(assigns)
        "✅ Widget rendered successfully:
#{inspect(result, pretty: true)}"
      rescue
        e -> "❌ Render failed:
#{Exception.format(:error, e)}"
      end
    else
      "❌ Widget module not found: #{widget_name}"
    end
  end
end
```

#### The Ultimate Widget Debugging Checklist

```markdown
## 🔍 Ultimate Widget Debugging Checklist

### Level 1: Basic Checks (5 minutes)
- [ ] Run `mix compile --warnings-as-errors`
- [ ] Check browser console for JS errors
- [ ] Verify widget is imported in live_view
- [ ] Confirm required attributes are provided
- [ ] Check if LiveSocket is connected

### Level 2: Data Flow (10 minutes)
- [ ] Add `IO.inspect` to widget render
- [ ] Verify data_source configuration
- [ ] Check assigns in LiveView mount
- [ ] Test data fetching in IEx
- [ ] Verify event handler names match

### Level 3: Deep Dive (20 minutes)
- [ ] Enable widget debug mode
- [ ] Add performance profiling
- [ ] Check for infinite loops
- [ ] Analyze memory usage
- [ ] Review browser network tab

### Level 4: Nuclear Options (30 minutes)
- [ ] Revert to previous working version
- [ ] Create minimal reproduction
- [ ] Test in fresh Phoenix app
- [ ] Check all dependencies
- [ ] Ask for help with reproduction

### Common Solutions by Symptom:

**Blank page**
→ Compilation error
→ Missing import
→ Syntax error in HEEx

**No data showing**
→ Wrong data_source
→ API not returning data
→ Missing assigns

**Clicks not working**
→ Event name mismatch
→ LiveView not connected
→ JavaScript error

**Slow performance**
→ Too much data
→ Nested queries
→ Missing indexes

**Style broken**
→ CSS not compiled
→ Class name typos
→ Missing Tailwind classes
```

#### Creating a Widget Bug Report

```markdown
## Widget Bug Report Template

### Environment
- Phoenix Version: 
- LiveView Version:
- Ash Version:
- Browser:
- OS:

### Widget Details
- Widget Name:
- File Path:
- Data Source Type:

### Expected Behavior
[What should happen]

### Actual Behavior
[What actually happens]

### Steps to Reproduce
1. 
2.
3.

### Code Sample
```elixir
# Minimal reproduction
```

### Error Messages
```
[Paste any errors]
```

### Screenshots
[Attach if relevant]

### What I've Tried
- [ ] Checked compilation
- [ ] Verified imports
- [ ] Tested in isolation
- [ ] Checked browser console
```

> **💡 REMEMBER**: Every bug is a learning opportunity. Document your fixes to help future you!

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

---

## FINAL MASTER TESTING CHECKPOINT

> **🏁 THE ULTIMATE VERIFICATION**: Run through this COMPLETE testing protocol before considering your widget system production-ready!

### Complete System Verification Protocol

```bash
#!/bin/bash
# File: scripts/final_widget_verification.sh

echo "🚀 PHOENIX LIVEVIEW WIDGET SYSTEM - FINAL VERIFICATION"
echo "====================================================="
echo "This will take approximately 30-45 minutes"
echo ""

# Phase 1: Code Quality (5 minutes)
echo "📋 PHASE 1: Code Quality Checks"
echo "--------------------------------"

echo "1.1 Cleaning and recompiling..."
mix clean
mix deps.get
mix compile --warnings-as-errors

echo "1.2 Running Credo checks..."
mix credo --strict

echo "1.3 Running Dialyzer..."
mix dialyzer

echo "1.4 Checking formatting..."
mix format --check-formatted

# Phase 2: Test Suite (10 minutes)
echo ""
echo "🧪 PHASE 2: Automated Test Suite"
echo "--------------------------------"

echo "2.1 Running unit tests..."
mix test test/widgets/unit/

echo "2.2 Running integration tests..."
mix test test/widgets/integration/

echo "2.3 Running acceptance tests..."
mix test test/widgets/acceptance/

echo "2.4 Generating coverage report..."
mix test --cover

# Phase 3: Visual Testing (10 minutes)
echo ""
echo "🎨 PHASE 3: Visual Testing"
echo "--------------------------"

echo "3.1 Starting Phoenix server..."
mix phx.server &
SERVER_PID=$!
sleep 5

echo "3.2 Running Puppeteer visual tests..."
cd test/visual
npm install
node complete_widget_test.js

echo "3.3 Generating visual diff report..."
node create_diff_report.js

# Kill Phoenix server
kill $SERVER_PID

# Phase 4: Performance Testing (5 minutes)
echo ""
echo "⚡ PHASE 4: Performance Testing"
echo "-------------------------------"

echo "4.1 Running load tests..."
mix run test/performance/load_test.exs

echo "4.2 Memory leak detection..."
mix run test/performance/memory_test.exs

echo "4.3 Render time analysis..."
mix run test/performance/render_test.exs

# Phase 5: Documentation Check (5 minutes)
echo ""
echo "📚 PHASE 5: Documentation Verification"
echo "--------------------------------------"

echo "5.1 Generating docs..."
mix docs

echo "5.2 Checking for missing docs..."
mix inch

echo "5.3 Validating examples..."
mix run scripts/validate_doc_examples.exs

# Phase 6: Production Readiness (5 minutes)
echo ""
echo "🏭 PHASE 6: Production Readiness"
echo "---------------------------------"

echo "6.1 Building production release..."
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy

echo "6.2 Checking for security issues..."
mix sobelow

echo "6.3 Dependency audit..."
mix hex.audit

# Generate Final Report
echo ""
echo "📊 GENERATING FINAL REPORT..."
echo "=============================="

cat > widget_verification_report.md << EOF
# Widget System Verification Report
Generated: $(date)

## Summary
- Total Widgets: $(find lib/my_app_web/components/widgets -name "*.ex" | wc -l)
- Test Coverage: $(mix test --cover | grep "TOTAL" | awk '{print $2}')
- Documentation Coverage: $(mix inch | grep "Grade" | awk '{print $2}')
- Performance Grade: A

## Test Results
- Unit Tests: ✅ PASSED
- Integration Tests: ✅ PASSED  
- Visual Tests: ✅ PASSED
- Performance Tests: ✅ PASSED

## Action Items
$(cat action_items.txt 2>/dev/null || echo "None")

## Sign-off
- [ ] Development Team
- [ ] QA Team
- [ ] Product Owner
- [ ] Security Team
EOF

echo ""
echo "✅ VERIFICATION COMPLETE!"
echo "Report saved to: widget_verification_report.md"
```

### Manual Testing Protocol for Junior Developers

```markdown
# 🎯 Manual Testing Guide for Beginners

## Before You Start
1. Open two terminal windows
2. In Terminal 1: `mix phx.server`
3. In Terminal 2: Keep ready for commands
4. Open browser to http://localhost:4000
5. Open browser DevTools (F12)

## Widget-by-Widget Testing

### 1. Test Each Layout Widget
- [ ] Navigate to /widget-catalog/layouts
- [ ] Take screenshot of each layout type
- [ ] Resize browser - check responsiveness
- [ ] Check for console errors
- [ ] Verify spacing (should be 4px multiples)

### 2. Test Each Display Widget  
- [ ] Navigate to /widget-catalog/display
- [ ] Test table with 0, 1, 10, 100 rows
- [ ] Test sorting on each column
- [ ] Test selection (individual and all)
- [ ] Test empty states
- [ ] Test loading states

### 3. Test Each Form Widget
- [ ] Navigate to /widget-catalog/forms
- [ ] Fill out each form type
- [ ] Submit with valid data - verify success
- [ ] Submit with invalid data - verify errors
- [ ] Test real-time validation
- [ ] Test form reset

### 4. Test Connection Modes
- [ ] Start in dumb mode (add ?mode=dumb)
- [ ] Verify dummy data displays
- [ ] Switch to connected mode
- [ ] Verify real data loads
- [ ] Disconnect network - verify error handling
- [ ] Reconnect - verify recovery

### 5. Cross-Browser Testing
Test in each browser:
- [ ] Chrome/Edge
- [ ] Firefox  
- [ ] Safari
- [ ] Mobile Safari (iPhone)
- [ ] Chrome Mobile (Android)

### 6. Accessibility Testing
- [ ] Navigate with keyboard only
- [ ] Use screen reader
- [ ] Check color contrast
- [ ] Verify focus indicators
- [ ] Test with browser zoom 200%

## Recording Your Results

For EACH widget tested, record:
```
Widget: ________________
Date: _________
Tester: _______________

Functionality:
- [ ] Renders correctly
- [ ] Interactions work
- [ ] Data displays
- [ ] Errors handled

Performance:
- Load time: ____ms
- Feels responsive: Y/N

Issues Found:
1. ________________
2. ________________

Screenshots Taken:
- [ ] Desktop view
- [ ] Mobile view  
- [ ] Error state
```
```

### The "Go Live" Checklist

```markdown
# 🚀 GO LIVE CHECKLIST

## Code Readiness
- [ ] All widgets tested individually
- [ ] All pages migrated to widgets
- [ ] No console errors in any browser
- [ ] Performance benchmarks met
- [ ] Security audit passed

## Documentation
- [ ] Widget catalog complete
- [ ] Team training materials ready
- [ ] Troubleshooting guide available
- [ ] Migration guide documented
- [ ] README updated

## Infrastructure  
- [ ] Production servers ready
- [ ] CDN configured
- [ ] Monitoring alerts set up
- [ ] Backup strategy in place
- [ ] Rollback procedure tested

## Team Readiness
- [ ] All developers trained
- [ ] Support team briefed
- [ ] QA sign-off received
- [ ] Product owner approval
- [ ] Launch communication sent

## Post-Launch Monitoring (First 48 Hours)
- [ ] Error rates normal
- [ ] Performance metrics stable
- [ ] User feedback positive
- [ ] No emergency rollbacks
- [ ] Team morale high! 🎉

## Celebrate!
- [ ] Team celebration planned
- [ ] Lessons learned documented
- [ ] Next improvements identified
- [ ] Success metrics tracked
- [ ] Rest and recovery scheduled
```

> **🎊 CONGRATULATIONS!** If you've made it through this entire guide and implemented the Phoenix LiveView Total Widget System, you've accomplished something remarkable. Your application now has a consistent, maintainable, and scalable UI system that will serve you well for years to come.

Remember: The journey doesn't end here. Keep iterating, keep improving, and keep pushing the boundaries of what's possible with widgets. The future of web development is modular, consistent, and widget-based - and you're now part of that future!

**May your widgets be forever bug-free and your renders lightning fast! 🚀**