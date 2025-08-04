defmodule ForcefoundationWeb.Widgets.FormHelpers do
  @moduledoc """
  Helper functions for working with forms in widgets.
  
  Provides utilities for:
  - Creating forms from Ash resources
  - Handling form validation
  - Extracting and formatting errors
  - Form state management
  """
  
  import Phoenix.Component, only: [to_form: 1]
  
  @doc """
  Creates a form from an Ash resource for a specific action.
  
  ## Examples
  
      form = FormHelpers.create_form(User, :register)
      form = FormHelpers.create_form(User, :update, existing_user)
      form = FormHelpers.create_form(User, :create, %{name: "John"})
  """
  def create_form(resource, action, params \\ %{}) do
    cond do
      # Check if this is an Ash resource
      function_exported?(resource, :__ash_resource__, 0) ->
        create_ash_form(resource, action, params)
      
      # Check if it's an Ecto schema
      function_exported?(resource, :__schema__, 1) ->
        create_ecto_form(resource, action, params)
      
      # Fallback to basic map-based form
      true ->
        to_form(params)
    end
  end
  
  @doc """
  Updates a form with new params, maintaining form state.
  """
  def update_form(form, params) do
    case form.source do
      %AshPhoenix.Form{} = ash_form ->
        AshPhoenix.Form.validate(ash_form, params)
        |> to_form()
      
      %Ecto.Changeset{data: data} ->
        data
        |> data.__struct__.changeset(params)
        |> Map.put(:action, :validate)
        |> to_form()
      
      _ ->
        # Basic form update
        to_form(Map.merge(form.params || %{}, params))
    end
  end
  
  @doc """
  Submits a form and returns the result.
  """
  def submit_form(form) do
    case form.source do
      %AshPhoenix.Form{} = ash_form ->
        submit_ash_form(ash_form)
      
      %Ecto.Changeset{} = changeset ->
        submit_ecto_form(changeset)
      
      _ ->
        # Basic form submission
        {:ok, form.params}
    end
  end
  
  @doc """
  Extracts errors from a form in a consistent format.
  """
  def form_errors(form) do
    case form.source do
      %AshPhoenix.Form{} = ash_form ->
        AshPhoenix.Form.errors(ash_form)
      
      %Ecto.Changeset{errors: errors} ->
        format_ecto_errors(errors)
      
      _ ->
        []
    end
  end
  
  @doc """
  Checks if a form has any errors.
  """
  def has_errors?(form) do
    form_errors(form) != []
  end
  
  @doc """
  Gets the value of a field from a form.
  """
  def get_field_value(form, field) do
    case form.source do
      %AshPhoenix.Form{} = ash_form ->
        AshPhoenix.Form.value(ash_form, field)
      
      %Ecto.Changeset{} = changeset ->
        Ecto.Changeset.get_field(changeset, field)
      
      _ ->
        Map.get(form.params || %{}, to_string(field))
    end
  end
  
  # Private functions
  
  defp create_ash_form(_resource, action, params) when is_struct(params) do
    # Updating existing resource
    AshPhoenix.Form.for_update(params, action)
    |> AshPhoenix.Form.validate(params)
    |> to_form()
  end
  
  defp create_ash_form(resource, action, params) do
    # Creating new resource
    AshPhoenix.Form.for_create(resource, action)
    |> AshPhoenix.Form.validate(params)
    |> to_form()
  end
  
  defp create_ecto_form(schema, :create, params) do
    schema
    |> struct()
    |> schema.changeset(params)
    |> Map.put(:action, :validate)
    |> to_form()
  end
  
  defp create_ecto_form(schema, :update, %{__struct__: _} = struct) do
    struct
    |> schema.changeset(%{})
    |> Map.put(:action, :validate)
    |> to_form()
  end
  
  defp create_ecto_form(schema, _action, params) do
    schema
    |> struct()
    |> schema.changeset(params)
    |> Map.put(:action, :validate)
    |> to_form()
  end
  
  defp submit_ash_form(form) do
    case AshPhoenix.Form.submit(form) do
      {:ok, result} -> {:ok, result}
      {:error, form} -> {:error, to_form(form)}
    end
  end
  
  defp submit_ecto_form(changeset) do
    # This would typically use your repo
    # For now, we'll return a placeholder
    if changeset.valid? do
      {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
      {:error, to_form(changeset)}
    end
  end
  
  defp format_ecto_errors(errors) do
    Enum.map(errors, fn {field, {msg, opts}} ->
      message = format_error_message(msg, opts)
      {field, message}
    end)
  end
  
  defp format_error_message(msg, opts) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end