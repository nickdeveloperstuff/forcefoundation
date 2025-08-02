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

#### Tasks:
- [ ] Create directory structure: `lib/forcefoundation_web/widgets/`
- [ ] Create `lib/forcefoundation_web/widgets/base.ex` with the base behavior
- [ ] Create `lib/forcefoundation_web/widgets/helpers.ex` with spacing/grid helpers

#### Step 1: Create Directory Structure
```bash
# From your project root
mkdir -p lib/forcefoundation_web/widgets
```

#### Step 2: Create the Base Widget Module
Create `lib/forcefoundation_web/widgets/base.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.Base do
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
  
  # Optional callbacks
  @callback connect(data_source :: term(), socket :: Phoenix.LiveView.Socket.t()) :: 
    {:ok, Phoenix.LiveView.Socket.t()} | {:error, term()}
  @callback handle_event(event :: String.t(), params :: map(), socket :: Phoenix.LiveView.Socket.t()) ::
    {:noreply, Phoenix.LiveView.Socket.t()}
  @callback update(assigns :: map(), socket :: Phoenix.LiveView.Socket.t()) ::
    {:ok, Phoenix.LiveView.Socket.t()}
    
  @optional_callbacks connect: 2, handle_event: 3, update: 2
  
  defmacro __using__(opts) do
    quote do
      use Phoenix.Component
      import ForcefoundationWeb.Widgets.Helpers
      
      @behaviour ForcefoundationWeb.Widgets.Base
      
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
        
      # State attributes
      attr :loading, :boolean, default: false,
        doc: "Show loading state"
      attr :error, :string, default: nil,
        doc: "Error message to display"
      
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
          
          # State classes
          assigns[:loading] && "widget-loading",
          assigns[:error] && "widget-error",
          
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
        <div :if={@debug_mode} class="absolute top-0 right-0 bg-black/75 text-white text-xs p-2 rounded-bl z-50">
          <div class="font-bold"><%= widget_name() %></div>
          <div>Mode: <%= if @data_source == :static, do: "dumb", else: "connected" %></div>
          <div>Source: <%= inspect(@data_source) %></div>
          <div :if={@loading}>Loading...</div>
          <div :if={@error} class="text-red-400">Error: {@error}</div>
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

#### Step 3: Create the Helpers Module
Create `lib/forcefoundation_web/widgets/helpers.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.Helpers do
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
  
  # Padding classes (4px base)
  def padding_class(nil), do: nil
  def padding_class(0), do: "p-0"
  def padding_class(1), do: "p-1"   # 4px
  def padding_class(2), do: "p-2"   # 8px
  def padding_class(3), do: "p-3"   # 12px
  def padding_class(4), do: "p-4"   # 16px (default)
  def padding_class(6), do: "p-6"   # 24px
  def padding_class(8), do: "p-8"   # 32px
  
  # Margin classes (4px base)
  def margin_class(nil), do: nil
  def margin_class(0), do: "m-0"
  def margin_class(1), do: "m-1"   # 4px
  def margin_class(2), do: "m-2"   # 8px
  def margin_class(3), do: "m-3"   # 12px
  def margin_class(4), do: "m-4"   # 16px
  def margin_class(6), do: "m-6"   # 24px
  def margin_class(8), do: "m-8"   # 32px
  
  # Gap classes for flex/grid
  def gap_class(nil), do: nil
  def gap_class(0), do: "gap-0"
  def gap_class(1), do: "gap-1"   # 4px
  def gap_class(2), do: "gap-2"   # 8px
  def gap_class(3), do: "gap-3"   # 12px
  def gap_class(4), do: "gap-4"   # 16px
  def gap_class(6), do: "gap-6"   # 24px
  def gap_class(8), do: "gap-8"   # 32px
end
```

#### Quick & Dirty Test
```bash
# Terminal 1: Compile test
cd /path/to/forcefoundation
mix compile

# If you see errors like:
# == Compilation error in file lib/forcefoundation_web/widgets/base.ex ==
# Fix them before proceeding!

# Terminal 2: Interactive test (after successful compile)
iex -S mix

# In IEx, verify modules are loaded:
iex> ForcefoundationWeb.Widgets.Base.__info__(:functions)
# Should show list of functions

iex> ForcefoundationWeb.Widgets.Helpers.span_class(4)
# Should return: "col-span-4"
```

#### Visual Test
```bash
# Start Phoenix server
mix phx.server

# In another terminal, use Puppeteer to verify nothing broke:
# (This assumes you have the Puppeteer MCP configured)
```

```javascript
// Puppeteer test commands
await page.goto('http://localhost:4000')
await page.screenshot({ path: 'screenshots/phase1_section1_baseline.png' })
// Verify the homepage still loads without errors
```

#### Implementation Notes
**Date**: ___________
**Developer**: ___________

**Issues Encountered**:
- [ ] Issue: _________________
  - Solution: _________________

**Deviations from Guide**:
- [ ] Changed _______ because _______

**Additional Steps Required**:
- [ ] Had to also _______

**Time Taken**: _____ minutes

#### Section Completion
- [ ] All files created successfully
- [ ] `mix compile` runs without errors
- [ ] Helper functions tested in IEx
- [ ] Homepage still loads correctly
- [ ] Implementation notes documented
- [ ] ✅ **Section 1.1 Complete**

### Section 1.2: Widget Registry & Import System

#### Tasks:
- [ ] Create `lib/forcefoundation_web/widgets.ex` as the widget registry
- [ ] Update `lib/forcefoundation_web.ex` to import widgets in the `html` function
- [ ] Create a test widget to verify the system works

#### Step 1: Create the Widget Registry
Create `lib/forcefoundation_web/widgets.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets do
  @moduledoc """
  Central registry for all widgets in the system.
  
  This module:
  - Imports all widget modules
  - Provides a single import point for LiveViews
  - Manages widget discovery and registration
  """
  
  # Import all widgets here as we create them
  # This will grow as we add more widgets
  defmacro __using__(_opts) do
    quote do
      # Foundation widgets (we'll create these next)
      # import ForcefoundationWeb.Widgets.GridWidget
      # import ForcefoundationWeb.Widgets.FlexWidget
      # import ForcefoundationWeb.Widgets.SectionWidget
      
      # Display widgets
      # import ForcefoundationWeb.Widgets.TextWidget
      # import ForcefoundationWeb.Widgets.HeadingWidget
      # import ForcefoundationWeb.Widgets.CardWidget
      
      # Form widgets
      # import ForcefoundationWeb.Widgets.FormWidget
      # import ForcefoundationWeb.Widgets.InputWidget
      
      # For now, let's create a simple test widget
      import ForcefoundationWeb.Widgets.TestWidget
    end
  end
end
```

#### Step 2: Create a Test Widget
Create `lib/forcefoundation_web/widgets/test_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.TestWidget do
  use ForcefoundationWeb.Widgets.Base
  
  @moduledoc """
  A simple test widget to verify our widget system is working.
  This widget will be removed once we have real widgets.
  """
  
  attr :message, :string, default: "Hello from the widget system!"
  attr :color, :atom, default: :primary,
    values: [:primary, :secondary, :success, :error, :warning, :info]
  
  def render(assigns) do
    ~H"""
    <div class={[
      "alert",
      alert_color(@color),
      widget_classes(assigns)
    ]}>
      <%= render_debug(assigns) %>
      <span>{@message}</span>
    </div>
    """
  end
  
  defp alert_color(:primary), do: "alert-primary"
  defp alert_color(:secondary), do: "alert-secondary"
  defp alert_color(:success), do: "alert-success"
  defp alert_color(:error), do: "alert-error"
  defp alert_color(:warning), do: "alert-warning"
  defp alert_color(:info), do: "alert-info"
end
```

#### Step 3: Update ForcefoundationWeb Module
Edit `lib/forcefoundation_web.ex` and update the `html` function:

```elixir
# Find the html/0 function and add the widget import
def html do
  quote do
    use Phoenix.Component
    
    # Import all widgets
    use ForcefoundationWeb.Widgets
    
    # Core UI components
    import ForcefoundationWeb.CoreComponents
    import ForcefoundationWeb.ErrorHelpers
    
    # Existing imports...
    import Phoenix.Controller,
      only: [get_csrf_token: 0, view_module: 1, view_template: 1]
    
    unquote(html_helpers())
  end
end
```

#### Step 4: Create a Test Page
Create `lib/forcefoundation_web/live/widget_test_live.ex`:

```elixir
defmodule ForcefoundationWeb.WidgetTestLive do
  use ForcefoundationWeb, :live_view
  
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8">
      <h1 class="text-2xl font-bold mb-4">Widget System Test Page</h1>
      
      <!-- Test our widget system -->
      <.test_widget message="Success! The widget system is working!" color={:success} />
      
      <div class="mt-4">
        <.test_widget 
          message="Testing with debug mode" 
          color={:info}
          debug_mode={true}
          span={6}
          padding={4}
        />
      </div>
      
      <div class="mt-4 grid grid-cols-2 gap-4">
        <.test_widget message="Primary alert" color={:primary} />
        <.test_widget message="Warning alert" color={:warning} />
      </div>
    </div>
    """
  end
end
```

#### Step 5: Add Route
In `lib/forcefoundation_web/router.ex`, add in the appropriate scope:

```elixir
# In your live routes scope
live "/test/widgets", WidgetTestLive
```

#### Quick & Dirty Test
```bash
# Terminal 1: Compile and check for errors
mix compile

# Common errors and fixes:
# 1. "module ForcefoundationWeb.Widgets.Base is not available"
#    Fix: Make sure you created base.ex in the previous section
# 2. "function widget_classes/1 undefined"
#    Fix: Check that TestWidget properly uses ForcefoundationWeb.Widgets.Base

# Terminal 2: Start server
mix phx.server

# Terminal 3: Test in IEx
iex -S mix

# Verify the registry works:
iex> Code.ensure_loaded(ForcefoundationWeb.Widgets.TestWidget)
{:module, ForcefoundationWeb.Widgets.TestWidget}
```

#### Visual Test
```bash
# Navigate to test page
# http://localhost:4000/test/widgets

# Use Puppeteer for automated testing:
```

```javascript
// Puppeteer commands
await page.goto('http://localhost:4000/test/widgets')
await page.screenshot({ path: 'screenshots/phase1_section2_test_widget.png' })

// Verify widget rendered
const widgetExists = await page.$('.widget-test') !== null
console.log('Widget rendered:', widgetExists)

// Verify debug mode
const debugVisible = await page.$eval(
  '.widget-test[2] .absolute', 
  el => el.textContent.includes('Mode: dumb')
)
console.log('Debug mode working:', debugVisible)
```

#### Implementation Notes
**Date**: ___________
**Developer**: ___________

**Issues Encountered**:
- [ ] Issue: _________________
  - Solution: _________________

**Deviations from Guide**:
- [ ] Changed _______ because _______

**Additional Steps Required**:
- [ ] Had to also _______

**Time Taken**: _____ minutes

#### Section Completion
- [ ] Widget registry created
- [ ] Test widget created and working
- [ ] ForcefoundationWeb.ex updated
- [ ] Test page accessible at /test/widgets
- [ ] Widgets render with proper classes
- [ ] Debug mode displays correctly
- [ ] `mix compile` runs without errors
- [ ] Implementation notes documented
- [ ] ✅ **Section 1.2 Complete**

### Section 1.3: Connection Resolution System

#### Tasks:
- [ ] Create `lib/forcefoundation_web/widgets/connection_resolver.ex`
- [ ] Implement all 7 connection types
- [ ] Create test module to verify each connection type
- [ ] Update test widget to demonstrate connection modes

#### Step 1: Create the Connection Resolver
Create `lib/forcefoundation_web/widgets/connection_resolver.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.ConnectionResolver do
  @moduledoc """
  Resolves data connections for widgets.
  
  Supports 7 connection types:
  1. :static - Direct data passed as attributes (dumb mode)
  2. {:interface, function} - Calls domain code interface
  3. {:resource, resource, opts} - Direct Ash queries
  4. {:stream, name} - Phoenix LiveView streams
  5. {:form, action} - Form creation
  6. {:action, action, record} - Action invocation
  7. {:subscribe, topic} - PubSub subscriptions
  """
  
  import Phoenix.Component, only: [assign: 2, assign: 3]
  alias Phoenix.LiveView.Socket
  
  @doc """
  Resolves a data source and returns updated assigns.
  """
  def resolve(assigns, socket) do
    case assigns[:data_source] do
      :static ->
        # Dumb mode - use data directly from assigns
        assigns
        
      {:interface, function} when is_atom(function) ->
        resolve_interface(assigns, socket, function, [])
        
      {:interface, function, args} when is_atom(function) and is_list(args) ->
        resolve_interface(assigns, socket, function, args)
        
      {:resource, resource, opts} ->
        resolve_resource(assigns, socket, resource, opts)
        
      {:stream, stream_name} ->
        resolve_stream(assigns, socket, stream_name)
        
      {:form, action} ->
        resolve_form(assigns, socket, action)
        
      {:action, action, record} ->
        resolve_action(assigns, socket, action, record)
        
      {:subscribe, topic} ->
        resolve_subscription(assigns, socket, topic)
        
      nil ->
        # No data source specified, default to static
        Map.put(assigns, :data_source, :static)
        
      other ->
        # Invalid data source
        assigns
        |> Map.put(:error, "Invalid data source: #{inspect(other)}")
        |> Map.put(:loading, false)
    end
  end
  
  # Interface resolution - calls domain functions
  defp resolve_interface(assigns, socket, function, args) do
    domain = get_domain_from_socket(socket)
    
    if domain && function_exported?(domain, function, length(args)) do
      try do
        result = apply(domain, function, args)
        
        assigns
        |> Map.put(:data, result)
        |> Map.put(:loading, false)
        |> Map.put(:error, nil)
      rescue
        error ->
          assigns
          |> Map.put(:error, Exception.message(error))
          |> Map.put(:loading, false)
      end
    else
      assigns
      |> Map.put(:error, "Function #{function}/#{length(args)} not found in domain")
      |> Map.put(:loading, false)
    end
  end
  
  # Resource resolution - direct Ash queries
  defp resolve_resource(assigns, _socket, resource, opts) do
    query = build_query(resource, opts)
    
    case Ash.read(query) do
      {:ok, results} ->
        assigns
        |> Map.put(:data, results)
        |> Map.put(:loading, false)
        |> Map.put(:error, nil)
        
      {:error, error} ->
        assigns
        |> Map.put(:error, inspect(error))
        |> Map.put(:loading, false)
    end
  end
  
  # Stream resolution - for efficient list updates
  defp resolve_stream(assigns, socket, stream_name) do
    # Streams are handled differently - they're set up in mount/handle_event
    # This just marks that we're using a stream
    assigns
    |> Map.put(:stream_name, stream_name)
    |> Map.put(:loading, false)
  end
  
  # Form resolution - creates AshPhoenix.Form
  defp resolve_form(assigns, socket, {:create, resource}) do
    form = AshPhoenix.Form.for_create(resource, :create)
    
    assigns
    |> Map.put(:form, form)
    |> Map.put(:loading, false)
  end
  
  defp resolve_form(assigns, socket, {:update, record}) do
    form = AshPhoenix.Form.for_update(record, :update)
    
    assigns
    |> Map.put(:form, form)
    |> Map.put(:loading, false)
  end
  
  # Action resolution - for buttons that trigger actions
  defp resolve_action(assigns, _socket, action, record) do
    # Actions are typically invoked on events, not during render
    # This just stores the configuration
    assigns
    |> Map.put(:action_config, %{action: action, record: record})
    |> Map.put(:loading, false)
  end
  
  # Subscription resolution - sets up PubSub
  defp resolve_subscription(assigns, socket, topic) do
    if Phoenix.LiveView.connected?(socket) do
      Phoenix.PubSub.subscribe(Forcefoundation.PubSub, topic)
    end
    
    assigns
    |> Map.put(:subscribed_to, topic)
    |> Map.put(:loading, false)
  end
  
  # Helper functions
  
  defp get_domain_from_socket(socket) do
    # Domain should be assigned to socket in mount
    socket.assigns[:domain] || socket.assigns[:__domain__]
  end
  
  defp build_query(resource, opts) do
    query = resource
    
    query = 
      if opts[:filter] do
        Ash.Query.filter(query, ^opts[:filter])
      else
        query
      end
      
    query =
      if opts[:sort] do
        Ash.Query.sort(query, opts[:sort])
      else
        query
      end
      
    query =
      if opts[:load] do
        Ash.Query.load(query, opts[:load])
      else
        query
      end
      
    if opts[:limit] do
      Ash.Query.limit(query, opts[:limit])
    else
      query
    end
  end
end
```

#### Step 2: Create Widget Mixin for Connection Support
Create `lib/forcefoundation_web/widgets/connectable.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.Connectable do
  @moduledoc """
  Mixin for widgets that support data connections.
  Include this in widgets that need to fetch data.
  """
  
  defmacro __using__(_opts) do
    quote do
      import ForcefoundationWeb.Widgets.ConnectionResolver
      
      # Override update to handle data resolution
      def update(assigns, socket) do
        assigns = resolve(assigns, socket)
        {:ok, assign(socket, assigns)}
      end
      
      defoverridable update: 2
    end
  end
end
```

#### Step 3: Create Test Module for Connection Types
Create `lib/forcefoundation_web/live/connection_test_live.ex`:

```elixir
defmodule ForcefoundationWeb.ConnectionTestLive do
  use ForcefoundationWeb, :live_view
  
  # Mock domain module for testing
  defmodule TestDomain do
    def get_users do
      [
        %{id: 1, name: "Alice", email: "alice@example.com"},
        %{id: 2, name: "Bob", email: "bob@example.com"},
        %{id: 3, name: "Charlie", email: "charlie@example.com"}
      ]
    end
    
    def get_user(id) do
      Enum.find(get_users(), &(&1.id == id))
    end
    
    def count_users do
      length(get_users())
    end
  end
  
  def mount(_params, _session, socket) do
    # Assign domain for interface connections
    socket = 
      socket
      |> assign(:domain, TestDomain)
      |> stream(:items, generate_items())
    
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8">
      <h1 class="text-2xl font-bold mb-6">Connection Resolver Test</h1>
      
      <div class="space-y-6">
        <!-- Test 1: Static Connection (Dumb Mode) -->
        <section class="border p-4 rounded">
          <h2 class="text-lg font-semibold mb-2">1. Static Connection (Dumb Mode)</h2>
          <.connection_test_widget 
            data_source={:static}
            title="Static Data"
            items={[
              %{id: 1, text: "Static Item 1"},
              %{id: 2, text: "Static Item 2"}
            ]}
          />
        </section>
        
        <!-- Test 2: Interface Connection -->
        <section class="border p-4 rounded">
          <h2 class="text-lg font-semibold mb-2">2. Interface Connection</h2>
          <.connection_test_widget 
            data_source={:interface, :get_users}
            title="Users from Interface"
            debug_mode={true}
          />
        </section>
        
        <!-- Test 3: Interface with Args -->
        <section class="border p-4 rounded">
          <h2 class="text-lg font-semibold mb-2">3. Interface with Arguments</h2>
          <.connection_test_widget 
            data_source={:interface, :get_user, [1]}
            title="Single User"
          />
        </section>
        
        <!-- Test 4: Stream Connection -->
        <section class="border p-4 rounded">
          <h2 class="text-lg font-semibold mb-2">4. Stream Connection</h2>
          <div id="stream-test" phx-update="stream">
            <div :for={{dom_id, item} <- @streams.items} id={dom_id}>
              Item: <%= item.text %>
            </div>
          </div>
        </section>
      </div>
    </div>
    """
  end
  
  defp generate_items do
    for i <- 1..5 do
      %{id: i, text: "Stream Item #{i}"}
    end
  end
