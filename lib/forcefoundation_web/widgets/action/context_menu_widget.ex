defmodule ForcefoundationWeb.Widgets.Action.ContextMenuWidget do
  @moduledoc """
  Context menu widget that appears on right-click.
  
  Features:
  - Right-click activation
  - Custom positioning
  - Keyboard navigation
  - Item icons and variants
  - Section dividers
  - Nested menus support
  
  ## Examples
  
      <.context_menu_widget target_id="my-content">
        <:item icon="hero-pencil" on_click="edit">Edit</:item>
        <:item icon="hero-document-duplicate" on_click="duplicate">Duplicate</:item>
        <:divider />
        <:item icon="hero-trash" on_click="delete" variant="error">Delete</:item>
      </.context_menu_widget>
      
      <div id="my-content" class="p-4 border rounded">
        Right-click me!
      </div>
  """
  use ForcefoundationWeb.Widgets.Base
  import ForcefoundationWeb.CoreComponents, only: [icon: 1]
  
  attr :target_id, :string, required: true
  attr :position, :atom, default: :cursor,
    values: [:cursor, :center, :top_left, :top_right, :bottom_left, :bottom_right]
  
  # Include common widget attributes
  widget_attrs()
  
  # Slots for menu items
  slot :item do
    attr :icon, :string
    attr :on_click, :string
    attr :variant, :atom
    attr :disabled, :boolean
    attr :href, :string
  end
  
  slot :divider
  
  def context_menu_widget(assigns) do
    menu_id = assigns[:id] || "context-menu-#{System.unique_integer([:positive])}"
    assigns = assign(assigns, :menu_id, menu_id)
    
    ~H"""
    <div 
      id={@menu_id}
      class={[
        widget_classes(assigns),
        "context-menu",
        "hidden",
        "fixed",
        "z-50"
      ]}
      phx-hook="ContextMenu"
      data-target-id={@target_id}
      data-position={@position}
    >
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <ul class={[
        "menu",
        "p-2",
        "shadow-lg",
        "bg-base-100",
        "rounded-box",
        "w-52",
        "border",
        "border-base-300"
      ]}>
        <%= for item <- @item do %>
          <li>
            <%= if item[:href] do %>
              <a 
                href={item[:href]}
                class={[
                  item[:disabled] && "disabled",
                  item_variant_class(item[:variant])
                ]}
              >
                <%= if item[:icon] do %>
                  <.icon name={item[:icon]} class="w-4 h-4" />
                <% end %>
                <%= render_slot(item) %>
              </a>
            <% else %>
              <button
                type="button"
                phx-click={item[:on_click]}
                disabled={item[:disabled]}
                class={[
                  "w-full text-left",
                  item[:disabled] && "disabled",
                  item_variant_class(item[:variant])
                ]}
              >
                <%= if item[:icon] do %>
                  <.icon name={item[:icon]} class="w-4 h-4" />
                <% end %>
                <%= render_slot(item) %>
              </button>
            <% end %>
          </li>
        <% end %>
        
        <%= for _divider <- @divider do %>
          <li class="divider"></li>
        <% end %>
      </ul>
    </div>
    """
  end
  
  defp item_variant_class(nil), do: nil
  defp item_variant_class(:error), do: "text-error hover:bg-error hover:text-error-content"
  defp item_variant_class(:warning), do: "text-warning hover:bg-warning hover:text-warning-content"
  defp item_variant_class(:success), do: "text-success hover:bg-success hover:text-success-content"
  defp item_variant_class(:info), do: "text-info hover:bg-info hover:text-info-content"
end