defmodule ForcefoundationWeb.Widgets.RepeaterWidget do
  @moduledoc """
  Repeater widget for managing dynamic lists of form inputs.
  
  Unlike nested_form_widget which handles associations, repeater_widget is for
  simple repeated fields like tags, phone numbers, or email addresses.
  
  ## Attributes
  - `:field` - Base field name
  - `:values` - List of current values
  - `:template` - Function to render each item
  - `:min_items` - Minimum number of items
  - `:max_items` - Maximum number of items
  - `:add_label` - Label for add button
  - `:placeholder` - Placeholder for new items
  
  ## Examples
  
      # Tags repeater
      <.repeater_widget
        field={:tags}
        values={@tags}
        add_label="Add Tag"
        placeholder="Enter tag..."
      />
      
      # Phone numbers with custom template
      <.repeater_widget
        field={:phones}
        values={@phones}
        add_label="Add Phone"
      >
        <:template :let={%{value: value, index: idx}}>
          <.input_widget 
            field={%Phoenix.HTML.FormField{
              id: "phone_\#{idx}",
              name: "phones[]",
              value: value
            }}
            type="tel"
            placeholder="(555) 123-4567"
          />
        </:template>
      </.repeater_widget>
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :field, :atom, required: true
  attr :values, :list, default: []
  attr :min_items, :integer, default: 0
  attr :max_items, :integer, default: nil
  attr :add_label, :string, default: "Add Item"
  attr :remove_label, :string, default: "Remove"
  attr :placeholder, :string, default: ""
  attr :input_type, :string, default: "text"
  attr :sortable, :boolean, default: false
  
  # Include common widget attributes
  widget_attrs()
  
  # Custom template slot
  slot :template do
    attr :value, :any
    attr :index, :integer
    attr :field_name, :string
  end
  
  def repeater_widget(assigns) do
    items_count = length(assigns.values)
    can_add = assigns.max_items == nil || items_count < assigns.max_items
    can_remove = items_count > assigns.min_items
    
    assigns = 
      assigns
      |> assign(:items_count, items_count)
      |> assign(:can_add, can_add)
      |> assign(:can_remove, can_remove)
      |> assign(:container_id, "repeater-#{assigns.field}-#{System.unique_integer()}")
    
    ~H"""
    <div class={[
      widget_classes(assigns),
      "widget-repeater"
    ]} id={@container_id}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <div 
        id={"#{@container_id}-items"}
        class={[
          "repeater-items",
          @sortable && "sortable-container"
        ]} 
        phx-hook={@sortable && "Sortable"} 
        data-field={@field}>
        <%= for {value, index} <- Enum.with_index(@values) do %>
          <div class={[
            "repeater-item",
            @sortable && "sortable-item"
          ]} data-index={index}>
            <%= if @sortable do %>
              <div class="sortable-handle">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                </svg>
              </div>
            <% end %>
            
            <div class="repeater-item-content">
              <%= if @template != [] do %>
                <%= render_slot(@template, %{
                  value: value,
                  index: index,
                  field_name: "#{@field}[]"
                }) %>
              <% else %>
                <input
                  type={@input_type}
                  name={"#{@field}[]"}
                  value={value}
                  placeholder={@placeholder}
                  class="input input-bordered w-full"
                  phx-blur={"update_repeater_#{@field}"}
                  phx-value-index={index}
                />
              <% end %>
            </div>
            
            <%= if @can_remove do %>
              <button
                type="button"
                class="btn btn-sm btn-ghost btn-circle text-error"
                phx-click={"remove_repeater_#{@field}"}
                phx-value-index={index}
                title={@remove_label}
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            <% end %>
          </div>
        <% end %>
        
        <%= if @items_count == 0 do %>
          <div class="repeater-empty">
            <p class="text-gray-500 text-sm">No items added yet.</p>
          </div>
        <% end %>
      </div>
      
      <%= if @can_add do %>
        <div class="repeater-actions">
          <div class="join">
            <input
              type={@input_type}
              placeholder={@placeholder}
              class="input input-bordered join-item"
              phx-keyup={"add_repeater_#{@field}"}
              phx-key="Enter"
              id={"#{@container_id}-new-input"}
            />
            <button
              type="button"
              class="btn btn-primary join-item"
              phx-click={"add_repeater_#{@field}"}
            >
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
              </svg>
              <%= @add_label %>
            </button>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end