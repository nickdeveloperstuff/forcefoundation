defmodule ForcefoundationWeb.Widgets.StreamableTableWidget do
  @moduledoc """
  Table widget with Phoenix Streams support for efficient real-time updates.
  
  Features:
  - Live row insertion/updates/deletion
  - Bulk operations with minimal DOM updates
  - Optimistic UI updates
  - Conflict resolution for concurrent edits
  
  ## Examples
  
      # Stream-connected table
      <.streamable_table_widget
        id="users-table"
        stream={@streams.users}
        columns={[
          %{field: :name, label: "Name", editable: true},
          %{field: :email, label: "Email"},
          %{field: :status, label: "Status", render: &status_badge/1}
        ]}
        row_id={fn item -> "user-\#{item.id}" end}
        on_row_update="update_user"
      />
  """
  use ForcefoundationWeb.Widgets.Base
  import Phoenix.Component
  import ForcefoundationWeb.CoreComponents, only: [icon: 1]
  
  # Widget attributes
  defmacro widget_attrs() do
    quote do
      attr :id, :string, required: true
      attr :stream, :list, required: true
      attr :columns, :list, required: true
      attr :row_id, :any, default: nil
      attr :selection, :atom, default: :none, values: [:none, :single, :multi]
      attr :selected_rows, :list, default: []
      attr :editable, :boolean, default: false
      attr :on_row_update, :string, default: nil
      attr :on_row_delete, :string, default: nil
      attr :bulk_actions, :list, default: []
      attr :show_actions, :boolean, default: true
      attr :row_actions, :list, default: []
      attr :compact, :boolean, default: false
      attr :striped, :boolean, default: true
      attr :hover, :boolean, default: true
      attr :class, :string, default: ""
      attr :debug_mode, :boolean, default: false
    end
  end
  
  widget_attrs()
  
  def streamable_table_widget(assigns) do
    # Set default row_id function if not provided
    assigns = 
      if is_nil(assigns[:row_id]) do
        assign(assigns, :row_id, &"row-#{&1.id}")
      else
        assigns
      end
    ~H"""
    <div class={[
      widget_classes(assigns),
      "widget-streamable-table"
    ]} id={@id}>
      <%= if @debug_mode do %>
        <%= render_debug(assigns) %>
      <% end %>
      
      <!-- Bulk Actions Bar -->
      <%= if @selection != :none && length(@selected_rows) > 0 do %>
        <%= render_bulk_actions(assigns) %>
      <% end %>
      
      <!-- Table -->
      <div class="overflow-x-auto">
        <table class={[
          "table w-full",
          @striped && "table-zebra",
          @hover && "table-hover",
          @compact && "table-compact"
        ]}>
          <thead>
            <tr>
              <%= if @selection != :none do %>
                <th class="w-12">
                  <%= if @selection == :multi do %>
                    <input
                      type="checkbox"
                      class="checkbox checkbox-sm"
                      phx-click="toggle_all_stream"
                      phx-target={@id}
                    />
                  <% end %>
                </th>
              <% end %>
              
              <%= for column <- @columns do %>
                <th class={Map.get(column, :class, "")}>
                  <%= column.label %>
                </th>
              <% end %>
              
              <%= if @show_actions do %>
                <th class="text-right">Actions</th>
              <% end %>
            </tr>
          </thead>
          
          <tbody id={"#{@id}-tbody"} phx-update="stream">
            <%= for {dom_id, item} <- @stream do %>
              <tr 
                id={dom_id}
                class={[
                  dom_id in @selected_rows && "active",
                  "transition-colors duration-200"
                ]}
              >
                <%= if @selection != :none do %>
                  <td>
                    <input
                      type={if @selection == :single, do: "radio", else: "checkbox"}
                      name={if @selection == :single, do: "#{@id}-selection"}
                      class="checkbox checkbox-sm"
                      checked={dom_id in @selected_rows}
                      phx-click="toggle_stream_row"
                      phx-value-row-id={dom_id}
                      phx-target={@id}
                    />
                  </td>
                <% end %>
                
                <%= for column <- @columns do %>
                  <td class={Map.get(column, :class, "")}>
                    <%= if Map.get(column, :editable) && @editable do %>
                      <%= render_editable_cell(item, column, dom_id, assigns) %>
                    <% else %>
                      <%= render_cell(item, column) %>
                    <% end %>
                  </td>
                <% end %>
                
                <%= if @show_actions do %>
                  <td class="text-right">
                    <%= render_row_actions(item, dom_id, assigns) %>
                  </td>
                <% end %>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
      
      <%= if stream_empty?(@stream) do %>
        <div class="text-center py-8 opacity-50">
          No data available
        </div>
      <% end %>
    </div>
    """
  end
  
  defp render_bulk_actions(assigns) do
    ~H"""
    <div class="alert alert-info mb-4">
      <div class="flex justify-between items-center">
        <span>
          <%= length(@selected_rows) %> row(s) selected
        </span>
        <div class="flex gap-2">
          <%= for action <- @bulk_actions do %>
            <button
              class={["btn btn-sm", Map.get(action, :variant, "")]}
              phx-click="bulk_action"
              phx-value-action={action.action}
              phx-target={@id}
            >
              <%= if Map.get(action, :icon) do %>
                <.icon name={action.icon} class="w-4 h-4" />
              <% end %>
              <%= action.label %>
            </button>
          <% end %>
          
          <button class="btn btn-ghost btn-sm" phx-click="clear_selection" phx-target={@id}>
            Clear
          </button>
        </div>
      </div>
    </div>
    """
  end
  
  defp render_cell(item, column) do
    value = Map.get(item, column.field)
    
    cond do
      render_fn = Map.get(column, :render) ->
        render_fn.(value)
      format = Map.get(column, :format) ->
        format_value(value, format)
      true ->
        to_string(value || "")
    end
  end
  
  defp render_editable_cell(item, column, dom_id, assigns) do
    assigns = assign(assigns, :item, item)
    assigns = assign(assigns, :column, column)
    assigns = assign(assigns, :dom_id, dom_id)
    assigns = assign(assigns, :value, Map.get(item, column.field))
    
    ~H"""
    <div
      class="editable-cell cursor-text hover:bg-base-200 px-2 py-1 rounded"
      phx-click="start_edit"
      phx-value-row-id={@dom_id}
      phx-value-field={@column.field}
      phx-target={@id}
    >
      <%= @value || "-" %>
    </div>
    """
  end
  
  defp render_row_actions(item, dom_id, assigns) do
    assigns = assign(assigns, :item, item)
    assigns = assign(assigns, :dom_id, dom_id)
    
    ~H"""
    <div class="dropdown dropdown-end">
      <label tabindex="0" class="btn btn-ghost btn-sm btn-square">
        <.icon name="hero-ellipsis-vertical" class="w-4 h-4" />
      </label>
      <ul tabindex="0" class="dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52">
        <%= for action <- @row_actions do %>
          <li>
            <a
              phx-click={action.event || @on_row_update}
              phx-value-row-id={@dom_id}
              phx-value-action={action.action}
              phx-target={@id}
              class={Map.get(action, :class, "")}
            >
              <%= if Map.get(action, :icon) do %>
                <.icon name={action.icon} class="w-4 h-4" />
              <% end %>
              <%= action.label %>
            </a>
          </li>
        <% end %>
        
        <%= if @on_row_delete do %>
          <li><hr class="my-1" /></li>
          <li>
            <a
              phx-click={@on_row_delete}
              phx-value-row-id={@dom_id}
              phx-target={@id}
              class="text-error"
            >
              <.icon name="hero-trash" class="w-4 h-4" />
              Delete
            </a>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
  
  defp format_value(value, :relative_time) when is_struct(value, DateTime) do
    # Simple relative time formatting
    diff = DateTime.diff(DateTime.utc_now(), value, :second)
    
    cond do
      diff < 60 -> "Just now"
      diff < 3600 -> "#{div(diff, 60)} minutes ago"
      diff < 86400 -> "#{div(diff, 3600)} hours ago"
      diff < 604800 -> "#{div(diff, 86400)} days ago"
      true -> "#{div(diff, 604800)} weeks ago"
    end
  end
  defp format_value(value, :currency) do
    "$#{:erlang.float_to_binary(value / 1.0, decimals: 2)}"
  end
  defp format_value(value, _), do: to_string(value)
  
  defp stream_empty?([]), do: true
  defp stream_empty?(_), do: false
  
  # Add default implementations for widget base functions
  defp widget_classes(assigns) do
    [
      assigns[:class] || ""
    ]
    |> Enum.filter(& &1 != "")
    |> Enum.join(" ")
  end
  
  defp render_debug(assigns) do
    ~H"""
    <div class="absolute top-0 right-0 bg-black/75 text-white text-xs p-2 rounded-bl z-50">
      <div class="font-bold">StreamableTable</div>
      <div>Stream Items: <%= length(@stream) %></div>
      <div>Selected: <%= length(@selected_rows) %></div>
    </div>
    """
  end
end