end
```

#### Step 4: Create Connection Test Widget
Create `lib/forcefoundation_web/widgets/connection_test_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.ConnectionTestWidget do
  use ForcefoundationWeb.Widgets.Base
  use ForcefoundationWeb.Widgets.Connectable
  
  attr :title, :string, required: true
  attr :items, :list, default: []
  attr :data, :any, default: nil
  
  def render(assigns) do
    ~H"""
    <div class={["border rounded p-4 bg-gray-50", widget_classes(assigns)]}>
      <%= render_debug(assigns) %>
      
      <h3 class="font-semibold mb-2">{@title}</h3>
      
      <%= if @loading do %>
        <div class="text-gray-500">Loading...</div>
      <% else %>
        <%= if @error do %>
          <div class="text-red-500">Error: {@error}</div>
        <% else %>
          <ul class="list-disc list-inside">
            <%= for item <- get_items(assigns) do %>
              <li><%= format_item(item) %></li>
            <% end %>
          </ul>
        <% end %>
      <% end %>
    </div>
    """
  end
  
  defp get_items(%{data_source: :static, items: items}), do: items
  defp get_items(%{data: data}) when is_list(data), do: data
  defp get_items(%{data: data}) when not is_nil(data), do: [data]
  defp get_items(_), do: []
  
  defp format_item(%{name: name, email: email}), do: "#{name} (#{email})"
  defp format_item(%{text: text}), do: text
  defp format_item(%{name: name}), do: name
  defp format_item(item), do: inspect(item)
end
```

#### Step 5: Update Widget Registry
Update `lib/forcefoundation_web/widgets.ex`:

```elixir
# Add the new test widget to imports
import ForcefoundationWeb.Widgets.ConnectionTestWidget
```

#### Step 6: Add Route
In router.ex:

```elixir
live "/test/connections", ConnectionTestLive
```

#### Quick & Dirty Test
```bash
# Terminal 1: Compile
mix compile

# Check for common errors:
# 1. "undefined function resolve/2"
#    Fix: Make sure Connectable module is properly using ConnectionResolver
# 2. "Forcefoundation.PubSub is not started"
#    Fix: Check your application.ex includes PubSub in supervision tree

# Terminal 2: Interactive test
iex -S mix

# Test the resolver directly:
iex> alias ForcefoundationWeb.Widgets.ConnectionResolver
iex> ConnectionResolver.resolve(%{data_source: :static}, %{})
# Should return the assigns unchanged

# Terminal 3: Start server
mix phx.server
```

#### Visual Test
Navigate to http://localhost:4000/test/connections

```javascript
// Puppeteer test
await page.goto('http://localhost:4000/test/connections')
await page.screenshot({ path: 'screenshots/phase1_section3_connections.png' })

// Verify each connection type
const sections = await page.$$('section')
console.log(`Found ${sections.length} connection test sections`)

// Check debug mode shows connection info
const debugInfo = await page.$eval(
  '.widget-connection_test:nth-of-type(2) .absolute',
  el => el.textContent
)
console.log('Debug info:', debugInfo)
```

#### Implementation Notes
**Date**: ___________
**Developer**: ___________

**Issues Encountered**:
- [ ] Issue: _________________
  - Solution: _________________

**Deviations from Guide**:
- [ ] Changed _______ because _______

**Additional Steps Required**:
- [ ] Had to also _______

**Time Taken**: _____ minutes

#### Section Completion
- [ ] ConnectionResolver module created with all 7 types
- [ ] Connectable mixin created
- [ ] Test page shows all connection types
- [ ] Static mode works (shows hardcoded data)
- [ ] Interface mode works (calls domain functions)
- [ ] Error handling displays properly
- [ ] Debug mode shows connection details
- [ ] `mix compile` runs without errors
- [ ] Implementation notes documented
- [ ] ✅ **Section 1.3 Complete**

## Phase 1 Completion Checklist
- [ ] Base widget module provides common functionality
- [ ] Helper module implements spacing system
- [ ] Widget registry allows single import point
- [ ] Connection resolver handles all data patterns
- [ ] Test pages verify everything works
- [ ] No compilation errors
- [ ] Visual tests pass
- [ ] ✅ **Phase 1 Complete!**

**Phase 1 Summary Notes**:
_Use this space to note any overall observations, patterns noticed, or suggestions for Phase 2_

---

## Phase 2: Essential Layout Widgets (Wrapping DaisyUI Components)

### Section 2.1: Grid and Layout Widgets

#### Tasks:
- [ ] Create `grid_widget.ex` - 12-column grid using Tailwind grid classes
- [ ] Create `flex_widget.ex` - Flexbox container
- [ ] Create `section_widget.ex` - Content sections with padding
- [ ] Create test page to demonstrate all layout widgets
- [ ] Test responsive behavior

#### Step 1: Create Grid Widget
Create `lib/forcefoundation_web/widgets/grid_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.GridWidget do
  use ForcefoundationWeb.Widgets.Base
  
  @moduledoc """
  Responsive grid container using Tailwind's grid system.
  Supports 12-column layout with automatic responsive breakpoints.
  
  ## Examples
  
      <.grid_widget columns={3} gap={4}>
        <div>Item 1</div>
        <div>Item 2</div>
        <div>Item 3</div>
      </.grid_widget>
  """
  
  attr :columns, :any, default: 12,
    doc: "Number of columns. Can be integer or responsive map"
  attr :gap, :integer, default: 4,
    doc: "Gap between items (4px units)"
  attr :gap_x, :integer, default: nil,
    doc: "Horizontal gap override"
  attr :gap_y, :integer, default: nil,
    doc: "Vertical gap override"
  attr :align_items, :atom, default: :stretch,
    values: [:start, :center, :end, :stretch, :baseline],
    doc: "Vertical alignment of items"
  attr :justify_items, :atom, default: :stretch,
    values: [:start, :center, :end, :stretch],
    doc: "Horizontal alignment of items"
    
  slot :inner_block, required: true
  
  def render(assigns) do
    # Set gap overrides
    assigns = 
      assigns
      |> assign_new(:gap_x, fn -> assigns.gap end)
      |> assign_new(:gap_y, fn -> assigns.gap end)
    
    ~H"""
    <div class={[
      "grid",
      columns_class(@columns),
      gap_x_class(@gap_x),
      gap_y_class(@gap_y),
      align_items_class(@align_items),
      justify_items_class(@justify_items),
      widget_classes(assigns)
    ]}>
      <%= render_debug(assigns) %>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
  
  # Handle responsive columns
  defp columns_class(columns) when is_integer(columns) do
    "grid-cols-#{columns}"
  end
  
  defp columns_class(%{mobile: m, tablet: t, desktop: d}) do
    [
      "grid-cols-#{m}",
      "md:grid-cols-#{t}",
      "lg:grid-cols-#{d}"
    ]
    |> Enum.join(" ")
  end
  
  # Common responsive patterns
  defp columns_class(:responsive) do
    "grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4"
  end
  
  defp gap_x_class(nil), do: nil
  defp gap_x_class(n), do: "gap-x-#{n}"
  
  defp gap_y_class(nil), do: nil
  defp gap_y_class(n), do: "gap-y-#{n}"
  
  defp align_items_class(:start), do: "items-start"
  defp align_items_class(:center), do: "items-center"
  defp align_items_class(:end), do: "items-end"
  defp align_items_class(:stretch), do: "items-stretch"
  defp align_items_class(:baseline), do: "items-baseline"
  
  defp justify_items_class(:start), do: "justify-items-start"
  defp justify_items_class(:center), do: "justify-items-center"
  defp justify_items_class(:end), do: "justify-items-end"
  defp justify_items_class(:stretch), do: "justify-items-stretch"
end
```

#### Step 2: Create Flex Widget
Create `lib/forcefoundation_web/widgets/flex_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.FlexWidget do
  use ForcefoundationWeb.Widgets.Base
  
  @moduledoc """
  Flexible box container for one-dimensional layouts.
  Perfect for navigation bars, toolbars, and aligned content.
  """
  
  attr :direction, :atom, default: :row,
    values: [:row, :row_reverse, :col, :col_reverse],
    doc: "Flex direction"
  attr :wrap, :atom, default: :nowrap,
    values: [:wrap, :nowrap, :wrap_reverse],
    doc: "Whether items wrap"
  attr :justify, :atom, default: :start,
    values: [:start, :center, :end, :between, :around, :evenly],
    doc: "Justification along main axis"
  attr :align, :atom, default: :stretch,
    values: [:start, :center, :end, :stretch, :baseline],
    doc: "Alignment along cross axis"
  attr :gap, :integer, default: 0,
    doc: "Gap between items (4px units)"
  attr :full_height, :boolean, default: false,
    doc: "Take full height of parent"
    
  slot :inner_block, required: true
  
  def render(assigns) do
    ~H"""
    <div class={[
      "flex",
      direction_class(@direction),
      wrap_class(@wrap),
      justify_class(@justify),
      align_class(@align),
      gap_class(@gap),
      @full_height && "h-full",
      widget_classes(assigns)
    ]}>
      <%= render_debug(assigns) %>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
  
  defp direction_class(:row), do: "flex-row"
  defp direction_class(:row_reverse), do: "flex-row-reverse"
  defp direction_class(:col), do: "flex-col"
  defp direction_class(:col_reverse), do: "flex-col-reverse"
  
  defp wrap_class(:wrap), do: "flex-wrap"
  defp wrap_class(:nowrap), do: "flex-nowrap"
  defp wrap_class(:wrap_reverse), do: "flex-wrap-reverse"
  
  defp justify_class(:start), do: "justify-start"
  defp justify_class(:center), do: "justify-center"
  defp justify_class(:end), do: "justify-end"
  defp justify_class(:between), do: "justify-between"
  defp justify_class(:around), do: "justify-around"
  defp justify_class(:evenly), do: "justify-evenly"
  
  defp align_class(:start), do: "items-start"
  defp align_class(:center), do: "items-center"
  defp align_class(:end), do: "items-end"
  defp align_class(:stretch), do: "items-stretch"
  defp align_class(:baseline), do: "items-baseline"
end
```

#### Step 3: Create Section Widget
Create `lib/forcefoundation_web/widgets/section_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.SectionWidget do
  use ForcefoundationWeb.Widgets.Base
  
  @moduledoc """
  Section container with consistent spacing and optional styling.
  Use for grouping related content with proper spacing.
  """
  
  attr :background, :atom, default: :transparent,
    values: [:transparent, :white, :gray, :primary, :gradient],
    doc: "Background style"
  attr :rounded, :atom, default: :none,
    values: [:none, :sm, :md, :lg, :xl, :full],
    doc: "Border radius"
  attr :shadow, :atom, default: :none,
    values: [:none, :sm, :md, :lg, :xl],
    doc: "Box shadow"
  attr :border, :boolean, default: false,
    doc: "Show border"
  attr :container, :boolean, default: false,
    doc: "Constrain width with container"
  attr :full_width, :boolean, default: false,
    doc: "Take full width"
  attr :full_height, :boolean, default: false,
    doc: "Take full height"
    
  slot :header do
    attr :sticky, :boolean
  end
  slot :inner_block, required: true
  slot :footer
  
  def render(assigns) do
    ~H"""
    <section class={[
      background_class(@background),
      rounded_class(@rounded),
      shadow_class(@shadow),
      @border && "border border-gray-200",
      @container && "container mx-auto",
      @full_width && "w-full",
      @full_height && "h-full",
      widget_classes(assigns)
    ]}>
      <%= render_debug(assigns) %>
      
      <div :if={@header} class={[
        "section-header",
        @header[:sticky] && "sticky top-0 z-10 bg-inherit"
      ]}>
        <%= render_slot(@header) %>
      </div>
      
      <div class="section-body">
        <%= render_slot(@inner_block) %>
      </div>
      
      <div :if={@footer} class="section-footer">
        <%= render_slot(@footer) %>
      </div>
    </section>
    """
  end
  
  defp background_class(:transparent), do: "bg-transparent"
  defp background_class(:white), do: "bg-white"
  defp background_class(:gray), do: "bg-gray-50"
  defp background_class(:primary), do: "bg-primary-50"
  defp background_class(:gradient), do: "bg-gradient-to-br from-primary-50 to-secondary-50"
  
  defp rounded_class(:none), do: nil
  defp rounded_class(:sm), do: "rounded-sm"
  defp rounded_class(:md), do: "rounded-md"
  defp rounded_class(:lg), do: "rounded-lg"
  defp rounded_class(:xl), do: "rounded-xl"
  defp rounded_class(:full), do: "rounded-full"
  
  defp shadow_class(:none), do: nil
  defp shadow_class(:sm), do: "shadow-sm"
  defp shadow_class(:md), do: "shadow-md"
  defp shadow_class(:lg), do: "shadow-lg"
  defp shadow_class(:xl), do: "shadow-xl"
