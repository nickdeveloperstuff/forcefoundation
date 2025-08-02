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