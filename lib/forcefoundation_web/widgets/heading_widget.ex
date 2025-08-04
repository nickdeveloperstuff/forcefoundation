defmodule ForcefoundationWeb.Widgets.HeadingWidget do
  use ForcefoundationWeb.Widgets.Base
  
  @moduledoc """
  Heading widget with consistent styling and sizes.
  """
  
  attr :level, :integer, default: 2,
    values: [1, 2, 3, 4, 5, 6],
    doc: "Heading level (h1-h6)"
  attr :text, :string, required: true,
    doc: "Heading text"
  attr :size, :atom, default: nil,
    doc: "Override default size for level"
  attr :weight, :atom, default: :bold,
    values: [:normal, :medium, :semibold, :bold, :extrabold],
    doc: "Font weight"
  attr :color, :atom, default: :default,
    doc: "Text color"
  
  # Include common widget attributes
  widget_attrs()
  
  def heading_widget(assigns) do
    ~H"""
    <%= case @level do %>
      <% 1 -> %>
        <h1 class={[
          heading_size(@level, @size),
          font_weight(@weight),
          text_color(@color),
          widget_classes(assigns)
        ]}>
          <%= Phoenix.HTML.raw(render_debug(assigns)) %>
          <%= @text %>
        </h1>
      <% 2 -> %>
        <h2 class={[
          heading_size(@level, @size),
          font_weight(@weight),
          text_color(@color),
          widget_classes(assigns)
        ]}>
          <%= Phoenix.HTML.raw(render_debug(assigns)) %>
          <%= @text %>
        </h2>
      <% 3 -> %>
        <h3 class={[
          heading_size(@level, @size),
          font_weight(@weight),
          text_color(@color),
          widget_classes(assigns)
        ]}>
          <%= Phoenix.HTML.raw(render_debug(assigns)) %>
          <%= @text %>
        </h3>
      <% 4 -> %>
        <h4 class={[
          heading_size(@level, @size),
          font_weight(@weight),
          text_color(@color),
          widget_classes(assigns)
        ]}>
          <%= Phoenix.HTML.raw(render_debug(assigns)) %>
          <%= @text %>
        </h4>
      <% 5 -> %>
        <h5 class={[
          heading_size(@level, @size),
          font_weight(@weight),
          text_color(@color),
          widget_classes(assigns)
        ]}>
          <%= Phoenix.HTML.raw(render_debug(assigns)) %>
          <%= @text %>
        </h5>
      <% _ -> %>
        <h6 class={[
          heading_size(@level, @size),
          font_weight(@weight),
          text_color(@color),
          widget_classes(assigns)
        ]}>
          <%= Phoenix.HTML.raw(render_debug(assigns)) %>
          <%= @text %>
        </h6>
    <% end %>
    """
  end
  
  # Default sizes for each level
  defp heading_size(1, nil), do: "text-4xl"
  defp heading_size(2, nil), do: "text-3xl"
  defp heading_size(3, nil), do: "text-2xl"
  defp heading_size(4, nil), do: "text-xl"
  defp heading_size(5, nil), do: "text-lg"
  defp heading_size(6, nil), do: "text-base"
  
  # Size overrides
  defp heading_size(_, :xs), do: "text-xs"
  defp heading_size(_, :sm), do: "text-sm"
  defp heading_size(_, :base), do: "text-base"
  defp heading_size(_, :lg), do: "text-lg"
  defp heading_size(_, :xl), do: "text-xl"
  defp heading_size(_, :xxl), do: "text-2xl"
  defp heading_size(_, :xxxl), do: "text-3xl"
  
  defp font_weight(:normal), do: "font-normal"
  defp font_weight(:medium), do: "font-medium"
  defp font_weight(:semibold), do: "font-semibold"
  defp font_weight(:bold), do: "font-bold"
  defp font_weight(:extrabold), do: "font-extrabold"
  
  defp text_color(:default), do: "text-base-content"
  defp text_color(:primary), do: "text-primary"
  defp text_color(:secondary), do: "text-secondary"
  defp text_color(:muted), do: "text-base-content/70"
  defp text_color(:error), do: "text-error"
  defp text_color(:success), do: "text-success"
end