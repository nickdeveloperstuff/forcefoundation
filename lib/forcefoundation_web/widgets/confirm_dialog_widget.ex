defmodule ForcefoundationWeb.Widgets.ConfirmDialogWidget do
  @moduledoc """
  Modal confirmation dialog widget using DaisyUI modal component.
  
  Features:
  - Title and message display
  - Confirm/Cancel actions
  - Customizable button labels and variants
  - Keyboard support (ESC to cancel)
  - Focus management
  
  ## Attributes
  - `:id` - Unique dialog ID (required)
  - `:title` - Dialog title
  - `:message` - Confirmation message
  - `:confirm_label` - Confirm button label
  - `:cancel_label` - Cancel button label
  - `:confirm_variant` - Confirm button variant
  - `:cancel_variant` - Cancel button variant
  - `:on_confirm` - Event to trigger on confirmation
  - `:on_cancel` - Event to trigger on cancellation
  - `:open` - Whether dialog is open
  
  ## Examples
  
      <.confirm_dialog_widget
        id="delete-confirm"
        title="Delete Post"
        message="Are you sure you want to delete this post? This action cannot be undone."
        confirm_label="Delete"
        confirm_variant="error"
        on_confirm="delete_post"
        open={@show_delete_confirm}
      />
  """
  use ForcefoundationWeb.Widgets.Base
  import ForcefoundationWeb.Widgets.ButtonWidget
  
  attr :title, :string, default: "Confirm Action"
  attr :message, :string, default: "Are you sure you want to proceed?"
  attr :confirm_label, :string, default: "Confirm"
  attr :cancel_label, :string, default: "Cancel"
  attr :confirm_variant, :atom, default: :primary
  attr :cancel_variant, :atom, default: :ghost
  attr :on_confirm, :string, default: nil
  attr :on_cancel, :string, default: nil
  attr :open, :boolean, default: false
  
  # Include common widget attributes
  widget_attrs()
  
  def confirm_dialog_widget(assigns) do
    # Ensure ID is provided
    unless assigns[:id] do
      raise ArgumentError, "confirm_dialog_widget requires an :id attribute"
    end
    modal_id = "#{assigns.id}-modal"
    
    assigns = assign(assigns, :modal_id, modal_id)
    
    ~H"""
    <div class={widget_classes(assigns)} id={@id}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <!-- Hidden checkbox for modal state -->
      <input type="checkbox" id={@modal_id} class="modal-toggle" checked={@open} />
      
      <!-- Modal -->
      <div class="modal" id={"#{@id}-hook"} phx-hook="ConfirmDialogModal" data-dialog-id={@id}>
        <div class="modal-box">
          <h3 class="font-bold text-lg"><%= @title %></h3>
          <p class="py-4"><%= @message %></p>
          
          <div class="modal-action">
            <%= if @on_cancel do %>
              <.button_widget
                label={@cancel_label}
                variant={@cancel_variant}
                on_click={@on_cancel}
                phx-value-dialog-id={@id}
              />
            <% else %>
              <label for={@modal_id} class="btn btn-ghost">
                <%= @cancel_label %>
              </label>
            <% end %>
            
            <.button_widget
              label={@confirm_label}
              variant={@confirm_variant}
              on_click={@on_confirm}
              phx-value-dialog-id={@id}
            />
          </div>
        </div>
        
        <!-- Modal backdrop -->
        <label class="modal-backdrop" for={@modal_id}>Close</label>
      </div>
    </div>
    """
  end
  
  @doc """
  Opens a confirmation dialog by ID.
  """
  def open(socket, dialog_id) do
    Phoenix.LiveView.push_event(socket, "open_confirm_dialog", %{id: dialog_id})
  end
  
  @doc """
  Closes a confirmation dialog by ID.
  """
  def close(socket, dialog_id) do
    Phoenix.LiveView.push_event(socket, "close_confirm_dialog", %{id: dialog_id})
  end
end