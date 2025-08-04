defmodule ForcefoundationWeb.Widgets.GridWidget do
  use ForcefoundationWeb.Widgets.Base
  
  @moduledoc """
  Responsive grid container using Tailwind's grid system.
  Supports 12-column layout with automatic responsive breakpoints.
  
  ## Examples
  
      <.grid_widget columns={3} gap={4}>
        <div>Item 1</div>
        <div>Item 2</div>
        <div>Item 3</div>
      </.grid_widget>
  """
  
  attr :columns, :any, default: 12,
    doc: "Number of columns. Can be integer or responsive map"
  attr :gap, :integer, default: 4,
    doc: "Gap between items (4px units)"
  attr :gap_x, :integer, default: nil,
    doc: "Horizontal gap override"
  attr :gap_y, :integer, default: nil,
    doc: "Vertical gap override"
  attr :align_items, :atom, default: :stretch,
    values: [:start, :center, :end, :stretch, :baseline],
    doc: "Vertical alignment of items"
  attr :justify_items, :atom, default: :stretch,
    values: [:start, :center, :end, :stretch],
    doc: "Horizontal alignment of items"
    
  slot :inner_block, required: true
  
  # Include common widget attributes
  widget_attrs()
  
  def grid_widget(assigns) do
    # Set gap overrides
    assigns = 
      assigns
      |> assign_new(:gap_x, fn -> assigns.gap end)
      |> assign_new(:gap_y, fn -> assigns.gap end)
    
    ~H"""
    <div class={[
      "grid",
      columns_class(@columns),
      gap_x_class(@gap_x),
      gap_y_class(@gap_y),
      align_items_class(@align_items),
      justify_items_class(@justify_items),
      widget_classes(assigns)
    ]}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
  
  # Handle responsive columns
  # Note: With Tailwind CSS 4, ensure these dynamic classes are included
  # in your CSS build. Consider using a safelist or predefined mapping.
  defp columns_class(columns) when is_integer(columns) do
    "grid-cols-#{columns}"
  end
  
  defp columns_class(%{mobile: m, tablet: t, desktop: d}) do
    [
      "grid-cols-#{m}",
      "md:grid-cols-#{t}",
      "lg:grid-cols-#{d}"
    ]
    |> Enum.join(" ")
  end
  
  # Common responsive patterns
  defp columns_class(:responsive) do
    "grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4"
  end
  
  defp gap_x_class(nil), do: nil
  # Note: For Tailwind CSS 4 compatibility, ensure dynamic gap classes
  # are safelisted or use predefined values
  defp gap_x_class(n), do: "gap-x-#{n}"
  
  defp gap_y_class(nil), do: nil
  defp gap_y_class(n), do: "gap-y-#{n}"
  
  defp align_items_class(:start), do: "items-start"
  defp align_items_class(:center), do: "items-center"
  defp align_items_class(:end), do: "items-end"
  defp align_items_class(:stretch), do: "items-stretch"
  defp align_items_class(:baseline), do: "items-baseline"
  
  defp justify_items_class(:start), do: "justify-items-start"
  defp justify_items_class(:center), do: "justify-items-center"
  defp justify_items_class(:end), do: "justify-items-end"
  defp justify_items_class(:stretch), do: "justify-items-stretch"
end