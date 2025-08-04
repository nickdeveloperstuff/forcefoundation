defmodule ForcefoundationWeb.Widgets.CheckboxWidget do
  @moduledoc """
  Checkbox widget with DaisyUI styling.
  
  ## Attributes
  - `:field` - Phoenix.HTML.FormField struct (required)
  - `:label` - Checkbox label
  - `:checked` - Whether checkbox is checked
  - `:variant` - Checkbox variant (:default, :primary, :secondary, etc.)
  - `:size` - Checkbox size (:xs, :sm, :md, :lg)
  
  ## Examples
  
      # Basic checkbox
      <.checkbox_widget 
        field={@form[:terms]}
        label="I agree to the terms and conditions"
      />
      
      # Styled checkbox
      <.checkbox_widget
        field={@form[:newsletter]}
        label="Subscribe to newsletter"
        variant={:primary}
        size={:lg}
      />
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, default: nil
  attr :checked, :boolean, default: nil
  attr :required, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :variant, :atom, default: :default, 
       values: [:default, :primary, :secondary, :accent, :success, :warning, :info, :error]
  attr :size, :atom, default: :md, values: [:xs, :sm, :md, :lg]
  
  # Include common widget attributes
  widget_attrs()
  
  def checkbox_widget(assigns) do
    errors = get_errors(assigns.field, assigns.error)
    checked_value = assigns.checked || assigns.field.value == true || assigns.field.value == "true"
    
    assigns = 
      assigns
      |> assign(:errors, errors)
      |> assign(:has_error, errors != [])
      |> assign(:checkbox_id, assigns.field.id || "checkbox-#{System.unique_integer()}")
      |> assign(:checked_value, checked_value)
    
    ~H"""
    <div class={[
      widget_classes(assigns),
      "widget-checkbox form-control"
    ]}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <label for={@checkbox_id} class="label cursor-pointer justify-start gap-3">
        <input
          type="checkbox"
          name={@field.name}
          id={@checkbox_id}
          value="true"
          checked={@checked_value}
          class={[
            "checkbox",
            checkbox_variant_class(@variant),
            checkbox_size_class(@size),
            @has_error && "checkbox-error"
          ]}
          required={@required}
          disabled={@disabled}
          aria-invalid={@has_error && "true"}
          aria-describedby={@has_error && "#{@checkbox_id}-error"}
        />
        
        <%= if @label do %>
          <span class={["label-text", @required && "after:content-['*'] after:ml-0.5 after:text-error"]}>
            <%= @label %>
          </span>
        <% end %>
      </label>
      
      <%= if @has_error do %>
        <label class="label" id={"#{@checkbox_id}-error"}>
          <span class="label-text-alt text-error">
            <%= Enum.join(@errors, ", ") %>
          </span>
        </label>
      <% end %>
    </div>
    """
  end
  
  defp get_errors(field, custom_error) do
    cond do
      custom_error -> [custom_error]
      field.errors != [] -> Enum.map(field.errors, &translate_error/1)
      true -> []
    end
  end
  
  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
  
  defp checkbox_variant_class(:default), do: ""
  defp checkbox_variant_class(:primary), do: "checkbox-primary"
  defp checkbox_variant_class(:secondary), do: "checkbox-secondary"
  defp checkbox_variant_class(:accent), do: "checkbox-accent"
  defp checkbox_variant_class(:success), do: "checkbox-success"
  defp checkbox_variant_class(:warning), do: "checkbox-warning"
  defp checkbox_variant_class(:info), do: "checkbox-info"
  defp checkbox_variant_class(:error), do: "checkbox-error"
  
  defp checkbox_size_class(:xs), do: "checkbox-xs"
  defp checkbox_size_class(:sm), do: "checkbox-sm"
  defp checkbox_size_class(:md), do: "checkbox-md"
  defp checkbox_size_class(:lg), do: "checkbox-lg"
end