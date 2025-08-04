defmodule ForcefoundationWeb.Widgets.Action.ToolbarWidget do
  @moduledoc """
  Toolbar widget for grouping action buttons and controls.
  
  Features:
  - Flexible layout with start/center/end sections
  - Button groups support
  - Separator support
  - Responsive design
  - Custom spacing options
  
  ## Examples
  
      <.toolbar_widget>
        <:start>
          <.button_widget label="Save" variant="primary" icon="hero-check" />
          <.button_widget label="Cancel" variant="ghost" />
        </:start>
        
        <:center>
          <.button_group_widget>
            <.button_widget label="Bold" icon="hero-bold" />
            <.button_widget label="Italic" icon="hero-italic" />
            <.button_widget label="Underline" icon="hero-underline" />
          </.button_group_widget>
        </:center>
        
        <:end_section>
          <.dropdown_widget label="More" icon="hero-ellipsis-horizontal" />
        </:end_section>
      </.toolbar_widget>
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :variant, :atom, default: :default,
    values: [:default, :bordered, :elevated]
  attr :size, :atom, default: :md,
    values: [:sm, :md, :lg]
  attr :spacing, :atom, default: :normal,
    values: [:compact, :normal, :relaxed]
  attr :full_width, :boolean, default: true
  attr :sticky, :boolean, default: false
  
  # Include common widget attributes
  widget_attrs()
  
  # Slots for toolbar sections
  slot :start
  slot :center
  slot :end_section
  slot :separator
  
  def toolbar_widget(assigns) do
    ~H"""
    <div class={[
      widget_classes(assigns),
      "toolbar",
      "flex items-center",
      toolbar_variant_class(@variant),
      toolbar_size_class(@size),
      toolbar_spacing_class(@spacing),
      @full_width && "w-full",
      @sticky && "sticky top-0 z-10"
    ]}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <!-- Start section -->
      <%= if @start != [] do %>
        <div class="toolbar-start flex items-center gap-2">
          <%= for item <- @start do %>
            <%= render_slot(item) %>
          <% end %>
        </div>
      <% end %>
      
      <!-- Center section -->
      <%= if @center != [] do %>
        <div class="toolbar-center flex-1 flex items-center justify-center gap-2">
          <%= for item <- @center do %>
            <%= render_slot(item) %>
          <% end %>
        </div>
      <% else %>
        <div class="flex-1"></div>
      <% end %>
      
      <!-- End section -->
      <%= if @end_section != [] do %>
        <div class="toolbar-end flex items-center gap-2">
          <%= for item <- @end_section do %>
            <%= render_slot(item) %>
          <% end %>
        </div>
      <% end %>
      
      <!-- Separators (rendered inline where placed) -->
      <%= for _sep <- @separator do %>
        <div class="divider divider-horizontal mx-2"></div>
      <% end %>
    </div>
    """
  end
  
  defp toolbar_variant_class(:default), do: "bg-base-100"
  defp toolbar_variant_class(:bordered), do: "bg-base-100 border border-base-300 rounded-lg"
  defp toolbar_variant_class(:elevated), do: "bg-base-100 shadow-md rounded-lg"
  
  defp toolbar_size_class(:sm), do: "p-2 min-h-[2.5rem]"
  defp toolbar_size_class(:md), do: "p-3 min-h-[3rem]"
  defp toolbar_size_class(:lg), do: "p-4 min-h-[3.5rem]"
  
  defp toolbar_spacing_class(:compact), do: "gap-1"
  defp toolbar_spacing_class(:normal), do: "gap-2"
  defp toolbar_spacing_class(:relaxed), do: "gap-4"
end