defmodule ForcefoundationWeb.Widgets.ActionButtonWidget do
  @moduledoc """
  Specialized button for triggering Ash actions with built-in state management.
  
  Automatically handles:
  - Loading states during action execution
  - Error display
  - Success feedback
  - Confirmation dialogs
  - Optimistic UI updates
  
  ## Attributes
  - `:action` - Ash action name (required)
  - `:resource` - Ash resource module (required)
  - `:record` - Record to act on (for update/destroy actions)
  - `:params` - Additional params for the action
  - `:confirm` - Confirmation message
  - `:confirm_title` - Title for confirmation dialog
  - `:success_message` - Flash message on success
  - `:error_message` - Custom error message
  - `:on_success` - Success callback event
  - `:on_error` - Error callback event
  
  ## Examples
  
      # Delete button with confirmation
      <.action_button_widget
        label="Delete"
        variant="error"
        icon="trash"
        action={:destroy}
        resource={Post}
        record={@post}
        confirm="Are you sure you want to delete this post?"
        confirm_title="Delete Post"
        success_message="Post deleted successfully"
      />
      
      # Create button
      <.action_button_widget
        label="Create Post"
        variant="primary"
        action={:create}
        resource={Post}
        params={%{title: "New Post", content: "..."}}
        on_success="navigate_to_post"
      />
  """
  use ForcefoundationWeb.Widgets.Base
  import ForcefoundationWeb.Widgets.ButtonWidget
  
  attr :action, :atom, required: true
  attr :resource, :atom, required: true
  attr :record, :any, default: nil
  attr :params, :map, default: %{}
  attr :confirm, :string, default: nil
  attr :confirm_title, :string, default: "Confirm Action"
  attr :success_message, :string, default: nil
  attr :error_message, :string, default: nil
  attr :on_success, :string, default: nil
  attr :on_error, :string, default: nil
  attr :on_click, :string, default: nil
  
  # Button attributes
  attr :label, :string, default: ""
  attr :variant, :atom, default: :primary
  attr :style, :atom, default: :solid
  attr :size, :atom, default: :md
  attr :icon, :string, default: nil
  attr :icon_position, :atom, default: :left
  attr :disabled, :boolean, default: false
  attr :full_width, :boolean, default: false
  attr :shape, :atom, default: :default
  attr :tooltip, :string, default: nil
  
  # Include common widget attributes
  widget_attrs()
  
  def action_button_widget(assigns) do
    # Generate unique action ID
    action_id = "action-#{assigns.id || System.unique_integer([:positive])}"
    
    # Build the click event based on confirmation
    click_event = cond do
      assigns[:on_click] -> assigns[:on_click]
      assigns[:confirm] -> "confirm_action"
      true -> "execute_action"
    end
    
    assigns = 
      assigns
      |> assign(:action_id, action_id)
      |> assign(:click_event, click_event)
    
    ~H"""
    <div class={widget_classes(assigns)} data-action-id={@action_id}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <.button_widget
        id={@action_id}
        label={@label}
        variant={@variant}
        style={@style}
        size={@size}
        icon={@icon}
        icon_position={@icon_position}
        loading={@loading}
        disabled={@disabled || @loading}
        full_width={@full_width}
        shape={@shape}
        tooltip={@tooltip}
        on_click={@click_event}
        phx-value-action-id={@action_id}
        phx-value-action={@action}
        phx-value-resource={@resource}
        phx-value-record-id={@record && @record.id}
        class={@class}
        span={@span}
        padding={@padding}
        margin={@margin}
      />
      
      <%= if @confirm do %>
        <div
          id={"#{@action_id}-dialog"}
          class="hidden"
          phx-hook="ConfirmDialog"
          data-title={@confirm_title}
          data-message={@confirm}
          data-action-id={@action_id}
          data-confirm-event="execute_action"
        >
        </div>
      <% end %>
    </div>
    """
  end
end