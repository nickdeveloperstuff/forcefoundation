defmodule ForcefoundationWeb.Widgets.BadgeWidget do
  use ForcefoundationWeb.Widgets.Base
  
  @moduledoc """
  Badge component using DaisyUI badge classes.
  """
  
  attr :label, :string, required: true
  attr :color, :atom, default: :default,
    values: [:default, :primary, :secondary, :accent, :info, :success, :warning, :error, :ghost],
    doc: "Badge color"
  attr :size, :atom, default: :md,
    values: [:xs, :sm, :md, :lg],
    doc: "Badge size"
  attr :outline, :boolean, default: false,
    doc: "Use outline style"
  
  # Include common widget attributes
  widget_attrs()
  
  def badge_widget(assigns) do
    ~H"""
    <span class={[
      "badge",
      badge_color(@color, @outline),
      badge_size(@size),
      widget_classes(assigns)
    ]}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      <%= @label %>
    </span>
    """
  end
  
  defp badge_color(:default, false), do: nil
  defp badge_color(:default, true), do: "badge-outline"
  defp badge_color(color, false), do: "badge-#{color}"
  defp badge_color(color, true), do: "badge-#{color} badge-outline"
  
  defp badge_size(:xs), do: "badge-xs"
  defp badge_size(:sm), do: "badge-sm"
  defp badge_size(:md), do: nil
  defp badge_size(:lg), do: "badge-lg"
end