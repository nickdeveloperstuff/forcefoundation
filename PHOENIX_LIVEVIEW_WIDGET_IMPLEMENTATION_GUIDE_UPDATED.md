# Phoenix LiveView Widget System Implementation Guide (Updated)

This guide provides a step-by-step implementation plan for the Phoenix LiveView Widget System. Follow each phase and section in order, testing thoroughly after each step to ensure system stability.

## Prerequisites & Technology Stack

### Current Versions in Repository
- **Phoenix LiveView**: 1.1.2
- **Ash Framework**: 3.5.33
- **Phoenix**: 1.8.0-rc.4
- **Tailwind CSS**: 0.3.1 (build tool)
- **DaisyUI**: Not installed (needs to be added)

### Required Setup: Installing DaisyUI

**IMPORTANT**: DaisyUI is not currently installed in this project. You must add it before implementing the widget system.

#### Step 1: Install DaisyUI via NPM
```bash
# Navigate to assets directory
cd assets

# Install DaisyUI
npm install -D daisyui@latest

# Or if using Yarn
yarn add -D daisyui@latest
```

#### Step 2: Configure Tailwind CSS
Update `assets/tailwind.config.js`:

```javascript
module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex"
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("daisyui")  // Add this line
  ],
  // DaisyUI config (optional)
  daisyui: {
    themes: ["light", "dark", "cupcake"],
    darkTheme: "dark",
    base: true,
    styled: true,
    utils: true,
    prefix: "",
    logs: true,
    themeRoot: ":root",
  },
}
```

#### Step 3: Verify Installation
```bash
# Rebuild assets
mix assets.build

# Start Phoenix and verify DaisyUI classes work
mix phx.server
```

## Overview

This implementation creates a comprehensive widget system where **everything is a widget**. The system features two modes:
- **Dumb Mode**: Static data for rapid prototyping
- **Connected Mode**: Full Ash framework integration

Key principles:
- Wrap Phoenix LiveView form components for forms
- Use DaisyUI components for UI elements
- Every widget supports grid system and debug mode
- No raw HTML/CSS in LiveViews - only widgets

### Compatibility Notes

1. **Phoenix.HTML.FormField**: This is the correct type for LiveView 1.1.2. The attr definition is correct:
   ```elixir
   attr :field, Phoenix.HTML.FormField, required: true
   ```

2. **to_form/1**: This function exists in Phoenix LiveView 1.1.2 and is part of Phoenix.Component:
   ```elixir
   # This is correct for LiveView 1.1.2
   assign(:form, to_form(changeset))
   ```

3. **AshPhoenix.Form Integration**: For Ash 3.5.33, use AshPhoenix.Form for proper integration:
   ```elixir
   # For Ash forms
   form = AshPhoenix.Form.for_create(Resource, :create)
   assign(:form, AshPhoenix.Form.to_form(form))
   ```

## Phase 1: Foundation & Base Architecture

[Previous Phase 1 content remains the same...]

## Phase 3: Core Display Widgets

### Section 3.3: Form Integration with Ash

When working with Ash resources, the form widgets need special handling to properly integrate with AshPhoenix.Form.

#### Updated Form Widget with Ash Support

Update `lib/forcefoundation_web/widgets/form_widget.ex`:

