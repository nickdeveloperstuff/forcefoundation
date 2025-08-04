defmodule ForcefoundationWeb.Widgets.DropdownButtonWidget do
  @moduledoc """
  Button with dropdown menu using DaisyUI dropdown component.
  
  Provides a button that reveals a dropdown menu with multiple actions.
  Supports dividers, icons, and disabled items.
  
  ## Attributes
  - `:label` - Button label
  - `:variant` - Button variant
  - `:size` - Button size
  - `:align` - Dropdown alignment (:start, :end)
  - `:open` - Control dropdown state
  
  ## Slots
  - `:item` - Menu items with action handlers
  
  ## Examples
  
      # Basic dropdown
      <.dropdown_button_widget label="Options">
        <:item label="Edit" on_click="edit" icon="hero-pencil" />
        <:item label="Delete" on_click="delete" icon="hero-trash" />
      </.dropdown_button_widget>
      
      # With divider
      <.dropdown_button_widget label="Actions" variant="primary">
        <:item label="Save" on_click="save" />
        <:item divider />
        <:item label="Export" on_click="export" />
      </.dropdown_button_widget>
  """
  use ForcefoundationWeb.Widgets.Base
  import ForcefoundationWeb.CoreComponents, only: [icon: 1]
  
  attr :label, :string, default: "Actions"
  attr :variant, :atom, default: :default
  attr :style, :atom, default: :solid
  attr :size, :atom, default: :md
  attr :align, :atom, default: :end
  attr :open, :boolean, default: false
  attr :icon, :string, default: nil
  attr :disabled, :boolean, default: false
  
  # Include common widget attributes
  widget_attrs()
  
  # Menu item slots
  slot :item do
    attr :label, :string
    attr :icon, :string
    attr :on_click, :string
    attr :disabled, :boolean
    attr :divider, :boolean
    attr :href, :string
  end
  
  def dropdown_button_widget(assigns) do
    assigns = assign_new(assigns, :dropdown_id, fn -> 
      "dropdown-#{System.unique_integer([:positive])}"
    end)
    
    ~H"""
    <div class={[
      widget_classes(assigns),
      "dropdown",
      dropdown_align_class(@align),
      @open && "dropdown-open"
    ]} id={@dropdown_id}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <label tabindex="0" class={[
        "btn",
        button_variant_class(@variant, @style),
        button_size_class(@size),
        @loading && "loading"
      ]} disabled={@disabled}>
        <%= if @loading do %>
          <span class="loading loading-spinner"></span>
        <% end %>
        
        <%= if @icon && !@loading do %>
          <%= render_dropdown_icon(assigns) %>
        <% end %>
        
        <%= @label %>
        
        <svg class="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
        </svg>
      </label>
      
      <ul tabindex="0" class="dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52">
        <%= for item <- @item do %>
          <%= if Map.get(item, :divider, false) do %>
            <li class="divider"></li>
          <% else %>
            <li>
              <%= if Map.get(item, :href) do %>
                <a 
                  href={Map.get(item, :href)}
                  class={[Map.get(item, :disabled, false) && "disabled"]}
                >
                  <%= render_item_content(item) %>
                </a>
              <% else %>
                <button
                  phx-click={Map.get(item, :on_click)}
                  disabled={Map.get(item, :disabled, false)}
                  class="w-full text-left"
                >
                  <%= render_item_content(item) %>
                </button>
              <% end %>
            </li>
          <% end %>
        <% end %>
      </ul>
    </div>
    """
  end
  
  defp dropdown_align_class(align) do
    case align do
      :start -> "dropdown-start"
      :end -> "dropdown-end"
      :left -> "dropdown-left"
      :right -> "dropdown-right"
      :top -> "dropdown-top"
      :bottom -> "dropdown-bottom"
      _ -> "dropdown-end"
    end
  end
  
  defp button_variant_class(variant, style) do
    case {variant, style} do
      {:default, :solid} -> ""
      {:default, :outline} -> "btn-outline"
      {:default, :ghost} -> "btn-ghost"
      
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
      {:error, :solid} -> "btn-error"
      {:warning, :solid} -> "btn-warning"
      {:info, :solid} -> "btn-info"
      
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
  
  defp render_dropdown_icon(assigns) do
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
  
  defp render_item_content(item) do
    assigns = %{item: item}
    
    ~H"""
    <%= if Map.get(@item, :icon) do %>
      <%= render_item_icon(@item) %>
    <% end %>
    <%= Map.get(@item, :label, "") %>
    """
  end
  
  defp render_item_icon(item) do
    assigns = %{icon: Map.get(item, :icon)}
    
    cond do
      is_binary(assigns.icon) && String.starts_with?(assigns.icon, "hero-") ->
        ~H"""
        <.icon name={@icon} class="w-4 h-4 mr-2" />
        """
        
      is_binary(assigns.icon) ->
        ~H"""
        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <use href={"/images/icons.svg##{@icon}"} />
        </svg>
        """
        
      true ->
        ~H""
    end
  end
end