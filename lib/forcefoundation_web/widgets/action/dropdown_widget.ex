defmodule ForcefoundationWeb.Widgets.Action.DropdownWidget do
  @moduledoc """
  Dropdown menu widget for action items.
  
  Features:
  - Multiple action items
  - Section dividers
  - Icon support
  - Disabled state per item
  - Custom positioning
  - Keyboard navigation support
  
  ## Examples
  
      <.dropdown_widget label="Actions" variant="primary">
        <:item icon="hero-pencil" on_click="edit">Edit</:item>
        <:item icon="hero-document-duplicate" on_click="duplicate">Duplicate</:item>
        <:divider />
        <:item icon="hero-trash" on_click="delete" variant="error">Delete</:item>
      </.dropdown_widget>
  """
  use ForcefoundationWeb.Widgets.Base
  import ForcefoundationWeb.Widgets.ButtonWidget
  import ForcefoundationWeb.CoreComponents, only: [icon: 1]
  
  attr :label, :string, default: "Actions"
  attr :variant, :atom, default: :default
  attr :size, :atom, default: :md
  attr :position, :atom, default: :bottom_end,
    values: [:bottom_start, :bottom_end, :top_start, :top_end, :left, :right]
  attr :icon, :string, default: "hero-chevron-down"
  attr :full_width, :boolean, default: false
  
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
  
  def dropdown_widget(assigns) do
    dropdown_id = assigns[:id] || "dropdown-#{System.unique_integer([:positive])}"
    assigns = assign(assigns, :dropdown_id, dropdown_id)
    
    ~H"""
    <div class={[
      widget_classes(assigns),
      "dropdown",
      dropdown_position_class(@position),
      @full_width && "w-full"
    ]}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <label tabindex="0" class={[@full_width && "w-full"]}>
        <.button_widget
          label={@label}
          variant={@variant}
          size={@size}
          icon={@icon}
          icon_position={:right}
          full_width={@full_width}
          type="button"
          role="button"
          aria-haspopup="true"
          aria-expanded="false"
        />
      </label>
      
      <ul 
        tabindex="0" 
        class={[
          "dropdown-content",
          "menu",
          "p-2",
          "shadow",
          "bg-base-100",
          "rounded-box",
          "w-52",
          "z-[1]"
        ]}
      >
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
  
  defp dropdown_position_class(:bottom_start), do: "dropdown-bottom dropdown-start"
  defp dropdown_position_class(:bottom_end), do: "dropdown-bottom dropdown-end"
  defp dropdown_position_class(:top_start), do: "dropdown-top dropdown-start"
  defp dropdown_position_class(:top_end), do: "dropdown-top dropdown-end"
  defp dropdown_position_class(:left), do: "dropdown-left"
  defp dropdown_position_class(:right), do: "dropdown-right"
  
  defp item_variant_class(nil), do: nil
  defp item_variant_class(:error), do: "text-error hover:bg-error hover:text-error-content"
  defp item_variant_class(:warning), do: "text-warning hover:bg-warning hover:text-warning-content"
  defp item_variant_class(:success), do: "text-success hover:bg-success hover:text-success-content"
  defp item_variant_class(:info), do: "text-info hover:bg-info hover:text-info-content"
end