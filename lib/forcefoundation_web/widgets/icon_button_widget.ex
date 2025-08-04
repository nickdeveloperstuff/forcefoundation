defmodule ForcefoundationWeb.Widgets.IconButtonWidget do
  @moduledoc """
  Icon-only button widget for compact actions.
  
  Wraps ButtonWidget with specific configurations for icon-only display,
  typically used in toolbars or tight spaces.
  
  ## Attributes
  - `:icon` - Icon name or component (required)
  - `:variant` - Visual style
  - `:size` - Button size
  - `:tooltip` - Tooltip text (recommended for accessibility)
  - All other ButtonWidget attributes
  
  ## Examples
  
      # Edit button
      <.icon_button_widget
        icon="hero-pencil"
        tooltip="Edit"
        on_click="edit"
      />
      
      # Delete with confirmation
      <.icon_button_widget
        icon="hero-trash"
        variant="error"
        tooltip="Delete"
        confirm="Are you sure?"
      />
  """
  use ForcefoundationWeb.Widgets.Base
  import ForcefoundationWeb.Widgets.ButtonWidget
  
  attr :icon, :string, required: true
  attr :variant, :atom, default: :default
  attr :style, :atom, default: :ghost
  attr :size, :atom, default: :md
  attr :type, :string, default: "button"
  attr :disabled, :boolean, default: false
  attr :on_click, :string, default: nil
  attr :phx_disable_with, :string, default: nil
  attr :confirm, :string, default: nil
  attr :tooltip, :string, default: nil
  attr :phx_value_type, :string, default: nil
  
  # Include common widget attributes
  widget_attrs()
  
  # Icon slot
  slot :icon_slot
  
  def icon_button_widget(assigns) do
    # Set shape based on size for consistent icon buttons
    shape = case assigns.size do
      :xs -> :square
      :sm -> :square
      _ -> :circle
    end
    
    assigns = assign(assigns, :shape, shape)
    
    ~H"""
    <.button_widget
      id={@id}
      icon={@icon}
      variant={@variant}
      style={@style}
      size={@size}
      shape={@shape}
      type={@type}
      loading={@loading}
      disabled={@disabled}
      on_click={@on_click}
      phx_disable_with={@phx_disable_with}
      phx_value_type={@phx_value_type}
      confirm={@confirm}
      tooltip={@tooltip}
      class={Enum.join([@class, "!px-0"], " ")}
      data_source={@data_source}
      debug_mode={@debug_mode}
      span={@span}
      padding={@padding}
      margin={@margin}
    >
      <:icon_slot :if={@icon_slot != []}><%= render_slot(@icon_slot) %></:icon_slot>
    </.button_widget>
    """
  end
end