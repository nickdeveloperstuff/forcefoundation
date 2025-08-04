defmodule ForcefoundationWeb.Widgets.Connectable do
  @moduledoc """
  Mixin that adds data connection capabilities to widgets.
  
  Use this in your widget to automatically handle:
  - Data resolution on mount
  - Loading states
  - Error handling
  - Re-resolution on updates
  """
  
  alias ForcefoundationWeb.Widgets.ConnectionResolver
  
  defmacro __using__(_opts) do
    quote do
      import ForcefoundationWeb.Widgets.Connectable
      
      # Override update to handle data resolution
      def update(assigns, socket) do
        socket = Phoenix.Component.assign(socket, assigns)
        
        # Check if we need to resolve data
        if assigns[:data_source] && assigns[:data_source] != :static do
          resolve_data(socket)
        else
          {:ok, socket}
        end
      end
      
      # Allow widgets to override
      defoverridable update: 2
      
      # Handle incoming PubSub messages
      def handle_info({:pubsub, topic, message}, socket) do
        cond do
          # Stream subscription
          socket.assigns[:__widget_stream__] == topic ->
            {:noreply, Phoenix.Component.assign(socket, :data, message)}
            
          # Filtered subscription
          socket.assigns[:__widget_subscription__] == topic ->
            filter_fn = socket.assigns[:__widget_filter__]
            if filter_fn.(message) do
              {:noreply, Phoenix.Component.assign(socket, :data, message)}
            else
              {:noreply, socket}
            end
            
          # Not our subscription
          true ->
            {:noreply, socket}
        end
      end
      
      # Default handle_info that does nothing
      def handle_info(_message, socket) do
        {:noreply, socket}
      end
      
      defoverridable handle_info: 2
    end
  end
  
  @doc """
  Resolves data from the configured data source.
  
  Sets loading state while resolving and handles errors gracefully.
  """
  def resolve_data(socket) do
    data_source = socket.assigns[:data_source]
    
    # Set loading state
    socket = socket
      |> Phoenix.Component.assign(:loading, true)
      |> Phoenix.Component.assign(:error, nil)
    
    # Resolve the data
    case ConnectionResolver.resolve(data_source, socket) do
      {:ok, data, updated_socket} ->
        {:ok, updated_socket
          |> Phoenix.Component.assign(:data, data)
          |> Phoenix.Component.assign(:loading, false)}
        
      {:error, reason, updated_socket} ->
        {:ok, updated_socket
          |> Phoenix.Component.assign(:error, format_error(reason))
          |> Phoenix.Component.assign(:loading, false)}
    end
  end
  
  defp format_error(reason) when is_binary(reason), do: reason
  defp format_error(:not_found), do: "Resource not found"
  defp format_error(:unknown_data_source), do: "Unknown data source type"
  defp format_error(reason), do: inspect(reason)
end