end
```

#### Step 4: Update Widget Registry
Update `lib/forcefoundation_web/widgets.ex`:

```elixir
# Add layout widgets to imports
import ForcefoundationWeb.Widgets.GridWidget
import ForcefoundationWeb.Widgets.FlexWidget
import ForcefoundationWeb.Widgets.SectionWidget
```

#### Step 5: Create Layout Test Page
Create `lib/forcefoundation_web/live/layout_test_live.ex`:

```elixir
defmodule ForcefoundationWeb.LayoutTestLive do
  use ForcefoundationWeb, :live_view
  
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :selected_demo, :grid)}
  end
  
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100">
      <!-- Navigation -->
      <.section_widget background={:white} shadow={:md} padding={4}>
        <.flex_widget justify={:between} align={:center}>
          <h1 class="text-2xl font-bold">Layout Widget Tests</h1>
          <.flex_widget gap={2}>
            <button 
              class={["btn", @selected_demo == :grid && "btn-primary" || "btn-ghost"]}
              phx-click="select_demo" 
              phx-value-demo="grid"
            >
              Grid Demo
            </button>
            <button 
              class={["btn", @selected_demo == :flex && "btn-primary" || "btn-ghost"]}
              phx-click="select_demo" 
              phx-value-demo="flex"
            >
              Flex Demo
            </button>
            <button 
              class={["btn", @selected_demo == :section && "btn-primary" || "btn-ghost"]}
              phx-click="select_demo" 
              phx-value-demo="section"
            >
              Section Demo
            </button>
          </.flex_widget>
        </.flex_widget>
      </.section_widget>
      
      <!-- Content -->
      <div class="p-8">
        <%= case @selected_demo do %>
          <% :grid -> %>
            {render_grid_demo(assigns)}
          <% :flex -> %>
            {render_flex_demo(assigns)}
          <% :section -> %>
            {render_section_demo(assigns)}
        <% end %>
      </div>
    </div>
    """
  end
  
  defp render_grid_demo(assigns) do
    ~H"""
    <div class="space-y-8">
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6}>
        <h2 class="text-xl font-semibold mb-4">Basic Grid (12 columns)</h2>
        <.grid_widget columns={12} gap={4} debug_mode={true}>
          <div class="col-span-12 bg-blue-200 p-4 rounded">Full width (span-12)</div>
          <div class="col-span-6 bg-green-200 p-4 rounded">Half width (span-6)</div>
          <div class="col-span-6 bg-green-200 p-4 rounded">Half width (span-6)</div>
          <div class="col-span-4 bg-yellow-200 p-4 rounded">Third (span-4)</div>
          <div class="col-span-4 bg-yellow-200 p-4 rounded">Third (span-4)</div>
          <div class="col-span-4 bg-yellow-200 p-4 rounded">Third (span-4)</div>
          <div class="col-span-3 bg-purple-200 p-4 rounded">Quarter</div>
          <div class="col-span-3 bg-purple-200 p-4 rounded">Quarter</div>
          <div class="col-span-3 bg-purple-200 p-4 rounded">Quarter</div>
          <div class="col-span-3 bg-purple-200 p-4 rounded">Quarter</div>
        </.grid_widget>
      </.section_widget>
      
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6}>
        <h2 class="text-xl font-semibold mb-4">Responsive Grid</h2>
        <.grid_widget 
          columns={%{mobile: 1, tablet: 2, desktop: 4}} 
          gap={4}
        >
          <%= for i <- 1..8 do %>
            <div class="bg-indigo-200 p-4 rounded text-center">
              Item <%= i %>
            </div>
          <% end %>
        </.grid_widget>
      </.section_widget>
    </div>
    """
  end
  
  defp render_flex_demo(assigns) do
    ~H"""
    <div class="space-y-8">
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6}>
        <h2 class="text-xl font-semibold mb-4">Flex Layouts</h2>
        
        <!-- Horizontal layouts -->
        <div class="space-y-4">
          <div>
            <h3 class="font-medium mb-2">Justify: Space Between</h3>
            <.flex_widget justify={:between} align={:center} debug_mode={true}>
              <div class="bg-red-200 p-4 rounded">Left</div>
              <div class="bg-green-200 p-4 rounded">Center</div>
              <div class="bg-blue-200 p-4 rounded">Right</div>
            </.flex_widget>
          </div>
          
          <div>
            <h3 class="font-medium mb-2">Justify: Center with Gap</h3>
            <.flex_widget justify={:center} gap={4}>
              <div class="bg-yellow-200 p-4 rounded">Item 1</div>
              <div class="bg-yellow-200 p-4 rounded">Item 2</div>
              <div class="bg-yellow-200 p-4 rounded">Item 3</div>
            </.flex_widget>
          </div>
          
          <div>
            <h3 class="font-medium mb-2">Column Direction</h3>
            <.flex_widget direction={:col} gap={2} align={:start}>
              <div class="bg-purple-200 p-2 rounded w-full">Row 1</div>
              <div class="bg-purple-200 p-2 rounded w-3/4">Row 2 (75%)</div>
              <div class="bg-purple-200 p-2 rounded w-1/2">Row 3 (50%)</div>
            </.flex_widget>
          </div>
        </div>
      </.section_widget>
    </div>
    """
  end
  
  defp render_section_demo(assigns) do
    ~H"""
    <div class="space-y-8">
      <.section_widget 
        background={:white} 
        rounded={:lg} 
        shadow={:lg} 
        padding={6}
        border={true}
      >
        <:header sticky={true}>
          <.flex_widget justify={:between} align={:center} padding={4}>
            <h2 class="text-xl font-semibold">Section with Sticky Header</h2>
            <span class="text-sm text-gray-500">Scroll to see sticky behavior</span>
          </.flex_widget>
        </:header>
        
        <div class="space-y-4">
          <%= for i <- 1..10 do %>
            <p class="text-gray-700">
              This is paragraph <%= i %>. Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
              Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            </p>
          <% end %>
        </div>
        
        <:footer>
          <div class="border-t pt-4 mt-4">
            <p class="text-sm text-gray-500">This is the footer section</p>
          </div>
        </:footer>
      </.section_widget>
      
      <.section_widget background={:gradient} rounded={:xl} padding={8}>
        <h2 class="text-2xl font-bold mb-4">Gradient Background Section</h2>
        <p>This section has a gradient background and extra padding.</p>
      </.section_widget>
    </div>
    """
  end
  
  def handle_event("select_demo", %{"demo" => demo}, socket) do
    {:noreply, assign(socket, :selected_demo, String.to_atom(demo))}
  end
end
```

#### Step 6: Add Route
In router.ex:

```elixir
live "/test/layout", LayoutTestLive
```

#### Quick & Dirty Test
```bash
# Terminal 1: Compile
mix compile

# Common errors:
# 1. "function gap_class/1 is undefined"
#    Fix: Make sure you imported Helpers in Base module
# 2. "** (ArgumentError) unknown attribute :gap"
#    Fix: Check attribute definitions match usage

# Terminal 2: Start server
mix phx.server

# Terminal 3: Test specific widget functions
iex -S mix

iex> alias ForcefoundationWeb.Widgets.GridWidget
iex> # Test the widget module loaded correctly
```

#### Visual Test
```bash
# Navigate to http://localhost:4000/test/layout
```

```javascript
// Puppeteer tests
// Test 1: Grid responsiveness
await page.goto('http://localhost:4000/test/layout')
await page.screenshot({ path: 'screenshots/phase2_section1_grid_desktop.png' })

// Resize to tablet
await page.setViewport({ width: 768, height: 1024 })
await page.screenshot({ path: 'screenshots/phase2_section1_grid_tablet.png' })

// Resize to mobile
await page.setViewport({ width: 375, height: 667 })
await page.screenshot({ path: 'screenshots/phase2_section1_grid_mobile.png' })

// Test 2: Flex layouts
await page.click('button:has-text("Flex Demo")')
await page.waitForTimeout(500)
await page.screenshot({ path: 'screenshots/phase2_section1_flex.png' })

// Test 3: Section variants
await page.click('button:has-text("Section Demo")')
await page.waitForTimeout(500)
await page.screenshot({ path: 'screenshots/phase2_section1_sections.png' })

// Verify debug mode
const debugVisible = await page.$('.widget-grid .absolute') !== null
console.log('Debug mode visible on grid:', debugVisible)
```

#### Implementation Notes
**Date**: ___________
**Developer**: ___________

**Issues Encountered**:
- [ ] Issue: _________________
  - Solution: _________________

**Deviations from Guide**:
- [ ] Changed _______ because _______

**Additional Steps Required**:
- [ ] Had to also _______

**Time Taken**: _____ minutes

#### Section Completion
- [ ] Grid widget created with responsive support
- [ ] Flex widget created with all alignments
- [ ] Section widget created with variants
- [ ] Test page shows all layouts
- [ ] Responsive behavior verified
- [ ] Debug mode shows on widgets
- [ ] `mix compile` runs without errors
- [ ] Visual tests captured
- [ ] Implementation notes documented
- [ ] ✅ **Section 2.1 Complete**

### Section 2.2: Card Widget (DaisyUI Integration)

#### Tasks:
- [ ] Create `card_widget.ex` wrapping DaisyUI's card component
- [ ] Implement slots: `:header`, `:body`, `:footer`, `:image`, `:actions`
- [ ] Add grid span support
- [ ] Create card variations (compact, side image, etc.)
- [ ] Test with different content types

#### Step 1: Create Card Widget
Create `lib/forcefoundation_web/widgets/card_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.CardWidget do
  use ForcefoundationWeb.Widgets.Base
  
  @moduledoc """
  Card container wrapping DaisyUI's card component.
  Supports multiple layouts and content slots.
  
  ## Examples
  
      <.card_widget title="Simple Card">
        Card content goes here
      </.card_widget>
      
      <.card_widget image="/images/photo.jpg" compact={true}>
        <:body>
          <h2 class="card-title">Card with Image</h2>
          <p>Card description</p>
        </:body>
        <:actions>
          <button class="btn btn-primary">Action</button>
        </:actions>
      </.card_widget>
  """
  
  # Card configuration
  attr :variant, :atom, default: :default,
    values: [:default, :compact, :side, :overlay],
    doc: "Card layout variant"
  attr :image, :string, default: nil,
    doc: "Image URL for card"
  attr :image_alt, :string, default: "",
    doc: "Alt text for image"
  attr :title, :string, default: nil,
    doc: "Card title (shorthand)"
  attr :bordered, :boolean, default: false,
    doc: "Add border to card"
  attr :hoverable, :boolean, default: false,
    doc: "Add hover effect"
  attr :clickable, :boolean, default: false,
    doc: "Make entire card clickable"
  attr :on_click, :any, default: nil,
    doc: "Click handler for card"
  
  # Content slots
  slot :figure, doc: "Figure/image area (alternative to image attr)"
  slot :body, doc: "Main card content"
  slot :actions, doc: "Card action buttons"
  slot :badge, doc: "Badge overlays"
  slot :inner_block, doc: "Shorthand for body content"
  
  def render(assigns) do
    ~H"""
    <div 
      class={[
        "card",
        "bg-base-100",
        variant_class(@variant),
        @bordered && "card-bordered",
        @hoverable && "hover:shadow-xl transition-shadow",
        @clickable && "cursor-pointer",
        widget_classes(assigns)
      ]}
      phx-click={@clickable && @on_click}
    >
      <%= render_debug(assigns) %>
      
      <!-- Image or Figure -->
      <%= if @image || @figure do %>
        <figure class={figure_class(@variant)}>
          <%= if @figure do %>
            <%= render_slot(@figure) %>
          <% else %>
            <img src={@image} alt={@image_alt} />
          <% end %>
          
          <!-- Badges overlay on image -->
          <%= for badge <- @badge do %>
            <div class="absolute top-2 right-2">
              <%= render_slot(badge) %>
            </div>
          <% end %>
        </figure>
      <% end %>
      
      <!-- Card Body -->
      <div class="card-body">
        <!-- Title if provided as attribute -->
        <h2 :if={@title} class="card-title">
          {@title}
        </h2>
        
        <!-- Body content -->
        <%= if @body do %>
          <%= render_slot(@body) %>
        <% else %>
          <%= render_slot(@inner_block) %>
        <% end %>
        
        <!-- Actions -->
        <div :if={@actions} class="card-actions justify-end">
          <%= render_slot(@actions) %>
        </div>
      </div>
    </div>
    """
  end
  
  defp variant_class(:default), do: nil
  defp variant_class(:compact), do: "card-compact"
  defp variant_class(:side), do: "card-side"
  defp variant_class(:overlay), do: "image-full"
  
  defp figure_class(:side), do: "figure-side"
  defp figure_class(_), do: nil
end
```

#### Step 2: Create Display Widgets for Card Content
Create `lib/forcefoundation_web/widgets/heading_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.HeadingWidget do
  use ForcefoundationWeb.Widgets.Base
  
  @moduledoc """
  Heading widget with consistent styling and sizes.
  """
  
  attr :level, :integer, default: 2,
    values: [1, 2, 3, 4, 5, 6],
    doc: "Heading level (h1-h6)"
  attr :text, :string, required: true,
    doc: "Heading text"
  attr :size, :atom, default: nil,
    doc: "Override default size for level"
  attr :weight, :atom, default: :bold,
    values: [:normal, :medium, :semibold, :bold, :extrabold],
    doc: "Font weight"
  attr :color, :atom, default: :default,
    doc: "Text color"
  
  def render(assigns) do
    tag = :"h#{assigns.level}"
    
    assigns = assign(assigns, :tag, tag)
    
    ~H"""
    <.dynamic_tag 
      name={@tag}
      class={[
        heading_size(@level, @size),
        font_weight(@weight),
        text_color(@color),
        widget_classes(assigns)
      ]}
    >
      <%= render_debug(assigns) %>
      {@text}
    </.dynamic_tag>
    """
  end
  
  # Default sizes for each level
  defp heading_size(1, nil), do: "text-4xl"
  defp heading_size(2, nil), do: "text-3xl"
  defp heading_size(3, nil), do: "text-2xl"
  defp heading_size(4, nil), do: "text-xl"
  defp heading_size(5, nil), do: "text-lg"
  defp heading_size(6, nil), do: "text-base"
  
  # Size overrides
  defp heading_size(_, :xs), do: "text-xs"
  defp heading_size(_, :sm), do: "text-sm"
  defp heading_size(_, :base), do: "text-base"
  defp heading_size(_, :lg), do: "text-lg"
  defp heading_size(_, :xl), do: "text-xl"
  defp heading_size(_, :xxl), do: "text-2xl"
  defp heading_size(_, :xxxl), do: "text-3xl"
  
  defp font_weight(:normal), do: "font-normal"
  defp font_weight(:medium), do: "font-medium"
  defp font_weight(:semibold), do: "font-semibold"
  defp font_weight(:bold), do: "font-bold"
  defp font_weight(:extrabold), do: "font-extrabold"
  
  defp text_color(:default), do: "text-base-content"
  defp text_color(:primary), do: "text-primary"
  defp text_color(:secondary), do: "text-secondary"
  defp text_color(:muted), do: "text-base-content/70"
  defp text_color(:error), do: "text-error"
  defp text_color(:success), do: "text-success"
end
```

Create `lib/forcefoundation_web/widgets/badge_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.BadgeWidget do
  use ForcefoundationWeb.Widgets.Base
  
  @moduledoc """
  Badge component using DaisyUI badge classes.
  """
  
  attr :label, :string, required: true
  attr :color, :atom, default: :default,
    values: [:default, :primary, :secondary, :accent, :info, :success, :warning, :error, :ghost],
    doc: "Badge color"
  attr :size, :atom, default: :md,
    values: [:xs, :sm, :md, :lg],
    doc: "Badge size"
  attr :outline, :boolean, default: false,
    doc: "Use outline style"
  
  def render(assigns) do
    ~H"""
    <span class={[
      "badge",
      badge_color(@color, @outline),
      badge_size(@size),
      widget_classes(assigns)
    ]}>
      <%= render_debug(assigns) %>
      {@label}
    </span>
    """
  end
  
  defp badge_color(:default, false), do: nil
  defp badge_color(:default, true), do: "badge-outline"
  defp badge_color(color, false), do: "badge-#{color}"
  defp badge_color(color, true), do: "badge-#{color} badge-outline"
  
  defp badge_size(:xs), do: "badge-xs"
  defp badge_size(:sm), do: "badge-sm"
  defp badge_size(:md), do: nil
  defp badge_size(:lg), do: "badge-lg"
end
```

#### Step 3: Update Widget Registry
Update `lib/forcefoundation_web/widgets.ex`:

```elixir
# Add new widgets
import ForcefoundationWeb.Widgets.CardWidget
import ForcefoundationWeb.Widgets.HeadingWidget
import ForcefoundationWeb.Widgets.BadgeWidget
```

#### Step 4: Create Card Test Page
Create `lib/forcefoundation_web/live/card_test_live.ex`:

```elixir
defmodule ForcefoundationWeb.CardTestLive do
  use ForcefoundationWeb, :live_view
  
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100 p-8">
      <.heading_widget level={1} text="Card Widget Examples" class="mb-8" />
      
      <!-- Basic Cards Grid -->
      <.section_widget background={:white} rounded={:lg} padding={6} class="mb-8">
        <.heading_widget level={2} text="Basic Card Variations" class="mb-4" />
        
        <.grid_widget columns={3} gap={6}>
          <!-- Simple Card -->
          <.card_widget title="Simple Card" bordered={true}>
            <p>This is a simple card with just a title and body content.</p>
          </.card_widget>
          
          <!-- Card with Actions -->
          <.card_widget bordered={true} hoverable={true}>
            <:body>
              <.heading_widget level={3} text="Card with Actions" />
              <p>This card has action buttons and hover effect.</p>
            </:body>
            <:actions>
              <button class="btn btn-primary btn-sm">Save</button>
              <button class="btn btn-ghost btn-sm">Cancel</button>
            </:actions>
          </.card_widget>
          
          <!-- Clickable Card -->
          <.card_widget 
            title="Clickable Card" 
            bordered={true}
            clickable={true}
            on_click="card_clicked"
            hoverable={true}
          >
            <p>Click anywhere on this card to trigger an event.</p>
            <.badge_widget label="New" color={:primary} />
          </.card_widget>
        </.grid_widget>
      </.section_widget>
      
      <!-- Cards with Images -->
      <.section_widget background={:white} rounded={:lg} padding={6} class="mb-8">
        <.heading_widget level={2} text="Cards with Images" class="mb-4" />
        
        <.grid_widget columns={3} gap={6}>
          <!-- Card with Top Image -->
          <.card_widget 
            image="https://picsum.photos/400/200?random=1"
            image_alt="Random image"
            bordered={true}
          >
            <:badge>
              <.badge_widget label="Featured" color={:accent} />
            </:badge>
            <:body>
              <.heading_widget level={3} text="Top Image Card" />
              <p>Card with image on top and badge overlay.</p>
            </:body>
            <:actions>
              <button class="btn btn-primary btn-sm">View Details</button>
            </:actions>
          </.card_widget>
          
          <!-- Compact Card -->
          <.card_widget 
            variant={:compact}
            image="https://picsum.photos/400/200?random=2"
            bordered={true}
          >
            <:body>
              <.heading_widget level={3} text="Compact Card" size={:lg} />
              <p class="text-sm">Less padding for dense layouts.</p>
            </:body>
          </.card_widget>
          
          <!-- Side Image Card (spans 2 columns) -->
          <div class="col-span-2">
            <.card_widget 
              variant={:side}
              image="https://picsum.photos/200/200?random=3"
              bordered={true}
            >
              <:body>
                <.heading_widget level={3} text="Side Image Card" />
                <p>This card has the image on the side, perfect for list views.</p>
                <div class="flex gap-2 mt-2">
                  <.badge_widget label="Design" color={:primary} size={:sm} />
                  <.badge_widget label="Development" color={:secondary} size={:sm} />
                </div>
              </:body>
              <:actions>
                <button class="btn btn-primary btn-sm">Learn More</button>
              </:actions>
            </.card_widget>
          </div>
        </.grid_widget>
      </.section_widget>
      
      <!-- Debug Mode Example -->
      <.section_widget background={:white} rounded={:lg} padding={6}>
        <.heading_widget level={2} text="Debug Mode" class="mb-4" />
        
        <.grid_widget columns={2} gap={6}>
          <.card_widget 
            title="Debug Mode Enabled" 
            debug_mode={true}
            bordered={true}
            span={6}
          >
            <p>This card shows debug information including the widget name and configuration.</p>
          </.card_widget>
          
          <.card_widget 
            title="With Grid Span"
            debug_mode={true}
            span={6}
            padding={4}
          >
            <p>This card uses the grid span attribute to take up 6 columns.</p>
          </.card_widget>
        </.grid_widget>
      </.section_widget>
    </div>
    """
  end
  
  def handle_event("card_clicked", _, socket) do
    socket = put_flash(socket, :info, "Card was clicked!")
    {:noreply, socket}
  end
