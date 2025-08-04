defmodule ForcefoundationWeb.Widgets.SelectWidget do
  @moduledoc """
  Select dropdown widget with DaisyUI styling.
  
  ## Attributes
  - `:field` - Phoenix.HTML.FormField struct (required)
  - `:options` - List of options as {label, value} tuples
  - `:label` - Select label
  - `:prompt` - Default prompt option
  - `:selected` - Currently selected value
  - `:multiple` - Allow multiple selections
  - `:size` - Number of visible options (for multiple)
  
  ## Examples
  
      # Basic select
      <.select_widget 
        field={@form[:country]}
        label="Country"
        options={[
          {"United States", "US"},
          {"Canada", "CA"},
          {"Mexico", "MX"}
        ]}
        prompt="Choose a country"
      />
      
      # Multiple select
      <.select_widget
        field={@form[:tags]}
        label="Tags"
        options={@available_tags}
        multiple
        size={5}
      />
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :field, Phoenix.HTML.FormField, required: true
  attr :options, :list, required: true
  attr :label, :string, default: nil
  attr :prompt, :string, default: nil
  attr :selected, :any, default: nil
  attr :multiple, :boolean, default: false
  attr :size, :integer, default: nil
  attr :required, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :variant, :atom, default: :bordered, values: [:default, :bordered, :ghost]
  attr :select_size, :atom, default: :md, values: [:xs, :sm, :md, :lg]
  attr :hint, :string, default: nil
  
  # Include common widget attributes
  widget_attrs()
  
  def select_widget(assigns) do
    errors = get_errors(assigns.field, assigns.error)
    has_error = errors != []
    
    assigns = 
      assigns
      |> assign(:errors, errors)
      |> assign(:has_error, has_error)
      |> assign(:select_id, assigns.field.id || "select-#{System.unique_integer()}")
    
    ~H"""
    <div class={[
      widget_classes(assigns),
      "widget-select form-control"
    ]}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <%= if @label do %>
        <label for={@select_id} class="label">
          <span class={["label-text", @required && "after:content-['*'] after:ml-0.5 after:text-error"]}>
            <%= @label %>
          </span>
        </label>
      <% end %>
      
      <select
        name={@field.name <> if(@multiple, do: "[]", else: "")}
        id={@select_id}
        class={[
          "select",
          select_variant_class(@variant),
          select_size_class(@select_size),
          @has_error && "select-error"
        ]}
        multiple={@multiple}
        size={@size}
        required={@required}
        disabled={@disabled}
        aria-invalid={@has_error && "true"}
        aria-describedby={@has_error && "#{@select_id}-error"}
      >
        <%= if @prompt && !@multiple do %>
          <option value=""><%= @prompt %></option>
        <% end %>
        
        <%= Phoenix.HTML.Form.options_for_select(@options, @selected || @field.value) %>
      </select>
      
      <%= if @has_error do %>
        <label class="label" id={"#{@select_id}-error"}>
          <span class="label-text-alt text-error">
            <%= Enum.join(@errors, ", ") %>
          </span>
        </label>
      <% end %>
      
      <%= if @hint && !@has_error do %>
        <label class="label">
          <span class="label-text-alt"><%= @hint %></span>
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
  
  defp select_variant_class(:default), do: ""
  defp select_variant_class(:bordered), do: "select-bordered"
  defp select_variant_class(:ghost), do: "select-ghost"
  
  defp select_size_class(:xs), do: "select-xs"
  defp select_size_class(:sm), do: "select-sm"
  defp select_size_class(:md), do: "select-md"
  defp select_size_class(:lg), do: "select-lg"
end