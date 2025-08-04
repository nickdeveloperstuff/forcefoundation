defmodule ForcefoundationWeb.Widgets.NestedFormWidget do
  @moduledoc """
  Nested form widget for handling has_many associations with Phoenix LiveView.
  
  Supports dynamic addition/removal of nested forms with proper changeset handling.
  
  ## Attributes
  - `:form` - Parent form struct
  - `:field` - Field name for the association
  - `:builder` - Function that builds the nested form fields
  - `:add_label` - Label for add button
  - `:remove_label` - Label for remove button
  - `:sortable` - Enable drag-and-drop sorting
  
  ## Examples
  
      # Order with line items
      <.nested_form_widget
        form={@form}
        field={:line_items}
        add_label="Add Line Item"
      >
        <:builder :let={f}>
          <.input_widget field={f[:product_id]} label="Product" />
          <.input_widget field={f[:quantity]} type="number" label="Quantity" />
          <.input_widget field={f[:price]} type="number" label="Price" step="0.01" />
        </:builder>
      </.nested_form_widget>
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :form, Phoenix.HTML.Form, required: true
  attr :field, :atom, required: true
  attr :add_label, :string, default: "Add Item"
  attr :remove_label, :string, default: "Remove"
  attr :min_items, :integer, default: 0
  attr :max_items, :integer, default: nil
  attr :sortable, :boolean, default: false
  attr :item_wrapper_class, :string, default: ""
  
  # Include common widget attributes
  widget_attrs()
  
  # Slot for building nested form fields
  slot :builder, required: true do
    attr :form, Phoenix.HTML.Form
    attr :index, :integer
  end
  
  # Slot for empty state
  slot :empty do
    attr :add_action, :string
  end
  
  def nested_form_widget(assigns) do
    # Count nested forms first
    field = assigns.field
    items_count = 
      case assigns.form.data do
        %{^field => items} when is_list(items) -> length(items)
        _ -> 0
      end
    can_add = assigns.max_items == nil || items_count < assigns.max_items
    can_remove = items_count > assigns.min_items
    
    assigns = 
      assigns
      |> assign(:items_count, items_count)
      |> assign(:can_add, can_add)
      |> assign(:can_remove, can_remove)
      |> assign(:container_id, "nested-form-#{assigns.field}-#{System.unique_integer()}")
    
    ~H"""
    <div class={[
      widget_classes(assigns),
      "widget-nested-form"
    ]} id={@container_id}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <div 
        id={"#{@container_id}-items"}
        class={[
          "nested-form-items",
          @sortable && "sortable-container"
        ]} 
        phx-hook={@sortable && "Sortable"} 
        data-group={@field}>
        <%= if @items_count == 0 && @empty != [] do %>
          <div class="nested-form-empty">
            <%= render_slot(@empty, %{add_action: "add_#{@field}"}) %>
          </div>
        <% else %>
          <.inputs_for :let={nested_form} field={@form[@field]}>
            <div class={[
              "nested-form-item",
              @item_wrapper_class,
              @sortable && "sortable-item"
            ]} data-id={nested_form.index}>
              <%= if @sortable do %>
                <div class="sortable-handle">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                  </svg>
                </div>
              <% end %>
              
              <div class="nested-form-content">
                <%= render_slot(@builder, %{form: nested_form, index: nested_form.index}) %>
              </div>
              
              <%= if @can_remove do %>
                <button
                  type="button"
                  class="btn btn-sm btn-ghost btn-circle text-error"
                  phx-click={"remove_#{@field}"}
                  phx-value-index={nested_form.index}
                  title={@remove_label}
                >
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              <% end %>
            </div>
          </.inputs_for>
        <% end %>
      </div>
      
      <%= if @can_add do %>
        <div class="nested-form-actions">
          <button
            type="button"
            class="btn btn-sm btn-primary"
            phx-click={"add_#{@field}"}
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            <%= @add_label %>
          </button>
        </div>
      <% end %>
    </div>
    """
  end
end