end
```

#### Step 5: Add Route
In router.ex:

```elixir
live "/test/cards", CardTestLive
```

#### Quick & Dirty Test
```bash
# Terminal 1: Compile
mix compile

# Common errors:
# 1. "undefined function dynamic_tag/1"
#    Fix: Phoenix.Component provides this, ensure proper imports
# 2. "** (KeyError) key :figure not found"
#    Fix: Check slot definitions and usage

# Terminal 2: Test rendering
iex -S mix phx.server

# Navigate to http://localhost:4000/test/cards
```

#### Visual Test
```javascript
// Puppeteer tests for cards
await page.goto('http://localhost:4000/test/cards')

// Test 1: Full page screenshot
await page.screenshot({ 
  path: 'screenshots/phase2_section2_cards_full.png',
  fullPage: true 
})

// Test 2: Hover effects
await page.hover('.card.hover\\:shadow-xl:first-of-type')
await page.screenshot({ 
  path: 'screenshots/phase2_section2_card_hover.png',
  clip: { x: 0, y: 200, width: 400, height: 300 }
})

// Test 3: Click interaction
await page.click('.card[phx-click]')
await page.waitForTimeout(500)
const hasFlash = await page.$('[role="alert"]') !== null
console.log('Flash message appeared:', hasFlash)

// Test 4: Responsive grid
await page.setViewport({ width: 375, height: 667 })
await page.screenshot({ 
  path: 'screenshots/phase2_section2_cards_mobile.png',
  fullPage: true 
})
```

#### Implementation Notes
**Date**: ___________
**Developer**: ___________

**Issues Encountered**:
- [ ] Issue: _________________
  - Solution: _________________

**Deviations from Guide**:
- [ ] Changed _______ because _______

**Additional Steps Required**:
- [ ] Had to also _______

**Time Taken**: _____ minutes

#### Section Completion
- [ ] Card widget created with DaisyUI classes
- [ ] All slots working (figure, body, actions, badge)
- [ ] Image support with different layouts
- [ ] Heading and badge widgets created
- [ ] Test page shows all variations
- [ ] Hover and click interactions work
- [ ] Debug mode displays properly
- [ ] `mix compile` runs without errors
- [ ] Visual tests captured
- [ ] Implementation notes documented
- [ ] ✅ **Section 2.2 Complete**

### Section 2.3: Basic Display Widgets
- [ ] Create `text_widget.ex` with size/color/weight options
- [ ] Create `heading_widget.ex` with levels 1-6
- [ ] Create `badge_widget.ex` wrapping DaisyUI badge
- [ ] **TEST**: Add all display widgets to test page
- [ ] **VISUAL TEST**: Screenshot text hierarchy and badges

## Phase 3: Form Widgets (Wrapping Phoenix LiveView Components)

### Section 3.1: Form Container Widget

#### Overview
The FormWidget wraps Phoenix LiveView's `<.form>` component, providing automatic Ash integration and consistent DaisyUI styling. It supports both Ash changesets and regular Ecto changesets, with built-in error handling and submission tracking.

#### Step 1: Create FormWidget Module
Create `lib/forcefoundation_web/widgets/form_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.FormWidget do
  @moduledoc """
  Form container widget that wraps Phoenix LiveView's form component.
  
  Supports both Ash changesets and regular Ecto changesets with automatic
  error handling and submission state tracking.
  
  ## Attributes
  - `:for` - Phoenix.HTML.Form struct or changeset (required)
  - `:action` - Form action URL (optional)
  - `:method` - HTTP method (:post, :put, :patch, :delete)
  - `:multipart` - Whether form accepts file uploads
  - `:as` - Form name (defaults to resource name)
  - `:errors` - Whether to display errors inline
  - `:variant` - Form variant (:default, :inline, :floating)
  - `:on_submit` - Event handler for form submission
  - `:on_change` - Event handler for form changes
  - `:on_reset` - Event handler for form reset
  
  ## Slots
  - `:default` - Form content
  - `:actions` - Form action buttons
  - `:header` - Optional form header
  - `:footer` - Optional form footer
  
  ## Examples
  
      # Basic form
      <.form_widget 
        for={@form} 
        on_submit="save"
      >
        <.input_widget field={@form[:name]} label="Name" />
        <:actions>
          <.button type="submit">Save</.button>
        </:actions>
      </.form_widget>
      
      # Ash form with validation
      <.form_widget
        for={@form}
        on_submit="create_user"
        on_change="validate"
        variant={:floating}
        errors
      >
        <:header>
          <h2 class="text-xl font-bold">Create Account</h2>
        </:header>
        
        <.input_widget field={@form[:email]} label="Email" type="email" />
        <.input_widget field={@form[:password]} label="Password" type="password" />
        
        <:actions>
          <.button type="submit" phx-disable-with="Creating...">
            Create Account
          </.button>
        </:actions>
      </.form_widget>
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :for, :any, required: true, doc: "Phoenix.HTML.Form struct or changeset"
  attr :action, :string, default: nil
  attr :method, :atom, default: :post, values: [:post, :put, :patch, :delete]
  attr :multipart, :boolean, default: false
  attr :as, :atom, default: nil
  attr :errors, :boolean, default: false
  attr :variant, :atom, default: :default, values: [:default, :inline, :floating]
  attr :on_submit, :string, default: nil
  attr :on_change, :string, default: nil
  attr :on_reset, :string, default: nil
  attr :loading, :boolean, default: false
  attr :disabled, :boolean, default: false
  
  slot :default, required: true
  slot :actions
  slot :header
  slot :footer
  
  def render(assigns) do
    assigns = 
      assigns
      |> assign_new(:form_id, fn -> "form-#{System.unique_integer()}" end)
      |> assign_new(:error_messages, fn -> extract_errors(assigns[:for]) end)
    
    ~H"""
    <div class={[
      widget_classes(assigns),
      "widget-form",
      variant_class(@variant)
    ]}>
      <%= if @debug_mode do %>
        <%= render_debug(assigns) %>
      <% end %>
      
      <%= if @header != [] do %>
        <div class="form-header mb-4">
          <%= render_slot(@header) %>
        </div>
      <% end %>
      
      <%= if @errors && @error_messages != [] do %>
        <div class="alert alert-error mb-4">
          <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <div>
            <h3 class="font-bold">Form has errors:</h3>
            <ul class="mt-2 list-disc list-inside">
              <%= for {field, errors} <- @error_messages do %>
                <%= for error <- errors do %>
                  <li><%= humanize(field) %>: <%= error %></li>
                <% end %>
              <% end %>
            </ul>
          </div>
        </div>
      <% end %>
      
      <.form
        :let={f}
        for={@for}
        id={@form_id}
        action={@action}
        method={@method}
        multipart={@multipart}
        as={@as}
        phx-submit={@on_submit}
        phx-change={@on_change}
        phx-trigger-action={@trigger_action}
        class={[
          "form-content",
          @loading && "opacity-50 pointer-events-none",
          @disabled && "opacity-50 pointer-events-none"
        ]}
      >
        <div class={form_content_class(@variant)}>
          <%= render_slot(@default, f) %>
        </div>
        
        <%= if @actions != [] do %>
          <div class={actions_class(@variant)}>
            <%= render_slot(@actions) %>
          </div>
        <% end %>
        
        <%= if @on_reset do %>
          <button type="reset" phx-click={@on_reset} class="hidden">Reset</button>
        <% end %>
      </.form>
      
      <%= if @footer != [] do %>
        <div class="form-footer mt-4">
          <%= render_slot(@footer) %>
        </div>
      <% end %>
    </div>
    """
  end
  
  # Helper functions
  defp variant_class(:default), do: ""
  defp variant_class(:inline), do: "form-inline"
  defp variant_class(:floating), do: "form-floating"
  
  defp form_content_class(:inline), do: "flex flex-wrap gap-4 items-end"
  defp form_content_class(:floating), do: "space-y-6"
  defp form_content_class(_), do: "space-y-4"
  
  defp actions_class(:inline), do: "ml-auto"
  defp actions_class(_), do: "mt-6 flex gap-2"
  
  defp extract_errors(%Phoenix.HTML.Form{source: %Ecto.Changeset{} = changeset}) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
  
  # Support for AshPhoenix.Form
  defp extract_errors(%Phoenix.HTML.Form{source: %AshPhoenix.Form{} = form}) do
    form
    |> AshPhoenix.Form.errors()
    |> Enum.group_by(& &1.field)
    |> Enum.map(fn {field, errors} ->
      {field, Enum.map(errors, & &1.message)}
    end)
  end
  
  defp extract_errors(_), do: []
  
  defp humanize(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
```

#### Step 2: Add Styles
Add to `assets/css/widgets.css`:

```css
/* Form Widget Styles */
.widget-form {
  @apply relative;
}

.form-inline {
  .form-content {
    @apply flex flex-wrap items-end gap-4;
  }
  
  .form-actions {
    @apply ml-auto;
  }
}

.form-floating {
  /* Floating label styles for input widgets */
  .form-control {
    @apply pt-6;
  }
  
  .form-label {
    @apply absolute top-2 left-3 text-sm text-gray-500 transition-all;
    @apply peer-focus:top-1 peer-focus:text-xs;
  }
}

/* Loading state */
.form-loading {
  @apply relative;
  
  &::after {
    content: "";
    @apply absolute inset-0 bg-white bg-opacity-50;
    @apply flex items-center justify-center;
  }
}
```

#### Step 3: Create Form Helper Module
Create `lib/forcefoundation_web/widgets/form_helpers.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.FormHelpers do
  @moduledoc """
  Helper functions for form widgets.
  """
  
  alias Phoenix.HTML.Form
  alias AshPhoenix.Form, as: AshForm
  
  @doc """
  Creates a form from an Ash resource action.
  """
  def create_form(resource, action, params \\ %{}, opts \\ []) do
    resource
    |> AshForm.for_action(action, params, opts)
    |> to_form()
  end
  
  @doc """
  Updates an existing form with new params.
  """
  def update_form(form, params, opts \\ []) do
    form
    |> AshForm.validate(params, opts)
    |> to_form()
  end
  
  @doc """
  Submits a form and handles the result.
  """
  def submit_form(form, opts \\ []) do
    case AshForm.submit(form, opts) do
      {:ok, result} -> {:ok, result}
      {:error, form} -> {:error, to_form(form)}
    end
  end
  
  @doc """
  Adds a nested form to a parent form.
  """
  def add_form(form, field, opts \\ []) do
    form
    |> AshForm.add_form(field, opts)
    |> to_form()
  end
  
  @doc """
  Removes a nested form from a parent form.
  """
  def remove_form(form, field, index) do
    form
    |> AshForm.remove_form([field, index])
    |> to_form()
  end
  
  defp to_form(%AshForm{} = form) do
    AshPhoenix.Form.to_form(form)
  end
  
  defp to_form(other), do: other
end
```

#### Step 4: Create Test LiveView
Create `lib/forcefoundation_web/live/form_test_live.ex`:

```elixir
defmodule ForcefoundationWeb.FormTestLive do
  use ForcefoundationWeb, :live_view
  import ForcefoundationWeb.Widgets
  alias ForcefoundationWeb.Widgets.FormHelpers
  
  # Mock resource for testing
  defmodule User do
    use Ash.Resource,
      data_layer: Ash.DataLayer.Ets
    
    attributes do
      uuid_primary_key :id
      attribute :name, :string, allow_nil?: false
      attribute :email, :string, allow_nil?: false
      attribute :age, :integer
      attribute :bio, :string
      attribute :newsletter, :boolean, default: false
    end
    
    actions do
      defaults [:create, :read, :update]
      
      create :register do
        accept [:name, :email, :age, :bio, :newsletter]
        
        validate match(:email, ~r/^[^\s]+@[^\s]+$/)
        validate numericality(:age, greater_than: 0, less_than: 150)
      end
    end
  end
  
  def mount(_params, _session, socket) do
    form = FormHelpers.create_form(User, :register)
    
    {:ok,
     socket
     |> assign(:form, form)
     |> assign(:result, nil)
     |> assign(:variant, :default)
     |> assign(:show_errors, false)}
  end
  
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8 max-w-4xl">
      <h1 class="text-3xl font-bold mb-8">Form Widget Test Page</h1>
      
      <!-- Variant selector -->
      <div class="mb-8 flex gap-4">
        <button
          :for={variant <- [:default, :inline, :floating]}
          class={[
            "btn btn-sm",
            @variant == variant && "btn-primary"
          ]}
          phx-click="set_variant"
          phx-value-variant={variant}
        >
          <%= String.capitalize(to_string(variant)) %>
        </button>
        
        <label class="label cursor-pointer ml-auto">
          <span class="label-text mr-2">Show errors</span>
          <input
            type="checkbox"
            class="toggle toggle-primary"
            checked={@show_errors}
            phx-click="toggle_errors"
          />
        </label>
      </div>
      
      <!-- Test form -->
      <.form_widget
        for={@form}
        on_submit="save"
        on_change="validate"
        variant={@variant}
        errors={@show_errors}
        debug_mode
      >
        <:header>
          <h2 class="text-xl font-semibold">User Registration Form</h2>
          <p class="text-sm text-gray-600">All fields are validated in real-time</p>
        </:header>
        
        <.input_widget 
          field={@form[:name]} 
          label="Full Name" 
          placeholder="John Doe"
          required
        />
        
        <.input_widget 
          field={@form[:email]} 
          label="Email Address" 
          type="email"
          placeholder="john@example.com"
          required
        />
        
        <.input_widget 
          field={@form[:age]} 
          label="Age" 
          type="number"
          min="1"
          max="150"
        />
        
        <.textarea_widget
          field={@form[:bio]}
          label="Bio"
          placeholder="Tell us about yourself..."
          rows="4"
        />
        
        <.checkbox_widget
          field={@form[:newsletter]}
          label="Subscribe to newsletter"
        />
        
        <:actions>
          <.button type="submit" variant="primary" phx-disable-with="Saving...">
            Register
          </.button>
          <.button type="button" variant="ghost" phx-click="reset">
            Reset
          </.button>
        </:actions>
        
        <:footer>
          <p class="text-sm text-gray-500">
            By registering, you agree to our terms and conditions.
          </p>
        </:footer>
      </.form_widget>
      
      <!-- Result display -->
      <%= if @result do %>
        <div class="mt-8 p-4 bg-success text-success-content rounded-lg">
          <h3 class="font-bold">Form submitted successfully!</h3>
          <pre class="mt-2 text-sm"><%= inspect(@result, pretty: true) %></pre>
        </div>
      <% end %>
      
      <!-- Inline form example -->
      <div class="mt-12">
        <h2 class="text-2xl font-bold mb-4">Inline Form Example</h2>
        <.form_widget
          for={to_form(%{}, as: :search)}
          on_submit="search"
          variant={:inline}
        >
          <.input_widget 
            field={:query} 
            placeholder="Search..." 
            class="w-64"
          />
          <.select_widget
            field={:category}
            options={[
              {"All Categories", ""},
              {"Users", "users"},
              {"Posts", "posts"},
              {"Comments", "comments"}
            ]}
          />
          <:actions>
            <.button type="submit" variant="primary">
              Search
            </.button>
          </:actions>
        </.form_widget>
      </div>
    </div>
    """
  end
  
  def handle_event("validate", %{"user" => params}, socket) do
    form = FormHelpers.update_form(socket.assigns.form, params)
    {:noreply, assign(socket, :form, form)}
  end
  
  def handle_event("save", %{"user" => params}, socket) do
    case FormHelpers.submit_form(socket.assigns.form) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(:result, user)
         |> put_flash(:info, "User registered successfully!")}
      
      {:error, form} ->
        {:noreply,
         socket
         |> assign(:form, form)
         |> assign(:show_errors, true)}
    end
  end
  
  def handle_event("reset", _, socket) do
    form = FormHelpers.create_form(User, :register)
    
    {:noreply,
     socket
     |> assign(:form, form)
     |> assign(:result, nil)
     |> assign(:show_errors, false)}
  end
  
  def handle_event("set_variant", %{"variant" => variant}, socket) do
    {:noreply, assign(socket, :variant, String.to_atom(variant))}
  end
  
  def handle_event("toggle_errors", _, socket) do
    {:noreply, update(socket, :show_errors, &(!&1))}
  end
  
  def handle_event("search", params, socket) do
    IO.inspect(params, label: "Search params")
    {:noreply, put_flash(socket, :info, "Search submitted")}
  end