```elixir
defmodule ForcefoundationWeb.Widgets.FormWidget do
  use ForcefoundationWeb.Widgets.Base
  
  @moduledoc """
  Form container that wraps Phoenix.Component.form.
  Supports both regular changesets and AshPhoenix.Form.
  
  ## Examples
  
      # Regular changeset form
      <.form_widget for={@form} on_submit="save">
        <.input_widget field={@form[:name]} label="Name" />
      </.form_widget>
      
      # Ash resource form
      <.form_widget for={@ash_form} on_submit="create_user">
        <.input_widget field={@ash_form[:email]} label="Email" />
      </.form_widget>
  """
  
  attr :for, :any, required: true,
    doc: "Phoenix form struct or AshPhoenix.Form"
  attr :on_submit, :string, required: true,
    doc: "Event handler for form submission"
  attr :on_change, :string, default: nil,
    doc: "Event handler for form changes"
  attr :method, :atom, default: :post
  attr :multipart, :boolean, default: false
  attr :novalidate, :boolean, default: false
  attr :target, :string, default: nil
  attr :errors, :list, default: []
  attr :variant, :atom, default: :default,
    values: [:default, :inline, :horizontal]
  
  slot :inner_block, required: true
  slot :actions
  
  def render(assigns) do
    # Normalize form data
    assigns = update_in(assigns, [:for], &normalize_form/1)
    
    ~H"""
    <div class={[
      "widget-form",
      form_variant_class(@variant),
      widget_classes(assigns)
    ]}>
      <%= render_debug(assigns) %>
      
      <.form
        for={@for}
        phx-submit={@on_submit}
        phx-change={@on_change}
        method={@method}
        multipart={@multipart}
        novalidate={@novalidate}
        phx-target={@target}
        class="form-control"
      >
        <%= if @errors != [] do %>
          <div class="alert alert-error mb-4">
            <ul class="list-disc list-inside">
              <%= for error <- @errors do %>
                <li><%= error %></li>
              <% end %>
            </ul>
          </div>
        <% end %>
        
        <div class={form_content_class(@variant)}>
          <%= render_slot(@inner_block) %>
        </div>
        
        <%= if @actions do %>
          <div class={form_actions_class(@variant)}>
            <%= render_slot(@actions) %>
          </div>
        <% end %>
      </.form>
    </div>
    """
  end
  
  # Handle both regular forms and AshPhoenix.Form
  defp normalize_form(form) do
    case form do
      %AshPhoenix.Form{} = ash_form ->
        # Convert AshPhoenix.Form to Phoenix.HTML.Form
        AshPhoenix.Form.to_form(ash_form)
      %Phoenix.HTML.Form{} = html_form ->
        html_form
      changeset ->
        # Convert changeset to form
        Phoenix.HTML.FormData.to_form(changeset, [])
    end
  end
  
  defp form_variant_class(:default), do: ""
  defp form_variant_class(:inline), do: "form-inline"
  defp form_variant_class(:horizontal), do: "form-horizontal"
  
  defp form_content_class(:inline), do: "flex gap-2 items-end"
  defp form_content_class(_), do: "space-y-4"
  
  defp form_actions_class(:inline), do: "ml-2"
  defp form_actions_class(_), do: "mt-6 flex gap-2"
end
```

#### Example: Creating Forms with Ash Resources

Create `lib/forcefoundation_web/live/ash_form_example_live.ex`:

```elixir
defmodule ForcefoundationWeb.AshFormExampleLive do
  use ForcefoundationWeb, :live_view
  
  alias MyApp.Accounts
  alias MyApp.Accounts.User
  
  @impl true
  def mount(_params, _session, socket) do
    # Create form for new user
    form = 
      User
      |> AshPhoenix.Form.for_create(:create, 
        domain: Accounts,
        forms: [auto?: true]
      )
    
    {:ok,
     socket
     |> assign(:form, form)
     |> assign(:users, list_users())}
  end
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8">
      <h1 class="text-2xl font-bold mb-6">Ash Form Integration Example</h1>
      
      <!-- Create User Form -->
      <.card_widget title="Create New User" class="mb-8">
        <.form_widget 
          for={@form} 
          on_submit="create_user"
          on_change="validate"
        >
          <.input_widget 
            field={@form[:email]} 
            label="Email"
            type="email"
            required
          />
          
          <.input_widget 
            field={@form[:name]} 
            label="Name"
            required
          />
          
          <.select_widget
            field={@form[:role]}
            label="Role"
            options={[
              {"Admin", "admin"},
              {"User", "user"},
              {"Guest", "guest"}
            ]}
          />
          
          <.checkbox_widget
            field={@form[:active]}
            label="Active"
          />
          
          <:actions>
            <.button_widget 
              type="submit" 
              variant="primary"
              label="Create User"
            />
            <.button_widget 
              type="button" 
              variant="ghost"
              label="Cancel"
              on_click="cancel"
            />
          </:actions>
        </.form_widget>
      </.card_widget>
      
      <!-- Users List -->
      <.card_widget title="Existing Users">
        <.table_widget 
          rows={@users}
          connection={:static}
        >
          <:col :let={user} label="Email">
            <%= user.email %>
          </:col>
          
          <:col :let={user} label="Name">
            <%= user.name %>
          </:col>
          
          <:col :let={user} label="Role">
            <.badge_widget label={user.role} />
          </:col>
          
          <:col :let={user} label="Status">
            <.badge_widget 
              label={if user.active, do: "Active", else: "Inactive"}
              color={if user.active, do: "success", else: "warning"}
            />
          </:col>
          
          <:col :let={user} label="Actions">
            <.button_widget
              size="sm"
              variant="ghost"
              label="Edit"
              on_click={JS.push("edit_user", value: %{id: user.id})}
            />
          </:col>
        </.table_widget>
      </.card_widget>
    </div>
    """
  end
  
  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = 
      socket.assigns.form
      |> AshPhoenix.Form.validate(params)
    
    {:noreply, assign(socket, :form, form)}
  end
  
  @impl true
  def handle_event("create_user", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User created successfully!")
         |> assign(:form, new_user_form())
         |> assign(:users, list_users())}
         
      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
  
  @impl true
  def handle_event("edit_user", %{"id" => id}, socket) do
    user = Ash.get!(User, id, domain: Accounts)
    
    form = 
      user
      |> AshPhoenix.Form.for_update(:update,
        domain: Accounts,
        forms: [auto?: true]
      )
    
    {:noreply, assign(socket, :form, form)}
  end
  
  defp new_user_form do
    User
    |> AshPhoenix.Form.for_create(:create,
      domain: Accounts,
      forms: [auto?: true]
    )
  end
  
  defp list_users do
    User
    |> Ash.read!(domain: Accounts)
  end
end
```

