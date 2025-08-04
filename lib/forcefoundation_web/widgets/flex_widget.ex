defmodule ForcefoundationWeb.Widgets.FlexWidget do
  use ForcefoundationWeb.Widgets.Base
  
  @moduledoc """
  Flexible box container for one-dimensional layouts.
  Perfect for navigation bars, toolbars, and aligned content.
  """
  
  attr :direction, :atom, default: :row,
    values: [:row, :row_reverse, :col, :col_reverse],
    doc: "Flex direction"
  attr :wrap, :atom, default: :nowrap,
    values: [:wrap, :nowrap, :wrap_reverse],
    doc: "Whether items wrap"
  attr :justify, :atom, default: :start,
    values: [:start, :center, :end, :between, :around, :evenly],
    doc: "Justification along main axis"
  attr :align, :atom, default: :stretch,
    values: [:start, :center, :end, :stretch, :baseline],
    doc: "Alignment along cross axis"
  attr :gap, :integer, default: 0,
    doc: "Gap between items (4px units)"
  attr :full_height, :boolean, default: false,
    doc: "Take full height of parent"
    
  slot :inner_block, required: true
  
  # Include common widget attributes
  widget_attrs()
  
  def flex_widget(assigns) do
    ~H"""
    <div class={[
      "flex",
      direction_class(@direction),
      wrap_class(@wrap),
      justify_class(@justify),
      align_class(@align),
      gap_class(@gap),
      @full_height && "h-full",
      widget_classes(assigns)
    ]}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
  
  defp direction_class(:row), do: "flex-row"
  defp direction_class(:row_reverse), do: "flex-row-reverse"
  defp direction_class(:col), do: "flex-col"
  defp direction_class(:col_reverse), do: "flex-col-reverse"
  
  defp wrap_class(:wrap), do: "flex-wrap"
  defp wrap_class(:nowrap), do: "flex-nowrap"
  defp wrap_class(:wrap_reverse), do: "flex-wrap-reverse"
  
  defp justify_class(:start), do: "justify-start"
  defp justify_class(:center), do: "justify-center"
  defp justify_class(:end), do: "justify-end"
  defp justify_class(:between), do: "justify-between"
  defp justify_class(:around), do: "justify-around"
  defp justify_class(:evenly), do: "justify-evenly"
  
  defp align_class(:start), do: "items-start"
  defp align_class(:center), do: "items-center"
  defp align_class(:end), do: "items-end"
  defp align_class(:stretch), do: "items-stretch"
  defp align_class(:baseline), do: "items-baseline"
end