end
```

#### Step 5: Add Route
In `lib/forcefoundation_web/router.ex`:

```elixir
live "/test/forms", FormTestLive
```

#### Quick & Dirty Test
```bash
# Terminal 1: Compile and check for errors
mix compile

# Common errors:
# 1. "module ForcefoundationWeb.Widgets.Base is not available"
#    Fix: Ensure Base module exists from Phase 1
# 2. "undefined function render_debug/1"
#    Fix: Check Base module includes debug render helper
# 3. "AshPhoenix.Form.errors/1 is undefined"
#    Fix: Add {:ash_phoenix, "~> 1.2"} to mix.exs deps

# Terminal 2: Test in IEx
iex -S mix

iex> alias ForcefoundationWeb.Widgets.FormWidget
iex> # Create a test form
iex> form = Phoenix.HTML.FormData.to_form(%{name: "test", email: "test@example.com"})
iex> # Test render (should return HEEx)
iex> FormWidget.render(%{for: form, on_submit: "save", debug_mode: false})

# Terminal 3: Start server
mix phx.server

# Navigate to http://localhost:4000/test/forms
```

#### Visual Test with Puppeteer
```javascript
// test_form_widget.js
const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({ headless: false });
  const page = await browser.newPage();
  
  // Test 1: Basic form rendering
  await page.goto('http://localhost:4000/test/forms');
  await page.waitForSelector('.widget-form');
  await page.screenshot({ 
    path: 'screenshots/phase3_form_default.png',
    fullPage: true 
  });
  
  // Test 2: Form validation
  await page.click('input[name="user[email]"]');
  await page.type('input[name="user[email]"]', 'invalid-email');
  await page.click('input[name="user[name]"]');
  await page.waitForTimeout(500);
  await page.screenshot({ 
    path: 'screenshots/phase3_form_validation.png',
    fullPage: true 
  });
  
  // Test 3: Inline variant
  await page.click('button:has-text("Inline")');
  await page.waitForTimeout(300);
  await page.screenshot({ 
    path: 'screenshots/phase3_form_inline.png',
    fullPage: true 
  });
  
  // Test 4: Show errors toggle
  await page.click('.toggle');
  await page.waitForTimeout(300);
  await page.screenshot({ 
    path: 'screenshots/phase3_form_errors.png',
    fullPage: true 
  });
  
  // Test 5: Form submission
  await page.click('button:has-text("Default")');
  await page.fill('input[name="user[name]"]', 'John Doe');
  await page.fill('input[name="user[email]"]', 'john@example.com');
  await page.fill('input[name="user[age]"]', '25');
  await page.fill('textarea[name="user[bio]"]', 'Test bio content');
  await page.check('input[name="user[newsletter]"]');
  await page.click('button:has-text("Register")');
  await page.waitForSelector('.bg-success');
  await page.screenshot({ 
    path: 'screenshots/phase3_form_success.png',
    fullPage: true 
  });
  
  // Test 6: Debug mode
  const debugInfo = await page.$('.widget-debug');
  console.log('Debug mode visible:', debugInfo !== null);
  
  await browser.close();
})();
```

Run with:
```bash
node test_form_widget.js
```

#### Implementation Notes
**Date**: ___________
**Developer**: ___________

**Deviations from Design**:
- [ ] None - implemented as specified
- [ ] Modified: ________________________

**Challenges Encountered**:
- [ ] None
- [ ] Issue: ________________________
  - Resolution: ________________________

**Testing Results**:
- [ ] All tests passing
- [ ] Partial success - notes: ________________________
- [ ] Blocked by: ________________________

**Integration Notes**:
- [ ] Works with existing form helpers
- [ ] Ash integration verified
- [ ] Error handling tested
- [ ] All variants functional

#### Completion Checklist
- [ ] FormWidget module created
- [ ] Supports Phoenix.HTML.Form
- [ ] Supports AshPhoenix.Form
- [ ] Error extraction and display working
- [ ] All three variants implemented (default, inline, floating)
- [ ] Form submission handling
- [ ] Form validation on change
- [ ] Loading and disabled states
- [ ] Header and footer slots
- [ ] Actions slot with proper positioning
- [ ] CSS styles added
- [ ] FormHelpers module created
- [ ] Test page created and functional
- [ ] Route added to router
- [ ] IEx testing completed
- [ ] Puppeteer visual tests passing
- [ ] Documentation complete
- [ ] Implementation notes filled out

### Section 3.2: Form Input Widgets

#### Overview
Form input widgets wrap Phoenix LiveView's input components with consistent DaisyUI styling and enhanced features. Each input type provides automatic error handling, label management, and supports both controlled and uncontrolled modes.

#### Step 1: Create InputWidget Module
Create `lib/forcefoundation_web/widgets/input_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.InputWidget do
  @moduledoc """
  Input widget that wraps Phoenix's input component with DaisyUI styling.
  
  Supports all HTML5 input types with automatic error display, floating labels,
  and input group addons.
  
  ## Attributes
  - `:field` - Phoenix.HTML.FormField struct (required)
  - `:type` - Input type (text, email, password, number, etc.)
  - `:label` - Input label
  - `:placeholder` - Placeholder text
  - `:required` - Whether input is required
  - `:disabled` - Whether input is disabled
  - `:readonly` - Whether input is readonly
  - `:variant` - Input variant (:default, :bordered, :ghost, :underline)
  - `:size` - Input size (:xs, :sm, :md, :lg)
  - `:error` - Custom error message (overrides field errors)
  - `:hint` - Help text shown below input
  - `:prefix` - Content to show before input
  - `:suffix` - Content to show after input
  
  ## Examples
  
      # Basic input
      <.input_widget field={@form[:name]} label="Name" />
      
      # Email with validation
      <.input_widget 
        field={@form[:email]} 
        type="email"
        label="Email Address"
        required
        hint="We'll never share your email"
      />
      
      # Input with addons
      <.input_widget
        field={@form[:price]}
        type="number"
        label="Price"
        prefix="$"
        suffix=".00"
        min="0"
        step="0.01"
      />
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :field, Phoenix.HTML.FormField, required: true
  attr :type, :string, default: "text"
  attr :label, :string, default: nil
  attr :placeholder, :string, default: nil
  attr :required, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :readonly, :boolean, default: false
  attr :variant, :atom, default: :bordered, values: [:default, :bordered, :ghost, :underline]
  attr :size, :atom, default: :md, values: [:xs, :sm, :md, :lg]
  attr :error, :string, default: nil
  attr :hint, :string, default: nil
  attr :prefix, :string, default: nil
  attr :suffix, :string, default: nil
  attr :floating_label, :boolean, default: false
  
  # HTML attributes
  attr :autocomplete, :string, default: nil
  attr :pattern, :string, default: nil
  attr :min, :any, default: nil
  attr :max, :any, default: nil
  attr :step, :any, default: nil
  attr :list, :string, default: nil
  
  def render(assigns) do
    errors = get_errors(assigns.field, assigns.error)
    has_error = errors != []
    
    assigns = 
      assigns
      |> assign(:errors, errors)
      |> assign(:has_error, has_error)
      |> assign(:input_id, assigns.field.id || "input-#{System.unique_integer()}")
    
    ~H"""
    <div class={[
      widget_classes(assigns),
      "widget-input form-control",
      @floating_label && "form-control-floating"
    ]}>
      <%= if @debug_mode do %>
        <%= render_debug(assigns) %>
      <% end %>
      
      <%= if @label && !@floating_label do %>
        <label for={@input_id} class="label">
          <span class={["label-text", @required && "after:content-['*'] after:ml-0.5 after:text-error"]}>
            <%= @label %>
          </span>
        </label>
      <% end %>
      
      <div class={[
        @prefix || @suffix && "input-group",
        @has_error && "input-error-wrapper"
      ]}>
        <%= if @prefix do %>
          <span class="input-prefix"><%= @prefix %></span>
        <% end %>
        
        <input
          type={@type}
          name={@field.name}
          id={@input_id}
          value={Phoenix.HTML.Form.normalize_value(@type, @field.value)}
          class={[
            "input",
            input_variant_class(@variant),
            input_size_class(@size),
            @has_error && "input-error",
            @prefix && "has-prefix",
            @suffix && "has-suffix"
          ]}
          placeholder={@placeholder}
          required={@required}
          disabled={@disabled}
          readonly={@readonly}
          autocomplete={@autocomplete}
          pattern={@pattern}
          min={@min}
          max={@max}
          step={@step}
          list={@list}
          phx-debounce="300"
          {@field.errors != [] && "aria-invalid": "true"}
          {@field.errors != [] && "aria-describedby": "#{@input_id}-error"}
        />
        
        <%= if @floating_label && @label do %>
          <label for={@input_id} class="label label-floating">
            <%= @label %>
            <%= if @required do %>
              <span class="text-error ml-0.5">*</span>
            <% end %>
          </label>
        <% end %>
        
        <%= if @suffix do %>
          <span class="input-suffix"><%= @suffix %></span>
        <% end %>
      </div>
      
      <%= if @has_error do %>
        <label class="label" id={"#{@input_id}-error"}>
          <span class="label-text-alt text-error">
            <%= Enum.join(@errors, ", ") %>
          </span>
        </label>
      <% end %>
      
      <%= if @hint && !@has_error do %>
        <label class="label">
          <span class="label-text-alt"><%= @hint %></span>
        </label>
      <% end %>
    </div>
    """
  end
  
  defp get_errors(field, custom_error) do
    cond do
      custom_error -> [custom_error]
      field.errors != [] -> Enum.map(field.errors, &translate_error/1)
      true -> []
    end
  end
  
  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
  
  defp input_variant_class(:default), do: ""
  defp input_variant_class(:bordered), do: "input-bordered"
  defp input_variant_class(:ghost), do: "input-ghost"
  defp input_variant_class(:underline), do: "input-underline"
  
  defp input_size_class(:xs), do: "input-xs"
  defp input_size_class(:sm), do: "input-sm"
  defp input_size_class(:md), do: "input-md"
  defp input_size_class(:lg), do: "input-lg"
end
```

#### Step 2: Create SelectWidget Module
Create `lib/forcefoundation_web/widgets/select_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.SelectWidget do
  @moduledoc """
  Select dropdown widget with DaisyUI styling.
  
  ## Attributes
  - `:field` - Phoenix.HTML.FormField struct (required)
  - `:options` - List of options as {label, value} tuples
  - `:label` - Select label
  - `:prompt` - Default prompt option
  - `:selected` - Currently selected value
  - `:multiple` - Allow multiple selections
  - `:size` - Number of visible options (for multiple)
  
  ## Examples
  
      # Basic select
      <.select_widget 
        field={@form[:country]}
        label="Country"
        options={[
          {"United States", "US"},
          {"Canada", "CA"},
          {"Mexico", "MX"}
        ]}
        prompt="Choose a country"
      />
      
      # Multiple select
      <.select_widget
        field={@form[:tags]}
        label="Tags"
        options={@available_tags}
        multiple
        size={5}
      />
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :field, Phoenix.HTML.FormField, required: true
  attr :options, :list, required: true
  attr :label, :string, default: nil
  attr :prompt, :string, default: nil
  attr :selected, :any, default: nil
  attr :multiple, :boolean, default: false
  attr :size, :integer, default: nil
  attr :required, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :variant, :atom, default: :bordered, values: [:default, :bordered, :ghost]
  attr :select_size, :atom, default: :md, values: [:xs, :sm, :md, :lg]
  attr :error, :string, default: nil
  attr :hint, :string, default: nil
  
  def render(assigns) do
    errors = get_errors(assigns.field, assigns.error)
    has_error = errors != []
    
    assigns = 
      assigns
      |> assign(:errors, errors)
      |> assign(:has_error, has_error)
      |> assign(:select_id, assigns.field.id || "select-#{System.unique_integer()}")
    
    ~H"""
    <div class={[
      widget_classes(assigns),
      "widget-select form-control"
    ]}>
      <%= if @debug_mode do %>
        <%= render_debug(assigns) %>
      <% end %>
      
      <%= if @label do %>
        <label for={@select_id} class="label">
          <span class={["label-text", @required && "after:content-['*'] after:ml-0.5 after:text-error"]}>
            <%= @label %>
          </span>
        </label>
      <% end %>
      
      <select
        name={@field.name <> if(@multiple, do: "[]", else: "")}
        id={@select_id}
        class={[
          "select",
          select_variant_class(@variant),
          select_size_class(@select_size),
          @has_error && "select-error"
        ]}
        multiple={@multiple}
        size={@size}
        required={@required}
        disabled={@disabled}
        {@field.errors != [] && "aria-invalid": "true"}
        {@field.errors != [] && "aria-describedby": "#{@select_id}-error"}
      >
        <%= if @prompt && !@multiple do %>
          <option value=""><%= @prompt %></option>
        <% end %>
        
        <%= Phoenix.HTML.Form.options_for_select(@options, @selected || @field.value) %>
      </select>
      
      <%= if @has_error do %>
        <label class="label" id={"#{@select_id}-error"}>
          <span class="label-text-alt text-error">
            <%= Enum.join(@errors, ", ") %>
          </span>
        </label>
      <% end %>
      
      <%= if @hint && !@has_error do %>
        <label class="label">
          <span class="label-text-alt"><%= @hint %></span>
        </label>
      <% end %>
    </div>
    """
  end
  
  defp get_errors(field, custom_error) do
    cond do
      custom_error -> [custom_error]
      field.errors != [] -> Enum.map(field.errors, &translate_error/1)
      true -> []
    end
  end
  
  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
  
  defp select_variant_class(:default), do: ""
  defp select_variant_class(:bordered), do: "select-bordered"
  defp select_variant_class(:ghost), do: "select-ghost"
  
  defp select_size_class(:xs), do: "select-xs"
  defp select_size_class(:sm), do: "select-sm"
  defp select_size_class(:md), do: "select-md"
  defp select_size_class(:lg), do: "select-lg"
