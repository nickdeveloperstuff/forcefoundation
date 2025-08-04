defmodule ForcefoundationWeb.Widgets.ButtonGroupWidget do
  @moduledoc """
  Groups multiple buttons together with DaisyUI styling.
  
  Provides visual grouping of related buttons with proper borders
  and spacing. Supports both horizontal and vertical layouts.
  
  ## Attributes
  - `:layout` - Layout direction (:horizontal, :vertical)
  - `:size` - Size for all buttons in group
  - `:variant` - Default variant for buttons
  
  ## Slots
  - `:button` - Individual button definitions
  
  ## Examples
  
      # Basic button group
      <.button_group_widget>
        <:button label="Left" on_click="left" />
        <:button label="Center" on_click="center" />
        <:button label="Right" on_click="right" />
      </.button_group_widget>
      
      # Vertical layout
      <.button_group_widget layout="vertical" size="sm">
        <:button icon="hero-arrow-up" tooltip="Up" />
        <:button icon="hero-arrow-down" tooltip="Down" />
      </.button_group_widget>
  """
  use ForcefoundationWeb.Widgets.Base
  import ForcefoundationWeb.CoreComponents, only: [icon: 1]
  
  attr :layout, :atom, default: :horizontal
  attr :size, :atom, default: :md
  attr :variant, :atom, default: :default
  
  # Include common widget attributes
  widget_attrs()
  
  # Button slots
  slot :button do
    attr :label, :string
    attr :icon, :string
    attr :variant, :atom
    attr :style, :atom
    attr :on_click, :string
    attr :disabled, :boolean
    attr :loading, :boolean
    attr :active, :boolean
    attr :tooltip, :string
    attr :type, :string
  end
  
  def button_group_widget(assigns) do
    ~H"""
    <div class={[
      widget_classes(assigns),
      "btn-group",
      @layout == :vertical && "btn-group-vertical"
    ]}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <%= for {button, _index} <- Enum.with_index(@button) do %>
        <.button
          label={Map.get(button, :label, "")}
          icon={Map.get(button, :icon)}
          variant={Map.get(button, :variant, @variant)}
          style={Map.get(button, :style, :solid)}
          size={@size}
          on_click={Map.get(button, :on_click)}
          disabled={Map.get(button, :disabled, false)}
          loading={Map.get(button, :loading, false)}
          active={Map.get(button, :active, false)}
          tooltip={Map.get(button, :tooltip)}
          type={Map.get(button, :type, "button")}
        />
      <% end %>
    </div>
    """
  end
  
  # Internal button component for group
  defp button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "btn",
        button_variant_class(@variant, @style),
        button_size_class(@size),
        @active && "btn-active",
        @loading && "loading"
      ]}
      disabled={@disabled || @loading}
      phx-click={@on_click}
      title={@tooltip}
    >
      <%= if @loading do %>
        <span class="loading loading-spinner"></span>
      <% end %>
      
      <%= if @icon && !@loading do %>
        <%= render_button_icon(assigns) %>
      <% end %>
      
      <%= @label %>
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
      
      {:secondary, :solid} -> "btn-secondary"
      {:secondary, :outline} -> "btn-outline btn-secondary"
      {:secondary, :ghost} -> "btn-ghost btn-secondary"
      
      {:accent, :solid} -> "btn-accent"
      {:accent, :outline} -> "btn-outline btn-accent"
      {:accent, :ghost} -> "btn-ghost btn-accent"
      
      {:success, :solid} -> "btn-success"
      {:success, :outline} -> "btn-outline btn-success"
      {:success, :ghost} -> "btn-ghost btn-success"
      
      {:error, :solid} -> "btn-error"
      {:error, :outline} -> "btn-outline btn-error"
      {:error, :ghost} -> "btn-ghost btn-error"
      
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
  
  defp render_button_icon(assigns) do
    cond do
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