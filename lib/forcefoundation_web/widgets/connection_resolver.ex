defmodule ForcefoundationWeb.Widgets.ConnectionResolver do
  @moduledoc """
  Resolves widget data connections from various sources.
  
  Connection types:
  1. :static - No connection (dumb widget mode)
  2. {:interface, domain} - Connect to domain interface query
  3. {:resource, domain, id} - Connect to single resource
  4. {:stream, topic} - Connect to Phoenix PubSub stream  
  5. {:form, changeset} - Connect to form changeset
  6. {:action, domain, name, params} - Connect to domain action
  7. {:subscribe, topic, filter} - Subscribe with filtering
  """
  
  require Logger
  
  @doc """
  Resolves a data source connection and returns the data or error.
  
  ## Examples
  
      # Static/dumb mode
      resolve(:static, socket)
      # => {:ok, nil, socket}
      
      # Interface connection
      resolve({:interface, MyApp.Users}, socket)
      # => {:ok, [%User{}, ...], socket}
      
      # Resource connection
      resolve({:resource, MyApp.Users, "123"}, socket)
      # => {:ok, %User{id: "123"}, socket}
  """
  def resolve(:static, socket) do
    {:ok, nil, socket}
  end
  
  def resolve({:interface, domain}, socket) do
    case query_interface(domain) do
      {:ok, results} ->
        {:ok, results, socket}
      {:error, reason} ->
        {:error, reason, socket}
    end
  end
  
  def resolve({:resource, domain, id}, socket) do
    case fetch_resource(domain, id) do
      {:ok, resource} ->
        {:ok, resource, socket}
      {:error, reason} ->
        {:error, reason, socket}
    end
  end
  
  def resolve({:stream, topic}, socket) do
    # Subscribe to PubSub topic
    Phoenix.PubSub.subscribe(Forcefoundation.PubSub, topic)
    
    # Store subscription info in socket
    socket = update_assigns(socket, :__widget_stream__, topic)
    
    {:ok, nil, socket}
  end
  
  def resolve({:form, changeset}, socket) do
    # Forms pass through the changeset directly
    {:ok, changeset, socket}
  end
  
  def resolve({:action, domain, action_name, params}, socket) do
    case execute_action(domain, action_name, params) do
      {:ok, result} ->
        {:ok, result, socket}
      {:error, reason} ->
        {:error, reason, socket}
    end
  end
  
  def resolve({:subscribe, topic, filter_fn}, socket) when is_function(filter_fn) do
    # Subscribe to PubSub with filter
    Phoenix.PubSub.subscribe(Forcefoundation.PubSub, topic)
    
    # Store subscription and filter info
    socket = socket
      |> update_assigns(:__widget_subscription__, topic)
      |> update_assigns(:__widget_filter__, filter_fn)
    
    {:ok, nil, socket}
  end
  
  def resolve(unknown, socket) do
    Logger.warning("Unknown data source type: #{inspect(unknown)}")
    {:error, :unknown_data_source, socket}
  end
  
  # Private helpers
  
  defp update_assigns(socket, key, value) do
    # Safely update assigns whether it's a LiveView socket or a struct
    case socket do
      %Phoenix.LiveView.Socket{} ->
        Phoenix.Component.assign(socket, key, value)
      %{assigns: assigns} ->
        %{socket | assigns: Map.put(assigns, key, value)}
      socket ->
        socket
    end
  end
  
  defp query_interface(domain) do
    # In real implementation, this would:
    # 1. Check if domain has a query/0 or list/0 function
    # 2. Call it with appropriate context
    # For now, mock implementation:
    
    if function_exported?(domain, :list, 0) do
      try do
        {:ok, domain.list()}
      rescue
        e -> {:error, Exception.format(:error, e)}
      end
    else
      {:error, "Domain #{inspect(domain)} does not support interface queries"}
    end
  end
  
  defp fetch_resource(domain, id) do
    # In real implementation, this would:
    # 1. Check if domain has a get/1 or fetch/1 function  
    # 2. Call it with the ID
    # For now, mock implementation:
    
    if function_exported?(domain, :get, 1) do
      try do
        case domain.get(id) do
          nil -> {:error, :not_found}
          resource -> {:ok, resource}
        end
      rescue
        e -> {:error, Exception.format(:error, e)}
      end
    else
      {:error, "Domain #{inspect(domain)} does not support resource fetching"}
    end
  end
  
  defp execute_action(domain, action_name, params) do
    # In real implementation, this would:
    # 1. Check if domain has the action function
    # 2. Call it with params and context
    # For now, mock implementation:
    
    if function_exported?(domain, action_name, 1) do
      try do
        apply(domain, action_name, [params])
      rescue
        e -> {:error, Exception.format(:error, e)}
      end
    else
      {:error, "Domain #{inspect(domain)} does not have action #{action_name}/1"}
    end
  end
end