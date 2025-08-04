defmodule ForcefoundationWeb.Widgets.RadioWidget do
  @moduledoc """
  Radio button group widget with DaisyUI styling.
  
  ## Attributes
  - `:field` - Phoenix.HTML.FormField struct (required)
  - `:options` - List of {label, value} tuples
  - `:label` - Group label
  - `:selected` - Currently selected value
  - `:layout` - Layout direction (:vertical, :horizontal)
  
  ## Examples
  
      # Radio group
      <.radio_widget 
        field={@form[:plan]}
        label="Choose your plan"
        options={[
          {"Free", "free"},
          {"Pro ($9/mo)", "pro"},
          {"Enterprise", "enterprise"}
        ]}
      />
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :field, Phoenix.HTML.FormField, required: true
  attr :options, :list, required: true
  attr :label, :string, default: nil
  attr :selected, :any, default: nil
  attr :required, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :layout, :atom, default: :vertical, values: [:vertical, :horizontal]
  attr :variant, :atom, default: :default,
       values: [:default, :primary, :secondary, :accent, :success, :warning, :info, :error]
  attr :size, :atom, default: :md, values: [:xs, :sm, :md, :lg]
  
  # Include common widget attributes
  widget_attrs()
  
  def radio_widget(assigns) do
    errors = get_errors(assigns.field, assigns.error)
    current_value = assigns.selected || assigns.field.value
    
    assigns = 
      assigns
      |> assign(:errors, errors)
      |> assign(:has_error, errors != [])
      |> assign(:current_value, current_value)
      |> assign(:group_id, "radio-group-#{System.unique_integer()}")
    
    ~H"""
    <div class={[
      widget_classes(assigns),
      "widget-radio form-control"
    ]} role="radiogroup" aria-labelledby={@label && "#{@group_id}-label"}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <%= if @label do %>
        <label class="label" id={"#{@group_id}-label"}>
          <span class={["label-text", @required && "after:content-['*'] after:ml-0.5 after:text-error"]}>
            <%= @label %>
          </span>
        </label>
      <% end %>
      
      <div class={[
        "radio-group",
        @layout == :horizontal && "flex flex-wrap gap-4",
        @layout == :vertical && "space-y-2"
      ]}>
        <%= for {option_label, option_value} <- @options do %>
          <label class="label cursor-pointer justify-start gap-2">
            <input
              type="radio"
              name={@field.name}
              value={option_value}
              checked={to_string(@current_value) == to_string(option_value)}
              class={[
                "radio",
                radio_variant_class(@variant),
                radio_size_class(@size),
                @has_error && "radio-error"
              ]}
              required={@required}
              disabled={@disabled}
              aria-invalid={@has_error && "true"}
            />
            <span class="label-text"><%= option_label %></span>
          </label>
        <% end %>
      </div>
      
      <%= if @has_error do %>
        <label class="label">
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
  
  defp radio_variant_class(:default), do: ""
  defp radio_variant_class(:primary), do: "radio-primary"
  defp radio_variant_class(:secondary), do: "radio-secondary"
  defp radio_variant_class(:accent), do: "radio-accent"
  defp radio_variant_class(:success), do: "radio-success"
  defp radio_variant_class(:warning), do: "radio-warning"
  defp radio_variant_class(:info), do: "radio-info"
  defp radio_variant_class(:error), do: "radio-error"
  
  defp radio_size_class(:xs), do: "radio-xs"
  defp radio_size_class(:sm), do: "radio-sm"
  defp radio_size_class(:md), do: "radio-md"
  defp radio_size_class(:lg), do: "radio-lg"
end