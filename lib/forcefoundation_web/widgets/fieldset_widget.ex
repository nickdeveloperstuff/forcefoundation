defmodule ForcefoundationWeb.Widgets.FieldsetWidget do
  @moduledoc """
  Fieldset widget for grouping related form fields with optional legend and styling.
  
  ## Attributes
  - `:legend` - Fieldset legend/title
  - `:description` - Optional description text
  - `:variant` - Visual variant (:default, :bordered, :separated)
  - `:collapsible` - Whether fieldset can be collapsed
  - `:collapsed` - Initial collapsed state
  
  ## Examples
  
      <.fieldset_widget legend="Personal Information" description="Please provide your details">
        <.input_widget field={@form[:first_name]} label="First Name" />
        <.input_widget field={@form[:last_name]} label="Last Name" />
        <.input_widget field={@form[:email]} label="Email" type="email" />
      </.fieldset_widget>
      
      <.fieldset_widget legend="Address" variant={:bordered} collapsible>
        <.input_widget field={@form[:street]} label="Street Address" />
        <.input_widget field={@form[:city]} label="City" />
        <.select_widget field={@form[:state]} label="State" options={@states} />
        <.input_widget field={@form[:zip]} label="ZIP Code" />
      </.fieldset_widget>
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :legend, :string, default: nil
  attr :description, :string, default: nil
  attr :variant, :atom, default: :default, values: [:default, :bordered, :separated]
  attr :collapsible, :boolean, default: false
  attr :collapsed, :boolean, default: false
  attr :required, :boolean, default: false
  
  # Include common widget attributes
  widget_attrs()
  
  # Slot for fieldset content
  slot :inner_block, required: true
  
  # Slot for fieldset actions (e.g., buttons at the bottom)
  slot :actions
  
  def fieldset_widget(assigns) do
    fieldset_id = "fieldset-#{System.unique_integer()}"
    
    assigns = 
      assigns
      |> assign(:fieldset_id, fieldset_id)
      |> assign(:is_collapsed, assigns.collapsed && assigns.collapsible)
    
    ~H"""
    <fieldset class={[
      widget_classes(assigns),
      "widget-fieldset",
      fieldset_variant_class(@variant)
    ]} id={@fieldset_id}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <%= if @legend do %>
        <legend class={[
          "fieldset-legend",
          @collapsible && "fieldset-legend-collapsible"
        ]}>
          <%= if @collapsible do %>
            <button
              type="button"
              class="fieldset-toggle"
              phx-click={Phoenix.LiveView.JS.toggle(to: "##{@fieldset_id}-content")
                |> Phoenix.LiveView.JS.toggle_class("collapsed", to: "##{@fieldset_id}")}
              aria-expanded={!@is_collapsed}
              aria-controls={"#{@fieldset_id}-content"}
            >
              <span class="fieldset-legend-text">
                <%= @legend %>
                <%= if @required do %>
                  <span class="text-error ml-1">*</span>
                <% end %>
              </span>
              <svg xmlns="http://www.w3.org/2000/svg" 
                class="h-5 w-5 fieldset-toggle-icon transition-transform" 
                fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>
          <% else %>
            <span class="fieldset-legend-text">
              <%= @legend %>
              <%= if @required do %>
                <span class="text-error ml-1">*</span>
              <% end %>
            </span>
          <% end %>
        </legend>
      <% end %>
      
      <div 
        class={["fieldset-content", @is_collapsed && "hidden"]}
        id={"#{@fieldset_id}-content"}
      >
        <%= if @description do %>
          <p class="fieldset-description"><%= @description %></p>
        <% end %>
        
        <div class="fieldset-fields">
          <%= render_slot(@inner_block) %>
        </div>
        
        <%= if @actions != [] do %>
          <div class="fieldset-actions">
            <%= render_slot(@actions) %>
          </div>
        <% end %>
      </div>
    </fieldset>
    """
  end
  
  defp fieldset_variant_class(:default), do: ""
  defp fieldset_variant_class(:bordered), do: "fieldset-bordered"
  defp fieldset_variant_class(:separated), do: "fieldset-separated"
end