### Connection Resolver Updates for Ash Integration

Update the form resolution in `connection_resolver.ex`:

```elixir
# Form resolution - creates AshPhoenix.Form
defp resolve_form(assigns, socket, {:create, resource, action}) do
  domain = get_domain_from_socket(socket)
  
  form = 
    resource
    |> AshPhoenix.Form.for_create(action,
      domain: domain,
      forms: [auto?: true]
    )
  
  assigns
  |> Map.put(:form, form)
  |> Map.put(:loading, false)
end

defp resolve_form(assigns, socket, {:update, record, action}) do
  domain = get_domain_from_socket(socket)
  
  form = 
    record
    |> AshPhoenix.Form.for_update(action,
      domain: domain,
      forms: [auto?: true]
    )
  
  assigns
  |> Map.put(:form, form)
  |> Map.put(:loading, false)
end

# Add helper for form submissions
def submit_form(form, params, opts \\ []) do
  case AshPhoenix.Form.submit(form, [params: params] ++ opts) do
    {:ok, result} -> 
      {:ok, result}
    {:error, form} -> 
      # Ensure we return a proper form
      {:error, form}
  end
end
```

## Phase 10: Final Integration & Testing

### Section 10.1: Complete Example Page
**Overview:**
This section demonstrates a complete, production-ready dashboard built entirely with our widget system. Every piece of UI is a widget, showcasing the full power of the component system.

[Previous Phase 10 content remains the same, with these compatibility notes:]

### Compatibility Notes for Phase 10

1. **Form Initialization**: The example uses `to_form(%{"query" => ""})` which is correct for LiveView 1.1.2. For Ash forms, use:
   ```elixir
   # For search forms (non-resource based)
   assign(:search_form, to_form(%{"query" => ""}))
   
   # For Ash resource forms
   form = AshPhoenix.Form.for_create(Resource, :action)
   assign(:resource_form, AshPhoenix.Form.to_form(form))
   ```

2. **Stream API**: The stream syntax used is correct for LiveView 1.1.2:
   ```elixir
   |> stream(:activities, load_activities())
   ```

3. **JS Commands**: The JS.push syntax with value parameter works in LiveView 1.1.2:
   ```elixir
   on_click={JS.push("view_user", value: %{id: user.id})}
   ```

4. **Slot Syntax**: The slot syntax with `<:slot_name>` is supported in LiveView 1.1.2.

### Testing Checklist

- [ ] DaisyUI is installed and configured
- [ ] All DaisyUI component classes render correctly
- [ ] Form widgets work with both regular changesets and Ash forms
- [ ] All widgets compile without errors
- [ ] Widget debug mode displays correctly
- [ ] Grid system responsive breakpoints work
- [ ] Ash resource integration works properly

## Troubleshooting Common Issues

### DaisyUI Not Working
If DaisyUI classes aren't applying:
1. Verify installation: `cd assets && npm list daisyui`
2. Check tailwind.config.js includes the plugin
3. Rebuild assets: `mix assets.build`
4. Clear browser cache

### Form Field Errors
If you see "Phoenix.HTML.FormField not found":
- This is the correct module name for LiveView 1.1.2
- Ensure you're using `attr :field, Phoenix.HTML.FormField`
- Do NOT change to Phoenix.HTML.Form.Field

### Ash Form Issues
If Ash forms aren't working:
1. Ensure you have ash_phoenix in your deps
2. Use AshPhoenix.Form.for_create/for_update
3. Convert to HTML form with AshPhoenix.Form.to_form/1
4. Handle submissions with AshPhoenix.Form.submit/2

## Summary

This updated guide addresses:
1. ✅ DaisyUI installation requirements
2. ✅ Proper Ash form integration patterns
3. ✅ Compatibility notes for LiveView 1.1.2
4. ✅ Corrected misconceptions about Phoenix.HTML.FormField and to_form

The widget system implementation is fully compatible with your current technology stack when these guidelines are followed.