end
```

#### Step 3: Create CheckboxWidget Module
Create `lib/forcefoundation_web/widgets/checkbox_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.CheckboxWidget do
  @moduledoc """
  Checkbox widget with DaisyUI styling.
  
  ## Attributes
  - `:field` - Phoenix.HTML.FormField struct (required)
  - `:label` - Checkbox label
  - `:checked` - Whether checkbox is checked
  - `:variant` - Checkbox variant (:default, :primary, :secondary, etc.)
  - `:size` - Checkbox size (:xs, :sm, :md, :lg)
  
  ## Examples
  
      # Basic checkbox
      <.checkbox_widget 
        field={@form[:terms]}
        label="I agree to the terms and conditions"
      />
      
      # Styled checkbox
      <.checkbox_widget
        field={@form[:newsletter]}
        label="Subscribe to newsletter"
        variant={:primary}
        size={:lg}
      />
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, default: nil
  attr :checked, :boolean, default: nil
  attr :required, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :variant, :atom, default: :default, 
       values: [:default, :primary, :secondary, :accent, :success, :warning, :info, :error]
  attr :size, :atom, default: :md, values: [:xs, :sm, :md, :lg]
  attr :error, :string, default: nil
  
  def render(assigns) do
    errors = get_errors(assigns.field, assigns.error)
    checked_value = assigns.checked || assigns.field.value == true || assigns.field.value == "true"
    
    assigns = 
      assigns
      |> assign(:errors, errors)
      |> assign(:has_error, errors != [])
      |> assign(:checkbox_id, assigns.field.id || "checkbox-#{System.unique_integer()}")
      |> assign(:checked_value, checked_value)
    
    ~H"""
    <div class={[
      widget_classes(assigns),
      "widget-checkbox form-control"
    ]}>
      <%= if @debug_mode do %>
        <%= render_debug(assigns) %>
      <% end %>
      
      <label for={@checkbox_id} class="label cursor-pointer justify-start gap-3">
        <input
          type="checkbox"
          name={@field.name}
          id={@checkbox_id}
          value="true"
          checked={@checked_value}
          class={[
            "checkbox",
            checkbox_variant_class(@variant),
            checkbox_size_class(@size),
            @has_error && "checkbox-error"
          ]}
          required={@required}
          disabled={@disabled}
          {@field.errors != [] && "aria-invalid": "true"}
          {@field.errors != [] && "aria-describedby": "#{@checkbox_id}-error"}
        />
        
        <%= if @label do %>
          <span class={["label-text", @required && "after:content-['*'] after:ml-0.5 after:text-error"]}>
            <%= @label %>
          </span>
        <% end %>
      </label>
      
      <%= if @has_error do %>
        <label class="label" id={"#{@checkbox_id}-error"}>
          <span class="label-text-alt text-error">
            <%= Enum.join(@errors, ", ") %>
          </span>
        </label>
      <% end %>
    </div>
    """
  end
  
  defp get_errors(field, custom_error) do
    cond do
      custom_error -> [custom_error]
      field.errors != [] -> Enum.map(field.errors, &translate_error/1)
      true -> []
    end
  end
  
  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
  
  defp checkbox_variant_class(:default), do: ""
  defp checkbox_variant_class(:primary), do: "checkbox-primary"
  defp checkbox_variant_class(:secondary), do: "checkbox-secondary"
  defp checkbox_variant_class(:accent), do: "checkbox-accent"
  defp checkbox_variant_class(:success), do: "checkbox-success"
  defp checkbox_variant_class(:warning), do: "checkbox-warning"
  defp checkbox_variant_class(:info), do: "checkbox-info"
  defp checkbox_variant_class(:error), do: "checkbox-error"
  
  defp checkbox_size_class(:xs), do: "checkbox-xs"
  defp checkbox_size_class(:sm), do: "checkbox-sm"
  defp checkbox_size_class(:md), do: "checkbox-md"
  defp checkbox_size_class(:lg), do: "checkbox-lg"
end
```

#### Step 4: Create RadioWidget Module
Create `lib/forcefoundation_web/widgets/radio_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.RadioWidget do
  @moduledoc """
  Radio button group widget with DaisyUI styling.
  
  ## Attributes
  - `:field` - Phoenix.HTML.FormField struct (required)
  - `:options` - List of {label, value} tuples
  - `:label` - Group label
  - `:selected` - Currently selected value
  - `:layout` - Layout direction (:vertical, :horizontal)
  
  ## Examples
  
      # Radio group
      <.radio_widget 
        field={@form[:plan]}
        label="Choose your plan"
        options={[
          {"Free", "free"},
          {"Pro ($9/mo)", "pro"},
          {"Enterprise", "enterprise"}
        ]}
      />
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :field, Phoenix.HTML.FormField, required: true
  attr :options, :list, required: true
  attr :label, :string, default: nil
  attr :selected, :any, default: nil
  attr :required, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :layout, :atom, default: :vertical, values: [:vertical, :horizontal]
  attr :variant, :atom, default: :default,
       values: [:default, :primary, :secondary, :accent, :success, :warning, :info, :error]
  attr :size, :atom, default: :md, values: [:xs, :sm, :md, :lg]
  attr :error, :string, default: nil
  
  def render(assigns) do
    errors = get_errors(assigns.field, assigns.error)
    current_value = assigns.selected || assigns.field.value
    
    assigns = 
      assigns
      |> assign(:errors, errors)
      |> assign(:has_error, errors != [])
      |> assign(:current_value, current_value)
      |> assign(:group_id, "radio-group-#{System.unique_integer()}")
    
    ~H"""
    <div class={[
      widget_classes(assigns),
      "widget-radio form-control"
    ]} role="radiogroup" aria-labelledby={@label && "#{@group_id}-label"}>
      <%= if @debug_mode do %>
        <%= render_debug(assigns) %>
      <% end %>
      
      <%= if @label do %>
        <label class="label" id={"#{@group_id}-label"}>
          <span class={["label-text", @required && "after:content-['*'] after:ml-0.5 after:text-error"]}>
            <%= @label %>
          </span>
        </label>
      <% end %>
      
      <div class={[
        "radio-group",
        @layout == :horizontal && "flex flex-wrap gap-4",
        @layout == :vertical && "space-y-2"
      ]}>
        <%= for {option_label, option_value} <- @options do %>
          <label class="label cursor-pointer justify-start gap-2">
            <input
              type="radio"
              name={@field.name}
              value={option_value}
              checked={to_string(@current_value) == to_string(option_value)}
              class={[
                "radio",
                radio_variant_class(@variant),
                radio_size_class(@size),
                @has_error && "radio-error"
              ]}
              required={@required}
              disabled={@disabled}
              {@field.errors != [] && "aria-invalid": "true"}
            />
            <span class="label-text"><%= option_label %></span>
          </label>
        <% end %>
      </div>
      
      <%= if @has_error do %>
        <label class="label">
          <span class="label-text-alt text-error">
            <%= Enum.join(@errors, ", ") %>
          </span>
        </label>
      <% end %>
    </div>
    """
  end
  
  defp get_errors(field, custom_error) do
    cond do
      custom_error -> [custom_error]
      field.errors != [] -> Enum.map(field.errors, &translate_error/1)
      true -> []
    end
  end
  
  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
  
  defp radio_variant_class(:default), do: ""
  defp radio_variant_class(:primary), do: "radio-primary"
  defp radio_variant_class(:secondary), do: "radio-secondary"
  defp radio_variant_class(:accent), do: "radio-accent"
  defp radio_variant_class(:success), do: "radio-success"
  defp radio_variant_class(:warning), do: "radio-warning"
  defp radio_variant_class(:info), do: "radio-info"
  defp radio_variant_class(:error), do: "radio-error"
  
  defp radio_size_class(:xs), do: "radio-xs"
  defp radio_size_class(:sm), do: "radio-sm"
  defp radio_size_class(:md), do: "radio-md"
  defp radio_size_class(:lg), do: "radio-lg"
