defmodule ForcefoundationWeb.Widgets.ButtonWidget do
  @moduledoc """
  Button widget with DaisyUI styling and action support.
  
  Supports all DaisyUI button variants with icons, loading states,
  and integration with Ash actions.
  
  ## Attributes
  - `:label` - Button text
  - `:variant` - Visual style (primary, secondary, etc.)
  - `:style` - Button style (solid, outline, ghost, link)
  - `:size` - Button size (xs, sm, md, lg)
  - `:type` - HTML button type (button, submit, reset)
  - `:icon` - Icon name or function component
  - `:icon_position` - Icon position (:left, :right)
  - `:loading` - Show loading state
  - `:disabled` - Disable button
  - `:full_width` - Make button full width
  - `:on_click` - Click handler
  
  ## Slots
  - `:default` - Button content (overrides label)
  - `:icon` - Custom icon content
  
  ## Examples
  
      # Basic button
      <.button_widget label="Click me" variant="primary" />
      
      # Button with icon
      <.button_widget 
        label="Save" 
        variant="success"
        icon="check"
        on_click="save"
      />
      
      # Loading state
      <.button_widget
        label="Processing..."
        variant="primary"
        loading
        disabled
      />
  """
  use ForcefoundationWeb.Widgets.Base
  import ForcefoundationWeb.CoreComponents, only: [icon: 1]
  
  attr :label, :string, default: ""
  attr :variant, :atom, default: :default
  attr :style, :atom, default: :solid
  attr :size, :atom, default: :md
  attr :type, :string, default: "button"
  attr :icon, :string, default: nil
  attr :icon_position, :atom, default: :left
  attr :disabled, :boolean, default: false
  attr :full_width, :boolean, default: false
  attr :on_click, :string, default: nil
  attr :phx_disable_with, :string, default: nil
  attr :confirm, :string, default: nil
  attr :shape, :atom, default: :default
  attr :tooltip, :string, default: nil
  attr :phx_value_type, :string, default: nil
  
  # Include common widget attributes (loading already included)
  widget_attrs()
  
  # Slots
  slot :inner_block
  slot :icon_slot
  
  def button_widget(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        widget_classes(assigns),
        "btn",
        button_variant_class(@variant, @style),
        button_size_class(@size),
        button_shape_class(@shape),
        @loading && "loading",
        @full_width && "btn-block"
      ]}
      disabled={@disabled || @loading}
      phx-click={@on_click}
      phx-disable-with={@phx_disable_with}
      phx-value-type={@phx_value_type}
      data-confirm={@confirm}
      title={@tooltip}
    >
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <%= if @loading do %>
        <span class="loading loading-spinner"></span>
      <% end %>
      
      <%= if @icon && @icon_position == :left && !@loading do %>
        <%= render_icon(assigns) %>
      <% end %>
      
      <%= if @inner_block != [] do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        <%= @label %>
      <% end %>
      
      <%= if @icon && @icon_position == :right && !@loading do %>
        <%= render_icon(assigns) %>
      <% end %>
    </button>
    """
  end
  
  defp button_variant_class(variant, style) do
    case {variant, style} do
      {:default, :solid} -> ""
      {:default, :outline} -> "btn-outline"
      {:default, :ghost} -> "btn-ghost"
      {:default, :link} -> "btn-link"
      
      {:primary, :solid} -> "btn-primary"
      {:primary, :outline} -> "btn-outline btn-primary"
      {:primary, :ghost} -> "btn-ghost btn-primary"
      {:primary, :link} -> "btn-link btn-primary"
      
      {:secondary, :solid} -> "btn-secondary"
      {:secondary, :outline} -> "btn-outline btn-secondary"
      {:secondary, :ghost} -> "btn-ghost btn-secondary"
      {:secondary, :link} -> "btn-link btn-secondary"
      
      {:accent, :solid} -> "btn-accent"
      {:accent, :outline} -> "btn-outline btn-accent"
      {:accent, :ghost} -> "btn-ghost btn-accent"
      {:accent, :link} -> "btn-link btn-accent"
      
      {:success, :solid} -> "btn-success"
      {:success, :outline} -> "btn-outline btn-success"
      {:success, :ghost} -> "btn-ghost btn-success"
      {:success, :link} -> "btn-link btn-success"
      
      {:info, :solid} -> "btn-info"
      {:info, :outline} -> "btn-outline btn-info"
      {:info, :ghost} -> "btn-ghost btn-info"
      {:info, :link} -> "btn-link btn-info"
      
      {:warning, :solid} -> "btn-warning"
      {:warning, :outline} -> "btn-outline btn-warning"
      {:warning, :ghost} -> "btn-ghost btn-warning"
      {:warning, :link} -> "btn-link btn-warning"
      
      {:error, :solid} -> "btn-error"
      {:error, :outline} -> "btn-outline btn-error"
      {:error, :ghost} -> "btn-ghost btn-error"
      {:error, :link} -> "btn-link btn-error"
      
      {:neutral, :solid} -> "btn-neutral"
      {:neutral, :outline} -> "btn-outline btn-neutral"
      {:neutral, :ghost} -> "btn-ghost btn-neutral"
      {:neutral, :link} -> "btn-link btn-neutral"
      
      _ -> ""
    end
  end
  
  defp button_size_class(size) do
    case size do
      :xs -> "btn-xs"
      :sm -> "btn-sm"
      :md -> ""
      :lg -> "btn-lg"
      _ -> ""
    end
  end
  
  defp button_shape_class(shape) do
    case shape do
      :default -> ""
      :square -> "btn-square"
      :circle -> "btn-circle"
      :wide -> "btn-wide"
      :block -> "btn-block"
      _ -> ""
    end
  end
  
  defp render_icon(assigns) do
    cond do
      assigns.icon_slot != [] ->
        ~H"""
        <%= render_slot(@icon_slot) %>
        """
        
      is_function(assigns.icon) ->
        assigns.icon.(assigns)
        
      is_binary(assigns.icon) && String.starts_with?(assigns.icon, "hero-") ->
        ~H"""
        <.icon name={@icon} class="w-4 h-4" />
        """
        
      is_binary(assigns.icon) ->
        ~H"""
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <use href={"/images/icons.svg##{@icon}"} />
        </svg>
        """
        
      true ->
        ~H""
    end
  end
end