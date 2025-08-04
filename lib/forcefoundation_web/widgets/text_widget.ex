defmodule ForcefoundationWeb.Widgets.TextWidget do
  use ForcefoundationWeb.Widgets.Base
  
  @moduledoc """
  Flexible text widget with size, color, and weight options.
  Provides semantic text display with Tailwind typography classes.
  """
  
  attr :text, :string, required: true
  attr :size, :atom, default: :base,
    values: [:xs, :sm, :base, :lg, :xl, :xxl, :xxxl],
    doc: "Text size"
  attr :color, :atom, default: :default,
    values: [:default, :primary, :secondary, :accent, :info, :success, :warning, :error, :muted],
    doc: "Text color"
  attr :weight, :atom, default: :normal,
    values: [:thin, :light, :normal, :medium, :semibold, :bold, :extrabold, :black],
    doc: "Font weight"
  attr :align, :atom, default: :left,
    values: [:left, :center, :right, :justify],
    doc: "Text alignment"
  attr :italic, :boolean, default: false,
    doc: "Use italic style"
  attr :underline, :boolean, default: false,
    doc: "Add underline decoration"
  attr :truncate, :boolean, default: false,
    doc: "Truncate text with ellipsis"
  attr :wrap, :atom, default: :normal,
    values: [:normal, :nowrap, :break_words, :break_all],
    doc: "Text wrapping behavior"
  
  slot :inner_block,
    doc: "Alternative to text attribute for complex content"
  
  # Include common widget attributes
  widget_attrs()
  
  def text_widget(assigns) do
    ~H"""
    <span class={[
      text_size(@size),
      text_color(@color),
      text_weight(@weight),
      text_align(@align),
      text_style(@italic, @underline),
      text_wrap(@wrap, @truncate),
      widget_classes(assigns)
    ]}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      <%= if @inner_block && @inner_block != [], do: render_slot(@inner_block), else: @text %>
    </span>
    """
  end
  
  defp text_size(:xs), do: "text-xs"
  defp text_size(:sm), do: "text-sm"
  defp text_size(:base), do: "text-base"
  defp text_size(:lg), do: "text-lg"
  defp text_size(:xl), do: "text-xl"
  defp text_size(:xxl), do: "text-2xl"
  defp text_size(:xxxl), do: "text-3xl"
  
  defp text_color(:default), do: nil
  defp text_color(:primary), do: "text-primary"
  defp text_color(:secondary), do: "text-secondary"
  defp text_color(:accent), do: "text-accent"
  defp text_color(:info), do: "text-info"
  defp text_color(:success), do: "text-success"
  defp text_color(:warning), do: "text-warning"
  defp text_color(:error), do: "text-error"
  defp text_color(:muted), do: "text-gray-500"
  
  defp text_weight(:thin), do: "font-thin"
  defp text_weight(:light), do: "font-light"
  defp text_weight(:normal), do: "font-normal"
  defp text_weight(:medium), do: "font-medium"
  defp text_weight(:semibold), do: "font-semibold"
  defp text_weight(:bold), do: "font-bold"
  defp text_weight(:extrabold), do: "font-extrabold"
  defp text_weight(:black), do: "font-black"
  
  defp text_align(:left), do: "text-left"
  defp text_align(:center), do: "text-center"
  defp text_align(:right), do: "text-right"
  defp text_align(:justify), do: "text-justify"
  
  defp text_style(italic, underline) do
    [
      italic && "italic",
      underline && "underline"
    ]
  end
  
  defp text_wrap(:normal, false), do: nil
  defp text_wrap(:normal, true), do: "truncate"
  defp text_wrap(:nowrap, _), do: "whitespace-nowrap"
  defp text_wrap(:break_words, _), do: "break-words"
  defp text_wrap(:break_all, _), do: "break-all"
end