end
```

#### Step 5: Create TextareaWidget Module
Create `lib/forcefoundation_web/widgets/textarea_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.TextareaWidget do
  @moduledoc """
  Textarea widget for multi-line text input.
  
  ## Attributes
  - `:field` - Phoenix.HTML.FormField struct (required)
  - `:label` - Textarea label
  - `:placeholder` - Placeholder text
  - `:rows` - Number of visible rows
  - `:resize` - Allow resizing (:none, :vertical, :horizontal, :both)
  
  ## Examples
  
      # Basic textarea
      <.textarea_widget 
        field={@form[:description]}
        label="Description"
        rows={4}
      />
      
      # With character counter
      <.textarea_widget
        field={@form[:bio]}
        label="Bio"
        placeholder="Tell us about yourself..."
        rows={6}
        maxlength={500}
        show_count
      />
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, default: nil
  attr :placeholder, :string, default: nil
  attr :rows, :integer, default: 4
  attr :required, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :readonly, :boolean, default: false
  attr :resize, :atom, default: :vertical, values: [:none, :vertical, :horizontal, :both]
  attr :variant, :atom, default: :bordered, values: [:default, :bordered, :ghost]
  attr :size, :atom, default: :md, values: [:xs, :sm, :md, :lg]
  attr :error, :string, default: nil
  attr :hint, :string, default: nil
  attr :maxlength, :integer, default: nil
  attr :show_count, :boolean, default: false
  
  def render(assigns) do
    errors = get_errors(assigns.field, assigns.error)
    has_error = errors != []
    current_length = String.length(assigns.field.value || "")
    
    assigns = 
      assigns
      |> assign(:errors, errors)
      |> assign(:has_error, has_error)
      |> assign(:textarea_id, assigns.field.id || "textarea-#{System.unique_integer()}")
      |> assign(:current_length, current_length)
    
    ~H"""
    <div class={[
      widget_classes(assigns),
      "widget-textarea form-control"
    ]}>
      <%= if @debug_mode do %>
        <%= render_debug(assigns) %>
      <% end %>
      
      <%= if @label do %>
        <label for={@textarea_id} class="label">
          <span class={["label-text", @required && "after:content-['*'] after:ml-0.5 after:text-error"]}>
            <%= @label %>
          </span>
          <%= if @show_count && @maxlength do %>
            <span class="label-text-alt">
              <%= @current_length %>/<%= @maxlength %>
            </span>
          <% end %>
        </label>
      <% end %>
      
      <textarea
        name={@field.name}
        id={@textarea_id}
        rows={@rows}
        class={[
          "textarea",
          textarea_variant_class(@variant),
          textarea_size_class(@size),
          textarea_resize_class(@resize),
          @has_error && "textarea-error"
        ]}
        placeholder={@placeholder}
        required={@required}
        disabled={@disabled}
        readonly={@readonly}
        maxlength={@maxlength}
        phx-debounce="300"
        {@field.errors != [] && "aria-invalid": "true"}
        {@field.errors != [] && "aria-describedby": "#{@textarea_id}-error"}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @field.value) %></textarea>
      
      <%= if @has_error do %>
        <label class="label" id={"#{@textarea_id}-error"}>
          <span class="label-text-alt text-error">
            <%= Enum.join(@errors, ", ") %>
          </span>
        </label>
      <% end %>
      
      <%= if @hint && !@has_error do %>
        <label class="label">
          <span class="label-text-alt"><%= @hint %></span>
          <%= if @show_count && @maxlength && !@label do %>
            <span class="label-text-alt">
              <%= @current_length %>/<%= @maxlength %>
            </span>
          <% end %>
        </label>
      <% end %>
    </div>
    """
  end
  
  defp get_errors(field, custom_error) do
    cond do
      custom_error -> [custom_error]
      field.errors != [] -> Enum.map(field.errors, &translate_error/1)
      true -> []
    end
  end
  
  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
  
  defp textarea_variant_class(:default), do: ""
  defp textarea_variant_class(:bordered), do: "textarea-bordered"
  defp textarea_variant_class(:ghost), do: "textarea-ghost"
  
  defp textarea_size_class(:xs), do: "textarea-xs text-xs"
  defp textarea_size_class(:sm), do: "textarea-sm text-sm"
  defp textarea_size_class(:md), do: "textarea-md"
  defp textarea_size_class(:lg), do: "textarea-lg text-lg"
  
  defp textarea_resize_class(:none), do: "resize-none"
  defp textarea_resize_class(:vertical), do: "resize-y"
  defp textarea_resize_class(:horizontal), do: "resize-x"
  defp textarea_resize_class(:both), do: "resize"
end
```

#### Step 6: Update Widgets Module
Add imports to `lib/forcefoundation_web/widgets.ex`:

```elixir
# In the import_widgets/0 macro, add:
import ForcefoundationWeb.Widgets.InputWidget
import ForcefoundationWeb.Widgets.SelectWidget
import ForcefoundationWeb.Widgets.CheckboxWidget
import ForcefoundationWeb.Widgets.RadioWidget
import ForcefoundationWeb.Widgets.TextareaWidget
```

#### Step 7: Add CSS Styles
Add to `assets/css/widgets.css`:

```css
/* Input Widget Styles */
.widget-input {
  @apply w-full;
}

.input-group {
  @apply relative flex items-center;
}

.input-prefix,
.input-suffix {
  @apply absolute text-gray-500 pointer-events-none;
}

.input-prefix {
  @apply left-3;
}

.input-suffix {
  @apply right-3;
}

.input.has-prefix {
  @apply pl-8;
}

.input.has-suffix {
  @apply pr-8;
}

/* Floating label support */
.form-control-floating {
  @apply relative;
  
  .label-floating {
    @apply absolute left-3 top-3 text-gray-500 transition-all pointer-events-none;
    @apply peer-focus:top-1 peer-focus:text-xs peer-focus:text-primary;
    @apply peer-[:not(:placeholder-shown)]:top-1 peer-[:not(:placeholder-shown)]:text-xs;
  }
  
  input.input {
    @apply peer pt-5 pb-1;
  }
}

/* Error states */
.input-error-wrapper {
  @apply relative;
  
  &::after {
    content: "!";
    @apply absolute right-2 top-1/2 -translate-y-1/2 text-error;
  }
}

/* Radio and Checkbox Groups */
.radio-group,
.checkbox-group {
  @apply w-full;
}

/* Textarea specific */
.textarea {
  @apply leading-normal;
}

/* Size adjustments for form controls */
.select-xs,
.input-xs,
.textarea-xs {
  @apply text-xs;
}

.select-sm,
.input-sm,
.textarea-sm {
  @apply text-sm;
}

.select-lg,
.input-lg,
.textarea-lg {
  @apply text-lg;
}
```

#### Step 8: Update Test Page
Update the FormTestLive from Section 3.1 to test all input types. The test page already includes examples of input_widget, textarea_widget, and checkbox_widget. Let's add more comprehensive tests.

#### Quick & Dirty Test
```bash
# Terminal 1: Compile all new widgets
mix compile

# Common errors:
# 1. "module ForcefoundationWeb.Widgets.Base is not available"
#    Fix: Ensure Base module exists from Phase 1
# 2. "undefined function Phoenix.HTML.Form.normalize_value/2"
#    Fix: Update Phoenix.HTML dependency
# 3. "function textarea_resize_class/1 undefined"
#    Fix: Check all helper functions are defined

# Terminal 2: Test each widget in IEx
iex -S mix

iex> alias ForcefoundationWeb.Widgets.{InputWidget, SelectWidget, CheckboxWidget, RadioWidget, TextareaWidget}
iex> # Create test form field
iex> form = Phoenix.HTML.FormData.to_form(%{email: "test@example.com"}, as: :user)
iex> field = form[:email]
iex> # Test render
iex> InputWidget.render(%{field: field, type: "email", label: "Email", debug_mode: false})

# Terminal 3: Start server and test
mix phx.server

# Navigate to http://localhost:4000/test/forms
```

#### Visual Test with Puppeteer
```javascript
// test_input_widgets.js
const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({ headless: false });
  const page = await browser.newPage();
  
  // Test 1: All input types
  await page.goto('http://localhost:4000/test/forms');
  await page.waitForSelector('.widget-input');
  
  // Screenshot each input state
  await page.screenshot({ 
    path: 'screenshots/phase3_inputs_default.png',
    fullPage: true 
  });
  
  // Test 2: Focus states
  await page.focus('input[type="text"]');
  await page.screenshot({ 
    path: 'screenshots/phase3_input_focused.png' 
  });
  
  // Test 3: Error states
  await page.fill('input[type="email"]', 'invalid-email');
  await page.click('body'); // Trigger blur
  await page.waitForTimeout(500);
  await page.screenshot({ 
    path: 'screenshots/phase3_input_error.png' 
  });
  
  // Test 4: Select widget
  await page.selectOption('select', 'users');
  await page.screenshot({ 
    path: 'screenshots/phase3_select.png' 
  });
  
  // Test 5: Checkbox states
  await page.check('input[type="checkbox"]');
  await page.screenshot({ 
    path: 'screenshots/phase3_checkbox_checked.png' 
  });
  
  // Test 6: Radio buttons
  if (await page.$('input[type="radio"]')) {
    await page.click('input[type="radio"][value="pro"]');
    await page.screenshot({ 
      path: 'screenshots/phase3_radio_selected.png' 
    });
  }
  
  // Test 7: Textarea with character count
  const textarea = await page.$('textarea');
  if (textarea) {
    await page.fill('textarea', 'This is a test of the textarea widget with character counting functionality.');
    await page.screenshot({ 
      path: 'screenshots/phase3_textarea_filled.png' 
    });
  }
  
  // Test 8: Disabled states
  await page.evaluate(() => {
    document.querySelectorAll('input, select, textarea').forEach(el => {
      el.disabled = true;
    });
  });
  await page.screenshot({ 
    path: 'screenshots/phase3_inputs_disabled.png' 
  });
  
  await browser.close();
})();
```

Run with:
```bash
node test_input_widgets.js
```

#### Implementation Notes
**Date**: ___________
**Developer**: ___________

**Deviations from Design**:
- [ ] None - implemented as specified
- [ ] Modified: ________________________

**Challenges Encountered**:
- [ ] None
- [ ] Issue: ________________________
  - Resolution: ________________________

**Testing Results**:
- [ ] All tests passing
- [ ] Partial success - notes: ________________________
- [ ] Blocked by: ________________________

**Integration Notes**:
- [ ] All input types working with Phoenix forms
- [ ] DaisyUI styling properly applied
- [ ] Error handling functional
- [ ] Accessibility attributes included

#### Completion Checklist
- [ ] InputWidget module created
- [ ] SelectWidget module created
- [ ] CheckboxWidget module created
- [ ] RadioWidget module created
- [ ] TextareaWidget module created
- [ ] All widgets support Phoenix.HTML.FormField
- [ ] Error display working for all widgets
- [ ] DaisyUI styling variants implemented
- [ ] Size variants working
- [ ] Required field indicators
- [ ] Disabled/readonly states
- [ ] ARIA attributes for accessibility
- [ ] Floating label support in InputWidget
- [ ] Character counter in TextareaWidget
- [ ] Input groups with prefix/suffix
- [ ] CSS styles added
- [ ] Widgets module updated with imports
- [ ] IEx testing completed
- [ ] Puppeteer visual tests passing
- [ ] Documentation complete
- [ ] Implementation notes filled out

### Section 3.3: Nested Form Support

#### Overview
Nested form widgets handle complex data structures with parent-child relationships. They wrap Phoenix LiveView's `inputs_for` functionality while providing intuitive UI for adding, removing, and organizing nested data.

#### Step 1: Create NestedFormWidget Module
Create `lib/forcefoundation_web/widgets/nested_form_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.NestedFormWidget do
  @moduledoc """
  Nested form widget for handling has_many and embeds_many associations.
  
  Wraps Phoenix's inputs_for with automatic add/remove functionality and
  drag-and-drop reordering support.
  
  ## Attributes
  - `:field` - Parent form field for the association
  - `:label` - Label for the nested form section
  - `:add_label` - Label for add button (default: "Add")
  - `:remove_label` - Label for remove button (default: "Remove")
  - `:max_items` - Maximum number of items allowed
  - `:min_items` - Minimum number of items required
  - `:sortable` - Enable drag-and-drop reordering
  - `:collapsed` - Start with items collapsed
  
  ## Slots
  - `:default` - Content for each nested form item (receives f)
  - `:empty` - Content to show when no items
  - `:header` - Header for each item (receives f and index)
  
  ## Examples
  
      # Address list
      <.nested_form_widget 
        field={@form[:addresses]}
        label="Addresses"
        add_label="Add Address"
        max_items={3}
      >
        <:header :let={%{index: index}}>
          Address <%= index + 1 %>
        </:header>
        
        <.input_widget field={f[:street]} label="Street" />
        <.input_widget field={f[:city]} label="City" />
        <.input_widget field={f[:zip]} label="ZIP Code" />
      </.nested_form_widget>
  """
  use ForcefoundationWeb.Widgets.Base
  import Phoenix.HTML.Form
  
  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, default: nil
  attr :add_label, :string, default: "Add"
  attr :remove_label, :string, default: "Remove"
  attr :max_items, :integer, default: nil
  attr :min_items, :integer, default: 1
  attr :sortable, :boolean, default: false
  attr :collapsed, :boolean, default: false
  attr :variant, :atom, default: :default, values: [:default, :bordered, :compact]
  attr :on_add, :string, default: nil
  attr :on_remove, :string, default: nil
  attr :on_sort, :string, default: nil
  
  slot :default, required: true, doc: "Form content for each item"
  slot :empty, doc: "Content when no items exist"
  slot :header, doc: "Header for each item"
  
  def render(assigns) do
    nested_forms = inputs_for(assigns.field) || []
    item_count = length(nested_forms)
    can_add = is_nil(assigns.max_items) || item_count < assigns.max_items
    can_remove = item_count > assigns.min_items
    
    assigns = 
      assigns
      |> assign(:nested_forms, nested_forms)
      |> assign(:item_count, item_count)
      |> assign(:can_add, can_add)
      |> assign(:can_remove, can_remove)
      |> assign(:container_id, "nested-form-#{System.unique_integer()}")
    
    ~H"""
    <div class={[
      widget_classes(assigns),
      "widget-nested-form",
      variant_class(@variant)
    ]} id={@container_id}>
      <%= if @debug_mode do %>
        <%= render_debug(assigns) %>
      <% end %>
      
      <%= if @label do %>
        <div class="nested-form-header mb-4">
          <h3 class="text-lg font-medium"><%= @label %></h3>
          <span class="text-sm text-gray-500">
            <%= @item_count %> <%= inflect("item", @item_count) %>
            <%= if @max_items do %>
              (max <%= @max_items %>)
            <% end %>
          </span>
        </div>
      <% end %>
      
      <div class={[
        "nested-form-items",
        @sortable && "sortable",
        @variant == :compact && "space-y-2"
      ]} phx-hook={@sortable && "Sortable"} data-group={@container_id}>
        <%= if @item_count == 0 do %>
          <div class="nested-form-empty p-8 text-center text-gray-500">
            <%= if @empty != [] do %>
              <%= render_slot(@empty) %>
            <% else %>
              No items yet. Click "Add" to create one.
            <% end %>
          </div>
        <% else %>
          <%= for {f, index} <- Enum.with_index(@nested_forms) do %>
            <div 
              class={[
                "nested-form-item",
                item_variant_class(@variant),
                @collapsed && "collapsed"
              ]}
              data-index={index}
              id={"#{@container_id}-item-#{index}"}
            >
              <%= if @sortable do %>
                <div class="drag-handle cursor-move p-2" title="Drag to reorder">
                  <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 8h16M4 16h16"/>
                  </svg>
                </div>
              <% end %>
              
              <div class="nested-form-content flex-1">
                <%= if @header != [] do %>
                  <div class="nested-form-item-header" phx-click={@collapsed && "toggle_item"} phx-value-index={index}>
                    <%= render_slot(@header, %{f: f, index: index}) %>
                    <%= if @collapsed do %>
                      <svg class="collapse-icon w-5 h-5 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                      </svg>
                    <% end %>
                  </div>
                <% end %>
                
                <div class={["nested-form-item-body", @collapsed && "hidden"]}>
                  <%= render_slot(@default, f) %>
                </div>
              </div>
              
              <%= if @can_remove do %>
                <button
                  type="button"
                  class="btn btn-ghost btn-sm text-error"
                  phx-click={@on_remove || "remove_nested_item"}
                  phx-value-field={@field.field}
                  phx-value-index={index}
                  title={@remove_label}
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                  </svg>
                  <span class="hidden sm:inline ml-1"><%= @remove_label %></span>
                </button>
              <% end %>
            </div>
          <% end %>
        <% end %>
      </div>
      
      <%= if @can_add do %>
        <div class="nested-form-actions mt-4">
          <button
            type="button"
            class="btn btn-primary btn-sm"
            phx-click={@on_add || "add_nested_item"}
            phx-value-field={@field.field}
          >
            <svg class="w-5 h-5 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
            </svg>
            <%= @add_label %>
          </button>
        </div>
      <% end %>
    </div>
    """
  end
  
  # Helper functions
  defp variant_class(:default), do: ""
  defp variant_class(:bordered), do: "nested-form-bordered"
  defp variant_class(:compact), do: "nested-form-compact"
  
  defp item_variant_class(:default), do: "p-4 bg-gray-50 rounded-lg"
  defp item_variant_class(:bordered), do: "p-4 border border-gray-200 rounded-lg"
  defp item_variant_class(:compact), do: "p-2"
  
  defp inflect(word, 1), do: word
  defp inflect(word, _), do: word <> "s"
end
```

#### Step 2: Create FieldsetWidget Module
Create `lib/forcefoundation_web/widgets/fieldset_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.FieldsetWidget do
  @moduledoc """
  Fieldset widget for grouping related form fields.
  
  Provides visual grouping with optional legend, collapsible sections,
  and validation indicators.
  
  ## Attributes
  - `:legend` - Fieldset legend/title
  - `:description` - Help text for the fieldset
  - `:collapsible` - Allow collapsing the fieldset
  - `:collapsed` - Start in collapsed state
  - `:required` - Mark entire fieldset as required
  - `:variant` - Visual variant
  
  ## Examples
  
      # Personal information group
      <.fieldset_widget legend="Personal Information" required>
        <.input_widget field={@form[:first_name]} label="First Name" />
        <.input_widget field={@form[:last_name]} label="Last Name" />
        <.input_widget field={@form[:email]} label="Email" />
      </.fieldset_widget>
      
      # Collapsible preferences
      <.fieldset_widget 
        legend="Preferences" 
        description="Optional settings"
        collapsible
        collapsed
      >
        <.checkbox_widget field={@form[:newsletter]} label="Newsletter" />
        <.select_widget field={@form[:language]} label="Language" options={@languages} />
      </.fieldset_widget>
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :legend, :string, default: nil
  attr :description, :string, default: nil
  attr :collapsible, :boolean, default: false
  attr :collapsed, :boolean, default: false
  attr :required, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :variant, :atom, default: :default, values: [:default, :bordered, :filled, :accent]
  attr :icon, :string, default: nil
  attr :error, :boolean, default: false
  attr :success, :boolean, default: false
  
  slot :default, required: true
  slot :actions
  
  def render(assigns) do
    assigns = 
      assigns
      |> assign(:fieldset_id, "fieldset-#{System.unique_integer()}")
      |> assign_new(:is_collapsed, fn -> assigns.collapsed end)
    
    ~H"""
    <fieldset class={[
      widget_classes(assigns),
      "widget-fieldset",
      fieldset_variant_class(@variant),
      @error && "fieldset-error",
      @success && "fieldset-success",
      @disabled && "opacity-50"
    ]} disabled={@disabled} id={@fieldset_id}>
      <%= if @debug_mode do %>
        <%= render_debug(assigns) %>
      <% end %>
      
      <%= if @legend do %>
        <legend class={[
          "fieldset-legend",
          @collapsible && "cursor-pointer select-none"
        ]} phx-click={@collapsible && "toggle_fieldset"} phx-value-id={@fieldset_id}>
          <div class="flex items-center gap-2">
            <%= if @icon do %>
              <span class="fieldset-icon"><%= @icon %></span>
            <% end %>
            
            <span class="fieldset-title">
              <%= @legend %>
              <%= if @required do %>
                <span class="text-error ml-1">*</span>
              <% end %>
            </span>
            
            <%= if @collapsible do %>
              <svg 
                class={[
                  "w-5 h-5 transition-transform ml-auto",
                  @is_collapsed && "rotate-180"
                ]}
                fill="none" 
                stroke="currentColor" 
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
              </svg>
            <% end %>
          </div>
          
          <%= if @description && !@is_collapsed do %>
            <p class="fieldset-description mt-1 text-sm text-gray-600">
              <%= @description %>
            </p>
          <% end %>
        </legend>
      <% end %>
      
      <div class={[
        "fieldset-content",
        @is_collapsed && @collapsible && "hidden"
      ]}>
        <%= render_slot(@default) %>
        
        <%= if @actions != [] do %>
          <div class="fieldset-actions mt-4 pt-4 border-t">
            <%= render_slot(@actions) %>
          </div>
        <% end %>
      </div>
    </fieldset>
    """
  end
  
  defp fieldset_variant_class(:default), do: ""
  defp fieldset_variant_class(:bordered), do: "border border-gray-300 rounded-lg p-4"
  defp fieldset_variant_class(:filled), do: "bg-gray-50 rounded-lg p-4"
  defp fieldset_variant_class(:accent), do: "border-l-4 border-primary pl-4"
end
```

#### Step 3: Create RepeaterWidget Module
Create `lib/forcefoundation_web/widgets/repeater_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.RepeaterWidget do
  @moduledoc """
  Repeater widget for dynamic lists of simple values.
  
  Unlike NestedFormWidget which handles complex nested forms, RepeaterWidget
  is optimized for lists of single values like tags, emails, or phone numbers.
  
  ## Attributes
  - `:field` - Form field for the list
  - `:label` - Label for the repeater
  - `:placeholder` - Placeholder for new items
  - `:pattern` - Validation pattern for items
  - `:unique` - Enforce unique values
  - `:sort` - Auto-sort items
  - `:max_items` - Maximum number of items
  
  ## Examples
  
      # Email list
      <.repeater_widget 
        field={@form[:emails]}
        label="Email Addresses"
        placeholder="Enter email address"
        pattern="[^@]+@[^@]+\.[^@]+"
        unique
      />
      
      # Tags with autocomplete
      <.repeater_widget
        field={@form[:tags]}
        label="Tags"
        placeholder="Add tag..."
        suggestions={@available_tags}
        max_items={10}
      />
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, default: nil
  attr :placeholder, :string, default: "Add item..."
  attr :pattern, :string, default: nil
  attr :unique, :boolean, default: false
  attr :sort, :boolean, default: false
  attr :max_items, :integer, default: nil
  attr :min_items, :integer, default: 0
  attr :input_type, :string, default: "text"
  attr :suggestions, :list, default: []
  attr :variant, :atom, default: :default, values: [:default, :pills, :list]
  attr :size, :atom, default: :md, values: [:sm, :md, :lg]
  attr :on_add, :string, default: nil
  attr :on_remove, :string, default: nil
  
  def render(assigns) do
    items = get_list_value(assigns.field)
    item_count = length(items)
    can_add = is_nil(assigns.max_items) || item_count < assigns.max_items
    
    assigns = 
      assigns
      |> assign(:items, items)
      |> assign(:item_count, item_count)
      |> assign(:can_add, can_add)
      |> assign(:repeater_id, "repeater-#{System.unique_integer()}")
      |> assign(:input_id, "repeater-input-#{System.unique_integer()}")
      |> assign(:datalist_id, "repeater-list-#{System.unique_integer()}")
    
    ~H"""
    <div class={[
      widget_classes(assigns),
      "widget-repeater",
      "repeater-variant-#{@variant}"
    ]} id={@repeater_id}>
      <%= if @debug_mode do %>
        <%= render_debug(assigns) %>
      <% end %>
      
      <%= if @label do %>
        <label class="label">
          <span class="label-text">
            <%= @label %>
            <span class="text-sm text-gray-500 ml-2">
              (<%= @item_count %><%= if @max_items, do: "/#{@max_items}" %>)
            </span>
          </span>
        </label>
      <% end %>
      
      <div class={repeater_items_class(@variant)}>
        <%= for {item, index} <- Enum.with_index(@items) do %>
          <div class={repeater_item_class(@variant, @size)} data-value={item}>
            <span class="repeater-item-text"><%= item %></span>
            <button
              type="button"
              class="repeater-item-remove"
              phx-click={@on_remove || "remove_repeater_item"}
              phx-value-field={@field.field}
              phx-value-index={index}
              title="Remove"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
            <input type="hidden" name={@field.name <> "[]"} value={item} />
          </div>
        <% end %>
      </div>
      
      <%= if @can_add do %>
        <div class="repeater-input-wrapper mt-2">
          <form phx-submit={@on_add || "add_repeater_item"} class="flex gap-2">
            <input
              type={@input_type}
              id={@input_id}
              name="new_item"
              placeholder={@placeholder}
              pattern={@pattern}
              list={@suggestions != [] && @datalist_id}
              class={[
                "input input-bordered flex-1",
                repeater_input_size_class(@size)
              ]}
              phx-value-field={@field.field}
            />
            
            <%= if @suggestions != [] do %>
              <datalist id={@datalist_id}>
                <%= for suggestion <- @suggestions do %>
                  <option value={suggestion} />
                <% end %>
              </datalist>
            <% end %>
            
            <button type="submit" class={["btn btn-primary", repeater_button_size_class(@size)]}>
              Add
            </button>
          </form>
          
          <%= if @pattern do %>
            <p class="text-xs text-gray-500 mt-1">
              Format: <%= @pattern %>
            </p>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
  
  defp get_list_value(%{value: value}) when is_list(value), do: value
  defp get_list_value(_), do: []
  
  defp repeater_items_class(:pills), do: "flex flex-wrap gap-2"
  defp repeater_items_class(:list), do: "space-y-2"
  defp repeater_items_class(_), do: "space-y-2"
  
  defp repeater_item_class(:pills, size) do
    [
      "inline-flex items-center gap-1 px-3 py-1 rounded-full",
      "bg-primary text-primary-content",
      size_class(size)
    ]
  end
  
  defp repeater_item_class(:list, size) do
    [
      "flex items-center justify-between p-2",
      "border border-gray-200 rounded",
      size_class(size)
    ]
  end
  
  defp repeater_item_class(_, size) do
    [
      "flex items-center gap-2 p-2",
      "bg-gray-100 rounded",
      size_class(size)
    ]
  end
  
  defp size_class(:sm), do: "text-sm"
  defp size_class(:lg), do: "text-lg"
  defp size_class(_), do: ""
  
  defp repeater_input_size_class(:sm), do: "input-sm"
  defp repeater_input_size_class(:lg), do: "input-lg"
  defp repeater_input_size_class(_), do: ""
  
  defp repeater_button_size_class(:sm), do: "btn-sm"
  defp repeater_button_size_class(:lg), do: "btn-lg"
  defp repeater_button_size_class(_), do: ""
