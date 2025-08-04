defmodule ForcefoundationWeb.Widgets.Base do
  @moduledoc """
  Base behavior for all widgets in the system.
  
  This module provides:
  - Common attributes (class, id, data_source, debug_mode)
  - Grid system integration (span, padding, margin)
  - Data resolution patterns
  - Error handling
  - Loading states
  - Debug tooling
  """
  
  # Required callbacks for all widgets - the actual component function will be named after the widget
  
  # Optional callbacks
  @callback connect(data_source :: term(), socket :: Phoenix.LiveView.Socket.t()) :: 
    {:ok, Phoenix.LiveView.Socket.t()} | {:error, term()}
  @callback handle_event(event :: String.t(), params :: map(), socket :: Phoenix.LiveView.Socket.t()) ::
    {:noreply, Phoenix.LiveView.Socket.t()}
  @callback update(assigns :: map(), socket :: Phoenix.LiveView.Socket.t()) ::
    {:ok, Phoenix.LiveView.Socket.t()}
    
  @optional_callbacks connect: 2, handle_event: 3, update: 2
  
  defmacro __using__(_opts) do
    quote do
      use Phoenix.Component
      import ForcefoundationWeb.Widgets.Helpers
      import ForcefoundationWeb.Widgets.Base
      
      # Widgets are Phoenix Components, not behaviors
      
      # Helper functions available to all widgets
      
      defp widget_classes(assigns) do
        [
          # Base widget class
          "widget",
          "widget-#{widget_name()}",
          
          # Grid classes
          span_class(assigns[:span]),
          padding_class(assigns[:padding]),
          margin_class(assigns[:margin]),
          
          # State classes
          assigns[:loading] && "widget-loading",
          assigns[:error] && "widget-error",
          
          # Custom classes
          assigns[:class]
        ]
        |> Enum.filter(& &1)
        |> Enum.join(" ")
      end
      
      defp widget_name do
        __MODULE__
        |> Module.split()
        |> List.last()
        |> Macro.underscore()
        |> String.replace("_widget", "")
      end
      
      defp render_debug(assigns, widget_name) do
        if assigns[:debug_mode] do
          """
          <div class="absolute top-0 right-0 bg-black/75 text-white text-xs p-2 rounded-bl z-50">
            <div class="font-bold">#{widget_name}</div>
            <div>Mode: #{if assigns[:data_source] == :static, do: "dumb", else: "connected"}</div>
            <div>Source: #{inspect(assigns[:data_source])}</div>
            #{if assigns[:loading], do: "<div>Loading...</div>"}
            #{if assigns[:error], do: "<div class=\"text-red-400\">Error: #{assigns[:error]}</div>"}
          </div>
          """
        else
          ""
        end
      end
      
      defp render_debug(assigns) do
        render_debug(assigns, widget_name())
      end
      
      # Default implementations
      def update(assigns, socket) do
        {:ok, assign(socket, assigns)}
      end
      
      defoverridable update: 2
    end
  end
  
  defmacro widget_attrs do
    quote do
      # Core attributes every widget has
      attr :id, :string, default: nil,
        doc: "DOM ID for the widget"
      attr :class, :string, default: "",
        doc: "Additional CSS classes"
      attr :data_source, :any, default: :static,
        doc: "Data source configuration (see connection patterns)"
      attr :debug_mode, :boolean, default: false,
        doc: "Show debug overlay with data source info"
      
      # Grid system attributes  
      attr :span, :integer, default: nil,
        doc: "Grid columns to span (12-column grid) - allowed values: 1, 2, 3, 4, 6, 8, 12"
      attr :padding, :integer, default: nil,
        doc: "Padding multiplier (4px base) - allowed values: 0, 1, 2, 3, 4, 6, 8"
      attr :margin, :integer, default: nil,
        doc: "Margin multiplier (4px base) - allowed values: 0, 1, 2, 3, 4, 6, 8"
        
      # State attributes
      attr :loading, :boolean, default: false,
        doc: "Show loading state"
      attr :error, :string, default: nil,
        doc: "Error message to display"
    end
  end
end