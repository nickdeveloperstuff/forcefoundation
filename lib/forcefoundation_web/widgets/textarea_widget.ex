defmodule ForcefoundationWeb.Widgets.TextareaWidget do
  @moduledoc """
  Textarea widget for multi-line text input.
  
  ## Attributes
  - `:field` - Phoenix.HTML.FormField struct (required)
  - `:label` - Textarea label
  - `:placeholder` - Placeholder text
  - `:rows` - Number of visible rows
  - `:resize` - Allow resizing (:none, :vertical, :horizontal, :both)
  
  ## Examples
  
      # Basic textarea
      <.textarea_widget 
        field={@form[:description]}
        label="Description"
        rows={4}
      />
      
      # With character counter
      <.textarea_widget
        field={@form[:bio]}
        label="Bio"
        placeholder="Tell us about yourself..."
        rows={6}
        maxlength={500}
        show_count
      />
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, default: nil
  attr :placeholder, :string, default: nil
  attr :rows, :integer, default: 4
  attr :required, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :readonly, :boolean, default: false
  attr :resize, :atom, default: :vertical, values: [:none, :vertical, :horizontal, :both]
  attr :variant, :atom, default: :bordered, values: [:default, :bordered, :ghost]
  attr :size, :atom, default: :md, values: [:xs, :sm, :md, :lg]
  attr :hint, :string, default: nil
  attr :maxlength, :integer, default: nil
  attr :show_count, :boolean, default: false
  
  # Include common widget attributes
  widget_attrs()
  
  def textarea_widget(assigns) do
    errors = get_errors(assigns.field, assigns.error)
    has_error = errors != []
    current_length = String.length(assigns.field.value || "")
    
    assigns = 
      assigns
      |> assign(:errors, errors)
      |> assign(:has_error, has_error)
      |> assign(:textarea_id, assigns.field.id || "textarea-#{System.unique_integer()}")
      |> assign(:current_length, current_length)
    
    ~H"""
    <div class={[
      widget_classes(assigns),
      "widget-textarea form-control"
    ]}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <%= if @label do %>
        <label for={@textarea_id} class="label">
          <span class={["label-text", @required && "after:content-['*'] after:ml-0.5 after:text-error"]}>
            <%= @label %>
          </span>
          <%= if @show_count && @maxlength do %>
            <span class="label-text-alt">
              <%= @current_length %>/<%= @maxlength %>
            </span>
          <% end %>
        </label>
      <% end %>
      
      <textarea
        name={@field.name}
        id={@textarea_id}
        rows={@rows}
        class={[
          "textarea",
          textarea_variant_class(@variant),
          textarea_size_class(@size),
          textarea_resize_class(@resize),
          @has_error && "textarea-error"
        ]}
        placeholder={@placeholder}
        required={@required}
        disabled={@disabled}
        readonly={@readonly}
        maxlength={@maxlength}
        phx-debounce="300"
        aria-invalid={@has_error && "true"}
        aria-describedby={@has_error && "#{@textarea_id}-error"}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @field.value) %></textarea>
      
      <%= if @has_error do %>
        <label class="label" id={"#{@textarea_id}-error"}>
          <span class="label-text-alt text-error">
            <%= Enum.join(@errors, ", ") %>
          </span>
        </label>
      <% end %>
      
      <%= if @hint && !@has_error do %>
        <label class="label">
          <span class="label-text-alt"><%= @hint %></span>
          <%= if @show_count && @maxlength && !@label do %>
            <span class="label-text-alt">
              <%= @current_length %>/<%= @maxlength %>
            </span>
          <% end %>
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
  
  defp textarea_variant_class(:default), do: ""
  defp textarea_variant_class(:bordered), do: "textarea-bordered"
  defp textarea_variant_class(:ghost), do: "textarea-ghost"
  
  defp textarea_size_class(:xs), do: "textarea-xs text-xs"
  defp textarea_size_class(:sm), do: "textarea-sm text-sm"
  defp textarea_size_class(:md), do: "textarea-md"
  defp textarea_size_class(:lg), do: "textarea-lg text-lg"
  
  defp textarea_resize_class(:none), do: "resize-none"
  defp textarea_resize_class(:vertical), do: "resize-y"
  defp textarea_resize_class(:horizontal), do: "resize-x"
  defp textarea_resize_class(:both), do: "resize"
end