end
```

#### Step 4: Add JavaScript Hook for Sortable
Add to `assets/js/hooks.js`:

```javascript
// Sortable Hook for drag-and-drop
export const Sortable = {
  mounted() {
    this.initSortable()
  },
  
  updated() {
    this.initSortable()
  },
  
  initSortable() {
    if (typeof Sortable === 'undefined') {
      console.warn('Sortable.js not loaded')
      return
    }
    
    const group = this.el.dataset.group
    
    new Sortable(this.el, {
      handle: '.drag-handle',
      animation: 150,
      fallbackOnBody: true,
      swapThreshold: 0.65,
      
      onEnd: (evt) => {
        const newIndex = evt.newIndex
        const oldIndex = evt.oldIndex
        
        if (newIndex !== oldIndex) {
          this.pushEvent('reorder_items', {
            field: group,
            old_index: oldIndex,
            new_index: newIndex
          })
        }
      }
    })
  }
}
```

#### Step 5: Update Test Page
Create `lib/forcefoundation_web/live/nested_form_test_live.ex`:

```elixir
defmodule ForcefoundationWeb.NestedFormTestLive do
  use ForcefoundationWeb, :live_view
  import ForcefoundationWeb.Widgets
  alias ForcefoundationWeb.Widgets.FormHelpers
  
  # Mock schemas for testing
  defmodule Address do
    use Ash.Resource,
      data_layer: Ash.DataLayer.Ets
    
    attributes do
      uuid_primary_key :id
      attribute :street, :string
      attribute :city, :string
      attribute :state, :string
      attribute :zip, :string
    end
  end
  
  defmodule Contact do
    use Ash.Resource,
      data_layer: Ash.DataLayer.Ets
    
    attributes do
      uuid_primary_key :id
      attribute :name, :string
      attribute :emails, {:array, :string}, default: []
      attribute :phones, {:array, :string}, default: []
      
      # For nested forms
      attribute :addresses, {:array, Address}
    end
    
    actions do
      defaults [:create, :read, :update]
      
      create :register do
        accept [:name, :emails, :phones, :addresses]
      end
    end
  end
  
  def mount(_params, _session, socket) do
    form = FormHelpers.create_form(Contact, :register, %{
      addresses: [%{}]  # Start with one empty address
    })
    
    {:ok,
     socket
     |> assign(:form, form)
     |> assign(:demo_type, :nested_forms)}
  end
  
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8 max-w-4xl">
      <h1 class="text-3xl font-bold mb-8">Nested Form Widgets Test</h1>
      
      <!-- Demo selector -->
      <div class="tabs tabs-boxed mb-8">
        <a 
          class={["tab", @demo_type == :nested_forms && "tab-active"]}
          phx-click="set_demo" 
          phx-value-type="nested_forms"
        >
          Nested Forms
        </a>
        <a 
          class={["tab", @demo_type == :fieldsets && "tab-active"]}
          phx-click="set_demo" 
          phx-value-type="fieldsets"
        >
          Fieldsets
        </a>
        <a 
          class={["tab", @demo_type == :repeaters && "tab-active"]}
          phx-click="set_demo" 
          phx-value-type="repeaters"
        >
          Repeaters
        </a>
      </div>
      
      <%= case @demo_type do %>
        <% :nested_forms -> %>
          <.form_widget for={@form} on_submit="save" debug_mode>
            <.input_widget field={@form[:name]} label="Contact Name" required />
            
            <.nested_form_widget 
              field={@form[:addresses]}
              label="Addresses"
              add_label="Add Address"
              remove_label="Remove"
              max_items={5}
              min_items={1}
              sortable
              on_add="add_address"
              on_remove="remove_address"
            >
              <:header :let={%{index: index}}>
                <h4 class="font-medium">Address <%= index + 1 %></h4>
              </:header>
              
              <div class="grid grid-cols-2 gap-4">
                <.input_widget field={f[:street]} label="Street Address" class="col-span-2" />
                <.input_widget field={f[:city]} label="City" />
                <.input_widget field={f[:state]} label="State" />
                <.input_widget field={f[:zip]} label="ZIP Code" />
              </div>
            </.nested_form_widget>
            
            <:actions>
              <.button type="submit" variant="primary">
                Save Contact
              </.button>
            </:actions>
          </.form_widget>
          
        <% :fieldsets -> %>
          <.form_widget for={@form} on_submit="save">
            <.fieldset_widget 
              legend="Basic Information" 
              description="Required contact details"
              required
              icon="👤"
            >
              <.input_widget field={@form[:name]} label="Full Name" required />
              <.repeater_widget 
                field={@form[:emails]} 
                label="Email Addresses"
                input_type="email"
                unique
              />
            </.fieldset_widget>
            
            <.fieldset_widget 
              legend="Additional Information" 
              description="Optional contact details"
              collapsible
              collapsed
              variant={:bordered}
            >
              <.repeater_widget 
                field={@form[:phones]} 
                label="Phone Numbers"
                placeholder="Enter phone number"
                pattern="[0-9-()+ ]+"
              />
            </.fieldset_widget>
            
            <.fieldset_widget 
              legend="Settings" 
              variant={:accent}
              error={false}
            >
              <.checkbox_widget field={@form[:newsletter]} label="Subscribe to newsletter" />
              <.select_widget 
                field={@form[:language]} 
                label="Preferred Language"
                options={[{"English", "en"}, {"Spanish", "es"}, {"French", "fr"}]}
              />
            </.fieldset_widget>
            
            <:actions>
              <.button type="submit" variant="primary">Save</button>
            </:actions>
          </.form_widget>
          
        <% :repeaters -> %>
          <.form_widget for={@form} on_submit="save">
            <.input_widget field={@form[:name]} label="Name" />
            
            <.repeater_widget 
              field={@form[:emails]}
              label="Email Addresses"
              placeholder="Enter email address"
              input_type="email"
              pattern="[^@]+@[^@]+\.[^@]+"
              unique
              max_items={5}
              variant={:pills}
              debug_mode
            />
            
            <.repeater_widget 
              field={@form[:phones]}
              label="Phone Numbers"
              placeholder="Add phone number"
              pattern="[0-9-()+ ]+"
              variant={:list}
              size={:lg}
            />
            
            <.repeater_widget 
              field={@form[:tags]}
              label="Tags"
              placeholder="Add tag..."
              suggestions={["urgent", "important", "follow-up", "personal", "work"]}
              variant={:default}
              sort
            />
            
            <:actions>
              <.button type="submit" variant="primary">Save</button>
            </:actions>
          </.form_widget>
      <% end %>
    </div>
    """
  end
  
  # Event handlers
  def handle_event("set_demo", %{"type" => type}, socket) do
    {:noreply, assign(socket, :demo_type, String.to_atom(type))}
  end
  
  def handle_event("add_address", _, socket) do
    form = FormHelpers.add_form(socket.assigns.form, :addresses)
    {:noreply, assign(socket, :form, form)}
  end
  
  def handle_event("remove_address", %{"index" => index}, socket) do
    form = FormHelpers.remove_form(socket.assigns.form, :addresses, String.to_integer(index))
    {:noreply, assign(socket, :form, form)}
  end
  
  def handle_event("add_repeater_item", %{"field" => field, "new_item" => value}, socket) do
    field_atom = String.to_atom(field)
    current_values = get_in(socket.assigns.form.source.params, [field_atom]) || []
    new_values = current_values ++ [value]
    
    form = FormHelpers.update_form(socket.assigns.form, %{field_atom => new_values})
    {:noreply, assign(socket, :form, form)}
  end
  
  def handle_event("remove_repeater_item", %{"field" => field, "index" => index}, socket) do
    field_atom = String.to_atom(field)
    index = String.to_integer(index)
    current_values = get_in(socket.assigns.form.source.params, [field_atom]) || []
    new_values = List.delete_at(current_values, index)
    
    form = FormHelpers.update_form(socket.assigns.form, %{field_atom => new_values})
    {:noreply, assign(socket, :form, form)}
  end
  
  def handle_event("save", %{"contact" => params}, socket) do
    case FormHelpers.submit_form(socket.assigns.form) do
      {:ok, contact} ->
        {:noreply,
         socket
         |> put_flash(:info, "Contact saved successfully!")
         |> assign(:result, contact)}
      
      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
end
```

#### Step 6: Add Route
In `lib/forcefoundation_web/router.ex`:

```elixir
live "/test/nested-forms", NestedFormTestLive
```

#### Step 7: Add CSS Styles
Add to `assets/css/widgets.css`:

```css
/* Nested Form Widget Styles */
.widget-nested-form {
  @apply space-y-4;
}

.nested-form-item {
  @apply flex gap-4 transition-all;
  
  &.collapsed {
    .nested-form-item-body {
      @apply hidden;
    }
    
    .collapse-icon {
      @apply rotate-180;
    }
  }
}

.nested-form-item-header {
  @apply flex items-center justify-between p-2 cursor-pointer;
}

.drag-handle {
  @apply cursor-move opacity-50 hover:opacity-100 transition-opacity;
}

/* Fieldset Widget Styles */
.widget-fieldset {
  @apply relative;
}

.fieldset-legend {
  @apply text-lg font-medium mb-4;
}

.fieldset-content {
  @apply space-y-4;
}

.fieldset-error {
  @apply border-error;
  
  .fieldset-legend {
    @apply text-error;
  }
}

.fieldset-success {
  @apply border-success;
  
  .fieldset-legend {
    @apply text-success;
  }
}

/* Repeater Widget Styles */
.widget-repeater {
  @apply space-y-2;
}

.repeater-variant-pills {
  .repeater-item-remove {
    @apply ml-1 hover:text-error-content;
  }
}

.repeater-variant-list {
  .repeater-item-remove {
    @apply text-error hover:text-error-focus;
  }
}

.repeater-item-remove {
  @apply p-1 rounded hover:bg-black hover:bg-opacity-10 transition-colors;
}

/* Sortable styles */
.sortable-ghost {
  @apply opacity-50;
}

.sortable-drag {
  @apply shadow-lg;
}
```

#### Quick & Dirty Test
```bash
# Terminal 1: Compile
mix compile

# Common errors:
# 1. "undefined function inputs_for/1"
#    Fix: Import Phoenix.HTML.Form in nested_form_widget.ex
# 2. "Sortable is not defined"
#    Fix: Add Sortable.js to assets or use CDN
# 3. "undefined function get_in/2"
#    Fix: Ensure Kernel is imported

# Terminal 2: Test widgets
iex -S mix

iex> alias ForcefoundationWeb.Widgets.{NestedFormWidget, FieldsetWidget, RepeaterWidget}
iex> # Test rendering
iex> form = Phoenix.HTML.FormData.to_form(%{addresses: []}, as: :contact)
iex> field = form[:addresses]
iex> NestedFormWidget.render(%{field: field, label: "Addresses", debug_mode: false})

# Terminal 3: Start server
mix phx.server

# Navigate to http://localhost:4000/test/nested-forms
```

#### Visual Test with Puppeteer
```javascript
// test_nested_forms.js
const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({ headless: false });
  const page = await browser.newPage();
  
  // Test 1: Nested forms
  await page.goto('http://localhost:4000/test/nested-forms');
  await page.waitForSelector('.widget-nested-form');
  await page.screenshot({ 
    path: 'screenshots/phase3_nested_default.png',
    fullPage: true 
  });
  
  // Test 2: Add nested items
  await page.click('button:has-text("Add Address")');
  await page.waitForTimeout(300);
  await page.click('button:has-text("Add Address")');
  await page.waitForTimeout(300);
  await page.screenshot({ 
    path: 'screenshots/phase3_nested_multiple.png',
    fullPage: true 
  });
  
  // Test 3: Fieldsets
  await page.click('.tab:has-text("Fieldsets")');
  await page.waitForTimeout(500);
  await page.screenshot({ 
    path: 'screenshots/phase3_fieldsets.png',
    fullPage: true 
  });
  
  // Test 4: Collapse fieldset
  await page.click('legend:has-text("Additional Information")');
  await page.waitForTimeout(300);
  await page.screenshot({ 
    path: 'screenshots/phase3_fieldset_expanded.png',
    fullPage: true 
  });
  
  // Test 5: Repeaters
  await page.click('.tab:has-text("Repeaters")');
  await page.waitForTimeout(500);
  
  // Add items to repeaters
  await page.fill('input[placeholder="Enter email address"]', 'test@example.com');
  await page.click('button:has-text("Add"):near(input[placeholder="Enter email address"])');
  await page.waitForTimeout(300);
  
  await page.fill('input[placeholder="Add phone number"]', '123-456-7890');
  await page.click('button:has-text("Add"):near(input[placeholder="Add phone number"])');
  await page.waitForTimeout(300);
  
  await page.screenshot({ 
    path: 'screenshots/phase3_repeaters.png',
    fullPage: true 
  });
  
  // Test 6: Remove items
  await page.click('.repeater-item-remove');
  await page.waitForTimeout(300);
  await page.screenshot({ 
    path: 'screenshots/phase3_repeater_removed.png',
    fullPage: true 
  });
  
  await browser.close();
})();
```

Run with:
```bash
node test_nested_forms.js
```

#### Implementation Notes
**Date**: ___________
**Developer**: ___________

**Deviations from Design**:
- [ ] None - implemented as specified
- [ ] Modified: ________________________

**Challenges Encountered**:
- [ ] None
- [ ] Issue: ________________________
  - Resolution: ________________________

**Testing Results**:
- [ ] All tests passing
- [ ] Partial success - notes: ________________________
- [ ] Blocked by: ________________________

**Integration Notes**:
- [ ] Nested forms working with Ash associations
- [ ] Drag-and-drop requires Sortable.js library
- [ ] Add/remove functionality tested
- [ ] Fieldset collapsing working

#### Completion Checklist
- [ ] NestedFormWidget module created
- [ ] FieldsetWidget module created
- [ ] RepeaterWidget module created
- [ ] Supports Phoenix inputs_for functionality
- [ ] Add/remove item handlers implemented
- [ ] Drag-and-drop sorting support
- [ ] Fieldset collapsing functionality
- [ ] Repeater with unique value enforcement
- [ ] All three widget variants tested
- [ ] JavaScript hooks configured
- [ ] CSS styles added
- [ ] Test page with all demos
- [ ] Route added to router
- [ ] IEx testing completed
- [ ] Puppeteer visual tests passing
- [ ] Documentation complete
- [ ] Implementation notes filled out
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