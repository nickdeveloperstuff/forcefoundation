defmodule ForcefoundationWeb.Widgets.TestWidget do
  use ForcefoundationWeb.Widgets.Base
  
  @moduledoc """
  A simple test widget to verify our widget system is working.
  This widget will be removed once we have real widgets.
  """
  
  # Include common widget attributes
  widget_attrs()
  
  # Widget-specific attributes
  attr :message, :string, default: "Hello from the widget system!"
  attr :color, :atom, default: :primary,
    values: [:primary, :secondary, :success, :error, :warning, :info]
  
  def test_widget(assigns) do
    ~H"""
    <div class={[
      "alert",
      alert_color(@color),
      widget_classes(assigns)
    ]}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      <span>{@message}</span>
    </div>
    """
  end
  
  defp alert_color(:primary), do: "alert-primary"
  defp alert_color(:secondary), do: "alert-secondary"
  defp alert_color(:success), do: "alert-success"
  defp alert_color(:error), do: "alert-error"
  defp alert_color(:warning), do: "alert-warning"
  defp alert_color(:info), do: "alert-info"
end