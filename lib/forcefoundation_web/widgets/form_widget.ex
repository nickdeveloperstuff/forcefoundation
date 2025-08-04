defmodule ForcefoundationWeb.Widgets.FormWidget do
  @moduledoc """
  Form container widget that wraps Phoenix LiveView's form component.
  
  Supports both Ash changesets and regular Ecto changesets with automatic
  error handling and submission state tracking.
  
  ## Attributes
  - `:for` - Phoenix.HTML.Form struct or changeset (required)
  - `:action` - Form action URL (optional)
  - `:method` - HTTP method (:post, :put, :patch, :delete)
  - `:multipart` - Whether form accepts file uploads
  - `:as` - Form name (defaults to resource name)
  - `:errors` - Whether to display errors inline
  - `:variant` - Form variant (:default, :inline, :floating)
  - `:on_submit` - Event handler for form submission
  - `:on_change` - Event handler for form changes
  - `:on_reset` - Event handler for form reset
  
  ## Slots
  - `:default` - Form content
  - `:actions` - Form action buttons
  - `:header` - Optional form header
  - `:footer` - Optional form footer
  
  ## Examples
  
      # Basic form
      <.form_widget 
        for={@form} 
        on_submit="save"
      >
        <.input_widget field={@form[:name]} label="Name" />
        <:actions>
          <.button type="submit">Save</.button>
        </:actions>
      </.form_widget>
      
      # Ash form with validation
      <.form_widget
        for={@form}
        on_submit="save_user"
        on_change="validate_user"
        errors
      >
        <.input_widget field={@form[:email]} label="Email" />
        <:actions>
          <.button type="submit" loading={@saving}>
            Save User
          </.button>
        </:actions>
      </.form_widget>
  """
  use ForcefoundationWeb.Widgets.Base
  
  attr :for, :any, required: true, doc: "Phoenix.HTML.Form struct or changeset"
  attr :action, :string, default: nil
  attr :method, :atom, default: :post, values: [:post, :put, :patch, :delete]
  attr :multipart, :boolean, default: false
  attr :as, :atom, default: nil
  attr :errors, :boolean, default: true, doc: "Show errors inline"
  attr :variant, :atom, default: :default, values: [:default, :inline, :floating]
  attr :on_submit, :string, default: nil
  attr :on_change, :string, default: nil
  attr :on_reset, :string, default: nil
  attr :disabled, :boolean, default: false
  
  slot :inner_block, required: true
  slot :actions
  slot :header
  slot :footer
  
  # Include common widget attributes
  widget_attrs()
  
  def form_widget(assigns) do
    # Ensure we have a proper form struct
    form = ensure_form(assigns.for)
    
    assigns = 
      assigns
      |> assign(:form, form)
      |> assign(:form_errors, extract_errors(form))
      |> assign(:has_errors, has_errors?(form))
    
    ~H"""
    <.form
      for={@form}
      action={@action}
      method={@method}
      multipart={@multipart}
      as={@as || form_name(@form)}
      phx-submit={@on_submit}
      phx-change={@on_change}
      phx-reset={@on_reset}
      class={[
        widget_classes(assigns),
        "widget-form",
        form_variant_class(@variant),
        @has_errors && @errors && "form-has-errors",
        @loading && "form-loading",
        @disabled && "form-disabled"
      ]}
    >
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <%= if @header != [] do %>
        <div class="form-header">
          <%= render_slot(@header) %>
        </div>
      <% end %>
      
      <%= if @errors && @has_errors do %>
        <div class="alert alert-error mb-4">
          <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <div>
            <h3 class="font-bold">Form has errors</h3>
            <ul class="mt-2 list-disc list-inside">
              <%= for {field, errors} <- @form_errors do %>
                <%= for error <- errors do %>
                  <li><%= humanize(field) %>: <%= error %></li>
                <% end %>
              <% end %>
            </ul>
          </div>
        </div>
      <% end %>
      
      <div class={form_content_class(@variant)}>
        <%= render_slot(@inner_block) %>
      </div>
      
      <%= if @actions != [] do %>
        <div class={form_actions_class(@variant)}>
          <%= render_slot(@actions) %>
        </div>
      <% end %>
      
      <%= if @footer != [] do %>
        <div class="form-footer">
          <%= render_slot(@footer) %>
        </div>
      <% end %>
    </.form>
    """
  end
  
  # Helper functions
  defp ensure_form(%Phoenix.HTML.Form{} = form), do: form
  defp ensure_form(changeset) do
    Phoenix.Component.to_form(changeset)
  end
  
  defp form_name(%Phoenix.HTML.Form{name: name}) when is_atom(name), do: name
  defp form_name(%Phoenix.HTML.Form{name: name}) when is_binary(name), do: String.to_atom(name)
  defp form_name(_), do: :form
  
  defp extract_errors(%Phoenix.HTML.Form{source: %{errors: errors}}) when is_list(errors) do
    Enum.group_by(errors, fn {field, _} -> field end, fn {_, {msg, _}} -> msg end)
  end
  defp extract_errors(_), do: %{}
  
  defp has_errors?(%Phoenix.HTML.Form{source: %{errors: errors}}) when is_list(errors) do
    length(errors) > 0
  end
  defp has_errors?(_), do: false
  
  defp form_variant_class(:default), do: "form-default"
  defp form_variant_class(:inline), do: "form-inline flex flex-wrap items-end gap-4"
  defp form_variant_class(:floating), do: "form-floating"
  
  defp form_content_class(:inline), do: "flex-1 flex flex-wrap gap-4"
  defp form_content_class(_), do: "space-y-4"
  
  defp form_actions_class(:inline), do: "form-actions"
  defp form_actions_class(_), do: "form-actions mt-6 flex gap-2"
  
  defp humanize(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
  defp humanize(string), do: string
end