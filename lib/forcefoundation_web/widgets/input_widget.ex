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
  
  # Include common widget attributes
  widget_attrs()
  
  # Slots for input addons
  slot :start_addon, doc: "Content to show before the input"
  slot :end_addon, doc: "Content to show after the input"
  
  def input_widget(assigns) do
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
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <%= if @label && !@floating_label do %>
        <label for={@input_id} class="label">
          <span class={["label-text", @required && "after:content-['*'] after:ml-0.5 after:text-error"]}>
            <%= @label %>
          </span>
        </label>
      <% end %>
      
      <div class={[
        (@prefix || @suffix || @start_addon != [] || @end_addon != []) && "input-group",
        @has_error && "input-error-wrapper"
      ]}>
        <%= if @start_addon != [] do %>
          <span class="input-addon input-addon-start">
            <%= render_slot(@start_addon) %>
          </span>
        <% else %>
          <%= if @prefix do %>
            <span class="input-prefix"><%= @prefix %></span>
          <% end %>
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
          aria-invalid={@has_error && "true"}
          aria-describedby={@has_error && "#{@input_id}-error"}
        />
        
        <%= if @floating_label && @label do %>
          <label for={@input_id} class="label label-floating">
            <%= @label %>
            <%= if @required do %>
              <span class="text-error ml-0.5">*</span>
            <% end %>
          </label>
        <% end %>
        
        <%= if @end_addon != [] do %>
          <span class="input-addon input-addon-end">
            <%= render_slot(@end_addon) %>
          </span>
        <% else %>
          <%= if @suffix do %>
            <span class="input-suffix"><%= @suffix %></span>
          <% end %>
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