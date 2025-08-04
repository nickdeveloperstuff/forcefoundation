defmodule ForcefoundationWeb.Widgets.ActionHandler do
  @moduledoc """
  Handles Ash action execution for action widgets.
  
  Provides helpers for:
  - Executing Ash actions with proper error handling
  - Managing loading states during action execution
  - Formatting success/error messages
  - Handling optimistic updates
  """
  
  alias Phoenix.LiveView
  import Phoenix.Component, only: [update: 3]
  
  @doc """
  Executes an Ash action with automatic state management.
  
  Updates the socket with loading states and handles the result.
  """
  def execute_action(socket, action_params) do
    action_id = action_params["action_id"]
    action = String.to_existing_atom(action_params["action"])
    resource = Module.concat([action_params["resource"]])
    record_id = action_params["record_id"]
    params = action_params["params"] || %{}
    
    # Set loading state
    socket = start_loading(socket, action_id)
    
    # Execute the action
    result = case action do
      :create ->
        resource
        |> Ash.Changeset.for_create(action, params)
        |> Ash.create()
        
      :update when not is_nil(record_id) ->
        record = get_record!(resource, record_id)
        record
        |> Ash.Changeset.for_update(action, params)
        |> Ash.update()
        
      :destroy when not is_nil(record_id) ->
        record = get_record!(resource, record_id)
        record
        |> Ash.Changeset.for_destroy(action)
        |> Ash.destroy()
        
      custom_action when not is_nil(record_id) ->
        record = get_record!(resource, record_id)
        # For custom actions on records, use update changeset
        record
        |> Ash.Changeset.for_update(custom_action, params)
        |> Ash.update()
        
      custom_action ->
        # For custom actions on resources, use create changeset
        resource
        |> Ash.Changeset.for_create(custom_action, params)
        |> Ash.create()
    end
    
    # Handle the result
    case result do
      {:ok, data} ->
        socket
        |> stop_loading(action_id)
        |> handle_success(action_params, data)
        
      {:error, error} ->
        socket
        |> stop_loading(action_id)
        |> handle_error(action_params, error)
    end
  end
  
  @doc """
  Starts loading state for an action button.
  """
  def start_loading(socket, action_id) do
    update(socket, :loading_actions, fn loading ->
      Map.put(loading || %{}, action_id, true)
    end)
  end
  
  @doc """
  Stops loading state for an action button.
  """
  def stop_loading(socket, action_id) do
    update(socket, :loading_actions, fn loading ->
      Map.delete(loading || %{}, action_id)
    end)
  end
  
  @doc """
  Checks if an action is currently loading.
  """
  def loading?(assigns_or_socket, action_id) do
    assigns = case assigns_or_socket do
      %Phoenix.LiveView.Socket{assigns: assigns} -> assigns
      assigns when is_map(assigns) -> assigns
    end
    
    Map.get(assigns[:loading_actions] || %{}, action_id, false)
  end
  
  defp handle_success(socket, action_params, data) do
    success_message = action_params["success_message"] || default_success_message(action_params)
    on_success = action_params["on_success"]
    
    socket = LiveView.put_flash(socket, :info, success_message)
    
    if on_success do
      LiveView.push_event(socket, on_success, %{
        action: action_params["action"],
        resource: action_params["resource"],
        data: data
      })
    else
      socket
    end
  end
  
  defp handle_error(socket, action_params, error) do
    error_message = action_params["error_message"] || format_error(error)
    on_error = action_params["on_error"]
    
    socket = LiveView.put_flash(socket, :error, error_message)
    
    if on_error do
      LiveView.push_event(socket, on_error, %{
        action: action_params["action"],
        resource: action_params["resource"],
        error: error
      })
    else
      socket
    end
  end
  
  defp get_record!(resource, record_id) do
    case Ash.get(resource, record_id) do
      {:ok, record} -> record
      {:error, _} -> raise "Record not found"
    end
  end
  
  defp default_success_message(%{"action" => action}) do
    case String.to_existing_atom(action) do
      :create -> "Created successfully"
      :update -> "Updated successfully"
      :destroy -> "Deleted successfully"
      _ -> "Action completed successfully"
    end
  end
  
  defp format_error(%Ash.Error.Invalid{errors: errors}) do
    errors
    |> Enum.map(&format_error/1)
    |> Enum.join(", ")
  end
  
  defp format_error(%{message: message}) when is_binary(message) do
    message
  end
  
  defp format_error(%{field: field, message: message}) when is_binary(message) do
    "#{field}: #{message}"
  end
  
  defp format_error(_) do
    "An error occurred"
  end
  
  @doc """
  Helper to add action handlers to a LiveView.
  
  Use in your LiveView:
  
      def handle_event("execute_action", params, socket) do
        {:noreply, ActionHandler.execute_action(socket, params)}
      end
  """
  def handle_action_events(event, params, socket) do
    case event do
      "execute_action" ->
        {:noreply, execute_action(socket, params)}
        
      "confirm_action" ->
        # This will be handled by JavaScript to show the dialog
        {:noreply, socket}
        
      _ ->
        {:noreply, socket}
    end
  end
end